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

@Test func coreValidatorStillReportsNotImplementedWithParsedCount() async throws {
    let validator = SHACLCoreValidator()
    let shapes = try fixtureData("basic-targets.ttl")

    do {
        _ = try validator.validate(dataGraph: Data(), shapesGraph: shapes)
        Issue.record("Expected notImplemented until core engine lands")
    } catch let error as SHACLError {
        switch error {
        case .notImplemented(let detail):
            #expect(detail.contains("Parsed 1 shape"))
        default:
            Issue.record("Unexpected SHACLError: \(error)")
        }
    }
}
