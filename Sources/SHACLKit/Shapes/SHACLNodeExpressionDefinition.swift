import Foundation

public struct SHACLNodeExpressionDefinition: Sendable, Hashable {
    public let expressionIRI: String
    public let kind: SHACLNodeExpressionKind

    public init(expressionIRI: String, kind: SHACLNodeExpressionKind) {
        self.expressionIRI = expressionIRI
        self.kind = kind
    }
}
