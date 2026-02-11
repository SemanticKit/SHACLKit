import Foundation
import Testing
@testable import SHACLKit

private func fixtureData(_ name: String) throws -> Data {
    let fileURL = URL(fileURLWithPath: #filePath)
    let fixturesURL = fileURL.deletingLastPathComponent().appendingPathComponent("Fixtures")
    return try Data(contentsOf: fixturesURL.appendingPathComponent(name))
}

@Test func shapesLoaderParsesNodeShapeTargets() async throws {
    let loader = SHACLShapesGraphLoader()
    let graph = try loader.load(from: fixtureData("basic-targets.ttl"))

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
    let graph = try loader.load(from: fixtureData("multi-targets.ttl"))

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

    let shapes = try shapesLoader.load(from: fixtureData("basic-targets.ttl"))
    let dataGraph = try dataLoader.load(from: fixtureData("data-graph.ttl"))
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

    let shapes = try shapesLoader.load(from: fixtureData("multi-targets.ttl"))
    let dataGraph = try dataLoader.load(from: fixtureData("data-graph.ttl"))
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
    let shapes = try fixtureData("count-constraints-shapes.ttl")
    let dataGraph = try fixtureData("count-constraints-valid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsDeterministicCountViolations() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("count-constraints-shapes.ttl")
    let dataGraph = try fixtureData("count-constraints-invalid.ttl")

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
    let shapes = try fixtureData("class-constraints-shapes.ttl")
    let dataGraph = try fixtureData("class-constraints-valid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsClassConstraintViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("class-constraints-shapes.ttl")
    let dataGraph = try fixtureData("class-constraints-invalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)

    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.message.contains("class violation"))
    #expect(violation.message.contains("http://example.com/org1"))
}

@Test func coreValidatorConformsForNodeKindFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodekind-constraints-shapes.ttl")
    let dataGraph = try fixtureData("nodekind-constraints-valid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsNodeKindViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodekind-constraints-shapes.ttl")
    let dataGraph = try fixtureData("nodekind-constraints-invalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)

    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.message.contains("nodeKind violation"))
    #expect(violation.message.contains("iri"))
}

@Test func coreValidatorConformsForDatatypeFixture() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("datatype-constraints-shapes.ttl")
    let dataGraph = try fixtureData("datatype-constraints-valid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsDatatypeViolation() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("datatype-constraints-shapes.ttl")
    let dataGraph = try fixtureData("datatype-constraints-invalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)

    #expect(!result.conforms)
    #expect(result.violations.count == 1)
    let violation = try #require(result.violations.first)
    #expect(violation.message.contains("datatype violation"))
    #expect(violation.message.contains("XMLSchema#integer"))
}

@Test func coreValidatorConformsForBroaderNodeKinds() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodekind-broad-shapes.ttl")
    let dataGraph = try fixtureData("nodekind-broad-valid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)
    #expect(result.conforms)
    #expect(result.violations.isEmpty)
}

@Test func coreValidatorReportsBroaderNodeKindViolations() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("nodekind-broad-shapes.ttl")
    let dataGraph = try fixtureData("nodekind-broad-invalid.ttl")

    let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapes)

    #expect(!result.conforms)
    #expect(result.violations.count == 2)
    let messages = result.violations.map(\.message).joined(separator: " | ")
    #expect(messages.contains("blankNode"))
    #expect(messages.contains("iriOrLiteral"))
}
