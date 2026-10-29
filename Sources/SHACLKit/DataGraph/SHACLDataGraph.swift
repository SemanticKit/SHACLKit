import Foundation

public struct SHACLDataGraph: Sendable, Equatable {
    public let triples: [SHACLDataTriple]

    public init(triples: [SHACLDataTriple]) {
        self.triples = triples
    }
}
