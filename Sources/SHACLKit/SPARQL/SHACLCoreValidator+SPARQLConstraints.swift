import Foundation

extension SHACLCoreValidator {
    func evaluateSPARQLConstraints(
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

    func withSPARQLPrefixes(_ query: String, prefixes: [String: String]) -> String {
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
}
