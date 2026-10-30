import Foundation
import IRIKit
import RDFCore
import RDFKit

/// A constraint of a shape: one constraint component (SHACL 1.2 Core §4,
/// SHACL 1.2 SPARQL Extensions, SHACL 1.2 Node Expressions) with the values
/// a shape gives its parameters.
///
/// A shape declares a constraint for each value of a parameter, so
/// `sh:class ex:A, ex:B` is two ``class(_:)`` constraints. Shapes a
/// constraint names are the ``SHACLShape`` objects themselves.
public enum SHACLConstraint: Sendable {
    /// `sh:class` (§4.1.1).
    case `class`(ObjectTerm)
    /// `sh:datatype` (§4.1.2): a value node is a well-formed literal of
    /// one of the datatypes, as SHACL 1.2 allows a list of them.
    case datatype([IRI])
    /// `sh:nodeKind` (§4.1.3): a value node has one of the node kinds, as
    /// SHACL 1.2 allows a list of them.
    case nodeKind([any SHACL.NodeKind])
    /// `sh:minCount` (§4.2.1).
    case minCount(Int)
    /// `sh:maxCount` (§4.2.2).
    case maxCount(Int)
    /// `sh:minExclusive` (§4.3.1).
    case minExclusive(Literal)
    /// `sh:minInclusive` (§4.3.2).
    case minInclusive(Literal)
    /// `sh:maxExclusive` (§4.3.3).
    case maxExclusive(Literal)
    /// `sh:maxInclusive` (§4.3.4).
    case maxInclusive(Literal)
    /// `sh:minLength` (§4.4.1).
    case minLength(Int)
    /// `sh:maxLength` (§4.4.2).
    case maxLength(Int)
    /// `sh:pattern` with its `sh:flags` (§4.4.3).
    case pattern(NSRegularExpression)
    /// `sh:singleLine true`: no value node has a line break.
    case singleLine
    /// `sh:languageIn` (§4.4.4): the language ranges, in lower case.
    case languageIn([String])
    /// `sh:uniqueLang true` (§4.4.5).
    case uniqueLang
    /// `sh:equals` (§4.5.1).
    case equals(SHACLPropertyPath)
    /// `sh:disjoint` (§4.5.2).
    case disjoint(SHACLPropertyPath)
    /// `sh:lessThan` (§4.5.3).
    case lessThan(SHACLPropertyPath)
    /// `sh:lessThanOrEquals` (§4.5.4).
    case lessThanOrEquals(SHACLPropertyPath)
    /// `sh:not` (§4.6.1).
    case not(SHACLShape)
    /// `sh:and` (§4.6.2).
    case and([SHACLShape])
    /// `sh:or` (§4.6.3).
    case or([SHACLShape])
    /// `sh:xone` (§4.6.4).
    case xone([SHACLShape])
    /// `sh:node` (§4.7.1).
    case node(SHACLShape)
    /// `sh:property` (§4.7.2).
    case property(SHACLShape)
    /// `sh:qualifiedValueShape` with `sh:qualifiedMinCount`,
    /// `sh:qualifiedMaxCount` and, when `sh:qualifiedValueShapesDisjoint` is
    /// true, the sibling shapes a counted value node must not conform to
    /// (§4.7.3).
    case qualifiedValueShape(SHACLShape, min: Int?, max: Int?, siblings: [SHACLShape])
    /// `sh:someValue`: at least one value node conforms to the shape.
    case someValue(SHACLShape)
    /// `sh:closed true` (§4.8.1): the predicates a focus node may have, the
    /// predicate paths of the shape's property shapes and its
    /// `sh:ignoredProperties`.
    case closed(permitted: Set<IRI>)
    /// `sh:hasValue` (§4.8.2).
    case hasValue(ObjectTerm)
    /// `sh:in` (§4.8.3).
    case `in`([ObjectTerm])
    /// `sh:expression`: the node expression must give true for each value
    /// node; `node` is the expression's node, the result's
    /// `sh:sourceConstraint`.
    case expression(SHACLNodeExpression, node: ObjectTerm)
    /// `sh:nodeByExpression`: each value node conforms to each shape the
    /// expression outputs.
    case nodeByExpression(SHACLNodeExpression)
    /// `sh:reifierShape` and `sh:reificationRequired`: the reifiers of each
    /// value node's triple conform to the shape, and there is one when
    /// reification is required.
    case reifierShape(SHACLShape?, required: Bool)
    /// `sh:memberShape`: each value node is a SHACL list whose members
    /// conform to the shape.
    case memberShape(SHACLShape)
    /// `sh:minListLength`.
    case minListLength(Int)
    /// `sh:maxListLength`.
    case maxListLength(Int)
    /// `sh:uniqueMembers true`.
    case uniqueMembers
    /// `sh:sparql` (SHACL 1.2 SPARQL Extensions §5).
    case sparql(SHACLSPARQLQuery)

