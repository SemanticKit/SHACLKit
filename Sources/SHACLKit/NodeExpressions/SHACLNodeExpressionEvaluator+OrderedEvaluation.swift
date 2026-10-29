import Foundation

extension SHACLNodeExpressionEvaluator {
    func evaluateTermOrdered(
        _ term: String,
        focusNode: String,
        shapesGraph: SHACLShapesGraph,
        expressionsByIRI: [String: SHACLNodeExpressionDefinition],
        dataGraph: SHACLDataGraph?,
        variableBindings: [String: Set<String>],
        depth: Int,
        visited: inout Set<String>
    ) -> [String] {
        guard let expression = expressionsByIRI[term] else {
            return evaluateTerm(
                term,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth,
                visited: &visited
            ).sorted()
        }

        switch expression.kind {
        case .nodes(let members):
            var ordered: [String] = []
            for member in members {
                ordered.append(contentsOf: evaluateTermOrdered(
                    member,
                    focusNode: focusNode,
                    shapesGraph: shapesGraph,
                    expressionsByIRI: expressionsByIRI,
                    dataGraph: dataGraph,
                    variableBindings: variableBindings,
                    depth: depth + 1,
                    visited: &visited
                ))
            }
            return ordered
        case .concat(let inputTerm, let staticListMembers):
            let terms = staticListMembers ?? [inputTerm]
            var ordered: [String] = []
            for term in terms {
                ordered.append(contentsOf: evaluateTermOrdered(
                    term,
                    focusNode: focusNode,
                    shapesGraph: shapesGraph,
                    expressionsByIRI: expressionsByIRI,
                    dataGraph: dataGraph,
                    variableBindings: variableBindings,
                    depth: depth + 1,
                    visited: &visited
                ))
            }
            return ordered
        case .remove(let inputTerm, let removeTerm, let staticInputListMembers, let staticRemoveListMembers):
            let input = staticInputListMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            let removeNodes = Set(staticRemoveListMembers ?? evaluateTermOrdered(
                removeTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            ))
            return input.filter { !removeNodes.contains($0) }
        case .distinct(let inputTerm, let staticListMembers):
            let input = staticListMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            var seen: Set<String> = []
            var ordered: [String] = []
            for node in input where !seen.contains(node) {
                seen.insert(node)
                ordered.append(node)
            }
            return ordered
        case .flatMap(let inputTerm, let mapTerm, let staticInputListMembers):
            let inputs = staticInputListMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            var ordered: [String] = []
            for input in inputs {
                ordered.append(contentsOf: evaluateTermOrdered(
                    mapTerm,
                    focusNode: input,
                    shapesGraph: shapesGraph,
                    expressionsByIRI: expressionsByIRI,
                    dataGraph: dataGraph,
                    variableBindings: variableBindings,
                    depth: depth + 1,
                    visited: &visited
                ))
            }
            return ordered
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
            return Array(ordered.prefix(max(0, count)))
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
            return Array(ordered.dropFirst(max(0, count)))
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
            let input = staticListMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return sortOrderByNodes(
                input,
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
        case .union(let members):
            var seen: Set<String> = []
            var ordered: [String] = []
            for member in members {
                let memberOrdered = evaluateTermOrdered(
                    member,
                    focusNode: focusNode,
                    shapesGraph: shapesGraph,
                    expressionsByIRI: expressionsByIRI,
                    dataGraph: dataGraph,
                    variableBindings: variableBindings,
                    depth: depth + 1,
                    visited: &visited
                )
                for node in memberOrdered where !seen.contains(node) {
                    seen.insert(node)
                    ordered.append(node)
                }
            }
            return ordered
        case .intersection(let members):
            guard let first = members.first else {
                return []
            }
            let firstOrdered = evaluateTermOrdered(
                first,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            let remainingSets = members.dropFirst().map { member in
                Set(evaluateTerm(
                    member,
                    focusNode: focusNode,
                    shapesGraph: shapesGraph,
                    expressionsByIRI: expressionsByIRI,
                    dataGraph: dataGraph,
                    variableBindings: variableBindings,
                    depth: depth + 1,
                    visited: &visited
                ))
            }
            var seen: Set<String> = []
            var ordered: [String] = []
            for node in firstOrdered where !seen.contains(node) {
                if remainingSets.allSatisfy({ $0.contains(node) }) {
                    seen.insert(node)
                    ordered.append(node)
                }
            }
            return ordered
        case .filterShape(let inputTerm, let shapeTerm, let staticListMembers):
            let input = staticListMembers ?? evaluateTermOrdered(
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
            let matched = nodesMatching(
                shapeIRI: shapeTerm,
                candidates: Set(input),
                shapesGraph: shapesGraph,
                dataGraph: dataGraph
            )
            var seen: Set<String> = []
            var ordered: [String] = []
            for node in input where matched.contains(node) && !seen.contains(node) {
                seen.insert(node)
                ordered.append(node)
            }
            return ordered
        default:
            return evaluateTerm(
                term,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth,
                visited: &visited
            ).sorted()
        }
    }
}
