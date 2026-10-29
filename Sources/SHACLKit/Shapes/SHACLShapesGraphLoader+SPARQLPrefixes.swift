import Foundation

extension SHACLShapesGraphLoader {
    func resolveSPARQLPrefixes(
        for prefixesIRIs: Set<String>,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> [String: String] {
        var resolved: [String: String] = [:]
        for prefixesIRI in prefixesIRIs.sorted() {
            guard let prefixTriples = triplesBySubject[prefixesIRI] else {
                continue
            }
            let declareNodes = prefixTriples
                .filter { $0.predicate == SHACLIRIs.declare }
                .map(\.object)
                .sorted()
            for declareNode in declareNodes {
                guard let declareTriples = triplesBySubject[declareNode],
                      let prefixTerm = declareTriples.first(where: { $0.predicate == SHACLIRIs.prefix })?.object,
                      let namespaceTerm = declareTriples.first(where: { $0.predicate == SHACLIRIs.namespace })?.object else {
                    continue
                }
                let prefix = parsedLiteralLexicalForm(prefixTerm) ?? prefixTerm
                let namespace = parsedLiteralLexicalForm(namespaceTerm) ?? namespaceTerm
                if !namespace.isEmpty {
                    resolved[prefix] = namespace
                }
            }
        }
        return resolved
    }
}