    /// The constraint component the constraint belongs to, which its
    /// results name as their `sh:sourceConstraintComponent`.
    public var component: any SHACL.ConstraintComponent {
        switch self {
        case .class: SHACL.ClassConstraintComponent
        case .datatype: SHACL.DatatypeConstraintComponent
        case .nodeKind: SHACL.NodeKindConstraintComponent
        case .minCount: SHACL.MinCountConstraintComponent
        case .maxCount: SHACL.MaxCountConstraintComponent
        case .minExclusive: SHACL.MinExclusiveConstraintComponent
        case .minInclusive: SHACL.MinInclusiveConstraintComponent
        case .maxExclusive: SHACL.MaxExclusiveConstraintComponent
        case .maxInclusive: SHACL.MaxInclusiveConstraintComponent
        case .minLength: SHACL.MinLengthConstraintComponent
        case .maxLength: SHACL.MaxLengthConstraintComponent
        case .pattern: SHACL.PatternConstraintComponent
        case .singleLine: SHACL.SingleLineConstraintComponent
        case .languageIn: SHACL.LanguageInConstraintComponent
        case .uniqueLang: SHACL.UniqueLangConstraintComponent
        case .equals: SHACL.EqualsConstraintComponent
        case .disjoint: SHACL.DisjointConstraintComponent
        case .lessThan: SHACL.LessThanConstraintComponent
        case .lessThanOrEquals: SHACL.LessThanOrEqualsConstraintComponent
        case .not: SHACL.NotConstraintComponent
        case .and: SHACL.AndConstraintComponent
        case .or: SHACL.OrConstraintComponent
        case .xone: SHACL.XoneConstraintComponent
        case .node: SHACL.NodeConstraintComponent
        case .property: SHACL.PropertyConstraintComponent
        case .qualifiedValueShape: SHACL.QualifiedMinCountConstraintComponent
        case .someValue: SHACL.SomeValueConstraintComponent
        case .closed: SHACL.ClosedConstraintComponent
        case .hasValue: SHACL.HasValueConstraintComponent
        case .in: SHACL.InConstraintComponent
        case .expression: SHACL.ExpressionConstraintComponent
        case .nodeByExpression: SHACL.NodeByExpressionConstraintComponent
        case .reifierShape: SHACL.ReifierShapeConstraintComponent
        case .memberShape: SHACL.MemberShapeConstraintComponent
        case .minListLength: SHACL.MinListLengthConstraintComponent
        case .maxListLength: SHACL.MaxListLengthConstraintComponent
        case .uniqueMembers: SHACL.UniqueMembersConstraintComponent
        case .sparql: SHACL.SPARQLConstraintComponent
        }
    }
}

