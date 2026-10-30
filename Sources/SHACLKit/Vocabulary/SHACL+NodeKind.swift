import RDFCore

extension SHACL.NodeKind {
    /// Whether `node` has this node kind (SHACL 1.2 Core §4.1.3:
    /// "sh:BlankNode, sh:IRI, sh:Literal, sh:BlankNodeOrIRI,
    /// sh:BlankNodeOrLiteral and sh:IRIOrLiteral").
    func admits(_ node: ObjectTerm) -> Bool {
        let isIRI = node.isIRI, isBlankNode = node.isBlankNode, isLiteral = node.isLiteral
        if self === SHACL.IRI { return isIRI }
        if self === SHACL.Literal { return isLiteral }
        if self === SHACL.BlankNode { return isBlankNode }
        if self === SHACL.BlankNodeOrIRI { return isBlankNode || isIRI }
        if self === SHACL.BlankNodeOrLiteral { return isBlankNode || isLiteral }
        if self === SHACL.IRIOrLiteral { return isIRI || isLiteral }
        return false
    }
}
