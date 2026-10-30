import Foundation
import IRIKit
import RDFCore
import RDFKit

/// A shape of a shapes graph, decoded from its node (SHACL 1.2 Core §2.1).
///
/// "A shape is an IRI or blank node s" of the shapes graph; the node is the
/// shape's identity there, and a shape names the shapes it refers to by
/// their nodes, as the shapes graph does. The node's IRI is read only when a
/// result names the shape as its `sh:sourceShape`.
///
/// A shape's parameters are the values of its triples. Each constraint
/// component (§4) is applied by the validator to the shape's value nodes.
public struct SHACLShape: Sendable, Identifiable {
    /// The shape's node in the shapes graph.
    public let id: ObjectTerm

    /// `sh:path`: the property path of a property shape (§2.3).
    public let path: SHACLPropertyPath?

    /// The node expression whose output is the value nodes of a property
    /// shape that has `sh:expression` and no `sh:path`.
    public let valueExpression: SHACLNodeExpression?

    /// Whether the shape is a property shape: it has value nodes other than
    /// its focus node.
    public var isPropertyShape: Bool { path != nil || valueExpression != nil }

    /// The targets (§2.1.3).
    public let targets: [SHACLTarget]

    /// Whether the shape is also a class, with its SHACL instances as
    /// implicit focus nodes (§2.1.3.3).
    public let isClass: Bool

    /// `sh:deactivated` (§2.1.5): a deactivated shape has no results.
    public let isDeactivated: Bool

    /// `sh:severity` (§2.1.4), `sh:Violation` when none is given.
    public let severity: any SHACL.Severity

    // Value type (§4.1).
    public let classes: [ObjectTerm]
    public let datatype: IRI?
    public let nodeKind: (any SHACL.NodeKind)?

    // Cardinality (§4.2).
    public let minCount: Int?
    public let maxCount: Int?

    // Value range (§4.3).
    public let minExclusive: Literal?
    public let minInclusive: Literal?
    public let maxExclusive: Literal?
    public let maxInclusive: Literal?

    // String-based (§4.4).
    public let minLength: Int?
    public let maxLength: Int?
    public let patterns: [NSRegularExpression]
    public let singleLine: Bool
    public let languageIn: [String]?
    public let uniqueLang: Bool

    // Property pair (§4.5).
    public let equals: [SHACLPropertyPath]
    public let disjoint: [SHACLPropertyPath]
    public let lessThan: [SHACLPropertyPath]
    public let lessThanOrEquals: [SHACLPropertyPath]

    // Logical (§4.6).
    public let not: [ObjectTerm]
    public let and: [[ObjectTerm]]
    public let or: [[ObjectTerm]]
    public let xone: [[ObjectTerm]]

    // Shape-based (§4.7).
    public let nodes: [ObjectTerm]
    public let properties: [ObjectTerm]
    public let qualifiedValueShapes: [ObjectTerm]
    public let qualifiedMinCount: Int?
    public let qualifiedMaxCount: Int?
    public let qualifiedValueShapesDisjoint: Bool
    public let reifierShape: ObjectTerm?
    public let reificationRequired: Bool

    // Other (§4.8).
    public let isClosed: Bool
    public let ignoredProperties: [IRI]
    public let hasValues: [ObjectTerm]
    public let `in`: [ObjectTerm]?

    // Lists.
    public let memberShape: ObjectTerm?
    public let minListLength: Int?
    public let maxListLength: Int?
    public let uniqueMembers: Bool

    // Expressions.
    public let expression: SHACLNodeExpression?
    public let nodeByExpression: SHACLNodeExpression?

    // Rules and SPARQL.
    public let rules: [SHACLTripleRule]
    public let sparqlConstraints: [SHACLSPARQLQuery]

