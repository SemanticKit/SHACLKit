import IRIKit
import RDFCore
import RDFKit
import Synchronization

/// A shape of a shapes graph (SHACL 1.2 Core §2.1).
///
/// "A shape is an IRI or blank node s" of the shapes graph. Inside the
/// runtime a shape is this object: the shapes it refers to through `sh:node`,
/// `sh:property`, `sh:not` and the other shape-expecting parameters are the
/// ``SHACLShape`` objects themselves, so a reference is never looked up by
/// the node that names it. The node is kept as ``id`` for the boundary only,
/// where a validation result names the shape as its `sh:sourceShape`.
///
/// Shapes refer to each other in cycles, so a shapes graph creates every
/// shape before it decodes their parameters; ``SHACLShapesGraph`` is the
/// only place a shape is made.
public final class SHACLShape: Sendable, Hashable, CustomStringConvertible {
    /// The shape's node in the shapes graph, read where a result leaves the
    /// runtime as its `sh:sourceShape`.
    public let id: ObjectTerm

    private let decoded = Mutex(Definition())

    init(_ id: ObjectTerm) {
        self.id = id
    }

    /// What a shape's parameters say, decoded once from the shapes graph.
    struct Definition: Sendable {
        var path: SHACLPropertyPath?
        var valueExpression: SHACLNodeExpression?
        var targets: [SHACLTarget] = []
        var isClass = false
        var isDeactivated = false
        var severity: any SHACL.Severity = SHACL.Violation
        var messages: [Literal] = []
        var constraints: [SHACLConstraint] = []
        var rules: [SHACLTripleRule] = []
    }

    func define(_ definition: Definition) {
        decoded.withLock { $0 = definition }
    }

    private var definition: Definition {
        decoded.withLock { $0 }
    }

    /// `sh:path`: the property path of a property shape (§2.3).
    public var path: SHACLPropertyPath? { definition.path }

    /// The node expression whose output is the value nodes of a property
    /// shape that has `sh:expression` and no `sh:path` (SHACL 1.2 Node
    /// Expressions).
    public var valueExpression: SHACLNodeExpression? { definition.valueExpression }

    /// Whether the shape is a property shape (§2.3): its value nodes are
    /// the nodes its path, or its value expression, reaches from the focus
    /// node. A node shape's only value node is the focus node (§2.2).
    public var isPropertyShape: Bool { path != nil || valueExpression != nil }

    /// The targets (§2.1.3).
    public var targets: [SHACLTarget] { definition.targets }

    /// Whether the shape is also a class, with its SHACL instances as
    /// implicit focus nodes (§2.1.3.3).
    public var isClass: Bool { definition.isClass }

    /// `sh:deactivated` (§2.1.5): a deactivated shape has no results, and
    /// every node conforms to it.
    public var isDeactivated: Bool { definition.isDeactivated }

    /// `sh:severity` (§2.1.4), `sh:Violation` when none is given.
    public var severity: any SHACL.Severity { definition.severity }

    /// `sh:message` (§2.1.6): the messages each result of the shape carries.
    public var messages: [Literal] { definition.messages }

    /// The constraints of the shape's constraint components (§4).
    public var constraints: [SHACLConstraint] { definition.constraints }

    /// `sh:rule`: the triple rules of the shape (SHACL 1.2 Rules).
    public var rules: [SHACLTripleRule] { definition.rules }

    /// Shapes are the same shape when they are the same object.
    public static func == (lhs: SHACLShape, rhs: SHACLShape) -> Bool {
        lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    /// The shape's node as N-Triples writes it.
    public var description: String { id.description }
}

extension SHACLShape.Definition {
    /// Decodes the parameters of the shape whose node is `node`.
    ///
    /// - Throws: ``SHACLError/invalidShapesGraph(_:)`` when a parameter's
    ///   value is ill-formed.
    init(_ node: ObjectTerm, in nodes: SHACLShapesGraph.Nodes) throws {
        let graph = nodes.graph
        let types = graph.objects(of: node, RDF.type.metadata.id)
        let typedNodeShape = types.contains(.iri(SHACL.NodeShapeIndividual.metadata.id))
        let typedPropertyShape = types.contains(.iri(SHACL.PropertyShapeIndividual.metadata.id))

        if let pathNode = graph.object(of: node, SHACL.path.metadata.id) {
            guard let path = SHACLPropertyPath(pathNode, in: graph) else {
                throw SHACLError.invalidShapesGraph("Shape \(node) has an ill-formed sh:path \(pathNode)")
            }
            self.path = path
        }
        let expression = graph.object(of: node, SHACL.expression.metadata.id).map { SHACLNodeExpression($0, in: nodes) }
        if path == nil, let expression, !typedNodeShape {
            valueExpression = expression
        }
        if typedPropertyShape, path == nil, valueExpression == nil {
            throw SHACLError.invalidShapesGraph("Property shape \(node) is missing both sh:path and sh:expression")
        }

        targets = try SHACLTarget.targets(of: node, in: nodes)
        isClass = graph.isInstance(node, of: .iri(RDFS.ClassIndividual.metadata.id))
            || types.contains(.iri(SHACL.ShapeClassIndividual.metadata.id))
        isDeactivated = graph.object(of: node, SHACL.deactivated.metadata.id)?.literal?.isTrue ?? false
        if let value = graph.object(of: node, SHACL.severity.metadata.id) {
            severity = try nodes.severity(value)
        }
        messages = graph.objects(of: node, SHACL.message.metadata.id).compactMap(\.literal)
        constraints = try SHACLConstraint.constraints(
            of: node,
            in: nodes,
            isPropertyShape: path != nil || valueExpression != nil,
            expression: valueExpression == nil ? expression : nil
        )
        rules = try graph.objects(of: node, SHACL.rule.metadata.id)
            .flatMap(graph.listOrValue)
            .map { try SHACLTripleRule($0, in: nodes) }
    }
}
