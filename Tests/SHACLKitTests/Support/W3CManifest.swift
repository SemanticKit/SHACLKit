import Foundation
import IRIKit
import RDFCore
import RDFFormats
import Testing
import RDF
import SHACL
import TestManifest
import struct RDFCore.Literal
import struct RDFCore.Graph
@testable import SHACLKit

// W3C test manifests are Turtle, decoded into an RDFCore graph. The `mf:`
// terms they are written in come from the DAWG test-manifest.ttl, which
// SPARQLKit's TestManifest target translates. The SHACL suites' own `sht:`
// (shacl-test#) and `srt:` (shacl-rules-test#) terms have no published
// vocabulary document in w3c/data-shapes, so each decoder below names the
// ones it reads at the boundary, where it turns an entry into its case.

extension Graph {
    /// The objects of `node`'s `property`, a property a translated
    /// vocabulary declares.
    func objects(of node: ObjectTerm, _ property: any RDFCore.PropertyTerm.Type) -> [ObjectTerm] {
        objects(of: node, IRIKit.IRI(of: property)!)
    }

    /// The object of `node`'s `property`, a property a translated
    /// vocabulary declares.
    func object(of node: ObjectTerm, _ property: any RDFCore.PropertyTerm.Type) -> ObjectTerm? {
        object(of: node, IRIKit.IRI(of: property)!)
    }

    /// The manifest entries whose `rdf:type` is `type`, in a stable order.
    func entries(typed type: ObjectTerm) -> [ObjectTerm] {
        subjects(IRIKit.IRI(of: RDF.type.self)!, type).sorted()
    }

    /// The manifests an `mf:include` names.
    var includedManifests: [URL] {
        compactMap { $0.predicate == IRIKit.IRI(of: TestManifest.include.self) ? $0.object.file : nil }
    }

    /// The files an `mf:action` names.
    var actionFiles: [URL] {
        compactMap { $0.predicate == IRIKit.IRI(of: TestManifest.action.self) ? $0.object.file : nil }
    }
}

extension ObjectTerm {
    /// The file a manifest names, when it is a `file:` IRI.
    var file: URL? {
        iri.flatMap { URL(string: $0.rawValue) }.flatMap { $0.isFileURL ? $0 : nil }
    }
}

/// One `sht:Validate` entry of a SHACL test manifest: its `mf:action` names
/// a data graph and a shapes graph, and its `mf:result` is the report.
struct W3CValidateTest {
    let entry: ObjectTerm
    let dataGraph: [ObjectTerm]
    let shapesGraph: [ObjectTerm]
    let result: ObjectTerm?

    /// The `sht:Validate` entries of the manifest graph `graph`.
    static func entries(in graph: Graph) -> [W3CValidateTest] {
        graph.entries(typed: .iri("http://www.w3.org/ns/shacl-test#Validate")).compactMap { entry in
            guard let action = graph.object(of: entry, TestManifest.action.self) else { return nil }
            return W3CValidateTest(
                entry: entry,
                dataGraph: graph.objects(of: action, "http://www.w3.org/ns/shacl-test#dataGraph"),
                shapesGraph: graph.objects(of: action, "http://www.w3.org/ns/shacl-test#shapesGraph"),
                result: graph.object(of: entry, TestManifest.result.self)
            )
        }
    }
}

/// One `srt:RulesEvalTest` entry of a SHACL rules manifest: its `mf:action`
/// names a ruleset and a data graph, and its `mf:result` the inferred graph.
struct W3CRulesEvalTest {
    let ruleset: ObjectTerm?
    let data: ObjectTerm?
    let result: ObjectTerm?

    /// The `srt:RulesEvalTest` entries of the manifest graph `graph`.
    static func entries(in graph: Graph) -> [W3CRulesEvalTest] {
        graph.entries(typed: .iri("http://www.w3.org/ns/shacl-rules-test#RulesEvalTest")).compactMap { entry in
            guard let action = graph.object(of: entry, TestManifest.action.self) else { return nil }
            return W3CRulesEvalTest(
                ruleset: graph.object(of: action, "http://www.w3.org/ns/shacl-rules-test#ruleset"),
                data: graph.object(of: action, "http://www.w3.org/ns/shacl-rules-test#data"),
                result: graph.object(of: entry, TestManifest.result.self)
            )
        }
    }
}

/// One positive or negative SRL syntax, well-formedness or stratification
/// entry of a SHACL rules manifest: the ruleset its `mf:action` names, and
/// whether the entry's `rdf:type` says the ruleset is valid.
struct W3CRulesSrlTest {
    let ruleset: URL?
    let expectedValid: Bool

