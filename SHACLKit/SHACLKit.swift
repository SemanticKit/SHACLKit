import Foundation

public enum SHACLSeverity: String, Sendable, Codable {
    case violation
    case warning
    case info
}

public enum SHACLShapeKind: String, Sendable, Codable {
    case nodeShape
    case propertyShape
}

public enum SHACLTargetSelector: Sendable, Hashable {
    case targetClass(String)
    case targetNode(String)
    case targetSubjectsOf(String)
    case targetObjectsOf(String)
}

public enum SHACLNodeKindConstraint: String, Sendable, Codable, Hashable {
    case iri
    case literal
    case blankNode
    case blankNodeOrIRI
    case blankNodeOrLiteral
    case iriOrLiteral
}

public struct SHACLShapeDefinition: Sendable, Hashable {
    public let shapeIRI: String
    public let kind: SHACLShapeKind
    public let severity: SHACLSeverity?
    public let targets: [SHACLTargetSelector]
    public let propertyShapeIRIs: [String]
    public let pathIRI: String?
    public let expressionIRI: String?
    public let classIRI: String?
    public let nodeKind: SHACLNodeKindConstraint?
    public let datatypeIRI: String?
    public let minLength: Int?
    public let maxLength: Int?
    public let minInclusive: Int?
    public let maxInclusive: Int?
    public let pattern: String?
    public let hasValue: String?
    public let inValues: [String]
    public let nodeShapeReferenceIRI: String?
    public let andShapeIRIs: [String]
    public let orShapeIRIs: [String]
    public let xoneShapeIRIs: [String]
    public let notShapeIRI: String?
    public let qualifiedValueShapeIRI: String?
    public let qualifiedMinCount: Int?
    public let qualifiedMaxCount: Int?
    public let minCount: Int?
    public let maxCount: Int?

    public init(
        shapeIRI: String,
        kind: SHACLShapeKind,
        severity: SHACLSeverity? = nil,
        targets: [SHACLTargetSelector],
        propertyShapeIRIs: [String] = [],
        pathIRI: String? = nil,
        expressionIRI: String? = nil,
        classIRI: String? = nil,
        nodeKind: SHACLNodeKindConstraint? = nil,
        datatypeIRI: String? = nil,
        minLength: Int? = nil,
        maxLength: Int? = nil,
        minInclusive: Int? = nil,
        maxInclusive: Int? = nil,
        pattern: String? = nil,
        hasValue: String? = nil,
        inValues: [String] = [],
        nodeShapeReferenceIRI: String? = nil,
        andShapeIRIs: [String] = [],
        orShapeIRIs: [String] = [],
        xoneShapeIRIs: [String] = [],
        notShapeIRI: String? = nil,
        qualifiedValueShapeIRI: String? = nil,
        qualifiedMinCount: Int? = nil,
        qualifiedMaxCount: Int? = nil,
        minCount: Int? = nil,
        maxCount: Int? = nil
    ) {
        self.shapeIRI = shapeIRI
        self.kind = kind
        self.severity = severity
        self.targets = targets
        self.propertyShapeIRIs = propertyShapeIRIs
        self.pathIRI = pathIRI
        self.expressionIRI = expressionIRI
        self.classIRI = classIRI
        self.nodeKind = nodeKind
        self.datatypeIRI = datatypeIRI
        self.minLength = minLength
        self.maxLength = maxLength
        self.minInclusive = minInclusive
        self.maxInclusive = maxInclusive
        self.pattern = pattern
        self.hasValue = hasValue
        self.inValues = inValues
        self.nodeShapeReferenceIRI = nodeShapeReferenceIRI
        self.andShapeIRIs = andShapeIRIs
        self.orShapeIRIs = orShapeIRIs
        self.xoneShapeIRIs = xoneShapeIRIs
        self.notShapeIRI = notShapeIRI
        self.qualifiedValueShapeIRI = qualifiedValueShapeIRI
        self.qualifiedMinCount = qualifiedMinCount
        self.qualifiedMaxCount = qualifiedMaxCount
        self.minCount = minCount
        self.maxCount = maxCount
    }
}

public struct SHACLShapesGraph: Sendable, Equatable {
    public let shapes: [SHACLShapeDefinition]
    public let nodeExpressions: [SHACLNodeExpressionDefinition]

    public init(shapes: [SHACLShapeDefinition], nodeExpressions: [SHACLNodeExpressionDefinition] = []) {
        self.shapes = shapes
        self.nodeExpressions = nodeExpressions
    }
}

public enum SHACLNodeExpressionKind: Sendable, Hashable {
    case union([String])
    case intersection([String])
}

public struct SHACLNodeExpressionDefinition: Sendable, Hashable {
    public let expressionIRI: String
    public let kind: SHACLNodeExpressionKind

    public init(expressionIRI: String, kind: SHACLNodeExpressionKind) {
        self.expressionIRI = expressionIRI
        self.kind = kind
    }
}

public struct SHACLDataTriple: Sendable, Equatable, Hashable {
    public let subject: String
    public let predicate: String
    public let object: String

    public init(subject: String, predicate: String, object: String) {
        self.subject = subject
        self.predicate = predicate
        self.object = object
    }
}

public struct SHACLDataGraph: Sendable, Equatable {
    public let triples: [SHACLDataTriple]

    public init(triples: [SHACLDataTriple]) {
        self.triples = triples
    }
}

public struct SHACLTargetResolution: Sendable, Equatable {
    public let shapeIRI: String
    public let focusNodes: [String]

    public init(shapeIRI: String, focusNodes: [String]) {
        self.shapeIRI = shapeIRI
        self.focusNodes = focusNodes
    }
}

public struct SHACLViolation: Sendable, Equatable {
    public let severity: SHACLSeverity
    public let shapeIRI: String
    public let focusNode: String
    public let pathIRI: String?
    public let valueNode: String?
    public let sourceConstraintIRI: String?
    public let message: String

    public init(
        severity: SHACLSeverity = .violation,
        shapeIRI: String,
        focusNode: String,
        pathIRI: String?,
        valueNode: String? = nil,
        sourceConstraintIRI: String? = nil,
        message: String
    ) {
        self.severity = severity
        self.shapeIRI = shapeIRI
        self.focusNode = focusNode
        self.pathIRI = pathIRI
        self.valueNode = valueNode
        self.sourceConstraintIRI = sourceConstraintIRI
        self.message = message
    }
}

public struct SHACLValidationResult: Sendable, Equatable {
    public let conforms: Bool
    public let message: String
    public let violations: [SHACLViolation]

    public init(conforms: Bool, message: String, violations: [SHACLViolation] = []) {
        self.conforms = conforms
        self.message = message
        self.violations = violations
    }
}

public protocol SHACLShapesGraphLoading: Sendable {
    func load(from data: Data) throws -> SHACLShapesGraph
}

public protocol SHACLDataGraphLoading: Sendable {
    func load(from data: Data) throws -> SHACLDataGraph
}

public protocol SHACLValidator: Sendable {
    func validate(dataGraph: Data, shapesGraph: Data) throws -> SHACLValidationResult
    func validate(dataGraph: SHACLDataGraph, shapesGraph: SHACLShapesGraph) throws -> SHACLValidationResult
}

public protocol SHACLDataGraphAdapting: Sendable {
    associatedtype Source
    func adapt(_ source: Source) throws -> SHACLDataGraph
}

public protocol SHACLShapesGraphAdapting: Sendable {
    associatedtype Source
    func adapt(_ source: Source) throws -> SHACLShapesGraph
}

public struct AnySHACLDataGraphAdapter<Source>: SHACLDataGraphAdapting {
    private let adapter: @Sendable (Source) throws -> SHACLDataGraph

    public init(_ adapter: @escaping @Sendable (Source) throws -> SHACLDataGraph) {
        self.adapter = adapter
    }

