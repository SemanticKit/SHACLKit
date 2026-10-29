import Foundation

extension SHACLCoreValidator {
    func resolveFocusNodes(
        dataGraph: SHACLDataGraph,
        shapesGraph: SHACLShapesGraph,
        sparqlDefinitionsByIRI: [String: SHACLSPARQLDefinition]
    ) throws -> [SHACLTargetResolution] {
        let baseline = focusResolver.resolve(dataGraph: dataGraph, shapesGraph: shapesGraph)
        let baselineByShapeIRI = Dictionary(uniqueKeysWithValues: baseline.map { ($0.shapeIRI, Set($0.focusNodes)) })
        let shapesByIRI = Dictionary(uniqueKeysWithValues: shapesGraph.shapes.map { ($0.shapeIRI, $0) })
        let nodeExpressionsByIRI = Dictionary(uniqueKeysWithValues: shapesGraph.nodeExpressions.map { ($0.expressionIRI, $0) })
        let expressionGraph = SHACLShapesGraph(
            shapes: Array(shapesByIRI.values),
            nodeExpressions: Array(nodeExpressionsByIRI.values)
        )
        let candidateTargetWhereNodes = Set(dataGraph.triples.flatMap { [$0.subject, $0.object] }).sorted()

        return try shapesGraph.shapes.map { shape in
            var focus = baselineByShapeIRI[shape.shapeIRI] ?? []
            for target in shape.targets {
                guard case .targetWhere(let whereShapeIRI) = target else {
                    continue
                }
                guard shapesByIRI[whereShapeIRI] != nil else {
                    continue
                }
                for candidate in candidateTargetWhereNodes {
                    var visited: Set<String> = []
                    if conforms(
                        valueNode: candidate,
                        toShapeIRI: whereShapeIRI,
                        dataGraph: dataGraph,
                        shapesByIRI: shapesByIRI,
                        expressionGraph: expressionGraph,
                        nodeExpressionsByIRI: nodeExpressionsByIRI,
                        depth: 0,
                        visited: &visited
                    ) {
                        focus.insert(candidate)
                    }
                }
            }
            for sparqlTargetIRI in shape.sparqlTargetIRIs.sorted() {
                guard let sparql = sparqlDefinitionsByIRI[sparqlTargetIRI], let selectQuery = sparql.selectQuery else {
                    continue
                }
                let resolved = try sparqlExecutor.select(
                    query: withSPARQLPrefixes(selectQuery, prefixes: sparql.prefixes),
                    focusNode: nil,
                    dataGraph: dataGraph,
                    shapesGraph: shapesGraph
                )
                focus.formUnion(resolved.filter { !$0.isEmpty })
            }
            return SHACLTargetResolution(shapeIRI: shape.shapeIRI, focusNodes: focus.sorted())
        }
    }
}
