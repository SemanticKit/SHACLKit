import Foundation
import Testing
@testable import SHACLKit

private let rdfTypeIRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"

private func fixtureData(_ name: String) throws -> Data {
    let fileURL = URL(fileURLWithPath: #filePath)
    let fixturesURL = fileURL.deletingLastPathComponent().appendingPathComponent("Fixtures")
    return try Data(contentsOf: fixturesURL.appendingPathComponent(name))
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

@Test func coreValidatorKeepsConformanceTrueForWarningOnlyResults() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("severityWarningShapes.ttl")
    let dataGraph = try fixtureData("severityWarningData.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
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
                minInclusive: 18,
                maxInclusive: 90
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
    #expect(first.conforms)
    let warning = try #require(first.violations.first)
    #expect(warning.severity == .warning)
}
