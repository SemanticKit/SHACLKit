import Foundation

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
