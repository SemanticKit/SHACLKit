import Foundation

extension SHACLCoreValidator {
    func evaluateQualifiedValueConstraints(
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
}