    /// The positive and negative SRL entries of the manifest graph `graph`.
    static func entries(in graph: Graph) -> [W3CRulesSrlTest] {
        let positive: [ObjectTerm] = [
            .iri("http://www.w3.org/ns/shacl-rules-test#RulesPositiveSyntaxTest"),
            .iri("http://www.w3.org/ns/shacl-rules-test#RulesPositiveWellFormednessTest"),
            .iri("http://www.w3.org/ns/shacl-rules-test#RulesPositiveStratificationTest"),
        ]
        let negative: [ObjectTerm] = [
            .iri("http://www.w3.org/ns/shacl-rules-test#RulesNegativeSyntaxTest"),
            .iri("http://www.w3.org/ns/shacl-rules-test#RulesNegativeWellFormednessTest"),
            .iri("http://www.w3.org/ns/shacl-rules-test#RulesNegativeStratificationTest"),
        ]
        let typed = positive.flatMap { graph.entries(typed: $0).map { ($0, true) } }
            + negative.flatMap { graph.entries(typed: $0).map { ($0, false) } }
        return typed.map { entry, valid in
            W3CRulesSrlTest(ruleset: graph.object(of: entry, TestManifest.action.self)?.file, expectedValid: valid)
        }
    }
}

/// One `sht:EvalNodeExpr` entry of a W3C node expression manifest.
struct W3CNodeExprEvalCase {
    let caseID: String
    let expression: ObjectTerm
    let focusNode: ObjectTerm?
    let ignoreOrder: Bool
    let variables: [String: [ObjectTerm]]
    let expected: [ObjectTerm]

    /// The entries of the manifest graph `graph`.
    static func cases(in graph: Graph, manifest: String) -> [W3CNodeExprEvalCase] {
        // `sht:scope-<name>` binds the variable `<name>` of the expression.
        let scope = "http://www.w3.org/ns/shacl-test#scope-"
        return graph.entries(typed: .iri("http://www.w3.org/ns/shacl-test#EvalNodeExpr")).compactMap { entry in
            guard let action = graph.object(of: entry, TestManifest.action.self),
                  let expression = graph.object(of: action, "http://www.w3.org/ns/shacl-test#nodeExpr"),
                  let result = graph.object(of: entry, TestManifest.result.self) else { return nil }
            var variables: [String: [ObjectTerm]] = [:]
            for triple in graph.triples(of: action) where triple.predicate.rawValue.hasPrefix(scope) {
                variables[String(triple.predicate.rawValue.dropFirst(scope.count)), default: []].append(triple.object)
            }
            return W3CNodeExprEvalCase(
                caseID: "\(manifest)#\(entry)",
                expression: expression,
                focusNode: graph.object(of: action, "http://www.w3.org/ns/shacl-test#focusNode"),
                ignoreOrder: graph.object(of: action, "http://www.w3.org/ns/shacl-test#ignoreOrder")?.literal?.isTrue ?? false,
                variables: variables,
                expected: graph.list(result) ?? []
            )
        }
    }
}

/// One row of the curated W3C conformance manifest.
struct W3CCuratedConformanceCase: CustomTestStringConvertible, Sendable {
    let caseID: String
    let dataGraph: String
    let shapesGraph: String
    let expectedConforms: Bool
    let conformanceDisallows: [String]?

    var testDescription: String { caseID }

    /// The rows of `W3CCuratedConformanceManifest.tsv`: case id, data graph,
    /// shapes graph, expected `sh:conforms`, notes, and the
    /// `sh:conformanceDisallows` severities of the expected report.
    static var all: [W3CCuratedConformanceCase] {
        // The manifest is a fixture of this target and always reads.
        let text = try! Fixtures.text("W3CDataShapes/W3CCuratedConformanceManifest.tsv")
        return text.split(whereSeparator: \.isNewline).compactMap { line in
            let line = line.trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty, !line.hasPrefix("#") else { return nil }
            let fields = line.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
            let disallows = fields.count >= 6 && !fields[5].isEmpty ? fields[5].split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } : nil
            return W3CCuratedConformanceCase(
                caseID: fields[0],
                dataGraph: fields[1],
                shapesGraph: fields[2],
                expectedConforms: fields[3].lowercased() == "true",
                conformanceDisallows: disallows
            )
        }
    }

    /// The data and shapes graph files, through the `sht:dataGraph` and
    /// `sht:shapesGraph` of a test whose action names other files.
    func graphFiles() throws -> (data: URL, shapes: URL) {
        let data = Fixtures.url("W3CDataShapes/\(dataGraph)")
        let shapes = Fixtures.url("W3CDataShapes/\(shapesGraph)")
        guard dataGraph == shapesGraph else { return (data, shapes) }
        let graph = try Fixtures.graph("W3CDataShapes/\(dataGraph)")
        for test in W3CValidateTest.entries(in: graph) {
            guard let dataFile = test.dataGraph.first?.file, let shapesFile = test.shapesGraph.first?.file else { continue }
            return (dataFile, shapesFile)
        }
        return (data, shapes)
    }

    /// The severities the row disallows, as SHACL's individuals.
    var disallowedSeverities: [any SHACL.Severity]? {
        conformanceDisallows?.map { name -> any SHACL.Severity in
            switch name.lowercased() {
            case "warning": SHACL.Warning
            case "info": SHACL.Info
            default: SHACL.Violation
            }
        }
    }
}
