import IRIKit
import RDFCore
import RDFKit
import Testing
@testable import SHACLKit

@Suite("Targets and focus nodes", .tags(.targets))
struct TargetTests {
    /// The focus nodes of the shape named `shape` in the shapes fixture,
    /// over the data fixture.
    private func focusNodes(_ shapesFixture: String, _ dataFixture: String, shape: String) throws -> [ObjectTerm] {
        let shapes = try Fixtures.shapes(shapesFixture)
        let target = try #require(shapes.shape(term(shape)))
        return try SHACLValidator().focusNodes(of: target, in: Fixtures.graph(dataFixture), against: shapes)
    }

    private let ns = "http://example.com/ns#"

    @Test func coreValidatorResolvesTargetWhereFocusNodes() throws {
        let fixture = "W3CDataShapes/shacl12-test-suite/tests/core/targets/targetWhere-001.ttl"
        let report = try Fixtures.validate(shapes: fixture, data: fixture)
        #expect(!report.conforms)
        #expect(report.results.contains { $0.focusNode == .iri(IRI(rawValue: ns + "InvalidResource1")!) })
        #expect(!report.results.contains { $0.focusNode == .iri(IRI(rawValue: ns + "InvalidResource2")!) })
    }

    @Test func coreValidatorResolvesShapeClassImplicitTargets() throws {
        let fixture = "W3CDataShapes/shacl12-test-suite/tests/core/targets/targetClassImplicit-002.ttl"
        let report = try Fixtures.validate(shapes: fixture, data: fixture)
        #expect(!report.conforms)
        #expect(report.results.contains { $0.focusNode == .iri(IRI(rawValue: ns + "InvalidInstance")!) })
    }

    @Test func coreValidatorResolvesShapeSelectorTargets() throws {
        let report = try Fixtures.validate(
            shapes: "W3CDataShapes/shacl12-test-suite/tests/core/targets/shape-001.ttl",
            data: "W3CDataShapes/shacl12-test-suite/tests/core/targets/shape-001-data.ttl"
        )
        #expect(!report.conforms)
        #expect(report.results.contains { $0.focusNode == .iri(IRI(rawValue: ns + "InvalidResource1")!) })
        #expect(!report.results.contains { $0.focusNode == .iri(IRI(rawValue: ns + "ValidResource1")!) })
    }

    @Test func focusNodeResolverResolvesSelectorsAgainstDataGraph() throws {
        let shapes = try Fixtures.shapes("basicTargets.ttl")
        #expect(shapes.shapes.count == 1)
        #expect(try focusNodes("basicTargets.ttl", "dataGraph.ttl", shape: "ex:PersonShape")
            == [term("ex:alice"), term("ex:carol"), term("ex:org1")])
    }

    @Test func focusNodeResolverSupportsMultipleShapes() throws {
        #expect(try focusNodes("multiTargets.ttl", "dataGraph.ttl", shape: "ex:ThingShape") == [term("ex:alice"), term("ex:bob")])
        #expect(try focusNodes("multiTargets.ttl", "dataGraph.ttl", shape: "ex:NamePropShape") == [term("ex:alice")])
    }

    @Test func focusNodeResolverResolvesTargetNodeExpressions() throws {
        #expect(try focusNodes("targetNodeExpressionShapes.ttl", "dataGraph.ttl", shape: "ex:ExprTargetShape")
            == [term("ex:alice"), term("ex:bob")])
    }

    @Test func focusNodeResolverResolvesPathValuesTargetNodeExpression() throws {
        #expect(try focusNodes("targetNodeExpressionPathValuesShapes.ttl", "nodeExpressionPathValuesData.ttl", shape: "ex:FriendShape")
            == [term("ex:bob")])
    }

    @Test func focusNodeResolverResolvesNodesTargetNodeExpression() throws {
        #expect(try focusNodes("targetNodeExpressionNodesShapes.ttl", "dataGraph.ttl", shape: "ex:NodesTargetShape")
            == [term("ex:alice"), term("ex:bob")])
    }

    @Test func focusNodeResolverIgnoresEmptyTargetNodeExpressionOutputs() throws {
        #expect(try focusNodes("targetNodeExpressionWithThisShapes.ttl", "dataGraph.ttl", shape: "ex:ExprTargetWithThisShape")
            == [term("ex:alice")])
    }

    @Test func focusNodeResolverIgnoresEmptyNodesTargetNodeExpressionOutputs() throws {
        #expect(try focusNodes("targetNodeExpressionEmptyNodesShapes.ttl", "dataGraph.ttl", shape: "ex:EmptyNodesTargetShape").isEmpty)
    }
}
