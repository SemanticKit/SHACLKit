import Foundation
import RDFKit
import SemanticKit
import Testing
@testable import SHACLKit

private let rdfTypeIRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
private let rdfFirstIRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#first"
private let rdfRestIRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#rest"
private let rdfNilIRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#nil"
private let mfActionIRI = "http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#action"
private let mfResultIRI = "http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#result"
private let shtEvalNodeExprIRI = "http://www.w3.org/ns/shacl-test#EvalNodeExpr"
private let shtNodeExprIRI = "http://www.w3.org/ns/shacl-test#nodeExpr"
private let shtFocusNodeIRI = "http://www.w3.org/ns/shacl-test#focusNode"
private let shtIgnoreOrderIRI = "http://www.w3.org/ns/shacl-test#ignoreOrder"
private let shtScopePrefixIRI = "http://www.w3.org/ns/shacl-test#scope-"

private func fixtureData(_ name: String) throws -> Data {
    let fileURL = URL(fileURLWithPath: #filePath)
    let fixturesURL = fileURL.deletingLastPathComponent().appendingPathComponent("Fixtures")
    return try Data(contentsOf: fixturesURL.appendingPathComponent(name))
}

private func fixtureExists(_ relativePath: String) -> Bool {
    let fileURL = URL(fileURLWithPath: #filePath)
    let fixturesURL = fileURL.deletingLastPathComponent().appendingPathComponent("Fixtures")
    return FileManager.default.fileExists(atPath: fixturesURL.appendingPathComponent(relativePath).path)
}

private func fixturesRootURL() -> URL {
    let fileURL = URL(fileURLWithPath: #filePath)
    return fileURL.deletingLastPathComponent().appendingPathComponent("Fixtures")
}

private struct W3CNodeExprEvalCase {
    let caseID: String
    let expressionTerm: String
    let focusNode: String?
    let ignoreOrder: Bool
    let variableBindings: [String: Set<String>]
    let expectedOrderedResults: [String]
}

private func isTrueBooleanLiteral(_ term: String) -> Bool {
    term == "\"true\"^^http://www.w3.org/2001/XMLSchema#boolean"
}

private func rdfListMembers(head: String, triples: [SHACLDataTriple]) -> [String] {
    if head == rdfNilIRI {
        return []
    }
    var members: [String] = []
    var current = head
    var visited: Set<String> = []
    while current != rdfNilIRI && !visited.contains(current) {
        visited.insert(current)
        guard let first = triples.first(where: { $0.subject == current && $0.predicate == rdfFirstIRI })?.object,
              let rest = triples.first(where: { $0.subject == current && $0.predicate == rdfRestIRI })?.object else {
            break
        }
        members.append(first)
        current = rest
    }
    return members
}

private func multisetCounts(_ values: [String]) -> [String: Int] {
    values.reduce(into: [:]) { partial, value in
        partial[value, default: 0] += 1
    }
}

private func loadW3CNodeExprEvalCases(from triples: [SHACLDataTriple], manifestID: String) -> [W3CNodeExprEvalCase] {
    let evalSubjects = triples
        .filter { $0.predicate == rdfTypeIRI && $0.object == shtEvalNodeExprIRI }
        .map(\.subject)
        .sorted()

    var cases: [W3CNodeExprEvalCase] = []
    for subject in evalSubjects {
        guard let actionNode = triples.first(where: { $0.subject == subject && $0.predicate == mfActionIRI })?.object,
              let expressionTerm = triples.first(where: { $0.subject == actionNode && $0.predicate == shtNodeExprIRI })?.object,
              let resultListHead = triples.first(where: { $0.subject == subject && $0.predicate == mfResultIRI })?.object else {
            continue
        }

        let focusNode = triples.first(where: { $0.subject == actionNode && $0.predicate == shtFocusNodeIRI })?.object
        let ignoreOrder = triples
            .first(where: { $0.subject == actionNode && $0.predicate == shtIgnoreOrderIRI })
            .map { isTrueBooleanLiteral($0.object) } ?? false
        let scopedTriples = triples.filter { $0.subject == actionNode && $0.predicate.hasPrefix(shtScopePrefixIRI) }
        let bindings = Dictionary(grouping: scopedTriples, by: { String($0.predicate.dropFirst(shtScopePrefixIRI.count)) })
            .mapValues { Set($0.map(\.object)) }
        let expectedResults = rdfListMembers(head: resultListHead, triples: triples)

        cases.append(
            W3CNodeExprEvalCase(
                caseID: "\(manifestID)#\(subject)",
                expressionTerm: expressionTerm,
                focusNode: focusNode,
                ignoreOrder: ignoreOrder,
                variableBindings: bindings,
                expectedOrderedResults: expectedResults
            )
        )
    }

    return cases
}

private struct W3CCuratedConformanceCase {
    let caseID: String
    let dataGraphRelativePath: String
    let shapesGraphRelativePath: String
    let expectedConforms: Bool
    let conformanceDisallowedSeverities: Set<SHACLSeverity>?
}

private func resolvedW3CManifestGraphPaths(
    dataGraphRelativePath: String,
    shapesGraphRelativePath: String
) throws -> (data: String, shapes: String) {
    guard dataGraphRelativePath == shapesGraphRelativePath,
          dataGraphRelativePath.hasSuffix(".ttl") else {
        return (dataGraphRelativePath, shapesGraphRelativePath)
    }

    let wrapperRelativePath = "W3CDataShapes/\(dataGraphRelativePath)"
    let wrapperPayload = try fixtureData(wrapperRelativePath)
    guard let wrapperText = String(data: wrapperPayload, encoding: .utf8) else {
        return (dataGraphRelativePath, shapesGraphRelativePath)
    }

    guard let dataMatch = firstRegexCapture(
        pattern: #"sht:dataGraph\s+<([^>]+)>"#,
        in: wrapperText
    ),
        let shapesMatch = firstRegexCapture(
            pattern: #"sht:shapesGraph\s+<([^>]+)>"#,
            in: wrapperText
        ) else {
        return (dataGraphRelativePath, shapesGraphRelativePath)
    }

    let baseDirectory = (dataGraphRelativePath as NSString).deletingLastPathComponent
    let dataResolved = baseDirectory.isEmpty ? dataMatch : "\(baseDirectory)/\(dataMatch)"
    let shapesResolved = baseDirectory.isEmpty ? shapesMatch : "\(baseDirectory)/\(shapesMatch)"
    return (dataResolved, shapesResolved)
}

private func firstRegexCapture(pattern: String, in text: String) -> String? {
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
        return nil
    }
    let range = NSRange(text.startIndex..<text.endIndex, in: text)
    guard let match = regex.firstMatch(in: text, options: [], range: range),
          let capture = Range(match.range(at: 1), in: text) else {
        return nil
    }
    return String(text[capture])
}

private func loadW3CCuratedConformanceCases() throws -> [W3CCuratedConformanceCase] {
    let manifestData = try fixtureData("W3CDataShapes/W3CCuratedConformanceManifest.tsv")
    guard let manifestText = String(data: manifestData, encoding: .utf8) else {
        throw NSError(
            domain: "SHACLKitTests",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Unable to decode curated W3C manifest as UTF-8."]
        )
    }

    var cases: [W3CCuratedConformanceCase] = []
    for rawLine in manifestText.split(whereSeparator: \.isNewline) {
        let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
        if line.isEmpty || line.hasPrefix("#") {
            continue
        }

        let fields = line.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
        guard fields.count >= 4 else {
            throw NSError(
                domain: "SHACLKitTests",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Invalid curated W3C manifest row: \(line)"]
            )
        }

        let expectedField = fields[3].lowercased()
        guard expectedField == "true" || expectedField == "false" else {
            throw NSError(
                domain: "SHACLKitTests",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "Invalid expected_conforms value in row: \(line)"]
            )
        }

        var conformanceDisallowedSeverities: Set<SHACLSeverity>? = nil
        if fields.count >= 6 {
            let severityField = fields[5]
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
            if !severityField.isEmpty {
                let mapped = severityField
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .compactMap { token -> SHACLSeverity? in
                        switch token {
                        case "violation":
                            return .violation
                        case "warning":
                            return .warning
                        case "info":
                            return .info
                        default:
                            return nil
                        }
                    }
                if mapped.count != severityField.split(separator: ",").count {
                    throw NSError(
                        domain: "SHACLKitTests",
                        code: 4,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid conformance severities in row: \(line)"]
                    )
                }
                conformanceDisallowedSeverities = Set(mapped)
            }
        }

        cases.append(
            W3CCuratedConformanceCase(
                caseID: fields[0],
                dataGraphRelativePath: fields[1],
                shapesGraphRelativePath: fields[2],
                expectedConforms: expectedField == "true",
                conformanceDisallowedSeverities: conformanceDisallowedSeverities
            )
        )
    }

    return cases
}

private func semanticGraph(fromTurtleData data: Data) throws -> Graph {
    guard let turtle = String(data: data, encoding: .utf8) else {
        throw SHACLError.invalidUTF8
    }
    let sanitizedTurtle = normalizedW3CTurtle(turtle)
        .replacingOccurrences(of: "\r\n", with: "\n")
        .replacingOccurrences(of: "<>", with: "<https://example.invalid/shaclkit/w3c-fixture-self>")
    let baseIRI = try IRI("https://example.invalid/shaclkit/w3c-fixture")
    return try Graph(turtle: sanitizedTurtle, baseIRI: baseIRI)
}

private func normalizedW3CTurtle(_ turtle: String) -> String {
    turtle
        .replacingOccurrences(of: "{|", with: ";")
        .replacingOccurrences(of: "|}", with: ";")
}

private func strippedW3CManifestStatements(from turtle: String) -> String {
    var outputLines: [String] = []
    var skippingManifestStatement = false

    for rawLine in turtle.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline) {
        let line = String(rawLine)
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        if !skippingManifestStatement
            && (trimmed.hasPrefix("<>")
                || (trimmed.hasPrefix("<") && !trimmed.hasPrefix("<http"))) {
            skippingManifestStatement = true
        }

        if !skippingManifestStatement {
            outputLines.append(line)
        }

        if skippingManifestStatement && trimmed == "." {
            skippingManifestStatement = false
        }
    }

    return outputLines.joined(separator: "\n")
}

private func cleanedGraphSectionData(fromTurtleData data: Data) throws -> Data {
    guard let turtle = String(data: data, encoding: .utf8) else {
        throw SHACLError.invalidUTF8
    }
    let usesReifierAnnotations = turtle.contains("sh:reifierShape") || turtle.contains("sh:reificationRequired")
    let normalizedSource = usesReifierAnnotations ? turtle : normalizedW3CTurtle(turtle)
    let normalized = normalizedSource.replacingOccurrences(of: "\r\n", with: "\n")
    let stripped = strippedW3CManifestStatements(from: normalized)
    return Data(
        stripped
            .replacingOccurrences(of: "<>", with: "<https://example.invalid/shaclkit/w3c-fixture-self>")
            .utf8
    )
}

@Test func shapesLoaderParsesNodeShapeTargets() async throws {
    let loader = SHACLShapesGraphLoader()
    let graph = try loader.load(from: fixtureData("basicTargets.ttl"))

    #expect(graph.shapes.count == 1)
    let shape = try #require(graph.shapes.first)
    #expect(shape.shapeIRI == "http://example.com/PersonShape")
    #expect(shape.kind == .nodeShape)

    let targets = Set(shape.targets)
    #expect(targets.contains(.targetClass("http://example.com/Person")))
    #expect(targets.contains(.targetNode("http://example.com/alice")))
    #expect(targets.contains(.targetSubjectsOf("http://example.com/knows")))
    #expect(targets.contains(.targetObjectsOf("http://example.com/memberOf")))
}

