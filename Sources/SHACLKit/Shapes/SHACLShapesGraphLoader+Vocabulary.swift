import Foundation

extension SHACLShapesGraphLoader {
    func targetSortKey(_ selector: SHACLTargetSelector) -> String {
        switch selector {
        case .targetClass(let iri):
            return "0:\(iri)"
        case .targetNode(let iri):
            return "1:\(iri)"
        case .targetNodeExpression(let iri):
            return "2:\(iri)"
        case .targetSubjectsOf(let iri):
            return "3:\(iri)"
        case .targetObjectsOf(let iri):
            return "4:\(iri)"
        case .targetWhere(let iri):
            return "5:\(iri)"
        }
    }

    func parseNodeKind(_ iri: String) -> SHACLNodeKindConstraint? {
        switch iri {
        case SHACLIRIs.nodeKindIRI:
            return .iri
        case SHACLIRIs.nodeKindLiteral:
            return .literal
        case SHACLIRIs.nodeKindBlankNode:
            return .blankNode
        case SHACLIRIs.nodeKindBlankNodeOrIRI:
            return .blankNodeOrIRI
        case SHACLIRIs.nodeKindBlankNodeOrLiteral:
            return .blankNodeOrLiteral
        case SHACLIRIs.nodeKindIRIOrLiteral:
            return .iriOrLiteral
        default:
            return nil
        }
    }

    func parseNodeKindConstraint(
        _ term: String,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> SHACLNodeKindConstraint? {
        if let direct = parseNodeKind(term) {
            return direct
        }

        let listTerms = resolveRDFListTermsOrdered(term, triplesBySubject: triplesBySubject)
        let resolvedKinds = listTerms.compactMap(parseNodeKind)
        guard resolvedKinds.count == listTerms.count, !resolvedKinds.isEmpty else {
            return nil
        }
        let uniqueKinds = Set(resolvedKinds)
        if uniqueKinds.count == 1 {
            return uniqueKinds.first
        }
        if uniqueKinds == Set<SHACLNodeKindConstraint>([.blankNode, .iri]) {
            return .blankNodeOrIRI
        }
        if uniqueKinds == Set<SHACLNodeKindConstraint>([.blankNode, .literal]) {
            return .blankNodeOrLiteral
        }
        if uniqueKinds == Set<SHACLNodeKindConstraint>([.iri, .literal]) {
            return .iriOrLiteral
        }
        return nil
    }

    func parseSeverity(_ iri: String) -> SHACLSeverity? {
        switch iri {
        case SHACLIRIs.severityViolation:
            return .violation
        case SHACLIRIs.severityWarning:
            return .warning
        case SHACLIRIs.severityInfo:
            return .info
        default:
            return nil
        }
    }
}
