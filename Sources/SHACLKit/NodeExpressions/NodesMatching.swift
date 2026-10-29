import Foundation

func nodesMatching(
    shapeIRI: String,
    candidates: Set<String>,
    shapesGraph: SHACLShapesGraph,
    dataGraph: SHACLDataGraph
) -> Set<String> {
    guard !candidates.isEmpty else {
        return []
    }

    let validator = SHACLCoreValidator()
    let neutralizedShapes = shapesGraph.shapes.map(shapeWithoutTargets)
    var matched: Set<String> = []
    for candidate in candidates {
        let tempShape = SHACLShapeDefinition(
            shapeIRI: "urn:codex:shaclkit:nodeexpr:nodesMatching:\(candidate)",
            kind: .nodeShape,
            targets: [.targetNode(candidate)],
            nodeShapeReferenceIRI: shapeIRI
        )
        let tempGraph = SHACLShapesGraph(
            shapes: neutralizedShapes + [tempShape],
            nodeExpressions: shapesGraph.nodeExpressions,
            tripleRules: shapesGraph.tripleRules,
            sparqlDefinitions: shapesGraph.sparqlDefinitions
        )
        if let result = try? validator.validate(dataGraph: dataGraph, shapesGraph: tempGraph),
           result.conforms {
            matched.insert(candidate)
        }
    }
    return matched
}

private func shapeWithoutTargets(_ shape: SHACLShapeDefinition) -> SHACLShapeDefinition {
    SHACLShapeDefinition(
        shapeIRI: shape.shapeIRI,
        kind: shape.kind,
        isRDFSClass: shape.isRDFSClass,
        isDeactivated: shape.isDeactivated,
        severity: shape.severity,
        targets: [],
        propertyShapeIRIs: shape.propertyShapeIRIs,
        tripleRuleIRIs: shape.tripleRuleIRIs,
        sparqlConstraintIRIs: shape.sparqlConstraintIRIs,
        sparqlTargetIRIs: shape.sparqlTargetIRIs,
        pathIRI: shape.pathIRI,
        propertyPath: shape.propertyPath,
        expressionIRI: shape.expressionIRI,
        classIRI: shape.classIRI,
        nodeKind: shape.nodeKind,
        datatypeIRI: shape.datatypeIRI,
        minLength: shape.minLength,
        maxLength: shape.maxLength,
        minInclusive: shape.minInclusive,
        maxInclusive: shape.maxInclusive,
        minExclusive: shape.minExclusive,
        maxExclusive: shape.maxExclusive,
        pattern: shape.pattern,
        hasValue: shape.hasValue,
        inValues: shape.inValues,
        languageInValues: shape.languageInValues,
        uniqueLang: shape.uniqueLang,
        equalsIRI: shape.equalsIRI,
        disjointIRI: shape.disjointIRI,
        lessThanIRI: shape.lessThanIRI,
        lessThanOrEqualsIRI: shape.lessThanOrEqualsIRI,
        isClosed: shape.isClosed,
        ignoredPropertyIRIs: shape.ignoredPropertyIRIs,
        nodeByExpressionIRI: shape.nodeByExpressionIRI,
        nodeShapeReferenceIRI: shape.nodeShapeReferenceIRI,
        andShapeIRIs: shape.andShapeIRIs,
        orShapeIRIs: shape.orShapeIRIs,
        xoneShapeIRIs: shape.xoneShapeIRIs,
        notShapeIRI: shape.notShapeIRI,
        qualifiedValueShapeIRI: shape.qualifiedValueShapeIRI,
        qualifiedValueShapesDisjoint: shape.qualifiedValueShapesDisjoint,
        qualifiedMinCount: shape.qualifiedMinCount,
        qualifiedMaxCount: shape.qualifiedMaxCount,
        minCount: shape.minCount,
        maxCount: shape.maxCount
    )
}
