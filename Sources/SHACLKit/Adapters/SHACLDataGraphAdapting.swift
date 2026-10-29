import Foundation

public protocol SHACLDataGraphAdapting: Sendable {
    associatedtype Source
    func adapt(_ source: Source) throws -> SHACLDataGraph
}
