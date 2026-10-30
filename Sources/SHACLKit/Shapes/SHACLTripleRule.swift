import RDFCore

/// A `sh:TripleRule` of a shape (SHACL 1.2 Rules): for each focus node of
/// the shape that conforms to its conditions, the triples whose subjects,
/// predicates and objects its node expressions give are inferred.
public struct SHACLTripleRule: Sendable, Hashable {
    /// The node of the rule in the shapes graph.
    public let node: ObjectTerm

    /// `sh:order`: rules run in ascending order.
    public let order: Double?

    /// `sh:condition`: the shapes each focus node conforms to.
    public let conditions: [ObjectTerm]

    /// `sh:subject`, `sh:predicate` and `sh:object`.
    public let subject: SHACLNodeExpression
    public let predicate: SHACLNodeExpression
    public let object: SHACLNodeExpression

    public init(
        node: ObjectTerm,
        order: Double? = nil,
        conditions: [ObjectTerm] = [],
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
}
