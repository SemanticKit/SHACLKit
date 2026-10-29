import Foundation

extension SHACLCoreValidator {
    func applyRules(
        dataGraph: SHACLDataGraph,
        shapesGraph: SHACLShapesGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition]
    ) -> SHACLDataGraph {
        let ruleByIRI = Dictionary(uniqueKeysWithValues: shapesGraph.tripleRules.map { ($0.ruleIRI, $0) })
        let nodeShapesWithRules = shapesGraph.shapes
            .filter { $0.kind == .nodeShape && !$0.tripleRuleIRIs.isEmpty }
            .sorted(by: { $0.shapeIRI < $1.shapeIRI })

        if nodeShapesWithRules.isEmpty || ruleByIRI.isEmpty {
            return dataGraph
        }

        var triples = Set(dataGraph.triples)
        let expressionGraph = SHACLShapesGraph(
            shapes: Array(shapesByIRI.values),
            nodeExpressions: Array(nodeExpressionsByIRI.values)
        )

        for _ in 0..<maxRuleIterations {
            let graphSnapshot = SHACLDataGraph(triples: Array(triples))
            let resolutions = focusResolver.resolve(dataGraph: graphSnapshot, shapesGraph: shapesGraph)
            let focusByShapeIRI = Dictionary(uniqueKeysWithValues: resolutions.map { ($0.shapeIRI, $0.focusNodes) })
            var insertedAny = false

            for nodeShape in nodeShapesWithRules {
                let focusNodes = focusByShapeIRI[nodeShape.shapeIRI] ?? []
                let orderedRules = nodeShape.tripleRuleIRIs
                    .compactMap { ruleByIRI[$0] }
                    .sorted { lhs, rhs in
                        let lhsOrder = lhs.ruleOrder ?? 0
                        let rhsOrder = rhs.ruleOrder ?? 0
                        if lhsOrder != rhsOrder {
                            return lhsOrder < rhsOrder
                        }
                        return lhs.ruleIRI < rhs.ruleIRI
                    }
                for focusNode in focusNodes {
                    for rule in orderedRules {
                        if !ruleConditionsSatisfied(
                            rule: rule,
                            focusNode: focusNode,
                            dataGraph: graphSnapshot,
                            shapesByIRI: shapesByIRI,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI
                        ) {
                            continue
                        }

                        let subjects = evaluateRuleTerm(
                            rule.subjectTerm,
                            focusNode: focusNode,
                            dataGraph: graphSnapshot,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI
                        )
                        let predicates = evaluateRuleTerm(
                            rule.predicateTerm,
                            focusNode: focusNode,
                            dataGraph: graphSnapshot,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI
                        )
                        let objects = evaluateRuleTerm(
                            rule.objectTerm,
                            focusNode: focusNode,
                            dataGraph: graphSnapshot,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI
                        )

                        for subject in subjects {
                            for predicate in predicates {
                                for object in objects {
                                    let triple = SHACLDataTriple(subject: subject, predicate: predicate, object: object)
                                    let inserted = triples.insert(triple).inserted
                                    insertedAny = insertedAny || inserted
                                }
                            }
                        }
                    }
                }
            }

            if !insertedAny {
                break
            }
        }

        let stableTriples = triples.sorted { lhs, rhs in
            (lhs.subject, lhs.predicate, lhs.object) < (rhs.subject, rhs.predicate, rhs.object)
        }
        return SHACLDataGraph(triples: stableTriples)
    }

    private func ruleConditionsSatisfied(
        rule: SHACLTripleRuleDefinition,
        focusNode: String,
        dataGraph: SHACLDataGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        expressionGraph: SHACLShapesGraph,
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition]
    ) -> Bool {
        if rule.conditionShapeIRIs.isEmpty {
            return true
        }
        var visited: Set<String> = []
        return rule.conditionShapeIRIs.allSatisfy { conditionShapeIRI in
            conforms(
                valueNode: focusNode,
                toShapeIRI: conditionShapeIRI,
                dataGraph: dataGraph,
                shapesByIRI: shapesByIRI,
                expressionGraph: expressionGraph,
                nodeExpressionsByIRI: nodeExpressionsByIRI,
                depth: 0,
                visited: &visited
            )
        }
    }

    private func evaluateRuleTerm(
        _ term: String,
        focusNode: String,
        dataGraph: SHACLDataGraph,
        expressionGraph: SHACLShapesGraph,
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition]
    ) -> [String] {
        if term == SHACLIRIs.shThis {
            return [focusNode]
        }

        if nodeExpressionsByIRI[term] != nil {
            return SHACLNodeExpressionEvaluator()
                .evaluate(
                    expressionIRI: term,
                    focusNode: focusNode,
                    shapesGraph: expressionGraph,
                    dataGraph: dataGraph
                )
                .filter { !$0.isEmpty }
                .sorted()
        }

        return [term]
    }
}
