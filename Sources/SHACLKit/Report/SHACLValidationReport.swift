import IRIKit
import RDFCore
import RDFKit

/// A validation report (SHACL 1.2 Core §3.6.1): whether the data graph
/// conforms to the shapes graph, and its results.
public struct SHACLValidationReport: Sendable, Equatable {
    /// `sh:conforms`: true when no result has a severity the validation
    /// disallows.
    public let conforms: Bool

    /// `sh:result`: the validation results, in a stable order.
    public let results: [SHACLValidationResult]

    public init(conforms: Bool, results: [SHACLValidationResult] = []) {
        self.conforms = conforms
        self.results = results
    }

    /// The report as an RDF graph (SHACL 1.2 Core §3.6): the boundary where
    /// a report's severities, constraint components and shapes are written
    /// as their IRIs and nodes.
    ///
    /// The report and its results are blank nodes, named `report`,
    /// `result1`, `result2` and so on, and complex result paths are written
    /// as §2.3.1 describes them.
    public var graph: Graph {
        var graph = Graph()
        var count = 0
        func blankNode(_ prefix: String) -> BlankNode {
            count += 1
            // A non-empty identifier is always a blank node.
            return try! BlankNode("\(prefix)\(count)")
        }
        func insert(_ subject: BlankNode, _ predicate: IRI, _ object: ObjectTerm) {
            graph.insert(Graph.Element(subject: .blankNode(subject), predicate: predicate, object: object))
        }
        func encode(_ result: SHACLValidationResult) -> BlankNode {
            let node = blankNode("result")
            insert(node, RDF.type.metadata.id, .iri(SHACL.ValidationResultIndividual.metadata.id))
            insert(node, SHACL.resultSeverity.metadata.id, (result.severity as? SHACLDeclaredSeverity)?.id ?? .iri(type(of: result.severity).metadata.id))
            insert(node, SHACL.sourceShape.metadata.id, result.sourceShape.id)
            insert(node, SHACL.focusNode.metadata.id, result.focusNode)
            if let path = result.resultPath {
                insert(node, SHACL.resultPath.metadata.id, path.encode(into: &graph) { blankNode("path") })
            }
            if let value = result.value {
                insert(node, SHACL.value.metadata.id, value)
            }
            insert(node, SHACL.sourceConstraintComponent.metadata.id, .iri(type(of: result.sourceConstraintComponent).metadata.id))
            if let constraint = result.sourceConstraint {
                insert(node, SHACL.sourceConstraint.metadata.id, constraint)
            }
            insert(node, SHACL.resultMessage.metadata.id, .literal(Literal(result.message)))
            for detail in result.details {
                insert(node, SHACL.detail.metadata.id, .blankNode(encode(detail)))
            }
            return node
        }
        // A non-empty identifier is always a blank node.
        let report = try! BlankNode("report")
        insert(report, RDF.type.metadata.id, .iri(SHACL.ValidationReportIndividual.metadata.id))
        insert(report, SHACL.conforms.metadata.id, .literal(Literal(conforms)))
        for result in results {
            insert(report, SHACL.result.metadata.id, .blankNode(encode(result)))
        }
        return graph
    }
}