extension SHACLConstraint {
    /// The parameters of the constraint components, which make the subject
    /// of a triple with one of them a shape (§2.1).
    static var parameters: Set<IRI> {
        [
            SHACL.path.metadata.id, SHACL.class.metadata.id, SHACL.datatype.metadata.id,
            SHACL.nodeKind.metadata.id, SHACL.minCount.metadata.id, SHACL.maxCount.metadata.id,
            SHACL.minExclusive.metadata.id, SHACL.minInclusive.metadata.id, SHACL.maxExclusive.metadata.id,
            SHACL.maxInclusive.metadata.id, SHACL.minLength.metadata.id, SHACL.maxLength.metadata.id,
            SHACL.pattern.metadata.id, SHACL.singleLine.metadata.id, SHACL.languageIn.metadata.id,
            SHACL.uniqueLang.metadata.id, SHACL.equals.metadata.id, SHACL.disjoint.metadata.id,
            SHACL.lessThan.metadata.id, SHACL.lessThanOrEquals.metadata.id, SHACL.not.metadata.id,
            SHACL.and.metadata.id, SHACL.or.metadata.id, SHACL.xone.metadata.id,
            SHACL.node.metadata.id, SHACL.property.metadata.id, SHACL.qualifiedValueShape.metadata.id,
            SHACL.someValue.metadata.id, SHACL.closed.metadata.id, SHACL.hasValue.metadata.id,
            SHACL.in.metadata.id, SHACL.expression.metadata.id, SHACL.nodeByExpression.metadata.id,
            SHACL.reifierShape.metadata.id, SHACL.reificationRequired.metadata.id, SHACL.memberShape.metadata.id,
            SHACL.minListLength.metadata.id, SHACL.maxListLength.metadata.id, SHACL.uniqueMembers.metadata.id,
            SHACL.rule.metadata.id, SHACL.sparql.metadata.id, SHACL.deactivated.metadata.id,
            SHACL.severity.metadata.id,
        ]
    }