    /// Decodes the shape whose node is `node` in `graph`.
    ///
    /// - Throws: ``SHACLError/invalidShapesGraph(_:)`` when a parameter's
    ///   value is ill-formed: a count that is not an integer, a rule without
    ///   `sh:subject`, `sh:predicate` and `sh:object`, a SPARQL constraint
    ///   without a query, or a typed property shape without a path.
    public init(_ node: ObjectTerm, in graph: Graph) throws {
        let reader = ParameterReader(node: node, graph: graph)
        id = node

        let pathNode = reader.value(SHACL.path.metadata.id)
        if let pathNode {
            guard let path = SHACLPropertyPath(pathNode, in: graph) else {
                throw SHACLError.invalidShapesGraph("Shape \(node) has an ill-formed sh:path \(pathNode)")
            }
            self.path = path
        } else {
            path = nil
        }
        let types = reader.values(RDF.type.metadata.id)
        let typedPropertyShape = types.contains(.iri(SHACL.PropertyShapeIndividual.metadata.id))
        let typedNodeShape = types.contains(.iri(SHACL.NodeShapeIndividual.metadata.id))
        let expression = reader.value(SHACL.expression.metadata.id).map { SHACLNodeExpression($0, in: graph) }
        if path == nil, expression != nil, !typedNodeShape {
            valueExpression = expression
            self.expression = nil
        } else {
            valueExpression = nil
            self.expression = expression
        }
        if typedPropertyShape, path == nil, valueExpression == nil {
            throw SHACLError.invalidShapesGraph("Property shape \(node) is missing both sh:path and sh:expression")
        }

        targets = try reader.targets()
        isClass = graph.isInstance(node, of: .iri(RDFS.ClassIndividual.metadata.id))
            || types.contains(.iri(SHACL.ShapeClassIndividual.metadata.id))
        isDeactivated = reader.value(SHACL.deactivated.metadata.id)?.literal?.isTrue ?? false
        severity = reader.value(SHACL.severity.metadata.id).flatMap(Self.severity) ?? SHACL.Violation

        classes = reader.values(SHACL.class.metadata.id)
        datatype = reader.value(SHACL.datatype.metadata.id)?.iri
        nodeKind = reader.value(SHACL.nodeKind.metadata.id).flatMap(Self.nodeKind)

        minCount = try reader.integer(SHACL.minCount.metadata.id)
        maxCount = try reader.integer(SHACL.maxCount.metadata.id)

        minExclusive = reader.value(SHACL.minExclusive.metadata.id)?.literal
        minInclusive = reader.value(SHACL.minInclusive.metadata.id)?.literal
        maxExclusive = reader.value(SHACL.maxExclusive.metadata.id)?.literal
        maxInclusive = reader.value(SHACL.maxInclusive.metadata.id)?.literal

        minLength = try reader.integer(SHACL.minLength.metadata.id)
        maxLength = try reader.integer(SHACL.maxLength.metadata.id)
        patterns = try reader.patterns()
        singleLine = reader.value(SHACL.singleLine.metadata.id)?.literal?.isTrue ?? false
        let languageRanges = reader.values(SHACL.languageIn.metadata.id).flatMap(graph.listOrValue)
        languageIn = languageRanges.isEmpty && reader.value(SHACL.languageIn.metadata.id) == nil
            ? nil : languageRanges.compactMap { $0.literal?.lexicalForm.lowercased() }
        uniqueLang = reader.value(SHACL.uniqueLang.metadata.id)?.literal?.isTrue ?? false

        equals = reader.paths(SHACL.equals.metadata.id)
        disjoint = reader.paths(SHACL.disjoint.metadata.id)
        lessThan = reader.paths(SHACL.lessThan.metadata.id)
        lessThanOrEquals = reader.paths(SHACL.lessThanOrEquals.metadata.id)

        not = reader.values(SHACL.not.metadata.id)
        and = reader.lists(SHACL.and.metadata.id)
        or = reader.lists(SHACL.or.metadata.id)
        xone = reader.lists(SHACL.xone.metadata.id)

        nodes = reader.values(SHACL.node.metadata.id)
        properties = reader.values(SHACL.property.metadata.id)
        let someValue = reader.value(SHACL.someValue.metadata.id)
        qualifiedValueShapes = reader.values(SHACL.qualifiedValueShape.metadata.id) + (someValue.map { [$0] } ?? [])
        qualifiedMinCount = try reader.integer(SHACL.qualifiedMinCount.metadata.id) ?? (someValue == nil ? nil : 1)
        qualifiedMaxCount = try reader.integer(SHACL.qualifiedMaxCount.metadata.id)
        qualifiedValueShapesDisjoint = reader.value(SHACL.qualifiedValueShapesDisjoint.metadata.id)?.literal?.isTrue ?? false
        reifierShape = reader.value(SHACL.reifierShape.metadata.id)
        reificationRequired = reader.value(SHACL.reificationRequired.metadata.id)?.literal?.isTrue ?? false

        isClosed = reader.value(SHACL.closed.metadata.id)?.literal?.isTrue ?? false
        ignoredProperties = reader.values(SHACL.ignoredProperties.metadata.id).flatMap(graph.listOrValue).compactMap(\.iri)
        hasValues = reader.values(SHACL.hasValue.metadata.id)
        let allowed = reader.values(SHACL.in.metadata.id)
        self.in = allowed.isEmpty ? nil : allowed.flatMap(graph.listOrValue)

        memberShape = reader.value(SHACL.memberShape.metadata.id)
        minListLength = try reader.integer(SHACL.minListLength.metadata.id)
        maxListLength = try reader.integer(SHACL.maxListLength.metadata.id)
        uniqueMembers = reader.value(SHACL.uniqueMembers.metadata.id)?.literal?.isTrue ?? false

        nodeByExpression = reader.value(SHACL.nodeByExpression.metadata.id).map { SHACLNodeExpression($0, in: graph) }

        rules = try reader.values(SHACL.rule.metadata.id).flatMap(graph.listOrValue).map { try Self.rule($0, in: graph) }
        sparqlConstraints = try reader.values(SHACL.sparql.metadata.id).flatMap(graph.listOrValue).map { node in
            let query = SHACLSPARQLQuery(node, in: graph)
            guard query.select != nil || query.ask != nil else {
                throw SHACLError.invalidShapesGraph("SPARQL constraint \(node) is missing sh:select/sh:ask")
            }
            return query
        }
    }

