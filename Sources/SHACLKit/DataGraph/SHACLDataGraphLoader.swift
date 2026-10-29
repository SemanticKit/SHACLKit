import Foundation

public struct SHACLDataGraphLoader: SHACLDataGraphLoading {
    public init() {}

    public func load(from data: Data) throws -> SHACLDataGraph {
        guard let source = String(data: data, encoding: .utf8) else {
            throw SHACLError.invalidUTF8
        }
        let parser = SHACLTurtleSubsetParser(source: source)
        let triples = try parser.parseTriples().map {
            SHACLDataTriple(subject: $0.subject, predicate: $0.predicate, object: $0.object)
        }
        return SHACLDataGraph(triples: triples)
    }
}
