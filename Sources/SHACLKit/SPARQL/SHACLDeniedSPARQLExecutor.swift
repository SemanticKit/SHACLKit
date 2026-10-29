import Foundation

public struct SHACLDeniedSPARQLExecutor: SHACLSPARQLExecutor {
    public init() {}

    public func select(
        query: String,
        focusNode: String?,
        dataGraph: SHACLDataGraph,
        shapesGraph: SHACLShapesGraph
    ) throws -> [String] {
        throw SHACLError.notImplemented("SPARQL execution requires an explicit sandboxed SHACLSPARQLExecutor.")
    }

    public func ask(
        query: String,
        focusNode: String?,
        dataGraph: SHACLDataGraph,
        shapesGraph: SHACLShapesGraph
    ) throws -> Bool {
        throw SHACLError.notImplemented("SPARQL execution requires an explicit sandboxed SHACLSPARQLExecutor.")
    }
}
