import IRIKit
import RDFCore

/// A SHACL property path (SHACL 1.2 Core §2.3.1).
///
/// A path is decoded from the node a shape's `sh:path` names, and is how a
/// property shape reaches its value nodes from a focus node: "the value
/// nodes are the nodes in the data graph that can be reached from the focus
/// node via the path".
public indirect enum SHACLPropertyPath: Sendable, Hashable {
    /// A predicate path: an IRI.
    case predicate(IRI)
    /// `sh:inversePath`.
    case inverse(SHACLPropertyPath)
    /// A sequence path: a SHACL list of paths.
    case sequence([SHACLPropertyPath])
    /// `sh:alternativePath`.
    case alternative([SHACLPropertyPath])
    /// `sh:zeroOrMorePath`.
    case zeroOrMore(SHACLPropertyPath)
    /// `sh:oneOrMorePath`.
    case oneOrMore(SHACLPropertyPath)
    /// `sh:zeroOrOnePath`.
    case zeroOrOne(SHACLPropertyPath)

    /// Decodes the path whose node is `node` in `graph`, or `nil` when the
    /// node is not a well-formed SHACL property path (§2.3.1.1 to §2.3.1.7).
    public init?(_ node: ObjectTerm, in graph: Graph) {
        var visiting: Set<ObjectTerm> = []
        guard let path = Self.decode(node, in: graph, visiting: &visiting) else { return nil }
        self = path
    }

    private static func decode(_ node: ObjectTerm, in graph: Graph, visiting: inout Set<ObjectTerm>) -> SHACLPropertyPath? {
        if case .iri(let iri) = node, !graph.isList(node) { return .predicate(iri) }
        guard visiting.insert(node).inserted else { return nil }
        defer { visiting.remove(node) }

        func nested(_ predicate: IRI) -> SHACLPropertyPath?? {
            guard let value = graph.object(of: node, predicate) else { return .none }
            return .some(decode(value, in: graph, visiting: &visiting))
        }
        func members(_ list: ObjectTerm) -> [SHACLPropertyPath]? {
            guard let items = graph.list(list), !items.isEmpty else { return nil }
            var paths: [SHACLPropertyPath] = []
            for item in items {
                guard let path = decode(item, in: graph, visiting: &visiting) else { return nil }
                paths.append(path)
            }
            return paths
        }

        if graph.isList(node) {
            return members(node).map { $0.count == 1 ? $0[0] : .sequence($0) }
        }
        if let inverse = nested(SHACL.inversePath.metadata.id) { return inverse.map(SHACLPropertyPath.inverse) }
        if let list = graph.object(of: node, SHACL.alternativePath.metadata.id) {
            return members(list).map(SHACLPropertyPath.alternative)
        }
        if let path = nested(SHACL.zeroOrMorePath.metadata.id) { return path.map(SHACLPropertyPath.zeroOrMore) }
        if let path = nested(SHACL.oneOrMorePath.metadata.id) { return path.map(SHACLPropertyPath.oneOrMore) }
        if let path = nested(SHACL.zeroOrOnePath.metadata.id) { return path.map(SHACLPropertyPath.zeroOrOne) }
        return nil
    }

    /// The predicate of a predicate path.
    public var predicate: IRI? {
        if case .predicate(let iri) = self { return iri }
        return nil
    }

    /// The nodes the path reaches from `node` in `graph` (SHACL 1.2 Core
    /// §2.3.1, in terms of SPARQL 1.2 property paths, §9.1).
    public func values(from node: ObjectTerm, in graph: Graph) -> [ObjectTerm] {
        switch self {
        case .predicate(let iri):
            return graph.objects(of: node, iri).uniqued()
        case .inverse(.predicate(let iri)):
            return graph.subjects(iri, node).uniqued()
        case .inverse(let path):
            return graph.nodes.filter { path.values(from: $0, in: graph).contains(node) }
        case .sequence(let paths):
            return paths.reduce([node]) { reached, path in
                reached.flatMap { path.values(from: $0, in: graph) }.uniqued()
            }
        case .alternative(let paths):
            return paths.flatMap { $0.values(from: node, in: graph) }.uniqued()
        case .zeroOrOne(let path):
            return ([node] + path.values(from: node, in: graph)).uniqued()
        case .zeroOrMore(let path):
            return Self.closure(of: path, from: [node], in: graph)
        case .oneOrMore(let path):
            return Self.closure(of: path, from: path.values(from: node, in: graph), in: graph)
        }
    }

    /// `start` and every node `path` reaches from them, repeatedly.
    private static func closure(of path: SHACLPropertyPath, from start: [ObjectTerm], in graph: Graph) -> [ObjectTerm] {
        var reached = start.uniqued()
        var seen = Set(reached)
        var frontier = reached
        while !frontier.isEmpty {
            let next = frontier.flatMap { path.values(from: $0, in: graph) }.filter { seen.insert($0).inserted }
            reached += next
            frontier = next
        }
        return reached
    }
}
