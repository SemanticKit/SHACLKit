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
    case targetNodeExpression(String)
    case targetSubjectsOf(String)
    case targetObjectsOf(String)
    case targetWhere(String)
}

public enum SHACLNodeKindConstraint: String, Sendable, Codable, Hashable {
    case iri
    case literal
    case blankNode
    case blankNodeOrIRI
    case blankNodeOrLiteral
    case iriOrLiteral
}

public indirect enum SHACLPropertyPath: Sendable, Hashable {
    case predicate(String)
    case inverse(SHACLPropertyPath)
    case sequence([SHACLPropertyPath])
    case alternative([SHACLPropertyPath])
    case zeroOrMore(SHACLPropertyPath)
    case oneOrMore(SHACLPropertyPath)
    case zeroOrOne(SHACLPropertyPath)
}

public struct SHACLShapeDefinition: Sendable, Hashable {
    public let shapeIRI: String
    public let kind: SHACLShapeKind
    public let isRDFSClass: Bool
    public let isDeactivated: Bool
    public let severity: SHACLSeverity?
    public let targets: [SHACLTargetSelector]
    public let propertyShapeIRIs: [String]
    public let tripleRuleIRIs: [String]
    public let sparqlConstraintIRIs: [String]
    public let sparqlTargetIRIs: [String]
    public let pathIRI: String?
    public let propertyPath: SHACLPropertyPath?
    public let expressionIRI: String?
    public let classIRI: String?
    public let nodeKind: SHACLNodeKindConstraint?
    public let datatypeIRI: String?
    public let minLength: Int?
    public let maxLength: Int?
    public let singleLine: Bool
    public let minListLength: Int?
    public let maxListLength: Int?
    public let minInclusive: String?
    public let maxInclusive: String?
    public let minExclusive: String?
    public let maxExclusive: String?
    public let pattern: String?
    public let hasValue: String?
    public let inValues: [String]
    public let languageInValues: [String]
    public let uniqueLang: Bool
    public let uniqueMembers: Bool
    public let equalsIRI: String?
    public let disjointIRI: String?
    public let lessThanIRI: String?
    public let lessThanOrEqualsIRI: String?
    public let isClosed: Bool
    public let ignoredPropertyIRIs: [String]
    public let nodeByExpressionIRI: String?
    public let nodeShapeReferenceIRI: String?
    public let andShapeIRIs: [String]
    public let orShapeIRIs: [String]
    public let xoneShapeIRIs: [String]
    public let notShapeIRI: String?
    public let reifierShapeIRI: String?
    public let reificationRequired: Bool
    public let memberShapeIRI: String?
    public let qualifiedValueShapeIRI: String?
    public let qualifiedValueShapesDisjoint: Bool
    public let qualifiedMinCount: Int?
    public let qualifiedMaxCount: Int?
    public let minCount: Int?
    public let maxCount: Int?

    public init(
        shapeIRI: String,
        kind: SHACLShapeKind,
        isRDFSClass: Bool = false,
        isDeactivated: Bool = false,
        severity: SHACLSeverity? = nil,
        targets: [SHACLTargetSelector],
        propertyShapeIRIs: [String] = [],
        tripleRuleIRIs: [String] = [],
        sparqlConstraintIRIs: [String] = [],
        sparqlTargetIRIs: [String] = [],
        pathIRI: String? = nil,
        propertyPath: SHACLPropertyPath? = nil,
        expressionIRI: String? = nil,
        classIRI: String? = nil,
        nodeKind: SHACLNodeKindConstraint? = nil,
        datatypeIRI: String? = nil,
        minLength: Int? = nil,
        maxLength: Int? = nil,
        singleLine: Bool = false,
        minListLength: Int? = nil,
        maxListLength: Int? = nil,
        minInclusive: String? = nil,
        maxInclusive: String? = nil,
        minExclusive: String? = nil,
        maxExclusive: String? = nil,
        pattern: String? = nil,
        hasValue: String? = nil,
        inValues: [String] = [],
        languageInValues: [String] = [],
        uniqueLang: Bool = false,
        uniqueMembers: Bool = false,
        equalsIRI: String? = nil,
        disjointIRI: String? = nil,
        lessThanIRI: String? = nil,
        lessThanOrEqualsIRI: String? = nil,
        isClosed: Bool = false,
        ignoredPropertyIRIs: [String] = [],
        nodeByExpressionIRI: String? = nil,
        nodeShapeReferenceIRI: String? = nil,
        andShapeIRIs: [String] = [],
        orShapeIRIs: [String] = [],
        xoneShapeIRIs: [String] = [],
        notShapeIRI: String? = nil,
        reifierShapeIRI: String? = nil,
        reificationRequired: Bool = false,
        memberShapeIRI: String? = nil,
        qualifiedValueShapeIRI: String? = nil,
        qualifiedValueShapesDisjoint: Bool = false,
        qualifiedMinCount: Int? = nil,
        qualifiedMaxCount: Int? = nil,
        minCount: Int? = nil,
        maxCount: Int? = nil
    ) {
        self.shapeIRI = shapeIRI
        self.kind = kind
        self.isRDFSClass = isRDFSClass
        self.isDeactivated = isDeactivated
        self.severity = severity
        self.targets = targets
        self.propertyShapeIRIs = propertyShapeIRIs
        self.tripleRuleIRIs = tripleRuleIRIs
        self.sparqlConstraintIRIs = sparqlConstraintIRIs
        self.sparqlTargetIRIs = sparqlTargetIRIs
        self.pathIRI = pathIRI
        self.propertyPath = propertyPath
        self.expressionIRI = expressionIRI
        self.classIRI = classIRI
        self.nodeKind = nodeKind
        self.datatypeIRI = datatypeIRI
        self.minLength = minLength
        self.maxLength = maxLength
        self.singleLine = singleLine
        self.minListLength = minListLength
        self.maxListLength = maxListLength
        self.minInclusive = minInclusive
        self.maxInclusive = maxInclusive
        self.minExclusive = minExclusive
        self.maxExclusive = maxExclusive
        self.pattern = pattern
        self.hasValue = hasValue
        self.inValues = inValues
        self.languageInValues = languageInValues
        self.uniqueLang = uniqueLang
        self.uniqueMembers = uniqueMembers
        self.equalsIRI = equalsIRI
        self.disjointIRI = disjointIRI
        self.lessThanIRI = lessThanIRI
        self.lessThanOrEqualsIRI = lessThanOrEqualsIRI
        self.isClosed = isClosed
        self.ignoredPropertyIRIs = ignoredPropertyIRIs
        self.nodeByExpressionIRI = nodeByExpressionIRI
        self.nodeShapeReferenceIRI = nodeShapeReferenceIRI
        self.andShapeIRIs = andShapeIRIs
        self.orShapeIRIs = orShapeIRIs
        self.xoneShapeIRIs = xoneShapeIRIs
        self.notShapeIRI = notShapeIRI
        self.reifierShapeIRI = reifierShapeIRI
        self.reificationRequired = reificationRequired
        self.memberShapeIRI = memberShapeIRI
        self.qualifiedValueShapeIRI = qualifiedValueShapeIRI
        self.qualifiedValueShapesDisjoint = qualifiedValueShapesDisjoint
        self.qualifiedMinCount = qualifiedMinCount
        self.qualifiedMaxCount = qualifiedMaxCount
        self.minCount = minCount
        self.maxCount = maxCount
    }
}

public struct SHACLShapesGraph: Sendable, Equatable {
    public let shapes: [SHACLShapeDefinition]
    public let nodeExpressions: [SHACLNodeExpressionDefinition]
    public let tripleRules: [SHACLTripleRuleDefinition]
    public let sparqlDefinitions: [SHACLSPARQLDefinition]

    public init(
        shapes: [SHACLShapeDefinition],
        nodeExpressions: [SHACLNodeExpressionDefinition] = [],
        tripleRules: [SHACLTripleRuleDefinition] = [],
        sparqlDefinitions: [SHACLSPARQLDefinition] = []
    ) {
        self.shapes = shapes
        self.nodeExpressions = nodeExpressions
        self.tripleRules = tripleRules
        self.sparqlDefinitions = sparqlDefinitions
    }
}

public enum SHACLNodeExpressionKind: Sendable, Hashable {
    case union([String])
    case intersection([String])
    case nodes([String])
    case exists(String)
    case count(inputTerm: String, staticListLength: Int?)
    case variable(String)
    case distinct(inputTerm: String, staticListMembers: [String]?)
    case matchAll(inputTerm: String, shapeTerm: String, staticListMembers: [String]?)
    case filterShape(inputTerm: String, shapeTerm: String, staticListMembers: [String]?)
    case instancesOf(String)
    case nodesMatching(String)
    case min(inputTerm: String, staticListMembers: [String]?)
    case max(inputTerm: String, staticListMembers: [String]?)
    case sum(inputTerm: String, staticListMembers: [String]?)
    case ifThenElse(condition: String, thenTerm: String, elseTerm: String?)
    case pathValues(path: SHACLPropertyPath, focusNodeTerm: String?)
    case concat(inputTerm: String, staticListMembers: [String]?)
    case remove(inputTerm: String, removeTerm: String, staticInputListMembers: [String]?, staticRemoveListMembers: [String]?)
    case flatMap(inputTerm: String, mapTerm: String, staticInputListMembers: [String]?)
    case limit(inputTerm: String, count: Int, staticListMembers: [String]?)
    case offset(inputTerm: String, count: Int, staticListMembers: [String]?)
    case findFirst(inputTerm: String, shapeTerm: String, staticOrderedInputMembers: [String]?)
    case orderBy(inputTerm: String, keyTerm: String, descending: Bool, staticListMembers: [String]?)
}

public struct SHACLNodeExpressionDefinition: Sendable, Hashable {
    public let expressionIRI: String
    public let kind: SHACLNodeExpressionKind

    public init(expressionIRI: String, kind: SHACLNodeExpressionKind) {
        self.expressionIRI = expressionIRI
        self.kind = kind
    }
}

public struct SHACLTripleRuleDefinition: Sendable, Hashable {
    public let ruleIRI: String
    public let ruleOrder: Double?
    public let conditionShapeIRIs: [String]
    public let subjectTerm: String
    public let predicateTerm: String
    public let objectTerm: String

    public init(
        ruleIRI: String,
        ruleOrder: Double? = nil,
        conditionShapeIRIs: [String] = [],
        subjectTerm: String,
        predicateTerm: String,
        objectTerm: String
    ) {
        self.ruleIRI = ruleIRI
        self.ruleOrder = ruleOrder
        self.conditionShapeIRIs = conditionShapeIRIs
        self.subjectTerm = subjectTerm
        self.predicateTerm = predicateTerm
        self.objectTerm = objectTerm
    }
}

public struct SHACLSPARQLDefinition: Sendable, Hashable {
    public let sparqlIRI: String
    public let selectQuery: String?
    public let askQuery: String?
    public let message: String?
    public let prefixes: [String: String]

