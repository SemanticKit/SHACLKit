import RDFCore

/// The executor a validator has when it is given none: it runs no query, so
/// a shapes graph with SPARQL-based constraints or targets cannot be
/// validated without an explicit, sandboxed executor.
public struct SHACLDeniedSPARQLExecutor: SHACLSPARQLExecutor {
    public init() {}

    public func select(query: String, bindings: SHACLSPARQLSolution, dataGraph: Graph, shapesGraph: SHACLShapesGraph) throws -> [SHACLSPARQLSolution] {
        throw SHACLError.sparqlNotExecuted("SPARQL execution requires an explicit sandboxed SHACLSPARQLExecutor.")
    }

    public func ask(query: String, bindings: SHACLSPARQLSolution, dataGraph: Graph, shapesGraph: SHACLShapesGraph) throws -> Bool {
        throw SHACLError.sparqlNotExecuted("SPARQL execution requires an explicit sandboxed SHACLSPARQLExecutor.")
    }
}
