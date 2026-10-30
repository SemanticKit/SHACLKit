import Foundation
import IRIKit
import RDFCore
import RDFKit
import Testing
@testable import SHACLKit

@Suite("W3C data-shapes test suites", .tags(.w3c))
struct W3CSuiteTests {
    private static let suite = Fixtures.url("W3CDataShapes/shacl12-test-suite/tests")

    /// The Turtle files of a directory of the SHACL 1.2 suite, recursively
    /// when `recursive`, in path order.
    private static func turtleFiles(in directory: String, recursive: Bool = false) throws -> [URL] {
        let root = suite.appendingPathComponent(directory)
        let files: [URL]
        if recursive {
            let enumerator = try #require(FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil))
            files = enumerator.compactMap { $0 as? URL }
        } else {
            files = try FileManager.default.contentsOfDirectory(at: root, includingPropertiesForKeys: nil)
        }
        return files.filter { $0.pathExtension == "ttl" }.sorted { $0.path < $1.path }
    }

    @Test func w3cCuratedFixturePackIsSyncedIntoTestResources() {
        let manager = FileManager.default
        #expect(manager.fileExists(atPath: Fixtures.url("W3CDataShapes/SourceInventory.md").path))
        #expect(manager.fileExists(atPath: Fixtures.url("W3CDataShapes/data-shapes-test-suite/tests/manifest.ttl").path))
        #expect(manager.fileExists(atPath: Fixtures.url("W3CDataShapes/shacl12-test-suite/tests/manifest.ttl").path))
        #expect(manager.fileExists(atPath: Fixtures.url("W3CDataShapes/shacl12-test-suite/tests/rules/manifest-rules.ttl").path))
    }

    @Test func w3cNodeExprShnexFixturesParseThroughSHACLLoaders() throws {
        let files = try Self.turtleFiles(in: "node-expr/shnex")
        #expect(!files.isEmpty)
        for file in files {
            let graph = try Fixtures.graph(at: file)
            _ = try SHACLShapesGraph(graph)
            #expect(!graph.isEmpty)
        }
    }

    @Test func w3cRulesEvalFixturesParseThroughSHACLLoaders() throws {
        let files = try Self.turtleFiles(in: "rules/eval").filter {
            $0.lastPathComponent.hasPrefix("data-") || $0.lastPathComponent.hasSuffix("-results.ttl")
        }
        #expect(!files.isEmpty)
        for file in files {
            _ = try SHACLShapesGraph(Fixtures.graph(at: file))
        }
    }

    @Test func w3cRulesManifestFixturesParseThroughSHACLLoaders() throws {
        for path in ["manifest-rules.ttl", "eval/manifest.ttl", "stratification/manifest.ttl", "syntax/manifest.ttl", "wellformed/manifest.ttl"] {
            _ = try SHACLShapesGraph(Fixtures.graph(at: Self.suite.appendingPathComponent("rules/\(path)")))
        }
    }

    @Test func w3cSPARQLFixturesParseThroughDataLoader() throws {
        let files = try Self.turtleFiles(in: "sparql", recursive: true)
        #expect(!files.isEmpty)
        for file in files {
            _ = try Fixtures.graph(at: file)
        }
    }

    @Test func w3cSPARQLManifestTreeReferencesExistingArtifacts() throws {
        var pending = [Self.suite.appendingPathComponent("sparql/manifest.ttl")]
        var visited: Set<URL> = []
        while let manifest = pending.popLast() {
            guard visited.insert(manifest.standardizedFileURL).inserted else { continue }
            #expect(FileManager.default.fileExists(atPath: manifest.path))
            let graph = try Fixtures.graph(at: manifest)
            for include in graph.compactMap({ $0.predicate == W3CManifest.include ? W3CManifest.file($0.object) : nil }) {
                #expect(FileManager.default.fileExists(atPath: include.path))
                pending.append(include)
            }
            for entry in W3CManifest.entries(of: W3CManifest.validate, in: graph) {
                let action = try #require(graph.object(of: entry, W3CManifest.action))
                _ = try #require(graph.object(of: entry, W3CManifest.result))
                let graphs = graph.objects(of: action, W3CManifest.dataGraph) + graph.objects(of: action, W3CManifest.shapesGraph)
                #expect(graphs.count == 2)
                for file in graphs.compactMap(W3CManifest.file) {
                    #expect(FileManager.default.fileExists(atPath: file.path), "Missing SPARQL manifest graph artifact: \(file.path)")
                }
            }
        }
        #expect(visited.count >= 5)
    }

    @Test(arguments: [
        ("sparql/node/sparql-001.ttl", false, 3),
        ("sparql/pre-binding/pre-binding-001.ttl", false, 1),
        ("sparql/targets/targetNode-select-001.ttl", false, 1),
    ])
    func w3cSPARQLCuratedValidationSubsetMatchesExpectations(fixture: String, conforms: Bool, results: Int) throws {
        let graph = try Fixtures.graph(at: Self.suite.appendingPathComponent(fixture))
        let report = try SHACLValidator(sparqlExecutor: W3CSPARQLFixtureSubsetExecutor()).validate(graph, against: SHACLShapesGraph(graph))
        #expect(report.conforms == conforms)
        #expect(report.results.count == results)
    }

