import IRIKit
import RDFCore
import RDFKit
import Testing
@testable import SHACLKit

@Suite("Decoding a shapes graph", .tags(.shapesGraph))
struct ShapesGraphTests {
    @Test func shapesLoaderParsesNodeShapeTargets() throws {
        let graph = try Fixtures.shapes("basicTargets.ttl")

        #expect(graph.shapes.count == 1)
        let shape = try #require(graph.shapes.first)
        #expect(shape.id == term("ex:PersonShape"))
        #expect(!shape.isPropertyShape)

        let targets = Set(shape.targets)
        #expect(targets.contains(.class(term("ex:Person"))))
        #expect(targets.contains(.node(term("ex:alice"))))
        #expect(targets.contains(.subjectsOf("http://example.com/knows")))
        #expect(targets.contains(.objectsOf("http://example.com/memberOf")))
    }

    @Test func shapesLoaderParsesMultipleShapesAndObjectLists() throws {
        let graph = try Fixtures.shapes("multiTargets.ttl")

        #expect(graph.shapes.count == 2)

        let thingShape = try #require(graph.shape(term("ex:ThingShape")))
        #expect(!thingShape.isPropertyShape)
        #expect(Set(thingShape.targets) == [.class(term("ex:Person")), .class(term("ex:Agent"))])

        let propertyShape = try #require(graph.shape(term("ex:NamePropShape")))
        #expect(propertyShape.isPropertyShape)
        #expect(propertyShape.path == predicate("ex:name"))
        #expect(Set(propertyShape.targets).contains(.node(term("ex:alice"))))
    }

    @Test func shapesLoaderParsesTargetNodeExpressionSelectors() throws {
        let graph = try Fixtures.shapes("targetNodeExpressionShapes.ttl")
        let shape = try #require(graph.shape(term("ex:ExprTargetShape")))
        #expect(shape.targets == [.nodeExpression(.union([.constant(term("ex:alice")), .constant(term("ex:bob"))]))])
    }

    @Test func shapesLoaderParsesTargetWhereSelectors() throws {
        let graph = try Fixtures.shapes("W3CDataShapes/shacl12-test-suite/tests/core/targets/targetWhere-001.ttl")
        let shape = try #require(graph.shape(.iri("http://example.com/ns#AdultShape")))
        let whereShapes = shape.targets.compactMap { target -> SHACLShape? in
            if case .where(let shape) = target { return shape }
            return nil
        }
        let whereShape = try #require(whereShapes.first)
        #expect(whereShape.id.isBlankNode)
        #expect(graph.shapes.contains(whereShape))
    }

    @Test func shapesLoaderParsesNodeExpressionDefinitions() throws {
        let graph = try Fixtures.shapes("nodeExpressionDefinitions.ttl")
        #expect(graph.expression(term("ex:ExprA")) == .union([.constant(term("ex:ConstA")), .focusNode]))
        #expect(graph.expression(term("ex:ExprB")) == .union([.focusNode, .constant(term("ex:ConstB"))]))
        #expect(graph.expression(term("ex:ExprInter")) == .intersection([
            .union([.constant(term("ex:ConstA")), .focusNode]),
            .union([.focusNode, .constant(term("ex:ConstB"))]),
        ]))
    }

    @Test func shapesLoaderParsesBooleanLiteralNodeExpressionMembers() throws {
        let graph = try Fixtures.shapes("nodeExpressionBooleanDefinitions.ttl")
        #expect(graph.expression(term("ex:ExprBool")) == .union([.constant(term("true")), .constant(term("false"))]))
    }

    @Test func shapesLoaderParsesTripleRules() throws {
        let graph = try Fixtures.shapes("ruleEvaluationShapes.ttl")
        let shape = try #require(graph.shape(term("ex:EmployeeRuleShape")))

        #expect(shape.rules.count == 2)
        let promoteRule = try #require(shape.rules.first { $0.node == term("ex:PromoteRule") })
        let issueBadgeRule = try #require(shape.rules.first { $0.node == term("ex:IssueBadgeRule") })
        #expect(promoteRule.subject == .focusNode)
        #expect(promoteRule.predicate == .constant(term("ex:status")))
        #expect(promoteRule.object == .constant(term("\"active\"")))
        #expect(promoteRule.conditions == [try #require(graph.shape(term("ex:AdultConditionShape")))])
        #expect(promoteRule.order == 1)
        #expect(issueBadgeRule.order == 2)
    }

    @Test func shapesLoaderParsesSPARQLDefinitions() throws {
        let query = try #require(Self.sparqlConstraints(in: "sparqlConstraintShapes.ttl").first)
        #expect(query.node == term("ex:NameConstraint"))
        #expect(query.select?.contains("SELECT ?this") == true)
    }

    @Test func shapesLoaderParsesSPARQLPrefixDeclarations() throws {
        let query = try #require(Self.sparqlConstraints(in: "sparqlConstraintWithPrefixesShapes.ttl").first)
        #expect(query.node == term("ex:NameConstraint"))
        #expect(query.prefixes["ex"] == "http://example.com/")
    }

    @Test func shapesLoaderParsesSPARQLDefaultPrefixDeclarations() throws {
        let query = try #require(Self.sparqlConstraints(in: "sparqlConstraintWithDefaultPrefixShapes.ttl").first)
        #expect(query.node == term("ex:NameConstraint"))
        #expect(query.prefixes[""] == "http://example.com/")
    }

    @Test("A shape refers to the shapes it names as the shape objects themselves")
    func shapeReferencesAreShapeObjects() throws {
        let graph = try Fixtures.shapes("ruleEvaluationShapes.ttl")
        let shape = try #require(graph.shape(term("ex:EmployeeRuleShape")))
        let badge = try #require(graph.shape(term("ex:BadgeRequiredShape")))
        let properties = shape.constraints.compactMap { constraint -> SHACLShape? in
            if case .property(let property) = constraint { return property }
            return nil
        }
        #expect(properties.count == 1)
        #expect(properties.first === badge)
    }

    @Test("Severities and constraint components decode into SHACL's individuals")
    func severitiesAreIndividuals() throws {
        let graph = try Fixtures.shapes("severityWarningShapes.ttl")
        let warning = try #require(graph.shapes.first { $0.severity === SHACL.Warning })
        #expect(warning.constraints.allSatisfy { !($0.component === SHACL.SPARQLConstraintComponent) })
    }

    private static func sparqlConstraints(in fixture: String) throws -> [SHACLSPARQLQuery] {
        try Fixtures.shapes(fixture).shapes.flatMap(\.constraints).compactMap { constraint in
            if case .sparql(let query) = constraint { return query }
            return nil
        }
    }
}
