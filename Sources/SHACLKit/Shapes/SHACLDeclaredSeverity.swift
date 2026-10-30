import RDFCore
import RDFKit

/// A severity a shapes graph names beyond the ones SHACL declares (SHACL
/// 1.2 Core §2.1.4 lets `sh:severity` be any IRI).
///
/// It is an individual of ``SHACL/Severity``, made once for each node a
/// shapes graph names as a severity, so two results with that severity have
/// the same object as their severity. The node is kept for the boundary,
/// where a result writes its `sh:resultSeverity`.
public final class SHACLDeclaredSeverity: SHACL.Severity, CustomStringConvertible {
    public static let metadata: any ContentMetadata = SHACL.SeverityIndividual.metadata

    /// The severity's node in the shapes graph.
    public let id: ObjectTerm

    init(_ id: ObjectTerm) {
        self.id = id
    }

    public var description: String { id.description }
}