    public func adapt(_ source: Source) throws -> SHACLDataGraph {
        try adapter(source)
    }
}

public struct AnySHACLShapesGraphAdapter<Source>: SHACLShapesGraphAdapting {
    private let adapter: @Sendable (Source) throws -> SHACLShapesGraph

    public init(_ adapter: @escaping @Sendable (Source) throws -> SHACLShapesGraph) {
        self.adapter = adapter
    }

    public func adapt(_ source: Source) throws -> SHACLShapesGraph {
        try adapter(source)
    }
}

public enum SHACLError: Error, LocalizedError {
    case invalidUTF8
    case invalidPrefixDeclaration(String)
    case unknownPrefix(String)
    case invalidStatement(String)
    case invalidIntegerLiteral(String)
    case unsupportedTerm(String)
    case invalidShapesGraph(String)
    case notImplemented(String)

    public var errorDescription: String? {
        switch self {
        case .invalidUTF8:
            return "Invalid UTF-8 input."
        case .invalidPrefixDeclaration(let line):
            return "Invalid @prefix declaration: \(line)"
        case .unknownPrefix(let prefix):
            return "Unknown prefix: \(prefix)"
        case .invalidStatement(let statement):
            return "Invalid statement: \(statement)"
        case .invalidIntegerLiteral(let value):
            return "Invalid integer literal: \(value)"
        case .unsupportedTerm(let term):
            return "Unsupported RDF term in SHACLKit Turtle subset parser: \(term)"
        case .invalidShapesGraph(let detail):
            return "Invalid SHACL shapes graph: \(detail)"
        case .notImplemented(let detail):
            return "SHACL feature not implemented: \(detail)"
        }
    }
}

public struct SHACLShapesGraphLoader: SHACLShapesGraphLoading {
    public init() {}

    public func load(from data: Data) throws -> SHACLShapesGraph {
        guard let source = String(data: data, encoding: .utf8) else {
            throw SHACLError.invalidUTF8
        }

        let parser = SHACLTurtleSubsetParser(source: source)
        let triples = try parser.parseTriples()

        struct PartialShape {
            var kind: SHACLShapeKind?
            var severity: SHACLSeverity?
            var targets: Set<SHACLTargetSelector> = []
            var propertyShapeIRIs: Set<String> = []
            var pathIRI: String?
            var expressionIRI: String?
            var classIRI: String?
            var nodeKind: SHACLNodeKindConstraint?
            var datatypeIRI: String?
            var minLength: Int?
            var maxLength: Int?
            var minInclusive: Int?
            var maxInclusive: Int?
            var pattern: String?
            var hasValue: String?
            var inValues: Set<String> = []
            var nodeShapeReferenceIRI: String?
            var andShapeIRIs: Set<String> = []
            var orShapeIRIs: Set<String> = []
            var xoneShapeIRIs: Set<String> = []
            var notShapeIRI: String?
            var qualifiedValueShapeIRI: String?
            var qualifiedMinCount: Int?
            var qualifiedMaxCount: Int?
            var minCount: Int?
            var maxCount: Int?
        }

        struct PartialNodeExpression {
            var unionMemberObjects: Set<String> = []
            var intersectionMemberObjects: Set<String> = []
        }

        var shapes: [String: PartialShape] = [:]
        var nodeExpressions: [String: PartialNodeExpression] = [:]

        for triple in triples {
            let subject = triple.subject
            let predicate = triple.predicate
            let object = triple.object

            if SHACLIRIs.phaseGatedPredicates.contains(predicate) {
                throw SHACLError.notImplemented("Predicate \(predicate) is gated pending later SHACL phases.")
            }

            var current = shapes[subject] ?? PartialShape()

            if predicate == SHACLIRIs.rdfType {
                if object == SHACLIRIs.nodeShape {
                    current.kind = .nodeShape
                } else if object == SHACLIRIs.propertyShape {
                    current.kind = .propertyShape
                }
            } else if predicate == SHACLIRIs.targetClass {
                current.targets.insert(.targetClass(object))
            } else if predicate == SHACLIRIs.targetNode {
                current.targets.insert(.targetNode(object))
            } else if predicate == SHACLIRIs.targetSubjectsOf {
                current.targets.insert(.targetSubjectsOf(object))
            } else if predicate == SHACLIRIs.targetObjectsOf {
                current.targets.insert(.targetObjectsOf(object))
            } else if predicate == SHACLIRIs.severity {
                current.severity = parseSeverity(object)
            } else if predicate == SHACLIRIs.property {
                current.propertyShapeIRIs.insert(object)
            } else if predicate == SHACLIRIs.path {
                current.pathIRI = object
            } else if predicate == SHACLIRIs.expression {
                current.expressionIRI = object
            } else if predicate == SHACLIRIs.class {
                current.classIRI = object
            } else if predicate == SHACLIRIs.nodeKind {
                current.nodeKind = parseNodeKind(object)
            } else if predicate == SHACLIRIs.datatype {
                current.datatypeIRI = object
            } else if predicate == SHACLIRIs.minLength {
                guard let length = Int(object) else {
                    throw SHACLError.invalidIntegerLiteral(object)
                }
                current.minLength = length
            } else if predicate == SHACLIRIs.maxLength {
                guard let length = Int(object) else {
                    throw SHACLError.invalidIntegerLiteral(object)
                }
                current.maxLength = length
            } else if predicate == SHACLIRIs.minInclusive {
                guard let minimum = Int(object) else {
                    throw SHACLError.invalidIntegerLiteral(object)
                }
                current.minInclusive = minimum
            } else if predicate == SHACLIRIs.maxInclusive {
                guard let maximum = Int(object) else {
                    throw SHACLError.invalidIntegerLiteral(object)
                }
                current.maxInclusive = maximum
            } else if predicate == SHACLIRIs.pattern {
                current.pattern = parsedLiteralLexicalForm(object)
            } else if predicate == SHACLIRIs.hasValue {
                current.hasValue = object
            } else if predicate == SHACLIRIs.in {
                current.inValues.insert(object)
            } else if predicate == SHACLIRIs.node {
                current.nodeShapeReferenceIRI = object
            } else if predicate == SHACLIRIs.and {
                current.andShapeIRIs.insert(object)
            } else if predicate == SHACLIRIs.or {
                current.orShapeIRIs.insert(object)
            } else if predicate == SHACLIRIs.xone {
                current.xoneShapeIRIs.insert(object)
            } else if predicate == SHACLIRIs.not {
                current.notShapeIRI = object
            } else if predicate == SHACLIRIs.qualifiedValueShape {
                current.qualifiedValueShapeIRI = object
            } else if predicate == SHACLIRIs.qualifiedMinCount {
                guard let count = Int(object) else {
                    throw SHACLError.invalidIntegerLiteral(object)
                }
                current.qualifiedMinCount = count
            } else if predicate == SHACLIRIs.qualifiedMaxCount {
                guard let count = Int(object) else {
                    throw SHACLError.invalidIntegerLiteral(object)
                }
                current.qualifiedMaxCount = count
            } else if predicate == SHACLIRIs.minCount {
                guard let count = Int(object) else {
                    throw SHACLError.invalidIntegerLiteral(object)
                }
                current.minCount = count
            } else if predicate == SHACLIRIs.maxCount {
                guard let count = Int(object) else {
                    throw SHACLError.invalidIntegerLiteral(object)
                }
                current.maxCount = count
            }

            shapes[subject] = current

            if predicate == SHACLIRIs.union || predicate == SHACLIRIs.intersection {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                if predicate == SHACLIRIs.union {
                    expression.unionMemberObjects.insert(object)
                } else {
                    expression.intersectionMemberObjects.insert(object)
                }
                nodeExpressions[subject] = expression
            }
        }

        let triplesBySubject = Dictionary(grouping: triples, by: \.subject)

        let definitions = shapes.compactMap { shapeIRI, partial -> SHACLShapeDefinition? in
            guard let kind = partial.kind else {
                return nil
            }
            return SHACLShapeDefinition(
                shapeIRI: shapeIRI,
                kind: kind,
                severity: partial.severity,
                targets: partial.targets.sorted(by: { targetSortKey($0) < targetSortKey($1) }),
                propertyShapeIRIs: partial.propertyShapeIRIs.sorted(),
                pathIRI: partial.pathIRI,
                expressionIRI: partial.expressionIRI,
                classIRI: partial.classIRI,
                nodeKind: partial.nodeKind,
                datatypeIRI: partial.datatypeIRI,
                minLength: partial.minLength,
                maxLength: partial.maxLength,
                minInclusive: partial.minInclusive,
                maxInclusive: partial.maxInclusive,
                pattern: partial.pattern,
                hasValue: partial.hasValue,
                inValues: resolveInValues(partial.inValues, triplesBySubject: triplesBySubject).sorted(),
                nodeShapeReferenceIRI: partial.nodeShapeReferenceIRI,
                andShapeIRIs: resolveShapeReferenceIRIs(partial.andShapeIRIs, triplesBySubject: triplesBySubject).sorted(),
                orShapeIRIs: resolveShapeReferenceIRIs(partial.orShapeIRIs, triplesBySubject: triplesBySubject).sorted(),
                xoneShapeIRIs: resolveShapeReferenceIRIs(partial.xoneShapeIRIs, triplesBySubject: triplesBySubject).sorted(),
                notShapeIRI: partial.notShapeIRI,
                qualifiedValueShapeIRI: partial.qualifiedValueShapeIRI,
                qualifiedMinCount: partial.qualifiedMinCount,
                qualifiedMaxCount: partial.qualifiedMaxCount,
                minCount: partial.minCount,
                maxCount: partial.maxCount
            )
        }
        .sorted(by: { $0.shapeIRI < $1.shapeIRI })

        let expressionDefinitions = nodeExpressions.compactMap { expressionIRI, partial -> SHACLNodeExpressionDefinition? in
            let unionMembers = resolveShapeReferenceIRIs(partial.unionMemberObjects, triplesBySubject: triplesBySubject).sorted()
            if !unionMembers.isEmpty {
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .union(unionMembers)
                )
            }

            let intersectionMembers = resolveShapeReferenceIRIs(partial.intersectionMemberObjects, triplesBySubject: triplesBySubject).sorted()
            if !intersectionMembers.isEmpty {
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .intersection(intersectionMembers)
                )
            }