@Test func shapesLoaderParsesMultipleShapesAndObjectLists() async throws {
    let loader = SHACLShapesGraphLoader()
    let graph = try loader.load(from: fixtureData("multiTargets.ttl"))

    #expect(graph.shapes.count == 2)

    let byIRI = Dictionary(uniqueKeysWithValues: graph.shapes.map { ($0.shapeIRI, $0) })

    let thingShape = try #require(byIRI["http://example.com/ThingShape"])
    #expect(thingShape.kind == .nodeShape)
    let thingTargets = Set(thingShape.targets)
    #expect(thingTargets.contains(.targetClass("http://example.com/Person")))
    #expect(thingTargets.contains(.targetClass("http://example.com/Agent")))

    let propShape = try #require(byIRI["http://example.com/NamePropShape"])
    #expect(propShape.kind == .propertyShape)
    #expect(Set(propShape.targets).contains(.targetNode("http://example.com/alice")))
}

@Test func shapesLoaderParsesTargetNodeExpressionSelectors() async throws {
    let loader = SHACLShapesGraphLoader()
    let graph = try loader.load(from: fixtureData("targetNodeExpressionShapes.ttl"))
    let shape = try #require(graph.shapes.first(where: { $0.shapeIRI == "http://example.com/ExprTargetShape" }))
    #expect(Set(shape.targets).contains(.targetNodeExpression("_:expr")))
}

@Test func shapesLoaderParsesTargetWhereSelectors() async throws {
    let loader = SHACLShapesGraphLoader()
    let turtle = try fixtureData("W3CDataShapes/shacl12-test-suite/tests/core/targets/targetWhere-001.ttl")
    let graph = try loader.load(from: cleanedGraphSectionData(fromTurtleData: turtle))
    let shape = try #require(graph.shapes.first(where: { $0.shapeIRI == "http://example.com/ns#AdultShape" }))
    let hasTargetWhere = shape.targets.contains { selector in
        if case .targetWhere(let shapeIRI) = selector {
            return shapeIRI.hasPrefix("_:")
        }
        return false
    }
    #expect(hasTargetWhere)
}

@Test func shapesLoaderParsesNodeExpressionDefinitions() async throws {
    let loader = SHACLShapesGraphLoader()
    let graph = try loader.load(from: fixtureData("nodeExpressionDefinitions.ttl"))

    let byIRI = Dictionary(uniqueKeysWithValues: graph.nodeExpressions.map { ($0.expressionIRI, $0.kind) })
    #expect(byIRI.count >= 5)
    if case .union(let members)? = byIRI["http://example.com/ExprA"] {
        #expect(Set(members) == Set([
            "http://example.com/ConstA",
            "http://www.w3.org/ns/shacl#this",
        ]))
    } else {
        Issue.record("ExprA union definition was not parsed.")
    }
}

@Test func shapesLoaderParsesBooleanLiteralNodeExpressionMembers() async throws {
    let loader = SHACLShapesGraphLoader()
    let graph = try loader.load(from: fixtureData("nodeExpressionBooleanDefinitions.ttl"))
    let kind = try #require(
        graph.nodeExpressions
            .first(where: { $0.expressionIRI == "http://example.com/ExprBool" })?
            .kind
    )
    if case .union(let members) = kind {
        #expect(Set(members) == Set([
            "\"true\"^^http://www.w3.org/2001/XMLSchema#boolean",
            "\"false\"^^http://www.w3.org/2001/XMLSchema#boolean",
        ]))
    } else {
        Issue.record("Expected union node expression with boolean members.")
    }
}

@Test func shapesLoaderParsesTripleRules() async throws {
    let loader = SHACLShapesGraphLoader()
    let graph = try loader.load(from: fixtureData("ruleEvaluationShapes.ttl"))

    #expect(graph.tripleRules.count == 2)
    let byIRI = Dictionary(uniqueKeysWithValues: graph.tripleRules.map { ($0.ruleIRI, $0) })
    let promoteRule = try #require(byIRI["http://example.com/PromoteRule"])
    let issueBadgeRule = try #require(byIRI["http://example.com/IssueBadgeRule"])
    #expect(promoteRule.subjectTerm == "http://www.w3.org/ns/shacl#this")
    #expect(promoteRule.predicateTerm == "http://example.com/status")
    #expect(promoteRule.objectTerm == "\"active\"")
    #expect(promoteRule.conditionShapeIRIs == ["http://example.com/AdultConditionShape"])
    #expect(promoteRule.ruleOrder == 1)
    #expect(issueBadgeRule.ruleOrder == 2)
}

@Test func shapesLoaderParsesSPARQLDefinitions() async throws {
    let loader = SHACLShapesGraphLoader()
    let graph = try loader.load(from: fixtureData("sparqlConstraintShapes.ttl"))

    #expect(graph.sparqlDefinitions.count == 1)
    let definition = try #require(graph.sparqlDefinitions.first)
    #expect(definition.sparqlIRI == "http://example.com/NameConstraint")
    #expect(definition.selectQuery?.contains("SELECT ?this") == true)
}

@Test func w3cCuratedFixturePackIsSyncedIntoTestResources() async throws {
    #expect(fixtureExists("W3CDataShapes/SourceInventory.md"))
    #expect(fixtureExists("W3CDataShapes/data-shapes-test-suite/tests/manifest.ttl"))
    #expect(fixtureExists("W3CDataShapes/shacl12-test-suite/tests/manifest.ttl"))
    #expect(fixtureExists("W3CDataShapes/shacl12-test-suite/tests/rules/manifest-rules.ttl"))
}

@Test func w3cNodeExprShnexFixturesParseThroughSemanticAndLoaders() async throws {
    let shnexDirectoryURL = fixturesRootURL()
        .appendingPathComponent("W3CDataShapes")
        .appendingPathComponent("shacl12-test-suite/tests/node-expr/shnex")
    let fileURLs = try FileManager.default.contentsOfDirectory(
        at: shnexDirectoryURL,
        includingPropertiesForKeys: nil
    )
    let turtleFixtureURLs = fileURLs
        .filter { $0.pathExtension == "ttl" }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
    #expect(!turtleFixtureURLs.isEmpty)

    let shapesLoader = SHACLShapesGraphLoader()
    let dataLoader = SHACLDataGraphLoader()

    for turtleFixtureURL in turtleFixtureURLs {
        let fixturePayload = try Data(contentsOf: turtleFixtureURL)
        _ = try semanticGraph(fromTurtleData: fixturePayload)
        let dataGraph = try dataLoader.load(from: fixturePayload)
        _ = try shapesLoader.load(from: fixturePayload)
        #expect(!dataGraph.triples.isEmpty)
    }
}

@Test func w3cNodeExprShnexEvalSubsetMatchesManifestResults() async throws {
    let shnexDirectoryURL = fixturesRootURL()
        .appendingPathComponent("W3CDataShapes")
        .appendingPathComponent("shacl12-test-suite/tests/node-expr/shnex")
    let fileURLs = try FileManager.default.contentsOfDirectory(
        at: shnexDirectoryURL,
        includingPropertiesForKeys: nil
    )
    let turtleFixtureURLs = fileURLs
        .filter { $0.pathExtension == "ttl" }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }

    let supportedManifests = Set([
        "concat.ttl",
        "constant.ttl",
        "count.ttl",
        "distinct.ttl",
        "empty.ttl",
        "exists.ttl",
        "filterShape.ttl",
        "findFirst.ttl",
        "flatMap.ttl",
        "if.ttl",
        "instancesOf.ttl",
        "intersection.ttl",
        "limit.ttl",
        "list.ttl",
        "matchAll.ttl",
        "max.ttl",
        "min.ttl",
        "nodesMatching.ttl",
        "offset.ttl",
        "orderBy.ttl",
        "pathValues.ttl",
        "remove.ttl",
        "sum.ttl",
        "var.ttl",
    ])
    let selectedURLs = turtleFixtureURLs.filter { supportedManifests.contains($0.lastPathComponent) }
    #expect(!selectedURLs.isEmpty)

    let evaluator = SHACLNodeExpressionEvaluator()
    let shapesLoader = SHACLShapesGraphLoader()
    let dataLoader = SHACLDataGraphLoader()

    for turtleFixtureURL in selectedURLs {
        let fixturePayload = try Data(contentsOf: turtleFixtureURL)
        let shapesGraph = try shapesLoader.load(from: fixturePayload)
        let dataGraph = try dataLoader.load(from: fixturePayload)
        let evalCases = loadW3CNodeExprEvalCases(
            from: dataGraph.triples,
            manifestID: turtleFixtureURL.lastPathComponent
        )

        for evalCase in evalCases {
            let actual = evaluator.evaluateOrdered(
                expressionIRI: evalCase.expressionTerm,
                focusNode: evalCase.focusNode ?? "",
                shapesGraph: shapesGraph,
                dataGraph: dataGraph,
                variableBindings: evalCase.variableBindings
            )

            if evalCase.ignoreOrder {
                #expect(
                    multisetCounts(actual) == multisetCounts(evalCase.expectedOrderedResults),
                    "W3C node-expr case \(evalCase.caseID) multiset mismatch"
                )
            } else {
                #expect(
                    actual == evalCase.expectedOrderedResults,
                    "W3C node-expr case \(evalCase.caseID) ordered mismatch"
                )
            }
        }
    }
}

@Test func w3cCuratedConformanceSubsetMatchesExpectations() async throws {
    let conformanceCases = try loadW3CCuratedConformanceCases()
    #expect(!conformanceCases.isEmpty)

    for conformanceCase in conformanceCases {
        let validator = SHACLCoreValidator(
            conformanceDisallowedSeverities: conformanceCase.conformanceDisallowedSeverities
                ?? [.violation, .warning, .info]
        )
        let resolvedPaths = try resolvedW3CManifestGraphPaths(
            dataGraphRelativePath: conformanceCase.dataGraphRelativePath,
            shapesGraphRelativePath: conformanceCase.shapesGraphRelativePath
        )
        let dataGraphPayload = try fixtureData("W3CDataShapes/\(resolvedPaths.data)")
        let shapesGraphPayload = try fixtureData("W3CDataShapes/\(resolvedPaths.shapes)")

        let parsedDataGraph: SHACLDataGraph
        let parsedShapesGraph: SHACLShapesGraph
        do {
            _ = try? semanticGraph(fromTurtleData: dataGraphPayload)
            parsedDataGraph = try SHACLDataGraphLoader().load(
                from: cleanedGraphSectionData(fromTurtleData: dataGraphPayload)
            )
            _ = try? semanticGraph(fromTurtleData: shapesGraphPayload)
            parsedShapesGraph = try SHACLShapesGraphLoader().load(
                from: cleanedGraphSectionData(fromTurtleData: shapesGraphPayload)
            )
        } catch {
            Issue.record("W3C curated case \(conformanceCase.caseID) failed preflight parse/load: \(error)")
            continue
        }

        let result: SHACLValidationResult
        do {
            result = try validator.validate(dataGraph: parsedDataGraph, shapesGraph: parsedShapesGraph)
        } catch {
            Issue.record("W3C curated case \(conformanceCase.caseID) failed validation: \(error)")
            continue
        }

        if result.conforms != conformanceCase.expectedConforms {
            Issue.record(
                """
                W3C curated case \(conformanceCase.caseID) expectation mismatch: \
                expected conforms=\(conformanceCase.expectedConforms), got \(result.conforms).
                """
            )
        }
    }
}

