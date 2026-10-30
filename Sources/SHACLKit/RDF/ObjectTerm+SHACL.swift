import IRIKit
import RDFCore

extension ObjectTerm {
    /// The IRI, when the term is one.
    var iri: IRI? {
        if case .iri(let iri) = self { return iri }
        return nil
    }

    /// The literal, when the term is one.
    var literal: Literal? {
        if case .literal(let literal) = self { return literal }
        return nil
    }

    var isIRI: Bool { iri != nil }

    var isLiteral: Bool { literal != nil }

    var isBlankNode: Bool {
        if case .blankNode = self { return true }
        return false
    }

    /// The term as SPARQL's `STR` gives it (SPARQL 1.2 §17.4.2.5): the
    /// lexical form of a literal and the string of an IRI. Blank nodes and
    /// triple terms have none.
    var stringValue: String? {
        switch self {
        case .iri(let iri): iri.rawValue
        case .literal(let literal): literal.lexicalForm
        case .blankNode, .tripleTerm: nil
        }
    }

    /// The term in subject position of a triple term's components.
    init(_ subject: SubjectTerm) {
        self = subject.object
    }
}

extension Sequence where Element == ObjectTerm {
    /// The terms in a stable order: by their N-Triples form.
    ///
    /// RDF terms have no order of their own (RDF 1.2 Concepts §3); results
    /// and focus nodes are reported in this one so that a validation gives
    /// the same report every time.
    func sorted() -> [ObjectTerm] {
        sorted { $0.description < $1.description }
    }

    /// The terms without repeats, in their first order.
    func uniqued() -> [ObjectTerm] {
        var seen: Set<ObjectTerm> = []
        return filter { seen.insert($0).inserted }
    }
}