            return nil
        }
        .sorted(by: { $0.expressionIRI < $1.expressionIRI })

        return SHACLShapesGraph(shapes: definitions, nodeExpressions: expressionDefinitions)
    }

    private func targetSortKey(_ selector: SHACLTargetSelector) -> String {
        switch selector {
        case .targetClass(let iri):
            return "0:\(iri)"
        case .targetNode(let iri):
            return "1:\(iri)"
        case .targetSubjectsOf(let iri):
            return "2:\(iri)"
        case .targetObjectsOf(let iri):
            return "3:\(iri)"
        }
    }

    private func parseNodeKind(_ iri: String) -> SHACLNodeKindConstraint? {
        switch iri {
        case SHACLIRIs.nodeKindIRI:
            return .iri
        case SHACLIRIs.nodeKindLiteral:
            return .literal
        case SHACLIRIs.nodeKindBlankNode:
            return .blankNode
        case SHACLIRIs.nodeKindBlankNodeOrIRI:
            return .blankNodeOrIRI
        case SHACLIRIs.nodeKindBlankNodeOrLiteral:
            return .blankNodeOrLiteral
        case SHACLIRIs.nodeKindIRIOrLiteral:
            return .iriOrLiteral
        default:
            return nil
        }
    }

    private func parseSeverity(_ iri: String) -> SHACLSeverity? {
        switch iri {
        case SHACLIRIs.severityViolation:
            return .violation
        case SHACLIRIs.severityWarning:
            return .warning
        case SHACLIRIs.severityInfo:
            return .info
        default:
            return nil
        }
    }

    private func parsedLiteralLexicalForm(_ value: String) -> String? {
        guard value.hasPrefix("\"") else {
            return nil
        }
        guard let closing = value.dropFirst().firstIndex(of: "\"") else {
            return nil
        }
        let start = value.index(after: value.startIndex)
        return String(value[start..<closing])
    }

    private func resolveInValues(
        _ valueObjects: Set<String>,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> Set<String> {
        var resolved: Set<String> = []
        for object in valueObjects {
            resolved.formUnion(resolveRDFListOrDirectValue(object, triplesBySubject: triplesBySubject))
        }
        return resolved
    }

    private func resolveShapeReferenceIRIs(
        _ valueObjects: Set<String>,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> Set<String> {
        var resolved: Set<String> = []
        for object in valueObjects {
            resolved.formUnion(resolveRDFListOrDirectValue(object, triplesBySubject: triplesBySubject))
        }
        return resolved
    }

    private func resolveRDFListOrDirectValue(
        _ headOrValue: String,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> Set<String> {
        if headOrValue == SHACLIRIs.rdfNil {
            return []
        }

        guard let firstRestTriples = triplesBySubject[headOrValue],
              firstRestTriples.contains(where: { $0.predicate == SHACLIRIs.rdfFirst }) else {
            return [headOrValue]
        }

        var values: Set<String> = []
        var current = headOrValue
        var visited: Set<String> = []

        while current != SHACLIRIs.rdfNil && !visited.contains(current) {
            visited.insert(current)
            guard let triples = triplesBySubject[current] else {
                break
            }
            guard let first = triples.first(where: { $0.predicate == SHACLIRIs.rdfFirst }),
                  let rest = triples.first(where: { $0.predicate == SHACLIRIs.rdfRest }) else {
                break
            }
            values.insert(first.object)
            current = rest.object
        }

        return values
    }
}

public struct SHACLDataGraphLoader: SHACLDataGraphLoading {
    public init() {}

    public func load(from data: Data) throws -> SHACLDataGraph {
        guard let source = String(data: data, encoding: .utf8) else {
            throw SHACLError.invalidUTF8
        }
        let parser = SHACLTurtleSubsetParser(source: source)
        let triples = try parser.parseTriples().map {
            SHACLDataTriple(subject: $0.subject, predicate: $0.predicate, object: $0.object)
        }
        return SHACLDataGraph(triples: triples)
    }
}

public struct SHACLFocusNodeResolver: Sendable {
    public init() {}

    public func resolve(dataGraph: SHACLDataGraph, shapesGraph: SHACLShapesGraph) -> [SHACLTargetResolution] {
        shapesGraph.shapes.map { shape in
            var nodes: Set<String> = []
            for selector in shape.targets {
                nodes.formUnion(resolve(selector: selector, in: dataGraph))
            }
            return SHACLTargetResolution(shapeIRI: shape.shapeIRI, focusNodes: nodes.sorted())
        }
    }

    private func resolve(selector: SHACLTargetSelector, in graph: SHACLDataGraph) -> Set<String> {
        switch selector {
        case .targetClass(let classIRI):
            return Set(
                graph.triples
                    .filter { $0.predicate == SHACLIRIs.rdfType && $0.object == classIRI }
                    .map(\.subject)
            )
        case .targetNode(let nodeIRI):
            return Set([nodeIRI])
        case .targetSubjectsOf(let predicateIRI):
            return Set(graph.triples.filter { $0.predicate == predicateIRI }.map(\.subject))
        case .targetObjectsOf(let predicateIRI):
            return Set(graph.triples.filter { $0.predicate == predicateIRI }.map(\.object))
        }
    }
}

public struct SHACLNodeExpressionEvaluator: Sendable {
    private let maxDepth = 16

    public init() {}

    public func evaluate(
        expressionIRI: String,
        focusNode: String,
        shapesGraph: SHACLShapesGraph
    ) -> Set<String> {
        let expressionByIRI = Dictionary(uniqueKeysWithValues: shapesGraph.nodeExpressions.map { ($0.expressionIRI, $0) })
        var visited: Set<String> = []
        return evaluateTerm(
            expressionIRI,
            focusNode: focusNode,
            expressionsByIRI: expressionByIRI,
            depth: 0,
            visited: &visited
        )
    }

    private func evaluateTerm(
        _ term: String,
        focusNode: String,
        expressionsByIRI: [String: SHACLNodeExpressionDefinition],
        depth: Int,
        visited: inout Set<String>
    ) -> Set<String> {
        if term == SHACLIRIs.shThis {
            return [focusNode]
        }

        guard let expression = expressionsByIRI[term] else {
            return [term]
        }

        if depth > maxDepth || visited.contains(expression.expressionIRI) {
            return []
        }

        visited.insert(expression.expressionIRI)
        defer { visited.remove(expression.expressionIRI) }

        switch expression.kind {
        case .union(let members):
            return members.reduce(into: Set<String>()) { result, member in
                result.formUnion(
                    evaluateTerm(
                        member,
                        focusNode: focusNode,
                        expressionsByIRI: expressionsByIRI,
                        depth: depth + 1,
                        visited: &visited
                    )
                )
            }
        case .intersection(let members):
            guard let first = members.first else {
                return []
            }
            let initial = evaluateTerm(
                first,
                focusNode: focusNode,
                expressionsByIRI: expressionsByIRI,
                depth: depth + 1,
                visited: &visited
            )
            return members.dropFirst().reduce(initial) { partial, member in
                partial.intersection(
                    evaluateTerm(
                        member,
                        focusNode: focusNode,
                        expressionsByIRI: expressionsByIRI,
                        depth: depth + 1,
                        visited: &visited
                    )
                )
            }
        }
    }
}

public struct SHACLCoreValidator: SHACLValidator {
    private let shapesLoader: any SHACLShapesGraphLoading
    private let dataLoader: any SHACLDataGraphLoading
    private let focusResolver: SHACLFocusNodeResolver
    private let maxReferenceDepth = 16

    public init(
        shapesLoader: any SHACLShapesGraphLoading = SHACLShapesGraphLoader(),
        dataLoader: any SHACLDataGraphLoading = SHACLDataGraphLoader(),
        focusResolver: SHACLFocusNodeResolver = SHACLFocusNodeResolver()
    ) {
        self.shapesLoader = shapesLoader
        self.dataLoader = dataLoader
        self.focusResolver = focusResolver
    }

    public func validate(dataGraph: Data, shapesGraph: Data) throws -> SHACLValidationResult {
        let parsedShapes = try shapesLoader.load(from: shapesGraph)
        let parsedData = try dataLoader.load(from: dataGraph)
        return try validate(dataGraph: parsedData, shapesGraph: parsedShapes)
    }

    public func validate(dataGraph: SHACLDataGraph, shapesGraph: SHACLShapesGraph) throws -> SHACLValidationResult {
        try validateShapesGraph(shapesGraph)
        let parsedShapes = shapesGraph
        let parsedData = dataGraph
        let resolutions = focusResolver.resolve(dataGraph: parsedData, shapesGraph: parsedShapes)
        let shapeByIRI = Dictionary(uniqueKeysWithValues: parsedShapes.shapes.map { ($0.shapeIRI, $0) })
        let nodeExpressionsByIRI = Dictionary(uniqueKeysWithValues: parsedShapes.nodeExpressions.map { ($0.expressionIRI, $0) })

        var violations: [SHACLViolation] = []

        for resolution in resolutions {
            guard let shape = shapeByIRI[resolution.shapeIRI], shape.kind == .nodeShape else {
                continue
            }
            for focusNode in resolution.focusNodes {
                var visited: Set<String> = []
                violations.append(
                    contentsOf: evaluate(
                        nodeShape: shape,
                        focusNode: focusNode,
                        dataGraph: parsedData,
                        shapesByIRI: shapeByIRI,
                        nodeExpressionsByIRI: nodeExpressionsByIRI,
                        depth: 0,
                        visited: &visited
                    )
                )
            }
        }

        let sortedViolations = violations.sorted { lhs, rhs in
            (
                lhs.shapeIRI,
                lhs.focusNode,
                lhs.pathIRI ?? "",
                lhs.sourceConstraintIRI ?? "",
                lhs.valueNode ?? "",
                lhs.message
            ) < (
                rhs.shapeIRI,
                rhs.focusNode,
                rhs.pathIRI ?? "",
                rhs.sourceConstraintIRI ?? "",
                rhs.valueNode ?? "",
                rhs.message
            )
        }

        let violationCount = sortedViolations.filter { $0.severity == .violation }.count

        if sortedViolations.isEmpty {
            return SHACLValidationResult(
                conforms: true,
                message: "SHACL Core subset validation passed for \(parsedShapes.shapes.count) shapes.",
                violations: []
            )
        }

        return SHACLValidationResult(
            conforms: violationCount == 0,
            message: "SHACL Core subset validation produced \(sortedViolations.count) result(s), including \(violationCount) violation(s).",
            violations: sortedViolations
        )
    }

    public func validate<DataSource, ShapesSource, DataAdapter: SHACLDataGraphAdapting, ShapesAdapter: SHACLShapesGraphAdapting>(
        dataSource: DataSource,
        shapesSource: ShapesSource,
        dataAdapter: DataAdapter,
        shapesAdapter: ShapesAdapter
    ) throws -> SHACLValidationResult
    where DataAdapter.Source == DataSource, ShapesAdapter.Source == ShapesSource {
        let dataGraph = try dataAdapter.adapt(dataSource)
        let shapesGraph = try shapesAdapter.adapt(shapesSource)
        return try validate(dataGraph: dataGraph, shapesGraph: shapesGraph)
    }

    private func validateShapesGraph(_ shapesGraph: SHACLShapesGraph) throws {
        let byIRI = Dictionary(uniqueKeysWithValues: shapesGraph.shapes.map { ($0.shapeIRI, $0) })
        let expressionByIRI = Dictionary(uniqueKeysWithValues: shapesGraph.nodeExpressions.map { ($0.expressionIRI, $0) })

        for shape in shapesGraph.shapes where shape.kind == .nodeShape {
            for propertyShapeIRI in shape.propertyShapeIRIs {
                guard let propertyShape = byIRI[propertyShapeIRI], propertyShape.kind == .propertyShape else {
                    throw SHACLError.invalidShapesGraph(
                        "Node shape \(shape.shapeIRI) references missing or non-property shape \(propertyShapeIRI)"
                    )
                }
            }
        }

        for shape in shapesGraph.shapes where shape.kind == .propertyShape {
            if shape.pathIRI == nil && shape.expressionIRI == nil {
                throw SHACLError.invalidShapesGraph("Property shape \(shape.shapeIRI) is missing both sh:path and sh:expression")
            }
            if let expressionIRI = shape.expressionIRI, expressionByIRI[expressionIRI] == nil {
                throw SHACLError.invalidShapesGraph(
                    "Property shape \(shape.shapeIRI) references missing node expression \(expressionIRI)"
                )
            }

            let referencedNodeShapeIRIs =
                [shape.nodeShapeReferenceIRI, shape.notShapeIRI, shape.qualifiedValueShapeIRI].compactMap { $0 }
                + shape.andShapeIRIs
                + shape.orShapeIRIs
                + shape.xoneShapeIRIs

            for referencedIRI in referencedNodeShapeIRIs {
                guard let nodeShape = byIRI[referencedIRI], nodeShape.kind == .nodeShape else {
                    throw SHACLError.invalidShapesGraph(
                        "Property shape \(shape.shapeIRI) references missing or non-node shape \(referencedIRI)"
                    )
                }
            }
        }
    }

    private func evaluate(
        nodeShape: SHACLShapeDefinition,
        focusNode: String,
        dataGraph: SHACLDataGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition] = [:],
        depth: Int,
        visited: inout Set<String>
    ) -> [SHACLViolation] {
        var violations: [SHACLViolation] = []
        if depth > maxReferenceDepth {
            return violations
        }
        let nodeSeverity = nodeShape.severity ?? .violation
        let expressionGraph = SHACLShapesGraph(
            shapes: [],
            nodeExpressions: Array(nodeExpressionsByIRI.values)
        )

        if let classIRI = nodeShape.classIRI {
            let hasRequiredType = dataGraph.triples.contains {
                $0.subject == focusNode && $0.predicate == SHACLIRIs.rdfType && $0.object == classIRI
            }
            if !hasRequiredType {
                violations.append(
                    SHACLViolation(
                        severity: nodeSeverity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: focusNode,
                        sourceConstraintIRI: SHACLIRIs.class,
                        message: "class violation: focus node \(focusNode) is not typed as \(classIRI)"
                    )
                )
            }
        }

        if let nodeKind = nodeShape.nodeKind, !matchesNodeKind(focusNode, nodeKind: nodeKind) {
            violations.append(
                SHACLViolation(
                    severity: nodeSeverity,
                    shapeIRI: nodeShape.shapeIRI,
                    focusNode: focusNode,
                    pathIRI: nil,
                    valueNode: focusNode,
                    sourceConstraintIRI: SHACLIRIs.nodeKind,
                    message: "nodeKind violation: focus node \(focusNode) does not satisfy \(nodeKind.rawValue)"
                )
            )
        }

        if let expressionIRI = nodeShape.expressionIRI {
            let outputNodes = SHACLNodeExpressionEvaluator().evaluate(
                expressionIRI: expressionIRI,
                focusNode: focusNode,
                shapesGraph: expressionGraph
            )
            if !isTrueOnlyExpressionOutput(outputNodes) {
                violations.append(
                    SHACLViolation(
                        severity: nodeSeverity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: focusNode,
                        sourceConstraintIRI: SHACLIRIs.expression,
                        message: "expression violation: expression \(expressionIRI) did not return true for focus node \(focusNode)"
                    )
                )
            }
        }

        for propertyShapeIRI in nodeShape.propertyShapeIRIs {
            guard let propertyShape = shapesByIRI[propertyShapeIRI], propertyShape.kind == .propertyShape else {
                continue
            }
            let pathIRI = propertyShape.pathIRI
            let expressionIRI = propertyShape.expressionIRI
            if pathIRI == nil && expressionIRI == nil {
                continue
            }
            let severity = propertyShape.severity ?? nodeShape.severity ?? .violation

            let values: [String]
            if let pathIRI {
                values = dataGraph.triples
                    .filter { $0.subject == focusNode && $0.predicate == pathIRI }
                    .map(\.object)
            } else if let expressionIRI {
                values = SHACLNodeExpressionEvaluator()
                    .evaluate(
                        expressionIRI: expressionIRI,
                        focusNode: focusNode,
                        shapesGraph: expressionGraph
                    )
                    .sorted()
            } else {
                values = []
            }
            let valueCount = values.count

            if let expressionIRI, pathIRI != nil {
                for valueNode in values {
                    let outputNodes = SHACLNodeExpressionEvaluator().evaluate(
                        expressionIRI: expressionIRI,
                        focusNode: valueNode,
                        shapesGraph: expressionGraph
                    )
                    if !isTrueOnlyExpressionOutput(outputNodes) {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.expression,
                                message: "expression violation: expression \(expressionIRI) did not return true for value \(valueNode)"
                            )
                        )
                    }
                }
            }

            if let minCount = propertyShape.minCount, valueCount < minCount {
                violations.append(
                    SHACLViolation(
                        severity: severity,
                        shapeIRI: propertyShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: pathIRI,
                        sourceConstraintIRI: SHACLIRIs.minCount,
                        message: "minCount violation: expected >= \(minCount), got \(valueCount)"
                    )
                )
            }

            if let maxCount = propertyShape.maxCount, valueCount > maxCount {
                violations.append(
                    SHACLViolation(
                        severity: severity,
                        shapeIRI: propertyShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: pathIRI,
                        sourceConstraintIRI: SHACLIRIs.maxCount,
                        message: "maxCount violation: expected <= \(maxCount), got \(valueCount)"
                    )
                )
            }

            if let classIRI = propertyShape.classIRI {
                for valueNode in values {
                    let hasRequiredType = dataGraph.triples.contains {
                        $0.subject == valueNode && $0.predicate == SHACLIRIs.rdfType && $0.object == classIRI
                    }
                    if !hasRequiredType {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.class,
                                message: "class violation: value \(valueNode) is not typed as \(classIRI)"
                            )
                        )
                    }
                }
            }

            if let nodeKind = propertyShape.nodeKind {
                for valueNode in values {
                    if !matchesNodeKind(valueNode, nodeKind: nodeKind) {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.nodeKind,
                                message: "nodeKind violation: value \(valueNode) does not satisfy \(nodeKind.rawValue)"
                            )
                        )
                    }
                }
            }

            if let datatypeIRI = propertyShape.datatypeIRI {
                for valueNode in values {
                    let actualDatatype = inferredDatatypeIRI(for: valueNode)
                    if actualDatatype != datatypeIRI {
                        let actualText = actualDatatype ?? "none"
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.datatype,
                                message: "datatype violation: value \(valueNode) has datatype \(actualText), expected \(datatypeIRI)"
                            )
                        )
                    }
                }
            }

            if propertyShape.minLength != nil || propertyShape.maxLength != nil || propertyShape.pattern != nil {
                for valueNode in values {
                    guard let lexical = extractLiteralLexicalForm(valueNode) else {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.minLength,
                                message: "string facet violation: value \(valueNode) is not a literal"
                            )
                        )
                        continue
                    }

                    if let minLength = propertyShape.minLength, lexical.count < minLength {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.minLength,
                                message: "minLength violation: expected >= \(minLength), got \(lexical.count)"
                            )
                        )
                    }

                    if let maxLength = propertyShape.maxLength, lexical.count > maxLength {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.maxLength,
                                message: "maxLength violation: expected <= \(maxLength), got \(lexical.count)"
                            )
                        )
                    }

                    if let pattern = propertyShape.pattern {
                        let range = NSRange(lexical.startIndex..<lexical.endIndex, in: lexical)
                        let regex = try? NSRegularExpression(pattern: pattern)
                        let matches = regex?.firstMatch(in: lexical, options: [], range: range) != nil
                        if !matches {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.pattern,
                                    message: "pattern violation: value \(lexical) does not match \(pattern)"
                                )
                            )
                        }
                    }
                }
            }

            if propertyShape.minInclusive != nil || propertyShape.maxInclusive != nil {
                for valueNode in values {
                    guard let numeric = extractIntegerValue(valueNode) else {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: propertyShape.minInclusive != nil ? SHACLIRIs.minInclusive : SHACLIRIs.maxInclusive,
                                message: "range violation: value \(valueNode) is not an integer literal"
                            )
                        )
                        continue
                    }

                    if let minimum = propertyShape.minInclusive, numeric < minimum {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.minInclusive,
                                message: "minInclusive violation: expected >= \(minimum), got \(numeric)"
                            )
                        )
                    }

                    if let maximum = propertyShape.maxInclusive, numeric > maximum {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.maxInclusive,
                                message: "maxInclusive violation: expected <= \(maximum), got \(numeric)"
                            )
                        )
                    }
                }
            }

            if let requiredValue = propertyShape.hasValue {
                let hasRequiredValue = values.contains(requiredValue)
                if !hasRequiredValue {
                    violations.append(
                        SHACLViolation(
                            severity: severity,
                            shapeIRI: propertyShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: pathIRI,
                            sourceConstraintIRI: SHACLIRIs.hasValue,
                            message: "hasValue violation: required value \(requiredValue) not present"
                        )
                    )
                }
            }

            if !propertyShape.inValues.isEmpty {
                let allowed = Set(propertyShape.inValues)
                for valueNode in values {
                    if !allowed.contains(valueNode) {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.in,
                                message: "in violation: value \(valueNode) not in allowed set"
                            )
                        )
                    }
                }
            }

            if let nodeReference = propertyShape.nodeShapeReferenceIRI,
               let referencedShape = shapesByIRI[nodeReference],
               referencedShape.kind == .nodeShape {
                for valueNode in values {
                    let key = "\(referencedShape.shapeIRI)|\(valueNode)"
                    if visited.contains(key) {
                        continue
                    }
                    visited.insert(key)
                    let nestedViolations = evaluate(
                        nodeShape: referencedShape,
                        focusNode: valueNode,
                        dataGraph: dataGraph,
                        shapesByIRI: shapesByIRI,
                        nodeExpressionsByIRI: nodeExpressionsByIRI,
                        depth: depth + 1,
                        visited: &visited
                    )
                    visited.remove(key)
                    violations.append(contentsOf: nestedViolations)
                }
            }

            if !propertyShape.andShapeIRIs.isEmpty {
                for valueNode in values {
                    let matchesAll = propertyShape.andShapeIRIs.allSatisfy { shapeIRI in
                        conforms(
                            valueNode: valueNode,
                            toNodeShapeIRI: shapeIRI,
                            dataGraph: dataGraph,
                            shapesByIRI: shapesByIRI,
                            nodeExpressionsByIRI: nodeExpressionsByIRI,
                            depth: depth,
                            visited: &visited
                        )
                    }
                    if !matchesAll {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.and,
                                message: "and violation: value \(valueNode) does not satisfy all referenced shapes"
                            )
                        )
                    }
                }
            }

            if !propertyShape.orShapeIRIs.isEmpty {
                for valueNode in values {
                    let matchesAny = propertyShape.orShapeIRIs.contains { shapeIRI in
                        conforms(
                            valueNode: valueNode,
                            toNodeShapeIRI: shapeIRI,
                            dataGraph: dataGraph,
                            shapesByIRI: shapesByIRI,
                            nodeExpressionsByIRI: nodeExpressionsByIRI,
                            depth: depth,
                            visited: &visited
                        )
                    }
                    if !matchesAny {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.or,
                                message: "or violation: value \(valueNode) does not satisfy any referenced shape"
                            )
                        )
                    }
                }
            }

            if let forbiddenShapeIRI = propertyShape.notShapeIRI {
                for valueNode in values {
                    let matchesForbidden = conforms(
                        valueNode: valueNode,
                        toNodeShapeIRI: forbiddenShapeIRI,
                        dataGraph: dataGraph,
                        shapesByIRI: shapesByIRI,
                        nodeExpressionsByIRI: nodeExpressionsByIRI,
                        depth: depth,
                        visited: &visited
                    )
                    if matchesForbidden {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.not,
                                message: "not violation: value \(valueNode) conforms to forbidden shape"
                            )
                        )
                    }
                }
            }

            if !propertyShape.xoneShapeIRIs.isEmpty {
                for valueNode in values {
                    let matchCount = propertyShape.xoneShapeIRIs.reduce(into: 0) { count, shapeIRI in
                        if conforms(
                            valueNode: valueNode,
                            toNodeShapeIRI: shapeIRI,
                            dataGraph: dataGraph,
                            shapesByIRI: shapesByIRI,
                            nodeExpressionsByIRI: nodeExpressionsByIRI,
                            depth: depth,
                            visited: &visited
                        ) {
                            count += 1
                        }
                    }

                    if matchCount != 1 {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.xone,
                                message: "xone violation: value \(valueNode) matched \(matchCount) referenced shapes"
                            )
                        )
                    }
                }
            }

            if let qualifiedShapeIRI = propertyShape.qualifiedValueShapeIRI {
                let qualifiedMatchCount = values.reduce(into: 0) { count, valueNode in
                    if conforms(
                        valueNode: valueNode,
                        toNodeShapeIRI: qualifiedShapeIRI,
                        dataGraph: dataGraph,
                        shapesByIRI: shapesByIRI,
                        nodeExpressionsByIRI: nodeExpressionsByIRI,
                        depth: depth,
                        visited: &visited
                    ) {
                        count += 1
                    }
                }

                if let qualifiedMin = propertyShape.qualifiedMinCount, qualifiedMatchCount < qualifiedMin {
                    violations.append(
                        SHACLViolation(
                            severity: severity,
                            shapeIRI: propertyShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: pathIRI,
                            sourceConstraintIRI: SHACLIRIs.qualifiedMinCount,
                            message: "qualifiedMinCount violation: expected >= \(qualifiedMin), got \(qualifiedMatchCount)"
                        )
                    )
                }

                if let qualifiedMax = propertyShape.qualifiedMaxCount, qualifiedMatchCount > qualifiedMax {
                    violations.append(
                        SHACLViolation(
                            severity: severity,
                            shapeIRI: propertyShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: pathIRI,
                            sourceConstraintIRI: SHACLIRIs.qualifiedMaxCount,
                            message: "qualifiedMaxCount violation: expected <= \(qualifiedMax), got \(qualifiedMatchCount)"
                        )
                    )
                }
            }
        }

        return violations
    }

    private func conforms(
        valueNode: String,
        toNodeShapeIRI shapeIRI: String,
        dataGraph: SHACLDataGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition] = [:],
        depth: Int,
        visited: inout Set<String>
    ) -> Bool {
        guard let nodeShape = shapesByIRI[shapeIRI], nodeShape.kind == .nodeShape else {
            return false
        }

        let key = "\(nodeShape.shapeIRI)|\(valueNode)"
        if visited.contains(key) {
            return true
        }

        visited.insert(key)
        defer { visited.remove(key) }

        let nestedViolations = evaluate(
            nodeShape: nodeShape,
            focusNode: valueNode,
            dataGraph: dataGraph,
            shapesByIRI: shapesByIRI,
            nodeExpressionsByIRI: nodeExpressionsByIRI,
            depth: depth + 1,
            visited: &visited
        )
        return !nestedViolations.contains { $0.severity == .violation }
    }

    private func matchesNodeKind(_ value: String, nodeKind: SHACLNodeKindConstraint) -> Bool {
        let isLiteral = value.allSatisfy { $0.isNumber } || value.hasPrefix("\"")
        let isBlankNode = value.hasPrefix("_:")
        let isIRI = !isLiteral && !isBlankNode && (value.contains("://") || value.hasPrefix("urn:"))

        switch nodeKind {
        case .iri:
            return isIRI
        case .literal:
            return isLiteral
        case .blankNode:
            return isBlankNode
        case .blankNodeOrIRI:
            return isBlankNode || isIRI
        case .blankNodeOrLiteral:
            return isBlankNode || isLiteral
        case .iriOrLiteral:
            return isIRI || isLiteral
        }
    }

    private func inferredDatatypeIRI(for value: String) -> String? {
        if value.allSatisfy({ $0.isNumber }) {
            return SHACLIRIs.xsdInteger
        }

        guard value.hasPrefix("\"") else {
            return nil
        }

        if let typedRange = value.range(of: "^^") {
            return String(value[typedRange.upperBound...])
        }

        if value.contains("\"@") {
            return SHACLIRIs.rdfLangString
        }

        return SHACLIRIs.xsdString
    }

    private func extractLiteralLexicalForm(_ value: String) -> String? {
        guard value.hasPrefix("\"") else {
            return nil
        }
        guard let closing = value.dropFirst().firstIndex(of: "\"") else {
            return nil
        }
        let start = value.index(after: value.startIndex)
        return String(value[start..<closing])
    }

    private func extractIntegerValue(_ value: String) -> Int? {
        if let direct = Int(value) {
            return direct
        }

        guard let lexical = extractLiteralLexicalForm(value) else {
            return nil
        }
        return Int(lexical)
    }

    private func isTrueOnlyExpressionOutput(_ outputNodes: Set<String>) -> Bool {
        guard outputNodes.count == 1, let only = outputNodes.first else {
            return false
        }
        return only == "true"
            || only == "1"
            || only == "\"true\""
            || only == "\"true\"^^\(SHACLIRIs.xsdBoolean)"
            || only == "\"1\"^^\(SHACLIRIs.xsdBoolean)"
    }
}

