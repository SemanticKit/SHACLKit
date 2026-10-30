import IRIKit
import RDFCore
import RDFKit
import Testing
import SHACL
import struct RDFCore.Literal
import struct RDFCore.Graph
@testable import SHACLKit

@Suite("SPARQL-based constraints and targets", .tags(.sparql))
struct SPARQLTests {
    private func validate(_ shapes: String, _ data: String = "sparqlData.ttl", executor: any SHACLSPARQLExecutor = SHACLDeniedSPARQLExecutor()) throws -> SHACLValidationReport {
        try Fixtures.validate(shapes: shapes, data: data, with: SHACLValidator(sparqlExecutor: executor))
    }

    /// An executor whose `SELECT` query finds `ex:alice` as `$this` when it
    /// is pre-bound to `ex:alice`.
    private func aliceSelect(_ query: String) -> TestSPARQLExecutor {
        TestSPARQLExecutor(selectResults: [TestSPARQLExecutor.key(query, this: term("ex:alice")): [["this": term("ex:alice")]]])
    }

    /// An executor whose SPARQL-based target query, run with nothing
    /// pre-bound, finds `ex:alice`.
    private func aliceTarget(_ query: String) -> TestSPARQLExecutor {
        TestSPARQLExecutor(selectResults: [TestSPARQLExecutor.key(query): [["this": term("ex:alice")]]])
    }

    /// An executor whose property shape `SELECT` query finds the empty name
    /// of `focus` as `?value`.
    private func emptyValue(_ query: String, focus: String = "ex:alice") -> TestSPARQLExecutor {
        TestSPARQLExecutor(selectResults: [TestSPARQLExecutor.key(query, this: term(focus)): [["this": term(focus), "value": term("\"\"")]]])
    }

    @Test func coreValidatorThrowsWithoutSandboxedSPARQLExecutor() throws {
        #expect(throws: SHACLError.self) { try validate("sparqlConstraintShapes.ttl") }
    }

    @Test func coreValidatorThrowsWithoutSandboxedSPARQLExecutorForAskConstraint() throws {
        #expect(throws: SHACLError.self) { try validate("sparqlAskConstraintShapes.ttl", "sparqlAskData.ttl") }
    }

    @Test func coreValidatorExecutesSPARQLSelectConstraintThroughExecutorBoundary() throws {
        let report = try validate("sparqlConstraintShapes.ttl", executor: aliceSelect("SELECT ?this WHERE { ?this ex:name ?name . FILTER(strlen(str(?name)) = 0) }"))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        let result = try #require(report.results.first)
        #expect(result.focusNode == term("ex:alice"))
        #expect(result.value == term("ex:alice"))
        #expect(result.sourceConstraintComponent === SHACL.SPARQLConstraintComponent)
        #expect(result.sourceConstraint == term("ex:NameConstraint"))
    }

    @Test func coreValidatorExecutesSPARQLSelectConstraintWithDollarThisVariable() throws {
        let report = try validate("sparqlConstraintDollarThisShapes.ttl", executor: aliceSelect("SELECT $this WHERE { $this ex:name ?name . FILTER(strlen(str(?name)) = 0) }"))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
    }

    @Test func coreValidatorAcceptsSPARQLConstraintWithPrefixesDeclaration() throws {
        let report = try validate("sparqlConstraintWithPrefixesShapes.ttl", executor: aliceSelect("PREFIX ex: <http://example.com/>\nSELECT ?this WHERE { ?this ex:name ?name . FILTER(strlen(str(?name)) = 0) }"))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
    }

    @Test func coreValidatorDoesNotDuplicateInlineSPARQLPrefixDeclarations() throws {
        let report = try validate("sparqlConstraintWithInlinePrefixShapes.ttl", executor: aliceSelect("PREFIX ex: <http://example.com/> SELECT ?this WHERE { ?this ex:name ?name . FILTER(strlen(str(?name)) = 0) }"))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
    }

    @Test func coreValidatorInjectsSPARQLPrefixesInDeterministicSortedOrder() throws {
        let query = "PREFIX ex: <http://example.com/>\nPREFIX zzz: <http://example.com/z#>\nSELECT ?this WHERE { ?this ex:name ?name . FILTER(strlen(str(?name)) = 0) }"
        let report = try validate("sparqlConstraintWithMultiplePrefixesShapes.ttl", executor: aliceSelect(query))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
    }

