import Foundation

public enum SHACLSeverity: String, Sendable, Codable {
    case violation
    case warning
    case info
}

public struct SHACLValidationResult: Sendable, Equatable {
    public let conforms: Bool
    public let message: String

    public init(conforms: Bool, message: String) {
        self.conforms = conforms
        self.message = message
    }
}

public protocol SHACLValidator: Sendable {
    func validate(dataGraph: Data, shapesGraph: Data) throws -> SHACLValidationResult
}

public enum SHACLError: Error, LocalizedError {
    case notImplemented(String)

    public var errorDescription: String? {
        switch self {
        case .notImplemented(let detail):
            return "SHACL feature not implemented: \(detail)"
        }
    }
}

public struct SHACLCoreValidator: SHACLValidator {
    public init() {}

    public func validate(dataGraph: Data, shapesGraph: Data) throws -> SHACLValidationResult {
        throw SHACLError.notImplemented("Core SHACL validation engine")
    }
}