    /// The severity an IRI names (§2.1.4): `sh:Violation`, `sh:Warning` or
    /// `sh:Info`.
    private static func severity(_ term: ObjectTerm) -> (any SHACL.Severity)? {
        [SHACL.Violation, SHACL.Warning, SHACL.Info].first { term == .iri(type(of: $0).metadata.id) }
    }

    /// The node kind an IRI names (§4.1.3).
    private static func nodeKind(_ term: ObjectTerm) -> (any SHACL.NodeKind)? {
        [SHACL.IRI, SHACL.Literal, SHACL.BlankNode, SHACL.BlankNodeOrIRI, SHACL.BlankNodeOrLiteral, SHACL.IRIOrLiteral]
            .first { term == .iri(type(of: $0).metadata.id) }
    }

    /// A `sh:TripleRule` (SHACL 1.2 Rules).
    private static func rule(_ node: ObjectTerm, in graph: Graph) throws -> SHACLTripleRule {
        let reader = ParameterReader(node: node, graph: graph)
        guard reader.values(RDF.type.metadata.id).contains(.iri(SHACL.TripleRuleIndividual.metadata.id)) else {
            throw SHACLError.invalidShapesGraph("Rule \(node) is missing rdf:type sh:TripleRule")
        }
        func expression(_ parameter: IRI, _ name: String) throws -> SHACLNodeExpression {
            guard let value = reader.value(parameter) else {
                throw SHACLError.invalidShapesGraph("Rule \(node) is missing \(name)")
            }
            return SHACLNodeExpression(value, in: graph)
        }
        let order: Double?
        if let value = reader.value(SHACL.order.metadata.id) {
            guard let number = value.literal?.numericValue else {
                throw SHACLError.invalidShapesGraph("Rule \(node) has invalid sh:order value \(value)")
            }
            order = number
        } else {
            order = nil
        }
        return SHACLTripleRule(
            node: node,
            order: order,
            conditions: reader.values(SHACL.condition.metadata.id).flatMap(graph.listOrValue),
            subject: try expression(SHACL.subject.metadata.id, "sh:subject"),
            predicate: try expression(SHACL.predicate.metadata.id, "sh:predicate"),
            object: try expression(SHACL.object.metadata.id, "sh:object")
        )
    }
}

