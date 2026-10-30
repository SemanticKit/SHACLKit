import IRIKit
import RDFCore
import RDF
import RDFFormats
import RDFKit
import Testing
import SHACL
import struct RDFCore.Literal
import struct RDFCore.Graph
@testable import SHACLKit

@Suite("Validating a data graph", .tags(.report))
struct ValidatorTests {
    private struct TestDataSource {
        let fixture: String
    }

    private struct TestShapesSource {
        let fixture: String
    }

    @Test func coreValidatorSupportsAdapterBoundaryEntryPoint() throws {
        let dataAdapter = AnySHACLDataGraphAdapter<TestDataSource> { try Fixtures.graph($0.fixture) }
        let shapesAdapter = AnySHACLShapesGraphAdapter<TestShapesSource> { try Fixtures.shapes($0.fixture) }
        let report = try SHACLValidator().validate(
            TestDataSource(fixture: "inListConstraintsValid.ttl"),
            adaptedBy: dataAdapter,
            against: TestShapesSource(fixture: "inListConstraintsShapes.ttl"),
            adaptedBy: shapesAdapter
        )
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorMatchesResultsAcrossDataAndGraphEntryPoints() throws {
        let shapes = try Fixtures.shapes("logicalOrShapes.ttl")
        let fromGraph = try SHACLValidator().validate(Fixtures.graph("logicalOrInvalid.ttl"), against: shapes)
        let fromSource = try SHACLValidator().validate(
            TestDataSource(fixture: "logicalOrInvalid.ttl"),
            adaptedBy: AnySHACLDataGraphAdapter<TestDataSource> { try Fixtures.graph($0.fixture) },
            against: shapes,
            adaptedBy: AnySHACLShapesGraphAdapter<SHACLShapesGraph> { $0 }
        )
        #expect(fromGraph == fromSource)
    }

    @Test("A data graph made from typed values validates without any text")
    func coreValidatorLargeGraphSmokeTest() throws {
        let shapes = try SHACLShapesGraph(TurtleDecoder().decode("""
            PREFIX sh: <http://www.w3.org/ns/shacl#>
            PREFIX ex: <http://example.com/>
            ex:PersonShape a sh:NodeShape ;
              sh:targetClass ex:Person ;
              sh:property ex:AgeShape .
            ex:AgeShape a sh:PropertyShape ;
              sh:path ex:age ;
              sh:minInclusive 18 ;
              sh:maxInclusive 90 .
            """))
        let type = RDF.type.iri!
        let age: IRI = "http://example.com/age"
        let person = term("ex:Person")
        let integer = term("25")
        var data = Graph()
        for index in 0..<500 {
            let subject = SubjectTerm.iri(IRI(rawValue: "http://example.com/person\(index)")!)
            data.insert(Graph.Element(subject: subject, predicate: type, object: person))
            data.insert(Graph.Element(subject: subject, predicate: age, object: integer))
        }
        let report = try SHACLValidator().validate(data, against: shapes)
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorRegressionCycleAndSeverityStability() throws {
        let shapes = try Fixtures.shapes("severityWarningShapes.ttl")
        let data = try Fixtures.graph("severityWarningData.ttl")
        let first = try SHACLValidator().validate(data, against: shapes)
        let second = try SHACLValidator().validate(data, against: shapes)
        #expect(first == second)
        #expect(!first.conforms)
        let warning = try #require(first.results.first)
        #expect(warning.severity === SHACL.Warning)
    }

    @Test func coreValidatorAllowsWarningOnlyResultsWhenConfigured() throws {
        let report = try Fixtures.validate(
            shapes: "severityWarningShapes.ttl",
            data: "severityWarningData.ttl",
            with: SHACLValidator(conformanceDisallows: [SHACL.Violation])
        )
        #expect(report.conforms)
        let warning = try #require(report.results.first)
        #expect(warning.severity === SHACL.Warning)
    }

    @Test("A severity a shapes graph names beyond SHACL's is one object for every result")
    func declaredSeveritiesAreShared() throws {
        let shapes = try SHACLShapesGraph(TurtleDecoder().decode("""
            PREFIX sh: <http://www.w3.org/ns/shacl#>
            PREFIX ex: <http://example.com/>
            ex:A a sh:NodeShape ; sh:targetNode ex:x ; sh:class ex:C ; sh:severity ex:MySeverity .
            ex:B a sh:NodeShape ; sh:targetNode ex:y ; sh:class ex:C ; sh:severity ex:MySeverity .
            """))
        let report = try SHACLValidator().validate([], against: shapes)
        #expect(report.results.count == 2)
        let severity = try #require(report.results.first?.severity)
        #expect(![SHACL.Violation, SHACL.Warning, SHACL.Info, SHACL.Debug, SHACL.Trace].contains { $0 === severity })
        #expect(report.graph.contains { $0.predicate == SHACL.resultSeverity.iri! && $0.object == term("ex:MySeverity") })
        #expect(report.results.last?.severity === severity)
    }
}
