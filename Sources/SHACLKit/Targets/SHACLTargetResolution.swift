import Foundation

public struct SHACLTargetResolution: Sendable, Equatable {
    public let shapeIRI: String
    public let focusNodes: [String]

    public init(shapeIRI: String, focusNodes: [String]) {
        self.shapeIRI = shapeIRI
        self.focusNodes = focusNodes
    }
}
