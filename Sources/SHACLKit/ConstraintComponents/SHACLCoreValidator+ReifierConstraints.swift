import Foundation

extension SHACLCoreValidator {
    func evaluateDeferredReifierExtensionsForPropertyShape(
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
}
