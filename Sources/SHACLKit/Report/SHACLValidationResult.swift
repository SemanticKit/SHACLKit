/// A validation report (SHACL 1.2 Core §3.6.1): whether the data graph
/// conforms to the shapes graph, and its results.
public struct SHACLValidationResult: Sendable, Equatable {
    /// `sh:conforms`: true when no result has a severity the validation
    /// disallows (`sh:conformanceDisallows`).
    public let conforms: Bool

    /// A summary of the report.
    public let message: String

    /// `sh:result`: the validation results, in a stable order.
    public let violations: [SHACLViolation]

    public init(conforms: Bool, message: String, violations: [SHACLViolation] = []) {
        self.conforms = conforms
        self.message = message
        self.violations = violations
    }
}
