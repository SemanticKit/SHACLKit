import Foundation
import IRIKit
import RDFCore
import Testing
import RDF
import SHACL
import struct RDFCore.Literal
import struct RDFCore.Graph
@testable import SHACLKit

/// The terms of the W3C test manifest vocabularies the suites use, read
/// from manifests as RDF graphs.
enum W3CManifest {
    static var type: IRI { RDF.type.iri! }
    static var first: IRI { RDF.first.iri! }
    static var rest: IRI { RDF.rest.iri! }
    static let action: IRI = "http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#action"
    static let result: IRI = "http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#result"
    static let include: IRI = "http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#include"
    static let validate: ObjectTerm = .iri("http://www.w3.org/ns/shacl-test#Validate")
    static let dataGraph: IRI = "http://www.w3.org/ns/shacl-test#dataGraph"
    static let shapesGraph: IRI = "http://www.w3.org/ns/shacl-test#shapesGraph"
    static let evalNodeExpr: ObjectTerm = .iri("http://www.w3.org/ns/shacl-test#EvalNodeExpr")
    static let nodeExpr: IRI = "http://www.w3.org/ns/shacl-test#nodeExpr"
    static let focusNode: IRI = "http://www.w3.org/ns/shacl-test#focusNode"
    static let ignoreOrder: IRI = "http://www.w3.org/ns/shacl-test#ignoreOrder"
    static let scopePrefix = "http://www.w3.org/ns/shacl-test#scope-"
    static let rulesEvalTest: ObjectTerm = .iri("http://www.w3.org/ns/shacl-rules-test#RulesEvalTest")
    static let ruleset: IRI = "http://www.w3.org/ns/shacl-rules-test#ruleset"
    static let data: IRI = "http://www.w3.org/ns/shacl-rules-test#data"

    /// The file a manifest's IRI names, when it is a `file:` IRI.
    static func file(_ term: ObjectTerm) -> URL? {
        term.iri.flatMap { URL(string: $0.rawValue) }.flatMap { $0.isFileURL ? $0 : nil }
    }

    /// The subjects typed `type` in `graph`, in a stable order.
    static func entries(of type: ObjectTerm, in graph: Graph) -> [ObjectTerm] {
        graph.subjects(Self.type, type).sorted()
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
        W3CManifest.entries(of: W3CManifest.evalNodeExpr, in: graph).compactMap { entry in
            guard let action = graph.object(of: entry, W3CManifest.action),
                  let expression = graph.object(of: action, W3CManifest.nodeExpr),
                  let result = graph.object(of: entry, W3CManifest.result) else { return nil }
            var variables: [String: [ObjectTerm]] = [:]
            for triple in graph.triples(of: action) where triple.predicate.rawValue.hasPrefix(W3CManifest.scopePrefix) {
                variables[String(triple.predicate.rawValue.dropFirst(W3CManifest.scopePrefix.count)), default: []].append(triple.object)
            }
            return W3CNodeExprEvalCase(
                caseID: "\(manifest)#\(entry)",
                expression: expression,
                focusNode: graph.object(of: action, W3CManifest.focusNode),
                ignoreOrder: graph.object(of: action, W3CManifest.ignoreOrder)?.literal?.isTrue ?? false,
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
        for entry in W3CManifest.entries(of: W3CManifest.validate, in: graph) {
            guard let action = graph.object(of: entry, W3CManifest.action),
                  let dataFile = graph.object(of: action, W3CManifest.dataGraph).flatMap(W3CManifest.file),
                  let shapesFile = graph.object(of: action, W3CManifest.shapesGraph).flatMap(W3CManifest.file) else { continue }
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
