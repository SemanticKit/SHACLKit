import IRIKit
import RDFCore
import RDFKit
import Testing
import SHACL
import struct RDFCore.Literal
import struct RDFCore.Graph
@testable import SHACLKit

@Suite("Ill-formed shapes graphs and undescribed shapes", .tags(.shapesGraph))
struct IllFormedShapesGraphTests {
    private func validate(_ shapes: String, _ data: String = "invalidShapesData.ttl") throws -> SHACLValidationReport {
        try Fixtures.validate(shapes: shapes, data: data)
    }

    @Test func coreValidatorThrowsForPropertyShapeMissingPath() throws {
        #expect(throws: SHACLError.self) { try validate("invalidShapesMissingPath.ttl") }
    }

    @Test("A value of sh:property that is not a property shape is ill-formed")
    func coreValidatorThrowsForMissingReferencedPropertyShape() throws {
        #expect(throws: SHACLError.self) { try validate("invalidShapesUnknownProperty.ttl") }
    }

    @Test("A qualified value shape the shapes graph does not describe is the empty shape, which every value conforms to")
    func coreValidatorThrowsForMissingReferencedNodeShape() throws {
        let report = try validate("invalidShapesUnknownNodeShape.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.QualifiedMinCountConstraintComponent)
        #expect(result.focusNode == term("ex:alice"))
    }

    @Test("A sh:node the shapes graph does not describe is the empty shape, which every node conforms to")
    func coreValidatorThrowsForMissingReferencedNodeShapeOnNodeShape() throws {
        let report = try validate("invalidShapesUnknownNodeReferenceOnNodeShape.ttl")
        #expect(report.conforms)
    }

    @Test("An IRI with no node expression parameters is a constant node expression")
    func coreValidatorThrowsForMissingReferencedNodeExpression() throws {
        let shapes = try Fixtures.shapes("invalidShapesUnknownExpression.ttl")
        let derived = try #require(shapes.shape(term("ex:DerivedShape")))
        #expect(derived.valueExpression == .constant(term("ex:MissingExpr")))
        let report = try SHACLValidator().validate(Fixtures.graph("invalidShapesData.ttl"), against: shapes)
        let result = try #require(report.results.first)
        #expect(result.focusNode == term("ex:task1"))
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test("A constant sh:expression that is not true is a result for each focus node")
    func coreValidatorThrowsForMissingReferencedNodeExpressionOnNodeShape() throws {
        let report = try validate("invalidShapesUnknownNodeExpression.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.ExpressionConstraintComponent)
        #expect(result.sourceConstraint == term("ex:MissingNodeExpression"))
    }

    @Test("A sh:nodeByExpression output the shapes graph does not describe is the empty shape")
    func coreValidatorThrowsForMissingReferencedNodeByExpressionOnNodeShape() throws {
        #expect(try validate("invalidShapesUnknownNodeByExpressionNode.ttl").conforms)
    }

    @Test("A property shape's sh:nodeByExpression output the shapes graph does not describe is the empty shape")
    func coreValidatorThrowsForMissingReferencedNodeByExpressionOnPropertyShape() throws {
        #expect(try validate("invalidShapesUnknownNodeByExpressionProperty.ttl").conforms)
    }

    @Test("A sh:rule value that is not a sh:TripleRule is ill-formed")
    func coreValidatorThrowsForMissingReferencedRule() throws {
        #expect(throws: SHACLError.self) { try validate("phaseGatedRulesShapes.ttl") }
    }

    @Test func coreValidatorThrowsForPropertyShapeSPARQLTargetMissingSelect() throws {
        #expect(throws: SHACLError.self) { try validate("invalidPropertySparqlTargetShapes.ttl") }
    }

    @Test func coreValidatorThrowsForTargetNodeSPARQLTargetMissingSelect() throws {
        #expect(throws: SHACLError.self) { try validate("invalidTargetNodeSparqlAskOnlyShapes.ttl", "sparqlData.ttl") }
    }

    @Test func coreValidatorRegressionSuiteKnownDefects() throws {
        #expect(throws: SHACLError.self) { try validate("phaseGatedRulesShapes.ttl") }

        let qualified = try validate("qualifiedCountsShapes.ttl", "qualifiedCountsMaxInvalid.ttl")
        #expect(!qualified.conforms)
        #expect(qualified.results.contains { $0.sourceConstraintComponent === SHACL.QualifiedMaxCountConstraintComponent })

        let range = try validate("rangeFacetsShapes.ttl", "rangeFacetsNonNumeric.ttl")
        #expect(!range.conforms)
        #expect(range.results.contains { $0.message.contains("not comparable") })
    }
}
