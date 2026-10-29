import Foundation

public protocol SHACLSPARQLExecutor: Sendable {
    func select(
        query: String,
        focusNode: String?,
        dataGraph: SHACLDataGraph,
        shapesGraph: SHACLShapesGraph
    ) throws -> [String]

    func ask(
        query: String,
        focusNode: String?,
        dataGraph: SHACLDataGraph,
        shapesGraph: SHACLShapesGraph
    ) throws -> Bool
}
