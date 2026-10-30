import IRIKit
import RDFCore
import RDFKit

/// One validation of a data graph against a shapes graph (SHACL 1.2 Core
/// §3.4): the graphs, the SPARQL executor, and the shapes being validated
/// at the moment, which is how recursive shapes stop.
final class Validation {
    let dataGraph: Graph
    let shapesGraph: SHACLShapesGraph
    let sparqlExecutor: any SHACLSPARQLExecutor

    /// How deep shape references are followed.
    let maxDepth = 16

    /// A shape being validated for a node.
    private struct Visit: Hashable {
        let shape: ObjectTerm
        let node: ObjectTerm
    }

    /// The shapes being validated, for the nodes they are validated for.
    /// SHACL 1.2 Core §3.4.1 leaves recursive shapes undefined; a node met
    /// again by the shape that is validating it is taken to conform.
    private var visiting: Set<Visit> = []

    init(dataGraph: Graph, shapesGraph: SHACLShapesGraph, sparqlExecutor: any SHACLSPARQLExecutor = SHACLDeniedSPARQLExecutor()) {
        self.dataGraph = dataGraph
        self.shapesGraph = shapesGraph
        self.sparqlExecutor = sparqlExecutor
    }

    // MARK: - Focus nodes

    /// The focus nodes of `shape` (§2.1.3): its targets' nodes, its SHACL
    /// instances when it is a class, and the nodes that name it with
    /// `sh:shape`.
    func focusNodes(of shape: SHACLShape) throws -> [ObjectTerm] {
        var nodes: [ObjectTerm] = []
        for target in shape.targets {
            nodes += try focusNodes(of: target)
        }
        if shape.isClass {
            nodes += dataGraph.instances(of: shape.id)
        }
        nodes += dataGraph.subjects(SHACL.shape.metadata.id, shape.id)
        return nodes.uniqued().sorted()
    }

    /// The nodes a target selects (§2.1.3.1 to §2.1.3.5, SHACL 1.2 SPARQL
    /// Extensions §6).
    func focusNodes(of target: SHACLTarget) throws -> [ObjectTerm] {
        switch target {
        case .node(let node):
            return [node]
        case .nodeExpression(let expression):
            return expression.evaluate(focusNode: nil, in: self)
        case .class(let cls):
            return dataGraph.instances(of: cls)
        case .subjectsOf(let predicate):
            return dataGraph.filter { $0.predicate == predicate }.map(\.subject.object)
        case .objectsOf(let predicate):
            return dataGraph.filter { $0.predicate == predicate }.map(\.object)
        case .where(let shape):
            return try dataGraph.nodes.filter { try conforms($0, to: shape) }
        case .sparql(let query):
            guard let select = query.select else { return [] }
            return try sparqlExecutor.select(query: query.prefixed(select), focusNode: nil, dataGraph: dataGraph, shapesGraph: shapesGraph)
        }
    }

    // MARK: - Shapes

    /// The value nodes of `shape` for `focusNode` (§2.3): the nodes its path
    /// reaches, the output of its value expression, or the focus node.
    func valueNodes(of shape: SHACLShape, focusNode: ObjectTerm) -> [ObjectTerm] {
        if let path = shape.path {
            return path.values(from: focusNode, in: dataGraph).sorted()
        }
        if let expression = shape.valueExpression {
            return expression.evaluate(focusNode: focusNode, in: self).uniqued().sorted()
        }
        return [focusNode]
    }

    /// Whether `node` conforms to the shape whose node is `shapeNode`
    /// (§3.4: "a node conforms to a shape if validating it against the
    /// shape produces no validation results").
    func conforms(_ node: ObjectTerm, to shapeNode: ObjectTerm, depth: Int = 0) throws -> Bool {
        guard let shape = shapesGraph.shape(shapeNode) else { return false }
        return try validate(shape, focusNode: node, depth: depth + 1).isEmpty
    }

    /// The results of validating `focusNode` against `shape` (§3.4).
    func validate(_ shape: SHACLShape, focusNode: ObjectTerm, depth: Int = 0) throws -> [SHACLViolation] {
        guard !shape.isDeactivated, depth <= maxDepth else { return [] }
        let visit = Visit(shape: shape.id, node: focusNode)
        guard visiting.insert(visit).inserted else { return [] }
        defer { visiting.remove(visit) }

        let constraints = Constraints(
            validation: self,
            shape: shape,
            focusNode: focusNode,
            valueNodes: valueNodes(of: shape, focusNode: focusNode),
            depth: depth
        )
        return try constraints.results()
    }
}
