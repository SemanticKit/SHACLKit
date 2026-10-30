import IRIKit
import RDFCore
import RDF
import struct RDFCore.Literal
import SHACL
import struct RDFCore.Graph

/// A `sh:TripleRule` of a shape (SHACL 1.2 Rules): for each focus node of
/// the shape that conforms to its conditions, the triples whose subjects,
/// predicates and objects its node expressions give are inferred.
public struct SHACLTripleRule: Sendable, Hashable {
    /// The node of the rule in the shapes graph.
    public let node: ObjectTerm

    /// `sh:order`: rules run in ascending order.
    public let order: Double?

    /// `sh:condition`: the shapes each focus node conforms to.
    public let conditions: [SHACLShape]

    /// `sh:subject`, `sh:predicate` and `sh:object`.
    public let subject: SHACLNodeExpression
    public let predicate: SHACLNodeExpression
    public let object: SHACLNodeExpression

    public init(
        node: ObjectTerm,
        order: Double? = nil,
        conditions: [SHACLShape] = [],
        subject: SHACLNodeExpression,
        predicate: SHACLNodeExpression,
        object: SHACLNodeExpression
    ) {
        self.node = node
        self.order = order
        self.conditions = conditions
        self.subject = subject
        self.predicate = predicate
        self.object = object
    }

    /// Decodes the rule whose node is `node`.
    ///
    /// - Throws: ``SHACLError/invalidShapesGraph(_:)`` when the node is not
    ///   a `sh:TripleRule`, lacks `sh:subject`, `sh:predicate` or
    ///   `sh:object`, or has a non-numeric `sh:order`.
    init(_ node: ObjectTerm, in nodes: SHACLShapesGraph.Nodes) throws {
        let graph = nodes.graph
        guard graph.objects(of: node, RDF.type.iri!).contains(.iri(SHACL.TripleRuleIndividual.iri!)) else {
            throw SHACLError.invalidShapesGraph("Rule \(node) is missing rdf:type sh:TripleRule")
        }
        func expression(_ parameter: IRI, _ name: String) throws -> SHACLNodeExpression {
            guard let value = graph.object(of: node, parameter) else {
                throw SHACLError.invalidShapesGraph("Rule \(node) is missing \(name)")
            }
            return SHACLNodeExpression(value, in: nodes)
        }
        var order: Double?
        if let value = graph.object(of: node, SHACL.order.iri!) {
            guard let number = value.literal?.numericValue else {
                throw SHACLError.invalidShapesGraph("Rule \(node) has invalid sh:order value \(value)")
            }
            order = number
        }
        self.init(
            node: node,
            order: order,
            conditions: graph.objects(of: node, SHACL.condition.iri!).flatMap(graph.listOrValue).map(nodes.shape),
            subject: try expression(SHACL.subject.iri!, "sh:subject"),
            predicate: try expression(SHACL.predicate.iri!, "sh:predicate"),
            object: try expression(SHACL.object.iri!, "sh:object")
        )
    }

    /// The triples the rule infers for `focusNode`: none unless the focus
    /// node conforms to every condition, otherwise one for each subject,
    /// predicate and object the expressions output that can be a triple's
    /// subject, predicate and object (RDF 1.2 Concepts §3.1).
    func triples(for focusNode: ObjectTerm, in validation: Validation) throws -> [Graph.Element] {
        for condition in conditions where try !validation.conforms(focusNode, to: condition) {
            return []
        }
        let subjects = try subject.evaluate(focusNode: focusNode, in: validation).compactMap(\.subject)
        let predicates = try predicate.evaluate(focusNode: focusNode, in: validation).compactMap(\.iri)
        let objects = try object.evaluate(focusNode: focusNode, in: validation)
        return subjects.flatMap { subject in
            predicates.flatMap { predicate in
                objects.map { Graph.Element(subject: subject, predicate: predicate, object: $0) }
            }
        }
    }
}
