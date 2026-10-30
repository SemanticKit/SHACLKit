import IRIKit
import RDFCore
import RDFKit
import Testing
@testable import SHACLKit

@Suite("SHACL Core constraint components", .tags(.constraints))
struct ConstraintTests {
    private func validate(_ shapes: String, _ data: String) throws -> SHACLValidationReport {
        try Fixtures.validate(shapes: shapes, data: data)
    }

    @Test func coreValidatorConformsForMinMaxCountFixture() throws {
        let report = try validate("countConstraintsShapes.ttl", "countConstraintsValid.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsDeterministicCountViolations() throws {
        let report = try validate("countConstraintsShapes.ttl", "countConstraintsInvalid.ttl")
        #expect(!report.conforms)
        #expect(report.results.count == 2)
        #expect(report.results[0].focusNode == term("ex:alice"))
        #expect(report.results[0].sourceConstraintComponent === SHACL.MinCountConstraintComponent)
        #expect(report.results[1].focusNode == term("ex:bob"))
        #expect(report.results[1].sourceConstraintComponent === SHACL.MaxCountConstraintComponent)
    }

    @Test func coreValidatorConformsForClassConstraintFixture() throws {
        let report = try validate("classConstraintsShapes.ttl", "classConstraintsValid.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorConformsForNodeShapeLevelConstraints() throws {
        let report = try validate("nodeShapeConstraintsShapes.ttl", "nodeShapeConstraintsValid.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsNodeShapeLevelClassViolation() throws {
        let report = try validate("nodeShapeConstraintsShapes.ttl", "nodeShapeConstraintsInvalid.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceShape.id == term("ex:EmployeeNodeShape"))
        #expect(result.resultPath == nil)
        #expect(result.sourceConstraintComponent === SHACL.ClassConstraintComponent)
    }

    @Test(arguments: [
        ("nodeShapeConstraintsShapes.ttl", "nodeShapeConstraintsValid.ttl", true),
        ("nodeShapeConstraintsShapes.ttl", "nodeShapeConstraintsInvalid.ttl", false),
        ("severityWarningShapes.ttl", "severityWarningData.ttl", false),
    ])
    func coreValidatorNodeShapeValidationMatrixSubset(shapes: String, data: String, conforms: Bool) throws {
        #expect(try validate(shapes, data).conforms == conforms)
    }

    @Test func coreValidatorReportsClassConstraintViolation() throws {
        let report = try validate("classConstraintsShapes.ttl", "classConstraintsInvalid.ttl")
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.ClassConstraintComponent)
        #expect(result.value == term("ex:org1"))
    }

    @Test func coreValidatorConformsForNodeKindFixture() throws {
        let report = try validate("nodeKindConstraintsShapes.ttl", "nodeKindConstraintsValid.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsNodeKindViolation() throws {
        let report = try validate("nodeKindConstraintsShapes.ttl", "nodeKindConstraintsInvalid.ttl")
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.NodeKindConstraintComponent)
        #expect(result.value == term("123"))
        #expect(result.message.contains("IRI"))
    }

    @Test func coreValidatorConformsForDatatypeFixture() throws {
        let report = try validate("datatypeConstraintsShapes.ttl", "datatypeConstraintsValid.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsDatatypeViolation() throws {
        let report = try validate("datatypeConstraintsShapes.ttl", "datatypeConstraintsInvalid.ttl")
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.DatatypeConstraintComponent)
        #expect(result.message.contains("XMLSchema#integer"))
    }

    @Test func coreValidatorConformsForBroaderNodeKinds() throws {
        let report = try validate("nodeKindBroadShapes.ttl", "nodeKindBroadValid.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsBroaderNodeKindViolations() throws {
        let report = try validate("nodeKindBroadShapes.ttl", "nodeKindBroadInvalid.ttl")
        #expect(!report.conforms)
        #expect(report.results.count == 2)
        #expect(report.results.allSatisfy { $0.sourceConstraintComponent === SHACL.NodeKindConstraintComponent })
        let messages = report.results.map(\.message).joined(separator: " | ")
        #expect(messages.contains("BlankNode"))
        #expect(messages.contains("IRIOrLiteral"))
    }

    @Test func coreValidatorConformsForExtendedNodeKinds() throws {
        let report = try validate("nodeKindExtendedShapes.ttl", "nodeKindExtendedValid.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsExtendedNodeKindViolations() throws {
        let report = try validate("nodeKindExtendedShapes.ttl", "nodeKindExtendedInvalid.ttl")
        #expect(!report.conforms)
        #expect(report.results.count == 2)
        let messages = report.results.map(\.message).joined(separator: " | ")
        #expect(messages.contains("BlankNodeOrIRI"))
        #expect(messages.contains("BlankNodeOrLiteral"))
    }

    @Test func coreValidatorConformsForStringFacetFixture() throws {
        let report = try validate("stringFacetsShapes.ttl", "stringFacetsValid.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsStringFacetViolations() throws {
        let report = try validate("stringFacetsShapes.ttl", "stringFacetsInvalid.ttl")
        #expect(!report.conforms)
        #expect(report.results.count == 2)
        #expect(report.results.contains { $0.sourceConstraintComponent === SHACL.MinLengthConstraintComponent })
        #expect(report.results.contains { $0.sourceConstraintComponent === SHACL.PatternConstraintComponent })
    }

    @Test func coreValidatorConformsForSingleLineConstraintFixture() throws {
        let report = try validate("singleLineConstraintsShapes.ttl", "singleLineConstraintsValid.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsSingleLineConstraintViolations() throws {
        let report = try validate("singleLineConstraintsShapes.ttl", "singleLineConstraintsInvalid.ttl")
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.SingleLineConstraintComponent)
        #expect(result.value == .literal("Invalid\nlabel"))
    }

    @Test func coreValidatorConformsForRangeFacetFixture() throws {
        let report = try validate("rangeFacetsShapes.ttl", "rangeFacetsValid.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsRangeFacetViolations() throws {
        let report = try validate("rangeFacetsShapes.ttl", "rangeFacetsInvalid.ttl")
        #expect(!report.conforms)
        #expect(report.results.count == 2)
        #expect(report.results.contains { $0.sourceConstraintComponent === SHACL.MinInclusiveConstraintComponent })
        #expect(report.results.contains { $0.sourceConstraintComponent === SHACL.MaxInclusiveConstraintComponent })
    }

    @Test("A value that is not comparable with a range bound violates the bound")
    func coreValidatorReportsRangeFacetNonNumericViolation() throws {
        let report = try validate("rangeFacetsShapes.ttl", "rangeFacetsNonNumeric.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first { $0.sourceConstraintComponent === SHACL.MinInclusiveConstraintComponent })
        #expect(result.value == term("\"eighteen\""))
        #expect(result.message.contains("not comparable"))
    }

    @Test func coreValidatorConformsForHasValueFixture() throws {
        let report = try validate("hasValueConstraintsShapes.ttl", "hasValueConstraintsValid.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsHasValueViolation() throws {
        let report = try validate("hasValueConstraintsShapes.ttl", "hasValueConstraintsInvalid.ttl")
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
        #expect(result.value == nil)
        #expect(result.message.contains("http://example.com/Active"))
    }

    @Test func coreValidatorConformsForInConstraintFixture() throws {
        let report = try validate("inConstraintsShapes.ttl", "inConstraintsValid.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsInConstraintViolation() throws {
        let report = try validate("inConstraintsShapes.ttl", "inConstraintsInvalid.ttl")
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.InConstraintComponent)
        #expect(result.value == term("ex:Archived"))
    }

    @Test func coreValidatorConformsForInListConstraintFixture() throws {
        let report = try validate("inListConstraintsShapes.ttl", "inListConstraintsValid.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsInListConstraintViolation() throws {
        let report = try validate("inListConstraintsShapes.ttl", "inListConstraintsInvalid.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.InConstraintComponent)
        #expect(result.value == term("ex:Archived"))
    }

    @Test func coreValidatorConformsForNodeReferenceFixture() throws {
        let report = try validate("nodeReferenceShapes.ttl", "nodeReferenceValid.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test("A value that does not conform to sh:node is one result, detailed by the shape's results")
    func coreValidatorReportsNodeReferenceViolation() throws {
        let report = try validate("nodeReferenceShapes.ttl", "nodeReferenceInvalid.ttl")
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        let result = try #require(report.results.first)
        #expect(result.sourceShape.id == term("ex:ManagerPropertyShape"))
        #expect(result.sourceConstraintComponent === SHACL.NodeConstraintComponent)
        #expect(result.value == term("ex:bob"))
        let detail = try #require(result.details.first)
        #expect(detail.sourceShape.id == term("ex:EmployeeIdShape"))
        #expect(detail.sourceConstraintComponent === SHACL.MinCountConstraintComponent)
    }

    @Test func coreValidatorConformsForQualifiedCountFixture() throws {
        let report = try validate("qualifiedCountsShapes.ttl", "qualifiedCountsValid.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsQualifiedMinCountViolation() throws {
        let report = try validate("qualifiedCountsShapes.ttl", "qualifiedCountsMinInvalid.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.QualifiedMinCountConstraintComponent)
    }

    @Test func coreValidatorReportsQualifiedMaxCountViolation() throws {
        let report = try validate("qualifiedCountsShapes.ttl", "qualifiedCountsMaxInvalid.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.QualifiedMaxCountConstraintComponent)
    }

    @Test func coreValidatorSetsConformanceFalseForWarningOnlyResults() throws {
        let report = try validate("severityWarningShapes.ttl", "severityWarningData.ttl")
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        let warning = try #require(report.results.first)
        #expect(warning.severity === SHACL.Warning)
        #expect(warning.sourceConstraintComponent === SHACL.MinCountConstraintComponent)
    }

    @Test func coreValidatorPropagatesMixedSeverityAndDeterministicDiagnostics() throws {
        let report = try validate("severityMixedShapes.ttl", "severityMixedData.ttl")
        #expect(!report.conforms)
        #expect(report.results.count == 3)
        let results = report.results
        #expect(results[0].sourceShape.id == term("ex:NameRequiredShape"))
        #expect(results[0].severity === SHACL.Violation)
        #expect(results[0].sourceConstraintComponent === SHACL.MinCountConstraintComponent)
        #expect(results[1].sourceShape.id == term("ex:NickHintShape"))
        #expect(results[1].severity === SHACL.Info)
        #expect(results[1].sourceConstraintComponent === SHACL.MinCountConstraintComponent)
        #expect(results[2].sourceShape.id == term("ex:StatusAllowedShape"))
        #expect(results[2].severity === SHACL.Warning)
        #expect(results[2].sourceConstraintComponent === SHACL.InConstraintComponent)
        #expect(results[2].value == term("ex:Archived"))
    }

    @Test func coreValidatorTerminatesOnCyclicNodeReferences() throws {
        let report = try validate("cycleGuardShapes.ttl", "cycleGuardData.ttl")
        #expect(!report.conforms)
        #expect(report.results.count == 1)
    }

    @Test("A cycle of sh:node references reports the node that breaks it")
    func coreValidatorReportsStableViolationForCycleGuardFixture() throws {
        let report = try validate("cycleGuardShapes.ttl", "cycleGuardData.ttl")
        let result = try #require(report.results.first)
        #expect(result.sourceShape.id == term("ex:ManagerLinkShape"))
        #expect(result.focusNode == term("ex:alice"))
        #expect(result.value == term("ex:bob"))
        #expect(result.sourceConstraintComponent === SHACL.NodeConstraintComponent)
        let detail = try #require(result.details.first { $0.sourceShape.id == term("ex:EmployeeIdShape") })
        #expect(detail.focusNode == term("ex:bob"))
        #expect(detail.sourceConstraintComponent === SHACL.MinCountConstraintComponent)
    }

    @Test func coreValidatorConformsForLogicalOrFixture() throws {
        #expect(try validate("logicalOrShapes.ttl", "logicalOrValid.ttl").conforms)
    }

    @Test func coreValidatorReportsLogicalOrViolation() throws {
        let report = try validate("logicalOrShapes.ttl", "logicalOrInvalid.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.OrConstraintComponent)
    }

    @Test func coreValidatorConformsForLogicalOrListFixture() throws {
        let report = try validate("logicalListOrShapes.ttl", "logicalListOrValid.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsLogicalOrListViolation() throws {
        let report = try validate("logicalListOrShapes.ttl", "logicalListOrInvalid.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.OrConstraintComponent)
    }

    @Test func coreValidatorConformsForLogicalAndFixture() throws {
        #expect(try validate("logicalAndShapes.ttl", "logicalAndValid.ttl").conforms)
    }

    @Test func coreValidatorReportsLogicalAndViolation() throws {
        let report = try validate("logicalAndShapes.ttl", "logicalAndInvalid.ttl")
        #expect(!report.conforms)
        #expect(report.results.contains { $0.sourceConstraintComponent === SHACL.AndConstraintComponent })
    }

    @Test func coreValidatorConformsForLogicalAndListFixture() throws {
        let report = try validate("logicalListAndShapes.ttl", "logicalListAndValid.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsLogicalAndListViolation() throws {
        let report = try validate("logicalListAndShapes.ttl", "logicalListAndInvalid.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.AndConstraintComponent)
    }

    @Test func coreValidatorConformsForLogicalNotFixture() throws {
        #expect(try validate("logicalNotShapes.ttl", "logicalNotValid.ttl").conforms)
    }

    @Test func coreValidatorReportsLogicalNotViolation() throws {
        let report = try validate("logicalNotShapes.ttl", "logicalNotInvalid.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.NotConstraintComponent)
    }

    @Test func coreValidatorConformsForLogicalXoneFixture() throws {
        #expect(try validate("logicalXoneShapes.ttl", "logicalXoneValid.ttl").conforms)
    }

    @Test func coreValidatorReportsLogicalXoneViolation() throws {
        let report = try validate("logicalXoneShapes.ttl", "logicalXoneInvalid.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.XoneConstraintComponent)
    }

    @Test func coreValidatorConformsForLogicalXoneListFixture() throws {
        let report = try validate("logicalListXoneShapes.ttl", "logicalListXoneValid.ttl")
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorReportsLogicalXoneListViolation() throws {
        let report = try validate("logicalListXoneShapes.ttl", "logicalListXoneInvalid.ttl")
        #expect(!report.conforms)
        let result = try #require(report.results.first)
        #expect(result.sourceConstraintComponent === SHACL.XoneConstraintComponent)
    }

    @Test(arguments: [
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
    ])
    func coreValidatorPropertyShapeValidationMatrixSubset(shapes: String, data: String, conforms: Bool) throws {
        #expect(try validate(shapes, data).conforms == conforms)
    }

    @Test func coreValidatorEmitsCompleteMachineReadableDiagnostics() throws {
        let report = try validate("logicalOrShapes.ttl", "logicalOrInvalid.ttl")
        let result = try #require(report.results.first)
        #expect(result.sourceShape.id == term("ex:RoleShape"))
        #expect(result.focusNode == term("ex:alice"))
        #expect(result.resultPath == predicate("ex:role"))
        #expect(result.value == term("ex:r1"))
        #expect(result.sourceConstraintComponent === SHACL.OrConstraintComponent)
        #expect(result.severity === SHACL.Violation)
    }

    @Test func coreValidatorIsDeterministicAcrossRepeatedRuns() throws {
        let shapes = try Fixtures.shapes("logicalAndShapes.ttl")
        let data = try Fixtures.graph("logicalAndInvalid.ttl")
        let first = try SHACLValidator().validate(data, against: shapes)
        let second = try SHACLValidator().validate(data, against: shapes)
        #expect(first == second)
    }
}
