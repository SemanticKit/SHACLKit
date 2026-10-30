import Foundation

/// Why SHACLKit could not validate.
public enum SHACLError: Error, LocalizedError, Equatable {
    /// The shapes graph is ill-formed (SHACL 1.2 Core §3.4: "If the shapes
    /// graph contains ill-formed nodes, then the result of the validation
    /// process is undefined"), so validation stops with this error instead.
    case invalidShapesGraph(String)

    /// A SPARQL query could not be run: no executor was given, or the
    /// executor's policy refused it.
    case sparqlNotExecuted(String)

    public var errorDescription: String? {
        switch self {
        case .invalidShapesGraph(let detail): "Invalid SHACL shapes graph: \(detail)"
        case .sparqlNotExecuted(let detail): "SPARQL query not executed: \(detail)"
        }
    }
}
