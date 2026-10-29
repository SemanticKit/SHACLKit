import Foundation

extension SHACLCoreValidator {
    func evaluate(
        nodeShape: SHACLShapeDefinition,
        focusNode: String,
        dataGraph: SHACLDataGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        expressionGraph: SHACLShapesGraph,
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition] = [:],
        depth: Int,
        visited: inout Set<String>
    ) -> [SHACLViolation] {
        var violations: [SHACLViolation] = []
        if depth > maxReferenceDepth {
            return violations
        }
        if nodeShape.isDeactivated {
            return violations
        }
        let nodeSeverity = nodeShape.severity ?? .violation

        if let classIRI = nodeShape.classIRI {
            let hasRequiredType = nodeSatisfiesClassConstraint(
                focusNode,
                classIRI: classIRI,
                dataGraph: dataGraph
            )
            if !hasRequiredType {
                violations.append(
                    SHACLViolation(
                        severity: nodeSeverity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: focusNode,
                        sourceConstraintIRI: SHACLIRIs.class,
                        message: "class violation: focus node \(focusNode) is not typed as \(classIRI)"
                    )
                )
            }
        }

        if let nodeKind = nodeShape.nodeKind, !matchesNodeKind(focusNode, nodeKind: nodeKind) {
            violations.append(
                SHACLViolation(
                    severity: nodeSeverity,
                    shapeIRI: nodeShape.shapeIRI,
                    focusNode: focusNode,
                    pathIRI: nil,
                    valueNode: focusNode,
                    sourceConstraintIRI: SHACLIRIs.nodeKind,
                    message: "nodeKind violation: focus node \(focusNode) does not satisfy \(nodeKind.rawValue)"
                )
            )
        }

            if let datatypeIRI = nodeShape.datatypeIRI {
                let actualDatatype = inferredDatatypeIRI(for: focusNode)
                if actualDatatype != datatypeIRI || !isLexicallyValidLiteral(focusNode, forDatatypeIRI: datatypeIRI) {
                    let actualText = actualDatatype ?? "none"
                    violations.append(
                        SHACLViolation(
                        severity: nodeSeverity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: focusNode,
                        sourceConstraintIRI: SHACLIRIs.datatype,
                        message: "datatype violation: value \(focusNode) has datatype \(actualText), expected \(datatypeIRI)"
                    )
                )
            }
        }

        if nodeShape.minLength != nil || nodeShape.maxLength != nil || nodeShape.pattern != nil {
            if let lexical = extractLiteralLexicalForm(focusNode) {
                if let minLength = nodeShape.minLength, lexical.count < minLength {
                    violations.append(
                        SHACLViolation(
                            severity: nodeSeverity,
                            shapeIRI: nodeShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: nil,
                            valueNode: focusNode,
                            sourceConstraintIRI: SHACLIRIs.minLength,
                            message: "minLength violation: expected >= \(minLength), got \(lexical.count)"
                        )
                    )
                }

                if let maxLength = nodeShape.maxLength, lexical.count > maxLength {
                    violations.append(
                        SHACLViolation(
                            severity: nodeSeverity,
                            shapeIRI: nodeShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: nil,
                            valueNode: focusNode,
                            sourceConstraintIRI: SHACLIRIs.maxLength,
                            message: "maxLength violation: expected <= \(maxLength), got \(lexical.count)"
                        )
                    )
                }

                if let pattern = nodeShape.pattern {
                    let range = NSRange(lexical.startIndex..<lexical.endIndex, in: lexical)
                    let regex = try? NSRegularExpression(pattern: pattern)
                    let matches = regex?.firstMatch(in: lexical, options: [], range: range) != nil
                    if !matches {
                        violations.append(
                            SHACLViolation(
                                severity: nodeSeverity,
                                shapeIRI: nodeShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: nil,
                                valueNode: focusNode,
                                sourceConstraintIRI: SHACLIRIs.pattern,
                                message: "pattern violation: value \(lexical) does not match \(pattern)"
                            )
                        )
                    }
                }
            } else {
                violations.append(
                    SHACLViolation(
                        severity: nodeSeverity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: focusNode,
                        sourceConstraintIRI: SHACLIRIs.minLength,
                        message: "string facet violation: value \(focusNode) is not a literal"
                    )
                )
            }
        }

        if nodeShape.minInclusive != nil || nodeShape.maxInclusive != nil || nodeShape.minExclusive != nil || nodeShape.maxExclusive != nil {
            var hasComparableRangeValue = true

            if let minimum = nodeShape.minInclusive {
                if let comparison = compareRangeValueTerm(focusNode, toBoundTerm: minimum) {
                    if comparison == .orderedAscending {
                        violations.append(
                            SHACLViolation(
                                severity: nodeSeverity,
                                shapeIRI: nodeShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: nil,
                                valueNode: focusNode,
                                sourceConstraintIRI: SHACLIRIs.minInclusive,
                                message: "minInclusive violation: expected >= \(minimum), got \(focusNode)"
                            )
                        )
                    }
                } else {
                    violations.append(
                        SHACLViolation(
                            severity: nodeSeverity,
                            shapeIRI: nodeShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: nil,
                            valueNode: focusNode,
                            sourceConstraintIRI: SHACLIRIs.minInclusive,
                            message: rangeTypeViolationMessage(valueTerm: focusNode, boundTerm: minimum)
                        )
                    )
                    hasComparableRangeValue = false
                }
            }

            if hasComparableRangeValue, let maximum = nodeShape.maxInclusive {
                if let comparison = compareRangeValueTerm(focusNode, toBoundTerm: maximum) {
                    if comparison == .orderedDescending {
                        violations.append(
                            SHACLViolation(
                                severity: nodeSeverity,
                                shapeIRI: nodeShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: nil,
                                valueNode: focusNode,
                                sourceConstraintIRI: SHACLIRIs.maxInclusive,
                                message: "maxInclusive violation: expected <= \(maximum), got \(focusNode)"
                            )
                        )
                    }
                } else {
                    violations.append(
                        SHACLViolation(
                            severity: nodeSeverity,
                            shapeIRI: nodeShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: nil,
                            valueNode: focusNode,
                            sourceConstraintIRI: SHACLIRIs.maxInclusive,
                            message: rangeTypeViolationMessage(valueTerm: focusNode, boundTerm: maximum)
                        )
                    )
                    hasComparableRangeValue = false
                }
            }

            if hasComparableRangeValue, let minimum = nodeShape.minExclusive {
                if let comparison = compareRangeValueTerm(focusNode, toBoundTerm: minimum) {
                    if comparison != .orderedDescending {
                        violations.append(
                            SHACLViolation(
                                severity: nodeSeverity,
                                shapeIRI: nodeShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: nil,
                                valueNode: focusNode,
                                sourceConstraintIRI: SHACLIRIs.minExclusive,
                                message: "minExclusive violation: expected > \(minimum), got \(focusNode)"
                            )
                        )
                    }
                } else {
                    violations.append(
                        SHACLViolation(
                            severity: nodeSeverity,
                            shapeIRI: nodeShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: nil,
                            valueNode: focusNode,
                            sourceConstraintIRI: SHACLIRIs.minExclusive,
                            message: rangeTypeViolationMessage(valueTerm: focusNode, boundTerm: minimum)
                        )
                    )
                    hasComparableRangeValue = false
                }
            }

            if hasComparableRangeValue, let maximum = nodeShape.maxExclusive {
                if let comparison = compareRangeValueTerm(focusNode, toBoundTerm: maximum) {
                    if comparison != .orderedAscending {
                        violations.append(
                            SHACLViolation(
                                severity: nodeSeverity,
                                shapeIRI: nodeShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: nil,
                                valueNode: focusNode,
                                sourceConstraintIRI: SHACLIRIs.maxExclusive,
                                message: "maxExclusive violation: expected < \(maximum), got \(focusNode)"
                            )
                        )
                    }
                } else {
                    violations.append(
                        SHACLViolation(
                            severity: nodeSeverity,
                            shapeIRI: nodeShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: nil,
                            valueNode: focusNode,
                            sourceConstraintIRI: SHACLIRIs.maxExclusive,
                            message: rangeTypeViolationMessage(valueTerm: focusNode, boundTerm: maximum)
                        )
                    )
                }
            }
        }

        if let requiredValue = nodeShape.hasValue, focusNode != requiredValue {
            violations.append(
                SHACLViolation(
                    severity: nodeSeverity,
                    shapeIRI: nodeShape.shapeIRI,
                    focusNode: focusNode,
                    pathIRI: nil,
                    valueNode: focusNode,
                    sourceConstraintIRI: SHACLIRIs.hasValue,
                    message: "hasValue violation: required value \(requiredValue) not present"
                )
            )
        }

        if !nodeShape.inValues.isEmpty {
            let allowed = Set(nodeShape.inValues)
            if !allowed.contains(focusNode) {
                violations.append(
                    SHACLViolation(
                        severity: nodeSeverity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: focusNode,
                        sourceConstraintIRI: SHACLIRIs.in,
                        message: "in violation: value \(focusNode) not found in allowed set"
                    )
                )
            }
        }

        if !nodeShape.languageInValues.isEmpty {
            let languageRanges = nodeShape.languageInValues.compactMap { extractLiteralLexicalForm($0)?.lowercased() }
            if !matchesLanguageIn(languageTag: extractLiteralLanguageTag(focusNode), ranges: languageRanges) {
                violations.append(
                    SHACLViolation(
                        severity: nodeSeverity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: focusNode,
                        sourceConstraintIRI: SHACLIRIs.languageIn,
                        message: "languageIn violation: value \(focusNode) language tag not in allowed set"
                    )
                )
            }
        }

        if let equalsIRI = nodeShape.equalsIRI {
            let relatedValues = Set(dataGraph.triples.filter { $0.subject == focusNode && $0.predicate == equalsIRI }.map(\.object))
            let expectedValues: Set<String> = [focusNode]
            let mismatchValues = expectedValues.symmetricDifference(relatedValues).sorted()
            for mismatchValue in mismatchValues {
                violations.append(
                    SHACLViolation(
                        severity: nodeSeverity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: mismatchValue,
                        sourceConstraintIRI: SHACLIRIs.equals,
                        message: "equals violation: value \(mismatchValue) not aligned with predicate \(equalsIRI)"
                    )
                )
            }
        }

        if let disjointIRI = nodeShape.disjointIRI {
            let relatedValues = Set(dataGraph.triples.filter { $0.subject == focusNode && $0.predicate == disjointIRI }.map(\.object))
            if relatedValues.contains(focusNode) {
                violations.append(
                    SHACLViolation(
                        severity: nodeSeverity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: focusNode,
                        sourceConstraintIRI: SHACLIRIs.disjoint,
                        message: "disjoint violation: value \(focusNode) overlaps predicate \(disjointIRI)"
                    )
                )
            }
        }

        if nodeShape.isClosed {
            let allowedPredicates = Set(
                nodeShape.propertyShapeIRIs.compactMap { propertyShapeIRI in
                    shapesByIRI[propertyShapeIRI]?.pathIRI
                }
            )
            let ignoredPredicates = Set(nodeShape.ignoredPropertyIRIs)
            for triple in dataGraph.triples where triple.subject == focusNode {
                if allowedPredicates.contains(triple.predicate) || ignoredPredicates.contains(triple.predicate) {
                    continue
                }
                violations.append(
                    SHACLViolation(
                        severity: nodeSeverity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: triple.predicate,
                        valueNode: triple.object,
                        sourceConstraintIRI: SHACLIRIs.closed,
                        message: "closed violation: predicate \(triple.predicate) is not permitted by closed shape"
                    )
                )
            }
        }

        violations.append(
            contentsOf: evaluateNodeLogicalConstraints(
                nodeShape: nodeShape,
                focusNode: focusNode,
                severity: nodeSeverity,
                dataGraph: dataGraph,
                shapesByIRI: shapesByIRI,
                expressionGraph: expressionGraph,
                nodeExpressionsByIRI: nodeExpressionsByIRI,
                depth: depth,
                visited: &visited
            )
        )

        if let expressionIRI = nodeShape.expressionIRI {
            let outputNodes = SHACLNodeExpressionEvaluator().evaluate(
                expressionIRI: expressionIRI,
                focusNode: focusNode,
                shapesGraph: expressionGraph,
                dataGraph: dataGraph
            )
            if !isTrueOnlyExpressionOutput(outputNodes) {
                violations.append(
                    SHACLViolation(
                        severity: nodeSeverity,
                        shapeIRI: nodeShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: nil,
                        valueNode: focusNode,
                        sourceConstraintIRI: SHACLIRIs.expression,
                        message: "expression violation: expression \(expressionIRI) did not return true for focus node \(focusNode)"
                    )
                )
            }
        }

        if let nodeByExpressionIRI = nodeShape.nodeByExpressionIRI {
            let referencedShapeIRIs = SHACLNodeExpressionEvaluator()
                .evaluate(
                    expressionIRI: nodeByExpressionIRI,
                    focusNode: focusNode,
                    shapesGraph: expressionGraph,
                    dataGraph: dataGraph
                )
                .sorted()
            for referencedShapeIRI in referencedShapeIRIs {
                let doesConform = conforms(
                    valueNode: focusNode,
                    toNodeShapeIRI: referencedShapeIRI,
                    dataGraph: dataGraph,
                    shapesByIRI: shapesByIRI,
                    expressionGraph: expressionGraph,
                    nodeExpressionsByIRI: nodeExpressionsByIRI,
                    depth: depth,
                    visited: &visited
                )
                if !doesConform {
                    violations.append(
                        SHACLViolation(
                            severity: nodeSeverity,
                            shapeIRI: nodeShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: nil,
                            valueNode: focusNode,
                            sourceConstraintIRI: referencedShapeIRI,
                            message: "nodeByExpression violation: focus node \(focusNode) does not conform to \(referencedShapeIRI)"
                        )
                    )
                }
            }
        }

        if let nodeReference = nodeShape.nodeShapeReferenceIRI,
           let referencedShape = shapesByIRI[nodeReference],
           referencedShape.kind == .nodeShape {
            let key = "\(referencedShape.shapeIRI)|\(focusNode)"
            if !visited.contains(key) {
                visited.insert(key)
                let nestedViolations = evaluate(
                    nodeShape: referencedShape,
                    focusNode: focusNode,
                    dataGraph: dataGraph,
                    shapesByIRI: shapesByIRI,
                    expressionGraph: expressionGraph,
                    nodeExpressionsByIRI: nodeExpressionsByIRI,
                    depth: depth + 1,
                    visited: &visited
                )
                visited.remove(key)
                violations.append(contentsOf: nestedViolations)
            }
        }

        for propertyShapeIRI in nodeShape.propertyShapeIRIs {
            guard let propertyShape = shapesByIRI[propertyShapeIRI], propertyShape.kind == .propertyShape else {
                continue
            }
            if propertyShape.isDeactivated {
                continue
            }
            let pathIRI = propertyShape.pathIRI
            let expressionIRI = propertyShape.expressionIRI
            if pathIRI == nil && expressionIRI == nil {
                continue
            }
            let severity = propertyShape.severity ?? nodeShape.severity ?? .violation

            let values: [String]
            if let propertyPath = propertyShape.propertyPath {
                values = resolvePropertyPathValues(
                    propertyPath,
                    from: focusNode,
                    dataGraph: dataGraph
                ).sorted()
            } else if let pathIRI {
                values = dataGraph.triples
                    .filter { $0.subject == focusNode && $0.predicate == pathIRI }
                    .map(\.object)
            } else if let expressionIRI {
                values = SHACLNodeExpressionEvaluator()
                    .evaluate(
                        expressionIRI: expressionIRI,
                        focusNode: focusNode,
                        shapesGraph: expressionGraph,
                        dataGraph: dataGraph
                    )
                    .sorted()
            } else {
                values = []
            }
            let valueCount = values.count

            if let expressionIRI, pathIRI != nil {
                for valueNode in values {
                    let outputNodes = SHACLNodeExpressionEvaluator().evaluate(
                        expressionIRI: expressionIRI,
                        focusNode: valueNode,
                        shapesGraph: expressionGraph,
                        dataGraph: dataGraph
                    )
                    if !isTrueOnlyExpressionOutput(outputNodes) {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.expression,
                                message: "expression violation: expression \(expressionIRI) did not return true for value \(valueNode)"
                            )
                        )
                    }
                }
            }

            if let minCount = propertyShape.minCount, valueCount < minCount {
                violations.append(
                    SHACLViolation(
                        severity: severity,
                        shapeIRI: propertyShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: pathIRI,
                        sourceConstraintIRI: SHACLIRIs.minCount,
                        message: "minCount violation: expected >= \(minCount), got \(valueCount)"
                    )
                )
            }

            if let maxCount = propertyShape.maxCount, valueCount > maxCount {
                violations.append(
                    SHACLViolation(
                        severity: severity,
                        shapeIRI: propertyShape.shapeIRI,
                        focusNode: focusNode,
                        pathIRI: pathIRI,
                        sourceConstraintIRI: SHACLIRIs.maxCount,
                        message: "maxCount violation: expected <= \(maxCount), got \(valueCount)"
                    )
                )
            }

            if let classIRI = propertyShape.classIRI {
                for valueNode in values {
                    let hasRequiredType = nodeSatisfiesClassConstraint(
                        valueNode,
                        classIRI: classIRI,
                        dataGraph: dataGraph
                    )
                    if !hasRequiredType {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.class,
                                message: "class violation: value \(valueNode) is not typed as \(classIRI)"
                            )
                        )
                    }
                }
            }

            if let nodeKind = propertyShape.nodeKind {
                for valueNode in values {
                    if !matchesNodeKind(valueNode, nodeKind: nodeKind) {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.nodeKind,
                                message: "nodeKind violation: value \(valueNode) does not satisfy \(nodeKind.rawValue)"
                            )
                        )
                    }
                }
            }

            if let datatypeIRI = propertyShape.datatypeIRI {
                for valueNode in values {
                    let actualDatatype = inferredDatatypeIRI(for: valueNode)
                    if actualDatatype != datatypeIRI || !isLexicallyValidLiteral(valueNode, forDatatypeIRI: datatypeIRI) {
                        let actualText = actualDatatype ?? "none"
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.datatype,
                                message: "datatype violation: value \(valueNode) has datatype \(actualText), expected \(datatypeIRI)"
                            )
                        )
                    }
                }
            }

            if propertyShape.minLength != nil || propertyShape.maxLength != nil || propertyShape.pattern != nil {
                for valueNode in values {
                    guard let lexical = extractLiteralLexicalForm(valueNode) else {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.minLength,
                                message: "string facet violation: value \(valueNode) is not a literal"
                            )
                        )
                        continue
                    }

                    if let minLength = propertyShape.minLength, lexical.count < minLength {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.minLength,
                                message: "minLength violation: expected >= \(minLength), got \(lexical.count)"
                            )
                        )
                    }

                    if let maxLength = propertyShape.maxLength, lexical.count > maxLength {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.maxLength,
                                message: "maxLength violation: expected <= \(maxLength), got \(lexical.count)"
                            )
                        )
                    }

                    if let pattern = propertyShape.pattern {
                        let range = NSRange(lexical.startIndex..<lexical.endIndex, in: lexical)
                        let regex = try? NSRegularExpression(pattern: pattern)
                        let matches = regex?.firstMatch(in: lexical, options: [], range: range) != nil
                        if !matches {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.pattern,
                                    message: "pattern violation: value \(lexical) does not match \(pattern)"
                                )
                            )
                        }
                    }
                }
            }

            if propertyShape.singleLine {
                for valueNode in values {
                    guard let lexical = extractLiteralLexicalForm(valueNode) else {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.singleLine,
                                message: "singleLine violation: value \(valueNode) is not a literal"
                            )
                        )
                        continue
                    }

                    if containsSingleLineDisallowedBreak(lexical) {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.singleLine,
                                message: "singleLine violation: value \(valueNode) contains line breaks"
                            )
                        )
                    }
                }
            }

            if propertyShape.minInclusive != nil
                || propertyShape.maxInclusive != nil
                || propertyShape.minExclusive != nil
                || propertyShape.maxExclusive != nil {
                for valueNode in values {
                    if let minimum = propertyShape.minInclusive {
                        guard let comparison = compareRangeValueTerm(valueNode, toBoundTerm: minimum) else {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.minInclusive,
                                    message: rangeTypeViolationMessage(valueTerm: valueNode, boundTerm: minimum)
                                )
                            )
                            continue
                        }

                        if comparison == .orderedAscending {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.minInclusive,
                                    message: "minInclusive violation: expected >= \(minimum), got \(valueNode)"
                                )
                            )
                        }
                    }

                    if let maximum = propertyShape.maxInclusive {
                        guard let comparison = compareRangeValueTerm(valueNode, toBoundTerm: maximum) else {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.maxInclusive,
                                    message: rangeTypeViolationMessage(valueTerm: valueNode, boundTerm: maximum)
                                )
                            )
                            continue
                        }

                        if comparison == .orderedDescending {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.maxInclusive,
                                    message: "maxInclusive violation: expected <= \(maximum), got \(valueNode)"
                                )
                            )
                        }
                    }

                    if let minimum = propertyShape.minExclusive {
                        guard let comparison = compareRangeValueTerm(valueNode, toBoundTerm: minimum) else {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.minExclusive,
                                    message: rangeTypeViolationMessage(valueTerm: valueNode, boundTerm: minimum)
                                )
                            )
                            continue
                        }
                        if comparison != .orderedDescending {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.minExclusive,
                                    message: "minExclusive violation: expected > \(minimum), got \(valueNode)"
                                )
                            )
                        }
                    }

                    if let maximum = propertyShape.maxExclusive {
                        guard let comparison = compareRangeValueTerm(valueNode, toBoundTerm: maximum) else {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.maxExclusive,
                                    message: rangeTypeViolationMessage(valueTerm: valueNode, boundTerm: maximum)
                                )
                            )
                            continue
                        }
                        if comparison != .orderedAscending {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.maxExclusive,
                                    message: "maxExclusive violation: expected < \(maximum), got \(valueNode)"
                                )
                            )
                        }
                    }
                }
            }

            if let requiredValue = propertyShape.hasValue {
                let hasRequiredValue = values.contains(requiredValue)
                if !hasRequiredValue {
                    violations.append(
                        SHACLViolation(
                            severity: severity,
                            shapeIRI: propertyShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: pathIRI,
                            sourceConstraintIRI: SHACLIRIs.hasValue,
                            message: "hasValue violation: required value \(requiredValue) not present"
                        )
                    )
                }
            }

            if !propertyShape.inValues.isEmpty {
                let allowed = Set(propertyShape.inValues)
                for valueNode in values {
                    if !allowed.contains(valueNode) {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.in,
                                message: "in violation: value \(valueNode) not in allowed set"
                            )
                        )
                    }
                }
            }

            if !propertyShape.languageInValues.isEmpty {
                let languageRanges = propertyShape.languageInValues.compactMap { extractLiteralLexicalForm($0)?.lowercased() }
                for valueNode in values {
                    if !matchesLanguageIn(languageTag: extractLiteralLanguageTag(valueNode), ranges: languageRanges) {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.languageIn,
                                message: "languageIn violation: value \(valueNode) language tag not in allowed set"
                            )
                        )
                    }
                }
            }

            if propertyShape.uniqueLang {
                var languageCounts: [String: Int] = [:]
                for valueNode in values {
                    guard let language = extractLiteralLanguageTag(valueNode)?.lowercased() else {
                        continue
                    }
                    languageCounts[language, default: 0] += 1
                }
                for (_, count) in languageCounts where count > 1 {
                    for _ in 0..<(count - 1) {
                        violations.append(
                            SHACLViolation(
                                severity: severity,
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                sourceConstraintIRI: SHACLIRIs.uniqueLang,
                                message: "uniqueLang violation: duplicate language-tagged values detected"
                            )
                        )
                    }
                }
            }

            if let lessThanIRI = propertyShape.lessThanIRI {
                let comparisonValues = evaluatePropertyPairComparisonValues(
                    propertyPathTerm: lessThanIRI,
                    focusNode: focusNode,
                    dataGraph: dataGraph
                )
                for valueNode in values {
                    for comparisonValue in comparisonValues {
                        guard let comparison = compareRangeValueTerm(valueNode, toBoundTerm: comparisonValue),
                              comparison == .orderedAscending else {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.lessThan,
                                    message: "lessThan violation: value \(valueNode) is not < \(comparisonValue)"
                                )
                            )
                            continue
                        }
                    }
                }
            }

            if let lessThanOrEqualsIRI = propertyShape.lessThanOrEqualsIRI {
                let comparisonValues = evaluatePropertyPairComparisonValues(
                    propertyPathTerm: lessThanOrEqualsIRI,
                    focusNode: focusNode,
                    dataGraph: dataGraph
                )
                for valueNode in values {
                    for comparisonValue in comparisonValues {
                        guard let comparison = compareRangeValueTerm(valueNode, toBoundTerm: comparisonValue),
                              comparison == .orderedAscending || comparison == .orderedSame else {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: SHACLIRIs.lessThanOrEquals,
                                    message: "lessThanOrEquals violation: value \(valueNode) is not <= \(comparisonValue)"
                                )
                            )
                            continue
                        }
                    }
                }
            }

            if let equalsIRI = propertyShape.equalsIRI {
                let relatedValues = Set(
                    evaluatePropertyPairComparisonValues(
                        propertyPathTerm: equalsIRI,
                        focusNode: focusNode,
                        dataGraph: dataGraph
                    )
                )
                let expectedValues = Set(values)
                let mismatchValues = expectedValues.symmetricDifference(relatedValues).sorted()
                for mismatchValue in mismatchValues {
                    violations.append(
                        SHACLViolation(
                            severity: severity,
                            shapeIRI: propertyShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: pathIRI,
                            valueNode: mismatchValue,
                            sourceConstraintIRI: SHACLIRIs.equals,
                            message: "equals violation: value \(mismatchValue) not aligned with predicate \(equalsIRI)"
                        )
                    )
                }
            }

            if let disjointIRI = propertyShape.disjointIRI {
                let relatedValues = Set(
                    evaluatePropertyPairComparisonValues(
                        propertyPathTerm: disjointIRI,
                        focusNode: focusNode,
                        dataGraph: dataGraph
                    )
                )
                for valueNode in values where relatedValues.contains(valueNode) {
                    violations.append(
                        SHACLViolation(
                            severity: severity,
                            shapeIRI: propertyShape.shapeIRI,
                            focusNode: focusNode,
                            pathIRI: pathIRI,
                            valueNode: valueNode,
                            sourceConstraintIRI: SHACLIRIs.disjoint,
                            message: "disjoint violation: value \(valueNode) overlaps predicate \(disjointIRI)"
                        )
                    )
                }
            }

            if let nodeByExpressionIRI = propertyShape.nodeByExpressionIRI {
                for valueNode in values {
                    let referencedShapeIRIs = SHACLNodeExpressionEvaluator()
                        .evaluate(
                            expressionIRI: nodeByExpressionIRI,
                            focusNode: valueNode,
                            shapesGraph: expressionGraph,
                            dataGraph: dataGraph
                        )
                        .sorted()
                    for referencedShapeIRI in referencedShapeIRIs {
                        let doesConform = conforms(
                            valueNode: valueNode,
                            toNodeShapeIRI: referencedShapeIRI,
                            dataGraph: dataGraph,
                            shapesByIRI: shapesByIRI,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI,
                            depth: depth,
                            visited: &visited
                        )
                        if !doesConform {
                            violations.append(
                                SHACLViolation(
                                    severity: severity,
                                    shapeIRI: propertyShape.shapeIRI,
                                    focusNode: focusNode,
                                    pathIRI: pathIRI,
                                    valueNode: valueNode,
                                    sourceConstraintIRI: referencedShapeIRI,
                                    message: "nodeByExpression violation: value \(valueNode) does not conform to \(referencedShapeIRI)"
                                )
                            )
                        }
                    }
                }
            }

            if let nodeReference = propertyShape.nodeShapeReferenceIRI,
               let referencedShape = shapesByIRI[nodeReference],
               referencedShape.kind == .nodeShape {
                for valueNode in values {
                    let key = "\(referencedShape.shapeIRI)|\(valueNode)"
                    if visited.contains(key) {
                        continue
                    }
                    visited.insert(key)
                    let nestedViolations = evaluate(
                        nodeShape: referencedShape,
                        focusNode: valueNode,
                        dataGraph: dataGraph,
                        shapesByIRI: shapesByIRI,
                        expressionGraph: expressionGraph,
                        nodeExpressionsByIRI: nodeExpressionsByIRI,
                        depth: depth + 1,
                        visited: &visited
                    )
                    visited.remove(key)
                    violations.append(contentsOf: nestedViolations)
                }
            }

            if !propertyShape.propertyShapeIRIs.isEmpty {
                for valueNode in values {
                    let wrapperShape = SHACLShapeDefinition(
                        shapeIRI: "\(propertyShape.shapeIRI)#property-wrapper",
                        kind: .nodeShape,
                        severity: severity,
                        targets: [],
                        propertyShapeIRIs: propertyShape.propertyShapeIRIs
                    )
                    let nestedViolations = evaluate(
                        nodeShape: wrapperShape,
                        focusNode: valueNode,
                        dataGraph: dataGraph,
                        shapesByIRI: shapesByIRI,
                        expressionGraph: expressionGraph,
                        nodeExpressionsByIRI: nodeExpressionsByIRI,
                        depth: depth + 1,
                        visited: &visited
                    )
                    violations.append(contentsOf: nestedViolations)
                }
            }

            if !propertyShape.andShapeIRIs.isEmpty {
                for valueNode in values {
                    var matchesAll = true
                    for shapeIRI in propertyShape.andShapeIRIs {
                        if !conforms(
                            valueNode: valueNode,
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
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.and,
                                message: "and violation: value \(valueNode) does not satisfy all referenced shapes"
                            )
                        )
                    }
                }
            }

            if !propertyShape.orShapeIRIs.isEmpty {
                for valueNode in values {
                    var matchesAny = false
                    for shapeIRI in propertyShape.orShapeIRIs {
                        if conforms(
                            valueNode: valueNode,
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
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.or,
                                message: "or violation: value \(valueNode) does not satisfy any referenced shape"
                            )
                        )
                    }
                }
            }

            if let forbiddenShapeIRI = propertyShape.notShapeIRI {
                for valueNode in values {
                    let matchesForbidden = conforms(
                        valueNode: valueNode,
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
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.not,
                                message: "not violation: value \(valueNode) conforms to forbidden shape"
                            )
                        )
                    }
                }
            }

            if !propertyShape.xoneShapeIRIs.isEmpty {
                for valueNode in values {
                    var matchCount = 0
                    for shapeIRI in propertyShape.xoneShapeIRIs {
                        if conforms(
                            valueNode: valueNode,
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
                                shapeIRI: propertyShape.shapeIRI,
                                focusNode: focusNode,
                                pathIRI: pathIRI,
                                valueNode: valueNode,
                                sourceConstraintIRI: SHACLIRIs.xone,
                                message: "xone violation: value \(valueNode) matched \(matchCount) referenced shapes"
                            )
                        )
                    }
                }
            }

            violations.append(
                contentsOf: evaluateQualifiedValueConstraints(
                    nodeShape: nodeShape,
                    propertyShape: propertyShape,
                    propertyShapeIRI: propertyShapeIRI,
                    focusNode: focusNode,
                    pathIRI: pathIRI,
                    values: values,
                    severity: severity,
                    dataGraph: dataGraph,
                    shapesByIRI: shapesByIRI,
                    expressionGraph: expressionGraph,
                    nodeExpressionsByIRI: nodeExpressionsByIRI,
                    depth: depth,
                    visited: &visited
                )
            )
        }

        return violations
    }

    func resolvePropertyPathValues(
        _ path: SHACLPropertyPath,
        from focusNode: String,
        dataGraph: SHACLDataGraph
    ) -> Set<String> {
        evaluatePropertyPathValues(path, from: focusNode, dataGraph: dataGraph)
    }

    func conforms(
        valueNode: String,
        toNodeShapeIRI shapeIRI: String,
        dataGraph: SHACLDataGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        expressionGraph: SHACLShapesGraph,
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition] = [:],
        depth: Int,
        visited: inout Set<String>
    ) -> Bool {
        conforms(
            valueNode: valueNode,
            toShapeIRI: shapeIRI,
            dataGraph: dataGraph,
            shapesByIRI: shapesByIRI,
            expressionGraph: expressionGraph,
            nodeExpressionsByIRI: nodeExpressionsByIRI,
            depth: depth,
            visited: &visited
        )
    }

    func conforms(
        valueNode: String,
        toShapeIRI shapeIRI: String,
        dataGraph: SHACLDataGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        expressionGraph: SHACLShapesGraph,
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition] = [:],
        depth: Int,
        visited: inout Set<String>
    ) -> Bool {
        guard let shape = shapesByIRI[shapeIRI] else {
            return false
        }

        let key = "\(shape.shapeIRI)|\(valueNode)"
        if visited.contains(key) {
            return true
        }

        visited.insert(key)
        defer { visited.remove(key) }

        let nestedViolations: [SHACLViolation]
        switch shape.kind {
        case .nodeShape:
            nestedViolations = evaluate(
                nodeShape: shape,
                focusNode: valueNode,
                dataGraph: dataGraph,
                shapesByIRI: shapesByIRI,
                expressionGraph: expressionGraph,
                nodeExpressionsByIRI: nodeExpressionsByIRI,
                depth: depth + 1,
                visited: &visited
            )
        case .propertyShape:
            let wrapper = SHACLShapeDefinition(
                shapeIRI: "\(shape.shapeIRI)#rule-condition-wrapper",
                kind: .nodeShape,
                targets: [],
                propertyShapeIRIs: [shape.shapeIRI]
            )
            nestedViolations = evaluate(
                nodeShape: wrapper,
                focusNode: valueNode,
                dataGraph: dataGraph,
                shapesByIRI: shapesByIRI,
                expressionGraph: expressionGraph,
                nodeExpressionsByIRI: nodeExpressionsByIRI,
                depth: depth + 1,
                visited: &visited
            )
        }
        return nestedViolations.isEmpty
    }
}
