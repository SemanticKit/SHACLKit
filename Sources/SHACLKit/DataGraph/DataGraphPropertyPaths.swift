import Foundation

func evaluatePropertyPathValues(
    _ path: SHACLPropertyPath,
    from focusNode: String,
    dataGraph: SHACLDataGraph
) -> Set<String> {
    switch path {
    case .predicate(let predicateIRI):
        return Set(
            dataGraph.triples
                .filter { $0.subject == focusNode && $0.predicate == predicateIRI }
                .map(\.object)
        )
    case .inverse(let nested):
        let candidateNodes = Set(dataGraph.triples.map(\.subject) + dataGraph.triples.map(\.object))
        return Set(
            candidateNodes.filter { candidate in
                evaluatePropertyPathValues(nested, from: candidate, dataGraph: dataGraph).contains(focusNode)
            }
        )
    case .sequence(let members):
        return members.reduce(into: Set([focusNode])) { partial, member in
            let next = partial.reduce(into: Set<String>()) { nextSet, node in
                nextSet.formUnion(evaluatePropertyPathValues(member, from: node, dataGraph: dataGraph))
            }
            partial = next
        }
    case .alternative(let members):
        return members.reduce(into: Set<String>()) { partial, member in
            partial.formUnion(evaluatePropertyPathValues(member, from: focusNode, dataGraph: dataGraph))
        }
    case .zeroOrOne(let nested):
        return Set([focusNode]).union(evaluatePropertyPathValues(nested, from: focusNode, dataGraph: dataGraph))
    case .zeroOrMore(let nested):
        var reached: Set<String> = [focusNode]
        var frontier: Set<String> = [focusNode]
        while !frontier.isEmpty {
            let next = frontier.reduce(into: Set<String>()) { partial, node in
                partial.formUnion(evaluatePropertyPathValues(nested, from: node, dataGraph: dataGraph))
            }
            let delta = next.subtracting(reached)
            if delta.isEmpty {
                break
            }
            reached.formUnion(delta)
            frontier = delta
        }
        return reached
    case .oneOrMore(let nested):
        var reached = evaluatePropertyPathValues(nested, from: focusNode, dataGraph: dataGraph)
        var frontier = reached
        while !frontier.isEmpty {
            let next = frontier.reduce(into: Set<String>()) { partial, node in
                partial.formUnion(evaluatePropertyPathValues(nested, from: node, dataGraph: dataGraph))
            }
            let delta = next.subtracting(reached)
            if delta.isEmpty {
                break
            }
            reached.formUnion(delta)
            frontier = delta
        }
        return reached
    }
}

func evaluatePropertyPairComparisonValues(
    propertyPathTerm: String,
    focusNode: String,
    dataGraph: SHACLDataGraph
) -> [String] {
    let triplesBySubject = Dictionary(grouping: dataGraph.triples, by: \.subject)
    if let propertyPath = parsePropertyPathInDataGraph(propertyPathTerm, triplesBySubject: triplesBySubject) {
        return Array(evaluatePropertyPathValues(propertyPath, from: focusNode, dataGraph: dataGraph))
    }
    return dataGraph.triples
        .filter { $0.subject == focusNode && $0.predicate == propertyPathTerm }
        .map(\.object)
}

private func parsePropertyPathInDataGraph(
    _ term: String,
    triplesBySubject: [String: [SHACLDataTriple]]
) -> SHACLPropertyPath? {
    var visited: Set<String> = []
    return parsePropertyPathInDataGraph(term, triplesBySubject: triplesBySubject, visited: &visited)
}

private func parsePropertyPathInDataGraph(
    _ term: String,
    triplesBySubject: [String: [SHACLDataTriple]],
    visited: inout Set<String>
) -> SHACLPropertyPath? {
    if visited.contains(term) {
        return nil
    }
    visited.insert(term)
    defer { visited.remove(term) }

    if hasRDFListStructureInDataGraph(term, triplesBySubject: triplesBySubject) {
        let members = resolveRDFListTermsOrderedInDataGraph(term, triplesBySubject: triplesBySubject)
        let parsedMembers = members.compactMap { member in
            parsePropertyPathInDataGraph(
                member,
                triplesBySubject: triplesBySubject,
                visited: &visited
            )
        }
        guard !parsedMembers.isEmpty, parsedMembers.count == members.count else {
            return nil
        }
        if parsedMembers.count == 1 {
            return parsedMembers[0]
        }
        return .sequence(parsedMembers)
    }

    if let triples = triplesBySubject[term] {
        if let inverseObject = triples.first(where: { $0.predicate == SHACLIRIs.inversePath })?.object,
           let nested = parsePropertyPathInDataGraph(
               inverseObject,
               triplesBySubject: triplesBySubject,
               visited: &visited
           ) {
            return .inverse(nested)
        }

        if let alternativeList = triples.first(where: { $0.predicate == SHACLIRIs.alternativePath })?.object {
            let members = resolveRDFListTermsOrderedInDataGraph(alternativeList, triplesBySubject: triplesBySubject)
            let parsedMembers = members.compactMap { member in
                parsePropertyPathInDataGraph(
                    member,
                    triplesBySubject: triplesBySubject,
                    visited: &visited
                )
            }
            guard !parsedMembers.isEmpty, parsedMembers.count == members.count else {
                return nil
            }
            return .alternative(parsedMembers)
        }

        if let zeroOrMoreObject = triples.first(where: { $0.predicate == SHACLIRIs.zeroOrMorePath })?.object,
           let nested = parsePropertyPathInDataGraph(
               zeroOrMoreObject,
               triplesBySubject: triplesBySubject,
               visited: &visited
           ) {
            return .zeroOrMore(nested)
        }

        if let oneOrMoreObject = triples.first(where: { $0.predicate == SHACLIRIs.oneOrMorePath })?.object,
           let nested = parsePropertyPathInDataGraph(
               oneOrMoreObject,
               triplesBySubject: triplesBySubject,
               visited: &visited
           ) {
            return .oneOrMore(nested)
        }

        if let zeroOrOneObject = triples.first(where: { $0.predicate == SHACLIRIs.zeroOrOnePath })?.object,
           let nested = parsePropertyPathInDataGraph(
               zeroOrOneObject,
               triplesBySubject: triplesBySubject,
               visited: &visited
           ) {
            return .zeroOrOne(nested)
        }
    }

    if isIRIReferenceTermInDataGraph(term) {
        return .predicate(term)
    }

    return nil
}
