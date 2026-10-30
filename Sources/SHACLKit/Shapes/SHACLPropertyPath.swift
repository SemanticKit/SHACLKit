import IRIKit
import RDFCore
import RDF
import struct RDFCore.Literal
import SHACL
import struct RDFCore.Graph

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
        if let inverse = nested(SHACL.inversePath.iri!) { return inverse.map(SHACLPropertyPath.inverse) }
        if let list = graph.object(of: node, SHACL.alternativePath.iri!) {
            return members(list).map(SHACLPropertyPath.alternative)
        }
        if let path = nested(SHACL.zeroOrMorePath.iri!) { return path.map(SHACLPropertyPath.zeroOrMore) }
        if let path = nested(SHACL.oneOrMorePath.iri!) { return path.map(SHACLPropertyPath.oneOrMore) }
        if let path = nested(SHACL.zeroOrOnePath.iri!) { return path.map(SHACLPropertyPath.zeroOrOne) }
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

extension SHACLPropertyPath {
    /// The path in SPARQL 1.2 property path syntax (§18.1.7), as a
    /// SPARQL-based constraint's `$PATH` is replaced by it (SHACL 1.2
    /// SPARQL Extensions §5.3.1).
    public var sparql: String {
        switch self {
        case .predicate(let iri): "<\(iri)>"
        case .inverse(let path): "^(\(path.sparql))"
        case .sequence(let paths): "(\(paths.map(\.sparql).joined(separator: "/")))"
        case .alternative(let paths): "(\(paths.map(\.sparql).joined(separator: "|")))"
        case .zeroOrMore(let path): "(\(path.sparql))*"
        case .oneOrMore(let path): "(\(path.sparql))+"
        case .zeroOrOne(let path): "(\(path.sparql))?"
        }
    }

    /// Writes the path into `graph` as SHACL 1.2 Core §2.3.1 describes it,
    /// and gives the node that is the path: the IRI of a predicate path, or
    /// a blank node from `blankNode` for any other path.
    func encode(into graph: inout Graph, blankNode: () -> BlankNode) -> ObjectTerm {
        func node(_ predicate: IRI, _ path: SHACLPropertyPath) -> ObjectTerm {
            let subject = blankNode()
            let object = path.encode(into: &graph, blankNode: blankNode)
            graph.insert(Graph.Element(subject: .blankNode(subject), predicate: predicate, object: object))
            return .blankNode(subject)
        }
        func list(_ paths: [SHACLPropertyPath]) -> ObjectTerm {
            var head = ObjectTerm.iri(RDF.nil.iri!)
            for path in paths.reversed() {
                let cell = blankNode()
                graph.insert(Graph.Element(subject: .blankNode(cell), predicate: RDF.first.iri!, object: path.encode(into: &graph, blankNode: blankNode)))
                graph.insert(Graph.Element(subject: .blankNode(cell), predicate: RDF.rest.iri!, object: head))
                head = .blankNode(cell)
            }
            return head
        }
        switch self {
        case .predicate(let iri):
            return .iri(iri)
        case .inverse(let path):
            return node(SHACL.inversePath.iri!, path)
        case .sequence(let paths):
            return list(paths)
        case .alternative(let paths):
            let subject = blankNode()
            graph.insert(Graph.Element(subject: .blankNode(subject), predicate: SHACL.alternativePath.iri!, object: list(paths)))
            return .blankNode(subject)
        case .zeroOrMore(let path):
            return node(SHACL.zeroOrMorePath.iri!, path)
        case .oneOrMore(let path):
            return node(SHACL.oneOrMorePath.iri!, path)
        case .zeroOrOne(let path):
            return node(SHACL.zeroOrOnePath.iri!, path)
        }
    }
}
