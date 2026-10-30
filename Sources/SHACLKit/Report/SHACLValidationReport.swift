import IRIKit
import RDFCore
import RDF
import struct RDFCore.Literal
import SHACL
import struct RDFCore.Graph

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
            insert(node, RDF.type.iri!, .iri(SHACL.ValidationResultIndividual.iri!))
            insert(node, SHACL.resultSeverity.iri!, .iri(result.severity.iri!))
            insert(node, SHACL.sourceShape.iri!, result.sourceShape.id)
            insert(node, SHACL.focusNode.iri!, result.focusNode)
            if let path = result.resultPath {
                insert(node, SHACL.resultPath.iri!, path.encode(into: &graph) { blankNode("path") })
            }
            if let value = result.value {
                insert(node, SHACL.value.iri!, value)
            }
            insert(node, SHACL.sourceConstraintComponent.iri!, .iri(result.sourceConstraintComponent.iri!))
            if let constraint = result.sourceConstraint {
                insert(node, SHACL.sourceConstraint.iri!, constraint)
            }
            insert(node, SHACL.resultMessage.iri!, .literal(Literal(result.message)))
            for detail in result.details {
                insert(node, SHACL.detail.iri!, .blankNode(encode(detail)))
            }
            return node
        }
        // A non-empty identifier is always a blank node.
        let report = try! BlankNode("report")
        insert(report, RDF.type.iri!, .iri(SHACL.ValidationReportIndividual.iri!))
        insert(report, SHACL.conforms.iri!, .literal(Literal(conforms)))
        for result in results {
            insert(report, SHACL.result.iri!, .blankNode(encode(result)))
        }
        return graph
    }
}