    /// Decodes the constraints of the shape whose node is `node`.
    ///
    /// `expression` is the shape's `sh:expression` when it is a constraint,
    /// not the source of a property shape's value nodes.
    ///
    /// - Throws: ``SHACLError/invalidShapesGraph(_:)`` when a parameter's
    ///   value is ill-formed.
    static func constraints(
        of node: ObjectTerm,
        in nodes: SHACLShapesGraph.Nodes,
        isPropertyShape: Bool,
        expression: SHACLNodeExpression?
    ) throws -> [SHACLConstraint] {
        let graph = nodes.graph
        // A value whose triple a reifier deactivates is not a constraint
        // (SHACL 1.2 Core: sh:deactivated on a reified parameter triple).
        func values(_ parameter: IRI) -> [ObjectTerm] {
            graph.objects(of: node, parameter).filter { value in
                !graph.reifiers(of: node, parameter, value).contains { reifier in
                    graph.object(of: reifier, SHACL.deactivated.metadata.id)?.literal?.isTrue ?? false
                }
            }
        }
        func value(_ parameter: IRI) -> ObjectTerm? { graph.object(of: node, parameter) }
        func isTrue(_ parameter: IRI) -> Bool { value(parameter)?.literal?.isTrue ?? false }
        func integers(_ parameter: IRI) throws -> [Int] {
            try values(parameter).map { value in
                guard let integer = value.literal?.integerValue else {
                    throw SHACLError.invalidShapesGraph("Shape \(node) has a non-integer <\(parameter)> \(value)")
                }
                return integer
            }
        }
        func literals(_ parameter: IRI) throws -> [Literal] {
            try values(parameter).map { value in
                guard let literal = value.literal else {
                    throw SHACLError.invalidShapesGraph("Shape \(node) has a non-literal <\(parameter)> \(value)")
                }
                return literal
            }
        }
        func paths(_ parameter: IRI) throws -> [SHACLPropertyPath] {
            try values(parameter).map { value in
                guard let path = SHACLPropertyPath(value, in: graph) else {
                    throw SHACLError.invalidShapesGraph("Shape \(node) has an ill-formed <\(parameter)> \(value)")
                }
                return path
            }
        }
        func shapeLists(_ parameter: IRI) throws -> [[SHACLShape]] {
            try values(parameter).map { value in
                guard let members = graph.list(value) else {
                    throw SHACLError.invalidShapesGraph("Shape \(node) has a <\(parameter)> \(value) that is not a SHACL list")
                }
                return members.map(nodes.shape)
            }
        }

        var constraints: [SHACLConstraint] = []
        constraints += values(SHACL.class.metadata.id).map(SHACLConstraint.class)
        constraints += try values(SHACL.datatype.metadata.id).map { value in
            .datatype(try graph.listOrValue(value).map { datatype in
                guard let datatype = datatype.iri else {
                    throw SHACLError.invalidShapesGraph("Shape \(node) has a sh:datatype \(datatype) that is not an IRI")
                }
                return datatype
            })
        }
        constraints += try values(SHACL.nodeKind.metadata.id).map { value in
            .nodeKind(try graph.listOrValue(value).map { kind in
                guard let kind = SHACL.namedNodeKind(kind) else {
                    throw SHACLError.invalidShapesGraph("Shape \(node) has an unknown sh:nodeKind \(kind)")
                }
                return kind
            })
        }
        if isPropertyShape {
            constraints += try integers(SHACL.minCount.metadata.id).map(SHACLConstraint.minCount)
            constraints += try integers(SHACL.maxCount.metadata.id).map(SHACLConstraint.maxCount)
        }
        constraints += try literals(SHACL.minExclusive.metadata.id).map(SHACLConstraint.minExclusive)
        constraints += try literals(SHACL.minInclusive.metadata.id).map(SHACLConstraint.minInclusive)
        constraints += try literals(SHACL.maxExclusive.metadata.id).map(SHACLConstraint.maxExclusive)
        constraints += try literals(SHACL.maxInclusive.metadata.id).map(SHACLConstraint.maxInclusive)
        constraints += try integers(SHACL.minLength.metadata.id).map(SHACLConstraint.minLength)
        constraints += try integers(SHACL.maxLength.metadata.id).map(SHACLConstraint.maxLength)
        constraints += try patterns(of: node, in: graph).map(SHACLConstraint.pattern)
        if isTrue(SHACL.singleLine.metadata.id) { constraints.append(.singleLine) }
        constraints += values(SHACL.languageIn.metadata.id).map { list in
            .languageIn(graph.listOrValue(list).compactMap { $0.literal?.lexicalForm.lowercased() })
        }
        if isPropertyShape, isTrue(SHACL.uniqueLang.metadata.id) { constraints.append(.uniqueLang) }

        constraints += try paths(SHACL.equals.metadata.id).map(SHACLConstraint.equals)
        constraints += try paths(SHACL.disjoint.metadata.id).map(SHACLConstraint.disjoint)
        if isPropertyShape {
            constraints += try paths(SHACL.lessThan.metadata.id).map(SHACLConstraint.lessThan)
            constraints += try paths(SHACL.lessThanOrEquals.metadata.id).map(SHACLConstraint.lessThanOrEquals)
        }

        constraints += values(SHACL.not.metadata.id).map { .not(nodes.shape($0)) }
        constraints += try shapeLists(SHACL.and.metadata.id).map(SHACLConstraint.and)
        constraints += try shapeLists(SHACL.or.metadata.id).map(SHACLConstraint.or)
        constraints += try shapeLists(SHACL.xone.metadata.id).map(SHACLConstraint.xone)
        constraints += values(SHACL.node.metadata.id).map { .node(nodes.shape($0)) }
        constraints += values(SHACL.property.metadata.id).map { .property(nodes.shape($0)) }

        if isPropertyShape {
            let qualifiedShapes = values(SHACL.qualifiedValueShape.metadata.id)
            if !qualifiedShapes.isEmpty {
                let minimum = try integers(SHACL.qualifiedMinCount.metadata.id).first
                let maximum = try integers(SHACL.qualifiedMaxCount.metadata.id).first
                let siblings = isTrue(SHACL.qualifiedValueShapesDisjoint.metadata.id)
                    ? siblingShapes(of: node, in: graph) : []
                constraints += qualifiedShapes.map { qualified in
                    .qualifiedValueShape(
                        nodes.shape(qualified),
                        min: minimum,
                        max: maximum,
                        siblings: siblings.filter { $0 != qualified }.map(nodes.shape)
                    )
                }
            }
            constraints += values(SHACL.someValue.metadata.id).map { .someValue(nodes.shape($0)) }
        }

        if isTrue(SHACL.closed.metadata.id) {
            var permitted = Set(graph.objects(of: node, SHACL.property.metadata.id).compactMap { property in
                graph.object(of: property, SHACL.path.metadata.id)?.iri
            })
            for list in values(SHACL.ignoredProperties.metadata.id) {
                permitted.formUnion(graph.listOrValue(list).compactMap(\.iri))
            }
            constraints.append(.closed(permitted: permitted))
        }
        constraints += values(SHACL.hasValue.metadata.id).map(SHACLConstraint.hasValue)
        constraints += try values(SHACL.in.metadata.id).map { list in
            guard let members = graph.list(list) else {
                throw SHACLError.invalidShapesGraph("Shape \(node) has a sh:in \(list) that is not a SHACL list")
            }
            return .in(members)
        }

        if let expression, let expressionNode = value(SHACL.expression.metadata.id) {
            constraints.append(.expression(expression, node: expressionNode))
        }
        constraints += values(SHACL.nodeByExpression.metadata.id).map {
            .nodeByExpression(SHACLNodeExpression($0, in: nodes))
        }

        if isPropertyShape {
            let reifierShape = value(SHACL.reifierShape.metadata.id).map(nodes.shape)
            let required = isTrue(SHACL.reificationRequired.metadata.id)
            if reifierShape != nil || required {
                constraints.append(.reifierShape(reifierShape, required: required))
            }
        }
        do {
            constraints += values(SHACL.memberShape.metadata.id).map { .memberShape(nodes.shape($0)) }
            constraints += try integers(SHACL.minListLength.metadata.id).map(SHACLConstraint.minListLength)
            constraints += try integers(SHACL.maxListLength.metadata.id).map(SHACLConstraint.maxListLength)
            if isTrue(SHACL.uniqueMembers.metadata.id) { constraints.append(.uniqueMembers) }
        }

        for constraint in values(SHACL.sparql.metadata.id).flatMap(graph.listOrValue) {
            let query = SHACLSPARQLQuery(constraint, in: graph)
            guard query.select != nil || query.ask != nil else {
                throw SHACLError.invalidShapesGraph("SPARQL constraint \(constraint) is missing sh:select/sh:ask")
            }
            if !query.isDeactivated { constraints.append(.sparql(query)) }
        }
        return constraints
    }

