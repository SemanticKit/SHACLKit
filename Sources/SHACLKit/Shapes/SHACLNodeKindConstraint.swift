import Foundation

public enum SHACLNodeKindConstraint: String, Sendable, Codable, Hashable {
    case iri
    case literal
    case blankNode
    case blankNodeOrIRI
    case blankNodeOrLiteral
    case iriOrLiteral
}
