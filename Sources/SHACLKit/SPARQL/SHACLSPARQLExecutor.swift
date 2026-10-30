import RDFCore

/// Runs the SPARQL queries of SPARQL-based constraints and targets (SHACL
/// 1.2 SPARQL Extensions).
///
/// SPARQL is an expression language outside the runtime: the validator
/// hands the executor the query text, with `$this` pre-bound to the focus
/// node, and the executor gives back RDF terms.
public protocol SHACLSPARQLExecutor: Sendable {
    /// The nodes a `SELECT` query binds, with `$this` bound to `focusNode`.
    func select(query: String, focusNode: ObjectTerm?, dataGraph: Graph, shapesGraph: SHACLShapesGraph) throws -> [ObjectTerm]

    /// The result of an `ASK` query, with `$this` bound to `focusNode`.
    func ask(query: String, focusNode: ObjectTerm?, dataGraph: Graph, shapesGraph: SHACLShapesGraph) throws -> Bool
}
