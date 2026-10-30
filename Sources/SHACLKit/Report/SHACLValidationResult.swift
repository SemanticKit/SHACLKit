import RDFCore
import SHACL
import struct RDFCore.Literal
import struct RDFCore.Graph

/// A validation result (SHACL 1.2 Core §3.6.2): one constraint that a focus
/// node does not meet.
///
/// The severity and the constraint component are SHACL individuals, and
/// the source shape is the ``SHACLShape`` object, each compared by identity
/// (`result.sourceConstraintComponent === SHACL.MinCountConstraintComponent`).
/// The focus node and value are nodes of the data graph.
public struct SHACLValidationResult: Sendable, Equatable, CustomStringConvertible {
    /// `sh:resultSeverity`: the severity of the shape.
    public let severity: any SHACL.Severity

    /// `sh:sourceShape`: the shape the result is about.
    public let sourceShape: SHACLShape

    /// `sh:focusNode`.
    public let focusNode: ObjectTerm

    /// `sh:resultPath`: the path of a property shape, or the predicate a
    /// closed shape does not permit.
    public let resultPath: SHACLPropertyPath?

    /// `sh:value`: the value node that does not meet the constraint.
    public let value: ObjectTerm?

    /// `sh:sourceConstraintComponent`.
    public let sourceConstraintComponent: any SHACL.ConstraintComponent

    /// `sh:sourceConstraint`: the node of the SPARQL-based constraint or
    /// node expression that produced the result.
    public let sourceConstraint: ObjectTerm?

    /// `sh:resultMessage`: the shape's or constraint's `sh:message`, or a
    /// description of the result when there is none.
    public let message: String

    /// `sh:detail`: the results that made a value node fail a shape it
    /// was validated against.
    public let details: [SHACLValidationResult]

    public init(
        severity: any SHACL.Severity = SHACL.Violation,
        sourceShape: SHACLShape,
        focusNode: ObjectTerm,
        resultPath: SHACLPropertyPath? = nil,
        value: ObjectTerm? = nil,
        sourceConstraintComponent: any SHACL.ConstraintComponent,
        sourceConstraint: ObjectTerm? = nil,
        message: String,
        details: [SHACLValidationResult] = []
    ) {
        self.severity = severity
        self.sourceShape = sourceShape
        self.focusNode = focusNode
        self.resultPath = resultPath
        self.value = value
        self.sourceConstraintComponent = sourceConstraintComponent
        self.sourceConstraint = sourceConstraint
        self.message = message
        self.details = details
    }

    public static func == (lhs: SHACLValidationResult, rhs: SHACLValidationResult) -> Bool {
        lhs.severity === rhs.severity
            && lhs.sourceShape === rhs.sourceShape
            && lhs.focusNode == rhs.focusNode
            && lhs.resultPath == rhs.resultPath
            && lhs.value == rhs.value
            && lhs.sourceConstraintComponent === rhs.sourceConstraintComponent
            && lhs.sourceConstraint == rhs.sourceConstraint
            && lhs.message == rhs.message
            && lhs.details == rhs.details
    }

    public var description: String { message }

    /// Whether the result comes before `other` in a report: by shape,
    /// focus node, path, constraint component, value and message, each in
    /// its N-Triples form, so a validation gives the same report every time.
    func precedes(_ other: SHACLValidationResult) -> Bool {
        sortKey.lexicographicallyPrecedes(other.sortKey)
    }

    private var sortKey: [String] {
        [
            sourceShape.id.description, focusNode.description, resultPath?.sparql ?? "",
            sourceConstraintComponent.iri?.rawValue ?? "", value?.description ?? "", message,
        ]
    }
}
