import IRIKit
import RDFCore

/// A SPARQL-based constraint or target of a shapes graph (SHACL 1.2 SPARQL
/// Extensions §5 and §6): SPARQL text, and the prefixes its `sh:prefixes`
/// declare.
///
/// SPARQL is an expression language outside the runtime, so a query is
/// text: it is handed to a ``SHACLSPARQLExecutor`` with the prefix
/// declarations it needs written into it.
public struct SHACLSPARQLQuery: Sendable, Hashable {
    /// The node of the constraint or target in the shapes graph.
    public let node: ObjectTerm

    /// The `sh:select` query.
    public let select: String?

    /// The `sh:ask` query.
    public let ask: String?

    /// The `sh:message` of the constraint.
    public let message: String?

    /// The namespaces of the prefixes `sh:prefixes` declares, by prefix.
    public let prefixes: [String: IRI]

    public init(node: ObjectTerm, select: String? = nil, ask: String? = nil, message: String? = nil, prefixes: [String: IRI] = [:]) {
        self.node = node
        self.select = select
        self.ask = ask
        self.message = message
        self.prefixes = prefixes
    }

    /// `query` with a `PREFIX` declaration for each declared prefix the
    /// query does not declare itself, in prefix order (SHACL 1.2 SPARQL
    /// Extensions §5.2.1: "the SPARQL query ... is prepended with PREFIX
    /// declarations").
    func prefixed(_ query: String) -> String {
        let declared = Set(query.matches(of: /(?im)^\s*prefix\s+([A-Za-z_][A-Za-z0-9_-]*|)\s*:/).map { String($0.1).lowercased() })
        let lines = prefixes.sorted { $0.key < $1.key }
            .filter { !declared.contains($0.key.lowercased()) }
            .map { "PREFIX \($0.key): <\($0.value)>" }
        return lines.isEmpty ? query : lines.joined(separator: "\n") + "\n" + query
    }
}
