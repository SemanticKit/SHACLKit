import IRIKit
import RDFCore

/// A target of a shape: how its focus nodes are found in the data graph
/// (SHACL 1.2 Core §2.1.3).
public enum SHACLTarget: Sendable, Hashable {
    /// `sh:targetNode` with a term: the term itself.
    case node(ObjectTerm)
    /// `sh:targetNode` with a node expression: its output.
    case nodeExpression(SHACLNodeExpression)
    /// `sh:targetClass`: the SHACL instances of the class.
    case `class`(ObjectTerm)
    /// `sh:targetSubjectsOf`: the subjects of triples with the predicate.
    case subjectsOf(IRI)
    /// `sh:targetObjectsOf`: the objects of triples with the predicate.
    case objectsOf(IRI)
    /// `sh:targetWhere`: the nodes that conform to the shape.
    case `where`(ObjectTerm)
    /// A SPARQL-based target: the bindings of its `sh:select` query.
    case sparql(SHACLSPARQLQuery)
}
