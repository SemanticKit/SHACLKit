import IRIKit
import RDF
import struct RDFCore.Literal
import RDFCore
import SHACL
import struct RDFCore.Graph

extension SHACL.NodeKindIndividual {
    /// The node kinds SHACL 1.2 Core §4.1.3 declares, as shacl.ttl's
    /// individuals.
    static var declared: [SHACL.NodeKindIndividual] {
        [SHACL.IRI, SHACL.Literal, SHACL.BlankNode, SHACL.BlankNodeOrIRI, SHACL.BlankNodeOrLiteral, SHACL.IRIOrLiteral, SHACL.TripleTerm]
    }

    /// The node kind the node `term` of a shapes graph denotes, read where
    /// the shapes graph is decoded: the individual whose IRI it is.
    static func named(_ term: ObjectTerm) -> SHACL.NodeKindIndividual? {
        guard let iri = term.iri else { return nil }
        return declared.first { $0.iri == iri }
    }
}

extension SHACL.NodeKind {
    /// Whether `node` has this node kind (SHACL 1.2 Core §4.1.3:
    /// "sh:BlankNode, sh:IRI, sh:Literal, sh:BlankNodeOrIRI,
    /// sh:BlankNodeOrLiteral and sh:IRIOrLiteral", and sh:TripleTerm).
    func admits(_ node: ObjectTerm) -> Bool {
        let isIRI = node.isIRI, isBlankNode = node.isBlankNode, isLiteral = node.isLiteral
        if self === SHACL.IRI { return isIRI }
        if self === SHACL.Literal { return isLiteral }
        if self === SHACL.BlankNode { return isBlankNode }
        if self === SHACL.BlankNodeOrIRI { return isBlankNode || isIRI }
        if self === SHACL.BlankNodeOrLiteral { return isBlankNode || isLiteral }
        if self === SHACL.IRIOrLiteral { return isIRI || isLiteral }
        if self === SHACL.TripleTerm { return !isIRI && !isBlankNode && !isLiteral }
        return false
    }
}
