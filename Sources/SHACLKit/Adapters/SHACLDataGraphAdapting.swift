import RDFCore
import RDF
import struct RDFCore.Literal

/// Turns a source of data, such as an app's typed values, into the RDFCore
/// graph a validator reads: the boundary where a data graph's terms are
/// written as RDF.
public protocol SHACLDataGraphAdapting: Sendable {
    associatedtype Source
    func adapt(_ source: Source) throws -> Graph
}
