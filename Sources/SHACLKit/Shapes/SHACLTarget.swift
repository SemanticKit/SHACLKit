import IRIKit
import RDFCore
import RDFFormats
import SHACL
import struct RDFCore.Literal
import struct RDFCore.Graph

/// A target of a shape: how its focus nodes are found in the data graph
/// (SHACL 1.2 Core §2.1.3).
public enum SHACLTarget: Sendable, Hashable {
    /// `sh:targetNode` with a term: the term itself.
    case node(ObjectTerm)
    /// `sh:targetNode` with a node expression: its output.
    case nodeExpression(SHACLNodeExpression)
    /// `sh:targetClass`: the SHACL instances of the class.
    case `class`(ObjectTerm)
    /// `sh:targetSubjectsOf`: the subjects of triples with the predicate.
    case subjectsOf(IRI)
    /// `sh:targetObjectsOf`: the objects of triples with the predicate.
    case objectsOf(IRI)
    /// `sh:targetWhere`: the nodes that conform to the shape.
    case `where`(SHACLShape)
    /// A SPARQL-based target: the bindings of `$this` in its `sh:select`
    /// query (SHACL 1.2 SPARQL Extensions).
    case sparql(SHACLSPARQLQuery)
}

extension SHACLTarget {
    /// The parameters that declare targets.
    static var parameters: Set<IRI> {
        [
            IRIKit.IRI(of: SHACL.targetNode.self)!, IRIKit.IRI(of: SHACL.targetClass.self)!, IRIKit.IRI(of: SHACL.targetSubjectsOf.self)!,
            IRIKit.IRI(of: SHACL.targetObjectsOf.self)!, IRIKit.IRI(of: SHACL.targetWhere.self)!, IRIKit.IRI(of: SHACL.target.self)!,
        ]
    }

    /// The targets the shape whose node is `node` declares (§2.1.3).
    ///
    /// - Throws: ``SHACLError/invalidShapesGraph(_:)`` for a SPARQL-based
    ///   target without `sh:select`.
    static func targets(of node: ObjectTerm, in nodes: SHACLShapesGraph.Nodes) throws -> [SHACLTarget] {
        let graph = nodes.graph
        var targets: [SHACLTarget] = []
        for value in graph.objects(of: node, IRIKit.IRI(of: SHACL.targetNode.self)!) {
            if graph.object(of: value, IRIKit.IRI(of: SHACL.select.self)!) != nil || graph.object(of: value, IRIKit.IRI(of: SHACL.ask.self)!) != nil {
                targets.append(try .sparql(value, in: graph))
            } else if SHACLNodeExpression.isExpression(value, in: graph) {
                targets.append(.nodeExpression(SHACLNodeExpression(value, in: nodes)))
            } else {
                targets.append(.node(value))
            }
        }
        targets += graph.objects(of: node, IRIKit.IRI(of: SHACL.targetClass.self)!).map(SHACLTarget.class)
        targets += graph.objects(of: node, IRIKit.IRI(of: SHACL.targetSubjectsOf.self)!).compactMap(\.iri).map(SHACLTarget.subjectsOf)
        targets += graph.objects(of: node, IRIKit.IRI(of: SHACL.targetObjectsOf.self)!).compactMap(\.iri).map(SHACLTarget.objectsOf)
        targets += graph.objects(of: node, IRIKit.IRI(of: SHACL.targetWhere.self)!).map { .where(nodes.shape($0)) }
        for value in graph.objects(of: node, IRIKit.IRI(of: SHACL.target.self)!) {
            targets.append(try .sparql(value, in: graph))
        }
        return targets
    }

    /// A SPARQL-based target, which must have a `sh:select` query.
    private static func sparql(_ node: ObjectTerm, in graph: Graph) throws -> SHACLTarget {
        let query = SHACLSPARQLQuery(node, in: graph)
        guard query.select != nil else {
            throw SHACLError.invalidShapesGraph("SPARQL target \(node) must define sh:select")
        }
        return .sparql(query)
    }

    /// The nodes the target selects in the validation's data graph
    /// (§2.1.3.1 to §2.1.3.5, SHACL 1.2 SPARQL Extensions).
    func focusNodes(in validation: Validation) throws -> [ObjectTerm] {
        let dataGraph = validation.dataGraph
        switch self {
        case .node(let node):
            return [node]
        case .nodeExpression(let expression):
            return try expression.evaluate(focusNode: nil, in: validation)
        case .class(let cls):
            return dataGraph.instances(of: cls)
        case .subjectsOf(let predicate):
            return dataGraph.compactMap { $0.predicate == predicate ? $0.subject.object : nil }
        case .objectsOf(let predicate):
            return dataGraph.compactMap { $0.predicate == predicate ? $0.object : nil }
        case .where(let shape):
            return try dataGraph.nodes.filter { try validation.conforms($0, to: shape) }
        case .sparql(let query):
            // A SPARQL-based target binds `this` (SHACL 1.2 SPARQL
            // Extensions §6); a `sh:select` value of `sh:targetNode` projects
            // the one variable whose values are the focus nodes.
            return try query.select(focusNode: nil, in: validation).compactMap { solution in
                solution["this"] ?? (solution.count == 1 ? solution.values.first : nil)
            }
        }
    }
}