extension SHACLSPARQLQuery {
    /// Decodes the SPARQL-based constraint or target whose node is `node`.
    init(_ node: ObjectTerm, in graph: Graph) {
        let reader = ParameterReader(node: node, graph: graph)
        var prefixes: [String: IRI] = [:]
        for declarations in reader.values(SHACL.prefixes.metadata.id) {
            for declaration in graph.objects(of: declarations, SHACL.declare.metadata.id) {
                guard let prefix = graph.object(of: declaration, SHACL.prefix.metadata.id)?.stringValue,
                      let namespace = graph.object(of: declaration, SHACL.namespace.metadata.id)?.stringValue,
                      let iri = IRI(rawValue: namespace) else { continue }
                prefixes[prefix] = iri
            }
        }
        self.init(
            node: node,
            select: reader.value(SHACL.select.metadata.id)?.stringValue,
            ask: reader.value(SHACL.ask.metadata.id)?.stringValue,
            message: reader.value(SHACL.message.metadata.id)?.stringValue,
            prefixes: prefixes
        )
    }
}

/// The values of one node's parameters in a shapes graph.
struct ParameterReader {
    let node: ObjectTerm
    let graph: Graph

    func values(_ parameter: IRI) -> [ObjectTerm] {
        graph.objects(of: node, parameter)
    }

    func value(_ parameter: IRI) -> ObjectTerm? {
        graph.object(of: node, parameter)
    }

    /// The members of each SHACL list the parameter has as a value.
    func lists(_ parameter: IRI) -> [[ObjectTerm]] {
        values(parameter).map(graph.listOrValue)
    }

    /// The paths the parameter's values are.
    func paths(_ parameter: IRI) -> [SHACLPropertyPath] {
        values(parameter).compactMap { SHACLPropertyPath($0, in: graph) }
    }

    /// An integer parameter.
    func integer(_ parameter: IRI) throws -> Int? {
        guard let value = value(parameter) else { return nil }
        guard let integer = value.literal?.integerValue else {
            throw SHACLError.invalidShapesGraph("Shape \(node) has a non-integer <\(parameter)> \(value)")
        }
        return integer
    }

    /// `sh:pattern` with `sh:flags` (§4.4.3): the regular expression of
    /// SPARQL's `REGEX` function, with its flags `i`, `m`, `s` and `x`.
    func patterns() throws -> [NSRegularExpression] {
        var options: NSRegularExpression.Options = []
        for flag in value(SHACL.flags.metadata.id)?.stringValue ?? "" {
            switch flag {
            case "i": options.insert(.caseInsensitive)
            case "m": options.insert(.anchorsMatchLines)
            case "s": options.insert(.dotMatchesLineSeparators)
            case "x": options.insert(.allowCommentsAndWhitespace)
            default: break
            }
        }
        return try values(SHACL.pattern.metadata.id).map { value in
            guard let pattern = value.stringValue, let expression = try? NSRegularExpression(pattern: pattern, options: options) else {
                throw SHACLError.invalidShapesGraph("Shape \(node) has an ill-formed sh:pattern \(value)")
            }
            return expression
        }
    }

    /// The targets of the shape (§2.1.3).
    func targets() throws -> [SHACLTarget] {
        var targets: [SHACLTarget] = []
        for value in values(SHACL.targetNode.metadata.id) {
            if graph.object(of: value, SHACL.select.metadata.id) != nil || graph.object(of: value, SHACL.ask.metadata.id) != nil {
                let query = SHACLSPARQLQuery(value, in: graph)
                guard query.select != nil else {
                    throw SHACLError.invalidShapesGraph("SPARQL target \(value) must define sh:select")
                }
                targets.append(.sparql(query))
            } else if SHACLNodeExpression.isExpression(value, in: graph) {
                targets.append(.nodeExpression(SHACLNodeExpression(value, in: graph)))
            } else {
                targets.append(.node(value))
            }
        }
        targets += values(SHACL.targetClass.metadata.id).map(SHACLTarget.class)
        targets += values(SHACL.targetSubjectsOf.metadata.id).compactMap(\.iri).map(SHACLTarget.subjectsOf)
        targets += values(SHACL.targetObjectsOf.metadata.id).compactMap(\.iri).map(SHACLTarget.objectsOf)
        targets += values(SHACL.targetWhere.metadata.id).map(SHACLTarget.where)
        for value in values(SHACL.target.metadata.id) {
            let query = SHACLSPARQLQuery(value, in: graph)
            guard query.select != nil else {
                throw SHACLError.invalidShapesGraph("SPARQL target \(value) must define sh:select")
            }
            targets.append(.sparql(query))
        }
        return targets
    }
}
