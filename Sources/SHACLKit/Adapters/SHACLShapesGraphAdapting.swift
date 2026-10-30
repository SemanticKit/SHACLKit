/// Turns a source of shapes into a decoded shapes graph.
public protocol SHACLShapesGraphAdapting: Sendable {
    associatedtype Source
    func adapt(_ source: Source) throws -> SHACLShapesGraph
}