    public init(
        sparqlIRI: String,
        selectQuery: String? = nil,
        askQuery: String? = nil,
        message: String? = nil,
        prefixes: [String: String] = [:]
    ) {
        self.sparqlIRI = sparqlIRI
        self.selectQuery = selectQuery
        self.askQuery = askQuery
        self.message = message
        self.prefixes = prefixes
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

public protocol SHACLSPARQLExecutor: Sendable {
    func select(
        query: String,
        focusNode: String?,
        dataGraph: SHACLDataGraph,
        shapesGraph: SHACLShapesGraph
    ) throws -> [String]

    func ask(
        query: String,
        focusNode: String?,
        dataGraph: SHACLDataGraph,
        shapesGraph: SHACLShapesGraph
    ) throws -> Bool
}

public struct SHACLDeniedSPARQLExecutor: SHACLSPARQLExecutor {
    public init() {}

    public func select(
        query: String,
        focusNode: String?,
        dataGraph: SHACLDataGraph,
        shapesGraph: SHACLShapesGraph
    ) throws -> [String] {
        throw SHACLError.notImplemented("SPARQL execution requires an explicit sandboxed SHACLSPARQLExecutor.")
    }

    public func ask(
        query: String,
        focusNode: String?,
        dataGraph: SHACLDataGraph,
        shapesGraph: SHACLShapesGraph
    ) throws -> Bool {
        throw SHACLError.notImplemented("SPARQL execution requires an explicit sandboxed SHACLSPARQLExecutor.")
    }
}

public struct SHACLGuardedSPARQLExecutor: SHACLSPARQLExecutor {
    public let wrappedExecutor: any SHACLSPARQLExecutor
    public let disallowedKeywords: [String]
    public let maxQueryLength: Int?

    public init(
        wrapping wrappedExecutor: any SHACLSPARQLExecutor,
        disallowedKeywords: [String] = ["SERVICE", "MINUS", "VALUES", "LOAD", "CLEAR", "DROP", "CREATE", "ADD", "MOVE", "COPY", "INSERT", "DELETE", "WITH"],
        maxQueryLength: Int? = nil
    ) {
        self.wrappedExecutor = wrappedExecutor
        self.disallowedKeywords = disallowedKeywords
        self.maxQueryLength = maxQueryLength
    }

    public func select(
        query: String,
        focusNode: String?,
        dataGraph: SHACLDataGraph,
        shapesGraph: SHACLShapesGraph
    ) throws -> [String] {
        try enforcePolicy(query: query, requirePreboundThisReference: true)
        return try wrappedExecutor.select(query: query, focusNode: focusNode, dataGraph: dataGraph, shapesGraph: shapesGraph)
    }

    public func ask(
        query: String,
        focusNode: String?,
        dataGraph: SHACLDataGraph,
        shapesGraph: SHACLShapesGraph
    ) throws -> Bool {
        try enforcePolicy(query: query, requirePreboundThisReference: true)
        return try wrappedExecutor.ask(query: query, focusNode: focusNode, dataGraph: dataGraph, shapesGraph: shapesGraph)
    }

    private func enforcePolicy(query: String, requirePreboundThisReference: Bool) throws {
        if let maxQueryLength, query.count > maxQueryLength {
            throw SHACLError.notImplemented("SPARQL query blocked by guard policy: query length exceeds \(maxQueryLength) characters.")
        }

        for keyword in disallowedKeywords where !keyword.isEmpty {
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            let range = NSRange(query.startIndex..<query.endIndex, in: query)
            if regex.firstMatch(in: query, options: [], range: range) != nil {
                throw SHACLError.notImplemented("SPARQL query blocked by guard policy: contains disallowed keyword \(keyword).")
            }
        }

        let preboundVariables = ["this", "path", "value"]
        let preboundRange = NSRange(query.startIndex..<query.endIndex, in: query)
        for variable in preboundVariables {
            let pattern = #"(?i)\bAS\s+\?\#(variable)\b"#
            let regex = try NSRegularExpression(pattern: pattern)
            if regex.firstMatch(in: query, options: [], range: preboundRange) != nil {
                throw SHACLError.notImplemented("SPARQL query blocked by guard policy: query attempts to rebind pre-bound ?\(variable).")
            }
        }

        if requirePreboundThisReference {
            let thisReferencePattern = #"(?i)\?this\b"#
            let thisReferenceRegex = try NSRegularExpression(pattern: thisReferencePattern)
            if thisReferenceRegex.firstMatch(in: query, options: [], range: preboundRange) == nil {
                throw SHACLError.notImplemented("SPARQL query blocked by guard policy: SELECT query does not reference pre-bound ?this.")
            }
        }
    }
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
            var isRDFSClass = false
            var isDeactivated = false
            var severity: SHACLSeverity?
            var targets: Set<SHACLTargetSelector> = []
            var propertyShapeIRIs: Set<String> = []
            var ruleIRIs: Set<String> = []
            var sparqlConstraintIRIs: Set<String> = []
            var sparqlTargetIRIs: Set<String> = []
            var pathIRI: String?
            var expressionIRI: String?
            var classIRI: String?
            var nodeKind: SHACLNodeKindConstraint?
            var nodeKindTerm: String?
            var datatypeIRI: String?
            var minLength: Int?
            var maxLength: Int?
            var singleLine = false
            var minListLength: Int?
            var maxListLength: Int?
            var minInclusive: String?
            var maxInclusive: String?
            var minExclusive: String?
            var maxExclusive: String?
            var pattern: String?
            var hasValue: String?
            var inValues: Set<String> = []
            var languageInValues: Set<String> = []
            var uniqueLang = false
            var uniqueMembers = false
            var equalsIRI: String?
            var disjointIRI: String?
            var lessThanIRI: String?
            var lessThanOrEqualsIRI: String?
            var isClosed = false
            var ignoredPropertyIRIs: Set<String> = []
            var nodeByExpressionIRI: String?
            var nodeShapeReferenceIRI: String?
            var andShapeIRIs: Set<String> = []
            var orShapeIRIs: Set<String> = []
            var xoneShapeIRIs: Set<String> = []
            var notShapeIRI: String?
            var reifierShapeIRI: String?
            var reificationRequired = false
            var memberShapeIRI: String?
            var qualifiedValueShapeIRI: String?
            var qualifiedValueShapesDisjoint = false
            var qualifiedMinCount: Int?
            var qualifiedMaxCount: Int?
            var minCount: Int?
            var maxCount: Int?
        }

        struct PartialNodeExpression {
            var unionMemberObjects: Set<String> = []
            var intersectionMemberObjects: Set<String> = []
            var nodesObjects: Set<String> = []
            var existsObjects: Set<String> = []
            var countObjects: Set<String> = []
            var variableNames: Set<String> = []
            var distinctObjects: Set<String> = []
            var matchAllObjects: Set<String> = []
            var filterShapeObjects: Set<String> = []
            var instancesOfObjects: Set<String> = []
            var nodesMatchingObjects: Set<String> = []
            var minObjects: Set<String> = []
            var maxObjects: Set<String> = []
            var sumObjects: Set<String> = []
            var ifObjects: Set<String> = []
            var thenObjects: Set<String> = []
            var elseObjects: Set<String> = []
            var pathValuesObject: String?
            var pathValuesFocusNodeObject: String?
            var concatObjects: Set<String> = []
            var removeObjects: Set<String> = []
            var flatMapObjects: Set<String> = []
            var limitObjects: Set<String> = []
            var offsetObjects: Set<String> = []
            var findFirstObjects: Set<String> = []
            var orderByObjects: Set<String> = []
            var orderByDescending = false
        }

        struct PartialRule {
            var isTripleRule = false
            var ruleOrder: Double?
            var conditionShapeIRIs: Set<String> = []
            var subjectTerm: String?
            var predicateTerm: String?
            var objectTerm: String?
        }

        struct PartialSPARQL {
            var selectQuery: String?
            var askQuery: String?
            var message: String?
            var prefixesIRIs: Set<String> = []
        }

        var shapes: [String: PartialShape] = [:]
        var nodeExpressions: [String: PartialNodeExpression] = [:]
        var rules: [String: PartialRule] = [:]
        var sparqlDefinitions: [String: PartialSPARQL] = [:]

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
                } else if object == SHACLIRIs.rdfsClass {
                    current.isRDFSClass = true
                } else if object == SHACLIRIs.shapeClass {
                    current.isRDFSClass = true
                }
                if object == SHACLIRIs.tripleRule {
                    var rule = rules[subject] ?? PartialRule()
                    rule.isTripleRule = true
                    rules[subject] = rule
                }
            } else if predicate == SHACLIRIs.targetClass {
                current.targets.insert(.targetClass(object))
            } else if predicate == SHACLIRIs.targetNode {
                current.targets.insert(.targetNode(object))
            } else if predicate == SHACLIRIs.targetSubjectsOf {
                current.targets.insert(.targetSubjectsOf(object))
            } else if predicate == SHACLIRIs.targetObjectsOf {
                current.targets.insert(.targetObjectsOf(object))
            } else if predicate == SHACLIRIs.targetWhere {
                current.targets.insert(.targetWhere(object))
            } else if predicate == SHACLIRIs.severity {
                current.severity = parseSeverity(object)
            } else if predicate == SHACLIRIs.deactivated {
                current.isDeactivated = isTrueBooleanTerm(object)
            } else if predicate == SHACLIRIs.property {
                current.propertyShapeIRIs.insert(object)
            } else if predicate == SHACLIRIs.rule {
                current.ruleIRIs.insert(object)
            } else if predicate == SHACLIRIs.sparql {
                current.sparqlConstraintIRIs.insert(object)
            } else if predicate == SHACLIRIs.target {
                current.sparqlTargetIRIs.insert(object)
            } else if predicate == SHACLIRIs.path {
                current.pathIRI = object
            } else if predicate == SHACLIRIs.expression {
                current.expressionIRI = object
            } else if predicate == SHACLIRIs.class {
                current.classIRI = object
            } else if predicate == SHACLIRIs.nodeKind {
                current.nodeKind = parseNodeKind(object)
                current.nodeKindTerm = object
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
            } else if predicate == SHACLIRIs.singleLine {
                current.singleLine = isStrictTrueBooleanTerm(object)
            } else if predicate == SHACLIRIs.minListLength {
                guard let length = Int(object) else {
                    throw SHACLError.invalidIntegerLiteral(object)
                }
                current.minListLength = length
            } else if predicate == SHACLIRIs.maxListLength {
                guard let length = Int(object) else {
                    throw SHACLError.invalidIntegerLiteral(object)
                }
                current.maxListLength = length
            } else if predicate == SHACLIRIs.minInclusive {
                current.minInclusive = object
            } else if predicate == SHACLIRIs.maxInclusive {
                current.maxInclusive = object
            } else if predicate == SHACLIRIs.minExclusive {
                current.minExclusive = object
            } else if predicate == SHACLIRIs.maxExclusive {
                current.maxExclusive = object
            } else if predicate == SHACLIRIs.pattern {
                current.pattern = parsedLiteralLexicalForm(object)
            } else if predicate == SHACLIRIs.hasValue {
                current.hasValue = object
            } else if predicate == SHACLIRIs.in {
                current.inValues.insert(object)
            } else if predicate == SHACLIRIs.languageIn {
                current.languageInValues.insert(object)
            } else if predicate == SHACLIRIs.uniqueLang {
                current.uniqueLang = isStrictTrueBooleanTerm(object)
            } else if predicate == SHACLIRIs.uniqueMembers {
                current.uniqueMembers = isStrictTrueBooleanTerm(object)
            } else if predicate == SHACLIRIs.equals {
                current.equalsIRI = object
            } else if predicate == SHACLIRIs.disjoint {
                current.disjointIRI = object
            } else if predicate == SHACLIRIs.lessThan {
                current.lessThanIRI = object
            } else if predicate == SHACLIRIs.lessThanOrEquals {
                current.lessThanOrEqualsIRI = object
            } else if predicate == SHACLIRIs.closed {
                current.isClosed = isTrueBooleanTerm(object)
            } else if predicate == SHACLIRIs.ignoredProperties {
                current.ignoredPropertyIRIs.insert(object)
            } else if predicate == SHACLIRIs.nodeByExpression {
                current.nodeByExpressionIRI = object
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
            } else if predicate == SHACLIRIs.reifierShape {
                current.reifierShapeIRI = object
            } else if predicate == SHACLIRIs.reificationRequired {
                current.reificationRequired = isStrictTrueBooleanTerm(object)
            } else if predicate == SHACLIRIs.memberShape {
                current.memberShapeIRI = object
            } else if predicate == SHACLIRIs.qualifiedValueShape {
                current.qualifiedValueShapeIRI = object
            } else if predicate == SHACLIRIs.someValue {
                if current.qualifiedValueShapeIRI == nil {
                    current.qualifiedValueShapeIRI = object
                }
                if current.qualifiedMinCount == nil {
                    current.qualifiedMinCount = 1
                }
            } else if predicate == SHACLIRIs.qualifiedValueShapesDisjoint {
                current.qualifiedValueShapesDisjoint = isTrueBooleanTerm(object)
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
            } else if predicate == SHACLIRIs.condition {
                var rule = rules[subject] ?? PartialRule()
                rule.conditionShapeIRIs.insert(object)
                rules[subject] = rule
            } else if predicate == SHACLIRIs.order {
                guard let order = Double(parsedLiteralLexicalForm(object) ?? object) else {
                    throw SHACLError.invalidShapesGraph("Rule \(subject) has invalid sh:order value \(object)")
                }
                var rule = rules[subject] ?? PartialRule()
                rule.ruleOrder = order
                rules[subject] = rule
            } else if predicate == SHACLIRIs.subject {
                var rule = rules[subject] ?? PartialRule()
                rule.subjectTerm = object
                rules[subject] = rule
            } else if predicate == SHACLIRIs.predicate {
                var rule = rules[subject] ?? PartialRule()
                rule.predicateTerm = object
                rules[subject] = rule
            } else if predicate == SHACLIRIs.object {
                var rule = rules[subject] ?? PartialRule()
                rule.objectTerm = object
                rules[subject] = rule
            } else if predicate == SHACLIRIs.select {
                var sparql = sparqlDefinitions[subject] ?? PartialSPARQL()
                sparql.selectQuery = parsedLiteralLexicalForm(object) ?? object
                sparqlDefinitions[subject] = sparql
            } else if predicate == SHACLIRIs.ask {
                var sparql = sparqlDefinitions[subject] ?? PartialSPARQL()
                sparql.askQuery = parsedLiteralLexicalForm(object) ?? object
                sparqlDefinitions[subject] = sparql
            } else if predicate == SHACLIRIs.message {
                var sparql = sparqlDefinitions[subject] ?? PartialSPARQL()
                sparql.message = parsedLiteralLexicalForm(object) ?? object
                sparqlDefinitions[subject] = sparql
            } else if predicate == SHACLIRIs.prefixes {
                var sparql = sparqlDefinitions[subject] ?? PartialSPARQL()
                sparql.prefixesIRIs.insert(object)
                sparqlDefinitions[subject] = sparql
            }

            shapes[subject] = current

            if predicate == SHACLIRIs.union
                || predicate == SHACLIRIs.shnexUnion
                || predicate == SHACLIRIs.intersection
                || predicate == SHACLIRIs.shnexIntersection {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                if predicate == SHACLIRIs.union || predicate == SHACLIRIs.shnexUnion {
                    expression.unionMemberObjects.insert(object)
                } else {
                    expression.intersectionMemberObjects.insert(object)
                }
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexNodes {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.nodesObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexExists {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.existsObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexCount {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.countObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexVar {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.variableNames.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexDistinct {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.distinctObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexMatchAll {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.matchAllObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexFilterShape {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.filterShapeObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexInstancesOf {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.instancesOfObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexNodesMatching {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.nodesMatchingObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexMin {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.minObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexMax {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.maxObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexSum {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.sumObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexIf {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.ifObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexThen {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.thenObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexElse {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.elseObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexPathValues {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.pathValuesObject = object
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexFocusNode {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.pathValuesFocusNodeObject = object
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexConcat {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.concatObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexRemove {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.removeObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexFlatMap {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.flatMapObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexLimit {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.limitObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexOffset {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.offsetObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexFindFirst {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.findFirstObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexOrderBy {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.orderByObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexDesc {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.orderByDescending = isTrueBooleanTerm(object)
                nodeExpressions[subject] = expression
            }
        }

        let triplesBySubject = Dictionary(grouping: triples, by: \.subject)

        var expressionDefinitions = nodeExpressions.compactMap { expressionIRI, partial -> SHACLNodeExpressionDefinition? in
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

            if let shapeTerm = resolveShapeReferenceIRIs(partial.matchAllObjects, triplesBySubject: triplesBySubject).sorted().first,
               let inputObject = partial.nodesObjects.sorted().first {
                let resolvedInput = resolveShapeReferenceIRIs([inputObject], triplesBySubject: triplesBySubject).sorted().first ?? inputObject
                let staticListMembers = resolveStaticRDFListMembers(inputObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .matchAll(inputTerm: resolvedInput, shapeTerm: shapeTerm, staticListMembers: staticListMembers)
                )
            }

            if let shapeTerm = resolveShapeReferenceIRIs(partial.filterShapeObjects, triplesBySubject: triplesBySubject).sorted().first,
               let inputObject = partial.nodesObjects.sorted().first {
                let resolvedInput = resolveShapeReferenceIRIs([inputObject], triplesBySubject: triplesBySubject).sorted().first ?? inputObject
                let staticListMembers = resolveStaticRDFListMembers(inputObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .filterShape(inputTerm: resolvedInput, shapeTerm: shapeTerm, staticListMembers: staticListMembers)
                )
            }

            if let removeObject = partial.removeObjects.sorted().first,
               let inputObject = partial.nodesObjects.sorted().first {
                let resolvedInput = resolveShapeReferenceIRIs([inputObject], triplesBySubject: triplesBySubject).sorted().first ?? inputObject
                let staticInputListMembers = resolveStaticRDFListMembers(inputObject, triplesBySubject: triplesBySubject)
                let resolvedRemove = resolveShapeReferenceIRIs([removeObject], triplesBySubject: triplesBySubject).sorted().first ?? removeObject
                let staticRemoveListMembers = resolveStaticRDFListMembers(removeObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .remove(
                        inputTerm: resolvedInput,
                        removeTerm: resolvedRemove,
                        staticInputListMembers: staticInputListMembers,
                        staticRemoveListMembers: staticRemoveListMembers
                    )
                )
            }

            if let mapTerm = resolveShapeReferenceIRIs(partial.flatMapObjects, triplesBySubject: triplesBySubject).sorted().first,
               let inputObject = partial.nodesObjects.sorted().first {
                let resolvedInput = resolveShapeReferenceIRIs([inputObject], triplesBySubject: triplesBySubject).sorted().first ?? inputObject
                let staticInputListMembers = resolveStaticRDFListMembers(inputObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .flatMap(inputTerm: resolvedInput, mapTerm: mapTerm, staticInputListMembers: staticInputListMembers)
                )
            }

            if let limitObject = partial.limitObjects.sorted().first,
               let limitCount = Int(parsedLiteralLexicalForm(limitObject) ?? limitObject),
               let inputObject = partial.nodesObjects.sorted().first {
                let resolvedInput = resolveShapeReferenceIRIs([inputObject], triplesBySubject: triplesBySubject).sorted().first ?? inputObject
                let staticListMembers = resolveStaticRDFListMembers(inputObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .limit(inputTerm: resolvedInput, count: limitCount, staticListMembers: staticListMembers)
                )
            }

            if let offsetObject = partial.offsetObjects.sorted().first,
               let offsetCount = Int(parsedLiteralLexicalForm(offsetObject) ?? offsetObject),
               let inputObject = partial.nodesObjects.sorted().first {
                let resolvedInput = resolveShapeReferenceIRIs([inputObject], triplesBySubject: triplesBySubject).sorted().first ?? inputObject
                let staticListMembers = resolveStaticRDFListMembers(inputObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .offset(inputTerm: resolvedInput, count: offsetCount, staticListMembers: staticListMembers)
                )
            }

            if let shapeTerm = resolveShapeReferenceIRIs(partial.findFirstObjects, triplesBySubject: triplesBySubject).sorted().first,
               let inputObject = partial.nodesObjects.sorted().first {
                let resolvedInput = resolveShapeReferenceIRIs([inputObject], triplesBySubject: triplesBySubject).sorted().first ?? inputObject
                let staticOrderedInputMembers = rdfListLength(inputObject, triplesBySubject: triplesBySubject) != nil
                    ? resolveRDFListOrDirectValueOrdered(inputObject, triplesBySubject: triplesBySubject)
                    : nil
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .findFirst(inputTerm: resolvedInput, shapeTerm: shapeTerm, staticOrderedInputMembers: staticOrderedInputMembers)
                )
            }

            if let keyTerm = resolveShapeReferenceIRIs(partial.orderByObjects, triplesBySubject: triplesBySubject).sorted().first,
               let inputObject = partial.nodesObjects.sorted().first {
                let resolvedInput = resolveShapeReferenceIRIs([inputObject], triplesBySubject: triplesBySubject).sorted().first ?? inputObject
                let staticListMembers = rdfListLength(inputObject, triplesBySubject: triplesBySubject) != nil
                    ? resolveShapeReferenceIRIs([inputObject], triplesBySubject: triplesBySubject).sorted()
                    : nil
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .orderBy(
                        inputTerm: resolvedInput,
                        keyTerm: keyTerm,
                        descending: partial.orderByDescending,
                        staticListMembers: staticListMembers
                    )
                )
            }

            let nodesMembers: [String]
            if partial.nodesObjects.count == 1,
               let only = partial.nodesObjects.first,
               let staticOrdered = resolveStaticRDFListMembers(only, triplesBySubject: triplesBySubject) {
                nodesMembers = staticOrdered
            } else {
                nodesMembers = resolveShapeReferenceIRIs(partial.nodesObjects, triplesBySubject: triplesBySubject).sorted()
            }
            if !nodesMembers.isEmpty || partial.nodesObjects.contains(SHACLIRIs.rdfNil) {
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .nodes(nodesMembers)
                )
            }

            if let concatObject = partial.concatObjects.sorted().first {
                let resolvedConcatInput = resolveShapeReferenceIRIs([concatObject], triplesBySubject: triplesBySubject).sorted().first ?? concatObject
                let staticListMembers: [String]?
                if rdfListLength(concatObject, triplesBySubject: triplesBySubject) != nil {
                    let members = resolveRDFListOrDirectValueOrdered(concatObject, triplesBySubject: triplesBySubject)
                    var flattened: [String] = []
                    for member in members {
                        if let nestedList = resolveStaticRDFListMembers(member, triplesBySubject: triplesBySubject) {
                            flattened.append(contentsOf: nestedList)
                        } else {
                            flattened.append(member)
                        }
                    }
                    staticListMembers = flattened
                } else {
                    staticListMembers = nil
                }
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .concat(inputTerm: resolvedConcatInput, staticListMembers: staticListMembers)
                )
            }

            if let existsInput = resolveShapeReferenceIRIs(partial.existsObjects, triplesBySubject: triplesBySubject).sorted().first {
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .exists(existsInput)
                )
            }

            if let countObject = partial.countObjects.sorted().first {
                let resolvedCountInput = resolveShapeReferenceIRIs([countObject], triplesBySubject: triplesBySubject).sorted().first ?? countObject
                let staticListLength = rdfListLength(countObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .count(inputTerm: resolvedCountInput, staticListLength: staticListLength)
                )
            }

            if let variableNameTerm = partial.variableNames.sorted().first {
                let variableName = parsedLiteralLexicalForm(variableNameTerm) ?? variableNameTerm
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .variable(variableName)
                )
            }

            if let distinctObject = partial.distinctObjects.sorted().first {
                let resolvedDistinctInput = resolveShapeReferenceIRIs([distinctObject], triplesBySubject: triplesBySubject).sorted().first ?? distinctObject
                let staticListMembers = resolveStaticRDFListMembers(distinctObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .distinct(inputTerm: resolvedDistinctInput, staticListMembers: staticListMembers)
                )
            }

            if let classTerm = resolveShapeReferenceIRIs(partial.instancesOfObjects, triplesBySubject: triplesBySubject).sorted().first {
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .instancesOf(classTerm)
                )
            }

            if let shapeTerm = resolveShapeReferenceIRIs(partial.nodesMatchingObjects, triplesBySubject: triplesBySubject).sorted().first {
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .nodesMatching(shapeTerm)
                )
            }

            if let minObject = partial.minObjects.sorted().first {
                let resolvedMinInput = resolveShapeReferenceIRIs([minObject], triplesBySubject: triplesBySubject).sorted().first ?? minObject
                let staticListMembers = resolveStaticRDFListMembers(minObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .min(inputTerm: resolvedMinInput, staticListMembers: staticListMembers)
                )
            }

            if let maxObject = partial.maxObjects.sorted().first {
                let resolvedMaxInput = resolveShapeReferenceIRIs([maxObject], triplesBySubject: triplesBySubject).sorted().first ?? maxObject
                let staticListMembers = resolveStaticRDFListMembers(maxObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .max(inputTerm: resolvedMaxInput, staticListMembers: staticListMembers)
                )
            }

            if let sumObject = partial.sumObjects.sorted().first {
                let resolvedSumInput = resolveShapeReferenceIRIs([sumObject], triplesBySubject: triplesBySubject).sorted().first ?? sumObject
                let staticListMembers = resolveStaticRDFListMembers(sumObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .sum(inputTerm: resolvedSumInput, staticListMembers: staticListMembers)
                )
            }

            let ifTerms = resolveShapeReferenceIRIs(partial.ifObjects, triplesBySubject: triplesBySubject).sorted()
            let thenTerms = resolveShapeReferenceIRIs(partial.thenObjects, triplesBySubject: triplesBySubject).sorted()
            let elseTerms = resolveShapeReferenceIRIs(partial.elseObjects, triplesBySubject: triplesBySubject).sorted()
            if let condition = ifTerms.first, let thenTerm = thenTerms.first {
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .ifThenElse(condition: condition, thenTerm: thenTerm, elseTerm: elseTerms.first)
                )
            }

            if let pathValuesObject = partial.pathValuesObject,
               let parsedPath = parsePropertyPath(pathValuesObject, triplesBySubject: triplesBySubject) {
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .pathValues(path: parsedPath, focusNodeTerm: partial.pathValuesFocusNodeObject)
                )
            }

            return nil
        }

        let definedExpressionIRIs = Set(expressionDefinitions.map(\.expressionIRI))
        let rdfListHeadIRIs = Set(
            triplesBySubject.compactMap { subject, subjectTriples in
                subjectTriples.contains(where: { $0.predicate == SHACLIRIs.rdfFirst }) ? subject : nil
            }
        )
        let synthesizedListExpressions = rdfListHeadIRIs
            .subtracting(definedExpressionIRIs)
            .sorted()
            .map { listHeadIRI in
                SHACLNodeExpressionDefinition(
                    expressionIRI: listHeadIRI,
                    kind: .nodes(resolveRDFListOrDirectValueOrdered(listHeadIRI, triplesBySubject: triplesBySubject))
                )
            }
        expressionDefinitions.append(contentsOf: synthesizedListExpressions)
        expressionDefinitions.sort(by: { $0.expressionIRI < $1.expressionIRI })
        let expressionIRIs = Set(expressionDefinitions.map(\.expressionIRI))

        let definitions = shapes.compactMap { shapeIRI, partial -> SHACLShapeDefinition? in
            let kind: SHACLShapeKind
            if let explicitKind = partial.kind {
                kind = explicitKind
            } else if partial.pathIRI != nil || partial.expressionIRI != nil {
                // W3C fixtures often omit rdf:type sh:PropertyShape on nested blank nodes.
                kind = .propertyShape
            } else {
                // Untyped shapes without sh:path/sh:expression are treated as node shapes.
                kind = .nodeShape
            }
            let resolvedTargetNodes = partial.targets.compactMap { selector -> String? in
                if case .targetNode(let node) = selector {
                    return node
                }
                return nil
            }
            let derivedSPARQLTargetIRIs = Set(
                resolvedTargetNodes.filter { targetNode in
                    if let sparql = sparqlDefinitions[targetNode] {
                        return sparql.selectQuery != nil
                    }
                    return false
                }
            )
            let normalizedTargets = partial.targets.compactMap { selector -> SHACLTargetSelector? in
                if case .targetNode(let node) = selector {
                    if expressionIRIs.contains(node) {
                        return .targetNodeExpression(node)
                    }
                    if derivedSPARQLTargetIRIs.contains(node) {
                        return nil
                    }
                }
                return selector
            }
            let normalizedSPARQLTargetIRIs = resolveShapeReferenceIRIs(partial.sparqlTargetIRIs, triplesBySubject: triplesBySubject)
                .union(derivedSPARQLTargetIRIs)
            return SHACLShapeDefinition(
                shapeIRI: shapeIRI,
                kind: kind,
                isRDFSClass: partial.isRDFSClass,
                isDeactivated: partial.isDeactivated,
                severity: partial.severity,
                targets: normalizedTargets.sorted(by: { targetSortKey($0) < targetSortKey($1) }),
                propertyShapeIRIs: partial.propertyShapeIRIs.sorted(),
                tripleRuleIRIs: resolveShapeReferenceIRIs(partial.ruleIRIs, triplesBySubject: triplesBySubject).sorted(),
                sparqlConstraintIRIs: resolveShapeReferenceIRIs(partial.sparqlConstraintIRIs, triplesBySubject: triplesBySubject).sorted(),
                sparqlTargetIRIs: normalizedSPARQLTargetIRIs.sorted(),
                pathIRI: partial.pathIRI,
                propertyPath: partial.pathIRI.flatMap { parsePropertyPath($0, triplesBySubject: triplesBySubject) },
                expressionIRI: partial.expressionIRI,
                classIRI: partial.classIRI,
                nodeKind: partial.nodeKind ?? partial.nodeKindTerm.flatMap { term in
                    parseNodeKindConstraint(term, triplesBySubject: triplesBySubject)
                },
                datatypeIRI: partial.datatypeIRI,
                minLength: partial.minLength,
                maxLength: partial.maxLength,
                singleLine: partial.singleLine,
                minListLength: partial.minListLength,
                maxListLength: partial.maxListLength,
                minInclusive: partial.minInclusive,
                maxInclusive: partial.maxInclusive,
                minExclusive: partial.minExclusive,
                maxExclusive: partial.maxExclusive,
                pattern: partial.pattern,
                hasValue: partial.hasValue,
                inValues: resolveInValues(partial.inValues, triplesBySubject: triplesBySubject).sorted(),
                languageInValues: resolveInValues(partial.languageInValues, triplesBySubject: triplesBySubject).sorted(),
                uniqueLang: partial.uniqueLang,
                uniqueMembers: partial.uniqueMembers,
                equalsIRI: partial.equalsIRI,
                disjointIRI: partial.disjointIRI,
                lessThanIRI: partial.lessThanIRI,
                lessThanOrEqualsIRI: partial.lessThanOrEqualsIRI,
                isClosed: partial.isClosed,
                ignoredPropertyIRIs: resolveShapeReferenceIRIs(partial.ignoredPropertyIRIs, triplesBySubject: triplesBySubject).sorted(),
                nodeByExpressionIRI: partial.nodeByExpressionIRI,
                nodeShapeReferenceIRI: partial.nodeShapeReferenceIRI,
                andShapeIRIs: resolveShapeReferenceIRIs(partial.andShapeIRIs, triplesBySubject: triplesBySubject).sorted(),
                orShapeIRIs: resolveShapeReferenceIRIs(partial.orShapeIRIs, triplesBySubject: triplesBySubject).sorted(),
                xoneShapeIRIs: resolveShapeReferenceIRIs(partial.xoneShapeIRIs, triplesBySubject: triplesBySubject).sorted(),
                notShapeIRI: partial.notShapeIRI,
                reifierShapeIRI: partial.reifierShapeIRI,
                reificationRequired: partial.reificationRequired,
                memberShapeIRI: partial.memberShapeIRI,
                qualifiedValueShapeIRI: partial.qualifiedValueShapeIRI,
                qualifiedValueShapesDisjoint: partial.qualifiedValueShapesDisjoint,
                qualifiedMinCount: partial.qualifiedMinCount,
                qualifiedMaxCount: partial.qualifiedMaxCount,
                minCount: partial.minCount,
                maxCount: partial.maxCount
            )
        }
        .sorted(by: { $0.shapeIRI < $1.shapeIRI })

        let referencedRuleIRIs = Set(definitions.flatMap(\.tripleRuleIRIs))
        let tripleRuleDefinitions = try referencedRuleIRIs.sorted().map { ruleIRI in
            guard let partial = rules[ruleIRI] else {
                throw SHACLError.invalidShapesGraph("Shape references missing rule \(ruleIRI)")
            }
            guard partial.isTripleRule else {
                throw SHACLError.invalidShapesGraph("Rule \(ruleIRI) is missing rdf:type sh:TripleRule")
            }
            guard let subjectTerm = partial.subjectTerm else {
                throw SHACLError.invalidShapesGraph("Rule \(ruleIRI) is missing sh:subject")
            }
            guard let predicateTerm = partial.predicateTerm else {
                throw SHACLError.invalidShapesGraph("Rule \(ruleIRI) is missing sh:predicate")
            }
            guard let objectTerm = partial.objectTerm else {
                throw SHACLError.invalidShapesGraph("Rule \(ruleIRI) is missing sh:object")
            }
            return SHACLTripleRuleDefinition(
                ruleIRI: ruleIRI,
                ruleOrder: partial.ruleOrder,
                conditionShapeIRIs: resolveShapeReferenceIRIs(partial.conditionShapeIRIs, triplesBySubject: triplesBySubject).sorted(),
                subjectTerm: subjectTerm,
                predicateTerm: predicateTerm,
                objectTerm: objectTerm
            )
        }

        let targetNodeReferencedSPARQLIRIs = Set(
            definitions.flatMap(\.targets).compactMap { target -> String? in
                if case .targetNode(let iri) = target, sparqlDefinitions[iri] != nil {
                    return iri
                }
                return nil
            }
        )
        let referencedSPARQLIRIs = Set(
            definitions.flatMap(\.sparqlConstraintIRIs)
                + definitions.flatMap(\.sparqlTargetIRIs)
                + Array(targetNodeReferencedSPARQLIRIs)
        )
        let parsedSPARQLDefinitions = try referencedSPARQLIRIs.sorted().map { sparqlIRI in
            guard let partial = sparqlDefinitions[sparqlIRI] else {
                throw SHACLError.invalidShapesGraph("Shape references missing SPARQL definition \(sparqlIRI)")
            }
            if partial.selectQuery == nil && partial.askQuery == nil {
                throw SHACLError.invalidShapesGraph("SPARQL definition \(sparqlIRI) is missing sh:select/sh:ask")
            }
            let prefixes = resolveSPARQLPrefixes(
                for: partial.prefixesIRIs,
                triplesBySubject: triplesBySubject
            )
            return SHACLSPARQLDefinition(
                sparqlIRI: sparqlIRI,
                selectQuery: partial.selectQuery,
                askQuery: partial.askQuery,
                message: partial.message,
                prefixes: prefixes
            )
        }

        return SHACLShapesGraph(
            shapes: definitions,
            nodeExpressions: expressionDefinitions,
            tripleRules: tripleRuleDefinitions,
            sparqlDefinitions: parsedSPARQLDefinitions
        )
    }

    private func targetSortKey(_ selector: SHACLTargetSelector) -> String {
        switch selector {
        case .targetClass(let iri):
            return "0:\(iri)"
        case .targetNode(let iri):
            return "1:\(iri)"
        case .targetNodeExpression(let iri):
            return "2:\(iri)"
        case .targetSubjectsOf(let iri):
            return "3:\(iri)"
        case .targetObjectsOf(let iri):
            return "4:\(iri)"
        case .targetWhere(let iri):
            return "5:\(iri)"
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

    private func parseNodeKindConstraint(
        _ term: String,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> SHACLNodeKindConstraint? {
        if let direct = parseNodeKind(term) {
            return direct
        }

        let listTerms = resolveRDFListTermsOrdered(term, triplesBySubject: triplesBySubject)
        let resolvedKinds = listTerms.compactMap(parseNodeKind)
        guard resolvedKinds.count == listTerms.count, !resolvedKinds.isEmpty else {
            return nil
        }
        let uniqueKinds = Set(resolvedKinds)
        if uniqueKinds.count == 1 {
            return uniqueKinds.first
        }
        if uniqueKinds == Set<SHACLNodeKindConstraint>([.blankNode, .iri]) {
            return .blankNodeOrIRI
        }
        if uniqueKinds == Set<SHACLNodeKindConstraint>([.blankNode, .literal]) {
            return .blankNodeOrLiteral
        }
        if uniqueKinds == Set<SHACLNodeKindConstraint>([.iri, .literal]) {
            return .iriOrLiteral
        }
        return nil
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

    private func resolveSPARQLPrefixes(
        for prefixesIRIs: Set<String>,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> [String: String] {
        var resolved: [String: String] = [:]
        for prefixesIRI in prefixesIRIs.sorted() {
            guard let prefixTriples = triplesBySubject[prefixesIRI] else {
                continue
            }
            let declareNodes = prefixTriples
                .filter { $0.predicate == SHACLIRIs.declare }
                .map(\.object)
                .sorted()
            for declareNode in declareNodes {
                guard let declareTriples = triplesBySubject[declareNode],
                      let prefixTerm = declareTriples.first(where: { $0.predicate == SHACLIRIs.prefix })?.object,
                      let namespaceTerm = declareTriples.first(where: { $0.predicate == SHACLIRIs.namespace })?.object else {
                    continue
                }
                let prefix = parsedLiteralLexicalForm(prefixTerm) ?? prefixTerm
                let namespace = parsedLiteralLexicalForm(namespaceTerm) ?? namespaceTerm
                if !namespace.isEmpty {
                    resolved[prefix] = namespace
                }
            }
        }
        return resolved
    }

    private func isTrueBooleanTerm(_ term: String) -> Bool {
        term == "true"
            || term == "1"
            || term == "\"true\""
            || term == "\"true\"^^\(SHACLIRIs.xsdBoolean)"
            || term == "\"1\"^^\(SHACLIRIs.xsdBoolean)"
    }

    private func isStrictTrueBooleanTerm(_ term: String) -> Bool {
        term == "true"
            || term == "\"true\""
            || term == "\"true\"^^\(SHACLIRIs.xsdBoolean)"
    }

    private func parsedLiteralLexicalForm(_ value: String) -> String? {
        if value.hasPrefix("\"\"\"") {
            let start = value.index(value.startIndex, offsetBy: 3)
            guard let closing = value.range(of: "\"\"\"", range: start..<value.endIndex)?.lowerBound else {
                return nil
            }
            return String(value[start..<closing])
        }
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

    private func resolveStaticRDFListMembers(
        _ headOrValue: String,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> [String]? {
        guard rdfListLength(headOrValue, triplesBySubject: triplesBySubject) != nil else {
            return nil
        }
        return resolveRDFListOrDirectValueOrdered(headOrValue, triplesBySubject: triplesBySubject)
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

    private func resolveRDFListOrDirectValueOrdered(
        _ headOrValue: String,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> [String] {
        if headOrValue == SHACLIRIs.rdfNil {
            return []
        }

        guard let firstRestTriples = triplesBySubject[headOrValue],
              firstRestTriples.contains(where: { $0.predicate == SHACLIRIs.rdfFirst }) else {
            return [headOrValue]
        }

        var values: [String] = []
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
            values.append(first.object)
            current = rest.object
        }

        return values
    }

    private func rdfListLength(
        _ headOrValue: String,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> Int? {
        if headOrValue == SHACLIRIs.rdfNil {
            return 0
        }

        guard let firstRestTriples = triplesBySubject[headOrValue],
              firstRestTriples.contains(where: { $0.predicate == SHACLIRIs.rdfFirst }) else {
            return nil
        }

        var current = headOrValue
        var visited: Set<String> = []
        var count = 0

        while current != SHACLIRIs.rdfNil && !visited.contains(current) {
            visited.insert(current)
            guard let triples = triplesBySubject[current],
                  triples.contains(where: { $0.predicate == SHACLIRIs.rdfFirst }),
                  let rest = triples.first(where: { $0.predicate == SHACLIRIs.rdfRest }) else {
                break
            }
            count += 1
            current = rest.object
        }

        return count
    }

    private func parsePropertyPath(
        _ term: String,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> SHACLPropertyPath? {
        var visited: Set<String> = []
        return parsePropertyPath(
            term,
            triplesBySubject: triplesBySubject,
            visited: &visited
        )
    }

    private func parsePropertyPath(
        _ term: String,
        triplesBySubject: [String: [SHACLTriple]],
        visited: inout Set<String>
    ) -> SHACLPropertyPath? {
        if visited.contains(term) {
            return nil
        }
        visited.insert(term)
        defer { visited.remove(term) }

        if hasRDFListStructure(term, triplesBySubject: triplesBySubject) {
            let members = resolveRDFListTermsOrdered(term, triplesBySubject: triplesBySubject)
            let parsedMembers = members.compactMap { member in
                parsePropertyPath(
                    member,
                    triplesBySubject: triplesBySubject,
                    visited: &visited
                )
            }
            guard !parsedMembers.isEmpty, parsedMembers.count == members.count else {
                return nil
            }
            if parsedMembers.count == 1 {
                return parsedMembers[0]
            }
            return .sequence(parsedMembers)
        }

        if let triples = triplesBySubject[term] {
            if let inverseObject = triples.first(where: { $0.predicate == SHACLIRIs.inversePath })?.object,
               let nested = parsePropertyPath(
                   inverseObject,
                   triplesBySubject: triplesBySubject,
                   visited: &visited
               ) {
                return .inverse(nested)
            }

            if let alternativeList = triples.first(where: { $0.predicate == SHACLIRIs.alternativePath })?.object {
                let members = resolveRDFListTermsOrdered(alternativeList, triplesBySubject: triplesBySubject)
                let parsedMembers = members.compactMap { member in
                    parsePropertyPath(
                        member,
                        triplesBySubject: triplesBySubject,
                        visited: &visited
                    )
                }
                guard !parsedMembers.isEmpty, parsedMembers.count == members.count else {
                    return nil
                }
                return .alternative(parsedMembers)
            }

            if let zeroOrMoreObject = triples.first(where: { $0.predicate == SHACLIRIs.zeroOrMorePath })?.object,
               let nested = parsePropertyPath(
                   zeroOrMoreObject,
                   triplesBySubject: triplesBySubject,
                   visited: &visited
               ) {
                return .zeroOrMore(nested)
            }

            if let oneOrMoreObject = triples.first(where: { $0.predicate == SHACLIRIs.oneOrMorePath })?.object,
               let nested = parsePropertyPath(
                   oneOrMoreObject,
                   triplesBySubject: triplesBySubject,
                   visited: &visited
               ) {
                return .oneOrMore(nested)
            }

            if let zeroOrOneObject = triples.first(where: { $0.predicate == SHACLIRIs.zeroOrOnePath })?.object,
               let nested = parsePropertyPath(
                   zeroOrOneObject,
                   triplesBySubject: triplesBySubject,
                   visited: &visited
               ) {
                return .zeroOrOne(nested)
            }
        }

        if isIRIReferenceTerm(term) {
            return .predicate(term)
        }

        return nil
    }

    private func hasRDFListStructure(
        _ term: String,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> Bool {
        guard let triples = triplesBySubject[term] else {
            return false
        }
        return triples.contains(where: { $0.predicate == SHACLIRIs.rdfFirst })
    }

    private func resolveRDFListTermsOrdered(
        _ headOrValue: String,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> [String] {
        if headOrValue == SHACLIRIs.rdfNil {
            return []
        }

        guard hasRDFListStructure(headOrValue, triplesBySubject: triplesBySubject) else {
            return [headOrValue]
        }

        var values: [String] = []
        var current = headOrValue
        var visited: Set<String> = []

        while current != SHACLIRIs.rdfNil && !visited.contains(current) {
            visited.insert(current)
            guard let triples = triplesBySubject[current],
                  let first = triples.first(where: { $0.predicate == SHACLIRIs.rdfFirst }),
                  let rest = triples.first(where: { $0.predicate == SHACLIRIs.rdfRest }) else {
                break
            }
            values.append(first.object)
            current = rest.object
        }

        return values
    }

    private func isIRIReferenceTerm(_ term: String) -> Bool {
        !term.hasPrefix("_:")
            && !term.hasPrefix("\"")
            && !term.isEmpty
            && term != SHACLIRIs.rdfNil
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
                nodes.formUnion(resolve(selector: selector, in: dataGraph, shapesGraph: shapesGraph))
            }
            if shape.kind == .nodeShape && shape.isRDFSClass {
                let subclassMap = Dictionary(grouping: dataGraph.triples.filter { $0.predicate == SHACLIRIs.rdfsSubClassOf }, by: \.subject)
                var closure: Set<String> = [shape.shapeIRI]
                var pending: [String] = [shape.shapeIRI]
                while let current = pending.popLast() {
                    let directSubclasses = subclassMap
                        .filter { _, triples in triples.contains(where: { $0.object == current }) }
                        .map(\.key)
                    for subclass in directSubclasses where !closure.contains(subclass) {
                        closure.insert(subclass)
                        pending.append(subclass)
                    }
                }
                nodes.formUnion(
                    dataGraph.triples
                        .filter { $0.predicate == SHACLIRIs.rdfType && closure.contains($0.object) }
                        .map(\.subject)
                )
            }
            nodes.formUnion(
                dataGraph.triples
                    .filter { $0.predicate == SHACLIRIs.shape && $0.object == shape.shapeIRI }
                    .map(\.subject)
            )
            return SHACLTargetResolution(shapeIRI: shape.shapeIRI, focusNodes: nodes.sorted())
        }
    }

    private func resolve(selector: SHACLTargetSelector, in graph: SHACLDataGraph, shapesGraph: SHACLShapesGraph) -> Set<String> {
        switch selector {
        case .targetClass(let classIRI):
            return Set(
                graph.triples
                    .filter { $0.predicate == SHACLIRIs.rdfType && $0.object == classIRI }
                    .map(\.subject)
            )
        case .targetNode(let nodeIRI):
            return Set([nodeIRI])
        case .targetNodeExpression(let expressionIRI):
            let output = SHACLNodeExpressionEvaluator().evaluate(
                expressionIRI: expressionIRI,
                focusNode: "",
                shapesGraph: shapesGraph,
                dataGraph: graph
            )
            return Set(output.filter { !$0.isEmpty })
        case .targetSubjectsOf(let predicateIRI):
            return Set(graph.triples.filter { $0.predicate == predicateIRI }.map(\.subject))
        case .targetObjectsOf(let predicateIRI):
            return Set(graph.triples.filter { $0.predicate == predicateIRI }.map(\.object))
        case .targetWhere:
            return []
        }
    }
}

public struct SHACLNodeExpressionEvaluator: Sendable {
    private let maxDepth = 16

    public init() {}

    public func evaluate(
        expressionIRI: String,
        focusNode: String,
        shapesGraph: SHACLShapesGraph,
        dataGraph: SHACLDataGraph? = nil,
        variableBindings: [String: Set<String>] = [:]
    ) -> Set<String> {
        let expressionByIRI = Dictionary(uniqueKeysWithValues: shapesGraph.nodeExpressions.map { ($0.expressionIRI, $0) })
        var visited: Set<String> = []
        return evaluateTerm(
            expressionIRI,
            focusNode: focusNode,
            shapesGraph: shapesGraph,
            expressionsByIRI: expressionByIRI,
            dataGraph: dataGraph,
            variableBindings: variableBindings,
            depth: 0,
            visited: &visited
        )
    }

    public func evaluateOrdered(
        expressionIRI: String,
        focusNode: String,
        shapesGraph: SHACLShapesGraph,
        dataGraph: SHACLDataGraph? = nil,
        variableBindings: [String: Set<String>] = [:]
    ) -> [String] {
        let expressionByIRI = Dictionary(uniqueKeysWithValues: shapesGraph.nodeExpressions.map { ($0.expressionIRI, $0) })
        var visited: Set<String> = []
        return evaluateTermOrdered(
            expressionIRI,
            focusNode: focusNode,
            shapesGraph: shapesGraph,
            expressionsByIRI: expressionByIRI,
            dataGraph: dataGraph,
            variableBindings: variableBindings,
            depth: 0,
            visited: &visited
        )
    }

    private func evaluateTerm(
        _ term: String,
        focusNode: String,
        shapesGraph: SHACLShapesGraph,
        expressionsByIRI: [String: SHACLNodeExpressionDefinition],
        dataGraph: SHACLDataGraph?,
        variableBindings: [String: Set<String>],
        depth: Int,
        visited: inout Set<String>
    ) -> Set<String> {
        if term == SHACLIRIs.shThis {
            return [focusNode]
        }

        guard let expression = expressionsByIRI[term] else {
            if term.hasPrefix("_:") {
                // Anonymous node-expression placeholders (e.g. []) are treated as empty expressions.
                return []
            }
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
                        shapesGraph: shapesGraph,
                        expressionsByIRI: expressionsByIRI,
                        dataGraph: dataGraph,
                        variableBindings: variableBindings,
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
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return members.dropFirst().reduce(initial) { partial, member in
                partial.intersection(
                    evaluateTerm(
                        member,
                        focusNode: focusNode,
                        shapesGraph: shapesGraph,
                        expressionsByIRI: expressionsByIRI,
                        dataGraph: dataGraph,
                        variableBindings: variableBindings,
                        depth: depth + 1,
                        visited: &visited
                    )
                )
            }
        case .nodes(let members):
            return members.reduce(into: Set<String>()) { result, member in
                result.formUnion(
                    evaluateTerm(
                        member,
                        focusNode: focusNode,
                        shapesGraph: shapesGraph,
                        expressionsByIRI: expressionsByIRI,
                        dataGraph: dataGraph,
                        variableBindings: variableBindings,
                        depth: depth + 1,
                        visited: &visited
                    )
                )
            }
        case .exists(let input):
            let output = evaluateTerm(
                input,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return output.isEmpty
                ? ["\"false\"^^\(SHACLIRIs.xsdBoolean)"]
                : ["\"true\"^^\(SHACLIRIs.xsdBoolean)"]
        case .count(let inputTerm, let staticListLength):
            if let staticListLength {
                return ["\(staticListLength)"]
            }
            let output = evaluateTerm(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return ["\(output.count)"]
        case .variable(let variableName):
            if let binding = variableBindings[variableName] {
                return binding
            }
            if variableName == "focusNode" {
                return [focusNode]
            }
            return []
        case .distinct(let inputTerm, let staticListMembers):
            return staticListMembers.map(Set.init) ?? evaluateTerm(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
        case .matchAll(let inputTerm, let shapeTerm, let staticListMembers):
            let inputNodes = staticListMembers.map(Set.init) ?? evaluateTerm(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            if inputNodes.isEmpty {
                return ["\"true\"^^\(SHACLIRIs.xsdBoolean)"]
            }
            guard let dataGraph else {
                return ["\"false\"^^\(SHACLIRIs.xsdBoolean)"]
            }
            let matched = nodesMatching(
                shapeIRI: shapeTerm,
                candidates: inputNodes,
                shapesGraph: shapesGraph,
                dataGraph: dataGraph
            )
            return matched.count == inputNodes.count
                ? ["\"true\"^^\(SHACLIRIs.xsdBoolean)"]
                : ["\"false\"^^\(SHACLIRIs.xsdBoolean)"]
        case .filterShape(let inputTerm, let shapeTerm, let staticListMembers):
            let inputNodes = staticListMembers.map(Set.init) ?? evaluateTerm(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            guard let dataGraph else {
                return []
            }
            return nodesMatching(
                shapeIRI: shapeTerm,
                candidates: inputNodes,
                shapesGraph: shapesGraph,
                dataGraph: dataGraph
            )
        case .instancesOf(let classIRI):
            guard let dataGraph else {
                return []
            }
            let subclasses = transitiveSubclasses(of: classIRI, dataGraph: dataGraph)
            let matchingClasses = subclasses.union([classIRI])
            return Set(
                dataGraph.triples
                    .filter { $0.predicate == SHACLIRIs.rdfType && matchingClasses.contains($0.object) }
                    .map(\.subject)
            )
        case .nodesMatching(let shapeIRI):
            guard let dataGraph else {
                return []
            }
            let candidates = Set(dataGraph.triples.map(\.subject) + dataGraph.triples.map(\.object))
            return nodesMatching(shapeIRI: shapeIRI, candidates: candidates, shapesGraph: shapesGraph, dataGraph: dataGraph)
        case .min(let inputTerm, let staticListMembers):
            let output = staticListMembers.map(Set.init) ?? evaluateTerm(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            guard let minimum = numericExtremeTerm(from: output, findMaximum: false) else {
                return []
            }
            return [minimum]
        case .max(let inputTerm, let staticListMembers):
            let output = staticListMembers.map(Set.init) ?? evaluateTerm(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            guard let maximum = numericExtremeTerm(from: output, findMaximum: true) else {
                return []
            }
            return [maximum]
        case .sum(let inputTerm, let staticListMembers):
            let output = staticListMembers.map(Set.init) ?? evaluateTerm(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return [numericSum(from: output)]
        case .ifThenElse(let condition, let thenTerm, let elseTerm):
            let conditionOutput = evaluateTerm(
                condition,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            if isTrueOnlyExpressionSet(conditionOutput) {
                return evaluateTerm(
                    thenTerm,
                    focusNode: focusNode,
                    shapesGraph: shapesGraph,
                    expressionsByIRI: expressionsByIRI,
                    dataGraph: dataGraph,
                    variableBindings: variableBindings,
                    depth: depth + 1,
                    visited: &visited
                )
            }
            guard let elseTerm else {
                return []
            }
            return evaluateTerm(
                elseTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
        case .pathValues(let path, let focusNodeTerm):
            guard let dataGraph else {
                return []
            }
            let focusNodes: Set<String>
            if let focusNodeTerm {
                focusNodes = evaluateTerm(
                    focusNodeTerm,
                    focusNode: focusNode,
                    shapesGraph: shapesGraph,
                    expressionsByIRI: expressionsByIRI,
                    dataGraph: dataGraph,
                    variableBindings: variableBindings,
                    depth: depth + 1,
                    visited: &visited
                )
            } else {
                focusNodes = [focusNode]
            }
            return focusNodes.reduce(into: Set<String>()) { result, node in
                result.formUnion(evaluatePropertyPathValues(path, from: node, dataGraph: dataGraph))
            }
        case .concat(let inputTerm, let staticListMembers):
            let terms = staticListMembers ?? [inputTerm]
            return terms.reduce(into: Set<String>()) { result, term in
                result.formUnion(
                    evaluateTerm(
                        term,
                        focusNode: focusNode,
                        shapesGraph: shapesGraph,
                        expressionsByIRI: expressionsByIRI,
                        dataGraph: dataGraph,
                        variableBindings: variableBindings,
                        depth: depth + 1,
                        visited: &visited
                    )
                )
            }
        case .remove(let inputTerm, let removeTerm, let staticInputListMembers, let staticRemoveListMembers):
            let inputNodes = staticInputListMembers.map(Set.init) ?? evaluateTerm(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            let removeNodes = staticRemoveListMembers.map(Set.init) ?? evaluateTerm(
                removeTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return inputNodes.subtracting(removeNodes)
        case .flatMap(let inputTerm, let mapTerm, let staticInputListMembers):
            let inputNodes = staticInputListMembers.map(Set.init) ?? evaluateTerm(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return inputNodes.reduce(into: Set<String>()) { result, inputNode in
                result.formUnion(
                    evaluateTerm(
                        mapTerm,
                        focusNode: inputNode,
                        shapesGraph: shapesGraph,
                        expressionsByIRI: expressionsByIRI,
                        dataGraph: dataGraph,
                        variableBindings: variableBindings,
                        depth: depth + 1,
                        visited: &visited
                    )
                )
            }
        case .limit(let inputTerm, let count, let staticListMembers):
            let ordered = staticListMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return Set(ordered.prefix(max(0, count)))
        case .offset(let inputTerm, let count, let staticListMembers):
            let ordered = staticListMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return Set(ordered.dropFirst(max(0, count)))
        case .findFirst(let inputTerm, let shapeTerm, let staticOrderedInputMembers):
            let orderedInputs = staticOrderedInputMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            if orderedInputs.isEmpty {
                return []
            }
            let evaluationGraph = dataGraph ?? SHACLDataGraph(triples: [])
            let matched = nodesMatching(
                shapeIRI: shapeTerm,
                candidates: Set(orderedInputs),
                shapesGraph: shapesGraph,
                dataGraph: evaluationGraph
            )
            guard let first = orderedInputs.first(where: { matched.contains($0) }) else {
                return []
            }
            return [first]
        case .orderBy(let inputTerm, let keyTerm, let descending, let staticListMembers):
            let ordered = staticListMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            if ordered.isEmpty {
                return []
            }
            let sorted = sortOrderByNodes(
                ordered,
                keyTerm: keyTerm,
                descending: descending,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return Set(sorted)
        }
    }

    private func evaluateTermOrdered(
        _ term: String,
        focusNode: String,
        shapesGraph: SHACLShapesGraph,
        expressionsByIRI: [String: SHACLNodeExpressionDefinition],
        dataGraph: SHACLDataGraph?,
        variableBindings: [String: Set<String>],
        depth: Int,
        visited: inout Set<String>
    ) -> [String] {
        guard let expression = expressionsByIRI[term] else {
            return evaluateTerm(
                term,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth,
                visited: &visited
            ).sorted()
        }

        switch expression.kind {
        case .nodes(let members):
            var ordered: [String] = []
            for member in members {
                ordered.append(contentsOf: evaluateTermOrdered(
                    member,
                    focusNode: focusNode,
                    shapesGraph: shapesGraph,
                    expressionsByIRI: expressionsByIRI,
                    dataGraph: dataGraph,
                    variableBindings: variableBindings,
                    depth: depth + 1,
                    visited: &visited
                ))
            }
            return ordered
        case .concat(let inputTerm, let staticListMembers):
            let terms = staticListMembers ?? [inputTerm]
            var ordered: [String] = []
            for term in terms {
                ordered.append(contentsOf: evaluateTermOrdered(
                    term,
                    focusNode: focusNode,
                    shapesGraph: shapesGraph,
                    expressionsByIRI: expressionsByIRI,
                    dataGraph: dataGraph,
                    variableBindings: variableBindings,
                    depth: depth + 1,
                    visited: &visited
                ))
            }
            return ordered
        case .remove(let inputTerm, let removeTerm, let staticInputListMembers, let staticRemoveListMembers):
            let input = staticInputListMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            let removeNodes = Set(staticRemoveListMembers ?? evaluateTermOrdered(
                removeTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            ))
            return input.filter { !removeNodes.contains($0) }
        case .distinct(let inputTerm, let staticListMembers):
            let input = staticListMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            var seen: Set<String> = []
            var ordered: [String] = []
            for node in input where !seen.contains(node) {
                seen.insert(node)
                ordered.append(node)
            }
            return ordered
        case .flatMap(let inputTerm, let mapTerm, let staticInputListMembers):
            let inputs = staticInputListMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            var ordered: [String] = []
            for input in inputs {
                ordered.append(contentsOf: evaluateTermOrdered(
                    mapTerm,
                    focusNode: input,
                    shapesGraph: shapesGraph,
                    expressionsByIRI: expressionsByIRI,
                    dataGraph: dataGraph,
                    variableBindings: variableBindings,
                    depth: depth + 1,
                    visited: &visited
                ))
            }
            return ordered
        case .limit(let inputTerm, let count, let staticListMembers):
            let ordered = staticListMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return Array(ordered.prefix(max(0, count)))
        case .offset(let inputTerm, let count, let staticListMembers):
            let ordered = staticListMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return Array(ordered.dropFirst(max(0, count)))
        case .findFirst(let inputTerm, let shapeTerm, let staticOrderedInputMembers):
            let orderedInputs = staticOrderedInputMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            if orderedInputs.isEmpty {
                return []
            }
            let evaluationGraph = dataGraph ?? SHACLDataGraph(triples: [])
            let matched = nodesMatching(
                shapeIRI: shapeTerm,
                candidates: Set(orderedInputs),
                shapesGraph: shapesGraph,
                dataGraph: evaluationGraph
            )
            guard let first = orderedInputs.first(where: { matched.contains($0) }) else {
                return []
            }
            return [first]
        case .orderBy(let inputTerm, let keyTerm, let descending, let staticListMembers):
            let input = staticListMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            return sortOrderByNodes(
                input,
                keyTerm: keyTerm,
                descending: descending,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
        case .union(let members):
            var seen: Set<String> = []
            var ordered: [String] = []
            for member in members {
                let memberOrdered = evaluateTermOrdered(
                    member,
                    focusNode: focusNode,
                    shapesGraph: shapesGraph,
                    expressionsByIRI: expressionsByIRI,
                    dataGraph: dataGraph,
                    variableBindings: variableBindings,
                    depth: depth + 1,
                    visited: &visited
                )
                for node in memberOrdered where !seen.contains(node) {
                    seen.insert(node)
                    ordered.append(node)
                }
            }
            return ordered
        case .intersection(let members):
            guard let first = members.first else {
                return []
            }
            let firstOrdered = evaluateTermOrdered(
                first,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            let remainingSets = members.dropFirst().map { member in
                Set(evaluateTerm(
                    member,
                    focusNode: focusNode,
                    shapesGraph: shapesGraph,
                    expressionsByIRI: expressionsByIRI,
                    dataGraph: dataGraph,
                    variableBindings: variableBindings,
                    depth: depth + 1,
                    visited: &visited
                ))
            }
            var seen: Set<String> = []
            var ordered: [String] = []
            for node in firstOrdered where !seen.contains(node) {
                if remainingSets.allSatisfy({ $0.contains(node) }) {
                    seen.insert(node)
                    ordered.append(node)
                }
            }
            return ordered
        case .filterShape(let inputTerm, let shapeTerm, let staticListMembers):
            let input = staticListMembers ?? evaluateTermOrdered(
                inputTerm,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth + 1,
                visited: &visited
            )
            guard let dataGraph else {
                return []
            }
            let matched = nodesMatching(
                shapeIRI: shapeTerm,
                candidates: Set(input),
                shapesGraph: shapesGraph,
                dataGraph: dataGraph
            )
            var seen: Set<String> = []
            var ordered: [String] = []
            for node in input where matched.contains(node) && !seen.contains(node) {
                seen.insert(node)
                ordered.append(node)
            }
            return ordered
        default:
            return evaluateTerm(
                term,
                focusNode: focusNode,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth,
                visited: &visited
            ).sorted()
        }
    }

    private func sortOrderByNodes(
        _ inputNodes: [String],
        keyTerm: String,
        descending: Bool,
        focusNode: String,
        shapesGraph: SHACLShapesGraph,
        expressionsByIRI: [String: SHACLNodeExpressionDefinition],
        dataGraph: SHACLDataGraph?,
        variableBindings: [String: Set<String>],
        depth: Int,
        visited: inout Set<String>
    ) -> [String] {
        return inputNodes.sorted { lhs, rhs in
            let lhsKeys = evaluateTerm(
                keyTerm,
                focusNode: lhs,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth,
                visited: &visited
            ).sorted()
            let rhsKeys = evaluateTerm(
                keyTerm,
                focusNode: rhs,
                shapesGraph: shapesGraph,
                expressionsByIRI: expressionsByIRI,
                dataGraph: dataGraph,
                variableBindings: variableBindings,
                depth: depth,
                visited: &visited
            ).sorted()
            let lhsKey = lhsKeys.first ?? ""
            let rhsKey = rhsKeys.first ?? ""
            let ascending: Bool
            if let lhsNumeric = nodeExpressionNumericTerm(lhsKey)?.value,
               let rhsNumeric = nodeExpressionNumericTerm(rhsKey)?.value {
                if lhsNumeric == rhsNumeric {
                    ascending = lhs < rhs
                } else {
                    ascending = lhsNumeric < rhsNumeric
                }
            } else if lhsKey == rhsKey {
                ascending = lhs < rhs
            } else {
                ascending = lhsKey < rhsKey
            }
            return descending ? !ascending : ascending
        }
    }
}

private func isTrueOnlyExpressionSet(_ outputNodes: Set<String>) -> Bool {
    guard outputNodes.count == 1, let only = outputNodes.first else {
        return false
    }
    return only == "true"
        || only == "1"
        || only == "\"true\""
        || only == "\"true\"^^\(SHACLIRIs.xsdBoolean)"
        || only == "\"1\"^^\(SHACLIRIs.xsdBoolean)"
}

private func numericExtremeTerm(from outputNodes: Set<String>, findMaximum: Bool) -> String? {
    var chosen: (term: String, value: Double)?
    for term in outputNodes {
        guard let value = nodeExpressionNumericTerm(term)?.value else {
            continue
        }
        guard let current = chosen else {
            chosen = (term, value)
            continue
        }
        if findMaximum {
            if value > current.value {
                chosen = (term, value)
            }
        } else if value < current.value {
            chosen = (term, value)
        }
    }
    return chosen?.term
}

private func numericSum(from outputNodes: Set<String>) -> String {
    var total = 0.0
    var sawDecimal = false
    for term in outputNodes {
        guard let parsed = nodeExpressionNumericTerm(term) else {
            continue
        }
        total += parsed.value
        if !parsed.isInteger {
            sawDecimal = true
        }
    }

    if !sawDecimal && floor(total) == total {
        return String(Int(total))
    }
    if sawDecimal && floor(total) == total {
        return "\(Int(total)).0"
    }

    var text = String(total)
    if text.contains(".") {
        while text.last == "0" {
            text.removeLast()
        }
        if text.last == "." {
            text.removeLast()
        }
    }
    return text
}

private func nodeExpressionNumericTerm(_ term: String) -> (value: Double, isInteger: Bool)? {
    if let direct = Double(term) {
        return (direct, Int(term) != nil)
    }
    guard let lexical = nodeExpressionLiteralLexicalForm(term),
          let parsed = Double(lexical) else {
        return nil
    }
    return (parsed, Int(lexical) != nil)
}

private func nodeExpressionLiteralLexicalForm(_ value: String) -> String? {
    guard value.hasPrefix("\"") else {
        return nil
    }
    guard let closing = value.dropFirst().firstIndex(of: "\"") else {
        return nil
    }
    let start = value.index(after: value.startIndex)
    return String(value[start..<closing])
}

private func evaluatePropertyPathValues(
    _ path: SHACLPropertyPath,
    from focusNode: String,
    dataGraph: SHACLDataGraph
) -> Set<String> {
    switch path {
    case .predicate(let predicateIRI):
        return Set(
            dataGraph.triples
                .filter { $0.subject == focusNode && $0.predicate == predicateIRI }
                .map(\.object)
        )
    case .inverse(let nested):
        let candidateNodes = Set(dataGraph.triples.map(\.subject) + dataGraph.triples.map(\.object))
        return Set(
            candidateNodes.filter { candidate in
                evaluatePropertyPathValues(nested, from: candidate, dataGraph: dataGraph).contains(focusNode)
            }
        )
    case .sequence(let members):
        return members.reduce(into: Set([focusNode])) { partial, member in
            let next = partial.reduce(into: Set<String>()) { nextSet, node in
                nextSet.formUnion(evaluatePropertyPathValues(member, from: node, dataGraph: dataGraph))
            }
            partial = next
        }
    case .alternative(let members):
        return members.reduce(into: Set<String>()) { partial, member in
            partial.formUnion(evaluatePropertyPathValues(member, from: focusNode, dataGraph: dataGraph))
        }
    case .zeroOrOne(let nested):
        return Set([focusNode]).union(evaluatePropertyPathValues(nested, from: focusNode, dataGraph: dataGraph))
    case .zeroOrMore(let nested):
        var reached: Set<String> = [focusNode]
        var frontier: Set<String> = [focusNode]
        while !frontier.isEmpty {
            let next = frontier.reduce(into: Set<String>()) { partial, node in
                partial.formUnion(evaluatePropertyPathValues(nested, from: node, dataGraph: dataGraph))
            }
            let delta = next.subtracting(reached)
            if delta.isEmpty {
                break
            }
            reached.formUnion(delta)
            frontier = delta
        }
        return reached
    case .oneOrMore(let nested):
        var reached = evaluatePropertyPathValues(nested, from: focusNode, dataGraph: dataGraph)
        var frontier = reached
        while !frontier.isEmpty {
            let next = frontier.reduce(into: Set<String>()) { partial, node in
                partial.formUnion(evaluatePropertyPathValues(nested, from: node, dataGraph: dataGraph))
            }
            let delta = next.subtracting(reached)
            if delta.isEmpty {
                break
            }
            reached.formUnion(delta)
            frontier = delta
        }
        return reached
    }
}

private func evaluatePropertyPairComparisonValues(
    propertyPathTerm: String,
    focusNode: String,
    dataGraph: SHACLDataGraph
) -> [String] {
    let triplesBySubject = Dictionary(grouping: dataGraph.triples, by: \.subject)
    if let propertyPath = parsePropertyPathInDataGraph(propertyPathTerm, triplesBySubject: triplesBySubject) {
        return Array(evaluatePropertyPathValues(propertyPath, from: focusNode, dataGraph: dataGraph))
    }
    return dataGraph.triples
        .filter { $0.subject == focusNode && $0.predicate == propertyPathTerm }
        .map(\.object)
}

private func parsePropertyPathInDataGraph(
    _ term: String,
    triplesBySubject: [String: [SHACLDataTriple]]
) -> SHACLPropertyPath? {
    var visited: Set<String> = []
    return parsePropertyPathInDataGraph(term, triplesBySubject: triplesBySubject, visited: &visited)
}

private func parsePropertyPathInDataGraph(
    _ term: String,
    triplesBySubject: [String: [SHACLDataTriple]],
    visited: inout Set<String>
) -> SHACLPropertyPath? {
    if visited.contains(term) {
        return nil
    }
    visited.insert(term)
    defer { visited.remove(term) }

    if hasRDFListStructureInDataGraph(term, triplesBySubject: triplesBySubject) {
        let members = resolveRDFListTermsOrderedInDataGraph(term, triplesBySubject: triplesBySubject)
        let parsedMembers = members.compactMap { member in
            parsePropertyPathInDataGraph(
                member,
                triplesBySubject: triplesBySubject,
                visited: &visited
            )
        }
        guard !parsedMembers.isEmpty, parsedMembers.count == members.count else {
            return nil
        }
        if parsedMembers.count == 1 {
            return parsedMembers[0]
        }
        return .sequence(parsedMembers)
    }

    if let triples = triplesBySubject[term] {
        if let inverseObject = triples.first(where: { $0.predicate == SHACLIRIs.inversePath })?.object,
           let nested = parsePropertyPathInDataGraph(
               inverseObject,
               triplesBySubject: triplesBySubject,
               visited: &visited
           ) {
            return .inverse(nested)
        }

        if let alternativeList = triples.first(where: { $0.predicate == SHACLIRIs.alternativePath })?.object {
            let members = resolveRDFListTermsOrderedInDataGraph(alternativeList, triplesBySubject: triplesBySubject)
            let parsedMembers = members.compactMap { member in
                parsePropertyPathInDataGraph(
                    member,
                    triplesBySubject: triplesBySubject,
                    visited: &visited
                )
            }
            guard !parsedMembers.isEmpty, parsedMembers.count == members.count else {
                return nil
            }
            return .alternative(parsedMembers)
        }

        if let zeroOrMoreObject = triples.first(where: { $0.predicate == SHACLIRIs.zeroOrMorePath })?.object,
           let nested = parsePropertyPathInDataGraph(
               zeroOrMoreObject,
               triplesBySubject: triplesBySubject,
               visited: &visited
           ) {
            return .zeroOrMore(nested)
        }

        if let oneOrMoreObject = triples.first(where: { $0.predicate == SHACLIRIs.oneOrMorePath })?.object,
           let nested = parsePropertyPathInDataGraph(
               oneOrMoreObject,
               triplesBySubject: triplesBySubject,
               visited: &visited
           ) {
            return .oneOrMore(nested)
        }

        if let zeroOrOneObject = triples.first(where: { $0.predicate == SHACLIRIs.zeroOrOnePath })?.object,
           let nested = parsePropertyPathInDataGraph(
               zeroOrOneObject,
               triplesBySubject: triplesBySubject,
               visited: &visited
           ) {
            return .zeroOrOne(nested)
        }
    }

    if isIRIReferenceTermInDataGraph(term) {
        return .predicate(term)
    }

    return nil
}

private func hasRDFListStructureInDataGraph(
    _ term: String,
    triplesBySubject: [String: [SHACLDataTriple]]
) -> Bool {
    guard let triples = triplesBySubject[term] else {
        return false
    }
    return triples.contains(where: { $0.predicate == SHACLIRIs.rdfFirst })
}

private func resolveRDFListTermsOrderedInDataGraph(
    _ headOrValue: String,
    triplesBySubject: [String: [SHACLDataTriple]]
) -> [String] {
    if headOrValue == SHACLIRIs.rdfNil {
        return []
    }

    guard let firstRestTriples = triplesBySubject[headOrValue],
          firstRestTriples.contains(where: { $0.predicate == SHACLIRIs.rdfFirst }) else {
        return [headOrValue]
    }

    var terms: [String] = []
    var current = headOrValue
    var visited: Set<String> = []

    while current != SHACLIRIs.rdfNil && !visited.contains(current) {
        visited.insert(current)
        guard let triples = triplesBySubject[current],
              let first = triples.first(where: { $0.predicate == SHACLIRIs.rdfFirst }),
              let rest = triples.first(where: { $0.predicate == SHACLIRIs.rdfRest }) else {
            break
        }
        terms.append(first.object)
        current = rest.object
    }

    return terms
}

private func isIRIReferenceTermInDataGraph(_ term: String) -> Bool {
    if term.hasPrefix("_:") || term.hasPrefix("\"") {
        return false
    }
    if Double(term) != nil {
        return false
    }
    if term == "true" || term == "false" {
        return false
    }
    return term.contains(":")
}

private func transitiveSubclasses(of classIRI: String, dataGraph: SHACLDataGraph) -> Set<String> {
    var descendants: Set<String> = []
    var frontier: Set<String> = [classIRI]

    while !frontier.isEmpty {
        let next = Set(
            dataGraph.triples
                .filter { frontier.contains($0.object) && $0.predicate == SHACLIRIs.rdfsSubClassOf }
                .map(\.subject)
        )
        let delta = next.subtracting(descendants)
        if delta.isEmpty {
            break
        }
        descendants.formUnion(delta)
        frontier = delta
    }

    return descendants
}

private func nodeSatisfiesClassConstraint(
    _ node: String,
    classIRI: String,
    dataGraph: SHACLDataGraph
) -> Bool {
    let acceptedTypes = transitiveSubclasses(of: classIRI, dataGraph: dataGraph).union([classIRI])
    return dataGraph.triples.contains {
        $0.subject == node && $0.predicate == SHACLIRIs.rdfType && acceptedTypes.contains($0.object)
    }
}

private func nodesMatching(
    shapeIRI: String,
    candidates: Set<String>,
    shapesGraph: SHACLShapesGraph,
    dataGraph: SHACLDataGraph
) -> Set<String> {
    guard !candidates.isEmpty else {
        return []
    }

    let validator = SHACLCoreValidator()
    let neutralizedShapes = shapesGraph.shapes.map(shapeWithoutTargets)
    var matched: Set<String> = []
    for candidate in candidates {
        let tempShape = SHACLShapeDefinition(
            shapeIRI: "urn:codex:shaclkit:nodeexpr:nodesMatching:\(candidate)",
            kind: .nodeShape,
            targets: [.targetNode(candidate)],
            nodeShapeReferenceIRI: shapeIRI
        )
        let tempGraph = SHACLShapesGraph(
            shapes: neutralizedShapes + [tempShape],
            nodeExpressions: shapesGraph.nodeExpressions,
            tripleRules: shapesGraph.tripleRules,
            sparqlDefinitions: shapesGraph.sparqlDefinitions
        )
        if let result = try? validator.validate(dataGraph: dataGraph, shapesGraph: tempGraph),
           result.conforms {
            matched.insert(candidate)
        }
    }
    return matched
}

private func shapeWithoutTargets(_ shape: SHACLShapeDefinition) -> SHACLShapeDefinition {
    SHACLShapeDefinition(
        shapeIRI: shape.shapeIRI,
        kind: shape.kind,
        isRDFSClass: shape.isRDFSClass,
        isDeactivated: shape.isDeactivated,
        severity: shape.severity,
        targets: [],
        propertyShapeIRIs: shape.propertyShapeIRIs,
        tripleRuleIRIs: shape.tripleRuleIRIs,
        sparqlConstraintIRIs: shape.sparqlConstraintIRIs,
        sparqlTargetIRIs: shape.sparqlTargetIRIs,
        pathIRI: shape.pathIRI,
        propertyPath: shape.propertyPath,
        expressionIRI: shape.expressionIRI,
        classIRI: shape.classIRI,
        nodeKind: shape.nodeKind,
        datatypeIRI: shape.datatypeIRI,
        minLength: shape.minLength,
        maxLength: shape.maxLength,
        minInclusive: shape.minInclusive,
        maxInclusive: shape.maxInclusive,
        minExclusive: shape.minExclusive,
        maxExclusive: shape.maxExclusive,
        pattern: shape.pattern,
        hasValue: shape.hasValue,
        inValues: shape.inValues,
        languageInValues: shape.languageInValues,
        uniqueLang: shape.uniqueLang,
        equalsIRI: shape.equalsIRI,
        disjointIRI: shape.disjointIRI,
        lessThanIRI: shape.lessThanIRI,
        lessThanOrEqualsIRI: shape.lessThanOrEqualsIRI,
        isClosed: shape.isClosed,
        ignoredPropertyIRIs: shape.ignoredPropertyIRIs,
        nodeByExpressionIRI: shape.nodeByExpressionIRI,
        nodeShapeReferenceIRI: shape.nodeShapeReferenceIRI,
        andShapeIRIs: shape.andShapeIRIs,
        orShapeIRIs: shape.orShapeIRIs,
        xoneShapeIRIs: shape.xoneShapeIRIs,
        notShapeIRI: shape.notShapeIRI,
        qualifiedValueShapeIRI: shape.qualifiedValueShapeIRI,
        qualifiedValueShapesDisjoint: shape.qualifiedValueShapesDisjoint,
        qualifiedMinCount: shape.qualifiedMinCount,
        qualifiedMaxCount: shape.qualifiedMaxCount,
        minCount: shape.minCount,
        maxCount: shape.maxCount
    )
}

public struct SHACLCoreValidator: SHACLValidator {
    private let shapesLoader: any SHACLShapesGraphLoading
    private let dataLoader: any SHACLDataGraphLoading
    private let focusResolver: SHACLFocusNodeResolver
    private let sparqlExecutor: any SHACLSPARQLExecutor
    private let conformanceDisallowedSeverities: Set<SHACLSeverity>
    private let maxReferenceDepth = 16
    private let maxRuleIterations = 16

    public init(
        shapesLoader: any SHACLShapesGraphLoading = SHACLShapesGraphLoader(),
        dataLoader: any SHACLDataGraphLoading = SHACLDataGraphLoader(),
        focusResolver: SHACLFocusNodeResolver = SHACLFocusNodeResolver(),
        sparqlExecutor: any SHACLSPARQLExecutor = SHACLDeniedSPARQLExecutor(),
        conformanceDisallowedSeverities: Set<SHACLSeverity> = [.violation, .warning, .info]
    ) {
        self.shapesLoader = shapesLoader
        self.dataLoader = dataLoader
        self.focusResolver = focusResolver
        self.sparqlExecutor = sparqlExecutor
        self.conformanceDisallowedSeverities = conformanceDisallowedSeverities
    }

    public func validate(dataGraph: Data, shapesGraph: Data) throws -> SHACLValidationResult {
        let parsedShapes = try shapesLoader.load(from: shapesGraph)
        let parsedData = try dataLoader.load(from: dataGraph)
        return try validate(dataGraph: parsedData, shapesGraph: parsedShapes)
    }

    public func validate(dataGraph: SHACLDataGraph, shapesGraph: SHACLShapesGraph) throws -> SHACLValidationResult {
        try validateShapesGraph(shapesGraph)
        let parsedShapes = shapesGraph
        let shapeByIRI = Dictionary(uniqueKeysWithValues: parsedShapes.shapes.map { ($0.shapeIRI, $0) })
        let nodeExpressionsByIRI = Dictionary(uniqueKeysWithValues: parsedShapes.nodeExpressions.map { ($0.expressionIRI, $0) })
        let parsedData = applyRules(
            dataGraph: dataGraph,
            shapesGraph: parsedShapes,
            shapesByIRI: shapeByIRI,
            nodeExpressionsByIRI: nodeExpressionsByIRI
        )
        let expressionGraph = SHACLShapesGraph(
            shapes: Array(shapeByIRI.values),
            nodeExpressions: Array(nodeExpressionsByIRI.values)
        )
        let sparqlDefinitionsByIRI = Dictionary(uniqueKeysWithValues: parsedShapes.sparqlDefinitions.map { ($0.sparqlIRI, $0) })
        let resolutions = try resolveFocusNodes(
            dataGraph: parsedData,
            shapesGraph: parsedShapes,
            sparqlDefinitionsByIRI: sparqlDefinitionsByIRI
        )

        var violations: [SHACLViolation] = []

        for resolution in resolutions {
            guard let shape = shapeByIRI[resolution.shapeIRI] else {
                continue
            }
            if shape.isDeactivated {
                continue
            }
            for focusNode in resolution.focusNodes {
                var visited: Set<String> = []
                var deferredVisited: Set<String> = []
                if shape.kind == .nodeShape {
                    violations.append(
                        contentsOf: evaluate(
                            nodeShape: shape,
                            focusNode: focusNode,
                            dataGraph: parsedData,
                            shapesByIRI: shapeByIRI,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI,
                            depth: 0,
                            visited: &visited
                        )
                    )
                    violations.append(
                        contentsOf: evaluateDeferredMemberShapeConstraints(
                            nodeShape: shape,
                            focusNode: focusNode,
                            dataGraph: parsedData,
                            shapesByIRI: shapeByIRI,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI,
                            visited: &deferredVisited
                        )
                    )
                } else if shape.kind == .propertyShape {
                    if shape.isDeactivated {
                        continue
                    }
                    let wrapperShape = SHACLShapeDefinition(
                        shapeIRI: "\(shape.shapeIRI)#direct-property-target-wrapper",
                        kind: .nodeShape,
                        severity: shape.severity,
                        targets: [],
                        propertyShapeIRIs: [shape.shapeIRI]
                    )
                    violations.append(
                        contentsOf: evaluate(
                            nodeShape: wrapperShape,
                            focusNode: focusNode,
                            dataGraph: parsedData,
                            shapesByIRI: shapeByIRI,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI,
                            depth: 0,
                            visited: &visited
                        )
                    )
                    violations.append(
                        contentsOf: evaluateDeferredMemberShapeForPropertyShape(
                            propertyShape: shape,
                            rootFocusNode: focusNode,
                            currentNode: focusNode,
                            inheritedSeverity: shape.severity,
                            dataGraph: parsedData,
                            shapesByIRI: shapeByIRI,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI,
                            visited: &deferredVisited
                        )
                    )
                }
            }
        }

        violations.append(
            contentsOf: try evaluateSPARQLConstraints(
                resolutions: resolutions,
                dataGraph: parsedData,
                shapesGraph: parsedShapes,
                shapesByIRI: shapeByIRI,
                sparqlDefinitionsByIRI: sparqlDefinitionsByIRI
            )
        )

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
        let disallowedResultCount = sortedViolations.filter { conformanceDisallowedSeverities.contains($0.severity) }.count

        if sortedViolations.isEmpty {
            return SHACLValidationResult(
                conforms: true,
                message: "SHACL Core subset validation passed for \(parsedShapes.shapes.count) shapes.",
                violations: []
            )
        }

        return SHACLValidationResult(
            conforms: disallowedResultCount == 0,
            message: "SHACL Core subset validation produced \(sortedViolations.count) result(s), including \(violationCount) violation(s) and \(disallowedResultCount) disallowed severities.",
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
        let ruleByIRI = Dictionary(uniqueKeysWithValues: shapesGraph.tripleRules.map { ($0.ruleIRI, $0) })
        let sparqlByIRI = Dictionary(uniqueKeysWithValues: shapesGraph.sparqlDefinitions.map { ($0.sparqlIRI, $0) })

        for shape in shapesGraph.shapes where shape.kind == .nodeShape {
            for target in shape.targets {
                if case .targetNode(let targetNodeIRI) = target,
                   let sparql = sparqlByIRI[targetNodeIRI],
                   sparql.selectQuery == nil {
                    throw SHACLError.invalidShapesGraph("SPARQL target \(targetNodeIRI) must define sh:select")
                }
            }
            if let expressionIRI = shape.expressionIRI,
               expressionByIRI[expressionIRI] == nil,
               expressionIRI != SHACLIRIs.shThis,
               !isDirectExpressionLiteralTerm(expressionIRI) {
                throw SHACLError.invalidShapesGraph(
                    "Node shape \(shape.shapeIRI) references missing node expression \(expressionIRI)"
                )
            }
            if let nodeByExpressionIRI = shape.nodeByExpressionIRI, expressionByIRI[nodeByExpressionIRI] == nil {
                guard let referencedShape = byIRI[nodeByExpressionIRI], referencedShape.kind == .nodeShape else {
                    throw SHACLError.invalidShapesGraph(
                        "Node shape \(shape.shapeIRI) references missing nodeByExpression \(nodeByExpressionIRI)"
                    )
                }
            }
            let referencedNodeShapeIRIs =
                [shape.nodeShapeReferenceIRI, shape.notShapeIRI, shape.reifierShapeIRI, shape.memberShapeIRI, shape.qualifiedValueShapeIRI].compactMap { $0 }
                + shape.andShapeIRIs
                + shape.orShapeIRIs
                + shape.xoneShapeIRIs

            for referencedIRI in referencedNodeShapeIRIs {
                guard let nodeShape = byIRI[referencedIRI], nodeShape.kind == .nodeShape else {
                    throw SHACLError.invalidShapesGraph(
                        "Node shape \(shape.shapeIRI) references missing or non-node shape \(referencedIRI)"
                    )
                }
            }
            for propertyShapeIRI in shape.propertyShapeIRIs {
                guard let propertyShape = byIRI[propertyShapeIRI], propertyShape.kind == .propertyShape else {
                    throw SHACLError.invalidShapesGraph(
                        "Node shape \(shape.shapeIRI) references missing or non-property shape \(propertyShapeIRI)"
                    )
                }
            }
            for ruleIRI in shape.tripleRuleIRIs {
                guard let rule = ruleByIRI[ruleIRI] else {
                    throw SHACLError.invalidShapesGraph(
                        "Node shape \(shape.shapeIRI) references missing triple rule \(ruleIRI)"
                    )
                }
                for conditionShapeIRI in rule.conditionShapeIRIs {
                    guard byIRI[conditionShapeIRI] != nil else {
                        throw SHACLError.invalidShapesGraph(
                            "Triple rule \(ruleIRI) references missing condition shape \(conditionShapeIRI)"
                        )
                    }
                }
            }
            for sparqlIRI in shape.sparqlConstraintIRIs {
                guard let sparql = sparqlByIRI[sparqlIRI] else {
                    throw SHACLError.invalidShapesGraph(
                        "Node shape \(shape.shapeIRI) references missing SPARQL constraint \(sparqlIRI)"
                    )
                }
                if sparql.selectQuery == nil && sparql.askQuery == nil {
                    throw SHACLError.invalidShapesGraph("SPARQL constraint \(sparqlIRI) is missing sh:select/sh:ask")
                }
            }
            for sparqlTargetIRI in shape.sparqlTargetIRIs {
                guard let sparql = sparqlByIRI[sparqlTargetIRI] else {
                    throw SHACLError.invalidShapesGraph(
                        "Node shape \(shape.shapeIRI) references missing SPARQL target \(sparqlTargetIRI)"
                    )
                }
                if sparql.selectQuery == nil {
                    throw SHACLError.invalidShapesGraph("SPARQL target \(sparqlTargetIRI) must define sh:select")
                }
            }
        }

        for shape in shapesGraph.shapes where shape.kind == .propertyShape {
            for target in shape.targets {
                if case .targetNode(let targetNodeIRI) = target,
                   let sparql = sparqlByIRI[targetNodeIRI],
                   sparql.selectQuery == nil {
                    throw SHACLError.invalidShapesGraph("SPARQL target \(targetNodeIRI) must define sh:select")
                }
            }
            if shape.pathIRI == nil && shape.expressionIRI == nil {
                throw SHACLError.invalidShapesGraph("Property shape \(shape.shapeIRI) is missing both sh:path and sh:expression")
            }
            if let expressionIRI = shape.expressionIRI,
               expressionByIRI[expressionIRI] == nil,
               expressionIRI != SHACLIRIs.shThis,
               !isDirectExpressionLiteralTerm(expressionIRI) {
                throw SHACLError.invalidShapesGraph(
                    "Property shape \(shape.shapeIRI) references missing node expression \(expressionIRI)"
                )
            }
            if let nodeByExpressionIRI = shape.nodeByExpressionIRI, expressionByIRI[nodeByExpressionIRI] == nil {
                guard let referencedShape = byIRI[nodeByExpressionIRI], referencedShape.kind == .nodeShape else {
                    throw SHACLError.invalidShapesGraph(
                        "Property shape \(shape.shapeIRI) references missing nodeByExpression \(nodeByExpressionIRI)"
                    )
                }
            }

            let referencedNodeShapeIRIs =
                [shape.nodeShapeReferenceIRI, shape.notShapeIRI, shape.reifierShapeIRI, shape.memberShapeIRI, shape.qualifiedValueShapeIRI].compactMap { $0 }
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
            for sparqlIRI in shape.sparqlConstraintIRIs {
                guard let sparql = sparqlByIRI[sparqlIRI] else {
                    throw SHACLError.invalidShapesGraph(
                        "Property shape \(shape.shapeIRI) references missing SPARQL constraint \(sparqlIRI)"
                    )
                }
                if sparql.selectQuery == nil && sparql.askQuery == nil {
                    throw SHACLError.invalidShapesGraph("SPARQL constraint \(sparqlIRI) is missing sh:select/sh:ask")
                }
            }
            for sparqlTargetIRI in shape.sparqlTargetIRIs {
                guard let sparql = sparqlByIRI[sparqlTargetIRI] else {
                    throw SHACLError.invalidShapesGraph(
                        "Property shape \(shape.shapeIRI) references missing SPARQL target \(sparqlTargetIRI)"
                    )
                }
                if sparql.selectQuery == nil {
                    throw SHACLError.invalidShapesGraph("SPARQL target \(sparqlTargetIRI) must define sh:select")
                }
            }
        }
    }

    private func isDirectExpressionLiteralTerm(_ term: String) -> Bool {
        if term.hasPrefix("\"") {
            return true
        }
        return Int(term) != nil || Double(term) != nil
    }

    private func isTrueBooleanTerm(_ term: String) -> Bool {
        term == "true"
            || term == "1"
            || term == "\"true\""
            || term == "\"true\"^^\(SHACLIRIs.xsdBoolean)"
            || term == "\"1\"^^\(SHACLIRIs.xsdBoolean)"
    }

    private func resolveFocusNodes(
        dataGraph: SHACLDataGraph,
        shapesGraph: SHACLShapesGraph,
        sparqlDefinitionsByIRI: [String: SHACLSPARQLDefinition]
    ) throws -> [SHACLTargetResolution] {
        let baseline = focusResolver.resolve(dataGraph: dataGraph, shapesGraph: shapesGraph)
        let baselineByShapeIRI = Dictionary(uniqueKeysWithValues: baseline.map { ($0.shapeIRI, Set($0.focusNodes)) })
        let shapesByIRI = Dictionary(uniqueKeysWithValues: shapesGraph.shapes.map { ($0.shapeIRI, $0) })
        let nodeExpressionsByIRI = Dictionary(uniqueKeysWithValues: shapesGraph.nodeExpressions.map { ($0.expressionIRI, $0) })
        let expressionGraph = SHACLShapesGraph(
            shapes: Array(shapesByIRI.values),
            nodeExpressions: Array(nodeExpressionsByIRI.values)
        )
        let candidateTargetWhereNodes = Set(dataGraph.triples.flatMap { [$0.subject, $0.object] }).sorted()

        return try shapesGraph.shapes.map { shape in
            var focus = baselineByShapeIRI[shape.shapeIRI] ?? []
            for target in shape.targets {
                guard case .targetWhere(let whereShapeIRI) = target else {
                    continue
                }
                guard shapesByIRI[whereShapeIRI] != nil else {
                    continue
                }
                for candidate in candidateTargetWhereNodes {
                    var visited: Set<String> = []
                    if conforms(
                        valueNode: candidate,
                        toShapeIRI: whereShapeIRI,
                        dataGraph: dataGraph,
                        shapesByIRI: shapesByIRI,
                        expressionGraph: expressionGraph,
                        nodeExpressionsByIRI: nodeExpressionsByIRI,
                        depth: 0,
                        visited: &visited
                    ) {
                        focus.insert(candidate)
                    }
                }
            }
            for sparqlTargetIRI in shape.sparqlTargetIRIs.sorted() {
                guard let sparql = sparqlDefinitionsByIRI[sparqlTargetIRI], let selectQuery = sparql.selectQuery else {
                    continue
                }
                let resolved = try sparqlExecutor.select(
                    query: withSPARQLPrefixes(selectQuery, prefixes: sparql.prefixes),
                    focusNode: nil,
                    dataGraph: dataGraph,
                    shapesGraph: shapesGraph
                )
                focus.formUnion(resolved.filter { !$0.isEmpty })
            }
            return SHACLTargetResolution(shapeIRI: shape.shapeIRI, focusNodes: focus.sorted())
        }
    }

    private func evaluateSPARQLConstraints(
        resolutions: [SHACLTargetResolution],
        dataGraph: SHACLDataGraph,
        shapesGraph: SHACLShapesGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        sparqlDefinitionsByIRI: [String: SHACLSPARQLDefinition]
    ) throws -> [SHACLViolation] {
        var violations: [SHACLViolation] = []
        let expressionGraph = SHACLShapesGraph(
            shapes: Array(shapesByIRI.values),
            nodeExpressions: shapesGraph.nodeExpressions
        )

        for resolution in resolutions {
            guard let shape = shapesByIRI[resolution.shapeIRI] else {
                continue
            }
            if shape.isDeactivated {
                continue
            }
            switch shape.kind {
            case .nodeShape:
                let severity = shape.severity ?? .violation

                for focusNode in resolution.focusNodes {
                    for sparqlConstraintIRI in shape.sparqlConstraintIRIs.sorted() {
                        guard let sparql = sparqlDefinitionsByIRI[sparqlConstraintIRI] else {
                            continue
                        }

                        if let askQuery = sparql.askQuery {
                            let result = try sparqlExecutor.ask(
                                query: withSPARQLPrefixes(askQuery, prefixes: sparql.prefixes),
                                focusNode: focusNode,
                                dataGraph: dataGraph,
                                shapesGraph: shapesGraph
                            )
                            if !result {
                                violations.append(
                                    SHACLViolation(
                                        severity: severity,
                                        shapeIRI: shape.shapeIRI,
                                        focusNode: focusNode,
                                        pathIRI: nil,
                                        valueNode: focusNode,
                                        sourceConstraintIRI: sparqlConstraintIRI,
                                        message: sparql.message ?? "SPARQL ASK constraint violation for focus node \(focusNode)"
                                    )
                                )
                            }
                        }

                        if let selectQuery = sparql.selectQuery {
                            let boundNodes = try sparqlExecutor.select(
                                query: withSPARQLPrefixes(selectQuery, prefixes: sparql.prefixes),
                                focusNode: focusNode,
                                dataGraph: dataGraph,
                                shapesGraph: shapesGraph
                            )
                            for valueNode in boundNodes.filter({ !$0.isEmpty }).sorted() {
                                violations.append(
                                    SHACLViolation(
                                        severity: severity,
                                        shapeIRI: shape.shapeIRI,
                                        focusNode: focusNode,
                                        pathIRI: nil,
                                        valueNode: valueNode,
                                        sourceConstraintIRI: sparqlConstraintIRI,
                                        message: sparql.message ?? "SPARQL SELECT constraint violation produced value \(valueNode)"
                                    )
                                )
                            }
                        }
                    }

                    for propertyShapeIRI in shape.propertyShapeIRIs.sorted() {
                        guard let propertyShape = shapesByIRI[propertyShapeIRI], propertyShape.kind == .propertyShape else {
                            continue
                        }
                        var visitedPropertySPARQL: Set<String> = []
                        violations.append(
                            contentsOf: try evaluatePropertyShapeSPARQLConstraints(
                                propertyShape: propertyShape,
                                rootFocusNode: focusNode,
                                currentNode: focusNode,
                                inheritedSeverity: shape.severity,
                                dataGraph: dataGraph,
                                shapesGraph: shapesGraph,
                                shapesByIRI: shapesByIRI,
                                sparqlDefinitionsByIRI: sparqlDefinitionsByIRI,
                                expressionGraph: expressionGraph,
                                visited: &visitedPropertySPARQL
                            )
                        )
                    }
                }
            case .propertyShape:
                for focusNode in resolution.focusNodes {
                    var visitedPropertySPARQL: Set<String> = []
                    violations.append(
                        contentsOf: try evaluatePropertyShapeSPARQLConstraints(
                            propertyShape: shape,
                            rootFocusNode: focusNode,
                            currentNode: focusNode,
                            inheritedSeverity: shape.severity,
                            dataGraph: dataGraph,
                            shapesGraph: shapesGraph,
                            shapesByIRI: shapesByIRI,
                            sparqlDefinitionsByIRI: sparqlDefinitionsByIRI,
                            expressionGraph: expressionGraph,
                            visited: &visitedPropertySPARQL
                        )
                    )
                }
            }
        }

        return violations
    }

    private func evaluatePropertyShapeSPARQLConstraints(
        propertyShape: SHACLShapeDefinition,
        rootFocusNode: String,
        currentNode: String,
        inheritedSeverity: SHACLSeverity?,
        dataGraph: SHACLDataGraph,
        shapesGraph: SHACLShapesGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        sparqlDefinitionsByIRI: [String: SHACLSPARQLDefinition],
        expressionGraph: SHACLShapesGraph,
        visited: inout Set<String>
    ) throws -> [SHACLViolation] {
        if propertyShape.isDeactivated {
            return []
        }
        let visitKey = "\(propertyShape.shapeIRI)|\(currentNode)"
        if visited.contains(visitKey) {
            return []
        }
        visited.insert(visitKey)
        defer { visited.remove(visitKey) }

        var violations: [SHACLViolation] = []
        let propertyValues = sparqlPropertyValues(
            for: propertyShape,
            focusNode: currentNode,
            dataGraph: dataGraph,
            expressionGraph: expressionGraph
        )
        if propertyValues.isEmpty {
            return []
        }

        let propertySeverity = propertyShape.severity ?? inheritedSeverity ?? .violation
        for sparqlConstraintIRI in propertyShape.sparqlConstraintIRIs.sorted() {
            guard let sparql = sparqlDefinitionsByIRI[sparqlConstraintIRI] else {
                continue
            }

            for propertyValue in propertyValues {
                if let askQuery = sparql.askQuery {
                    let result = try sparqlExecutor.ask(
                        query: withSPARQLPrefixes(askQuery, prefixes: sparql.prefixes),
                        focusNode: propertyValue,
                        dataGraph: dataGraph,
                        shapesGraph: shapesGraph
                    )
                    if !result {
                        violations.append(
                            SHACLViolation(
                                severity: propertySeverity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: rootFocusNode,
                                pathIRI: propertyShape.pathIRI,
                                valueNode: propertyValue,
                                sourceConstraintIRI: sparqlConstraintIRI,
                                message: sparql.message ?? "SPARQL ASK constraint violation for property value \(propertyValue)"
                            )
                        )
                    }
                }

                if let selectQuery = sparql.selectQuery {
                    let boundNodes = try sparqlExecutor.select(
                        query: withSPARQLPrefixes(selectQuery, prefixes: sparql.prefixes),
                        focusNode: propertyValue,
                        dataGraph: dataGraph,
                        shapesGraph: shapesGraph
                    )
                    for valueNode in boundNodes.filter({ !$0.isEmpty }).sorted() {
                        violations.append(
                            SHACLViolation(
                                severity: propertySeverity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: rootFocusNode,
                                pathIRI: propertyShape.pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: sparqlConstraintIRI,
                                message: sparql.message ?? "SPARQL SELECT constraint violation produced value \(valueNode) for property value \(propertyValue)"
                            )
                        )
                    }
                }
            }
        }

        for nestedPropertyShapeIRI in propertyShape.propertyShapeIRIs.sorted() {
            guard let nestedShape = shapesByIRI[nestedPropertyShapeIRI], nestedShape.kind == .propertyShape else {
                continue
            }
            for propertyValue in propertyValues {
                violations.append(
                    contentsOf: try evaluatePropertyShapeSPARQLConstraints(
                        propertyShape: nestedShape,
                        rootFocusNode: rootFocusNode,
                        currentNode: propertyValue,
                        inheritedSeverity: propertySeverity,
                        dataGraph: dataGraph,
                        shapesGraph: shapesGraph,
                        shapesByIRI: shapesByIRI,
                        sparqlDefinitionsByIRI: sparqlDefinitionsByIRI,
                        expressionGraph: expressionGraph,
                        visited: &visited
                    )
                )
            }
        }

        return violations
    }

    private func sparqlPropertyValues(
        for propertyShape: SHACLShapeDefinition,
        focusNode: String,
        dataGraph: SHACLDataGraph,
        expressionGraph: SHACLShapesGraph
    ) -> [String] {
        if let propertyPath = propertyShape.propertyPath {
            return resolvePropertyPathValues(
                propertyPath,
                from: focusNode,
                dataGraph: dataGraph
            ).sorted()
        }
        if let pathIRI = propertyShape.pathIRI {
            return dataGraph.triples
                .filter { $0.subject == focusNode && $0.predicate == pathIRI }
                .map(\.object)
        }
        if let expressionIRI = propertyShape.expressionIRI {
            return SHACLNodeExpressionEvaluator()
                .evaluate(
                    expressionIRI: expressionIRI,
                    focusNode: focusNode,
                    shapesGraph: expressionGraph,
                    dataGraph: dataGraph
                )
                .sorted()
        }
        return []
    }

    private func applyRules(
        dataGraph: SHACLDataGraph,
        shapesGraph: SHACLShapesGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition]
    ) -> SHACLDataGraph {
        let ruleByIRI = Dictionary(uniqueKeysWithValues: shapesGraph.tripleRules.map { ($0.ruleIRI, $0) })
        let nodeShapesWithRules = shapesGraph.shapes
            .filter { $0.kind == .nodeShape && !$0.tripleRuleIRIs.isEmpty }
            .sorted(by: { $0.shapeIRI < $1.shapeIRI })

        if nodeShapesWithRules.isEmpty || ruleByIRI.isEmpty {
            return dataGraph
        }

        var triples = Set(dataGraph.triples)
        let expressionGraph = SHACLShapesGraph(
            shapes: Array(shapesByIRI.values),
            nodeExpressions: Array(nodeExpressionsByIRI.values)
        )

        for _ in 0..<maxRuleIterations {
            let graphSnapshot = SHACLDataGraph(triples: Array(triples))
            let resolutions = focusResolver.resolve(dataGraph: graphSnapshot, shapesGraph: shapesGraph)
            let focusByShapeIRI = Dictionary(uniqueKeysWithValues: resolutions.map { ($0.shapeIRI, $0.focusNodes) })
            var insertedAny = false

            for nodeShape in nodeShapesWithRules {
                let focusNodes = focusByShapeIRI[nodeShape.shapeIRI] ?? []
                let orderedRules = nodeShape.tripleRuleIRIs
                    .compactMap { ruleByIRI[$0] }
                    .sorted { lhs, rhs in
                        let lhsOrder = lhs.ruleOrder ?? 0
                        let rhsOrder = rhs.ruleOrder ?? 0
                        if lhsOrder != rhsOrder {
                            return lhsOrder < rhsOrder
                        }
                        return lhs.ruleIRI < rhs.ruleIRI
                    }
                for focusNode in focusNodes {
                    for rule in orderedRules {
                        if !ruleConditionsSatisfied(
                            rule: rule,
                            focusNode: focusNode,
                            dataGraph: graphSnapshot,
                            shapesByIRI: shapesByIRI,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI
                        ) {
                            continue
                        }

                        let subjects = evaluateRuleTerm(
                            rule.subjectTerm,
                            focusNode: focusNode,
                            dataGraph: graphSnapshot,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI
                        )
                        let predicates = evaluateRuleTerm(
                            rule.predicateTerm,
                            focusNode: focusNode,
                            dataGraph: graphSnapshot,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI
                        )
                        let objects = evaluateRuleTerm(
                            rule.objectTerm,
                            focusNode: focusNode,
                            dataGraph: graphSnapshot,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI
                        )

                        for subject in subjects {
                            for predicate in predicates {
                                for object in objects {
                                    let triple = SHACLDataTriple(subject: subject, predicate: predicate, object: object)
                                    let inserted = triples.insert(triple).inserted
                                    insertedAny = insertedAny || inserted
                                }
                            }
                        }
                    }
                }
            }

            if !insertedAny {
                break
            }
        }

        let stableTriples = triples.sorted { lhs, rhs in
            (lhs.subject, lhs.predicate, lhs.object) < (rhs.subject, rhs.predicate, rhs.object)
        }
        return SHACLDataGraph(triples: stableTriples)
    }

    private func ruleConditionsSatisfied(
        rule: SHACLTripleRuleDefinition,
        focusNode: String,
        dataGraph: SHACLDataGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        expressionGraph: SHACLShapesGraph,
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition]
    ) -> Bool {
        if rule.conditionShapeIRIs.isEmpty {
            return true
        }
        var visited: Set<String> = []
        return rule.conditionShapeIRIs.allSatisfy { conditionShapeIRI in
            conforms(
                valueNode: focusNode,
                toShapeIRI: conditionShapeIRI,
                dataGraph: dataGraph,
                shapesByIRI: shapesByIRI,
                expressionGraph: expressionGraph,
                nodeExpressionsByIRI: nodeExpressionsByIRI,
                depth: 0,
                visited: &visited
            )
        }
    }

    private func evaluateRuleTerm(
        _ term: String,
        focusNode: String,
        dataGraph: SHACLDataGraph,
        expressionGraph: SHACLShapesGraph,
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition]
    ) -> [String] {
        if term == SHACLIRIs.shThis {
            return [focusNode]
        }

        if nodeExpressionsByIRI[term] != nil {
            return SHACLNodeExpressionEvaluator()
                .evaluate(
                    expressionIRI: term,
                    focusNode: focusNode,
                    shapesGraph: expressionGraph,
                    dataGraph: dataGraph
                )
                .filter { !$0.isEmpty }
                .sorted()
        }

        return [term]
    }

    private func evaluate(
        nodeShape: SHACLShapeDefinition,
        focusNode: String,
        dataGraph: SHACLDataGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        expressionGraph: SHACLShapesGraph,
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition] = [:],
        depth: Int,
        visited: inout Set<String>
    ) -> [SHACLViolation] {
        var violations: [SHACLViolation] = []
        if depth > maxReferenceDepth {
            return violations
        }
        if nodeShape.isDeactivated {
            return violations
        }
        let nodeSeverity = nodeShape.severity ?? .violation

        if let classIRI = nodeShape.classIRI {
            let hasRequiredType = nodeSatisfiesClassConstraint(
                focusNode,
                classIRI: classIRI,
                dataGraph: dataGraph
            )
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

            if let datatypeIRI = nodeShape.datatypeIRI {
                let actualDatatype = inferredDatatypeIRI(for: focusNode)
                if actualDatatype != datatypeIRI || !isLexicallyValidLiteral(focusNode, forDatatypeIRI: datatypeIRI) {
                    let actualText = actualDatatype ?? "none"
                    violations.append(
                        SHACLViolation(
                        severity: nodeSeverity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: focusNode,
                        sourceConstraintIRI: SHACLIRIs.datatype,
                        message: "datatype violation: value \(focusNode) has datatype \(actualText), expected \(datatypeIRI)"
                    )
                )
            }
        }

        if nodeShape.minLength != nil || nodeShape.maxLength != nil || nodeShape.pattern != nil {
            if let lexical = extractLiteralLexicalForm(focusNode) {
                if let minLength = nodeShape.minLength, lexical.count < minLength {
                    violations.append(
                        SHACLViolation(
                            severity: nodeSeverity,
                            shapeIRI: nodeShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: nil,
                            valueNode: focusNode,
                            sourceConstraintIRI: SHACLIRIs.minLength,
                            message: "minLength violation: expected >= \(minLength), got \(lexical.count)"
                        )
                    )
                }

                if let maxLength = nodeShape.maxLength, lexical.count > maxLength {
                    violations.append(
                        SHACLViolation(
                            severity: nodeSeverity,
                            shapeIRI: nodeShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: nil,
                            valueNode: focusNode,
                            sourceConstraintIRI: SHACLIRIs.maxLength,
                            message: "maxLength violation: expected <= \(maxLength), got \(lexical.count)"
                        )
                    )
                }

                if let pattern = nodeShape.pattern {
                    let range = NSRange(lexical.startIndex..<lexical.endIndex, in: lexical)
                    let regex = try? NSRegularExpression(pattern: pattern)
                    let matches = regex?.firstMatch(in: lexical, options: [], range: range) != nil
                    if !matches {
                        violations.append(
                            SHACLViolation(
                                severity: nodeSeverity,
                                shapeIRI: nodeShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: nil,
                                valueNode: focusNode,
                                sourceConstraintIRI: SHACLIRIs.pattern,
                                message: "pattern violation: value \(lexical) does not match \(pattern)"
                            )
                        )
                    }
                }
            } else {
                violations.append(
                    SHACLViolation(
                        severity: nodeSeverity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: focusNode,
                        sourceConstraintIRI: SHACLIRIs.minLength,
                        message: "string facet violation: value \(focusNode) is not a literal"
                    )
                )
            }
        }

        if nodeShape.minInclusive != nil || nodeShape.maxInclusive != nil || nodeShape.minExclusive != nil || nodeShape.maxExclusive != nil {
            var hasComparableRangeValue = true

            if let minimum = nodeShape.minInclusive {
                if let comparison = compareRangeValueTerm(focusNode, toBoundTerm: minimum) {
                    if comparison == .orderedAscending {
                        violations.append(
                            SHACLViolation(
                                severity: nodeSeverity,
                                shapeIRI: nodeShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: nil,
                                valueNode: focusNode,
                                sourceConstraintIRI: SHACLIRIs.minInclusive,
                                message: "minInclusive violation: expected >= \(minimum), got \(focusNode)"
                            )
                        )
                    }
                } else {
                    violations.append(
                        SHACLViolation(
                            severity: nodeSeverity,
                            shapeIRI: nodeShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: nil,
                            valueNode: focusNode,
                            sourceConstraintIRI: SHACLIRIs.minInclusive,
                            message: rangeTypeViolationMessage(valueTerm: focusNode, boundTerm: minimum)
                        )
                    )
                    hasComparableRangeValue = false
                }
            }

            if hasComparableRangeValue, let maximum = nodeShape.maxInclusive {
                if let comparison = compareRangeValueTerm(focusNode, toBoundTerm: maximum) {
                    if comparison == .orderedDescending {
                        violations.append(
                            SHACLViolation(
                                severity: nodeSeverity,
                                shapeIRI: nodeShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: nil,
                                valueNode: focusNode,
                                sourceConstraintIRI: SHACLIRIs.maxInclusive,
                                message: "maxInclusive violation: expected <= \(maximum), got \(focusNode)"
                            )
                        )
                    }
                } else {
                    violations.append(
                        SHACLViolation(
                            severity: nodeSeverity,
                            shapeIRI: nodeShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: nil,
                            valueNode: focusNode,
                            sourceConstraintIRI: SHACLIRIs.maxInclusive,
                            message: rangeTypeViolationMessage(valueTerm: focusNode, boundTerm: maximum)
                        )
                    )
                    hasComparableRangeValue = false
                }
            }

            if hasComparableRangeValue, let minimum = nodeShape.minExclusive {
                if let comparison = compareRangeValueTerm(focusNode, toBoundTerm: minimum) {
                    if comparison != .orderedDescending {
                        violations.append(
                            SHACLViolation(
                                severity: nodeSeverity,
                                shapeIRI: nodeShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: nil,
                                valueNode: focusNode,
                                sourceConstraintIRI: SHACLIRIs.minExclusive,
                                message: "minExclusive violation: expected > \(minimum), got \(focusNode)"
                            )
                        )
                    }
                } else {
                    violations.append(
                        SHACLViolation(
                            severity: nodeSeverity,
                            shapeIRI: nodeShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: nil,
                            valueNode: focusNode,
                            sourceConstraintIRI: SHACLIRIs.minExclusive,
                            message: rangeTypeViolationMessage(valueTerm: focusNode, boundTerm: minimum)
                        )
                    )
                    hasComparableRangeValue = false
                }
            }

            if hasComparableRangeValue, let maximum = nodeShape.maxExclusive {
                if let comparison = compareRangeValueTerm(focusNode, toBoundTerm: maximum) {
                    if comparison != .orderedAscending {
                        violations.append(
                            SHACLViolation(
                                severity: nodeSeverity,
                                shapeIRI: nodeShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: nil,
                                valueNode: focusNode,
                                sourceConstraintIRI: SHACLIRIs.maxExclusive,
                                message: "maxExclusive violation: expected < \(maximum), got \(focusNode)"
                            )
                        )
                    }
                } else {
                    violations.append(
                        SHACLViolation(
                            severity: nodeSeverity,
                            shapeIRI: nodeShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: nil,
                            valueNode: focusNode,
                            sourceConstraintIRI: SHACLIRIs.maxExclusive,
                            message: rangeTypeViolationMessage(valueTerm: focusNode, boundTerm: maximum)
                        )
                    )
                }
            }
        }

        if let requiredValue = nodeShape.hasValue, focusNode != requiredValue {
            violations.append(
                SHACLViolation(
                    severity: nodeSeverity,
                    shapeIRI: nodeShape.shapeIRI,
                    focusNode: focusNode,
                    pathIRI: nil,
                    valueNode: focusNode,
                    sourceConstraintIRI: SHACLIRIs.hasValue,
                    message: "hasValue violation: required value \(requiredValue) not present"
                )
            )
        }

        if !nodeShape.inValues.isEmpty {
            let allowed = Set(nodeShape.inValues)
            if !allowed.contains(focusNode) {
                violations.append(
                    SHACLViolation(
                        severity: nodeSeverity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: focusNode,
                        sourceConstraintIRI: SHACLIRIs.in,
                        message: "in violation: value \(focusNode) not found in allowed set"
                    )
                )
            }
        }

        if !nodeShape.languageInValues.isEmpty {
            let languageRanges = nodeShape.languageInValues.compactMap { extractLiteralLexicalForm($0)?.lowercased() }
            if !matchesLanguageIn(languageTag: extractLiteralLanguageTag(focusNode), ranges: languageRanges) {
                violations.append(
                    SHACLViolation(
                        severity: nodeSeverity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: focusNode,
                        sourceConstraintIRI: SHACLIRIs.languageIn,
                        message: "languageIn violation: value \(focusNode) language tag not in allowed set"
                    )
                )
            }
        }

        if let equalsIRI = nodeShape.equalsIRI {
            let relatedValues = Set(dataGraph.triples.filter { $0.subject == focusNode && $0.predicate == equalsIRI }.map(\.object))
            let expectedValues: Set<String> = [focusNode]
            let mismatchValues = expectedValues.symmetricDifference(relatedValues).sorted()
            for mismatchValue in mismatchValues {
                violations.append(
                    SHACLViolation(
                        severity: nodeSeverity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: mismatchValue,
                        sourceConstraintIRI: SHACLIRIs.equals,
                        message: "equals violation: value \(mismatchValue) not aligned with predicate \(equalsIRI)"
                    )
                )
            }
        }

        if let disjointIRI = nodeShape.disjointIRI {
            let relatedValues = Set(dataGraph.triples.filter { $0.subject == focusNode && $0.predicate == disjointIRI }.map(\.object))
            if relatedValues.contains(focusNode) {
                violations.append(
                    SHACLViolation(
                        severity: nodeSeverity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: focusNode,
                        sourceConstraintIRI: SHACLIRIs.disjoint,
                        message: "disjoint violation: value \(focusNode) overlaps predicate \(disjointIRI)"
                    )
                )
            }
        }

        if nodeShape.isClosed {
            let allowedPredicates = Set(
                nodeShape.propertyShapeIRIs.compactMap { propertyShapeIRI in
                    shapesByIRI[propertyShapeIRI]?.pathIRI
                }
            )
            let ignoredPredicates = Set(nodeShape.ignoredPropertyIRIs)
            for triple in dataGraph.triples where triple.subject == focusNode {
                if allowedPredicates.contains(triple.predicate) || ignoredPredicates.contains(triple.predicate) {
                    continue
                }
                violations.append(
                    SHACLViolation(
                        severity: nodeSeverity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: triple.predicate,
                        valueNode: triple.object,
                        sourceConstraintIRI: SHACLIRIs.closed,
                        message: "closed violation: predicate \(triple.predicate) is not permitted by closed shape"
                    )
                )
            }
        }

        violations.append(
            contentsOf: evaluateNodeLogicalConstraints(
                nodeShape: nodeShape,
                focusNode: focusNode,
                severity: nodeSeverity,
                dataGraph: dataGraph,
                shapesByIRI: shapesByIRI,
                expressionGraph: expressionGraph,
                nodeExpressionsByIRI: nodeExpressionsByIRI,
                depth: depth,
                visited: &visited
            )
        )

        if let expressionIRI = nodeShape.expressionIRI {
            let outputNodes = SHACLNodeExpressionEvaluator().evaluate(
                expressionIRI: expressionIRI,
                focusNode: focusNode,
                shapesGraph: expressionGraph,
                dataGraph: dataGraph
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

        if let nodeByExpressionIRI = nodeShape.nodeByExpressionIRI {
            let referencedShapeIRIs = SHACLNodeExpressionEvaluator()
                .evaluate(
                    expressionIRI: nodeByExpressionIRI,
                    focusNode: focusNode,
                    shapesGraph: expressionGraph,
                    dataGraph: dataGraph
                )
                .sorted()
            for referencedShapeIRI in referencedShapeIRIs {
                let doesConform = conforms(
                    valueNode: focusNode,
                    toNodeShapeIRI: referencedShapeIRI,
                    dataGraph: dataGraph,
                    shapesByIRI: shapesByIRI,
                    expressionGraph: expressionGraph,
                    nodeExpressionsByIRI: nodeExpressionsByIRI,
                    depth: depth,
                    visited: &visited
                )
                if !doesConform {
                    violations.append(
                        SHACLViolation(
                            severity: nodeSeverity,
                            shapeIRI: nodeShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: nil,
                            valueNode: focusNode,
                            sourceConstraintIRI: referencedShapeIRI,
                            message: "nodeByExpression violation: focus node \(focusNode) does not conform to \(referencedShapeIRI)"
                        )
                    )
                }
            }
        }

        if let nodeReference = nodeShape.nodeShapeReferenceIRI,
           let referencedShape = shapesByIRI[nodeReference],
           referencedShape.kind == .nodeShape {
            let key = "\(referencedShape.shapeIRI)|\(focusNode)"
            if !visited.contains(key) {
                visited.insert(key)
                let nestedViolations = evaluate(
                    nodeShape: referencedShape,
                    focusNode: focusNode,
                    dataGraph: dataGraph,
                    shapesByIRI: shapesByIRI,
                    expressionGraph: expressionGraph,
                    nodeExpressionsByIRI: nodeExpressionsByIRI,
                    depth: depth + 1,
                    visited: &visited
                )
                visited.remove(key)
                violations.append(contentsOf: nestedViolations)
            }
        }

        for propertyShapeIRI in nodeShape.propertyShapeIRIs {
            guard let propertyShape = shapesByIRI[propertyShapeIRI], propertyShape.kind == .propertyShape else {
                continue
            }
            if propertyShape.isDeactivated {
                continue
            }
            let pathIRI = propertyShape.pathIRI
            let expressionIRI = propertyShape.expressionIRI
            if pathIRI == nil && expressionIRI == nil {
                continue
            }
            let severity = propertyShape.severity ?? nodeShape.severity ?? .violation

            let values: [String]
            if let propertyPath = propertyShape.propertyPath {
                values = resolvePropertyPathValues(
                    propertyPath,
                    from: focusNode,
                    dataGraph: dataGraph
                ).sorted()
            } else if let pathIRI {
                values = dataGraph.triples
                    .filter { $0.subject == focusNode && $0.predicate == pathIRI }
                    .map(\.object)
            } else if let expressionIRI {
                values = SHACLNodeExpressionEvaluator()
                    .evaluate(
                        expressionIRI: expressionIRI,
                        focusNode: focusNode,
                        shapesGraph: expressionGraph,
                        dataGraph: dataGraph
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
                        shapesGraph: expressionGraph,
                        dataGraph: dataGraph
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
                    let hasRequiredType = nodeSatisfiesClassConstraint(
                        valueNode,
                        classIRI: classIRI,
                        dataGraph: dataGraph
                    )
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
                    if actualDatatype != datatypeIRI || !isLexicallyValidLiteral(valueNode, forDatatypeIRI: datatypeIRI) {
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

            if propertyShape.singleLine {
                for valueNode in values {
                    guard let lexical = extractLiteralLexicalForm(valueNode) else {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.singleLine,
                                message: "singleLine violation: value \(valueNode) is not a literal"
                            )
                        )
                        continue
                    }

                    if containsSingleLineDisallowedBreak(lexical) {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.singleLine,
                                message: "singleLine violation: value \(valueNode) contains line breaks"
                            )
                        )
                    }
                }
            }

            if propertyShape.minInclusive != nil
                || propertyShape.maxInclusive != nil
                || propertyShape.minExclusive != nil
                || propertyShape.maxExclusive != nil {
                for valueNode in values {
                    if let minimum = propertyShape.minInclusive {
                        guard let comparison = compareRangeValueTerm(valueNode, toBoundTerm: minimum) else {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.minInclusive,
                                    message: rangeTypeViolationMessage(valueTerm: valueNode, boundTerm: minimum)
                                )
                            )
                            continue
                        }

                        if comparison == .orderedAscending {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.minInclusive,
                                    message: "minInclusive violation: expected >= \(minimum), got \(valueNode)"
                                )
                            )
                        }
                    }

                    if let maximum = propertyShape.maxInclusive {
                        guard let comparison = compareRangeValueTerm(valueNode, toBoundTerm: maximum) else {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.maxInclusive,
                                    message: rangeTypeViolationMessage(valueTerm: valueNode, boundTerm: maximum)
                                )
                            )
                            continue
                        }

                        if comparison == .orderedDescending {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.maxInclusive,
                                    message: "maxInclusive violation: expected <= \(maximum), got \(valueNode)"
                                )
                            )
                        }
                    }

                    if let minimum = propertyShape.minExclusive {
                        guard let comparison = compareRangeValueTerm(valueNode, toBoundTerm: minimum) else {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.minExclusive,
                                    message: rangeTypeViolationMessage(valueTerm: valueNode, boundTerm: minimum)
                                )
                            )
                            continue
                        }
                        if comparison != .orderedDescending {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.minExclusive,
                                    message: "minExclusive violation: expected > \(minimum), got \(valueNode)"
                                )
                            )
                        }
                    }

                    if let maximum = propertyShape.maxExclusive {
                        guard let comparison = compareRangeValueTerm(valueNode, toBoundTerm: maximum) else {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.maxExclusive,
                                    message: rangeTypeViolationMessage(valueTerm: valueNode, boundTerm: maximum)
                                )
                            )
                            continue
                        }
                        if comparison != .orderedAscending {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.maxExclusive,
                                    message: "maxExclusive violation: expected < \(maximum), got \(valueNode)"
                                )
                            )
                        }
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

            if !propertyShape.languageInValues.isEmpty {
                let languageRanges = propertyShape.languageInValues.compactMap { extractLiteralLexicalForm($0)?.lowercased() }
                for valueNode in values {
                    if !matchesLanguageIn(languageTag: extractLiteralLanguageTag(valueNode), ranges: languageRanges) {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.languageIn,
                                message: "languageIn violation: value \(valueNode) language tag not in allowed set"
                            )
                        )
                    }
                }
            }

            if propertyShape.uniqueLang {
                var languageCounts: [String: Int] = [:]
                for valueNode in values {
                    guard let language = extractLiteralLanguageTag(valueNode)?.lowercased() else {
                        continue
                    }
                    languageCounts[language, default: 0] += 1
                }
                for (_, count) in languageCounts where count > 1 {
                    for _ in 0..<(count - 1) {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                sourceConstraintIRI: SHACLIRIs.uniqueLang,
                                message: "uniqueLang violation: duplicate language-tagged values detected"
                            )
                        )
                    }
                }
            }

            if let lessThanIRI = propertyShape.lessThanIRI {
                let comparisonValues = evaluatePropertyPairComparisonValues(
                    propertyPathTerm: lessThanIRI,
                    focusNode: focusNode,
                    dataGraph: dataGraph
                )
                for valueNode in values {
                    for comparisonValue in comparisonValues {
                        guard let comparison = compareRangeValueTerm(valueNode, toBoundTerm: comparisonValue),
                              comparison == .orderedAscending else {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.lessThan,
                                    message: "lessThan violation: value \(valueNode) is not < \(comparisonValue)"
                                )
                            )
                            continue
                        }
                    }
                }
            }

            if let lessThanOrEqualsIRI = propertyShape.lessThanOrEqualsIRI {
                let comparisonValues = evaluatePropertyPairComparisonValues(
                    propertyPathTerm: lessThanOrEqualsIRI,
                    focusNode: focusNode,
                    dataGraph: dataGraph
                )
                for valueNode in values {
                    for comparisonValue in comparisonValues {
                        guard let comparison = compareRangeValueTerm(valueNode, toBoundTerm: comparisonValue),
                              comparison == .orderedAscending || comparison == .orderedSame else {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.lessThanOrEquals,
                                    message: "lessThanOrEquals violation: value \(valueNode) is not <= \(comparisonValue)"
                                )
                            )
                            continue
                        }
                    }
                }
            }

            if let equalsIRI = propertyShape.equalsIRI {
                let relatedValues = Set(
                    evaluatePropertyPairComparisonValues(
                        propertyPathTerm: equalsIRI,
                        focusNode: focusNode,
                        dataGraph: dataGraph
                    )
                )
                let expectedValues = Set(values)
                let mismatchValues = expectedValues.symmetricDifference(relatedValues).sorted()
                for mismatchValue in mismatchValues {
                    violations.append(
                        SHACLViolation(
                            severity: severity,
                            shapeIRI: propertyShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: pathIRI,
                            valueNode: mismatchValue,
                            sourceConstraintIRI: SHACLIRIs.equals,
                            message: "equals violation: value \(mismatchValue) not aligned with predicate \(equalsIRI)"
                        )
                    )
                }
            }

            if let disjointIRI = propertyShape.disjointIRI {
                let relatedValues = Set(
                    evaluatePropertyPairComparisonValues(
                        propertyPathTerm: disjointIRI,
                        focusNode: focusNode,
                        dataGraph: dataGraph
                    )
                )
                for valueNode in values where relatedValues.contains(valueNode) {
                    violations.append(
                        SHACLViolation(
                            severity: severity,
                            shapeIRI: propertyShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: pathIRI,
                            valueNode: valueNode,
                            sourceConstraintIRI: SHACLIRIs.disjoint,
                            message: "disjoint violation: value \(valueNode) overlaps predicate \(disjointIRI)"
                        )
                    )
                }
            }

            if let nodeByExpressionIRI = propertyShape.nodeByExpressionIRI {
                for valueNode in values {
                    let referencedShapeIRIs = SHACLNodeExpressionEvaluator()
                        .evaluate(
                            expressionIRI: nodeByExpressionIRI,
                            focusNode: valueNode,
                            shapesGraph: expressionGraph,
                            dataGraph: dataGraph
                        )
                        .sorted()
                    for referencedShapeIRI in referencedShapeIRIs {
                        let doesConform = conforms(
                            valueNode: valueNode,
                            toNodeShapeIRI: referencedShapeIRI,
                            dataGraph: dataGraph,
                            shapesByIRI: shapesByIRI,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI,
                            depth: depth,
                            visited: &visited
                        )
                        if !doesConform {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: referencedShapeIRI,
                                    message: "nodeByExpression violation: value \(valueNode) does not conform to \(referencedShapeIRI)"
                                )
                            )
                        }
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
                        expressionGraph: expressionGraph,
                        nodeExpressionsByIRI: nodeExpressionsByIRI,
                        depth: depth + 1,
                        visited: &visited
                    )
                    visited.remove(key)
                    violations.append(contentsOf: nestedViolations)
                }
            }

            if !propertyShape.propertyShapeIRIs.isEmpty {
                for valueNode in values {
                    let wrapperShape = SHACLShapeDefinition(
                        shapeIRI: "\(propertyShape.shapeIRI)#property-wrapper",
                        kind: .nodeShape,
                        severity: severity,
                        targets: [],
                        propertyShapeIRIs: propertyShape.propertyShapeIRIs
                    )
                    let nestedViolations = evaluate(
                        nodeShape: wrapperShape,
                        focusNode: valueNode,
                        dataGraph: dataGraph,
                        shapesByIRI: shapesByIRI,
                        expressionGraph: expressionGraph,
                        nodeExpressionsByIRI: nodeExpressionsByIRI,
                        depth: depth + 1,
                        visited: &visited
                    )
                    violations.append(contentsOf: nestedViolations)
                }
            }

            if !propertyShape.andShapeIRIs.isEmpty {
                for valueNode in values {
                    var matchesAll = true
                    for shapeIRI in propertyShape.andShapeIRIs {
                        if !conforms(
                            valueNode: valueNode,
                            toNodeShapeIRI: shapeIRI,
                            dataGraph: dataGraph,
                            shapesByIRI: shapesByIRI,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI,
                            depth: depth,
                            visited: &visited
                        ) {
                            matchesAll = false
                            break
                        }
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
                    var matchesAny = false
                    for shapeIRI in propertyShape.orShapeIRIs {
                        if conforms(
                            valueNode: valueNode,
                            toNodeShapeIRI: shapeIRI,
                            dataGraph: dataGraph,
                            shapesByIRI: shapesByIRI,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI,
                            depth: depth,
                            visited: &visited
                        ) {
                            matchesAny = true
                            break
                        }
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
                        expressionGraph: expressionGraph,
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
                    var matchCount = 0
                    for shapeIRI in propertyShape.xoneShapeIRIs {
                        if conforms(
                            valueNode: valueNode,
                            toNodeShapeIRI: shapeIRI,
                            dataGraph: dataGraph,
                            shapesByIRI: shapesByIRI,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI,
                            depth: depth,
                            visited: &visited
                        ) {
                            matchCount += 1
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

            violations.append(
                contentsOf: evaluateQualifiedValueConstraints(
                    nodeShape: nodeShape,
                    propertyShape: propertyShape,
                    propertyShapeIRI: propertyShapeIRI,
                    focusNode: focusNode,
                    pathIRI: pathIRI,
                    values: values,
                    severity: severity,
                    dataGraph: dataGraph,
                    shapesByIRI: shapesByIRI,
                    expressionGraph: expressionGraph,
                    nodeExpressionsByIRI: nodeExpressionsByIRI,
                    depth: depth,
                    visited: &visited
                )
            )
        }

        return violations
    }

    private func evaluateNodeLogicalConstraints(
        nodeShape: SHACLShapeDefinition,
        focusNode: String,
        severity: SHACLSeverity,
        dataGraph: SHACLDataGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        expressionGraph: SHACLShapesGraph,
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition],
        depth: Int,
        visited: inout Set<String>
    ) -> [SHACLViolation] {
        var violations: [SHACLViolation] = []

        if !nodeShape.andShapeIRIs.isEmpty {
            var matchesAll = true
            for shapeIRI in nodeShape.andShapeIRIs {
                if !conforms(
                    valueNode: focusNode,
                    toNodeShapeIRI: shapeIRI,
                    dataGraph: dataGraph,
                    shapesByIRI: shapesByIRI,
                    expressionGraph: expressionGraph,
                    nodeExpressionsByIRI: nodeExpressionsByIRI,
                    depth: depth,
                    visited: &visited
                ) {
                    matchesAll = false
                    break
                }
            }
            if !matchesAll {
                violations.append(
                    SHACLViolation(
                        severity: severity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: focusNode,
                        sourceConstraintIRI: SHACLIRIs.and,
                        message: "and violation: value \(focusNode) does not satisfy all referenced shapes"
                    )
                )
            }
        }

        if !nodeShape.orShapeIRIs.isEmpty {
            var matchesAny = false
            for shapeIRI in nodeShape.orShapeIRIs {
                if conforms(
                    valueNode: focusNode,
                    toNodeShapeIRI: shapeIRI,
                    dataGraph: dataGraph,
                    shapesByIRI: shapesByIRI,
                    expressionGraph: expressionGraph,
                    nodeExpressionsByIRI: nodeExpressionsByIRI,
                    depth: depth,
                    visited: &visited
                ) {
                    matchesAny = true
                    break
                }
            }
            if !matchesAny {
                violations.append(
                    SHACLViolation(
                        severity: severity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: focusNode,
                        sourceConstraintIRI: SHACLIRIs.or,
                        message: "or violation: value \(focusNode) does not satisfy any referenced shape"
                    )
                )
            }
        }

        if let forbiddenShapeIRI = nodeShape.notShapeIRI {
            let matchesForbidden = conforms(
                valueNode: focusNode,
                toNodeShapeIRI: forbiddenShapeIRI,
                dataGraph: dataGraph,
                shapesByIRI: shapesByIRI,
                expressionGraph: expressionGraph,
                nodeExpressionsByIRI: nodeExpressionsByIRI,
                depth: depth,
                visited: &visited
            )
            if matchesForbidden {
                violations.append(
                    SHACLViolation(
                        severity: severity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: focusNode,
                        sourceConstraintIRI: SHACLIRIs.not,
                        message: "not violation: value \(focusNode) conforms to forbidden shape"
                    )
                )
            }
        }

        if !nodeShape.xoneShapeIRIs.isEmpty {
            var matchCount = 0
            for shapeIRI in nodeShape.xoneShapeIRIs {
                if conforms(
                    valueNode: focusNode,
                    toNodeShapeIRI: shapeIRI,
                    dataGraph: dataGraph,
                    shapesByIRI: shapesByIRI,
                    expressionGraph: expressionGraph,
                    nodeExpressionsByIRI: nodeExpressionsByIRI,
                    depth: depth,
                    visited: &visited
                ) {
                    matchCount += 1
                }
            }

            if matchCount != 1 {
                violations.append(
                    SHACLViolation(
                        severity: severity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: focusNode,
                        sourceConstraintIRI: SHACLIRIs.xone,
                        message: "xone violation: value \(focusNode) matched \(matchCount) referenced shapes"
                    )
                )
            }
        }

        return violations
    }

    private func evaluateQualifiedValueConstraints(
        nodeShape: SHACLShapeDefinition,
        propertyShape: SHACLShapeDefinition,
        propertyShapeIRI: String,
        focusNode: String,
        pathIRI: String?,
        values: [String],
        severity: SHACLSeverity,
        dataGraph: SHACLDataGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        expressionGraph: SHACLShapesGraph,
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition],
        depth: Int,
        visited: inout Set<String>
    ) -> [SHACLViolation] {
        guard let qualifiedShapeIRI = propertyShape.qualifiedValueShapeIRI else {
            return []
        }

        let siblingQualifiedShapeIRIs: [String]
        if propertyShape.qualifiedValueShapesDisjoint {
            siblingQualifiedShapeIRIs = nodeShape.propertyShapeIRIs.compactMap { siblingIRI in
                guard siblingIRI != propertyShapeIRI,
                      let siblingShape = shapesByIRI[siblingIRI],
                      siblingShape.kind == .propertyShape,
                      siblingShape.pathIRI == propertyShape.pathIRI,
                      let siblingQualifiedShapeIRI = siblingShape.qualifiedValueShapeIRI else {
                    return nil
                }
                return siblingQualifiedShapeIRI
            }
        } else {
            siblingQualifiedShapeIRIs = []
        }

        var qualifiedMatchCount = 0
        for valueNode in values {
            let matchesQualifiedShape = conforms(
                valueNode: valueNode,
                toNodeShapeIRI: qualifiedShapeIRI,
                dataGraph: dataGraph,
                shapesByIRI: shapesByIRI,
                expressionGraph: expressionGraph,
                nodeExpressionsByIRI: nodeExpressionsByIRI,
                depth: depth,
                visited: &visited
            )
            guard matchesQualifiedShape else {
                continue
            }

            if propertyShape.qualifiedValueShapesDisjoint {
                var matchesSiblingQualifiedShape = false
                for siblingShapeIRI in siblingQualifiedShapeIRIs {
                    if conforms(
                        valueNode: valueNode,
                        toNodeShapeIRI: siblingShapeIRI,
                        dataGraph: dataGraph,
                        shapesByIRI: shapesByIRI,
                        expressionGraph: expressionGraph,
                        nodeExpressionsByIRI: nodeExpressionsByIRI,
                        depth: depth,
                        visited: &visited
                    ) {
                        matchesSiblingQualifiedShape = true
                        break
                    }
                }
                if matchesSiblingQualifiedShape {
                    continue
                }
            }

            qualifiedMatchCount += 1
        }

        var violations: [SHACLViolation] = []
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

        return violations
    }

    private func evaluateDeferredMemberShapeConstraints(
        nodeShape: SHACLShapeDefinition,
        focusNode: String,
        dataGraph: SHACLDataGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        expressionGraph: SHACLShapesGraph,
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition],
        visited: inout Set<String>
    ) -> [SHACLViolation] {
        if nodeShape.isDeactivated {
            return []
        }

        var violations: [SHACLViolation] = []
        let nodeSeverity = nodeShape.severity ?? .violation
        violations.append(
            contentsOf: evaluateDeferredListExtensionsOnValueNode(
                hostShape: nodeShape,
                rootFocusNode: focusNode,
                pathIRI: nil,
                candidateValueNode: focusNode,
                severity: nodeSeverity,
                dataGraph: dataGraph,
                shapesByIRI: shapesByIRI,
                expressionGraph: expressionGraph,
                nodeExpressionsByIRI: nodeExpressionsByIRI,
                visited: &visited
            )
        )

        for propertyShapeIRI in nodeShape.propertyShapeIRIs.sorted() {
            guard let propertyShape = shapesByIRI[propertyShapeIRI], propertyShape.kind == .propertyShape else {
                continue
            }
            violations.append(
                contentsOf: evaluateDeferredMemberShapeForPropertyShape(
                    propertyShape: propertyShape,
                    rootFocusNode: focusNode,
                    currentNode: focusNode,
                    inheritedSeverity: nodeShape.severity,
                    dataGraph: dataGraph,
                    shapesByIRI: shapesByIRI,
                    expressionGraph: expressionGraph,
                    nodeExpressionsByIRI: nodeExpressionsByIRI,
                    visited: &visited
                )
            )
        }

        return violations
    }

    private func evaluateDeferredMemberShapeForPropertyShape(
        propertyShape: SHACLShapeDefinition,
        rootFocusNode: String,
        currentNode: String,
        inheritedSeverity: SHACLSeverity?,
        dataGraph: SHACLDataGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        expressionGraph: SHACLShapesGraph,
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition],
        visited: inout Set<String>
    ) -> [SHACLViolation] {
        if propertyShape.isDeactivated {
            return []
        }

        let visitKey = "\(propertyShape.shapeIRI)|\(currentNode)"
        if visited.contains(visitKey) {
            return []
        }
        visited.insert(visitKey)
        defer { visited.remove(visitKey) }

        let severity = propertyShape.severity ?? inheritedSeverity ?? .violation
        let pathIRI = propertyShape.pathIRI
        let values: [String]
        if let propertyPath = propertyShape.propertyPath {
            values = resolvePropertyPathValues(propertyPath, from: currentNode, dataGraph: dataGraph).sorted()
        } else if let pathIRI = propertyShape.pathIRI {
            values = dataGraph.triples
                .filter { $0.subject == currentNode && $0.predicate == pathIRI }
                .map(\.object)
        } else if let expressionIRI = propertyShape.expressionIRI {
            values = SHACLNodeExpressionEvaluator()
                .evaluate(
                    expressionIRI: expressionIRI,
                    focusNode: currentNode,
                    shapesGraph: expressionGraph,
                    dataGraph: dataGraph
                )
                .sorted()
        } else {
            values = []
        }

        var violations: [SHACLViolation] = []
        for valueNode in values {
            violations.append(
                contentsOf: evaluateDeferredListExtensionsOnValueNode(
                    hostShape: propertyShape,
                    rootFocusNode: rootFocusNode,
                    pathIRI: pathIRI,
                    candidateValueNode: valueNode,
                    severity: severity,
                    dataGraph: dataGraph,
                    shapesByIRI: shapesByIRI,
                    expressionGraph: expressionGraph,
                    nodeExpressionsByIRI: nodeExpressionsByIRI,
                    visited: &visited
                )
            )
        }
        violations.append(
            contentsOf: evaluateDeferredReifierExtensionsForPropertyShape(
                propertyShape: propertyShape,
                rootFocusNode: rootFocusNode,
                currentNode: currentNode,
                pathIRI: pathIRI,
                values: values,
                severity: severity,
                dataGraph: dataGraph,
                shapesByIRI: shapesByIRI,
                expressionGraph: expressionGraph,
                nodeExpressionsByIRI: nodeExpressionsByIRI,
                visited: &visited
            )
        )

        for nestedPropertyShapeIRI in propertyShape.propertyShapeIRIs.sorted() {
            guard let nestedShape = shapesByIRI[nestedPropertyShapeIRI], nestedShape.kind == .propertyShape else {
                continue
            }
            for valueNode in values {
                violations.append(
                    contentsOf: evaluateDeferredMemberShapeForPropertyShape(
                        propertyShape: nestedShape,
                        rootFocusNode: rootFocusNode,
                        currentNode: valueNode,
                        inheritedSeverity: severity,
                        dataGraph: dataGraph,
                        shapesByIRI: shapesByIRI,
                        expressionGraph: expressionGraph,
                        nodeExpressionsByIRI: nodeExpressionsByIRI,
                        visited: &visited
                    )
                )
            }
        }

        return violations
    }

    private func evaluateDeferredListExtensionsOnValueNode(
        hostShape: SHACLShapeDefinition,
        rootFocusNode: String,
        pathIRI: String?,
        candidateValueNode: String,
        severity: SHACLSeverity,
        dataGraph: SHACLDataGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        expressionGraph: SHACLShapesGraph,
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition],
        visited: inout Set<String>
    ) -> [SHACLViolation] {
        let hasMemberShape = hostShape.memberShapeIRI != nil
        let hasUniqueMembers = hostShape.uniqueMembers
        let hasMinListLength = hostShape.minListLength != nil
        let hasMaxListLength = hostShape.maxListLength != nil
        if !hasMemberShape && !hasUniqueMembers && !hasMinListLength && !hasMaxListLength {
            return []
        }

        let triplesBySubject = Dictionary(grouping: dataGraph.triples, by: \.subject)
        guard let members = rdfListMembersStrictInDataGraph(candidateValueNode, triplesBySubject: triplesBySubject) else {
            var violations: [SHACLViolation] = []
            if hasMemberShape {
                violations.append(
                    SHACLViolation(
                        severity: severity,
                        shapeIRI: hostShape.shapeIRI,
                        focusNode: rootFocusNode,
                        pathIRI: pathIRI,
                        valueNode: candidateValueNode,
                        sourceConstraintIRI: SHACLIRIs.memberShape,
                        message: "memberShape violation: value \(candidateValueNode) is not a well-formed RDF list"
                    )
                )
            }
            if hasUniqueMembers {
                violations.append(
                    SHACLViolation(
                        severity: severity,
                        shapeIRI: hostShape.shapeIRI,
                        focusNode: rootFocusNode,
                        pathIRI: pathIRI,
                        valueNode: candidateValueNode,
                        sourceConstraintIRI: SHACLIRIs.uniqueMembers,
                        message: "uniqueMembers violation: value \(candidateValueNode) is not a well-formed RDF list"
                    )
                )
            }
            if hasMinListLength {
                violations.append(
                    SHACLViolation(
                        severity: severity,
                        shapeIRI: hostShape.shapeIRI,
                        focusNode: rootFocusNode,
                        pathIRI: pathIRI,
                        valueNode: candidateValueNode,
                        sourceConstraintIRI: SHACLIRIs.minListLength,
                        message: "minListLength violation: value \(candidateValueNode) is not a well-formed RDF list"
                    )
                )
            }
            if hasMaxListLength {
                violations.append(
                    SHACLViolation(
                        severity: severity,
                        shapeIRI: hostShape.shapeIRI,
                        focusNode: rootFocusNode,
                        pathIRI: pathIRI,
                        valueNode: candidateValueNode,
                        sourceConstraintIRI: SHACLIRIs.maxListLength,
                        message: "maxListLength violation: value \(candidateValueNode) is not a well-formed RDF list"
                    )
                )
            }
            return violations
        }

        var violations: [SHACLViolation] = []
        if let minListLength = hostShape.minListLength, members.count < minListLength {
            violations.append(
                SHACLViolation(
                    severity: severity,
                    shapeIRI: hostShape.shapeIRI,
                    focusNode: rootFocusNode,
                    pathIRI: pathIRI,
                    valueNode: candidateValueNode,
                    sourceConstraintIRI: SHACLIRIs.minListLength,
                    message: "minListLength violation: expected >= \(minListLength), got \(members.count)"
                )
            )
        }
        if let maxListLength = hostShape.maxListLength, members.count > maxListLength {
            violations.append(
                SHACLViolation(
                    severity: severity,
                    shapeIRI: hostShape.shapeIRI,
                    focusNode: rootFocusNode,
                    pathIRI: pathIRI,
                    valueNode: candidateValueNode,
                    sourceConstraintIRI: SHACLIRIs.maxListLength,
                    message: "maxListLength violation: expected <= \(maxListLength), got \(members.count)"
                )
            )
        }

        if hasUniqueMembers {
            var seen: Set<String> = []
            var hasDuplicate = false
            for member in members {
                let inserted = seen.insert(member).inserted
                if !inserted {
                    hasDuplicate = true
                    break
                }
            }
            if hasDuplicate {
                violations.append(
                    SHACLViolation(
                        severity: severity,
                        shapeIRI: hostShape.shapeIRI,
                        focusNode: rootFocusNode,
                        pathIRI: pathIRI,
                        valueNode: candidateValueNode,
                        sourceConstraintIRI: SHACLIRIs.uniqueMembers,
                        message: "uniqueMembers violation: list contains duplicate members"
                    )
                )
            }
        }

        if let memberShapeIRI = hostShape.memberShapeIRI {
            for member in members {
                var memberVisited: Set<String> = []
                if !conforms(
                    valueNode: member,
                    toNodeShapeIRI: memberShapeIRI,
                    dataGraph: dataGraph,
                    shapesByIRI: shapesByIRI,
                    expressionGraph: expressionGraph,
                    nodeExpressionsByIRI: nodeExpressionsByIRI,
                    depth: 0,
                    visited: &memberVisited
                ) {
                    violations.append(
                        SHACLViolation(
                            severity: severity,
                            shapeIRI: hostShape.shapeIRI,
                            focusNode: rootFocusNode,
                            pathIRI: pathIRI,
                            valueNode: candidateValueNode,
                            sourceConstraintIRI: SHACLIRIs.memberShape,
                            message: "memberShape violation: RDF list member \(member) does not conform to \(memberShapeIRI)"
                        )
                    )
                }
            }
        }

        return violations
    }

    private func evaluateDeferredReifierExtensionsForPropertyShape(
        propertyShape: SHACLShapeDefinition,
        rootFocusNode: String,
        currentNode: String,
        pathIRI: String?,
        values: [String],
        severity: SHACLSeverity,
        dataGraph: SHACLDataGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        expressionGraph: SHACLShapesGraph,
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition],
        visited: inout Set<String>
    ) -> [SHACLViolation] {
        let hasReifierShape = propertyShape.reifierShapeIRI != nil
        let reificationRequired = propertyShape.reificationRequired
        if !hasReifierShape && !reificationRequired {
            return []
        }
        guard let pathIRI else {
            return []
        }

        var violations: [SHACLViolation] = []
        for valueNode in values {
            let reifierNodes = findReifierNodes(
                subject: currentNode,
                predicate: pathIRI,
                object: valueNode,
                dataGraph: dataGraph
            )

            if reificationRequired && reifierNodes.isEmpty {
                violations.append(
                    SHACLViolation(
                        severity: severity,
                        shapeIRI: propertyShape.shapeIRI,
                        focusNode: rootFocusNode,
                        pathIRI: pathIRI,
                        valueNode: valueNode,
                        sourceConstraintIRI: SHACLIRIs.reifierShape,
                        message: "reifierShape violation: missing required reifier for value \(valueNode)"
                    )
                )
            }

            if let reifierShapeIRI = propertyShape.reifierShapeIRI {
                for reifierNode in reifierNodes {
                    var reifierVisited: Set<String> = []
                    if !conforms(
                        valueNode: reifierNode,
                        toNodeShapeIRI: reifierShapeIRI,
                        dataGraph: dataGraph,
                        shapesByIRI: shapesByIRI,
                        expressionGraph: expressionGraph,
                        nodeExpressionsByIRI: nodeExpressionsByIRI,
                        depth: 0,
                        visited: &reifierVisited
                    ) {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: rootFocusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.reifierShape,
                                message: "reifierShape violation: reifier does not conform to \(reifierShapeIRI)"
                            )
                        )
                    }
                }
            }
        }

        return violations
    }

    private func findReifierNodes(
        subject: String,
        predicate: String,
        object: String,
        dataGraph: SHACLDataGraph
    ) -> [String] {
        let triplesBySubject = Dictionary(grouping: dataGraph.triples, by: \.subject)
        var matches: [String] = []
        for (candidate, triples) in triplesBySubject {
            let hasSubject = triples.contains { $0.predicate == SHACLIRIs.rdfSubject && $0.object == subject }
            let hasPredicate = triples.contains { $0.predicate == SHACLIRIs.rdfPredicate && $0.object == predicate }
            let hasObject = triples.contains { $0.predicate == SHACLIRIs.rdfObject && $0.object == object }
            if hasSubject && hasPredicate && hasObject {
                matches.append(candidate)
            }
        }
        return matches.sorted()
    }

    private func resolvePropertyPathValues(
        _ path: SHACLPropertyPath,
        from focusNode: String,
        dataGraph: SHACLDataGraph
    ) -> Set<String> {
        evaluatePropertyPathValues(path, from: focusNode, dataGraph: dataGraph)
    }

    private func conforms(
        valueNode: String,
        toNodeShapeIRI shapeIRI: String,
        dataGraph: SHACLDataGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        expressionGraph: SHACLShapesGraph,
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition] = [:],
        depth: Int,
        visited: inout Set<String>
    ) -> Bool {
        conforms(
            valueNode: valueNode,
            toShapeIRI: shapeIRI,
            dataGraph: dataGraph,
            shapesByIRI: shapesByIRI,
            expressionGraph: expressionGraph,
            nodeExpressionsByIRI: nodeExpressionsByIRI,
            depth: depth,
            visited: &visited
        )
    }

    private func conforms(
        valueNode: String,
        toShapeIRI shapeIRI: String,
        dataGraph: SHACLDataGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        expressionGraph: SHACLShapesGraph,
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition] = [:],
        depth: Int,
        visited: inout Set<String>
    ) -> Bool {
        guard let shape = shapesByIRI[shapeIRI] else {
            return false
        }

        let key = "\(shape.shapeIRI)|\(valueNode)"
        if visited.contains(key) {
            return true
        }

        visited.insert(key)
        defer { visited.remove(key) }

        let nestedViolations: [SHACLViolation]
        switch shape.kind {
        case .nodeShape:
            nestedViolations = evaluate(
                nodeShape: shape,
                focusNode: valueNode,
                dataGraph: dataGraph,
                shapesByIRI: shapesByIRI,
                expressionGraph: expressionGraph,
                nodeExpressionsByIRI: nodeExpressionsByIRI,
                depth: depth + 1,
                visited: &visited
            )
        case .propertyShape:
            let wrapper = SHACLShapeDefinition(
                shapeIRI: "\(shape.shapeIRI)#rule-condition-wrapper",
                kind: .nodeShape,
                targets: [],
                propertyShapeIRIs: [shape.shapeIRI]
            )
            nestedViolations = evaluate(
                nodeShape: wrapper,
                focusNode: valueNode,
                dataGraph: dataGraph,
                shapesByIRI: shapesByIRI,
                expressionGraph: expressionGraph,
                nodeExpressionsByIRI: nodeExpressionsByIRI,
                depth: depth + 1,
                visited: &visited
            )
        }
        return nestedViolations.isEmpty
    }

    private func matchesNodeKind(_ value: String, nodeKind: SHACLNodeKindConstraint) -> Bool {
        let isLiteral = parseNumericValue(value) != nil || value.hasPrefix("\"")
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

    private enum SHACLRangeComparable {
        case number(Double, isInteger: Bool)
        case dateTime(Date, hasTimezone: Bool)
    }

    private func inferredDatatypeIRI(for value: String) -> String? {
        if let numeric = parseNumericValue(value) {
            return numeric.isInteger ? SHACLIRIs.xsdInteger : SHACLIRIs.xsdDecimal
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
        if value.hasPrefix("\"\"\"") {
            let start = value.index(value.startIndex, offsetBy: 3)
            guard let closing = value.range(of: "\"\"\"", range: start..<value.endIndex)?.lowerBound else {
                return nil
            }
            return String(value[start..<closing])
        }
        guard value.hasPrefix("\"") else {
            return nil
        }
        guard let closing = value.dropFirst().firstIndex(of: "\"") else {
            return nil
        }
        let start = value.index(after: value.startIndex)
        return String(value[start..<closing])
    }

    private func extractLiteralLanguageTag(_ value: String) -> String? {
        guard value.hasPrefix("\"") else {
            return nil
        }
        guard let closing = value.dropFirst().firstIndex(of: "\"") else {
            return nil
        }
        let next = value.index(after: closing)
        guard next < value.endIndex, value[next] == "@" else {
            return nil
        }
        let start = value.index(after: next)
        let languageTag = String(value[start...]).lowercased()
        return languageTag.isEmpty ? nil : languageTag
    }

    private func containsSingleLineDisallowedBreak(_ lexical: String) -> Bool {
        if lexical.contains("\n")
            || lexical.contains("\r")
            || lexical.contains("\u{000B}")
            || lexical.contains("\u{000C}") {
            return true
        }

        let escapedControlSequences = [
            "\\n", "\\r", "\\f",
            "\\u000A", "\\u000a",
            "\\u000B", "\\u000b",
            "\\u000C", "\\u000c",
            "\\u000D", "\\u000d"
        ]
        return escapedControlSequences.contains { sequence in lexical.contains(sequence) }
    }

    private func rdfListMembersStrictInDataGraph(
        _ term: String,
        triplesBySubject: [String: [SHACLDataTriple]]
    ) -> [String]? {
        if term == SHACLIRIs.rdfNil {
            return []
        }
        guard hasRDFListStructureInDataGraph(term, triplesBySubject: triplesBySubject) else {
            return nil
        }

        var members: [String] = []
        var current = term
        var visited: Set<String> = []
        while current != SHACLIRIs.rdfNil && !visited.contains(current) {
            visited.insert(current)
            guard let triples = triplesBySubject[current],
                  let first = triples.first(where: { $0.predicate == SHACLIRIs.rdfFirst })?.object,
                  let rest = triples.first(where: { $0.predicate == SHACLIRIs.rdfRest })?.object else {
                return nil
            }
            members.append(first)
            current = rest
        }
        return current == SHACLIRIs.rdfNil ? members : nil
    }

    private func matchesLanguageIn(languageTag: String?, ranges: [String]) -> Bool {
        guard let languageTag else {
            return false
        }
        for range in ranges {
            if languageTag == range || languageTag.hasPrefix(range + "-") {
                return true
            }
        }
        return false
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

    private func parseNumericValue(_ value: String) -> (number: Double, isInteger: Bool)? {
        if let direct = Double(value) {
            return (direct, Int(value) != nil)
        }
        guard let lexical = extractLiteralLexicalForm(value), let parsed = Double(lexical) else {
            return nil
        }
        return (parsed, Int(lexical) != nil)
    }

    private func withSPARQLPrefixes(_ query: String, prefixes: [String: String]) -> String {
        if prefixes.isEmpty {
            return query
        }
        let declaredPrefixLabels = declaredSPARQLPrefixLabels(in: query)
        var lines: [String] = []
        for (prefix, namespace) in prefixes.sorted(by: { $0.key < $1.key }) {
            if !declaredPrefixLabels.contains(prefix.lowercased()) {
                lines.append("PREFIX \(prefix): <\(namespace)>")
            }
        }
        if lines.isEmpty {
            return query
        }
        return lines.joined(separator: "\n") + "\n" + query
    }

    private func declaredSPARQLPrefixLabels(in query: String) -> Set<String> {
        guard let regex = try? NSRegularExpression(
            pattern: #"(?im)^\s*prefix\s+([A-Za-z_][A-Za-z0-9_-]*|)\s*:"#,
            options: []
        ) else {
            return []
        }
        let fullRange = NSRange(query.startIndex..<query.endIndex, in: query)
        let matches = regex.matches(in: query, options: [], range: fullRange)
        var labels: Set<String> = []
        labels.reserveCapacity(matches.count)
        for match in matches {
            guard let range = Range(match.range(at: 1), in: query) else {
                continue
            }
            labels.insert(String(query[range]).lowercased())
        }
        return labels
    }

    private func compareRangeValueTerm(_ valueTerm: String, toBoundTerm boundTerm: String) -> ComparisonResult? {
        guard let valueComparable = parseRangeComparable(valueTerm),
              let boundComparable = parseRangeComparable(boundTerm) else {
            return nil
        }

        switch (valueComparable, boundComparable) {
        case (.number(let value, _), .number(let bound, _)):
            if value < bound {
                return .orderedAscending
            }
            if value > bound {
                return .orderedDescending
            }
            return .orderedSame
        case (.dateTime(let valueDate, let valueHasTimezone), .dateTime(let boundDate, let boundHasTimezone)):
            guard valueHasTimezone == boundHasTimezone else {
                return nil
            }
            return valueDate.compare(boundDate)
        default:
            return nil
        }
    }

    private func rangeTypeViolationMessage(valueTerm: String, boundTerm: String) -> String {
        if case .number(_, let isInteger)? = parseRangeComparable(boundTerm), isInteger {
            return "range violation: value \(valueTerm) is not an integer literal"
        }
        if case .number = parseRangeComparable(boundTerm) {
            return "range violation: value \(valueTerm) is not a numeric literal"
        }
        if case .dateTime = parseRangeComparable(boundTerm) {
            return "range violation: value \(valueTerm) is not comparable to xsd:dateTime boundary"
        }
        return "range violation: value \(valueTerm) is not comparable to boundary \(boundTerm)"
    }

    private func parseRangeComparable(_ term: String) -> SHACLRangeComparable? {
        if let numeric = parseNumericValue(term) {
            return .number(numeric.number, isInteger: numeric.isInteger)
        }

        guard inferredDatatypeIRI(for: term) == SHACLIRIs.xsdDateTime,
              let lexical = extractLiteralLexicalForm(term),
              let parsedDate = parseDateTimeLexicalForm(lexical) else {
            return nil
        }
        return .dateTime(parsedDate.date, hasTimezone: parsedDate.hasTimezone)
    }

    private func parseDateTimeLexicalForm(_ lexical: String) -> (date: Date, hasTimezone: Bool)? {
        let hasTimezone = lexical.hasSuffix("Z")
            || lexical.range(of: #"[+-]\d{2}:\d{2}$"#, options: .regularExpression) != nil

        if hasTimezone {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let parsed = formatter.date(from: lexical) {
                return (parsed, true)
            }
            formatter.formatOptions = [.withInternetDateTime]
            if let parsed = formatter.date(from: lexical) {
                return (parsed, true)
            }
            return nil
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let parsed = formatter.date(from: lexical) else {
            return nil
        }
        return (parsed, false)
    }

    private func isLexicallyValidLiteral(_ valueNode: String, forDatatypeIRI datatypeIRI: String) -> Bool {
        if let numeric = parseNumericValue(valueNode) {
            switch datatypeIRI {
            case SHACLIRIs.xsdInteger:
                return numeric.isInteger
            case SHACLIRIs.xsdDecimal:
                return true
            case SHACLIRIs.xsdByte:
                guard numeric.isInteger else {
                    return false
                }
                let intValue = Int(numeric.number)
                return (-128...127).contains(intValue)
            default:
                break
            }
        }

        guard let lexical = extractLiteralLexicalForm(valueNode) else {
            return false
        }

        switch datatypeIRI {
        case SHACLIRIs.xsdInteger:
            return Int(lexical) != nil
        case SHACLIRIs.xsdDecimal:
            return lexical.range(of: #"^-?\d+(\.\d+)?$"#, options: .regularExpression) != nil
        case SHACLIRIs.xsdBoolean:
            return lexical == "true" || lexical == "false" || lexical == "1" || lexical == "0"
        case SHACLIRIs.xsdDateTime:
            return parseDateTimeLexicalForm(lexical) != nil
        case SHACLIRIs.xsdByte:
            guard let parsed = Int(lexical) else {
                return false
            }
            return (-128...127).contains(parsed)
        default:
            return true
        }
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
    static let rdfsClass = "http://www.w3.org/2000/01/rdf-schema#Class"
    static let rdfsSubClassOf = "http://www.w3.org/2000/01/rdf-schema#subClassOf"
    static let rdfFirst = "http://www.w3.org/1999/02/22-rdf-syntax-ns#first"
    static let rdfRest = "http://www.w3.org/1999/02/22-rdf-syntax-ns#rest"
    static let rdfNil = "http://www.w3.org/1999/02/22-rdf-syntax-ns#nil"
    static let rdfSubject = "http://www.w3.org/1999/02/22-rdf-syntax-ns#subject"
    static let rdfPredicate = "http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate"
    static let rdfObject = "http://www.w3.org/1999/02/22-rdf-syntax-ns#object"
    static let nodeShape = "http://www.w3.org/ns/shacl#NodeShape"
    static let propertyShape = "http://www.w3.org/ns/shacl#PropertyShape"
    static let shapeClass = "http://www.w3.org/ns/shacl#ShapeClass"
    static let targetClass = "http://www.w3.org/ns/shacl#targetClass"
    static let targetNode = "http://www.w3.org/ns/shacl#targetNode"
    static let targetSubjectsOf = "http://www.w3.org/ns/shacl#targetSubjectsOf"
    static let targetObjectsOf = "http://www.w3.org/ns/shacl#targetObjectsOf"
    static let targetWhere = "http://www.w3.org/ns/shacl#targetWhere"
    static let shape = "http://www.w3.org/ns/shacl#shape"
    static let order = "http://www.w3.org/ns/shacl#order"
    static let deactivated = "http://www.w3.org/ns/shacl#deactivated"
    static let severity = "http://www.w3.org/ns/shacl#severity"
    static let property = "http://www.w3.org/ns/shacl#property"
    static let path = "http://www.w3.org/ns/shacl#path"
    static let inversePath = "http://www.w3.org/ns/shacl#inversePath"
    static let alternativePath = "http://www.w3.org/ns/shacl#alternativePath"
    static let zeroOrMorePath = "http://www.w3.org/ns/shacl#zeroOrMorePath"
    static let oneOrMorePath = "http://www.w3.org/ns/shacl#oneOrMorePath"
    static let zeroOrOnePath = "http://www.w3.org/ns/shacl#zeroOrOnePath"
    static let `class` = "http://www.w3.org/ns/shacl#class"
    static let nodeKind = "http://www.w3.org/ns/shacl#nodeKind"
    static let datatype = "http://www.w3.org/ns/shacl#datatype"
    static let minLength = "http://www.w3.org/ns/shacl#minLength"
    static let maxLength = "http://www.w3.org/ns/shacl#maxLength"
    static let singleLine = "http://www.w3.org/ns/shacl#singleLine"
    static let minListLength = "http://www.w3.org/ns/shacl#minListLength"
    static let maxListLength = "http://www.w3.org/ns/shacl#maxListLength"
    static let minInclusive = "http://www.w3.org/ns/shacl#minInclusive"
    static let maxInclusive = "http://www.w3.org/ns/shacl#maxInclusive"
    static let minExclusive = "http://www.w3.org/ns/shacl#minExclusive"
    static let maxExclusive = "http://www.w3.org/ns/shacl#maxExclusive"
    static let pattern = "http://www.w3.org/ns/shacl#pattern"
    static let hasValue = "http://www.w3.org/ns/shacl#hasValue"
    static let `in` = "http://www.w3.org/ns/shacl#in"
    static let languageIn = "http://www.w3.org/ns/shacl#languageIn"
    static let uniqueLang = "http://www.w3.org/ns/shacl#uniqueLang"
    static let uniqueMembers = "http://www.w3.org/ns/shacl#uniqueMembers"
    static let equals = "http://www.w3.org/ns/shacl#equals"
    static let disjoint = "http://www.w3.org/ns/shacl#disjoint"
    static let lessThan = "http://www.w3.org/ns/shacl#lessThan"
    static let lessThanOrEquals = "http://www.w3.org/ns/shacl#lessThanOrEquals"
    static let closed = "http://www.w3.org/ns/shacl#closed"
    static let ignoredProperties = "http://www.w3.org/ns/shacl#ignoredProperties"
    static let node = "http://www.w3.org/ns/shacl#node"
    static let nodeByExpression = "http://www.w3.org/ns/shacl#nodeByExpression"
    static let and = "http://www.w3.org/ns/shacl#and"
    static let or = "http://www.w3.org/ns/shacl#or"
    static let not = "http://www.w3.org/ns/shacl#not"
    static let xone = "http://www.w3.org/ns/shacl#xone"
    static let reifierShape = "http://www.w3.org/ns/shacl#reifierShape"
    static let reificationRequired = "http://www.w3.org/ns/shacl#reificationRequired"
    static let memberShape = "http://www.w3.org/ns/shacl#memberShape"
    static let qualifiedValueShape = "http://www.w3.org/ns/shacl#qualifiedValueShape"
    static let someValue = "http://www.w3.org/ns/shacl#someValue"
    static let qualifiedValueShapesDisjoint = "http://www.w3.org/ns/shacl#qualifiedValueShapesDisjoint"
    static let qualifiedMinCount = "http://www.w3.org/ns/shacl#qualifiedMinCount"
    static let qualifiedMaxCount = "http://www.w3.org/ns/shacl#qualifiedMaxCount"
    static let rule = "http://www.w3.org/ns/shacl#rule"
    static let tripleRule = "http://www.w3.org/ns/shacl#TripleRule"
    static let condition = "http://www.w3.org/ns/shacl#condition"
    static let subject = "http://www.w3.org/ns/shacl#subject"
    static let predicate = "http://www.w3.org/ns/shacl#predicate"
    static let object = "http://www.w3.org/ns/shacl#object"
    static let sparql = "http://www.w3.org/ns/shacl#sparql"
    static let select = "http://www.w3.org/ns/shacl#select"
    static let ask = "http://www.w3.org/ns/shacl#ask"
    static let message = "http://www.w3.org/ns/shacl#message"
    static let prefixes = "http://www.w3.org/ns/shacl#prefixes"
    static let declare = "http://www.w3.org/ns/shacl#declare"
    static let prefix = "http://www.w3.org/ns/shacl#prefix"
    static let namespace = "http://www.w3.org/ns/shacl#namespace"
    static let target = "http://www.w3.org/ns/shacl#target"
    static let expression = "http://www.w3.org/ns/shacl#expression"
    static let union = "http://www.w3.org/ns/shacl#union"
    static let intersection = "http://www.w3.org/ns/shacl#intersection"
    static let shThis = "http://www.w3.org/ns/shacl#this"
    static let shnexNodes = "http://www.w3.org/ns/shacl-node-expr#nodes"
    static let shnexExists = "http://www.w3.org/ns/shacl-node-expr#exists"
    static let shnexCount = "http://www.w3.org/ns/shacl-node-expr#count"
    static let shnexVar = "http://www.w3.org/ns/shacl-node-expr#var"
    static let shnexDistinct = "http://www.w3.org/ns/shacl-node-expr#distinct"
    static let shnexMatchAll = "http://www.w3.org/ns/shacl-node-expr#matchAll"
    static let shnexFilterShape = "http://www.w3.org/ns/shacl-node-expr#filterShape"
    static let shnexInstancesOf = "http://www.w3.org/ns/shacl-node-expr#instancesOf"
    static let shnexNodesMatching = "http://www.w3.org/ns/shacl-node-expr#nodesMatching"
    static let shnexMin = "http://www.w3.org/ns/shacl-node-expr#min"
    static let shnexMax = "http://www.w3.org/ns/shacl-node-expr#max"
    static let shnexSum = "http://www.w3.org/ns/shacl-node-expr#sum"
    static let shnexIf = "http://www.w3.org/ns/shacl-node-expr#if"
    static let shnexThen = "http://www.w3.org/ns/shacl-node-expr#then"
    static let shnexElse = "http://www.w3.org/ns/shacl-node-expr#else"
    static let shnexPathValues = "http://www.w3.org/ns/shacl-node-expr#pathValues"
    static let shnexFocusNode = "http://www.w3.org/ns/shacl-node-expr#focusNode"
    static let shnexConcat = "http://www.w3.org/ns/shacl-node-expr#concat"
    static let shnexRemove = "http://www.w3.org/ns/shacl-node-expr#remove"
    static let shnexFlatMap = "http://www.w3.org/ns/shacl-node-expr#flatMap"
    static let shnexLimit = "http://www.w3.org/ns/shacl-node-expr#limit"
    static let shnexOffset = "http://www.w3.org/ns/shacl-node-expr#offset"
    static let shnexFindFirst = "http://www.w3.org/ns/shacl-node-expr#findFirst"
    static let shnexOrderBy = "http://www.w3.org/ns/shacl-node-expr#orderBy"
    static let shnexDesc = "http://www.w3.org/ns/shacl-node-expr#desc"
    static let shnexUnion = "http://www.w3.org/ns/shacl-node-expr#union"
    static let shnexIntersection = "http://www.w3.org/ns/shacl-node-expr#intersection"
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
    static let xsdDecimal = "http://www.w3.org/2001/XMLSchema#decimal"
    static let xsdBoolean = "http://www.w3.org/2001/XMLSchema#boolean"
    static let xsdString = "http://www.w3.org/2001/XMLSchema#string"
    static let xsdDateTime = "http://www.w3.org/2001/XMLSchema#dateTime"
    static let xsdByte = "http://www.w3.org/2001/XMLSchema#byte"
    static let rdfLangString = "http://www.w3.org/1999/02/22-rdf-syntax-ns#langString"
    static let phaseGatedPredicates: Set<String> = []
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
        var blankNodeCounter = 0

        for statement in statements {
            if statement.isEmpty {
                continue
            }
            triples.append(
                contentsOf: try parseStatement(
                    statement,
                    prefixes: parsed.prefixes,
                    listCounter: &listCounter,
                    blankNodeCounter: &blankNodeCounter
                )
            )
        }

        return triples
    }

    private func extractPrefixesAndBody(from source: String) throws -> (prefixes: [String: String], body: String) {
        var prefixes: [String: String] = [:]
        var bodyLines: [String] = []

        for rawLine in source.split(separator: "\n", omittingEmptySubsequences: false) {
            let withoutComments = stripComments(from: String(rawLine))
            let line = withoutComments.trimmingCharacters(in: .whitespacesAndNewlines)

            if line.isEmpty || line.hasPrefix("#") {
                continue
            }

            if line.hasPrefix("@prefix") || line.hasPrefix("PREFIX ") || line.hasPrefix("prefix ") {
                let parsed = try parsePrefixDeclaration(line)
                prefixes[parsed.prefix] = parsed.iri
            } else {
                bodyLines.append(String(rawLine))
            }
        }

        return (prefixes, bodyLines.joined(separator: "\n"))
    }

    private func parsePrefixDeclaration(_ line: String) throws -> (prefix: String, iri: String) {
        let remainder: String
        let requireTrailingDot: Bool

        if line.hasPrefix("@prefix") {
            remainder = String(line.dropFirst("@prefix".count)).trimmingCharacters(in: .whitespacesAndNewlines)
            requireTrailingDot = true
        } else if line.hasPrefix("PREFIX ") {
            remainder = String(line.dropFirst("PREFIX".count)).trimmingCharacters(in: .whitespacesAndNewlines)
            requireTrailingDot = false
        } else if line.hasPrefix("prefix ") {
            remainder = String(line.dropFirst("prefix".count)).trimmingCharacters(in: .whitespacesAndNewlines)
            requireTrailingDot = false
        } else {
            throw SHACLError.invalidPrefixDeclaration(line)
        }

        guard let spaceIndex = remainder.firstIndex(where: { $0.isWhitespace }) else {
            throw SHACLError.invalidPrefixDeclaration(line)
        }

        let rawPrefixToken = String(remainder[..<spaceIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
        var trailing = String(remainder[spaceIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)

        if requireTrailingDot {
            guard trailing.hasSuffix(".") else {
                throw SHACLError.invalidPrefixDeclaration(line)
            }
            trailing = String(trailing.dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        guard rawPrefixToken.hasSuffix(":") else {
            throw SHACLError.invalidPrefixDeclaration(line)
        }
        let prefixValue = String(rawPrefixToken.dropLast())
        if !prefixValue.isEmpty {
            let validPrefix = prefixValue.range(of: #"^[A-Za-z][A-Za-z0-9_-]*$"#, options: .regularExpression) != nil
            guard validPrefix else {
                throw SHACLError.invalidPrefixDeclaration(line)
            }
        }

        guard trailing.hasPrefix("<"), trailing.hasSuffix(">") else {
            throw SHACLError.invalidPrefixDeclaration(line)
        }
        let iri = String(trailing.dropFirst().dropLast())
        guard !iri.isEmpty else {
            throw SHACLError.invalidPrefixDeclaration(line)
        }

        return (prefixValue, iri)
    }

    private func stripComments(from line: String) -> String {
        var result = ""
        var inIRI = false
        var inString = false
        var escaped = false

        for ch in line {
            if ch == "\"" && !inIRI && !escaped {
                inString.toggle()
            } else if ch == "<" && !inString {
                inIRI = true
            } else if ch == ">" && inIRI {
                inIRI = false
            }

            if ch == "#" && !inIRI && !inString {
                break
            }

            result.append(ch)

            if inString && ch == "\\" && !escaped {
                escaped = true
            } else {
                escaped = false
            }
        }

        return result
    }

    private func splitStatements(from body: String) -> [String] {
        var statements: [String] = []
        var current = ""
        var inIRI = false
        var inString = false
        var inLongString = false
        var escaped = false
        let characters = Array(body)
        var position = 0

        while position < characters.count {
            let ch = characters[position]
            let startsLongQuote =
                position + 2 < characters.count
                && characters[position] == "\""
                && characters[position + 1] == "\""
                && characters[position + 2] == "\""

            if startsLongQuote && !inIRI {
                inLongString.toggle()
                current.append("\"\"\"")
                position += 3
                escaped = false
                continue
            }

            if ch == "#" && !inIRI && !inString && !inLongString {
                while position < characters.count, characters[position] != "\n" {
                    position += 1
                }
                continue
            }

            if ch == "<" && !inString && !inLongString {
                inIRI = true
            } else if ch == ">" && inIRI {
                inIRI = false
            } else if ch == "\"" && !escaped && !inLongString {
                inString.toggle()
            }

            if ch == "." && !inIRI && !inString && !inLongString {
                let previousIsDigit = position > 0 && characters[position - 1].isNumber
                let nextIsDigit = position + 1 < characters.count && characters[position + 1].isNumber
                if previousIsDigit && nextIsDigit {
                    current.append(ch)
                    position += 1
                    continue
                }
                let trimmed = current.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    statements.append(trimmed)
                }
                current = ""
            } else {
                current.append(ch)
            }

            if inString && ch == "\\" && !escaped {
                escaped = true
            } else {
                escaped = false
            }
            position += 1
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
        listCounter: inout Int,
        blankNodeCounter: inout Int
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

        func parseObjectWithOptionalReifier(
            subject: String,
            predicate: String
        ) throws -> String {
            let object = try parseTerm(
                tokens: tokens,
                index: &index,
                prefixes: prefixes,
                triples: &triples,
                listCounter: &listCounter,
                blankNodeCounter: &blankNodeCounter,
                statement: statement
            )
            if index < tokens.count, tokens[index] == "{|" {
                _ = takeToken()
                blankNodeCounter += 1
                let reifierNode = "_:shacl_reifier_\(blankNodeCounter)"
                triples.append(SHACLTriple(subject: reifierNode, predicate: SHACLIRIs.rdfSubject, object: subject))
                triples.append(SHACLTriple(subject: reifierNode, predicate: SHACLIRIs.rdfPredicate, object: predicate))
                triples.append(SHACLTriple(subject: reifierNode, predicate: SHACLIRIs.rdfObject, object: object))

                while index < tokens.count {
                    if tokens[index] == "|}" {
                        _ = takeToken()
                        break
                    }
                    guard let annotationPredicateToken = takeToken() else {
                        throw SHACLError.invalidStatement(statement)
                    }
                    let annotationPredicate = try resolveTerm(annotationPredicateToken, prefixes: prefixes)
                    var annotationObjects: [String] = [
                        try parseTerm(
                            tokens: tokens,
                            index: &index,
                            prefixes: prefixes,
                            triples: &triples,
                            listCounter: &listCounter,
                            blankNodeCounter: &blankNodeCounter,
                            statement: statement
                        )
                    ]
                    while index < tokens.count, tokens[index] == "," {
                        _ = takeToken()
                        annotationObjects.append(
                            try parseTerm(
                                tokens: tokens,
                                index: &index,
                                prefixes: prefixes,
                                triples: &triples,
                                listCounter: &listCounter,
                                blankNodeCounter: &blankNodeCounter,
                                statement: statement
                            )
                        )
                    }
                    for annotationObject in annotationObjects {
                        triples.append(SHACLTriple(subject: reifierNode, predicate: annotationPredicate, object: annotationObject))
                    }
                    if index < tokens.count, tokens[index] == ";" {
                        _ = takeToken()
                    }
                }
            }
            return object
        }

        var triples: [SHACLTriple] = []
        let subject = try parseTerm(
            tokens: tokens,
            index: &index,
            prefixes: prefixes,
            triples: &triples,
            listCounter: &listCounter,
            blankNodeCounter: &blankNodeCounter,
            statement: statement
        )

        while index < tokens.count {
            guard let predicateToken = takeToken() else {
                throw SHACLError.invalidStatement(statement)
            }

            if predicateToken == ";" {
                continue
            }

            let predicate = try resolveTerm(predicateToken, prefixes: prefixes)

            var objects: [String] = [
                try parseObjectWithOptionalReifier(subject: subject, predicate: predicate)
            ]

            while index < tokens.count, tokens[index] == "," {
                _ = takeToken()
                objects.append(
                    try parseObjectWithOptionalReifier(subject: subject, predicate: predicate)
                )
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
        blankNodeCounter: inout Int,
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
            if token == ";" || token == "," {
                throw SHACLError.invalidStatement(statement)
            }
            values.append(
                try parseTerm(
                    tokens: tokens,
                    index: &index,
                    prefixes: prefixes,
                    triples: &triples,
                    listCounter: &listCounter,
                    blankNodeCounter: &blankNodeCounter,
                    statement: statement
                )
            )
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

    private func parseBlankNodePropertyList(
        tokens: [String],
        index: inout Int,
        prefixes: [String: String],
        triples: inout [SHACLTriple],
        listCounter: inout Int,
        blankNodeCounter: inout Int,
        statement: String
    ) throws -> String {
        func nextBlankNode() -> String {
            defer { blankNodeCounter += 1 }
            return "_:BNode\(blankNodeCounter)"
        }

        let blankNode = nextBlankNode()

        while index < tokens.count {
            let token = tokens[index]
            if token == "]" {
                index += 1
                return blankNode
            }
            if token == ";" {
                index += 1
                continue
            }
            if token == "," || token == ")" {
                throw SHACLError.invalidStatement(statement)
            }

            let predicateToken = token
            index += 1
            let predicate = try resolveTerm(predicateToken, prefixes: prefixes)

            var objects: [String] = [
                try parseTerm(
                    tokens: tokens,
                    index: &index,
                    prefixes: prefixes,
                    triples: &triples,
                    listCounter: &listCounter,
                    blankNodeCounter: &blankNodeCounter,
                    statement: statement
                )
            ]

            while index < tokens.count, tokens[index] == "," {
                index += 1
                objects.append(
                    try parseTerm(
                        tokens: tokens,
                        index: &index,
                        prefixes: prefixes,
                        triples: &triples,
                        listCounter: &listCounter,
                        blankNodeCounter: &blankNodeCounter,
                        statement: statement
                    )
                )
            }

            for object in objects {
                triples.append(SHACLTriple(subject: blankNode, predicate: predicate, object: object))
            }

            if index < tokens.count, tokens[index] == ";" {
                index += 1
            }
        }

        throw SHACLError.invalidStatement(statement)
    }

    private func parseTerm(
        tokens: [String],
        index: inout Int,
        prefixes: [String: String],
        triples: inout [SHACLTriple],
        listCounter: inout Int,
        blankNodeCounter: inout Int,
        statement: String
    ) throws -> String {
        guard index < tokens.count else {
            throw SHACLError.invalidStatement(statement)
        }

        let token = tokens[index]
        if token == ";" || token == "," || token == ")" || token == "]" || token == "{|" || token == "|}" {
            throw SHACLError.invalidStatement(statement)
        }

        if token == "(" {
            index += 1
            return try parseObjectList(
                tokens: tokens,
                index: &index,
                prefixes: prefixes,
                triples: &triples,
                listCounter: &listCounter,
                blankNodeCounter: &blankNodeCounter,
                statement: statement
            )
        }

        if token == "[" {
            index += 1
            return try parseBlankNodePropertyList(
                tokens: tokens,
                index: &index,
                prefixes: prefixes,
                triples: &triples,
                listCounter: &listCounter,
                blankNodeCounter: &blankNodeCounter,
                statement: statement
            )
        }

        index += 1
        return try resolveTerm(token, prefixes: prefixes)
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

            if ch == "{",
               statement.index(after: index) < statement.endIndex,
               statement[statement.index(after: index)] == "|" {
                tokens.append("{|")
                index = statement.index(index, offsetBy: 2)
                continue
            }

            if ch == "|",
               statement.index(after: index) < statement.endIndex,
               statement[statement.index(after: index)] == "}" {
                tokens.append("|}")
                index = statement.index(index, offsetBy: 2)
                continue
            }

            if ch == ";" || ch == "," || ch == "(" || ch == ")" || ch == "[" || ch == "]" {
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
                let next = statement.index(after: index)
                let isLongLiteral = next < statement.endIndex
                    && statement[next] == "\""
                    && statement.index(after: next) < statement.endIndex
                    && statement[statement.index(after: next)] == "\""

                var end: String.Index
                if isLongLiteral {
                    end = statement.index(index, offsetBy: 3)
                    while end < statement.endIndex {
                        if statement[end] == "\"",
                           statement.index(after: end) < statement.endIndex,
                           statement[statement.index(after: end)] == "\"",
                           statement.index(end, offsetBy: 2) < statement.endIndex,
                           statement[statement.index(end, offsetBy: 2)] == "\"" {
                            end = statement.index(end, offsetBy: 2)
                            break
                        }
                        end = statement.index(after: end)
                    }
                } else {
                    end = statement.index(after: index)
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
                          statement[langEnd] != ",",
                          statement[langEnd] != ")",
                          statement[langEnd] != "]" {
                        langEnd = statement.index(after: langEnd)
                    }
                    token += String(statement[langStart..<langEnd])
                    probe = langEnd
                } else if probe < statement.endIndex, statement[probe] == "^" {
                    let typedNext = statement.index(after: probe)
                    guard typedNext < statement.endIndex, statement[typedNext] == "^" else {
                        throw SHACLError.invalidStatement(statement)
                    }
                    probe = statement.index(after: typedNext)
                    var dtEnd = probe
                    while dtEnd < statement.endIndex,
                          !statement[dtEnd].isWhitespace,
                          statement[dtEnd] != ";",
                          statement[dtEnd] != ",",
                          statement[dtEnd] != ")",
                          statement[dtEnd] != "]" {
                        dtEnd = statement.index(after: dtEnd)
                    }
                    token += "^^" + String(statement[probe..<dtEnd])
                    probe = dtEnd
                }

                tokens.append(token)
                index = probe
                continue
            }

            if ch == "'" {
                var end = statement.index(after: index)
                var escaped = false
                while end < statement.endIndex {
                    let c = statement[end]
                    if c == "\\" && !escaped {
                        escaped = true
                        end = statement.index(after: end)
                        continue
                    }
                    if c == "'" && !escaped {
                        break
                    }
                    escaped = false
                    end = statement.index(after: end)
                }

                guard end < statement.endIndex else {
                    throw SHACLError.invalidStatement(statement)
                }

                let rawLexical = String(statement[statement.index(after: index)..<end])
                let unescapedLexical = rawLexical
                    .replacingOccurrences(of: "\\'", with: "'")
                    .replacingOccurrences(of: "\\\\", with: "\\")
                let escapedLexical = unescapedLexical.replacingOccurrences(of: "\"", with: "\\\"")
                var token = "\"\(escapedLexical)\""
                var probe = statement.index(after: end)

                if probe < statement.endIndex, statement[probe] == "@" {
                    let langStart = probe
                    probe = statement.index(after: probe)
                    var langEnd = probe
                    while langEnd < statement.endIndex,
                          !statement[langEnd].isWhitespace,
                          statement[langEnd] != ";",
                          statement[langEnd] != ",",
                          statement[langEnd] != ")",
                          statement[langEnd] != "]" {
                        langEnd = statement.index(after: langEnd)
                    }
                    token += String(statement[langStart..<langEnd])
                    probe = langEnd
                } else if probe < statement.endIndex, statement[probe] == "^" {
                    let typedNext = statement.index(after: probe)
                    guard typedNext < statement.endIndex, statement[typedNext] == "^" else {
                        throw SHACLError.invalidStatement(statement)
                    }
                    probe = statement.index(after: typedNext)
                    var dtEnd = probe
                    while dtEnd < statement.endIndex,
                          !statement[dtEnd].isWhitespace,
                          statement[dtEnd] != ";",
                          statement[dtEnd] != ",",
                          statement[dtEnd] != ")",
                          statement[dtEnd] != "]" {
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
                  statement[end] != ",",
                  statement[end] != "(",
                  statement[end] != ")",
                  statement[end] != "[",
                  statement[end] != "]",
                  statement[end] != "{",
                  statement[end] != "|" {
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

        if isNumericToken(token) {
            return token
        }

        if token == "true" || token == "false" {
            return "\"\(token)\"^^\(SHACLIRIs.xsdBoolean)"
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

    private func isNumericToken(_ token: String) -> Bool {
        token.range(of: #"^-?\d+(\.\d+)?$"#, options: .regularExpression) != nil
    }
}
