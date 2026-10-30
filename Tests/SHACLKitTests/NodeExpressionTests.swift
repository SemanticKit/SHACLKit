import IRIKit
import RDFCore
import RDFKit
import Testing
@testable import SHACLKit

@Suite("Evaluating node expressions", .tags(.nodeExpression))
struct NodeExpressionTests {
    /// The output of the node expression `expression` names in the shapes
    /// graph of `fixture`, for `focus`, over the fixture itself as data
    /// graph when `withData`, otherwise over an empty data graph.
    private func output(
        _ fixture: String,
        _ expression: String,
        focus: String = "ex:focus",
        variables: [String: Set<String>] = [:],
        withData: Bool = false
    ) throws -> Set<ObjectTerm> {
        let graph = try Fixtures.graph(fixture)
        let shapes = try SHACLShapesGraph(graph)
        return Set(try shapes.expression(term(expression)).evaluate(
            focusNode: term(focus),
            dataGraph: withData ? graph : [],
            shapesGraph: shapes,
            variables: variables.mapValues { $0.map(term) }
        ))
    }

    @Test func nodeExpressionEvaluatorEvaluatesUnionIntersectionAndCycle() throws {
        let fixture = "nodeExpressionDefinitions.ttl"
        #expect(try output(fixture, "ex:ExprA") == terms("ex:ConstA", "ex:focus"))
        #expect(try output(fixture, "ex:ExprInter") == terms("ex:focus"))
        #expect(try output(fixture, "ex:ExprNested") == terms("ex:focus", "ex:ConstC"))
        #expect(try output(fixture, "ex:ExprCycle") == terms("ex:ConstD"))
    }

    @Test func nodeExpressionEvaluatorEvaluatesNodesAndExists() throws {
        let fixture = "nodeExpressionExistsDefinitions.ttl"
        #expect(try output(fixture, "ex:ConstNodes") == terms("ex:a", "42"))
        #expect(try output(fixture, "ex:ExistsTrue") == terms("true"))
        #expect(try output(fixture, "ex:ExistsFalse") == terms("false"))
        #expect(try output(fixture, "ex:ExistsFalseAnonymous") == terms("false"))
    }

    @Test func nodeExpressionEvaluatorEvaluatesIfThenElse() throws {
        let fixture = "nodeExpressionIfDefinitions.ttl"
        #expect(try output(fixture, "ex:IfTrue") == terms("42"))
        #expect(try output(fixture, "ex:IfFalseWithElse") == terms("\"no\""))
        #expect(try output(fixture, "ex:IfFalseNoElse").isEmpty)
        #expect(try output(fixture, "ex:IfNested") == terms("ex:thenResult"))
    }

    @Test func nodeExpressionEvaluatorEvaluatesCount() throws {
        let fixture = "nodeExpressionCountDefinitions.ttl"
        #expect(try output(fixture, "ex:CountEmpty") == terms("0"))
        #expect(try output(fixture, "ex:CountListThree") == terms("3"))
        #expect(try output(fixture, "ex:CountNodesTwo") == terms("2"))
    }

    @Test func nodeExpressionEvaluatorEvaluatesDistinct() throws {
        let fixture = "nodeExpressionDistinctDefinitions.ttl"
        #expect(try output(fixture, "ex:DistinctList") == terms("4", "2"))
        #expect(try output(fixture, "ex:DistinctTermEquality") == terms("4", "2", "\"04\"^^xsd:integer"))
        #expect(try output(fixture, "ex:DistinctNodes") == terms("ex:a", "ex:b"))
    }

    @Test func nodeExpressionEvaluatorEvaluatesVar() throws {
        let fixture = "nodeExpressionVarDefinitions.ttl"
        #expect(try output(fixture, "ex:VarFocusNode", focus: "ex:Aldi") == terms("ex:Aldi"))
        #expect(try output(fixture, "ex:VarBound", focus: "ex:Aldi", variables: ["bound": ["4.2"]]) == terms("4.2"))
        #expect(try output(fixture, "ex:VarUnbound", focus: "ex:Aldi").isEmpty)
        #expect(try output(fixture, "ex:DistinctFocusNode", focus: "ex:Aldi") == terms("ex:Aldi"))
    }

    @Test func nodeExpressionEvaluatorEvaluatesInstancesOf() throws {
        let fixture = "nodeExpressionInstancesOfDefinitions.ttl"
        #expect(try output(fixture, "ex:OrganizationsExpr", withData: true) == terms("ex:Org1", "ex:Company1", "ex:Company2"))
        #expect(try output(fixture, "ex:CompaniesExpr", withData: true) == terms("ex:Company1", "ex:Company2"))
    }

    @Test func nodeExpressionEvaluatorEvaluatesNodesMatching() throws {
        let fixture = "nodeExpressionNodesMatchingDefinitions.ttl"
        #expect(try output(fixture, "ex:OrganizationsMatchingExpr", withData: true) == terms("ex:Org1", "ex:Company1", "ex:Company2"))
        #expect(try output(fixture, "ex:CompaniesMatchingExpr", withData: true) == terms("ex:Company1", "ex:Company2"))
    }

