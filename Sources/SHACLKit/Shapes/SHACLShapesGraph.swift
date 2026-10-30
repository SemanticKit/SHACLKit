import IRIKit
import RDFCore
import RDFKit

/// A shapes graph (SHACL 1.2 Core §1.4): an RDF graph and the shapes it
/// describes.
///
/// A shapes graph is read with a format's decoder into an RDFCore
/// ``RDFCore/Graph`` and decoded here, which is where its SHACL terms are
/// read by their IRIs:
///
///     let shapes = try SHACLShapesGraph(TurtleDecoder().decode(turtle))
public struct SHACLShapesGraph: Sendable {
    /// The graph the shapes were decoded from.
    public let graph: Graph

    /// The shapes, in the order of their nodes' first triples.
    public let shapes: [SHACLShape]

    /// The shapes by their nodes, which is how shapes name each other.
    private let byNode: [ObjectTerm: Int]

    /// Decodes the shapes of `graph`.
    ///
    /// The shapes are the nodes §2.1 names: SHACL instances of
    /// `sh:NodeShape` and `sh:PropertyShape`, subjects of targets and of
    /// constraint parameters, and values of shape-expecting parameters.
    ///
    /// - Throws: ``SHACLError/invalidShapesGraph(_:)`` when a shape is
    ///   ill-formed, or a value of `sh:node` or `sh:property` is not a node
    ///   shape or a property shape.
    public init(_ graph: Graph) throws {
        self.graph = graph
        var shapes: [SHACLShape] = []
        var byNode: [ObjectTerm: Int] = [:]
        for node in Self.shapeNodes(in: graph) {
            byNode[node] = shapes.count
            shapes.append(try SHACLShape(node, in: graph))
        }
        self.shapes = shapes
        self.byNode = byNode
        try checkReferences()
    }

    /// The shape whose node is `node`. A node the shapes graph does not
    /// describe as a shape is decoded on the spot: §2.1 makes any value of a
    /// shape-expecting parameter a shape, and one with no parameters is
    /// the empty shape every node conforms to.
    public func shape(_ node: ObjectTerm) -> SHACLShape? {
        if let index = byNode[node] { return shapes[index] }
        return try? SHACLShape(node, in: graph)
    }

    /// The nodes of `graph` that are shapes (§2.1), in first order.
    private static func shapeNodes(in graph: Graph) -> [ObjectTerm] {
        let type = RDF.type.metadata.id
        let shapeClasses: Set<ObjectTerm> = [
            .iri(SHACL.NodeShapeIndividual.metadata.id),
            .iri(SHACL.PropertyShapeIndividual.metadata.id),
            .iri(SHACL.ShapeIndividual.metadata.id),
            .iri(SHACL.ShapeClassIndividual.metadata.id),
        ]
        let parameters = Self.parameters
        let shapeExpecting = Self.shapeExpecting
        let listOfShapes = Self.listOfShapes
        var nodes: [ObjectTerm] = []
        for triple in graph {
            if triple.predicate == type, shapeClasses.contains(triple.object) {
                nodes.append(triple.subject.object)
            } else if parameters.contains(triple.predicate) {
                nodes.append(triple.subject.object)
            }
            if shapeExpecting.contains(triple.predicate) {
                nodes.append(triple.object)
            } else if listOfShapes.contains(triple.predicate) {
                nodes += graph.listOrValue(triple.object)
            }
        }
        return nodes.filter { !$0.isLiteral }.uniqued()
    }

    /// Targets and the parameters of the constraint components (§2.1.3, §4).
    private static var parameters: Set<IRI> {
        [
            SHACL.targetNode.metadata.id, SHACL.targetClass.metadata.id, SHACL.targetSubjectsOf.metadata.id,
            SHACL.targetObjectsOf.metadata.id, SHACL.targetWhere.metadata.id, SHACL.target.metadata.id,
            SHACL.path.metadata.id, SHACL.class.metadata.id, SHACL.datatype.metadata.id,
            SHACL.nodeKind.metadata.id, SHACL.minCount.metadata.id, SHACL.maxCount.metadata.id,
            SHACL.minExclusive.metadata.id, SHACL.minInclusive.metadata.id, SHACL.maxExclusive.metadata.id,
            SHACL.maxInclusive.metadata.id, SHACL.minLength.metadata.id, SHACL.maxLength.metadata.id,
            SHACL.pattern.metadata.id, SHACL.singleLine.metadata.id, SHACL.languageIn.metadata.id,
            SHACL.uniqueLang.metadata.id, SHACL.equals.metadata.id, SHACL.disjoint.metadata.id,
            SHACL.lessThan.metadata.id, SHACL.lessThanOrEquals.metadata.id, SHACL.not.metadata.id,
            SHACL.and.metadata.id, SHACL.or.metadata.id, SHACL.xone.metadata.id,
            SHACL.node.metadata.id, SHACL.property.metadata.id, SHACL.qualifiedValueShape.metadata.id,
            SHACL.someValue.metadata.id, SHACL.closed.metadata.id, SHACL.hasValue.metadata.id,
            SHACL.in.metadata.id, SHACL.expression.metadata.id, SHACL.nodeByExpression.metadata.id,
            SHACL.reifierShape.metadata.id, SHACL.reificationRequired.metadata.id, SHACL.memberShape.metadata.id,
            SHACL.minListLength.metadata.id, SHACL.maxListLength.metadata.id, SHACL.uniqueMembers.metadata.id,
            SHACL.rule.metadata.id, SHACL.sparql.metadata.id, SHACL.deactivated.metadata.id,
            SHACL.severity.metadata.id,
        ]
    }

    /// The parameters whose values are shapes (§2.1).
    private static var shapeExpecting: Set<IRI> {
        [
            SHACL.node.metadata.id, SHACL.property.metadata.id, SHACL.not.metadata.id,
            SHACL.qualifiedValueShape.metadata.id, SHACL.someValue.metadata.id, SHACL.memberShape.metadata.id,
            SHACL.reifierShape.metadata.id, SHACL.targetWhere.metadata.id, SHACL.condition.metadata.id,
            SHNEX.filterShape.metadata.id, SHNEX.matchAll.metadata.id, SHNEX.findFirst.metadata.id,
            SHNEX.nodesMatching.metadata.id,
        ]
    }

    /// The parameters whose values are SHACL lists of shapes (§2.1).
    private static var listOfShapes: Set<IRI> {
        [SHACL.and.metadata.id, SHACL.or.metadata.id, SHACL.xone.metadata.id]
    }

    /// Checks that each value of `sh:node` is a node shape and each value of
    /// `sh:property` a property shape (§4.7.1, §4.7.2).
    private func checkReferences() throws {
        for shape in shapes {
            for node in shape.nodes {
                guard let referenced = self.shape(node), !referenced.isPropertyShape else {
                    throw SHACLError.invalidShapesGraph("Shape \(shape.id) references non-node shape \(node) with sh:node")
                }
            }
            for node in shape.properties {
                guard let referenced = self.shape(node), referenced.isPropertyShape else {
                    throw SHACLError.invalidShapesGraph("Shape \(shape.id) references missing or non-property shape \(node)")
                }
            }
        }
    }
}
