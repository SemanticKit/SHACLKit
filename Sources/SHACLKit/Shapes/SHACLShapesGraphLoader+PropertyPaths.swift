import Foundation

extension SHACLShapesGraphLoader {
    func parsePropertyPath(
        _ term: String,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> SHACLPropertyPath? {
        var visited: Set<String> = []
        return parsePropertyPath(
            term,
            triplesBySubject: triplesBySubject,
            visited: &visited
        )
    }

    func parsePropertyPath(
        _ term: String,
        triplesBySubject: [String: [SHACLTriple]],
        visited: inout Set<String>
    ) -> SHACLPropertyPath? {
        if visited.contains(term) {
            return nil
        }
        visited.insert(term)
        defer { visited.remove(term) }

        if hasRDFListStructure(term, triplesBySubject: triplesBySubject) {
            let members = resolveRDFListTermsOrdered(term, triplesBySubject: triplesBySubject)
            let parsedMembers = members.compactMap { member in
                parsePropertyPath(
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
               let nested = parsePropertyPath(
                   inverseObject,
                   triplesBySubject: triplesBySubject,
                   visited: &visited
               ) {
                return .inverse(nested)
            }

            if let alternativeList = triples.first(where: { $0.predicate == SHACLIRIs.alternativePath })?.object {
                let members = resolveRDFListTermsOrdered(alternativeList, triplesBySubject: triplesBySubject)
                let parsedMembers = members.compactMap { member in
                    parsePropertyPath(
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
               let nested = parsePropertyPath(
                   zeroOrMoreObject,
                   triplesBySubject: triplesBySubject,
                   visited: &visited
               ) {
                return .zeroOrMore(nested)
            }

            if let oneOrMoreObject = triples.first(where: { $0.predicate == SHACLIRIs.oneOrMorePath })?.object,
               let nested = parsePropertyPath(
                   oneOrMoreObject,
                   triplesBySubject: triplesBySubject,
                   visited: &visited
               ) {
                return .oneOrMore(nested)
            }

            if let zeroOrOneObject = triples.first(where: { $0.predicate == SHACLIRIs.zeroOrOnePath })?.object,
               let nested = parsePropertyPath(
                   zeroOrOneObject,
                   triplesBySubject: triplesBySubject,
                   visited: &visited
               ) {
                return .zeroOrOne(nested)
            }
        }

        if isIRIReferenceTerm(term) {
            return .predicate(term)
        }

        return nil
    }
}
