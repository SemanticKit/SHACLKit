import Foundation

public struct SHACLFocusNodeResolver: Sendable {
    public init() {}

    public func resolve(dataGraph: SHACLDataGraph, shapesGraph: SHACLShapesGraph) -> [SHACLTargetResolution] {
        shapesGraph.shapes.map { shape in
            var nodes: Set<String> = []
            for selector in shape.targets {
                nodes.formUnion(resolve(selector: selector, in: dataGraph, shapesGraph: shapesGraph))
            }
            if shape.kind == .nodeShape && shape.isRDFSClass {
                let subclassMap = Dictionary(grouping: dataGraph.triples.filter { $0.predicate == SHACLIRIs.rdfsSubClassOf }, by: \.subject)
                var closure: Set<String> = [shape.shapeIRI]
                var pending: [String] = [shape.shapeIRI]
                while let current = pending.popLast() {
                    let directSubclasses = subclassMap
                        .filter { _, triples in triples.contains(where: { $0.object == current }) }
                        .map(\.key)
                    for subclass in directSubclasses where !closure.contains(subclass) {
                        closure.insert(subclass)
                        pending.append(subclass)
                    }
                }
                nodes.formUnion(
                    dataGraph.triples
                        .filter { $0.predicate == SHACLIRIs.rdfType && closure.contains($0.object) }
                        .map(\.subject)
                )
            }
            nodes.formUnion(
                dataGraph.triples
                    .filter { $0.predicate == SHACLIRIs.shape && $0.object == shape.shapeIRI }
                    .map(\.subject)
            )
            return SHACLTargetResolution(shapeIRI: shape.shapeIRI, focusNodes: nodes.sorted())
        }
    }

    private func resolve(selector: SHACLTargetSelector, in graph: SHACLDataGraph, shapesGraph: SHACLShapesGraph) -> Set<String> {
        switch selector {
        case .targetClass(let classIRI):
            return Set(
                graph.triples
                    .filter { $0.predicate == SHACLIRIs.rdfType && $0.object == classIRI }
                    .map(\.subject)
            )
        case .targetNode(let nodeIRI):
            return Set([nodeIRI])
        case .targetNodeExpression(let expressionIRI):
            let output = SHACLNodeExpressionEvaluator().evaluate(
                expressionIRI: expressionIRI,
                focusNode: "",
                shapesGraph: shapesGraph,
                dataGraph: graph
            )
            return Set(output.filter { !$0.isEmpty })
        case .targetSubjectsOf(let predicateIRI):
            return Set(graph.triples.filter { $0.predicate == predicateIRI }.map(\.subject))
        case .targetObjectsOf(let predicateIRI):
            return Set(graph.triples.filter { $0.predicate == predicateIRI }.map(\.object))
        case .targetWhere:
            return []
        }
    }
}