@Test func nodeExpressionEvaluatorEvaluatesUnionIntersectionAndCycle() async throws {
    let loader = SHACLShapesGraphLoader()
    let graph = try loader.load(from: fixtureData("nodeExpressionDefinitions.ttl"))
    let evaluator = SHACLNodeExpressionEvaluator()
    let focus = "http://example.com/focus"

    let unionResult = evaluator.evaluate(
        expressionIRI: "http://example.com/ExprA",
        focusNode: focus,
        shapesGraph: graph
    )
    #expect(unionResult == Set(["http://example.com/ConstA", focus]))

    let intersectionResult = evaluator.evaluate(
        expressionIRI: "http://example.com/ExprInter",
        focusNode: focus,
        shapesGraph: graph
    )
    #expect(intersectionResult == Set([focus]))

    let nestedResult = evaluator.evaluate(
        expressionIRI: "http://example.com/ExprNested",
        focusNode: focus,
        shapesGraph: graph
    )
    #expect(nestedResult == Set([focus, "http://example.com/ConstC"]))

    let cycleResult = evaluator.evaluate(
        expressionIRI: "http://example.com/ExprCycle",
        focusNode: focus,
        shapesGraph: graph
    )
    #expect(cycleResult == Set(["http://example.com/ConstD"]))
}

