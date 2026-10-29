import Foundation

public protocol SHACLShapesGraphAdapting: Sendable {
    associatedtype Source
    func adapt(_ source: Source) throws -> SHACLShapesGraph
}
