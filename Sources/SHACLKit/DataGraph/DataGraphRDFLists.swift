import Foundation

func hasRDFListStructureInDataGraph(
    _ term: String,
    triplesBySubject: [String: [SHACLDataTriple]]
) -> Bool {
    guard let triples = triplesBySubject[term] else {
        return false
    }
    return triples.contains(where: { $0.predicate == SHACLIRIs.rdfFirst })
}

func resolveRDFListTermsOrderedInDataGraph(
    _ headOrValue: String,
    triplesBySubject: [String: [SHACLDataTriple]]
) -> [String] {
    if headOrValue == SHACLIRIs.rdfNil {
        return []
    }

    guard let firstRestTriples = triplesBySubject[headOrValue],
          firstRestTriples.contains(where: { $0.predicate == SHACLIRIs.rdfFirst }) else {
        return [headOrValue]
    }

    var terms: [String] = []
    var current = headOrValue
    var visited: Set<String> = []

    while current != SHACLIRIs.rdfNil && !visited.contains(current) {
        visited.insert(current)
        guard let triples = triplesBySubject[current],
              let first = triples.first(where: { $0.predicate == SHACLIRIs.rdfFirst }),
              let rest = triples.first(where: { $0.predicate == SHACLIRIs.rdfRest }) else {
            break
        }
        terms.append(first.object)
        current = rest.object
    }

    return terms
}

func isIRIReferenceTermInDataGraph(_ term: String) -> Bool {
    if term.hasPrefix("_:") || term.hasPrefix("\"") {
        return false
    }
    if Double(term) != nil {
        return false
    }
    if term == "true" || term == "false" {
        return false
    }
    return term.contains(":")
}
