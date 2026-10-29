import Foundation

extension SHACLCoreValidator {
    func validateShapesGraph(_ shapesGraph: SHACLShapesGraph) throws {
        let byIRI = Dictionary(uniqueKeysWithValues: shapesGraph.shapes.map { ($0.shapeIRI, $0) })
        let expressionByIRI = Dictionary(uniqueKeysWithValues: shapesGraph.nodeExpressions.map { ($0.expressionIRI, $0) })
        let ruleByIRI = Dictionary(uniqueKeysWithValues: shapesGraph.tripleRules.map { ($0.ruleIRI, $0) })
        let sparqlByIRI = Dictionary(uniqueKeysWithValues: shapesGraph.sparqlDefinitions.map { ($0.sparqlIRI, $0) })

        for shape in shapesGraph.shapes where shape.kind == .nodeShape {
            for target in shape.targets {
                if case .targetNode(let targetNodeIRI) = target,
                   let sparql = sparqlByIRI[targetNodeIRI],
                   sparql.selectQuery == nil {
                    throw SHACLError.invalidShapesGraph("SPARQL target \(targetNodeIRI) must define sh:select")
                }
            }
            if let expressionIRI = shape.expressionIRI,
               expressionByIRI[expressionIRI] == nil,
               expressionIRI != SHACLIRIs.shThis,
               !isDirectExpressionLiteralTerm(expressionIRI) {
                throw SHACLError.invalidShapesGraph(
                    "Node shape \(shape.shapeIRI) references missing node expression \(expressionIRI)"
                )
            }
            if let nodeByExpressionIRI = shape.nodeByExpressionIRI, expressionByIRI[nodeByExpressionIRI] == nil {
                guard let referencedShape = byIRI[nodeByExpressionIRI], referencedShape.kind == .nodeShape else {
                    throw SHACLError.invalidShapesGraph(
                        "Node shape \(shape.shapeIRI) references missing nodeByExpression \(nodeByExpressionIRI)"
                    )
                }
            }
            let referencedNodeShapeIRIs =
                [shape.nodeShapeReferenceIRI, shape.notShapeIRI, shape.reifierShapeIRI, shape.memberShapeIRI, shape.qualifiedValueShapeIRI].compactMap { $0 }
                + shape.andShapeIRIs
                + shape.orShapeIRIs
                + shape.xoneShapeIRIs

            for referencedIRI in referencedNodeShapeIRIs {
                guard let nodeShape = byIRI[referencedIRI], nodeShape.kind == .nodeShape else {
                    throw SHACLError.invalidShapesGraph(
                        "Node shape \(shape.shapeIRI) references missing or non-node shape \(referencedIRI)"
                    )
                }
            }
            for propertyShapeIRI in shape.propertyShapeIRIs {
                guard let propertyShape = byIRI[propertyShapeIRI], propertyShape.kind == .propertyShape else {
                    throw SHACLError.invalidShapesGraph(
                        "Node shape \(shape.shapeIRI) references missing or non-property shape \(propertyShapeIRI)"
                    )
                }
            }
            for ruleIRI in shape.tripleRuleIRIs {
                guard let rule = ruleByIRI[ruleIRI] else {
                    throw SHACLError.invalidShapesGraph(
                        "Node shape \(shape.shapeIRI) references missing triple rule \(ruleIRI)"
                    )
                }
                for conditionShapeIRI in rule.conditionShapeIRIs {
                    guard byIRI[conditionShapeIRI] != nil else {
                        throw SHACLError.invalidShapesGraph(
                            "Triple rule \(ruleIRI) references missing condition shape \(conditionShapeIRI)"
                        )
                    }
                }
            }
            for sparqlIRI in shape.sparqlConstraintIRIs {
                guard let sparql = sparqlByIRI[sparqlIRI] else {
                    throw SHACLError.invalidShapesGraph(
                        "Node shape \(shape.shapeIRI) references missing SPARQL constraint \(sparqlIRI)"
                    )
                }
                if sparql.selectQuery == nil && sparql.askQuery == nil {
                    throw SHACLError.invalidShapesGraph("SPARQL constraint \(sparqlIRI) is missing sh:select/sh:ask")
                }
            }
            for sparqlTargetIRI in shape.sparqlTargetIRIs {
                guard let sparql = sparqlByIRI[sparqlTargetIRI] else {
                    throw SHACLError.invalidShapesGraph(
                        "Node shape \(shape.shapeIRI) references missing SPARQL target \(sparqlTargetIRI)"
                    )
                }
                if sparql.selectQuery == nil {
                    throw SHACLError.invalidShapesGraph("SPARQL target \(sparqlTargetIRI) must define sh:select")
                }
            }
        }

        for shape in shapesGraph.shapes where shape.kind == .propertyShape {
            for target in shape.targets {
                if case .targetNode(let targetNodeIRI) = target,
                   let sparql = sparqlByIRI[targetNodeIRI],
                   sparql.selectQuery == nil {
                    throw SHACLError.invalidShapesGraph("SPARQL target \(targetNodeIRI) must define sh:select")
                }
            }
            if shape.pathIRI == nil && shape.expressionIRI == nil {
                throw SHACLError.invalidShapesGraph("Property shape \(shape.shapeIRI) is missing both sh:path and sh:expression")
            }
            if let expressionIRI = shape.expressionIRI,
               expressionByIRI[expressionIRI] == nil,
               expressionIRI != SHACLIRIs.shThis,
               !isDirectExpressionLiteralTerm(expressionIRI) {
                throw SHACLError.invalidShapesGraph(
                    "Property shape \(shape.shapeIRI) references missing node expression \(expressionIRI)"
                )
            }
            if let nodeByExpressionIRI = shape.nodeByExpressionIRI, expressionByIRI[nodeByExpressionIRI] == nil {
                guard let referencedShape = byIRI[nodeByExpressionIRI], referencedShape.kind == .nodeShape else {
                    throw SHACLError.invalidShapesGraph(
                        "Property shape \(shape.shapeIRI) references missing nodeByExpression \(nodeByExpressionIRI)"
                    )
                }
            }

            let referencedNodeShapeIRIs =
                [shape.nodeShapeReferenceIRI, shape.notShapeIRI, shape.reifierShapeIRI, shape.memberShapeIRI, shape.qualifiedValueShapeIRI].compactMap { $0 }
                + shape.andShapeIRIs
                + shape.orShapeIRIs
                + shape.xoneShapeIRIs

            for referencedIRI in referencedNodeShapeIRIs {
                guard let nodeShape = byIRI[referencedIRI], nodeShape.kind == .nodeShape else {
                    throw SHACLError.invalidShapesGraph(
                        "Property shape \(shape.shapeIRI) references missing or non-node shape \(referencedIRI)"
                    )
                }
            }
            for sparqlIRI in shape.sparqlConstraintIRIs {
                guard let sparql = sparqlByIRI[sparqlIRI] else {
                    throw SHACLError.invalidShapesGraph(
                        "Property shape \(shape.shapeIRI) references missing SPARQL constraint \(sparqlIRI)"
                    )
                }
                if sparql.selectQuery == nil && sparql.askQuery == nil {
                    throw SHACLError.invalidShapesGraph("SPARQL constraint \(sparqlIRI) is missing sh:select/sh:ask")
                }
            }
            for sparqlTargetIRI in shape.sparqlTargetIRIs {
                guard let sparql = sparqlByIRI[sparqlTargetIRI] else {
                    throw SHACLError.invalidShapesGraph(
                        "Property shape \(shape.shapeIRI) references missing SPARQL target \(sparqlTargetIRI)"
                    )
                }
                if sparql.selectQuery == nil {
                    throw SHACLError.invalidShapesGraph("SPARQL target \(sparqlTargetIRI) must define sh:select")
                }
            }
        }
    }

    private func isDirectExpressionLiteralTerm(_ term: String) -> Bool {
        if term.hasPrefix("\"") {
            return true
        }
        return Int(term) != nil || Double(term) != nil
    }

    func isTrueBooleanTerm(_ term: String) -> Bool {
        term == "true"
            || term == "1"
            || term == "\"true\""
            || term == "\"true\"^^\(SHACLIRIs.xsdBoolean)"
            || term == "\"1\"^^\(SHACLIRIs.xsdBoolean)"
    }
}
