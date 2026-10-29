import Foundation

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
