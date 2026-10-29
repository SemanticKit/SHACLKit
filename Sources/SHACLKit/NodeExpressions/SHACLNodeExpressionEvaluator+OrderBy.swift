import Foundation

extension SHACLNodeExpressionEvaluator {
    func sortOrderByNodes(
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
