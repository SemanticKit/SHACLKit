import Foundation

public struct AnySHACLDataGraphAdapter<Source>: SHACLDataGraphAdapting {
    private let adapter: @Sendable (Source) throws -> SHACLDataGraph

    public init(_ adapter: @escaping @Sendable (Source) throws -> SHACLDataGraph) {
        self.adapter = adapter
    }

    public func adapt(_ source: Source) throws -> SHACLDataGraph {
        try adapter(source)
    }
}
