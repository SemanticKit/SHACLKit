import Foundation

public enum SHACLError: Error, LocalizedError {
    case invalidUTF8
    case invalidPrefixDeclaration(String)
    case unknownPrefix(String)
    case invalidStatement(String)
    case invalidIntegerLiteral(String)
    case unsupportedTerm(String)
    case invalidShapesGraph(String)
    case notImplemented(String)

    public var errorDescription: String? {
        switch self {
        case .invalidUTF8:
            return "Invalid UTF-8 input."
        case .invalidPrefixDeclaration(let line):
            return "Invalid @prefix declaration: \(line)"
        case .unknownPrefix(let prefix):
            return "Unknown prefix: \(prefix)"
        case .invalidStatement(let statement):
            return "Invalid statement: \(statement)"
        case .invalidIntegerLiteral(let value):
            return "Invalid integer literal: \(value)"
        case .unsupportedTerm(let term):
            return "Unsupported RDF term in SHACLKit Turtle subset parser: \(term)"
        case .invalidShapesGraph(let detail):
            return "Invalid SHACL shapes graph: \(detail)"
        case .notImplemented(let detail):
            return "SHACL feature not implemented: \(detail)"
        }
    }
}
