import Foundation

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
