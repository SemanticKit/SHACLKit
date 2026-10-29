import Foundation

public struct SHACLSPARQLDefinition: Sendable, Hashable {
    public let sparqlIRI: String
    public let selectQuery: String?
    public let askQuery: String?
    public let message: String?
    public let prefixes: [String: String]

    public init(
        sparqlIRI: String,
        selectQuery: String? = nil,
        askQuery: String? = nil,
        message: String? = nil,
        prefixes: [String: String] = [:]
    ) {
        self.sparqlIRI = sparqlIRI
        self.selectQuery = selectQuery
        self.askQuery = askQuery
        self.message = message
        self.prefixes = prefixes
    }
}
