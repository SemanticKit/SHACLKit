import IRIKit
import RDFCore
import RDFFormats
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
        // The blank nodes of severities that have neither a declaration nor
        // a node in the shapes graph, one for each severity object.
        var undeclaredSeverities: [ObjectIdentifier: BlankNode] = [:]
        /// The node a severity is written as: the IRI its declaration
        /// derives, the `sh:severity` node of the shapes graph it came from,
        /// or, for a severity made in Swift with neither, a blank node.
        func severityTerm(_ severity: any SHACL.Severity, in shape: SHACLShape) -> ObjectTerm {
            if let iri = IRIKit.IRI(of: severity) { return .iri(iri) }
            if shape.severity === severity, let node = shape.severityNode { return node }
            let key = ObjectIdentifier(severity)
            if let node = undeclaredSeverities[key] { return .blankNode(node) }
            let node = blankNode("severity")
            undeclaredSeverities[key] = node
            return .blankNode(node)
        }
        func encode(_ result: SHACLValidationResult) -> BlankNode {
            let node = blankNode("result")
            insert(node, IRIKit.IRI(of: RDF.type)!, .iri(IRIKit.IRI(of: SHACL.ValidationResultIndividual.self)!))
            insert(node, IRIKit.IRI(of: SHACL.resultSeverity)!, severityTerm(result.severity, in: result.sourceShape))
            insert(node, IRIKit.IRI(of: SHACL.sourceShape)!, result.sourceShape.id)
            insert(node, IRIKit.IRI(of: SHACL.focusNode)!, result.focusNode)
            if let path = result.resultPath {
                insert(node, IRIKit.IRI(of: SHACL.resultPath)!, path.encode(into: &graph) { blankNode("path") })
            }
            if let value = result.value {
                insert(node, IRIKit.IRI(of: SHACL.value)!, value)
            }
            insert(node, IRIKit.IRI(of: SHACL.sourceConstraintComponent)!, .iri(IRIKit.IRI(of: result.sourceConstraintComponent)!))
            if let constraint = result.sourceConstraint {
                insert(node, IRIKit.IRI(of: SHACL.sourceConstraint)!, constraint)
            }
            insert(node, IRIKit.IRI(of: SHACL.resultMessage)!, .literal(Literal(result.message)))
            for detail in result.details {
                insert(node, IRIKit.IRI(of: SHACL.detail)!, .blankNode(encode(detail)))
            }
            return node
        }
        // A non-empty identifier is always a blank node.
        let report = try! BlankNode("report")
        insert(report, IRIKit.IRI(of: RDF.type)!, .iri(IRIKit.IRI(of: SHACL.ValidationReportIndividual.self)!))
        insert(report, IRIKit.IRI(of: SHACL.conforms)!, .literal(Literal(conforms)))
        for result in results {
            insert(report, IRIKit.IRI(of: SHACL.result)!, .blankNode(encode(result)))
        }
        return graph
    }
}
