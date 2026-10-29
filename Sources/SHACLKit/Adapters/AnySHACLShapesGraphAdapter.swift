import Foundation

public struct AnySHACLShapesGraphAdapter<Source>: SHACLShapesGraphAdapting {
    private let adapter: @Sendable (Source) throws -> SHACLShapesGraph

    public init(_ adapter: @escaping @Sendable (Source) throws -> SHACLShapesGraph) {
        self.adapter = adapter
    }

    public func adapt(_ source: Source) throws -> SHACLShapesGraph {
        try adapter(source)
    }
}
