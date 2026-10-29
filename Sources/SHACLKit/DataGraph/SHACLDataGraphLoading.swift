import Foundation

public protocol SHACLDataGraphLoading: Sendable {
    func load(from data: Data) throws -> SHACLDataGraph
}
