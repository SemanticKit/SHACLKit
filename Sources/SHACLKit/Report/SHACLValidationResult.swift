import Foundation

public struct SHACLValidationResult: Sendable, Equatable {
    public let conforms: Bool
    public let message: String
    public let violations: [SHACLViolation]

    public init(conforms: Bool, message: String, violations: [SHACLViolation] = []) {
        self.conforms = conforms
        self.message = message
        self.violations = violations
    }
}
