import RDFCore

/// A data graph adapter made from a closure.
public struct AnySHACLDataGraphAdapter<Source>: SHACLDataGraphAdapting {
    private let adapter: @Sendable (Source) throws -> Graph

    public init(_ adapter: @escaping @Sendable (Source) throws -> Graph) {
        self.adapter = adapter
    }

    public func adapt(_ source: Source) throws -> Graph {
        try adapter(source)
    }
}
