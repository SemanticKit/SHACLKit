import IRIKit
import RDF
import RDFCore
import RDFFormats
import struct RDFCore.Literal
import struct RDFCore.Graph
@testable import SHACLKit

/// An executor that answers the queries it is given answers for, by query
/// text and the focus node `$this` is pre-bound to.
struct TestSPARQLExecutor: SHACLSPARQLExecutor {
    var selectResults: [String: [SHACLSPARQLSolution]] = [:]
    var askResults: [String: Bool] = [:]

    /// The key of a query run with `$this` pre-bound to `focusNode`.
    static func key(_ query: String, this focusNode: ObjectTerm? = nil) -> String {
        "\(query)|\(focusNode?.description ?? "")"
    }

    func select(query: String, bindings: SHACLSPARQLSolution, dataGraph: Graph, shapesGraph: SHACLShapesGraph) throws -> [SHACLSPARQLSolution] {
        selectResults[Self.key(query, this: bindings["this"])] ?? []
    }

    func ask(query: String, bindings: SHACLSPARQLSolution, dataGraph: Graph, shapesGraph: SHACLShapesGraph) throws -> Bool {
        askResults[Self.key(query, this: bindings["this"])] ?? true
    }
}

/// An executor whose `SELECT` queries find `ex:alice` when the query has the
/// `ex:` prefix injected and keeps its `'prefix ex:'` string literal.
struct PrefixMarkerLiteralSPARQLExecutor: SHACLSPARQLExecutor {
    func select(query: String, bindings: SHACLSPARQLSolution, dataGraph: Graph, shapesGraph: SHACLShapesGraph) throws -> [SHACLSPARQLSolution] {
        guard query.contains("PREFIX ex: <http://example.com/>"),
              query.contains("BIND('prefix ex:' AS ?marker)"),
              query.contains("?this ex:name ?name"),
              bindings["this"] == term("ex:alice") else { return [] }
        return [["this": term("ex:alice")]]
    }

    func ask(query: String, bindings: SHACLSPARQLSolution, dataGraph: Graph, shapesGraph: SHACLShapesGraph) throws -> Bool {
        false
    }
}

/// An executor whose `SELECT` queries over `ex:name` and `STRLEN` find
/// `ex:alice`.
struct GuardLiteralKeywordSPARQLExecutor: SHACLSPARQLExecutor {
    func select(query: String, bindings: SHACLSPARQLSolution, dataGraph: Graph, shapesGraph: SHACLShapesGraph) throws -> [SHACLSPARQLSolution] {
        let uppercased = query.uppercased()
        guard uppercased.contains("?THIS"), uppercased.contains("EX:NAME"), uppercased.contains("STRLEN"),
              bindings["this"] == term("ex:alice") else { return [] }
        return [["this": term("ex:alice")]]
    }

    func ask(query: String, bindings: SHACLSPARQLSolution, dataGraph: Graph, shapesGraph: SHACLShapesGraph) throws -> Bool {
        false
    }
}

/// An executor whose `ASK` queries are all false.
struct AlwaysFalseAskSPARQLExecutor: SHACLSPARQLExecutor {
    func select(query: String, bindings: SHACLSPARQLSolution, dataGraph: Graph, shapesGraph: SHACLShapesGraph) throws -> [SHACLSPARQLSolution] {
        []
    }

    func ask(query: String, bindings: SHACLSPARQLSolution, dataGraph: Graph, shapesGraph: SHACLShapesGraph) throws -> Bool {
        false
    }
}

/// An executor that answers the queries of the W3C SPARQL fixtures the
/// conformance subset runs, by recognising each query.
struct W3CSPARQLFixtureSubsetExecutor: SHACLSPARQLExecutor {

    func select(query: String, bindings: SHACLSPARQLSolution, dataGraph: Graph, shapesGraph: SHACLShapesGraph) throws -> [SHACLSPARQLSolution] {
        let query = query.lowercased()
        let label = IRIKit.IRI(of: RDF.label.self)!
        if query.contains("filter (?path = <http://www.w3.org/2000/01/rdf-schema#label>)"), let this = bindings["this"], let subject = this.subject {
            return dataGraph.triples(subject: subject, predicate: label).map { ["this": this, "path": .iri(label), "value": $0.object] }
        }
        if query.contains("filter ($this = ex:invalidresource)"), let this = bindings["this"], this == term("ns:InvalidResource") {
            return [["this": this]]
        }
        if query.contains("select ?person"), query.contains("?person ex:age ?age"), query.contains("?age < 18") {
            return [["person": term("ns:Benjamin")]]
        }
        return []
    }

    func ask(query: String, bindings: SHACLSPARQLSolution, dataGraph: Graph, shapesGraph: SHACLShapesGraph) throws -> Bool {
        false
    }
}
