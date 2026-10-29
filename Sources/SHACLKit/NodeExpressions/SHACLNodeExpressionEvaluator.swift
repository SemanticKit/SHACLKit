import Foundation

public struct SHACLNodeExpressionEvaluator: Sendable {
    let maxDepth = 16

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
}
