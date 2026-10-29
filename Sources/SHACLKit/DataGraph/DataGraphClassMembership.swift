import Foundation

func transitiveSubclasses(of classIRI: String, dataGraph: SHACLDataGraph) -> Set<String> {
    var descendants: Set<String> = []
    var frontier: Set<String> = [classIRI]

    while !frontier.isEmpty {
        let next = Set(
            dataGraph.triples
                .filter { frontier.contains($0.object) && $0.predicate == SHACLIRIs.rdfsSubClassOf }
                .map(\.subject)
        )
        let delta = next.subtracting(descendants)
        if delta.isEmpty {
            break
        }
        descendants.formUnion(delta)
        frontier = delta
    }

    return descendants
}

func nodeSatisfiesClassConstraint(
    _ node: String,
    classIRI: String,
    dataGraph: SHACLDataGraph
) -> Bool {
    let acceptedTypes = transitiveSubclasses(of: classIRI, dataGraph: dataGraph).union([classIRI])
    return dataGraph.triples.contains {
        $0.subject == node && $0.predicate == SHACLIRIs.rdfType && acceptedTypes.contains($0.object)
    }
}