    @Test func nodeExpressionEvaluatorEvaluatesMatchAll() throws {
        let fixture = "nodeExpressionMatchAllDefinitions.ttl"
        #expect(try output(fixture, "ex:MatchAllEmpty", withData: true) == terms("true"))
        #expect(try output(fixture, "ex:MatchAllTrue", withData: true) == terms("true"))
        #expect(try output(fixture, "ex:MatchAllFalse", withData: true) == terms("false"))
    }

    @Test func nodeExpressionEvaluatorEvaluatesFilterShape() throws {
        let fixture = "nodeExpressionFilterShapeDefinitions.ttl"
        #expect(try output(fixture, "ex:FilterPeopleExpr", withData: true) == terms("ex:alice", "ex:bob"))
        #expect(try output(fixture, "ex:FilterUnconstrainedExpr", withData: true) == terms("ex:alice", "ex:bob", "ex:charlie"))
    }

    @Test func nodeExpressionEvaluatorEvaluatesConcatAndRemove() throws {
        let fixture = "nodeExpressionConcatRemoveDefinitions.ttl"
        #expect(try output(fixture, "ex:ConcatSimple", withData: true) == terms("ex:alice", "ex:bob", "false"))
        #expect(try output(fixture, "ex:RemoveSimple", withData: true) == terms("ex:alice", "ex:charlie"))
        #expect(try output(fixture, "ex:RemoveNested", withData: true) == terms("4", "2"))
    }

    @Test func nodeExpressionEvaluatorEvaluatesFlatMap() throws {
        let fixture = "nodeExpressionFlatMapDefinitions.ttl"
        #expect(try output(fixture, "ex:FlatMapIdentity", withData: true) == terms("ex:alice", "ex:bob", "ex:charlie"))
        #expect(try output(fixture, "ex:FlatMapSkills", withData: true)
            == terms("\"Java\"@en", "\"Python\"@en", "\"SQL\"@en", "\"JavaScript\"@en", "\"DevOps\"@en"))
    }

    @Test func nodeExpressionEvaluatorEvaluatesLimitAndOffset() throws {
        let fixture = "nodeExpressionLimitOffsetDefinitions.ttl"
        #expect(try output(fixture, "ex:LimitExpr") == terms("1", "2"))
        #expect(try output(fixture, "ex:OffsetExpr") == terms("3", "4"))
        #expect(try output(fixture, "ex:OffsetAfterLimitExpr") == terms("6"))
        #expect(try output(fixture, "ex:OffsetThenLimitFromConcatExpr") == terms("3"))
    }

    @Test func nodeExpressionEvaluatorEvaluatesFindFirst() throws {
        let fixture = "nodeExpressionFindFirstDefinitions.ttl"
        #expect(try output(fixture, "ex:FindFirstEmpty", withData: true).isEmpty)
        #expect(try output(fixture, "ex:FindFirstMinInclusive", withData: true) == terms("4"))
    }

    @Test func nodeExpressionEvaluatorEvaluatesOrderByAndDesc() throws {
        let fixture = "nodeExpressionOrderByDefinitions.ttl"
        #expect(try output(fixture, "ex:OrderByAscLimitExpr") == terms("2"))
        #expect(try output(fixture, "ex:OrderByDescLimitExpr") == terms("8"))
        #expect(try output(fixture, "ex:OrderByNumericLimitExpr") == terms("2"))
    }

    @Test func nodeExpressionEvaluatorEvaluatesOrderByPathValues() throws {
        let fixture = "nodeExpressionOrderByPathDefinitions.ttl"
        #expect(try output(fixture, "ex:OrderByBirthdayAscLimitExpr", withData: true) == terms("ex:Person1"))
        #expect(try output(fixture, "ex:OrderByBirthdayDescLimitExpr", withData: true) == terms("ex:Person2"))
        #expect(try output(fixture, "ex:OrderByHeightAscLimitExpr", withData: true) == terms("ex:Person3"))
    }

    @Test func nodeExpressionEvaluatorEvaluatesMinAndMax() throws {
        let fixture = "nodeExpressionMinMaxDefinitions.ttl"
        #expect(try output(fixture, "ex:MinEmpty").isEmpty)
        #expect(try output(fixture, "ex:MinList") == terms("3"))
        #expect(try output(fixture, "ex:MaxEmpty").isEmpty)
        #expect(try output(fixture, "ex:MaxList") == terms("5"))
        #expect(try output(fixture, "ex:MaxNodes") == terms("9"))
    }

    @Test func nodeExpressionEvaluatorEvaluatesSum() throws {
        let fixture = "nodeExpressionSumDefinitions.ttl"
        #expect(try output(fixture, "ex:SumEmpty") == terms("0"))
        #expect(try output(fixture, "ex:SumListIntegers") == terms("12"))
        #expect(try output(fixture, "ex:SumListMixed") == terms("12.1"))
        #expect(try output(fixture, "ex:SumNodes") == terms("42.0"))
    }
}
