import Foundation
import IRIKit
import RDFCore
import RDFFormats
import SHACL
import struct RDFCore.Literal
import struct RDFCore.Graph

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
            IRIKit.IRI(of: SHACL.path.self)!, IRIKit.IRI(of: SHACL.class.self)!, IRIKit.IRI(of: SHACL.datatype.self)!,
            IRIKit.IRI(of: SHACL.nodeKind.self)!, IRIKit.IRI(of: SHACL.minCount.self)!, IRIKit.IRI(of: SHACL.maxCount.self)!,
            IRIKit.IRI(of: SHACL.minExclusive.self)!, IRIKit.IRI(of: SHACL.minInclusive.self)!, IRIKit.IRI(of: SHACL.maxExclusive.self)!,
            IRIKit.IRI(of: SHACL.maxInclusive.self)!, IRIKit.IRI(of: SHACL.minLength.self)!, IRIKit.IRI(of: SHACL.maxLength.self)!,
            IRIKit.IRI(of: SHACL.pattern.self)!, IRIKit.IRI(of: SHACL.singleLine.self)!, IRIKit.IRI(of: SHACL.languageIn.self)!,
            IRIKit.IRI(of: SHACL.uniqueLang.self)!, IRIKit.IRI(of: SHACL.equals.self)!, IRIKit.IRI(of: SHACL.disjoint.self)!,
            IRIKit.IRI(of: SHACL.lessThan.self)!, IRIKit.IRI(of: SHACL.lessThanOrEquals.self)!, IRIKit.IRI(of: SHACL.not.self)!,
            IRIKit.IRI(of: SHACL.and.self)!, IRIKit.IRI(of: SHACL.or.self)!, IRIKit.IRI(of: SHACL.xone.self)!,
            IRIKit.IRI(of: SHACL.node.self)!, IRIKit.IRI(of: SHACL.property.self)!, IRIKit.IRI(of: SHACL.qualifiedValueShape.self)!,
            IRIKit.IRI(of: SHACL.someValue.self)!, IRIKit.IRI(of: SHACL.closed.self)!, IRIKit.IRI(of: SHACL.hasValue.self)!,
            IRIKit.IRI(of: SHACL.in.self)!, IRIKit.IRI(of: SHACL.expression.self)!, IRIKit.IRI(of: SHACL.nodeByExpression.self)!,
            IRIKit.IRI(of: SHACL.reifierShape.self)!, IRIKit.IRI(of: SHACL.reificationRequired.self)!, IRIKit.IRI(of: SHACL.memberShape.self)!,
            IRIKit.IRI(of: SHACL.minListLength.self)!, IRIKit.IRI(of: SHACL.maxListLength.self)!, IRIKit.IRI(of: SHACL.uniqueMembers.self)!,
            IRIKit.IRI(of: SHACL.rule.self)!, IRIKit.IRI(of: SHACL.sparql.self)!, IRIKit.IRI(of: SHACL.deactivated.self)!,
            IRIKit.IRI(of: SHACL.severity.self)!,
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
                    graph.object(of: reifier, IRIKit.IRI(of: SHACL.deactivated.self)!)?.literal?.isTrue ?? false
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
        constraints += values(IRIKit.IRI(of: SHACL.class.self)!).map(SHACLConstraint.class)
        constraints += try values(IRIKit.IRI(of: SHACL.datatype.self)!).map { value in
            .datatype(try graph.listOrValue(value).map { datatype in
                guard let datatype = datatype.iri else {
                    throw SHACLError.invalidShapesGraph("Shape \(node) has a sh:datatype \(datatype) that is not an IRI")
                }
                return datatype
            })
        }
        constraints += try values(IRIKit.IRI(of: SHACL.nodeKind.self)!).map { value in
            .nodeKind(try graph.listOrValue(value).map { kind in
                guard let kind = SHACL.NodeKindIndividual.named(kind) else {
                    throw SHACLError.invalidShapesGraph("Shape \(node) has an unknown sh:nodeKind \(kind)")
                }
                return kind
            })
        }
        if isPropertyShape {
            constraints += try integers(IRIKit.IRI(of: SHACL.minCount.self)!).map(SHACLConstraint.minCount)
            constraints += try integers(IRIKit.IRI(of: SHACL.maxCount.self)!).map(SHACLConstraint.maxCount)
        }
        constraints += try literals(IRIKit.IRI(of: SHACL.minExclusive.self)!).map(SHACLConstraint.minExclusive)
        constraints += try literals(IRIKit.IRI(of: SHACL.minInclusive.self)!).map(SHACLConstraint.minInclusive)
        constraints += try literals(IRIKit.IRI(of: SHACL.maxExclusive.self)!).map(SHACLConstraint.maxExclusive)
        constraints += try literals(IRIKit.IRI(of: SHACL.maxInclusive.self)!).map(SHACLConstraint.maxInclusive)
        constraints += try integers(IRIKit.IRI(of: SHACL.minLength.self)!).map(SHACLConstraint.minLength)
        constraints += try integers(IRIKit.IRI(of: SHACL.maxLength.self)!).map(SHACLConstraint.maxLength)
        constraints += try patterns(of: node, in: graph).map(SHACLConstraint.pattern)
        if isTrue(IRIKit.IRI(of: SHACL.singleLine.self)!) { constraints.append(.singleLine) }
        constraints += values(IRIKit.IRI(of: SHACL.languageIn.self)!).map { list in
            .languageIn(graph.listOrValue(list).compactMap { $0.literal?.lexicalForm.lowercased() })
        }
        if isPropertyShape, isTrue(IRIKit.IRI(of: SHACL.uniqueLang.self)!) { constraints.append(.uniqueLang) }

        constraints += try paths(IRIKit.IRI(of: SHACL.equals.self)!).map(SHACLConstraint.equals)
        constraints += try paths(IRIKit.IRI(of: SHACL.disjoint.self)!).map(SHACLConstraint.disjoint)
        if isPropertyShape {
            constraints += try paths(IRIKit.IRI(of: SHACL.lessThan.self)!).map(SHACLConstraint.lessThan)
            constraints += try paths(IRIKit.IRI(of: SHACL.lessThanOrEquals.self)!).map(SHACLConstraint.lessThanOrEquals)
        }

        constraints += values(IRIKit.IRI(of: SHACL.not.self)!).map { .not(nodes.shape($0)) }
        constraints += try shapeLists(IRIKit.IRI(of: SHACL.and.self)!).map(SHACLConstraint.and)
        constraints += try shapeLists(IRIKit.IRI(of: SHACL.or.self)!).map(SHACLConstraint.or)
        constraints += try shapeLists(IRIKit.IRI(of: SHACL.xone.self)!).map(SHACLConstraint.xone)
        constraints += values(IRIKit.IRI(of: SHACL.node.self)!).map { .node(nodes.shape($0)) }
        constraints += values(IRIKit.IRI(of: SHACL.property.self)!).map { .property(nodes.shape($0)) }

        if isPropertyShape {
            let qualifiedShapes = values(IRIKit.IRI(of: SHACL.qualifiedValueShape.self)!)
            if !qualifiedShapes.isEmpty {
                let minimum = try integers(IRIKit.IRI(of: SHACL.qualifiedMinCount.self)!).first
                let maximum = try integers(IRIKit.IRI(of: SHACL.qualifiedMaxCount.self)!).first
                let siblings = isTrue(IRIKit.IRI(of: SHACL.qualifiedValueShapesDisjoint.self)!)
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
            constraints += values(IRIKit.IRI(of: SHACL.someValue.self)!).map { .someValue(nodes.shape($0)) }
        }

        if isTrue(IRIKit.IRI(of: SHACL.closed.self)!) {
            var permitted = Set(graph.objects(of: node, IRIKit.IRI(of: SHACL.property.self)!).compactMap { property in
                graph.object(of: property, IRIKit.IRI(of: SHACL.path.self)!)?.iri
            })
            for list in values(IRIKit.IRI(of: SHACL.ignoredProperties.self)!) {
                permitted.formUnion(graph.listOrValue(list).compactMap(\.iri))
            }
            constraints.append(.closed(permitted: permitted))
        }
        constraints += values(IRIKit.IRI(of: SHACL.hasValue.self)!).map(SHACLConstraint.hasValue)
        constraints += try values(IRIKit.IRI(of: SHACL.in.self)!).map { list in
            guard let members = graph.list(list) else {
                throw SHACLError.invalidShapesGraph("Shape \(node) has a sh:in \(list) that is not a SHACL list")
            }
            return .in(members)
        }

        if let expression, let expressionNode = value(IRIKit.IRI(of: SHACL.expression.self)!) {
            constraints.append(.expression(expression, node: expressionNode))
        }
        constraints += values(IRIKit.IRI(of: SHACL.nodeByExpression.self)!).map {
            .nodeByExpression(SHACLNodeExpression($0, in: nodes))
        }

        if isPropertyShape {
            let reifierShape = value(IRIKit.IRI(of: SHACL.reifierShape.self)!).map(nodes.shape)
            let required = isTrue(IRIKit.IRI(of: SHACL.reificationRequired.self)!)
            if reifierShape != nil || required {
                constraints.append(.reifierShape(reifierShape, required: required))
            }
        }
        do {
            constraints += values(IRIKit.IRI(of: SHACL.memberShape.self)!).map { .memberShape(nodes.shape($0)) }
            constraints += try integers(IRIKit.IRI(of: SHACL.minListLength.self)!).map(SHACLConstraint.minListLength)
            constraints += try integers(IRIKit.IRI(of: SHACL.maxListLength.self)!).map(SHACLConstraint.maxListLength)
            if isTrue(IRIKit.IRI(of: SHACL.uniqueMembers.self)!) { constraints.append(.uniqueMembers) }
        }

        for constraint in values(IRIKit.IRI(of: SHACL.sparql.self)!).flatMap(graph.listOrValue) {
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
        for flag in graph.object(of: node, IRIKit.IRI(of: SHACL.flags.self)!)?.stringValue ?? "" {
            switch flag {
            case "i": options.insert(.caseInsensitive)
            case "m": options.insert(.anchorsMatchLines)
            case "s": options.insert(.dotMatchesLineSeparators)
            case "x": options.insert(.allowCommentsAndWhitespace)
            default: break
            }
        }
        return try graph.objects(of: node, IRIKit.IRI(of: SHACL.pattern.self)!).map { value in
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
        let property = IRIKit.IRI(of: SHACL.property.self)!
        let qualifiedValueShape = IRIKit.IRI(of: SHACL.qualifiedValueShape.self)!
        return graph.subjects(property, node)
            .flatMap { graph.objects(of: $0, property) }
            .flatMap { graph.objects(of: $0, qualifiedValueShape) }
            .uniqued()
    }
}