    /// `sh:pattern` with `sh:flags` (§4.4.3): the regular expressions of
    /// SPARQL's `REGEX` function, with its flags `i`, `m`, `s` and `x`.
    private static func patterns(of node: ObjectTerm, in graph: Graph) throws -> [NSRegularExpression] {
        var options: NSRegularExpression.Options = []
        for flag in graph.object(of: node, SHACL.flags.metadata.id)?.stringValue ?? "" {
            switch flag {
            case "i": options.insert(.caseInsensitive)
            case "m": options.insert(.anchorsMatchLines)
            case "s": options.insert(.dotMatchesLineSeparators)
            case "x": options.insert(.allowCommentsAndWhitespace)
            default: break
            }
        }
        return try graph.objects(of: node, SHACL.pattern.metadata.id).map { value in
            guard let pattern = value.stringValue, let expression = try? NSRegularExpression(pattern: pattern, options: options) else {
                throw SHACLError.invalidShapesGraph("Shape \(node) has an ill-formed sh:pattern \(value)")
            }
            return expression
        }
    }

    /// The sibling shapes of a property shape (§4.7.3): the values of
    /// `sh:qualifiedValueShape` of the property shapes that a shape with
    /// `node` as a value of `sh:property` also has as values of
    /// `sh:property`.
    private static func siblingShapes(of node: ObjectTerm, in graph: Graph) -> [ObjectTerm] {
        let property = SHACL.property.metadata.id
        let qualifiedValueShape = SHACL.qualifiedValueShape.metadata.id
        return graph.subjects(property, node)
            .flatMap { graph.objects(of: $0, property) }
            .flatMap { graph.objects(of: $0, qualifiedValueShape) }
            .uniqued()
    }
}
