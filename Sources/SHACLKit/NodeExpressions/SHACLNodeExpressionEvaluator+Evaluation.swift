import Foundation

extension SHACLNodeExpressionEvaluator {
    func evaluateTerm(
        _ term: String,
        focusNode: String,
        shapesGraph: SHACLShapesGraph,
        expressionsByIRI: [String: SHACLNodeExpressionDefinition],
        dataGraph: SHACLDataGraph?,
        variableBindings: [String: Set<String>],
        depth: Int,
        visited: inout Set<String>
    ) -> Set<String> {
        if term == SHACLIRIs.shThis {
            return [focusNode]
        }

        guard let expression = expressionsByIRI[term] else {
            if term.hasPrefix("_:") {
                // Anonymous node-expression placeholders (e.g. []) are treated as empty expressions.
                return []
            }
            return [term]
        }

        if depth > maxDepth || visited.contains(expression.expressionIRI) {
            return []
        }

        visited.insert(expression.expressionIRI)
        defer { visited.remove(expression.expressionIRI) }

        switch expression.kind {
        case .union(let members):
            return members.reduce(into: Set<String>()) { result, member in
                result.formUnion(
                    evaluateTerm(
                        member,
                        focusNode: focusNode,
                        shapesGraph: shapesGraph,
                        expressionsByIRI: expressionsByIRI,
                        dataGraph: dataGraph,
                        variableBindings: variableBindings,
                        depth: depth + 1,
                        visited: &visited
                    )
                )
            }
        case .intersection(let members):
            guard let first = members.first else {
                return []
            }
            let initial = evaluateTerm(
                first,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return members.dropFirst().reduce(initial) { partial, member in
                partial.intersection(
                    evaluateTerm(
                        member,
                        focusNode: focusNode,
                        shapesGraph: shapesGraph,
                        expressionsByIRI: expressionsByIRI,
                        dataGraph: dataGraph,
                        variableBindings: variableBindings,
                        depth: depth + 1,
                        visited: &visited
                    )
                )
            }
        case .nodes(let members):
            return members.reduce(into: Set<String>()) { result, member in
                result.formUnion(
                    evaluateTerm(
                        member,
                        focusNode: focusNode,
                        shapesGraph: shapesGraph,
                        expressionsByIRI: expressionsByIRI,
                        dataGraph: dataGraph,
                        variableBindings: variableBindings,
                        depth: depth + 1,
                        visited: &visited
                    )
                )
            }
        case .exists(let input):
            let output = evaluateTerm(
                input,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return output.isEmpty
                ? ["\"false\"^^\(SHACLIRIs.xsdBoolean)"]
                : ["\"true\"^^\(SHACLIRIs.xsdBoolean)"]
        case .count(let inputTerm, let staticListLength):
            if let staticListLength {
                return ["\(staticListLength)"]
            }
            let output = evaluateTerm(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return ["\(output.count)"]
        case .variable(let variableName):
            if let binding = variableBindings[variableName] {
                return binding
            }
            if variableName == "focusNode" {
                return [focusNode]
            }
            return []
        case .distinct(let inputTerm, let staticListMembers):
            return staticListMembers.map(Set.init) ?? evaluateTerm(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
        case .matchAll(let inputTerm, let shapeTerm, let staticListMembers):
            let inputNodes = staticListMembers.map(Set.init) ?? evaluateTerm(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            if inputNodes.isEmpty {
                return ["\"true\"^^\(SHACLIRIs.xsdBoolean)"]
            }
            guard let dataGraph else {
                return ["\"false\"^^\(SHACLIRIs.xsdBoolean)"]
            }
            let matched = nodesMatching(
                shapeIRI: shapeTerm,
                candidates: inputNodes,
                shapesGraph: shapesGraph,
                dataGraph: dataGraph
            )
            return matched.count == inputNodes.count
                ? ["\"true\"^^\(SHACLIRIs.xsdBoolean)"]
                : ["\"false\"^^\(SHACLIRIs.xsdBoolean)"]
        case .filterShape(let inputTerm, let shapeTerm, let staticListMembers):
            let inputNodes = staticListMembers.map(Set.init) ?? evaluateTerm(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            guard let dataGraph else {
                return []
            }
            return nodesMatching(
                shapeIRI: shapeTerm,
                candidates: inputNodes,
                shapesGraph: shapesGraph,
                dataGraph: dataGraph
            )
        case .instancesOf(let classIRI):
            guard let dataGraph else {
                return []
            }
            let subclasses = transitiveSubclasses(of: classIRI, dataGraph: dataGraph)
            let matchingClasses = subclasses.union([classIRI])
            return Set(
                dataGraph.triples
                    .filter { $0.predicate == SHACLIRIs.rdfType && matchingClasses.contains($0.object) }
                    .map(\.subject)
            )
        case .nodesMatching(let shapeIRI):
            guard let dataGraph else {
                return []
            }
            let candidates = Set(dataGraph.triples.map(\.subject) + dataGraph.triples.map(\.object))
            return nodesMatching(shapeIRI: shapeIRI, candidates: candidates, shapesGraph: shapesGraph, dataGraph: dataGraph)
        case .min(let inputTerm, let staticListMembers):
            let output = staticListMembers.map(Set.init) ?? evaluateTerm(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            guard let minimum = numericExtremeTerm(from: output, findMaximum: false) else {
                return []
            }
            return [minimum]
        case .max(let inputTerm, let staticListMembers):
            let output = staticListMembers.map(Set.init) ?? evaluateTerm(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            guard let maximum = numericExtremeTerm(from: output, findMaximum: true) else {
                return []
            }
            return [maximum]
        case .sum(let inputTerm, let staticListMembers):
            let output = staticListMembers.map(Set.init) ?? evaluateTerm(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return [numericSum(from: output)]
        case .ifThenElse(let condition, let thenTerm, let elseTerm):
            let conditionOutput = evaluateTerm(
                condition,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            if isTrueOnlyExpressionSet(conditionOutput) {
                return evaluateTerm(
                    thenTerm,
                    focusNode: focusNode,
                    shapesGraph: shapesGraph,
                    expressionsByIRI: expressionsByIRI,
                    dataGraph: dataGraph,
                    variableBindings: variableBindings,
                    depth: depth + 1,
                    visited: &visited
                )
            }
            guard let elseTerm else {
                return []
            }
            return evaluateTerm(
                elseTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
        case .pathValues(let path, let focusNodeTerm):
            guard let dataGraph else {
                return []
            }
            let focusNodes: Set<String>
            if let focusNodeTerm {
                focusNodes = evaluateTerm(
                    focusNodeTerm,
                    focusNode: focusNode,
                    shapesGraph: shapesGraph,
                    expressionsByIRI: expressionsByIRI,
                    dataGraph: dataGraph,
                    variableBindings: variableBindings,
                    depth: depth + 1,
                    visited: &visited
                )
            } else {
                focusNodes = [focusNode]
            }
            return focusNodes.reduce(into: Set<String>()) { result, node in
                result.formUnion(evaluatePropertyPathValues(path, from: node, dataGraph: dataGraph))
            }
        case .concat(let inputTerm, let staticListMembers):
            let terms = staticListMembers ?? [inputTerm]
            return terms.reduce(into: Set<String>()) { result, term in
                result.formUnion(
                    evaluateTerm(
                        term,
                        focusNode: focusNode,
                        shapesGraph: shapesGraph,
                        expressionsByIRI: expressionsByIRI,
                        dataGraph: dataGraph,
                        variableBindings: variableBindings,
                        depth: depth + 1,
                        visited: &visited
                    )
                )
            }
        case .remove(let inputTerm, let removeTerm, let staticInputListMembers, let staticRemoveListMembers):
            let inputNodes = staticInputListMembers.map(Set.init) ?? evaluateTerm(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            let removeNodes = staticRemoveListMembers.map(Set.init) ?? evaluateTerm(
                removeTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return inputNodes.subtracting(removeNodes)
        case .flatMap(let inputTerm, let mapTerm, let staticInputListMembers):
            let inputNodes = staticInputListMembers.map(Set.init) ?? evaluateTerm(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return inputNodes.reduce(into: Set<String>()) { result, inputNode in
                result.formUnion(
                    evaluateTerm(
                        mapTerm,
                        focusNode: inputNode,
                        shapesGraph: shapesGraph,
                        expressionsByIRI: expressionsByIRI,
                        dataGraph: dataGraph,
                        variableBindings: variableBindings,
                        depth: depth + 1,
                        visited: &visited
                    )
                )
            }
        case .limit(let inputTerm, let count, let staticListMembers):
            let ordered = staticListMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return Set(ordered.prefix(max(0, count)))
        case .offset(let inputTerm, let count, let staticListMembers):
            let ordered = staticListMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return Set(ordered.dropFirst(max(0, count)))
        case .findFirst(let inputTerm, let shapeTerm, let staticOrderedInputMembers):
            let orderedInputs = staticOrderedInputMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            if orderedInputs.isEmpty {
                return []
            }
            let evaluationGraph = dataGraph ?? SHACLDataGraph(triples: [])
            let matched = nodesMatching(
                shapeIRI: shapeTerm,
                candidates: Set(orderedInputs),
                shapesGraph: shapesGraph,
                dataGraph: evaluationGraph
            )
            guard let first = orderedInputs.first(where: { matched.contains($0) }) else {
                return []
            }
            return [first]
        case .orderBy(let inputTerm, let keyTerm, let descending, let staticListMembers):
            let ordered = staticListMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            if ordered.isEmpty {
                return []
            }
            let sorted = sortOrderByNodes(
                ordered,
                keyTerm: keyTerm,
                descending: descending,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return Set(sorted)
        }
    }
}
