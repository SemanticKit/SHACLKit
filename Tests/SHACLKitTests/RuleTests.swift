import IRIKit
import RDFCore
import RDFKit
import Testing
import SHACL
import struct RDFCore.Literal
import struct RDFCore.Graph
@testable import SHACLKit

@Suite("Triple rules", .tags(.rules))
struct RuleTests {
    private func validate(_ shapes: String, _ data: String) throws -> SHACLValidationReport {
        try Fixtures.validate(shapes: shapes, data: data)
    }

    @Test func coreValidatorConformsForRuleEvaluationFixture() throws {
        let report = try validate("ruleEvaluationShapes.ttl", "ruleEvaluationData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorRuleEvaluationIsDeterministicAcrossRuns() throws {
        let shapes = try Fixtures.shapes("ruleEvaluationShapes.ttl")
        let data = try Fixtures.graph("ruleEvaluationData.ttl")
        let first = try SHACLValidator().validate(data, against: shapes)
        let second = try SHACLValidator().validate(data, against: shapes)
        #expect(first == second)
    }

    @Test func coreValidatorRuleEvaluationTerminatesForSelfLoopingRule() throws {
        let report = try validate("ruleTerminationShapes.ttl", "ruleTerminationData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorRuleEvaluationRequiresAllConditions() throws {
        let report = try validate("ruleMultiConditionShapes.ttl", "ruleMultiConditionValidData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorRuleEvaluationSkipsWhenConditionMissing() throws {
        let report = try validate("ruleMultiConditionShapes.ttl", "ruleMultiConditionInvalidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorRuleEvaluationSupportsPropertyShapeCondition() throws {
        let report = try validate("rulePropertyConditionShapes.ttl", "rulePropertyConditionValidData.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorRuleEvaluationSkipsPropertyShapeConditionWhenNotSatisfied() throws {
        let report = try validate("rulePropertyConditionShapes.ttl", "rulePropertyConditionInvalidData.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }
}
