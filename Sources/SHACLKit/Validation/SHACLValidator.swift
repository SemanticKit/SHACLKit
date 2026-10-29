import Foundation

public protocol SHACLValidator: Sendable {
    func validate(dataGraph: Data, shapesGraph: Data) throws -> SHACLValidationResult
    func validate(dataGraph: SHACLDataGraph, shapesGraph: SHACLShapesGraph) throws -> SHACLValidationResult
}