@Test func nodeExpressionEvaluatorEvaluatesNodesAndExists() async throws {
    let loader = SHACLShapesGraphLoader()
    let graph = try loader.load(from: fixtureData("nodeExpressionExistsDefinitions.ttl"))
    let evaluator = SHACLNodeExpressionEvaluator()

    let nodesResult = evaluator.evaluate(
        expressionIRI: "http://example.com/ConstNodes",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(nodesResult == Set(["http://example.com/a", "42"]))

    let existsTrueResult = evaluator.evaluate(
        expressionIRI: "http://example.com/ExistsTrue",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(existsTrueResult == Set(["\"true\"^^http://www.w3.org/2001/XMLSchema#boolean"]))

    let existsFalseResult = evaluator.evaluate(
        expressionIRI: "http://example.com/ExistsFalse",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(existsFalseResult == Set(["\"false\"^^http://www.w3.org/2001/XMLSchema#boolean"]))

    let existsFalseAnonymousResult = evaluator.evaluate(
        expressionIRI: "http://example.com/ExistsFalseAnonymous",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(existsFalseAnonymousResult == Set(["\"false\"^^http://www.w3.org/2001/XMLSchema#boolean"]))
}

@Test func nodeExpressionEvaluatorEvaluatesIfThenElse() async throws {
    let loader = SHACLShapesGraphLoader()
    let graph = try loader.load(from: fixtureData("nodeExpressionIfDefinitions.ttl"))
    let evaluator = SHACLNodeExpressionEvaluator()

    let ifTrueResult = evaluator.evaluate(
        expressionIRI: "http://example.com/IfTrue",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(ifTrueResult == Set(["42"]))

    let ifFalseWithElseResult = evaluator.evaluate(
        expressionIRI: "http://example.com/IfFalseWithElse",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(ifFalseWithElseResult == Set(["\"no\""]))

    let ifFalseNoElseResult = evaluator.evaluate(
        expressionIRI: "http://example.com/IfFalseNoElse",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(ifFalseNoElseResult.isEmpty)

    let ifNestedResult = evaluator.evaluate(
        expressionIRI: "http://example.com/IfNested",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(ifNestedResult == Set(["http://example.com/thenResult"]))
}

@Test func nodeExpressionEvaluatorEvaluatesCount() async throws {
    let loader = SHACLShapesGraphLoader()
    let graph = try loader.load(from: fixtureData("nodeExpressionCountDefinitions.ttl"))
    let evaluator = SHACLNodeExpressionEvaluator()

    let countEmpty = evaluator.evaluate(
        expressionIRI: "http://example.com/CountEmpty",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(countEmpty == Set(["0"]))

    let countListThree = evaluator.evaluate(
        expressionIRI: "http://example.com/CountListThree",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(countListThree == Set(["3"]))

    let countNodesTwo = evaluator.evaluate(
        expressionIRI: "http://example.com/CountNodesTwo",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(countNodesTwo == Set(["2"]))
}

@Test func nodeExpressionEvaluatorEvaluatesDistinct() async throws {
    let loader = SHACLShapesGraphLoader()
    let graph = try loader.load(from: fixtureData("nodeExpressionDistinctDefinitions.ttl"))
    let evaluator = SHACLNodeExpressionEvaluator()

    let distinctList = evaluator.evaluate(
        expressionIRI: "http://example.com/DistinctList",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(distinctList == Set(["4", "2"]))

    let distinctTermEquality = evaluator.evaluate(
        expressionIRI: "http://example.com/DistinctTermEquality",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(distinctTermEquality == Set(["4", "2", "\"04\"^^http://www.w3.org/2001/XMLSchema#integer"]))

    let distinctNodes = evaluator.evaluate(
        expressionIRI: "http://example.com/DistinctNodes",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(distinctNodes == Set(["http://example.com/a", "http://example.com/b"]))
}

@Test func nodeExpressionEvaluatorEvaluatesVar() async throws {
    let loader = SHACLShapesGraphLoader()
    let graph = try loader.load(from: fixtureData("nodeExpressionVarDefinitions.ttl"))
    let evaluator = SHACLNodeExpressionEvaluator()

    let varFocusNode = evaluator.evaluate(
        expressionIRI: "http://example.com/VarFocusNode",
        focusNode: "http://example.com/Aldi",
        shapesGraph: graph
    )
    #expect(varFocusNode == Set(["http://example.com/Aldi"]))

    let varBound = evaluator.evaluate(
        expressionIRI: "http://example.com/VarBound",
        focusNode: "http://example.com/Aldi",
        shapesGraph: graph,
        variableBindings: ["bound": Set(["4.2"])]
    )
    #expect(varBound == Set(["4.2"]))

    let varUnbound = evaluator.evaluate(
        expressionIRI: "http://example.com/VarUnbound",
        focusNode: "http://example.com/Aldi",
        shapesGraph: graph
    )
    #expect(varUnbound.isEmpty)

    let distinctFocusNode = evaluator.evaluate(
        expressionIRI: "http://example.com/DistinctFocusNode",
        focusNode: "http://example.com/Aldi",
        shapesGraph: graph
    )
    #expect(distinctFocusNode == Set(["http://example.com/Aldi"]))
}

@Test func nodeExpressionEvaluatorEvaluatesInstancesOf() async throws {
    let loader = SHACLShapesGraphLoader()
    let dataLoader = SHACLDataGraphLoader()
    let graphData = try fixtureData("nodeExpressionInstancesOfDefinitions.ttl")
    let shapesGraph = try loader.load(from: graphData)
    let dataGraph = try dataLoader.load(from: graphData)
    let evaluator = SHACLNodeExpressionEvaluator()

    let organizations = evaluator.evaluate(
        expressionIRI: "http://example.com/OrganizationsExpr",
        focusNode: "http://example.com/focus",
        shapesGraph: shapesGraph,
        dataGraph: dataGraph
    )
    #expect(organizations == Set(["http://example.com/Org1", "http://example.com/Company1", "http://example.com/Company2"]))

    let companies = evaluator.evaluate(
        expressionIRI: "http://example.com/CompaniesExpr",
        focusNode: "http://example.com/focus",
        shapesGraph: shapesGraph,
        dataGraph: dataGraph
    )
    #expect(companies == Set(["http://example.com/Company1", "http://example.com/Company2"]))
}

@Test func nodeExpressionEvaluatorEvaluatesNodesMatching() async throws {
    let loader = SHACLShapesGraphLoader()
    let dataLoader = SHACLDataGraphLoader()
    let graphData = try fixtureData("nodeExpressionNodesMatchingDefinitions.ttl")
    let shapesGraph = try loader.load(from: graphData)
    let dataGraph = try dataLoader.load(from: graphData)
    let evaluator = SHACLNodeExpressionEvaluator()

    let organizations = evaluator.evaluate(
        expressionIRI: "http://example.com/OrganizationsMatchingExpr",
        focusNode: "http://example.com/focus",
        shapesGraph: shapesGraph,
        dataGraph: dataGraph
    )
    #expect(organizations == Set(["http://example.com/Org1", "http://example.com/Company1", "http://example.com/Company2"]))

    let companies = evaluator.evaluate(
        expressionIRI: "http://example.com/CompaniesMatchingExpr",
        focusNode: "http://example.com/focus",
        shapesGraph: shapesGraph,
        dataGraph: dataGraph
    )
    #expect(companies == Set(["http://example.com/Company1", "http://example.com/Company2"]))
}

@Test func nodeExpressionEvaluatorEvaluatesMatchAll() async throws {
    let loader = SHACLShapesGraphLoader()
    let dataLoader = SHACLDataGraphLoader()
    let graphData = try fixtureData("nodeExpressionMatchAllDefinitions.ttl")
    let shapesGraph = try loader.load(from: graphData)
    let dataGraph = try dataLoader.load(from: graphData)
    let evaluator = SHACLNodeExpressionEvaluator()

    let matchAllEmpty = evaluator.evaluate(
        expressionIRI: "http://example.com/MatchAllEmpty",
        focusNode: "http://example.com/focus",
        shapesGraph: shapesGraph,
        dataGraph: dataGraph
    )
    #expect(matchAllEmpty == Set(["\"true\"^^http://www.w3.org/2001/XMLSchema#boolean"]))

    let matchAllTrue = evaluator.evaluate(
        expressionIRI: "http://example.com/MatchAllTrue",
        focusNode: "http://example.com/focus",
        shapesGraph: shapesGraph,
        dataGraph: dataGraph
    )
    #expect(matchAllTrue == Set(["\"true\"^^http://www.w3.org/2001/XMLSchema#boolean"]))

    let matchAllFalse = evaluator.evaluate(
        expressionIRI: "http://example.com/MatchAllFalse",
        focusNode: "http://example.com/focus",
        shapesGraph: shapesGraph,
        dataGraph: dataGraph
    )
    #expect(matchAllFalse == Set(["\"false\"^^http://www.w3.org/2001/XMLSchema#boolean"]))
}

@Test func nodeExpressionEvaluatorEvaluatesFilterShape() async throws {
    let loader = SHACLShapesGraphLoader()
    let dataLoader = SHACLDataGraphLoader()
    let graphData = try fixtureData("nodeExpressionFilterShapeDefinitions.ttl")
    let shapesGraph = try loader.load(from: graphData)
    let dataGraph = try dataLoader.load(from: graphData)
    let evaluator = SHACLNodeExpressionEvaluator()

    let filteredPeople = evaluator.evaluate(
        expressionIRI: "http://example.com/FilterPeopleExpr",
        focusNode: "http://example.com/focus",
        shapesGraph: shapesGraph,
        dataGraph: dataGraph
    )
    #expect(filteredPeople == Set(["http://example.com/alice", "http://example.com/bob"]))

    let filterUnconstrained = evaluator.evaluate(
        expressionIRI: "http://example.com/FilterUnconstrainedExpr",
        focusNode: "http://example.com/focus",
        shapesGraph: shapesGraph,
        dataGraph: dataGraph
    )
    #expect(filterUnconstrained == Set(["http://example.com/alice", "http://example.com/bob", "http://example.com/charlie"]))
}

@Test func nodeExpressionEvaluatorEvaluatesConcatAndRemove() async throws {
    let loader = SHACLShapesGraphLoader()
    let dataLoader = SHACLDataGraphLoader()
    let graphData = try fixtureData("nodeExpressionConcatRemoveDefinitions.ttl")
    let shapesGraph = try loader.load(from: graphData)
    let dataGraph = try dataLoader.load(from: graphData)
    let evaluator = SHACLNodeExpressionEvaluator()

    let concatSimple = evaluator.evaluate(
        expressionIRI: "http://example.com/ConcatSimple",
        focusNode: "http://example.com/focus",
        shapesGraph: shapesGraph,
        dataGraph: dataGraph
    )
    #expect(concatSimple == Set(["http://example.com/alice", "http://example.com/bob", "\"false\"^^http://www.w3.org/2001/XMLSchema#boolean"]))

    let removeSimple = evaluator.evaluate(
        expressionIRI: "http://example.com/RemoveSimple",
        focusNode: "http://example.com/focus",
        shapesGraph: shapesGraph,
        dataGraph: dataGraph
    )
    #expect(removeSimple == Set(["http://example.com/alice", "http://example.com/charlie"]))

    let removeNested = evaluator.evaluate(
        expressionIRI: "http://example.com/RemoveNested",
        focusNode: "http://example.com/focus",
        shapesGraph: shapesGraph,
        dataGraph: dataGraph
    )
    #expect(removeNested == Set(["4", "2"]))
}

@Test func nodeExpressionEvaluatorEvaluatesFlatMap() async throws {
    let loader = SHACLShapesGraphLoader()
    let dataLoader = SHACLDataGraphLoader()
    let graphData = try fixtureData("nodeExpressionFlatMapDefinitions.ttl")
    let shapesGraph = try loader.load(from: graphData)
    let dataGraph = try dataLoader.load(from: graphData)
    let evaluator = SHACLNodeExpressionEvaluator()

    let identity = evaluator.evaluate(
        expressionIRI: "http://example.com/FlatMapIdentity",
        focusNode: "http://example.com/focus",
        shapesGraph: shapesGraph,
        dataGraph: dataGraph
    )
    #expect(identity == Set(["http://example.com/alice", "http://example.com/bob", "http://example.com/charlie"]))

    let allSkills = evaluator.evaluate(
        expressionIRI: "http://example.com/FlatMapSkills",
        focusNode: "http://example.com/focus",
        shapesGraph: shapesGraph,
        dataGraph: dataGraph
    )
    #expect(allSkills == Set(["\"Java\"@en", "\"Python\"@en", "\"SQL\"@en", "\"JavaScript\"@en", "\"DevOps\"@en"]))
}

@Test func nodeExpressionEvaluatorEvaluatesLimitAndOffset() async throws {
    let loader = SHACLShapesGraphLoader()
    let graph = try loader.load(from: fixtureData("nodeExpressionLimitOffsetDefinitions.ttl"))
    let evaluator = SHACLNodeExpressionEvaluator()

    let limit = evaluator.evaluate(
        expressionIRI: "http://example.com/LimitExpr",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(limit == Set(["1", "2"]))

    let offset = evaluator.evaluate(
        expressionIRI: "http://example.com/OffsetExpr",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(offset == Set(["3", "4"]))

    let offsetAfterLimit = evaluator.evaluate(
        expressionIRI: "http://example.com/OffsetAfterLimitExpr",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(offsetAfterLimit == Set(["6"]))

    let offsetThenLimitFromConcat = evaluator.evaluate(
        expressionIRI: "http://example.com/OffsetThenLimitFromConcatExpr",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(offsetThenLimitFromConcat == Set(["3"]))
}

@Test func nodeExpressionEvaluatorEvaluatesFindFirst() async throws {
    let loader = SHACLShapesGraphLoader()
    let dataLoader = SHACLDataGraphLoader()
    let graphData = try fixtureData("nodeExpressionFindFirstDefinitions.ttl")
    let shapesGraph = try loader.load(from: graphData)
    let dataGraph = try dataLoader.load(from: graphData)
    let evaluator = SHACLNodeExpressionEvaluator()

    let findFirstEmpty = evaluator.evaluate(
        expressionIRI: "http://example.com/FindFirstEmpty",
        focusNode: "http://example.com/focus",
        shapesGraph: shapesGraph,
        dataGraph: dataGraph
    )
    #expect(findFirstEmpty.isEmpty)

    let findFirstMinInclusive = evaluator.evaluate(
        expressionIRI: "http://example.com/FindFirstMinInclusive",
        focusNode: "http://example.com/focus",
        shapesGraph: shapesGraph,
        dataGraph: dataGraph
    )
    #expect(findFirstMinInclusive == Set(["4"]))
}

@Test func nodeExpressionEvaluatorEvaluatesOrderByAndDesc() async throws {
    let loader = SHACLShapesGraphLoader()
    let graph = try loader.load(from: fixtureData("nodeExpressionOrderByDefinitions.ttl"))
    let evaluator = SHACLNodeExpressionEvaluator()

    let orderByAsc = evaluator.evaluate(
        expressionIRI: "http://example.com/OrderByAscLimitExpr",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(orderByAsc == Set(["2"]))

    let orderByDesc = evaluator.evaluate(
        expressionIRI: "http://example.com/OrderByDescLimitExpr",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(orderByDesc == Set(["8"]))

    let orderByNumeric = evaluator.evaluate(
        expressionIRI: "http://example.com/OrderByNumericLimitExpr",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(orderByNumeric == Set(["2"]))
}

@Test func nodeExpressionEvaluatorEvaluatesOrderByPathValues() async throws {
    let loader = SHACLShapesGraphLoader()
    let dataLoader = SHACLDataGraphLoader()
    let graphData = try fixtureData("nodeExpressionOrderByPathDefinitions.ttl")
    let shapesGraph = try loader.load(from: graphData)
    let dataGraph = try dataLoader.load(from: graphData)
    let evaluator = SHACLNodeExpressionEvaluator()

    let earliestBirthday = evaluator.evaluate(
        expressionIRI: "http://example.com/OrderByBirthdayAscLimitExpr",
        focusNode: "http://example.com/focus",
        shapesGraph: shapesGraph,
        dataGraph: dataGraph
    )
    #expect(earliestBirthday == Set(["http://example.com/Person1"]))

    let latestBirthday = evaluator.evaluate(
        expressionIRI: "http://example.com/OrderByBirthdayDescLimitExpr",
        focusNode: "http://example.com/focus",
        shapesGraph: shapesGraph,
        dataGraph: dataGraph
    )
    #expect(latestBirthday == Set(["http://example.com/Person2"]))

    let missingHeightFirst = evaluator.evaluate(
        expressionIRI: "http://example.com/OrderByHeightAscLimitExpr",
        focusNode: "http://example.com/focus",
        shapesGraph: shapesGraph,
        dataGraph: dataGraph
    )
    #expect(missingHeightFirst == Set(["http://example.com/Person3"]))
}

@Test func nodeExpressionEvaluatorEvaluatesMinAndMax() async throws {
    let loader = SHACLShapesGraphLoader()
    let graph = try loader.load(from: fixtureData("nodeExpressionMinMaxDefinitions.ttl"))
    let evaluator = SHACLNodeExpressionEvaluator()

    let minEmpty = evaluator.evaluate(
        expressionIRI: "http://example.com/MinEmpty",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(minEmpty.isEmpty)

    let minList = evaluator.evaluate(
        expressionIRI: "http://example.com/MinList",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(minList == Set(["3"]))

    let maxEmpty = evaluator.evaluate(
        expressionIRI: "http://example.com/MaxEmpty",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(maxEmpty.isEmpty)

    let maxList = evaluator.evaluate(
        expressionIRI: "http://example.com/MaxList",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(maxList == Set(["5"]))

    let maxNodes = evaluator.evaluate(
        expressionIRI: "http://example.com/MaxNodes",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(maxNodes == Set(["9"]))
}

@Test func nodeExpressionEvaluatorEvaluatesSum() async throws {
    let loader = SHACLShapesGraphLoader()
    let graph = try loader.load(from: fixtureData("nodeExpressionSumDefinitions.ttl"))
    let evaluator = SHACLNodeExpressionEvaluator()

    let sumEmpty = evaluator.evaluate(
        expressionIRI: "http://example.com/SumEmpty",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(sumEmpty == Set(["0"]))

    let sumListIntegers = evaluator.evaluate(
        expressionIRI: "http://example.com/SumListIntegers",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(sumListIntegers == Set(["12"]))

    let sumListMixed = evaluator.evaluate(
        expressionIRI: "http://example.com/SumListMixed",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(sumListMixed == Set(["12.1"]))

    let sumNodes = evaluator.evaluate(
        expressionIRI: "http://example.com/SumNodes",
        focusNode: "http://example.com/focus",
        shapesGraph: graph
    )
    #expect(sumNodes == Set(["42.0"]))
}

@Test func coreValidatorConformsForExpressionDerivedPropertyValues() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodeExpressionConstraintValidShapes.ttl")
    let dataGraph = try fixtureData("nodeExpressionConstraintData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsExpressionDerivedPropertyViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodeExpressionConstraintInvalidShapes.ttl")
    let dataGraph = try fixtureData("nodeExpressionConstraintData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorConformsForPathValuesNodeExpression() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodeExpressionPathValuesValidShapes.ttl")
    let dataGraph = try fixtureData("nodeExpressionPathValuesData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsPathValuesNodeExpressionViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodeExpressionPathValuesInvalidShapes.ttl")
    let dataGraph = try fixtureData("nodeExpressionPathValuesData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorConformsForExistsExpressionConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintExistsShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintExistsValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsExistsExpressionConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintExistsShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintExistsInvalidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#expression")
}

@Test func coreValidatorConformsForIfExpressionConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintIfShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintIfValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsIfExpressionConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintIfShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintIfInvalidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#expression")
}

@Test func coreValidatorConformsForCountExpressionConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintCountShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintCountValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsCountExpressionConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintCountShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintCountInvalidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorConformsForDistinctExpressionConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintDistinctShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintDistinctValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsDistinctExpressionConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintDistinctShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintDistinctInvalidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorConformsForVarExpressionConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintVarShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintVarValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsVarExpressionConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintVarInvalidShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintVarValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorConformsForInstancesOfExpressionConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintInstancesOfShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintInstancesOfValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsInstancesOfExpressionConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintInstancesOfInvalidShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintInstancesOfValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorConformsForNodesMatchingExpressionConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapesLoader = SHACLShapesGraphLoader()
    let dataLoader = SHACLDataGraphLoader()
    let shapes = try fixtureData("expressionConstraintNodesMatchingShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintNodesMatchingValidData.ttl")

    let parsedShapes = try shapesLoader.load(from: shapes)
    let parsedData = try dataLoader.load(from: dataGraph)
    let expressionOutput = SHACLNodeExpressionEvaluator().evaluate(
        expressionIRI: "http://example.com/NodesMatchingExpr",
        focusNode: "http://example.com/scope",
        shapesGraph: parsedShapes,
        dataGraph: parsedData
    )
    #expect(expressionOutput.contains("http://example.com/alice"))

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsNodesMatchingExpressionConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintNodesMatchingInvalidShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintNodesMatchingValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorConformsForMatchAllExpressionConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintMatchAllShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintMatchAllValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsMatchAllExpressionConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintMatchAllShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintMatchAllInvalidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorConformsForFilterShapeExpressionConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintFilterShapeShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintFilterShapeValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsFilterShapeExpressionConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintFilterShapeShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintFilterShapeInvalidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorConformsForRemoveExpressionConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintRemoveShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintRemoveValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsRemoveExpressionConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintRemoveShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintRemoveInvalidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorConformsForFlatMapExpressionConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintFlatMapShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintFlatMapValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsFlatMapExpressionConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintFlatMapShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintFlatMapInvalidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorConformsForLimitExpressionConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintLimitShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintLimitValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsLimitExpressionConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintLimitShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintLimitInvalidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorConformsForFindFirstExpressionConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintFindFirstShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintFindFirstValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsFindFirstExpressionConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintFindFirstShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintFindFirstInvalidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorConformsForOrderByExpressionConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintOrderByShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintOrderByValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsOrderByExpressionConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintOrderByShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintOrderByInvalidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorConformsForMaxExpressionConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintMaxShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintMaxValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsMaxExpressionConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintMaxShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintMaxInvalidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorConformsForSumExpressionConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintSumShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintSumValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsSumExpressionConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintSumShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintSumInvalidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorConformsForPropertyExpressionConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintPathValidShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintPathData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsPropertyExpressionConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintPathInvalidShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintPathData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 2)
    #expect(result.violations.allSatisfy { $0.sourceConstraintIRI == "http://www.w3.org/ns/shacl#expression" })
}

@Test func coreValidatorConformsForNodeExpressionConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintNodeValidShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintNodeData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsNodeExpressionConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("expressionConstraintNodeInvalidShapes.ttl")
    let dataGraph = try fixtureData("expressionConstraintNodeData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 2)
    #expect(result.violations.allSatisfy { $0.sourceConstraintIRI == "http://www.w3.org/ns/shacl#expression" })
}

@Test func coreValidatorConformsForNodeByExpressionNodeConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodeByExpressionNodeShapes.ttl")
    let dataGraph = try fixtureData("nodeByExpressionNodeValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsNodeByExpressionNodeConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodeByExpressionNodeShapes.ttl")
    let dataGraph = try fixtureData("nodeByExpressionNodeInvalidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://example.com/AdultShape")
}

@Test func coreValidatorConformsForNodeByExpressionPropertyConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodeByExpressionPropertyShapes.ttl")
    let dataGraph = try fixtureData("nodeByExpressionPropertyValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsNodeByExpressionPropertyConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodeByExpressionPropertyShapes.ttl")
    let dataGraph = try fixtureData("nodeByExpressionPropertyInvalidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://example.com/NamedNodeShape")
}

@Test func coreValidatorResolvesTargetWhereFocusNodes() async throws {
    let validator = SHACLCoreValidator()
    let turtle = try fixtureData("W3CDataShapes/shacl12-test-suite/tests/core/targets/targetWhere-001.ttl")
    let fixturePayload = try cleanedGraphSectionData(fromTurtleData: turtle)

    let result = try validator.validate(dataGraph: fixturePayload, shapesGraph: fixturePayload)
    #expect(!result.conforms)
    #expect(result.violations.contains { $0.focusNode == "http://example.com/ns#InvalidResource1" })
    #expect(!result.violations.contains { $0.focusNode == "http://example.com/ns#InvalidResource2" })
}

@Test func coreValidatorResolvesShapeClassImplicitTargets() async throws {
    let validator = SHACLCoreValidator()
    let turtle = try fixtureData("W3CDataShapes/shacl12-test-suite/tests/core/targets/targetClassImplicit-002.ttl")
    let fixturePayload = try cleanedGraphSectionData(fromTurtleData: turtle)

    let result = try validator.validate(dataGraph: fixturePayload, shapesGraph: fixturePayload)
    #expect(!result.conforms)
    #expect(result.violations.contains { $0.focusNode == "http://example.com/ns#InvalidInstance" })
}

@Test func coreValidatorResolvesShapeSelectorTargets() async throws {
    let validator = SHACLCoreValidator()
    let shapesTurtle = try fixtureData("W3CDataShapes/shacl12-test-suite/tests/core/targets/shape-001.ttl")
    let dataTurtle = try fixtureData("W3CDataShapes/shacl12-test-suite/tests/core/targets/shape-001-data.ttl")

    let shapesPayload = try cleanedGraphSectionData(fromTurtleData: shapesTurtle)
    let dataPayload = try cleanedGraphSectionData(fromTurtleData: dataTurtle)
    let result = try validator.validate(dataGraph: dataPayload, shapesGraph: shapesPayload)

    #expect(!result.conforms)
    #expect(result.violations.contains { $0.focusNode == "http://example.com/ns#InvalidResource1" })
    #expect(!result.violations.contains { $0.focusNode == "http://example.com/ns#ValidResource1" })
}

@Test func focusNodeResolverResolvesSelectorsAgainstDataGraph() async throws {
    let shapesLoader = SHACLShapesGraphLoader()
    let dataLoader = SHACLDataGraphLoader()
    let resolver = SHACLFocusNodeResolver()

    let shapes = try shapesLoader.load(from: fixtureData("basicTargets.ttl"))
    let dataGraph = try dataLoader.load(from: fixtureData("dataGraph.ttl"))
    let resolutions = resolver.resolve(dataGraph: dataGraph, shapesGraph: shapes)

    #expect(resolutions.count == 1)
    let resolution = try #require(resolutions.first)
    #expect(resolution.shapeIRI == "http://example.com/PersonShape")
    #expect(resolution.focusNodes == [
        "http://example.com/alice",
        "http://example.com/carol",
        "http://example.com/org1",
    ])
}

@Test func focusNodeResolverSupportsMultipleShapes() async throws {
    let shapesLoader = SHACLShapesGraphLoader()
    let dataLoader = SHACLDataGraphLoader()
    let resolver = SHACLFocusNodeResolver()

    let shapes = try shapesLoader.load(from: fixtureData("multiTargets.ttl"))
    let dataGraph = try dataLoader.load(from: fixtureData("dataGraph.ttl"))
    let resolutions = resolver.resolve(dataGraph: dataGraph, shapesGraph: shapes)

    #expect(resolutions.count == 2)

    let byShape = Dictionary(uniqueKeysWithValues: resolutions.map { ($0.shapeIRI, $0.focusNodes) })
    #expect(byShape["http://example.com/ThingShape"] == [
        "http://example.com/alice",
        "http://example.com/bob",
    ])
    #expect(byShape["http://example.com/NamePropShape"] == [
        "http://example.com/alice",
    ])
}

@Test func focusNodeResolverResolvesTargetNodeExpressions() async throws {
    let shapesLoader = SHACLShapesGraphLoader()
    let dataLoader = SHACLDataGraphLoader()
    let resolver = SHACLFocusNodeResolver()

    let shapes = try shapesLoader.load(from: fixtureData("targetNodeExpressionShapes.ttl"))
    let dataGraph = try dataLoader.load(from: fixtureData("dataGraph.ttl"))
    let resolutions = resolver.resolve(dataGraph: dataGraph, shapesGraph: shapes)

    let resolution = try #require(resolutions.first(where: { $0.shapeIRI == "http://example.com/ExprTargetShape" }))
    #expect(resolution.focusNodes == [
        "http://example.com/alice",
        "http://example.com/bob",
    ])
}

@Test func focusNodeResolverResolvesPathValuesTargetNodeExpression() async throws {
    let shapesLoader = SHACLShapesGraphLoader()
    let dataLoader = SHACLDataGraphLoader()
    let resolver = SHACLFocusNodeResolver()

    let shapes = try shapesLoader.load(from: fixtureData("targetNodeExpressionPathValuesShapes.ttl"))
    let dataGraph = try dataLoader.load(from: fixtureData("nodeExpressionPathValuesData.ttl"))
    let resolutions = resolver.resolve(dataGraph: dataGraph, shapesGraph: shapes)

    let resolution = try #require(resolutions.first(where: { $0.shapeIRI == "http://example.com/FriendShape" }))
    #expect(resolution.focusNodes == ["http://example.com/bob"])
}

@Test func focusNodeResolverResolvesNodesTargetNodeExpression() async throws {
    let shapesLoader = SHACLShapesGraphLoader()
    let dataLoader = SHACLDataGraphLoader()
    let resolver = SHACLFocusNodeResolver()

    let shapes = try shapesLoader.load(from: fixtureData("targetNodeExpressionNodesShapes.ttl"))
    let dataGraph = try dataLoader.load(from: fixtureData("dataGraph.ttl"))
    let resolutions = resolver.resolve(dataGraph: dataGraph, shapesGraph: shapes)

    let resolution = try #require(resolutions.first(where: { $0.shapeIRI == "http://example.com/NodesTargetShape" }))
    #expect(resolution.focusNodes == [
        "http://example.com/alice",
        "http://example.com/bob",
    ])
}

@Test func focusNodeResolverIgnoresEmptyTargetNodeExpressionOutputs() async throws {
    let shapesLoader = SHACLShapesGraphLoader()
    let dataLoader = SHACLDataGraphLoader()
    let resolver = SHACLFocusNodeResolver()

    let shapes = try shapesLoader.load(from: fixtureData("targetNodeExpressionWithThisShapes.ttl"))
    let dataGraph = try dataLoader.load(from: fixtureData("dataGraph.ttl"))
    let resolutions = resolver.resolve(dataGraph: dataGraph, shapesGraph: shapes)

    let resolution = try #require(resolutions.first(where: { $0.shapeIRI == "http://example.com/ExprTargetWithThisShape" }))
    #expect(resolution.focusNodes == [
        "http://example.com/alice",
    ])
}

@Test func focusNodeResolverIgnoresEmptyNodesTargetNodeExpressionOutputs() async throws {
    let shapesLoader = SHACLShapesGraphLoader()
    let dataLoader = SHACLDataGraphLoader()
    let resolver = SHACLFocusNodeResolver()

    let shapes = try shapesLoader.load(from: fixtureData("targetNodeExpressionEmptyNodesShapes.ttl"))
    let dataGraph = try dataLoader.load(from: fixtureData("dataGraph.ttl"))
    let resolutions = resolver.resolve(dataGraph: dataGraph, shapesGraph: shapes)

    let resolution = try #require(resolutions.first(where: { $0.shapeIRI == "http://example.com/EmptyNodesTargetShape" }))
    #expect(resolution.focusNodes.isEmpty)
}

@Test func coreValidatorConformsForMinMaxCountFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("countConstraintsShapes.ttl")
    let dataGraph = try fixtureData("countConstraintsValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsDeterministicCountViolations() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("countConstraintsShapes.ttl")
    let dataGraph = try fixtureData("countConstraintsInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)

    #expect(!result.conforms)
    #expect(result.violations.count == 2)

    let summary = result.violations.map { ($0.focusNode, $0.message) }
    #expect(summary[0].0 == "http://example.com/alice")
    #expect(summary[0].1.contains("minCount violation"))
    #expect(summary[1].0 == "http://example.com/bob")
    #expect(summary[1].1.contains("maxCount violation"))
}

@Test func coreValidatorConformsForClassConstraintFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("classConstraintsShapes.ttl")
    let dataGraph = try fixtureData("classConstraintsValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorConformsForNodeShapeLevelConstraints() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodeShapeConstraintsShapes.ttl")
    let dataGraph = try fixtureData("nodeShapeConstraintsValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsNodeShapeLevelClassViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodeShapeConstraintsShapes.ttl")
    let dataGraph = try fixtureData("nodeShapeConstraintsInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.shapeIRI == "http://example.com/EmployeeNodeShape")
    #expect(violation.pathIRI == nil)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#class")
}

@Test func coreValidatorNodeShapeValidationMatrixSubset() async throws {
    let validator = SHACLCoreValidator()
    let scenarios: [(String, String, Bool)] = [
        ("nodeShapeConstraintsShapes.ttl", "nodeShapeConstraintsValid.ttl", true),
        ("nodeShapeConstraintsShapes.ttl", "nodeShapeConstraintsInvalid.ttl", false),
        ("severityWarningShapes.ttl", "severityWarningData.ttl", false),
    ]

    for scenario in scenarios {
        let shapes = try fixtureData(scenario.0)
        let dataGraph = try fixtureData(scenario.1)
        let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
        #expect(result.conforms == scenario.2)
    }
}

@Test func coreValidatorReportsClassConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("classConstraintsShapes.ttl")
    let dataGraph = try fixtureData("classConstraintsInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)

    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.message.contains("class violation"))
    #expect(violation.message.contains("http://example.com/org1"))
}

@Test func coreValidatorConformsForNodeKindFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodeKindConstraintsShapes.ttl")
    let dataGraph = try fixtureData("nodeKindConstraintsValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsNodeKindViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodeKindConstraintsShapes.ttl")
    let dataGraph = try fixtureData("nodeKindConstraintsInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)

    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.message.contains("nodeKind violation"))
    #expect(violation.message.contains("iri"))
}

@Test func coreValidatorConformsForDatatypeFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("datatypeConstraintsShapes.ttl")
    let dataGraph = try fixtureData("datatypeConstraintsValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsDatatypeViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("datatypeConstraintsShapes.ttl")
    let dataGraph = try fixtureData("datatypeConstraintsInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)

    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.message.contains("datatype violation"))
    #expect(violation.message.contains("XMLSchema#integer"))
}

@Test func coreValidatorConformsForBroaderNodeKinds() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodeKindBroadShapes.ttl")
    let dataGraph = try fixtureData("nodeKindBroadValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsBroaderNodeKindViolations() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodeKindBroadShapes.ttl")
    let dataGraph = try fixtureData("nodeKindBroadInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)

    #expect(!result.conforms)
    #expect(result.violations.count == 2)
    let messages = result.violations.map(\.message).joined(separator: " | ")
    #expect(messages.contains("blankNode"))
    #expect(messages.contains("iriOrLiteral"))
}

@Test func coreValidatorConformsForExtendedNodeKinds() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodeKindExtendedShapes.ttl")
    let dataGraph = try fixtureData("nodeKindExtendedValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsExtendedNodeKindViolations() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodeKindExtendedShapes.ttl")
    let dataGraph = try fixtureData("nodeKindExtendedInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 2)
    let messages = result.violations.map(\.message).joined(separator: " | ")
    #expect(messages.contains("blankNodeOrIRI"))
    #expect(messages.contains("blankNodeOrLiteral"))
}

@Test func coreValidatorConformsForStringFacetFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("stringFacetsShapes.ttl")
    let dataGraph = try fixtureData("stringFacetsValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsStringFacetViolations() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("stringFacetsShapes.ttl")
    let dataGraph = try fixtureData("stringFacetsInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 2)
    let messages = result.violations.map(\.message).joined(separator: " | ")
    #expect(messages.contains("minLength violation"))
    #expect(messages.contains("pattern violation"))
}

@Test func coreValidatorConformsForSingleLineConstraintFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("singleLineConstraintsShapes.ttl")
    let dataGraph = try fixtureData("singleLineConstraintsValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsSingleLineConstraintViolations() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("singleLineConstraintsShapes.ttl")
    let dataGraph = try fixtureData("singleLineConstraintsInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#singleLine")
    #expect(violation.message.contains("singleLine violation"))
}

@Test func coreValidatorConformsForRangeFacetFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("rangeFacetsShapes.ttl")
    let dataGraph = try fixtureData("rangeFacetsValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsRangeFacetViolations() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("rangeFacetsShapes.ttl")
    let dataGraph = try fixtureData("rangeFacetsInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 2)
    let messages = result.violations.map(\.message).joined(separator: " | ")
    #expect(messages.contains("minInclusive violation"))
    #expect(messages.contains("maxInclusive violation"))
}

@Test func coreValidatorReportsRangeFacetNonNumericViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("rangeFacetsShapes.ttl")
    let dataGraph = try fixtureData("rangeFacetsNonNumeric.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#minInclusive")
    #expect(violation.message.contains("not an integer literal"))
}

@Test func coreValidatorConformsForHasValueFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("hasValueConstraintsShapes.ttl")
    let dataGraph = try fixtureData("hasValueConstraintsValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsHasValueViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("hasValueConstraintsShapes.ttl")
    let dataGraph = try fixtureData("hasValueConstraintsInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.message.contains("hasValue violation"))
    #expect(violation.message.contains("http://example.com/Active"))
}

@Test func coreValidatorConformsForInConstraintFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("inConstraintsShapes.ttl")
    let dataGraph = try fixtureData("inConstraintsValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsInConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("inConstraintsShapes.ttl")
    let dataGraph = try fixtureData("inConstraintsInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.message.contains("in violation"))
    #expect(violation.message.contains("http://example.com/Archived"))
}

@Test func coreValidatorConformsForInListConstraintFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("inListConstraintsShapes.ttl")
    let dataGraph = try fixtureData("inListConstraintsValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsInListConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("inListConstraintsShapes.ttl")
    let dataGraph = try fixtureData("inListConstraintsInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#in")
    #expect(violation.message.contains("in violation"))
}

@Test func coreValidatorConformsForNodeReferenceFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodeReferenceShapes.ttl")
    let dataGraph = try fixtureData("nodeReferenceValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsNodeReferenceViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodeReferenceShapes.ttl")
    let dataGraph = try fixtureData("nodeReferenceInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.shapeIRI == "http://example.com/EmployeeIdShape")
    #expect(violation.message.contains("minCount violation"))
}

@Test func coreValidatorConformsForQualifiedCountFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("qualifiedCountsShapes.ttl")
    let dataGraph = try fixtureData("qualifiedCountsValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsQualifiedMinCountViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("qualifiedCountsShapes.ttl")
    let dataGraph = try fixtureData("qualifiedCountsMinInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#qualifiedMinCount")
    #expect(violation.message.contains("qualifiedMinCount violation"))
}

@Test func coreValidatorReportsQualifiedMaxCountViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("qualifiedCountsShapes.ttl")
    let dataGraph = try fixtureData("qualifiedCountsMaxInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#qualifiedMaxCount")
    #expect(violation.message.contains("qualifiedMaxCount violation"))
}

@Test func coreValidatorSetsConformanceFalseForWarningOnlyResults() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("severityWarningShapes.ttl")
    let dataGraph = try fixtureData("severityWarningData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let warning = try #require(result.violations.first)
    #expect(warning.severity == .warning)
    #expect(warning.sourceConstraintIRI == "http://www.w3.org/ns/shacl#minCount")
}

@Test func coreValidatorPropagatesMixedSeverityAndDeterministicDiagnostics() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("severityMixedShapes.ttl")
    let dataGraph = try fixtureData("severityMixedData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 3)

    let ordered = result.violations.map { ($0.shapeIRI, $0.severity, $0.sourceConstraintIRI ?? "") }
    #expect(ordered[0].0 == "http://example.com/NameRequiredShape")
    #expect(ordered[0].1 == .violation)
    #expect(ordered[0].2 == "http://www.w3.org/ns/shacl#minCount")
    #expect(ordered[1].0 == "http://example.com/NickHintShape")
    #expect(ordered[1].1 == .info)
    #expect(ordered[1].2 == "http://www.w3.org/ns/shacl#minCount")
    #expect(ordered[2].0 == "http://example.com/StatusAllowedShape")
    #expect(ordered[2].1 == .warning)
    #expect(ordered[2].2 == "http://www.w3.org/ns/shacl#in")

    let inResult = result.violations[2]
    #expect(inResult.valueNode == "http://example.com/Archived")
}

@Test func coreValidatorTerminatesOnCyclicNodeReferences() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("cycleGuardShapes.ttl")
    let dataGraph = try fixtureData("cycleGuardData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 1)
}

@Test func coreValidatorReportsStableViolationForCycleGuardFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("cycleGuardShapes.ttl")
    let dataGraph = try fixtureData("cycleGuardData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    let violation = try #require(result.violations.first)
    #expect(violation.shapeIRI == "http://example.com/EmployeeIdShape")
    #expect(violation.focusNode == "http://example.com/bob")
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#minCount")
    #expect(violation.message.contains("minCount violation"))
}

@Test func coreValidatorConformsForLogicalOrFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("logicalOrShapes.ttl")
    let dataGraph = try fixtureData("logicalOrValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
}

@Test func coreValidatorReportsLogicalOrViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("logicalOrShapes.ttl")
    let dataGraph = try fixtureData("logicalOrInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#or")
    #expect(violation.message.contains("or violation"))
}

@Test func coreValidatorConformsForLogicalOrListFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("logicalListOrShapes.ttl")
    let dataGraph = try fixtureData("logicalListOrValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsLogicalOrListViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("logicalListOrShapes.ttl")
    let dataGraph = try fixtureData("logicalListOrInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#or")
}

@Test func coreValidatorConformsForLogicalAndFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("logicalAndShapes.ttl")
    let dataGraph = try fixtureData("logicalAndValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
}

@Test func coreValidatorReportsLogicalAndViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("logicalAndShapes.ttl")
    let dataGraph = try fixtureData("logicalAndInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first { $0.sourceConstraintIRI == "http://www.w3.org/ns/shacl#and" })
    #expect(violation.message.contains("and violation"))
}

@Test func coreValidatorConformsForLogicalAndListFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("logicalListAndShapes.ttl")
    let dataGraph = try fixtureData("logicalListAndValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsLogicalAndListViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("logicalListAndShapes.ttl")
    let dataGraph = try fixtureData("logicalListAndInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#and")
}

@Test func coreValidatorConformsForLogicalNotFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("logicalNotShapes.ttl")
    let dataGraph = try fixtureData("logicalNotValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
}

@Test func coreValidatorReportsLogicalNotViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("logicalNotShapes.ttl")
    let dataGraph = try fixtureData("logicalNotInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#not")
    #expect(violation.message.contains("not violation"))
}

@Test func coreValidatorConformsForLogicalXoneFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("logicalXoneShapes.ttl")
    let dataGraph = try fixtureData("logicalXoneValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
}

@Test func coreValidatorReportsLogicalXoneViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("logicalXoneShapes.ttl")
    let dataGraph = try fixtureData("logicalXoneInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#xone")
    #expect(violation.message.contains("xone violation"))
}

@Test func coreValidatorConformsForLogicalXoneListFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("logicalListXoneShapes.ttl")
    let dataGraph = try fixtureData("logicalListXoneValid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsLogicalXoneListViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("logicalListXoneShapes.ttl")
    let dataGraph = try fixtureData("logicalListXoneInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#xone")
}

@Test func coreValidatorPropertyShapeValidationMatrixSubset() async throws {
    let validator = SHACLCoreValidator()
    let scenarios: [(String, String, Bool)] = [
        ("countConstraintsShapes.ttl", "countConstraintsValid.ttl", true),
        ("countConstraintsShapes.ttl", "countConstraintsInvalid.ttl", false),
        ("classConstraintsShapes.ttl", "classConstraintsValid.ttl", true),
        ("classConstraintsShapes.ttl", "classConstraintsInvalid.ttl", false),
        ("datatypeConstraintsShapes.ttl", "datatypeConstraintsValid.ttl", true),
        ("datatypeConstraintsShapes.ttl", "datatypeConstraintsInvalid.ttl", false),
        ("stringFacetsShapes.ttl", "stringFacetsValid.ttl", true),
        ("stringFacetsShapes.ttl", "stringFacetsInvalid.ttl", false),
        ("rangeFacetsShapes.ttl", "rangeFacetsValid.ttl", true),
        ("rangeFacetsShapes.ttl", "rangeFacetsInvalid.ttl", false),
        ("hasValueConstraintsShapes.ttl", "hasValueConstraintsValid.ttl", true),
        ("hasValueConstraintsShapes.ttl", "hasValueConstraintsInvalid.ttl", false),
        ("inListConstraintsShapes.ttl", "inListConstraintsValid.ttl", true),
        ("inListConstraintsShapes.ttl", "inListConstraintsInvalid.ttl", false),
        ("logicalListOrShapes.ttl", "logicalListOrValid.ttl", true),
        ("logicalListOrShapes.ttl", "logicalListOrInvalid.ttl", false),
    ]

    for scenario in scenarios {
        let shapes = try fixtureData(scenario.0)
        let dataGraph = try fixtureData(scenario.1)
        let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
        #expect(result.conforms == scenario.2)
    }
}

private struct TestDataSource {
    let payload: Data
}

private struct TestShapesSource {
    let payload: Data
}

@Test func coreValidatorSupportsAdapterBoundaryEntryPoint() async throws {
    let validator = SHACLCoreValidator()
    let dataSource = TestDataSource(payload: try fixtureData("inListConstraintsValid.ttl"))
    let shapesSource = TestShapesSource(payload: try fixtureData("inListConstraintsShapes.ttl"))

    let dataAdapter = AnySHACLDataGraphAdapter<TestDataSource> { source in
        try SHACLDataGraphLoader().load(from: source.payload)
    }
    let shapesAdapter = AnySHACLShapesGraphAdapter<TestShapesSource> { source in
        try SHACLShapesGraphLoader().load(from: source.payload)
    }

    let result = try validator.validate(
        dataSource: dataSource,
        shapesSource: shapesSource,
        dataAdapter: dataAdapter,
        shapesAdapter: shapesAdapter
    )

    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorEmitsCompleteMachineReadableDiagnostics() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("logicalOrShapes.ttl")
    let dataGraph = try fixtureData("logicalOrInvalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    let violation = try #require(result.violations.first)
    #expect(violation.shapeIRI == "http://example.com/RoleShape")
    #expect(violation.focusNode == "http://example.com/alice")
    #expect(violation.pathIRI == "http://example.com/role")
    #expect(violation.valueNode == "http://example.com/r1")
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#or")
}

@Test func coreValidatorIsDeterministicAcrossRepeatedRuns() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("logicalAndShapes.ttl")
    let dataGraph = try fixtureData("logicalAndInvalid.ttl")

    let first = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    let second = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(first == second)
}

@Test func coreValidatorThrowsForPropertyShapeMissingPath() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("invalidShapesMissingPath.ttl")
    let dataGraph = try fixtureData("invalidShapesData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorThrowsForMissingReferencedPropertyShape() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("invalidShapesUnknownProperty.ttl")
    let dataGraph = try fixtureData("invalidShapesData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorThrowsForMissingReferencedNodeShape() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("invalidShapesUnknownNodeShape.ttl")
    let dataGraph = try fixtureData("invalidShapesData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorThrowsForMissingReferencedNodeShapeOnNodeShape() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("invalidShapesUnknownNodeReferenceOnNodeShape.ttl")
    let dataGraph = try fixtureData("invalidShapesData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorThrowsForMissingReferencedNodeExpression() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("invalidShapesUnknownExpression.ttl")
    let dataGraph = try fixtureData("invalidShapesData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorThrowsForMissingReferencedNodeExpressionOnNodeShape() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("invalidShapesUnknownNodeExpression.ttl")
    let dataGraph = try fixtureData("invalidShapesData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorThrowsForMissingReferencedNodeByExpressionOnNodeShape() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("invalidShapesUnknownNodeByExpressionNode.ttl")
    let dataGraph = try fixtureData("invalidShapesData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorThrowsForMissingReferencedNodeByExpressionOnPropertyShape() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("invalidShapesUnknownNodeByExpressionProperty.ttl")
    let dataGraph = try fixtureData("invalidShapesData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorThrowsForMissingReferencedRule() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("phaseGatedRulesShapes.ttl")
    let dataGraph = try fixtureData("invalidShapesData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorThrowsForPropertyShapeSPARQLTargetMissingSelect() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("invalidPropertySparqlTargetShapes.ttl")
    let dataGraph = try fixtureData("invalidShapesData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorThrowsForTargetNodeSPARQLTargetMissingSelect() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("invalidTargetNodeSparqlAskOnlyShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorConformsForRuleEvaluationFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("ruleEvaluationShapes.ttl")
    let dataGraph = try fixtureData("ruleEvaluationData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorRuleEvaluationIsDeterministicAcrossRuns() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("ruleEvaluationShapes.ttl")
    let dataGraph = try fixtureData("ruleEvaluationData.ttl")

    let first = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    let second = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(first == second)
}

@Test func coreValidatorRuleEvaluationTerminatesForSelfLoopingRule() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("ruleTerminationShapes.ttl")
    let dataGraph = try fixtureData("ruleTerminationData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorRuleEvaluationRequiresAllConditions() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("ruleMultiConditionShapes.ttl")
    let dataGraph = try fixtureData("ruleMultiConditionValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorRuleEvaluationSkipsWhenConditionMissing() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("ruleMultiConditionShapes.ttl")
    let dataGraph = try fixtureData("ruleMultiConditionInvalidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorRuleEvaluationSupportsPropertyShapeCondition() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("rulePropertyConditionShapes.ttl")
    let dataGraph = try fixtureData("rulePropertyConditionValidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorRuleEvaluationSkipsPropertyShapeConditionWhenNotSatisfied() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("rulePropertyConditionShapes.ttl")
    let dataGraph = try fixtureData("rulePropertyConditionInvalidData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorThrowsWithoutSandboxedSPARQLExecutor() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("sparqlConstraintShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorThrowsWithoutSandboxedSPARQLExecutorForAskConstraint() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("sparqlAskConstraintShapes.ttl")
    let dataGraph = try fixtureData("sparqlAskData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorExecutesSPARQLSelectConstraintThroughExecutorBoundary() async throws {
    let executor = TestSPARQLExecutor(
        selectResults: [
            "SELECT ?this WHERE { ?this ex:name ?name . FILTER(strlen(str(?name)) = 0) }|http://example.com/alice": ["http://example.com/alice"],
            "SELECT ?this WHERE { ?this ex:name ?name . FILTER(strlen(str(?name)) = 0) }|http://example.com/bob": [],
        ]
    )
    let validator = SHACLCoreValidator(sparqlExecutor: executor)
    let shapes = try fixtureData("sparqlConstraintShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.focusNode == "http://example.com/alice")
    #expect(violation.sourceConstraintIRI == "http://example.com/NameConstraint")
}

@Test func coreValidatorAcceptsSPARQLConstraintWithPrefixesDeclaration() async throws {
    let executor = TestSPARQLExecutor(
        selectResults: [
            "SELECT ?this WHERE { ?this ex:name ?name . FILTER(strlen(str(?name)) = 0) }|http://example.com/alice": ["http://example.com/alice"],
            "SELECT ?this WHERE { ?this ex:name ?name . FILTER(strlen(str(?name)) = 0) }|http://example.com/bob": [],
        ]
    )
    let validator = SHACLCoreValidator(sparqlExecutor: executor)
    let shapes = try fixtureData("sparqlConstraintWithPrefixesShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 1)
}

@Test func coreValidatorUsesSPARQLMessageForNodeShapeConstraintViolation() async throws {
    let executor = TestSPARQLExecutor(
        selectResults: [
            "SELECT ?this WHERE { ?this ex:name ?name . FILTER(strlen(str(?name)) = 0) }|http://example.com/alice": ["http://example.com/alice"],
            "SELECT ?this WHERE { ?this ex:name ?name . FILTER(strlen(str(?name)) = 0) }|http://example.com/bob": [],
        ]
    )
    let validator = SHACLCoreValidator(sparqlExecutor: executor)
    let shapes = try fixtureData("sparqlConstraintMessageShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.message == "Name must not be empty")
}

@Test func coreValidatorExecutesSPARQLAskConstraintThroughExecutorBoundary() async throws {
    let executor = TestSPARQLExecutor(
        askResults: [
            "ASK WHERE { ?this ex:active true }|http://example.com/alice": true,
            "ASK WHERE { ?this ex:active true }|http://example.com/bob": false,
        ]
    )
    let validator = SHACLCoreValidator(sparqlExecutor: executor)
    let shapes = try fixtureData("sparqlAskConstraintShapes.ttl")
    let dataGraph = try fixtureData("sparqlAskData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.focusNode == "http://example.com/bob")
    #expect(violation.sourceConstraintIRI == "http://example.com/ActiveConstraint")
}

@Test func coreValidatorExecutesSPARQLTargetThroughExecutorBoundary() async throws {
    let executor = TestSPARQLExecutor(
        selectResults: [
            "SELECT ?this WHERE { ?this ex:segment ex:vip }|": ["http://example.com/alice"],
        ]
    )
    let validator = SHACLCoreValidator(sparqlExecutor: executor)
    let shapes = try fixtureData("sparqlTargetShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.focusNode == "http://example.com/alice")
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorExecutesTargetNodeSelectThroughExecutorBoundary() async throws {
    let executor = TestSPARQLExecutor(
        selectResults: [
            "SELECT ?this WHERE { ?this ex:segment ex:vip }|": ["http://example.com/alice"],
        ]
    )
    let validator = SHACLCoreValidator(sparqlExecutor: executor)
    let shapes = try fixtureData("sparqlTargetNodeSelectShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.shapeIRI == "http://example.com/StatusShape")
    #expect(violation.focusNode == "http://example.com/alice")
    #expect(violation.pathIRI == "http://example.com/status")
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorExecutesPropertyShapeSPARQLConstraintThroughExecutorBoundary() async throws {
    let executor = TestSPARQLExecutor(
        selectResults: [
            "SELECT ?this WHERE { FILTER(strlen(str(?this)) = 0) }|\"\"": ["\"\""],
            "SELECT ?this WHERE { FILTER(strlen(str(?this)) = 0) }|\"Bob\"": [],
        ]
    )
    let validator = SHACLCoreValidator(sparqlExecutor: executor)
    let shapes = try fixtureData("sparqlPropertyConstraintShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.shapeIRI == "http://example.com/NamePropertyShape")
    #expect(violation.focusNode == "http://example.com/alice")
    #expect(violation.pathIRI == "http://example.com/name")
    #expect(violation.sourceConstraintIRI == "http://example.com/NonEmptyNameConstraint")
}

@Test func coreValidatorUsesSPARQLMessageForPropertyShapeConstraintViolation() async throws {
    let executor = TestSPARQLExecutor(
        selectResults: [
            "SELECT ?this WHERE { FILTER(strlen(str(?this)) = 0) }|\"\"": ["\"\""],
            "SELECT ?this WHERE { FILTER(strlen(str(?this)) = 0) }|\"Bob\"": [],
        ]
    )
    let validator = SHACLCoreValidator(sparqlExecutor: executor)
    let shapes = try fixtureData("sparqlPropertyConstraintMessageShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.message == "Property name must not be empty")
}

@Test func coreValidatorExecutesDirectPropertyShapeSPARQLConstraintThroughExecutorBoundary() async throws {
    let executor = TestSPARQLExecutor(
        selectResults: [
            "SELECT ?this WHERE { FILTER(strlen(str(?this)) = 0) }|\"\"": ["\"\""],
            "SELECT ?this WHERE { FILTER(strlen(str(?this)) = 0) }|\"Bob\"": [],
        ]
    )
    let validator = SHACLCoreValidator(sparqlExecutor: executor)
    let shapes = try fixtureData("sparqlPropertyShapeDirectTargetShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.shapeIRI == "http://example.com/NamePropertyShape")
    #expect(violation.focusNode == "http://example.com/alice")
    #expect(violation.pathIRI == "http://example.com/name")
    #expect(violation.sourceConstraintIRI == "http://example.com/NonEmptyNameConstraint")
}

@Test func coreValidatorExecutesNestedPropertyShapeSPARQLConstraintThroughExecutorBoundary() async throws {
    let executor = TestSPARQLExecutor(
        selectResults: [
            "SELECT ?this WHERE { FILTER(strlen(str(?this)) = 0) }|\"\"": ["\"\""],
            "SELECT ?this WHERE { FILTER(strlen(str(?this)) = 0) }|\"94107\"": [],
        ]
    )
    let validator = SHACLCoreValidator(sparqlExecutor: executor)
    let shapes = try fixtureData("sparqlNestedPropertyConstraintShapes.ttl")
    let dataGraph = try fixtureData("sparqlNestedPropertyConstraintData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.shapeIRI == "http://example.com/ZipShape")
    #expect(violation.focusNode == "http://example.com/alice")
    #expect(violation.pathIRI == "http://example.com/zip")
    #expect(violation.sourceConstraintIRI == "http://example.com/ZipConstraint")
}

@Test func coreValidatorExecutesDirectPropertyShapeSPARQLTargetThroughExecutorBoundary() async throws {
    let executor = TestSPARQLExecutor(
        selectResults: [
            "SELECT ?this WHERE { ?this ex:segment ex:vip }|": ["http://example.com/alice"],
        ]
    )
    let validator = SHACLCoreValidator(sparqlExecutor: executor)
    let shapes = try fixtureData("sparqlPropertyShapeTargetShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.shapeIRI == "http://example.com/StatusPropertyShape")
    #expect(violation.focusNode == "http://example.com/alice")
    #expect(violation.pathIRI == "http://example.com/status")
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorExecutesPropertyShapeTargetNodeSelectThroughExecutorBoundary() async throws {
    let executor = TestSPARQLExecutor(
        selectResults: [
            "SELECT ?this WHERE { ?this ex:segment ex:vip }|": ["http://example.com/alice"],
        ]
    )
    let validator = SHACLCoreValidator(sparqlExecutor: executor)
    let shapes = try fixtureData("sparqlPropertyTargetNodeSelectShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.shapeIRI == "http://example.com/StatusPropertyShape")
    #expect(violation.focusNode == "http://example.com/alice")
    #expect(violation.pathIRI == "http://example.com/status")
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#hasValue")
}

@Test func coreValidatorSkipsSPARQLConstraintsForDeactivatedNodeShape() async throws {
    let executor = TestSPARQLExecutor(
        selectResults: [
            "SELECT ?this WHERE { ?this ex:name ?name . FILTER(strlen(str(?name)) = 0) }|http://example.com/alice": ["http://example.com/alice"],
            "SELECT ?this WHERE { ?this ex:name ?name . FILTER(strlen(str(?name)) = 0) }|http://example.com/bob": [],
        ]
    )
    let validator = SHACLCoreValidator(sparqlExecutor: executor)
    let shapes = try fixtureData("sparqlDeactivatedNodeShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorSkipsSPARQLConstraintsForDeactivatedPropertyShape() async throws {
    let executor = TestSPARQLExecutor(
        selectResults: [
            "SELECT ?this WHERE { FILTER(strlen(str(?this)) = 0) }|\"\"": ["\"\""],
            "SELECT ?this WHERE { FILTER(strlen(str(?this)) = 0) }|\"Bob\"": [],
        ]
    )
    let validator = SHACLCoreValidator(sparqlExecutor: executor)
    let shapes = try fixtureData("sparqlDeactivatedPropertyShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorBlocksGuardedSPARQLConstraintByKeywordPolicy() async throws {
    let guardedExecutor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
    let validator = SHACLCoreValidator(sparqlExecutor: guardedExecutor)
    let shapes = try fixtureData("sparqlGuardBlockedShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorBlocksGuardedSPARQLConstraintByMinusKeywordPolicy() async throws {
    let guardedExecutor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
    let validator = SHACLCoreValidator(sparqlExecutor: guardedExecutor)
    let shapes = try fixtureData("sparqlGuardBlockedMinusShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorBlocksGuardedSPARQLConstraintByValuesKeywordPolicy() async throws {
    let guardedExecutor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
    let validator = SHACLCoreValidator(sparqlExecutor: guardedExecutor)
    let shapes = try fixtureData("sparqlGuardBlockedValuesShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorBlocksGuardedSPARQLConstraintByPreboundThisPolicy() async throws {
    let guardedExecutor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
    let validator = SHACLCoreValidator(sparqlExecutor: guardedExecutor)
    let shapes = try fixtureData("sparqlGuardBlockedPreboundThisShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorBlocksGuardedSPARQLConstraintByPreboundPathPolicy() async throws {
    let guardedExecutor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
    let validator = SHACLCoreValidator(sparqlExecutor: guardedExecutor)
    let shapes = try fixtureData("sparqlGuardBlockedPreboundPathShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorBlocksGuardedSPARQLConstraintByPreboundValuePolicy() async throws {
    let guardedExecutor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
    let validator = SHACLCoreValidator(sparqlExecutor: guardedExecutor)
    let shapes = try fixtureData("sparqlGuardBlockedPreboundValueShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorBlocksGuardedSPARQLConstraintWithoutThisReference() async throws {
    let guardedExecutor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
    let validator = SHACLCoreValidator(sparqlExecutor: guardedExecutor)
    let shapes = try fixtureData("sparqlGuardMissingThisReferenceShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorBlocksGuardedSPARQLAskConstraintWithoutThisReference() async throws {
    let guardedExecutor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
    let validator = SHACLCoreValidator(sparqlExecutor: guardedExecutor)
    let shapes = try fixtureData("sparqlGuardAskMissingThisReferenceShapes.ttl")
    let dataGraph = try fixtureData("sparqlAskData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorBlocksGuardedSPARQLConstraintByLengthPolicy() async throws {
    let guardedExecutor = SHACLGuardedSPARQLExecutor(
        wrapping: TestSPARQLExecutor(),
        disallowedKeywords: [],
        maxQueryLength: 16
    )
    let validator = SHACLCoreValidator(sparqlExecutor: guardedExecutor)
    let shapes = try fixtureData("sparqlConstraintShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    }
}

@Test func coreValidatorAllowsGuardedSPARQLConstraintWhenPolicyAllowsQuery() async throws {
    let innerExecutor = TestSPARQLExecutor(
        selectResults: [
            "SELECT ?this WHERE { ?this ex:name ?name . FILTER(strlen(str(?name)) = 0) }|http://example.com/alice": ["http://example.com/alice"],
            "SELECT ?this WHERE { ?this ex:name ?name . FILTER(strlen(str(?name)) = 0) }|http://example.com/bob": [],
        ]
    )
    let guardedExecutor = SHACLGuardedSPARQLExecutor(
        wrapping: innerExecutor,
        disallowedKeywords: ["SERVICE"],
        maxQueryLength: 512
    )
    let validator = SHACLCoreValidator(sparqlExecutor: guardedExecutor)
    let shapes = try fixtureData("sparqlConstraintShapes.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    #expect(result.violations.count == 1)
}

@Test func coreValidatorAcceptsNodeExpressionPredicate() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("phaseGatedNodeExpressionsShapes.ttl")
    let dataGraph = try fixtureData("invalidShapesData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
}

@Test func coreValidatorAcceptsDecimalLiteralExpressionTerm() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("decimalExpressionLiteralShape.ttl")
    let dataGraph = try fixtureData("sparqlData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(!result.conforms)
    let violation = try #require(result.violations.first)
    #expect(violation.sourceConstraintIRI == "http://www.w3.org/ns/shacl#expression")
}

@Test func coreValidatorMatchesResultsAcrossDataAndGraphEntryPoints() async throws {
    let validator = SHACLCoreValidator()
    let shapesData = try fixtureData("logicalOrShapes.ttl")
    let graphData = try fixtureData("logicalOrInvalid.ttl")

    let fromData = try validator.validate(dataGraph: graphData, shapesGraph: shapesData)

    let shapes = try SHACLShapesGraphLoader().load(from: shapesData)
    let dataGraph = try SHACLDataGraphLoader().load(from: graphData)
    let fromGraphs = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)

    #expect(fromData == fromGraphs)
}

@Test func coreValidatorLargeGraphSmokeTest() async throws {
    let validator = SHACLCoreValidator()
    let shapes = SHACLShapesGraph(
        shapes: [
            SHACLShapeDefinition(
                shapeIRI: "http://example.com/PersonShape",
                kind: .nodeShape,
                targets: [.targetClass("http://example.com/Person")],
                propertyShapeIRIs: ["http://example.com/AgeShape"]
            ),
            SHACLShapeDefinition(
                shapeIRI: "http://example.com/AgeShape",
                kind: .propertyShape,
                targets: [],
                pathIRI: "http://example.com/age",
                minInclusive: "18",
                maxInclusive: "90"
            ),
        ]
    )

    var triples: [SHACLDataTriple] = []
    for index in 0..<500 {
        let person = "http://example.com/person\(index)"
        triples.append(SHACLDataTriple(subject: person, predicate: rdfTypeIRI, object: "http://example.com/Person"))
        triples.append(SHACLDataTriple(subject: person, predicate: "http://example.com/age", object: "25"))
    }
    let dataGraph = SHACLDataGraph(triples: triples)

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorRegressionCycleAndSeverityStability() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("severityWarningShapes.ttl")
    let dataGraph = try fixtureData("severityWarningData.ttl")

    let first = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    let second = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(first == second)
    #expect(!first.conforms)
    let warning = try #require(first.violations.first)
    #expect(warning.severity == .warning)
}

@Test func coreValidatorAllowsWarningOnlyResultsWhenConfigured() async throws {
    let validator = SHACLCoreValidator(conformanceDisallowedSeverities: [.violation])
    let shapes = try fixtureData("severityWarningShapes.ttl")
    let dataGraph = try fixtureData("severityWarningData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    let warning = try #require(result.violations.first)
    #expect(warning.severity == .warning)
}

@Test func coreValidatorRegressionSuiteKnownDefects() async throws {
    let validator = SHACLCoreValidator()

    let phaseGatedShapes = try fixtureData("phaseGatedRulesShapes.ttl")
    let baselineData = try fixtureData("invalidShapesData.ttl")
    #expect(throws: SHACLError.self) {
        _ = try validator.validate(dataGraph: baselineData, shapesGraph: phaseGatedShapes)
    }

    let qualifiedShapes = try fixtureData("qualifiedCountsShapes.ttl")
    let qualifiedData = try fixtureData("qualifiedCountsMaxInvalid.ttl")
    let qualifiedResult = try validator.validate(dataGraph: qualifiedData, shapesGraph: qualifiedShapes)
    #expect(!qualifiedResult.conforms)
    #expect(qualifiedResult.violations.contains { $0.sourceConstraintIRI == "http://www.w3.org/ns/shacl#qualifiedMaxCount" })

    let rangeShapes = try fixtureData("rangeFacetsShapes.ttl")
    let rangeData = try fixtureData("rangeFacetsNonNumeric.ttl")
    let rangeResult = try validator.validate(dataGraph: rangeData, shapesGraph: rangeShapes)
    #expect(!rangeResult.conforms)
    #expect(rangeResult.violations.contains { $0.message.contains("not an integer literal") })
}

private struct TestSPARQLExecutor: SHACLSPARQLExecutor {
    let selectResults: [String: [String]]
    let askResults: [String: Bool]

    init(selectResults: [String: [String]] = [:], askResults: [String: Bool] = [:]) {
        self.selectResults = selectResults
        self.askResults = askResults
    }

    func select(
        query: String,
        focusNode: String?,
        dataGraph: SHACLDataGraph,
        shapesGraph: SHACLShapesGraph
    ) throws -> [String] {
        let key = "\(query)|\(focusNode ?? "")"
        return selectResults[key] ?? []
    }

    func ask(
        query: String,
        focusNode: String?,
        dataGraph: SHACLDataGraph,
        shapesGraph: SHACLShapesGraph
    ) throws -> Bool {
        let key = "\(query)|\(focusNode ?? "")"
        return askResults[key] ?? true
    }
}
