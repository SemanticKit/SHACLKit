import IRIKit
import RDFCore
import RDFFormats
import SHACL
import struct RDFCore.Literal
import struct RDFCore.Graph

/// A SPARQL-based constraint or target of a shapes graph (SHACL 1.2 SPARQL
/// Extensions §5 and §6): SPARQL text, and the prefixes its `sh:prefixes`
/// declare.
///
/// SPARQL is an expression language outside the runtime, so a query is
/// text: it is handed to a ``SHACLSPARQLExecutor`` with the prefix
/// declarations it needs written into it, `$PATH` replaced by the shape's
/// path, and `$this` pre-bound to the focus node.
public struct SHACLSPARQLQuery: Sendable, Hashable {
    /// The node of the constraint or target in the shapes graph, a result's
    /// `sh:sourceConstraint`.
    public let node: ObjectTerm

    /// The `sh:select` query.
    public let select: String?

    /// The `sh:ask` query.
    public let ask: String?

    /// The `sh:message` of the constraint.
    public let message: String?

    /// `sh:deactivated`: a deactivated constraint is not evaluated.
    public let isDeactivated: Bool

    /// The namespaces of the prefixes `sh:prefixes` declares, by prefix.
    public let prefixes: [String: IRI]

    public init(
        node: ObjectTerm,
        select: String? = nil,
        ask: String? = nil,
        message: String? = nil,
        isDeactivated: Bool = false,
        prefixes: [String: IRI] = [:]
    ) {
        self.node = node
        self.select = select
        self.ask = ask
        self.message = message
        self.isDeactivated = isDeactivated
        self.prefixes = prefixes
    }

    /// Decodes the SPARQL-based constraint or target whose node is `node`.
    init(_ node: ObjectTerm, in graph: Graph) {
        var prefixes: [String: IRI] = [:]
        for declarations in graph.objects(of: node, IRIKit.IRI(of: SHACL.prefixes.self)!) {
            for declaration in graph.objects(of: declarations, IRIKit.IRI(of: SHACL.declare.self)!) {
                guard let prefix = graph.object(of: declaration, IRIKit.IRI(of: SHACL.prefix.self)!)?.stringValue,
                      let namespace = graph.object(of: declaration, IRIKit.IRI(of: SHACL.namespace.self)!)?.stringValue,
                      let iri = IRI(rawValue: namespace) else { continue }
                prefixes[prefix] = iri
            }
        }
        self.init(
            node: node,
            select: graph.object(of: node, IRIKit.IRI(of: SHACL.select.self)!)?.stringValue,
            ask: graph.object(of: node, IRIKit.IRI(of: SHACL.ask.self)!)?.stringValue,
            message: graph.object(of: node, IRIKit.IRI(of: SHACL.message.self)!)?.stringValue,
            isDeactivated: graph.object(of: node, IRIKit.IRI(of: SHACL.deactivated.self)!)?.literal?.isTrue ?? false,
            prefixes: prefixes
        )
    }

    /// `query` with a `PREFIX` declaration for each declared prefix the
    /// query does not declare itself, in prefix order (SHACL 1.2 SPARQL
    /// Extensions §5.2.1), and with `$PATH` replaced by the SPARQL form of
    /// `path` (§5.3.1).
    func text(of query: String, path: SHACLPropertyPath? = nil) -> String {
        let declared = Set(query.matches(of: /(?im)^\s*prefix\s+([A-Za-z_][A-Za-z0-9_-]*|)\s*:/).map { String($0.1).lowercased() })
        let lines = prefixes.sorted { $0.key < $1.key }
            .filter { !declared.contains($0.key.lowercased()) }
            .map { "PREFIX \($0.key): <\($0.value)>" }
        let body = path.map { query.replacing("$PATH", with: $0.sparql) } ?? query
        return lines.isEmpty ? body : lines.joined(separator: "\n") + "\n" + body
    }

    /// The solutions of the `sh:select` query with `$this` pre-bound to
    /// `focusNode`, or bound by the query when there is no focus node, as a
    /// SPARQL-based target's query binds it.
    func select(focusNode: ObjectTerm?, path: SHACLPropertyPath? = nil, in validation: Validation) throws -> [SHACLSPARQLSolution] {
        guard let select else { return [] }
        return try validation.sparqlExecutor.select(
            query: text(of: select, path: path),
            bindings: focusNode.map { ["this": $0] } ?? [:],
            dataGraph: validation.dataGraph,
            shapesGraph: validation.shapesGraph
        )
    }

    /// Whether the `sh:ask` query holds with `$this` pre-bound to
    /// `focusNode` and `$value` to `value`.
    func holds(focusNode: ObjectTerm, value: ObjectTerm, path: SHACLPropertyPath? = nil, in validation: Validation) throws -> Bool {
        guard let ask else { return true }
        return try validation.sparqlExecutor.ask(
            query: text(of: ask, path: path),
            bindings: ["this": focusNode, "value": value],
            dataGraph: validation.dataGraph,
            shapesGraph: validation.shapesGraph
        )
    }
}
