import Foundation

extension SHACLCoreValidator {
    func evaluateNodeLogicalConstraints(
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
}
