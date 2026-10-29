import Foundation

extension SHACLCoreValidator {
    func evaluateDeferredMemberShapeConstraints(
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

    func evaluateDeferredMemberShapeForPropertyShape(
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
}
