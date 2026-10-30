import IRIKit
import RDFCore
import RDFKit
import Testing
import SHACL
import struct RDFCore.Literal
import struct RDFCore.Graph
@testable import SHACLKit

@Suite("Constraints over node expressions", .tags(.constraints, .nodeExpression))
struct ExpressionConstraintTests {
    private func validate(_ shapes: String, _ data: String) throws -> SHACLValidationReport {
        try Fixtures.validate(shapes: shapes, data: data)
    }

    @Test func coreValidatorConformsForExpressionDerivedPropertyValues() throws {
        let report = try validate("nodeExpressionConstraintValidShapes.ttl", "nodeExpressionConstraintData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsExpressionDerivedPropertyViolation() throws {
        let report = try validate("nodeExpressionConstraintInvalidShapes.ttl", "nodeExpressionConstraintData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorConformsForPathValuesNodeExpression() throws {
        let report = try validate("nodeExpressionPathValuesValidShapes.ttl", "nodeExpressionPathValuesData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsPathValuesNodeExpressionViolation() throws {
        let report = try validate("nodeExpressionPathValuesInvalidShapes.ttl", "nodeExpressionPathValuesData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorConformsForExistsExpressionConstraint() throws {
        let report = try validate("expressionConstraintExistsShapes.ttl", "expressionConstraintExistsValidData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsExistsExpressionConstraintViolation() throws {
        let report = try validate("expressionConstraintExistsShapes.ttl", "expressionConstraintExistsInvalidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.ExpressionConstraintComponent)
    }

    @Test func coreValidatorConformsForIfExpressionConstraint() throws {
        let report = try validate("expressionConstraintIfShapes.ttl", "expressionConstraintIfValidData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsIfExpressionConstraintViolation() throws {
        let report = try validate("expressionConstraintIfShapes.ttl", "expressionConstraintIfInvalidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.ExpressionConstraintComponent)
    }

    @Test func coreValidatorConformsForCountExpressionConstraint() throws {
        let report = try validate("expressionConstraintCountShapes.ttl", "expressionConstraintCountValidData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsCountExpressionConstraintViolation() throws {
        let report = try validate("expressionConstraintCountShapes.ttl", "expressionConstraintCountInvalidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorConformsForDistinctExpressionConstraint() throws {
        let report = try validate("expressionConstraintDistinctShapes.ttl", "expressionConstraintDistinctValidData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsDistinctExpressionConstraintViolation() throws {
        let report = try validate("expressionConstraintDistinctShapes.ttl", "expressionConstraintDistinctInvalidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorConformsForVarExpressionConstraint() throws {
        let report = try validate("expressionConstraintVarShapes.ttl", "expressionConstraintVarValidData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsVarExpressionConstraintViolation() throws {
        let report = try validate("expressionConstraintVarInvalidShapes.ttl", "expressionConstraintVarValidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorConformsForInstancesOfExpressionConstraint() throws {
        let report = try validate("expressionConstraintInstancesOfShapes.ttl", "expressionConstraintInstancesOfValidData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsInstancesOfExpressionConstraintViolation() throws {
        let report = try validate("expressionConstraintInstancesOfInvalidShapes.ttl", "expressionConstraintInstancesOfValidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorReportsNodesMatchingExpressionConstraintViolation() throws {
        let report = try validate("expressionConstraintNodesMatchingInvalidShapes.ttl", "expressionConstraintNodesMatchingValidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorConformsForMatchAllExpressionConstraint() throws {
        let report = try validate("expressionConstraintMatchAllShapes.ttl", "expressionConstraintMatchAllValidData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsMatchAllExpressionConstraintViolation() throws {
        let report = try validate("expressionConstraintMatchAllShapes.ttl", "expressionConstraintMatchAllInvalidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorConformsForFilterShapeExpressionConstraint() throws {
        let report = try validate("expressionConstraintFilterShapeShapes.ttl", "expressionConstraintFilterShapeValidData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsFilterShapeExpressionConstraintViolation() throws {
        let report = try validate("expressionConstraintFilterShapeShapes.ttl", "expressionConstraintFilterShapeInvalidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorConformsForRemoveExpressionConstraint() throws {
        let report = try validate("expressionConstraintRemoveShapes.ttl", "expressionConstraintRemoveValidData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsRemoveExpressionConstraintViolation() throws {
        let report = try validate("expressionConstraintRemoveShapes.ttl", "expressionConstraintRemoveInvalidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorConformsForFlatMapExpressionConstraint() throws {
        let report = try validate("expressionConstraintFlatMapShapes.ttl", "expressionConstraintFlatMapValidData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsFlatMapExpressionConstraintViolation() throws {
        let report = try validate("expressionConstraintFlatMapShapes.ttl", "expressionConstraintFlatMapInvalidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorConformsForLimitExpressionConstraint() throws {
        let report = try validate("expressionConstraintLimitShapes.ttl", "expressionConstraintLimitValidData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsLimitExpressionConstraintViolation() throws {
        let report = try validate("expressionConstraintLimitShapes.ttl", "expressionConstraintLimitInvalidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorConformsForFindFirstExpressionConstraint() throws {
        let report = try validate("expressionConstraintFindFirstShapes.ttl", "expressionConstraintFindFirstValidData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsFindFirstExpressionConstraintViolation() throws {
        let report = try validate("expressionConstraintFindFirstShapes.ttl", "expressionConstraintFindFirstInvalidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorConformsForOrderByExpressionConstraint() throws {
        let report = try validate("expressionConstraintOrderByShapes.ttl", "expressionConstraintOrderByValidData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsOrderByExpressionConstraintViolation() throws {
        let report = try validate("expressionConstraintOrderByShapes.ttl", "expressionConstraintOrderByInvalidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorConformsForMaxExpressionConstraint() throws {
        let report = try validate("expressionConstraintMaxShapes.ttl", "expressionConstraintMaxValidData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsMaxExpressionConstraintViolation() throws {
        let report = try validate("expressionConstraintMaxShapes.ttl", "expressionConstraintMaxInvalidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorConformsForSumExpressionConstraint() throws {
        let report = try validate("expressionConstraintSumShapes.ttl", "expressionConstraintSumValidData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsSumExpressionConstraintViolation() throws {
        let report = try validate("expressionConstraintSumShapes.ttl", "expressionConstraintSumInvalidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorConformsForNodesMatchingExpressionConstraint() throws {
        let shapes = try Fixtures.shapes("expressionConstraintNodesMatchingShapes.ttl")
        let data = try Fixtures.graph("expressionConstraintNodesMatchingValidData.ttl")
        let output = try shapes.expression(term("ex:NodesMatchingExpr")).evaluate(
            focusNode: term("ex:scope"),
            dataGraph: data,
            shapesGraph: shapes
        )
        #expect(output.contains(term("ex:alice")))
        let report = try SHACLValidator().validate(data, against: shapes)
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorConformsForPropertyExpressionConstraint() throws {
        let report = try validate("expressionConstraintPathValidShapes.ttl", "expressionConstraintPathData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsPropertyExpressionConstraintViolation() throws {
        let report = try validate("expressionConstraintPathInvalidShapes.ttl", "expressionConstraintPathData.ttl")
        #expect(!report.conforms)
        #expect(report.results.count == 2)
        #expect(report.results.allSatisfy { $0.sourceConstraintComponent === SHACL.ExpressionConstraintComponent })
    }

    @Test func coreValidatorConformsForNodeExpressionConstraint() throws {
        let report = try validate("expressionConstraintNodeValidShapes.ttl", "expressionConstraintNodeData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsNodeExpressionConstraintViolation() throws {
        let report = try validate("expressionConstraintNodeInvalidShapes.ttl", "expressionConstraintNodeData.ttl")
        #expect(!report.conforms)
        #expect(report.results.count == 2)
        #expect(report.results.allSatisfy { $0.sourceConstraintComponent === SHACL.ExpressionConstraintComponent })
    }

    @Test func coreValidatorConformsForNodeByExpressionNodeConstraint() throws {
        let report = try validate("nodeByExpressionNodeShapes.ttl", "nodeByExpressionNodeValidData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsNodeByExpressionNodeConstraintViolation() throws {
        let report = try validate("nodeByExpressionNodeShapes.ttl", "nodeByExpressionNodeInvalidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.NodeByExpressionConstraintComponent)
        #expect(result.sourceConstraint == term("ex:AdultShape"))
    }

    @Test func coreValidatorConformsForNodeByExpressionPropertyConstraint() throws {
        let report = try validate("nodeByExpressionPropertyShapes.ttl", "nodeByExpressionPropertyValidData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsNodeByExpressionPropertyConstraintViolation() throws {
        let report = try validate("nodeByExpressionPropertyShapes.ttl", "nodeByExpressionPropertyInvalidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.NodeByExpressionConstraintComponent)
        #expect(result.sourceConstraint == term("ex:NamedNodeShape"))
    }

    @Test func coreValidatorAcceptsNodeExpressionPredicate() throws {
        #expect(try validate("phaseGatedNodeExpressionsShapes.ttl", "invalidShapesData.ttl").conforms)
    }

    @Test func coreValidatorAcceptsDecimalLiteralExpressionTerm() throws {
        let report = try validate("decimalExpressionLiteralShape.ttl", "sparqlData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.ExpressionConstraintComponent)
    }
}