private enum SHACLIRIs {
    static let rdfType = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
    static let rdfFirst = "http://www.w3.org/1999/02/22-rdf-syntax-ns#first"
    static let rdfRest = "http://www.w3.org/1999/02/22-rdf-syntax-ns#rest"
    static let rdfNil = "http://www.w3.org/1999/02/22-rdf-syntax-ns#nil"
    static let nodeShape = "http://www.w3.org/ns/shacl#NodeShape"
    static let propertyShape = "http://www.w3.org/ns/shacl#PropertyShape"
    static let targetClass = "http://www.w3.org/ns/shacl#targetClass"
    static let targetNode = "http://www.w3.org/ns/shacl#targetNode"
    static let targetSubjectsOf = "http://www.w3.org/ns/shacl#targetSubjectsOf"
    static let targetObjectsOf = "http://www.w3.org/ns/shacl#targetObjectsOf"
    static let severity = "http://www.w3.org/ns/shacl#severity"
    static let property = "http://www.w3.org/ns/shacl#property"
    static let path = "http://www.w3.org/ns/shacl#path"
    static let `class` = "http://www.w3.org/ns/shacl#class"
    static let nodeKind = "http://www.w3.org/ns/shacl#nodeKind"
    static let datatype = "http://www.w3.org/ns/shacl#datatype"
    static let minLength = "http://www.w3.org/ns/shacl#minLength"
    static let maxLength = "http://www.w3.org/ns/shacl#maxLength"
    static let minInclusive = "http://www.w3.org/ns/shacl#minInclusive"
    static let maxInclusive = "http://www.w3.org/ns/shacl#maxInclusive"
    static let pattern = "http://www.w3.org/ns/shacl#pattern"
    static let hasValue = "http://www.w3.org/ns/shacl#hasValue"
    static let `in` = "http://www.w3.org/ns/shacl#in"
    static let node = "http://www.w3.org/ns/shacl#node"
    static let and = "http://www.w3.org/ns/shacl#and"
    static let or = "http://www.w3.org/ns/shacl#or"
    static let not = "http://www.w3.org/ns/shacl#not"
    static let xone = "http://www.w3.org/ns/shacl#xone"
    static let qualifiedValueShape = "http://www.w3.org/ns/shacl#qualifiedValueShape"
    static let qualifiedMinCount = "http://www.w3.org/ns/shacl#qualifiedMinCount"
    static let qualifiedMaxCount = "http://www.w3.org/ns/shacl#qualifiedMaxCount"
    static let rule = "http://www.w3.org/ns/shacl#rule"
    static let condition = "http://www.w3.org/ns/shacl#condition"
    static let sparql = "http://www.w3.org/ns/shacl#sparql"
    static let select = "http://www.w3.org/ns/shacl#select"
    static let ask = "http://www.w3.org/ns/shacl#ask"
    static let prefixes = "http://www.w3.org/ns/shacl#prefixes"
    static let target = "http://www.w3.org/ns/shacl#target"
    static let expression = "http://www.w3.org/ns/shacl#expression"
    static let union = "http://www.w3.org/ns/shacl#union"
    static let intersection = "http://www.w3.org/ns/shacl#intersection"
    static let shThis = "http://www.w3.org/ns/shacl#this"
    static let minCount = "http://www.w3.org/ns/shacl#minCount"
    static let maxCount = "http://www.w3.org/ns/shacl#maxCount"
    static let nodeKindIRI = "http://www.w3.org/ns/shacl#IRI"
    static let nodeKindLiteral = "http://www.w3.org/ns/shacl#Literal"
    static let nodeKindBlankNode = "http://www.w3.org/ns/shacl#BlankNode"
    static let nodeKindBlankNodeOrIRI = "http://www.w3.org/ns/shacl#BlankNodeOrIRI"
    static let nodeKindBlankNodeOrLiteral = "http://www.w3.org/ns/shacl#BlankNodeOrLiteral"
    static let nodeKindIRIOrLiteral = "http://www.w3.org/ns/shacl#IRIOrLiteral"
    static let severityViolation = "http://www.w3.org/ns/shacl#Violation"
    static let severityWarning = "http://www.w3.org/ns/shacl#Warning"
    static let severityInfo = "http://www.w3.org/ns/shacl#Info"
    static let xsdInteger = "http://www.w3.org/2001/XMLSchema#integer"
    static let xsdBoolean = "http://www.w3.org/2001/XMLSchema#boolean"
    static let xsdString = "http://www.w3.org/2001/XMLSchema#string"
    static let rdfLangString = "http://www.w3.org/1999/02/22-rdf-syntax-ns#langString"
    static let phaseGatedPredicates: Set<String> = [
        rule,
        condition,
        sparql,
        select,
        ask,
        prefixes,
        target,
    ]
}

