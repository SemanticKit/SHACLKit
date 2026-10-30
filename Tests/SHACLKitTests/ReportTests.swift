import Foundation
import IRIKit
import RDFCore
import RDFFormats
import RDFKit
import Testing
import RDF
import struct RDFCore.Literal
import SHACL
import struct RDFCore.Graph
@testable import SHACLKit

@Suite("Validation reports as RDF", .tags(.report, .w3c))
struct ReportTests {
    /// The triples reachable from `node` through blank nodes: the
    /// description of `node` a manifest writes inline.
    private func description(of node: ObjectTerm, in graph: Graph) -> Graph {
        var description = Graph()
        var pending = [node]
        var visited: Set<ObjectTerm> = []
        while let next = pending.popLast() {
            guard visited.insert(next).inserted else { continue }
            for triple in graph.triples(of: next) {
                description.insert(triple)
                if triple.object.isBlankNode { pending.append(triple.object) }
            }
        }
        return description
    }

    /// The report the W3C test in `fixture` expects as its `mf:result`.
    private func expectedReport(in graph: Graph) throws -> Graph {
        let result = try #require(W3CValidateTest.entries(in: graph).first?.result)
        return description(of: result, in: graph)
    }

    @Test(
        "A report is written as the graph the W3C test expects",
        arguments: [
            "shacl12-test-suite/tests/core/validation-reports/conformance-disallows-002.ttl",
            "shacl12-test-suite/tests/core/node/class-001.ttl",
            "shacl12-test-suite/tests/core/property/minCount-001.ttl",
            "shacl12-test-suite/tests/core/path/path-sequence-001.ttl",
        ]
    )
    func reportGraphMatchesExpectedResult(fixture: String) throws {
        let graph = try Fixtures.graph("W3CDataShapes/\(fixture)")
        let report = try SHACLValidator().validate(graph, against: SHACLShapesGraph(graph))
        let written = Graph(report.graph.filter { $0.predicate != IRIKit.IRI(of: SHACL.resultMessage)! })
        let expected = Graph(try expectedReport(in: graph).filter { $0.predicate != IRIKit.IRI(of: SHACL.resultMessage)! })
        #expect(written.isIsomorphic(to: expected), "Report of \(fixture):\n\(written)\nexpected:\n\(expected)")
    }

    @Test("A conforming report is one sh:ValidationReport with sh:conforms true")
    func conformingReportGraph() throws {
        let report = SHACLValidationReport(conforms: true)
        let report1 = try BlankNode("report")
        #expect(report.graph == [
            Graph.Element(subject: .blankNode(report1), predicate: IRIKit.IRI(of: RDF.type)!, object: .iri(IRIKit.IRI(of: SHACL.ValidationReportIndividual.self)!)),
            Graph.Element(subject: .blankNode(report1), predicate: IRIKit.IRI(of: SHACL.conforms)!, object: term("true")),
        ])
    }
}
