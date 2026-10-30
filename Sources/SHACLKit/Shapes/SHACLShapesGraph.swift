import IRIKit
import RDFCore
import RDFFormats
import RDF
import struct RDFCore.Literal
import SHACL
import struct RDFCore.Graph

/// A shapes graph (SHACL 1.2 Core §1.4): an RDF graph and the shapes it
/// describes.
///
/// A shapes graph is read with a format's decoder into an RDFCore
/// ``RDFCore/Graph`` and decoded here. This is the boundary where its SHACL
/// terms are read by their IRIs and each shape node becomes a
/// ``SHACLShape`` object:
///
///     let shapes = try SHACLShapesGraph(TurtleDecoder().decode(turtle))
public struct SHACLShapesGraph: Sendable {
    /// The graph the shapes were decoded from.
    public let graph: Graph

    /// The shapes, in the order of their nodes' first triples.
    public let shapes: [SHACLShape]

    /// Decodes the shapes of `graph`.
    ///
    /// The shapes are the nodes §2.1 names: SHACL instances of
    /// `sh:NodeShape` and `sh:PropertyShape`, subjects of targets and of
    /// constraint parameters, and values of shape-expecting parameters.
    ///
    /// - Throws: ``SHACLError/invalidShapesGraph(_:)`` when a shape is
    ///   ill-formed, or a value of `sh:property` is not a property shape.
    public init(_ graph: Graph) throws {
        let nodes = Nodes(graph)
        for node in Self.shapeNodes(in: graph) {
            _ = nodes.shape(node)
        }
        try nodes.decodeShapes()
        self.graph = graph
        self.shapes = nodes.shapes
        try checkReferences()
    }

    /// The shape whose node is `node`, read where a caller names a shape by
    /// the IRI or blank node a document gives it.
    public func shape(_ node: ObjectTerm) -> SHACLShape? {
        shapes.first { $0.id == node }
    }

    /// Decodes the node expression whose node is `node` (SHACL 1.2 Node
    /// Expressions), with the shapes of this graph as the shapes its
    /// shape-expecting parameters name.
    public func expression(_ node: ObjectTerm) -> SHACLNodeExpression {
        let nodes = Nodes(graph, shapes: shapes)
        let expression = SHACLNodeExpression(node, in: nodes)
        try? nodes.decodeShapes()
        return expression
    }

    /// The nodes of `graph` that are shapes (§2.1), in first order.
    private static func shapeNodes(in graph: Graph) -> [ObjectTerm] {
        let type = IRIKit.IRI(of: RDF.type.self)!
        let shapeClasses: Set<ObjectTerm> = [
            .iri(IRIKit.IRI(of: SHACL.NodeShapeIndividual.self)!),
            .iri(IRIKit.IRI(of: SHACL.PropertyShapeIndividual.self)!),
            .iri(IRIKit.IRI(of: SHACL.ShapeIndividual.self)!),
            .iri(IRIKit.IRI(of: SHACL.ShapeClassIndividual.self)!),
        ]
        let parameters = SHACLConstraint.parameters.union(SHACLTarget.parameters)
        var nodes: [ObjectTerm] = []
        for triple in graph {
            if triple.predicate == type, shapeClasses.contains(triple.object) {
                nodes.append(triple.subject.object)
            } else if parameters.contains(triple.predicate) {
                nodes.append(triple.subject.object)
            }
        }
        return nodes.filter { !$0.isLiteral }.uniqued()
    }

    /// Checks that each value of `sh:property` is a property shape (§4.7.2:
    /// "Each value of sh:property in a shape must be a well-formed property
    /// shape").
    private func checkReferences() throws {
        for shape in shapes {
            for case .property(let property) in shape.constraints where !property.isPropertyShape {
                throw SHACLError.invalidShapesGraph("Shape \(shape) references missing or non-property shape \(property)")
            }
        }
    }
}

extension SHACLShapesGraph {
    /// The objects the nodes of a shapes graph decode into, while it is
    /// decoded: one ``SHACLShape`` for each shape node, and one
    /// `sh:Severity` individual for each severity SHACL does not declare.
    ///
    /// A shape is made the first time a node is read as one, so shapes that
    /// refer to each other in a cycle are each made once, and decoded after
    /// all of them exist.
    final class Nodes {
        let graph: Graph

        /// Every shape made so far, in the order they were made.
        private(set) var shapes: [SHACLShape]

        private var shapesByNode: [ObjectTerm: SHACLShape] = [:]
        private var pending: [SHACLShape] = []
        private var severities: [IRI: SHACL.SeverityIndividual] = [:]

        init(_ graph: Graph, shapes: [SHACLShape] = []) {
            self.graph = graph
            self.shapes = shapes
            for shape in shapes { shapesByNode[shape.id] = shape }
        }

        /// The shape whose node is `node`, made on first use.
        func shape(_ node: ObjectTerm) -> SHACLShape {
            if let shape = shapesByNode[node] { return shape }
            let shape = SHACLShape(node)
            shapesByNode[node] = shape
            shapes.append(shape)
            pending.append(shape)
            return shape
        }

        /// The severity `node` names (§2.1.4): `sh:Violation`, `sh:Warning`,
        /// `sh:Info`, `sh:Debug` or `sh:Trace`, or a severity of the shapes
        /// graph's own when it is any other IRI.
        func severity(_ node: ObjectTerm) throws -> any SHACL.Severity {
            if let severity = [SHACL.Violation, SHACL.Warning, SHACL.Info, SHACL.Debug, SHACL.Trace]
                .first(where: { node == .iri(IRIKit.IRI(of: $0)!) }) {
                return severity
            }
            guard let iri = node.iri else {
                throw SHACLError.invalidShapesGraph("The severity \(node) is not an IRI")
            }
            if let severity = severities[iri] { return severity }
            let severity = SHACL.SeverityIndividual()
            severities[iri] = severity
            return severity
        }

        /// Decodes every shape that has been made but not decoded, including
        /// the ones decoding them makes.
        func decodeShapes() throws {
            while !pending.isEmpty {
                let shape = pending.removeFirst()
                shape.define(try SHACLShape.Definition(shape.id, in: self))
            }
        }
    }
}
