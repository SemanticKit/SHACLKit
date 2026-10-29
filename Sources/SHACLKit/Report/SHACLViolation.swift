import Foundation

public struct SHACLViolation: Sendable, Equatable {
    public let severity: SHACLSeverity
    public let shapeIRI: String
    public let focusNode: String
    public let pathIRI: String?
    public let valueNode: String?
    public let sourceConstraintIRI: String?
    public let message: String

    public init(
        severity: SHACLSeverity = .violation,
        shapeIRI: String,
        focusNode: String,
        pathIRI: String?,
        valueNode: String? = nil,
        sourceConstraintIRI: String? = nil,
        message: String
    ) {
        self.severity = severity
        self.shapeIRI = shapeIRI
        self.focusNode = focusNode
        self.pathIRI = pathIRI
        self.valueNode = valueNode
        self.sourceConstraintIRI = sourceConstraintIRI
        self.message = message
    }
}