    @Test func coreValidatorInjectsSPARQLPrefixesWhenLiteralContainsPrefixMarker() throws {
        let report = try validate("sparqlConstraintWithPrefixMarkerLiteralShapes.ttl", executor: PrefixMarkerLiteralSPARQLExecutor())
        #expect(!report.conforms)
        #expect(report.results.count == 1)
    }

    @Test func coreValidatorAppliesDefaultSPARQLPrefixForConstraintQueries() throws {
        let query = "PREFIX : <http://example.com/>\nSELECT ?this WHERE { ?this :name ?name . FILTER(strlen(str(?name)) = 0) }"
        let report = try validate("sparqlConstraintWithDefaultPrefixShapes.ttl", executor: aliceSelect(query))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
    }

    @Test func coreValidatorDoesNotDuplicateInlineDefaultSPARQLPrefixDeclarations() throws {
        let query = "PREFIX : <http://example.com/> SELECT ?this WHERE { ?this :name ?name . FILTER(strlen(str(?name)) = 0) }"
        let report = try validate("sparqlConstraintWithInlineDefaultPrefixShapes.ttl", executor: aliceSelect(query))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
    }

    @Test func coreValidatorAppliesDefaultSPARQLPrefixForTargetQueries() throws {
        let report = try validate("sparqlTargetWithDefaultPrefixShapes.ttl", executor: aliceTarget("PREFIX : <http://example.com/>\nSELECT ?this WHERE { ?this :segment :vip }"))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        let result = try #require(report.results.first)
        #expect(result.focusNode == term("ex:alice"))
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorDoesNotDuplicateInlineDefaultSPARQLPrefixTargetQueries() throws {
        let report = try validate("sparqlTargetWithInlineDefaultPrefixShapes.ttl", executor: aliceTarget("PREFIX : <http://example.com/> SELECT ?this WHERE { ?this :segment :vip }"))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
    }

    @Test func coreValidatorUsesSPARQLMessageForNodeShapeConstraintViolation() throws {
        let report = try validate("sparqlConstraintMessageShapes.ttl", executor: aliceSelect("SELECT ?this WHERE { ?this ex:name ?name . FILTER(strlen(str(?name)) = 0) }"))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        #expect(report.results.first?.message == "Name must not be empty")
    }

    @Test func coreValidatorExecutesSPARQLAskConstraintThroughExecutorBoundary() throws {
        let query = "ASK WHERE { ?this ex:active true }"
        let executor = TestSPARQLExecutor(askResults: [
            TestSPARQLExecutor.key(query, this: term("ex:alice")): true,
            TestSPARQLExecutor.key(query, this: term("ex:bob")): false,
        ])
        let report = try validate("sparqlAskConstraintShapes.ttl", "sparqlAskData.ttl", executor: executor)
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        let result = try #require(report.results.first)
        #expect(result.focusNode == term("ex:bob"))
        #expect(result.sourceConstraint == term("ex:ActiveConstraint"))
    }

    @Test func coreValidatorExecutesSPARQLTargetThroughExecutorBoundary() throws {
        let report = try validate("sparqlTargetShapes.ttl", executor: aliceTarget("SELECT ?this WHERE { ?this ex:segment ex:vip }"))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        let result = try #require(report.results.first)
        #expect(result.focusNode == term("ex:alice"))
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorAppliesSPARQLPrefixesForTargetQueries() throws {
        let report = try validate("sparqlTargetWithPrefixesShapes.ttl", executor: aliceTarget("PREFIX ex: <http://example.com/>\nSELECT ?this WHERE { ?this ex:segment ex:vip }"))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        let result = try #require(report.results.first)
        #expect(result.focusNode == term("ex:alice"))
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorExecutesTargetNodeSelectThroughExecutorBoundary() throws {
        let report = try validate("sparqlTargetNodeSelectShapes.ttl", executor: aliceTarget("SELECT ?this WHERE { ?this ex:segment ex:vip }"))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        let result = try #require(report.results.first)
        #expect(result.sourceShape.id == term("ex:StatusShape"))
        #expect(result.focusNode == term("ex:alice"))
        #expect(result.resultPath == predicate("ex:status"))
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorExecutesPropertyShapeSPARQLConstraintThroughExecutorBoundary() throws {
        let report = try validate("sparqlPropertyConstraintShapes.ttl", executor: emptyValue("SELECT $this ?value WHERE { $this <http://example.com/name> ?value . FILTER(strlen(str(?value)) = 0) }"))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        let result = try #require(report.results.first)
        #expect(result.sourceShape.id == term("ex:NamePropertyShape"))
        #expect(result.focusNode == term("ex:alice"))
        #expect(result.resultPath == predicate("ex:name"))
        #expect(result.value == term("\"\""))
        #expect(result.sourceConstraint == term("ex:NonEmptyNameConstraint"))
    }

    @Test func coreValidatorUsesSPARQLMessageForPropertyShapeConstraintViolation() throws {
        let report = try validate("sparqlPropertyConstraintMessageShapes.ttl", executor: emptyValue("SELECT $this ?value WHERE { $this <http://example.com/name> ?value . FILTER(strlen(str(?value)) = 0) }"))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        #expect(report.results.first?.message == "Property name must not be empty")
    }

    @Test func coreValidatorExecutesDirectPropertyShapeSPARQLConstraintThroughExecutorBoundary() throws {
        let report = try validate("sparqlPropertyShapeDirectTargetShapes.ttl", executor: emptyValue("SELECT $this ?value WHERE { $this <http://example.com/name> ?value . FILTER(strlen(str(?value)) = 0) }"))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        let result = try #require(report.results.first)
        #expect(result.sourceShape.id == term("ex:NamePropertyShape"))
        #expect(result.focusNode == term("ex:alice"))
        #expect(result.resultPath == predicate("ex:name"))
        #expect(result.sourceConstraint == term("ex:NonEmptyNameConstraint"))
    }

    @Test func coreValidatorExecutesNestedPropertyShapeSPARQLConstraintThroughExecutorBoundary() throws {
        let report = try validate(
            "sparqlNestedPropertyConstraintShapes.ttl",
            "sparqlNestedPropertyConstraintData.ttl",
            executor: emptyValue("SELECT $this ?value WHERE { $this <http://example.com/zip> ?value . FILTER(strlen(str(?value)) = 0) }", focus: "ex:addr1")
        )
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        let result = try #require(report.results.first)
        #expect(result.sourceShape.id == term("ex:ZipShape"))
        #expect(result.focusNode == term("ex:addr1"))
        #expect(result.resultPath == predicate("ex:zip"))
        #expect(result.sourceConstraint == term("ex:ZipConstraint"))
    }

    @Test func coreValidatorExecutesDirectPropertyShapeSPARQLTargetThroughExecutorBoundary() throws {
        let report = try validate("sparqlPropertyShapeTargetShapes.ttl", executor: aliceTarget("SELECT ?this WHERE { ?this ex:segment ex:vip }"))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        let result = try #require(report.results.first)
        #expect(result.sourceShape.id == term("ex:StatusPropertyShape"))
        #expect(result.focusNode == term("ex:alice"))
        #expect(result.resultPath == predicate("ex:status"))
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorExecutesPropertyShapeTargetNodeSelectThroughExecutorBoundary() throws {
        let report = try validate("sparqlPropertyTargetNodeSelectShapes.ttl", executor: aliceTarget("SELECT ?this WHERE { ?this ex:segment ex:vip }"))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
        let result = try #require(report.results.first)
        #expect(result.sourceShape.id == term("ex:StatusPropertyShape"))
        #expect(result.focusNode == term("ex:alice"))
        #expect(result.resultPath == predicate("ex:status"))
        #expect(result.sourceConstraintComponent === SHACL.HasValueConstraintComponent)
    }

    @Test func coreValidatorSkipsSPARQLConstraintsForDeactivatedNodeShape() throws {
        let report = try validate("sparqlDeactivatedNodeShapes.ttl", executor: aliceSelect("SELECT ?this WHERE { ?this ex:name ?name . FILTER(strlen(str(?name)) = 0) }"))
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorSkipsSPARQLConstraintsForDeactivatedPropertyShape() throws {
        let report = try validate("sparqlDeactivatedPropertyShapes.ttl", executor: emptyValue("SELECT $this ?value WHERE { $this <http://example.com/name> ?value . FILTER(strlen(str(?value)) = 0) }"))
        #expect(report.conforms)
        #expect(report.results.isEmpty)
    }

    @Test func coreValidatorBlocksGuardedSPARQLConstraintByKeywordPolicy() throws {
        let executor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
        #expect(throws: SHACLError.self) { try validate("sparqlGuardBlockedShapes.ttl", executor: executor) }
    }

    @Test func coreValidatorBlocksGuardedSPARQLConstraintByMinusKeywordPolicy() throws {
        let executor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
        #expect(throws: SHACLError.self) { try validate("sparqlGuardBlockedMinusShapes.ttl", executor: executor) }
    }

    @Test func coreValidatorBlocksGuardedSPARQLConstraintByValuesKeywordPolicy() throws {
        let executor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
        #expect(throws: SHACLError.self) { try validate("sparqlGuardBlockedValuesShapes.ttl", executor: executor) }
    }

    @Test func coreValidatorBlocksGuardedSPARQLConstraintByPreboundThisPolicy() throws {
        let executor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
        #expect(throws: SHACLError.self) { try validate("sparqlGuardBlockedPreboundThisShapes.ttl", executor: executor) }
    }

    @Test func coreValidatorBlocksGuardedSPARQLConstraintByPreboundDollarThisPolicy() throws {
        let executor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
        #expect(throws: SHACLError.self) { try validate("sparqlGuardBlockedPreboundDollarThisShapes.ttl", executor: executor) }
    }

    @Test func coreValidatorBlocksGuardedSPARQLConstraintByPreboundPathPolicy() throws {
        let executor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
        #expect(throws: SHACLError.self) { try validate("sparqlGuardBlockedPreboundPathShapes.ttl", executor: executor) }
    }

    @Test func coreValidatorBlocksGuardedSPARQLConstraintByPreboundDollarPathPolicy() throws {
        let executor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
        #expect(throws: SHACLError.self) { try validate("sparqlGuardBlockedPreboundDollarPathShapes.ttl", executor: executor) }
    }

    @Test func coreValidatorBlocksGuardedSPARQLConstraintByPreboundValuePolicy() throws {
        let executor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
        #expect(throws: SHACLError.self) { try validate("sparqlGuardBlockedPreboundValueShapes.ttl", executor: executor) }
    }

    @Test func coreValidatorBlocksGuardedSPARQLConstraintByPreboundDollarValuePolicy() throws {
        let executor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
        #expect(throws: SHACLError.self) { try validate("sparqlGuardBlockedPreboundDollarValueShapes.ttl", executor: executor) }
    }

    @Test func coreValidatorBlocksGuardedSPARQLConstraintWithoutThisReference() throws {
        let executor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
        #expect(throws: SHACLError.self) { try validate("sparqlGuardMissingThisReferenceShapes.ttl", executor: executor) }
    }

    @Test func coreValidatorBlocksGuardedSPARQLConstraintWhenThisAppearsOnlyInStringLiteral() throws {
        let executor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
        #expect(throws: SHACLError.self) { try validate("sparqlGuardLiteralThisOnlyShapes.ttl", executor: executor) }
    }

    @Test func coreValidatorBlocksGuardedSPARQLConstraintWhenThisAppearsOnlyInComment() throws {
        let executor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor())
        #expect(throws: SHACLError.self) { try validate("sparqlGuardCommentThisOnlyShapes.ttl", executor: executor) }
    }

    @Test func coreValidatorAllowsGuardedSPARQLAskConstraintWithoutThisReference() throws {
        let report = try validate(
            "sparqlGuardAskMissingThisReferenceShapes.ttl",
            "sparqlAskData.ttl",
            executor: SHACLGuardedSPARQLExecutor(wrapping: AlwaysFalseAskSPARQLExecutor())
        )
        #expect(!report.conforms)
        #expect(report.results.count == 2)
    }

    @Test func coreValidatorBlocksGuardedSPARQLConstraintByLengthPolicy() throws {
        let executor = SHACLGuardedSPARQLExecutor(wrapping: TestSPARQLExecutor(), disallowedKeywords: [], maxQueryLength: 16)
        #expect(throws: SHACLError.self) { try validate("sparqlConstraintShapes.ttl", executor: executor) }
    }

    @Test func coreValidatorAllowsGuardedSPARQLConstraintWhenPolicyAllowsQuery() throws {
        let executor = SHACLGuardedSPARQLExecutor(wrapping: aliceSelect("SELECT ?this WHERE { ?this ex:name ?name . FILTER(strlen(str(?name)) = 0) }"), disallowedKeywords: ["SERVICE"], maxQueryLength: 512)
        let report = try validate("sparqlConstraintShapes.ttl", executor: executor)
        #expect(!report.conforms)
        #expect(report.results.count == 1)
    }

    @Test func coreValidatorAllowsGuardedSPARQLConstraintWithDollarThisReference() throws {
        let query = "SELECT $this WHERE { $this ex:name ?name . FILTER(strlen(str(?name)) = 0) }"
        let executor = SHACLGuardedSPARQLExecutor(wrapping: aliceSelect(query), disallowedKeywords: ["SERVICE"], maxQueryLength: 512)
        let report = try validate("sparqlConstraintDollarThisShapes.ttl", executor: executor)
        #expect(!report.conforms)
        #expect(report.results.count == 1)
    }

    @Test func coreValidatorAllowsGuardedSPARQLConstraintWhenKeywordOnlyAppearsInStringLiteral() throws {
        let report = try validate("sparqlGuardAllowsKeywordLiteralShapes.ttl", executor: SHACLGuardedSPARQLExecutor(wrapping: GuardLiteralKeywordSPARQLExecutor()))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
    }

    @Test func coreValidatorAllowsGuardedSPARQLConstraintWhenKeywordOnlyAppearsInComment() throws {
        let report = try validate("sparqlGuardAllowsKeywordCommentShapes.ttl", executor: SHACLGuardedSPARQLExecutor(wrapping: GuardLiteralKeywordSPARQLExecutor()))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
    }

    @Test func coreValidatorAllowsGuardedSPARQLConstraintWhenPathOnlyAppearsInStringLiteral() throws {
        let report = try validate("sparqlGuardAllowsPathLiteralShapes.ttl", executor: SHACLGuardedSPARQLExecutor(wrapping: GuardLiteralKeywordSPARQLExecutor()))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
    }

    @Test func coreValidatorAllowsGuardedSPARQLConstraintWhenPathRebindOnlyAppearsInComment() throws {
        let report = try validate("sparqlGuardAllowsPathCommentShapes.ttl", executor: SHACLGuardedSPARQLExecutor(wrapping: GuardLiteralKeywordSPARQLExecutor()))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
    }

    @Test func coreValidatorAllowsGuardedSPARQLConstraintWhenDollarPathRebindOnlyAppearsInComment() throws {
        let report = try validate("sparqlGuardAllowsDollarPathCommentShapes.ttl", executor: SHACLGuardedSPARQLExecutor(wrapping: GuardLiteralKeywordSPARQLExecutor()))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
    }

    @Test func coreValidatorAllowsGuardedSPARQLConstraintWhenValueOnlyAppearsInStringLiteral() throws {
        let report = try validate("sparqlGuardAllowsValueLiteralShapes.ttl", executor: SHACLGuardedSPARQLExecutor(wrapping: GuardLiteralKeywordSPARQLExecutor()))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
    }

    @Test func coreValidatorAllowsGuardedSPARQLConstraintWhenValueRebindOnlyAppearsInComment() throws {
        let report = try validate("sparqlGuardAllowsValueCommentShapes.ttl", executor: SHACLGuardedSPARQLExecutor(wrapping: GuardLiteralKeywordSPARQLExecutor()))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
    }

    @Test func coreValidatorAllowsGuardedSPARQLConstraintWhenDollarValueRebindOnlyAppearsInComment() throws {
        let report = try validate("sparqlGuardAllowsDollarValueCommentShapes.ttl", executor: SHACLGuardedSPARQLExecutor(wrapping: GuardLiteralKeywordSPARQLExecutor()))
        #expect(!report.conforms)
        #expect(report.results.count == 1)
    }

    @Test func propertyShapeQueriesHaveTheirPathSubstituted() throws {
        let shapes = try Fixtures.shapes("sparqlPropertyConstraintShapes.ttl")
        let shape = try #require(shapes.shape(term("ex:NamePropertyShape")))
        let query = try #require(shape.constraints.compactMap { constraint -> SHACLSPARQLQuery? in
            if case .sparql(let query) = constraint { return query }
            return nil
        }.first)
        #expect(query.text(of: try #require(query.select), path: shape.path).contains("$this <http://example.com/name> ?value"))
    }
}