private struct SHACLTriple {
    let subject: String
    let predicate: String
    let object: String
}

private struct SHACLTurtleSubsetParser {
    let source: String

    func parseTriples() throws -> [SHACLTriple] {
        let parsed = try extractPrefixesAndBody(from: source)
        let statements = splitStatements(from: parsed.body)

        var triples: [SHACLTriple] = []
        var listCounter = 0

        for statement in statements {
            if statement.isEmpty {
                continue
            }
            triples.append(
                contentsOf: try parseStatement(
                    statement,
                    prefixes: parsed.prefixes,
                    listCounter: &listCounter
                )
            )
        }

        return triples
    }

    private func extractPrefixesAndBody(from source: String) throws -> (prefixes: [String: String], body: String) {
        var prefixes: [String: String] = [:]
        var bodyLines: [String] = []

        for rawLine in source.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = String(rawLine).trimmingCharacters(in: .whitespacesAndNewlines)

            if line.isEmpty || line.hasPrefix("#") {
                continue
            }

            if line.hasPrefix("@prefix") {
                let pattern = #"^@prefix\s+([A-Za-z][A-Za-z0-9_-]*):\s*<([^>]+)>\s*\.\s*$"#
                guard let regex = try? NSRegularExpression(pattern: pattern) else {
                    throw SHACLError.invalidPrefixDeclaration(line)
                }
                let range = NSRange(line.startIndex..<line.endIndex, in: line)
                guard let match = regex.firstMatch(in: line, options: [], range: range),
                      let prefixRange = Range(match.range(at: 1), in: line),
                      let iriRange = Range(match.range(at: 2), in: line) else {
                    throw SHACLError.invalidPrefixDeclaration(line)
                }
                let prefix = String(line[prefixRange])
                let iri = String(line[iriRange])
                prefixes[prefix] = iri
            } else {
                bodyLines.append(String(rawLine))
            }
        }

