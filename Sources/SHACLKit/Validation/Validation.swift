import IRIKit
import RDFCore
import RDFFormats
import SHACL
import struct RDFCore.Literal
import struct RDFCore.Graph

/// One validation of a data graph against a shapes graph (SHACL 1.2 Core
/// §3.4): the graphs, the SPARQL executor, and the shapes being validated
/// at the moment, which is how recursive shapes stop.
final class Validation {
    private(set) var dataGraph: Graph
    let shapesGraph: SHACLShapesGraph
    let sparqlExecutor: any SHACLSPARQLExecutor

    /// How deep shape references are followed.
    let maxDepth = 16

    /// How many times the rules of the shapes graph are run over the data
    /// graph, at most, before validation.
    let maxRuleIterations = 16

    /// A shape being validated for a node.
    private struct Visit: Hashable {
        let shape: SHACLShape
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

    // MARK: - Rules

    /// Runs the triple rules of the shapes graph (SHACL 1.2 Rules) until
    /// they infer no new triple, adding what they infer to the data graph.
    /// Each shape's rules run in `sh:order` for each of its focus nodes.
    func applyRules() throws {
        let shapes = shapesGraph.shapes.filter { !$0.rules.isEmpty && !$0.isDeactivated }
        guard !shapes.isEmpty else { return }
        for _ in 0..<maxRuleIterations {
            var inferred = Graph()
            for shape in shapes {
                let rules = shape.rules.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
                for focusNode in try focusNodes(of: shape) {
                    for rule in rules {
                        for triple in try rule.triples(for: focusNode, in: self) where !dataGraph.contains(triple) {
                            inferred.insert(triple)
                        }
                    }
                }
            }
            guard !inferred.isEmpty else { return }
            dataGraph.formUnion(inferred)
        }
    }

    // MARK: - Focus nodes

    /// The focus nodes of `shape` (§2.1.3): its targets' nodes, its SHACL
    /// instances when it is a class, and the nodes that name it with
    /// `sh:shape`.
    func focusNodes(of shape: SHACLShape) throws -> [ObjectTerm] {
        var nodes: [ObjectTerm] = []
        for target in shape.targets {
            nodes += try target.focusNodes(in: self)
        }
        if shape.isClass {
            nodes += dataGraph.instances(of: shape.id)
        }
        nodes += dataGraph.subjects(IRIKit.IRI(of: SHACL.shape)!, shape.id)
        return nodes.uniqued().sorted()
    }

    // MARK: - Shapes

    /// The value nodes of `shape` for `focusNode` (§2.3): the nodes its path
    /// reaches, the output of its value expression, or the focus node.
    func valueNodes(of shape: SHACLShape, focusNode: ObjectTerm) throws -> [ObjectTerm] {
        if let path = shape.path {
            return path.values(from: focusNode, in: dataGraph).sorted()
        }
        if let expression = shape.valueExpression {
            return try expression.evaluate(focusNode: focusNode, in: self).uniqued().sorted()
        }
        return [focusNode]
    }

    /// Whether `node` conforms to `shape` (§3.4: "a node conforms to a
    /// shape if validating it against the shape produces no validation
    /// results").
    func conforms(_ node: ObjectTerm, to shape: SHACLShape, depth: Int = 0) throws -> Bool {
        try results(of: shape, focusNode: node, depth: depth + 1).isEmpty
    }

    /// Whether `node` conforms to the shape whose node is `shapeNode`: the
    /// shape of the shapes graph with that node, or the empty shape every
    /// node conforms to when the shapes graph does not describe it.
    func conforms(_ node: ObjectTerm, toShapeNamed shapeNode: ObjectTerm, depth: Int = 0) throws -> Bool {
        guard let shape = shapesGraph.shape(shapeNode) else { return true }
        return try conforms(node, to: shape, depth: depth)
    }

    /// The results of validating `focusNode` against `shape` (§3.4).
    func results(of shape: SHACLShape, focusNode: ObjectTerm, depth: Int = 0) throws -> [SHACLValidationResult] {
        guard !shape.isDeactivated, depth <= maxDepth else { return [] }
        let visit = Visit(shape: shape, node: focusNode)
        guard visiting.insert(visit).inserted else { return [] }
        defer { visiting.remove(visit) }

        let valueNodes = try valueNodes(of: shape, focusNode: focusNode)
        var results: [SHACLValidationResult] = []
        for constraint in shape.constraints {
            results += try constraint.results(of: shape, focusNode: focusNode, valueNodes: valueNodes, depth: depth, in: self)
        }
        return results
    }
}
