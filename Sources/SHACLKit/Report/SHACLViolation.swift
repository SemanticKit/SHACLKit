import RDFCore
import RDFKit

/// A validation result (SHACL 1.2 Core §3.6.2): one constraint that a focus
/// node does not meet.
///
/// The severity and the constraint component are the SHACL individuals
/// themselves, compared by identity (`result.sourceConstraintComponent ===
/// SHACL.MinCountConstraintComponent`). The shape, focus node, path and
/// value are the nodes of the shapes and data graphs.
public struct SHACLViolation: Sendable, Equatable, CustomStringConvertible {
    /// `sh:resultSeverity`: the severity of the shape.
    public let severity: any SHACL.Severity

    /// `sh:sourceShape`: the node of the shape the result is about.
    public let sourceShape: ObjectTerm

    /// `sh:focusNode`.
    public let focusNode: ObjectTerm

    /// `sh:resultPath`: the path of a property shape.
    public let resultPath: SHACLPropertyPath?

    /// `sh:value`: the value node that does not meet the constraint.
    public let value: ObjectTerm?

    /// `sh:sourceConstraintComponent`.
    public let sourceConstraintComponent: any SHACL.ConstraintComponent

    /// `sh:sourceConstraint`: the SPARQL-based constraint, for results it
    /// produced.
    public let sourceConstraint: ObjectTerm?

    /// `sh:resultMessage`.
    public let message: String

    public init(
        severity: any SHACL.Severity = SHACL.Violation,
        sourceShape: ObjectTerm,
        focusNode: ObjectTerm,
        resultPath: SHACLPropertyPath? = nil,
        value: ObjectTerm? = nil,
        sourceConstraintComponent: any SHACL.ConstraintComponent,
        sourceConstraint: ObjectTerm? = nil,
        message: String
    ) {
        self.severity = severity
        self.sourceShape = sourceShape
        self.focusNode = focusNode
        self.resultPath = resultPath
        self.value = value
        self.sourceConstraintComponent = sourceConstraintComponent
        self.sourceConstraint = sourceConstraint
        self.message = message
    }

    public static func == (lhs: SHACLViolation, rhs: SHACLViolation) -> Bool {
        lhs.severity === rhs.severity
            && lhs.sourceShape == rhs.sourceShape
            && lhs.focusNode == rhs.focusNode
            && lhs.resultPath == rhs.resultPath
            && lhs.value == rhs.value
            && lhs.sourceConstraintComponent === rhs.sourceConstraintComponent
            && lhs.sourceConstraint == rhs.sourceConstraint
            && lhs.message == rhs.message
    }

    public var description: String { message }

    /// The order results are reported in: by shape, focus node, path,
    /// constraint component, value and message.
    var sortKey: [String] {
        [
            sourceShape.description, focusNode.description, resultPath.map { "\($0)" } ?? "",
            type(of: sourceConstraintComponent).metadata.name, value?.description ?? "", message,
        ]
    }
}
