import Foundation

public protocol SHACLShapesGraphLoading: Sendable {
    func load(from data: Data) throws -> SHACLShapesGraph
}
