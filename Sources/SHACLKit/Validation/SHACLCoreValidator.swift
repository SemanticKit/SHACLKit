import Foundation

public struct SHACLCoreValidator: SHACLValidator {
    private let shapesLoader: any SHACLShapesGraphLoading

    private let dataLoader: any SHACLDataGraphLoading

    let focusResolver: SHACLFocusNodeResolver

    let sparqlExecutor: any SHACLSPARQLExecutor

    private let conformanceDisallowedSeverities: Set<SHACLSeverity>

    let maxReferenceDepth = 16

    let maxRuleIterations = 16

    public init(
        shapesLoader: any SHACLShapesGraphLoading = SHACLShapesGraphLoader(),
        dataLoader: any SHACLDataGraphLoading = SHACLDataGraphLoader(),
        focusResolver: SHACLFocusNodeResolver = SHACLFocusNodeResolver(),
        sparqlExecutor: any SHACLSPARQLExecutor = SHACLDeniedSPARQLExecutor(),
        conformanceDisallowedSeverities: Set<SHACLSeverity> = [.violation, .warning, .info]
    ) {
        self.shapesLoader = shapesLoader
        self.dataLoader = dataLoader
        self.focusResolver = focusResolver
        self.sparqlExecutor = sparqlExecutor
        self.conformanceDisallowedSeverities = conformanceDisallowedSeverities
    }

    public func validate(dataGraph: Data, shapesGraph: Data) throws -> SHACLValidationResult {
        let parsedShapes = try shapesLoader.load(from: shapesGraph)
        let parsedData = try dataLoader.load(from: dataGraph)
        return try validate(dataGraph: parsedData, shapesGraph: parsedShapes)
    }

    public func validate(dataGraph: SHACLDataGraph, shapesGraph: SHACLShapesGraph) throws -> SHACLValidationResult {
        try validateShapesGraph(shapesGraph)
        let parsedShapes = shapesGraph
        let shapeByIRI = Dictionary(uniqueKeysWithValues: parsedShapes.shapes.map { ($0.shapeIRI, $0) })
        let nodeExpressionsByIRI = Dictionary(uniqueKeysWithValues: parsedShapes.nodeExpressions.map { ($0.expressionIRI, $0) })
        let parsedData = applyRules(
            dataGraph: dataGraph,
            shapesGraph: parsedShapes,
            shapesByIRI: shapeByIRI,
            nodeExpressionsByIRI: nodeExpressionsByIRI
        )
        let expressionGraph = SHACLShapesGraph(
            shapes: Array(shapeByIRI.values),
            nodeExpressions: Array(nodeExpressionsByIRI.values)
        )
        let sparqlDefinitionsByIRI = Dictionary(uniqueKeysWithValues: parsedShapes.sparqlDefinitions.map { ($0.sparqlIRI, $0) })
        let resolutions = try resolveFocusNodes(
            dataGraph: parsedData,
            shapesGraph: parsedShapes,
            sparqlDefinitionsByIRI: sparqlDefinitionsByIRI
        )

        var violations: [SHACLViolation] = []

        for resolution in resolutions {
            guard let shape = shapeByIRI[resolution.shapeIRI] else {
                continue
            }
            if shape.isDeactivated {
                continue
            }
            for focusNode in resolution.focusNodes {
                var visited: Set<String> = []
                var deferredVisited: Set<String> = []
                if shape.kind == .nodeShape {
                    violations.append(
                        contentsOf: evaluate(
                            nodeShape: shape,
                            focusNode: focusNode,
                            dataGraph: parsedData,
                            shapesByIRI: shapeByIRI,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI,
                            depth: 0,
                            visited: &visited
                        )
                    )
                    violations.append(
                        contentsOf: evaluateDeferredMemberShapeConstraints(
                            nodeShape: shape,
                            focusNode: focusNode,
                            dataGraph: parsedData,
                            shapesByIRI: shapeByIRI,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI,
                            visited: &deferredVisited
                        )
                    )
                } else if shape.kind == .propertyShape {
                    if shape.isDeactivated {
                        continue
                    }
                    let wrapperShape = SHACLShapeDefinition(
                        shapeIRI: "\(shape.shapeIRI)#direct-property-target-wrapper",
                        kind: .nodeShape,
                        severity: shape.severity,
                        targets: [],
                        propertyShapeIRIs: [shape.shapeIRI]
                    )
                    violations.append(
                        contentsOf: evaluate(
                            nodeShape: wrapperShape,
                            focusNode: focusNode,
                            dataGraph: parsedData,
                            shapesByIRI: shapeByIRI,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI,
                            depth: 0,
                            visited: &visited
                        )
                    )
                    violations.append(
                        contentsOf: evaluateDeferredMemberShapeForPropertyShape(
                            propertyShape: shape,
                            rootFocusNode: focusNode,
                            currentNode: focusNode,
                            inheritedSeverity: shape.severity,
                            dataGraph: parsedData,
                            shapesByIRI: shapeByIRI,
                            expressionGraph: expressionGraph,
                            nodeExpressionsByIRI: nodeExpressionsByIRI,
                            visited: &deferredVisited
                        )
                    )
                }
            }
        }

        violations.append(
            contentsOf: try evaluateSPARQLConstraints(
                resolutions: resolutions,
                dataGraph: parsedData,
                shapesGraph: parsedShapes,
                shapesByIRI: shapeByIRI,
                sparqlDefinitionsByIRI: sparqlDefinitionsByIRI
            )
        )

        let sortedViolations = violations.sorted { lhs, rhs in
            (
                lhs.shapeIRI,
                lhs.focusNode,
                lhs.pathIRI ?? "",
                lhs.sourceConstraintIRI ?? "",
                lhs.valueNode ?? "",
                lhs.message
            ) < (
                rhs.shapeIRI,
                rhs.focusNode,
                rhs.pathIRI ?? "",
                rhs.sourceConstraintIRI ?? "",
                rhs.valueNode ?? "",
                rhs.message
            )
        }

        let violationCount = sortedViolations.filter { $0.severity == .violation }.count
        let disallowedResultCount = sortedViolations.filter { conformanceDisallowedSeverities.contains($0.severity) }.count

        if sortedViolations.isEmpty {
            return SHACLValidationResult(
                conforms: true,
                message: "SHACL Core subset validation passed for \(parsedShapes.shapes.count) shapes.",
                violations: []
            )
        }

        return SHACLValidationResult(
            conforms: disallowedResultCount == 0,
            message: "SHACL Core subset validation produced \(sortedViolations.count) result(s), including \(violationCount) violation(s) and \(disallowedResultCount) disallowed severities.",
            violations: sortedViolations
        )
    }

    public func validate<DataSource, ShapesSource, DataAdapter: SHACLDataGraphAdapting, ShapesAdapter: SHACLShapesGraphAdapting>(
        dataSource: DataSource,
        shapesSource: ShapesSource,
        dataAdapter: DataAdapter,
        shapesAdapter: ShapesAdapter
    ) throws -> SHACLValidationResult
    where DataAdapter.Source == DataSource, ShapesAdapter.Source == ShapesSource {
        let dataGraph = try dataAdapter.adapt(dataSource)
        let shapesGraph = try shapesAdapter.adapt(shapesSource)
        return try validate(dataGraph: dataGraph, shapesGraph: shapesGraph)
    }
}
