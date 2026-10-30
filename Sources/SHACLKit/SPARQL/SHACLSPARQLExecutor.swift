import RDFCore

/// One solution of a SPARQL `SELECT` query: the RDF term each variable of
/// the solution is bound to, by the variable's name without `?` or `$`.
public typealias SHACLSPARQLSolution = [String: ObjectTerm]

/// Runs the SPARQL queries of SPARQL-based constraints and targets (SHACL
/// 1.2 SPARQL Extensions).
///
/// SPARQL is an expression language outside the runtime: the validator
/// hands the executor the query text and the variables it pre-binds
/// (`this`, and `value` for an `ASK` query on a value node; SHACL 1.2
/// SPARQL Extensions §5.2), and the executor gives back RDF terms.
public protocol SHACLSPARQLExecutor: Sendable {
    /// The solutions of a `SELECT` query, with the pre-bound variables
    /// bound to `bindings`.
    func select(query: String, bindings: SHACLSPARQLSolution, dataGraph: Graph, shapesGraph: SHACLShapesGraph) throws -> [SHACLSPARQLSolution]

    /// The result of an `ASK` query, with the pre-bound variables bound to
    /// `bindings`.
    func ask(query: String, bindings: SHACLSPARQLSolution, dataGraph: Graph, shapesGraph: SHACLShapesGraph) throws -> Bool
}