        return (prefixes, bodyLines.joined(separator: "\n"))
    }

    private func splitStatements(from body: String) -> [String] {
        var statements: [String] = []
        var current = ""
        var inIRI = false
        var inString = false

        for ch in body {
            if ch == "<" && !inString {
                inIRI = true
            } else if ch == ">" && inIRI {
                inIRI = false
            } else if ch == "\"" {
                inString.toggle()
            }

            if ch == "." && !inIRI && !inString {
                let trimmed = current.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    statements.append(trimmed)
                }
                current = ""
            } else {
                current.append(ch)
            }
        }

        let tail = current.trimmingCharacters(in: .whitespacesAndNewlines)
        if !tail.isEmpty {
            statements.append(tail)
        }

        return statements
    }

    private func parseStatement(
        _ statement: String,
        prefixes: [String: String],
        listCounter: inout Int
    ) throws -> [SHACLTriple] {
        let tokens = try tokenize(statement)
        guard !tokens.isEmpty else {
            return []
        }

        var index = 0

        func takeToken() -> String? {
            guard index < tokens.count else {
                return nil
            }
            defer { index += 1 }
            return tokens[index]
        }

        guard let subjectToken = takeToken() else {
            throw SHACLError.invalidStatement(statement)
        }
        let subject = try resolveTerm(subjectToken, prefixes: prefixes)

        var triples: [SHACLTriple] = []

        while index < tokens.count {
            guard let predicateToken = takeToken() else {
                throw SHACLError.invalidStatement(statement)
            }

            if predicateToken == ";" {
                continue
            }

            let predicate = try resolveTerm(predicateToken, prefixes: prefixes)

            guard let firstObjectToken = takeToken() else {
                throw SHACLError.invalidStatement(statement)
            }

            if firstObjectToken == ";" || firstObjectToken == "," {
                throw SHACLError.invalidStatement(statement)
            }

            let firstObject: String
            if firstObjectToken == "(" {
                firstObject = try parseObjectList(
                    tokens: tokens,
                    index: &index,
                    prefixes: prefixes,
                    triples: &triples,
                    listCounter: &listCounter,
                    statement: statement
                )
            } else {
                firstObject = try resolveTerm(firstObjectToken, prefixes: prefixes)
            }

            var objects: [String] = [firstObject]

            while index < tokens.count, tokens[index] == "," {
                _ = takeToken()
                guard let nextObject = takeToken(), nextObject != ";", nextObject != "," else {
                    throw SHACLError.invalidStatement(statement)
                }
                if nextObject == "(" {
                    objects.append(
                        try parseObjectList(
                            tokens: tokens,
                            index: &index,
                            prefixes: prefixes,
                            triples: &triples,
                            listCounter: &listCounter,
                            statement: statement
                        )
                    )
                } else {
                    objects.append(try resolveTerm(nextObject, prefixes: prefixes))
                }
            }

            for object in objects {
                triples.append(SHACLTriple(subject: subject, predicate: predicate, object: object))
            }

            if index < tokens.count {
                let separator = tokens[index]
                if separator == ";" {
                    _ = takeToken()
                } else {
                    throw SHACLError.invalidStatement(statement)
                }
            }
        }

        return triples
    }

    private func parseObjectList(
        tokens: [String],
        index: inout Int,
        prefixes: [String: String],
        triples: inout [SHACLTriple],
        listCounter: inout Int,
        statement: String
    ) throws -> String {
        var values: [String] = []
        var sawClose = false

        while index < tokens.count {
            let token = tokens[index]
            if token == ")" {
                index += 1
                sawClose = true
                break
            }
            if token == "(" || token == ";" || token == "," {
                throw SHACLError.invalidStatement(statement)
            }
            values.append(try resolveTerm(token, prefixes: prefixes))
            index += 1
        }

        if !sawClose {
            throw SHACLError.invalidStatement(statement)
        }

        if values.isEmpty {
            return SHACLIRIs.rdfNil
        }

        func nextListNode() -> String {
            defer { listCounter += 1 }
            return "_:ListNode\(listCounter)"
        }

        let head = nextListNode()
        var current = head

        for position in values.indices {
            triples.append(
                SHACLTriple(subject: current, predicate: SHACLIRIs.rdfFirst, object: values[position])
            )
            let isLast = position == values.count - 1
            let next = isLast ? SHACLIRIs.rdfNil : nextListNode()
            triples.append(
                SHACLTriple(subject: current, predicate: SHACLIRIs.rdfRest, object: next)
            )
            current = next
        }

        return head
    }

    private func tokenize(_ statement: String) throws -> [String] {
        var tokens: [String] = []
        var index = statement.startIndex

        while index < statement.endIndex {
            let ch = statement[index]

            if ch.isWhitespace {
                index = statement.index(after: index)
                continue
            }

            if ch == ";" || ch == "," || ch == "(" || ch == ")" {
                tokens.append(String(ch))
                index = statement.index(after: index)
                continue
            }

            if ch == "<" {
                guard let close = statement[index...].firstIndex(of: ">") else {
                    throw SHACLError.invalidStatement(statement)
                }
                tokens.append(String(statement[index...close]))
                index = statement.index(after: close)
                continue
            }

            if ch == "\"" {
                var end = statement.index(after: index)
                var escaped = false
                while end < statement.endIndex {
                    let c = statement[end]
                    if c == "\\" && !escaped {
                        escaped = true
                        end = statement.index(after: end)
                        continue
                    }
                    if c == "\"" && !escaped {
                        break
                    }
                    escaped = false
                    end = statement.index(after: end)
                }
                guard end < statement.endIndex else {
                    throw SHACLError.invalidStatement(statement)
                }
                var token = String(statement[index...end])
                var probe = statement.index(after: end)

                if probe < statement.endIndex, statement[probe] == "@" {
                    let langStart = probe
                    probe = statement.index(after: probe)
                    var langEnd = probe
                    while langEnd < statement.endIndex,
                          !statement[langEnd].isWhitespace,
                          statement[langEnd] != ";",
                          statement[langEnd] != "," {
                        langEnd = statement.index(after: langEnd)
                    }
                    token += String(statement[langStart..<langEnd])
                    probe = langEnd
                } else if probe < statement.endIndex, statement[probe] == "^" {
                    let next = statement.index(after: probe)
                    guard next < statement.endIndex, statement[next] == "^" else {
                        throw SHACLError.invalidStatement(statement)
                    }
                    probe = statement.index(after: next)
                    var dtEnd = probe
                    while dtEnd < statement.endIndex,
                          !statement[dtEnd].isWhitespace,
                          statement[dtEnd] != ";",
                          statement[dtEnd] != "," {
                        dtEnd = statement.index(after: dtEnd)
                    }
                    token += "^^" + String(statement[probe..<dtEnd])
                    probe = dtEnd
                }

                tokens.append(token)
                index = probe
                continue
            }

            var end = index
            while end < statement.endIndex,
                  !statement[end].isWhitespace,
                  statement[end] != ";",
                  statement[end] != "," {
                end = statement.index(after: end)
            }

            tokens.append(String(statement[index..<end]))
            index = end
        }

        return tokens
    }

    private func resolveTerm(_ token: String, prefixes: [String: String]) throws -> String {
        if token == "a" {
            return SHACLIRIs.rdfType
        }

        if token.hasPrefix("<") && token.hasSuffix(">") {
            return String(token.dropFirst().dropLast())
        }

        if token.allSatisfy({ $0.isNumber }) {
            return token
        }

        if token.hasPrefix("_:") {
            return token
        }

        if token.hasPrefix("\"") {
            if let typedRange = token.range(of: "^^") {
                let literal = String(token[..<typedRange.lowerBound])
                let datatypeToken = String(token[typedRange.upperBound...])
                let datatypeIRI = try resolveIRIReference(datatypeToken, prefixes: prefixes)
                return literal + "^^" + datatypeIRI
            }
            return token
        }

        return try resolveIRIReference(token, prefixes: prefixes)
    }

    private func resolveIRIReference(_ token: String, prefixes: [String: String]) throws -> String {
        if let colon = token.firstIndex(of: ":") {
            let prefix = String(token[..<colon])
            let local = String(token[token.index(after: colon)...])

            guard let namespace = prefixes[prefix] else {
                throw SHACLError.unknownPrefix(prefix)
            }
            return namespace + local
        }

        throw SHACLError.unsupportedTerm(token)
    }
}