    @Test func w3cRulesEvalManifestReferencesExistingArtifacts() throws {
        let graph = try Fixtures.graph(at: Self.suite.appendingPathComponent("rules/eval/manifest.ttl"))
        let entries = W3CManifest.entries(of: W3CManifest.rulesEvalTest, in: graph)
        #expect(!entries.isEmpty)
        for entry in entries {
            let action = try #require(graph.object(of: entry, W3CManifest.action))
            let files = [
                graph.object(of: action, W3CManifest.ruleset),
                graph.object(of: action, W3CManifest.data),
                graph.object(of: entry, W3CManifest.result),
            ]
            for file in files {
                let url = try #require(file.flatMap(W3CManifest.file))
                #expect(FileManager.default.fileExists(atPath: url.path))
            }
        }
    }

    @Test func w3cRulesSyntaxAndWellformedManifestsReferenceExistingRulesetArtifacts() throws {
        for manifest in ["syntax/manifest.ttl", "wellformed/manifest.ttl", "stratification/manifest.ttl"] {
            let graph = try Fixtures.graph(at: Self.suite.appendingPathComponent("rules/\(manifest)"))
            let rulesets = Set(graph.compactMap { $0.predicate == W3CManifest.action ? W3CManifest.file($0.object) : nil }
                .filter { $0.pathExtension == "srl" })
            #expect(!rulesets.isEmpty)
            for ruleset in rulesets {
                #expect(FileManager.default.fileExists(atPath: ruleset.path))
            }
        }
    }

    @Test(arguments: [
        ("syntax/manifest.ttl", SrlPreflightSuite.syntax, "RulesPositiveSyntaxTest", "RulesNegativeSyntaxTest"),
        ("wellformed/manifest.ttl", .wellformed, "RulesPositiveWellFormednessTest", "RulesNegativeWellFormednessTest"),
        ("stratification/manifest.ttl", .stratification, "RulesPositiveStratificationTest", "RulesNegativeStratificationTest"),
    ])
    func w3cRulesSrlSuitesMatchPositiveAndNegativeManifestExpectations(
        manifest: String,
        suite: SrlPreflightSuite,
        positive: String,
        negative: String
    ) throws {
        let namespace = "http://www.w3.org/ns/shacl-rules-test#"
        let positiveType = ObjectTerm.iri(IRI(rawValue: namespace + positive)!)
        let negativeType = ObjectTerm.iri(IRI(rawValue: namespace + negative)!)
        let graph = try Fixtures.graph(at: Self.suite.appendingPathComponent("rules/\(manifest)"))
        let entries = W3CManifest.entries(of: positiveType, in: graph) + W3CManifest.entries(of: negativeType, in: graph)
        #expect(!entries.isEmpty)
        for entry in entries {
            let ruleset = try #require(graph.object(of: entry, W3CManifest.action).flatMap(W3CManifest.file))
            var preflight = SrlRulesetPreflight(source: try String(contentsOf: ruleset, encoding: .utf8))
            let expectedValid = graph.objects(of: entry, W3CManifest.type).contains(positiveType)
            #expect(
                preflight.validate(suite: suite) == expectedValid,
                "SRL suite mismatch for \(manifest): \(ruleset.lastPathComponent) expected \(expectedValid ? "valid" : "invalid")"
            )
        }
    }

    @Test(arguments: [
        "concat.ttl", "constant.ttl", "count.ttl", "distinct.ttl", "empty.ttl", "exists.ttl", "filterShape.ttl",
        "findFirst.ttl", "flatMap.ttl", "if.ttl", "instancesOf.ttl", "intersection.ttl", "limit.ttl", "list.ttl",
        "matchAll.ttl", "max.ttl", "min.ttl", "nodesMatching.ttl", "offset.ttl", "orderBy.ttl", "pathValues.ttl",
        "remove.ttl", "sum.ttl", "var.ttl",
    ])
    func w3cNodeExprShnexEvalSubsetMatchesManifestResults(manifest: String) throws {
        let graph = try Fixtures.graph(at: Self.suite.appendingPathComponent("node-expr/shnex/\(manifest)"))
        let shapes = try SHACLShapesGraph(graph)
        let cases = W3CNodeExprEvalCase.cases(in: graph, manifest: manifest)
        #expect(!cases.isEmpty)
        for evalCase in cases {
            let output = try shapes.expression(evalCase.expression).evaluate(
                focusNode: evalCase.focusNode,
                dataGraph: graph,
                shapesGraph: shapes,
                variables: evalCase.variables
            )
            if evalCase.ignoreOrder {
                #expect(output.counted == evalCase.expected.counted, "W3C node-expr case \(evalCase.caseID) multiset mismatch")
            } else {
                #expect(output == evalCase.expected, "W3C node-expr case \(evalCase.caseID) ordered mismatch")
            }
        }
    }

    @Test(arguments: W3CCuratedConformanceCase.all)
    func w3cCuratedConformanceSubsetMatchesExpectations(_ testCase: W3CCuratedConformanceCase) throws {
        let files = try testCase.graphFiles()
        let validator = SHACLValidator(conformanceDisallows: testCase.disallowedSeverities)
        let report = try validator.validate(Fixtures.graph(at: files.data), against: SHACLShapesGraph(Fixtures.graph(at: files.shapes)))
        #expect(report.conforms == testCase.expectedConforms, "W3C curated case \(testCase.caseID)")
    }

    @Test("The curated subset covers every case main's suite ran")
    func w3cCuratedConformanceSubsetSize() {
        #expect(W3CCuratedConformanceCase.all.count == 238)
    }
}

private extension Array where Element == ObjectTerm {
    /// The terms with how often each one occurs.
    var counted: [ObjectTerm: Int] {
        reduce(into: [:]) { $0[$1, default: 0] += 1 }
    }
}
