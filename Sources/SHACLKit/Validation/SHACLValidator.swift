import RDFCore
import SHACL
import struct RDFCore.Literal
import struct RDFCore.Graph

/// Validates data graphs against shapes graphs (SHACL 1.2 Core §3).
///
/// A data graph is an RDFCore ``RDFCore/Graph``, read with a format's
/// decoder or made by a ``SHACLDataGraphAdapting`` adapter from an app's
/// typed values, and a shapes graph is a decoded ``SHACLShapesGraph``:
///
///     let shapes = try SHACLShapesGraph(TurtleDecoder().decode(shapesTurtle))
///     let data = try TurtleDecoder().decode(dataTurtle)
///     let report = try SHACLValidator().validate(data, against: shapes)
///     report.conforms
public struct SHACLValidator: Sendable {
    /// The executor of SPARQL-based constraints and targets.
    public let sparqlExecutor: any SHACLSPARQLExecutor

    /// The severities whose results make the data graph not conform
    /// (`sh:conformanceDisallows`, SHACL 1.2 Core §3.6.1), or `nil` when a
    /// result of any severity does.
    public let conformanceDisallows: [any SHACL.Severity]?

    /// Creates a validator.
    ///
    /// - Parameters:
    ///   - sparqlExecutor: Runs SPARQL-based constraints and targets. The
    ///     default runs none, so a shapes graph that has them throws.
    ///   - conformanceDisallows: The severities whose results make the data
    ///     graph not conform; by default, every result does.
    public init(
        sparqlExecutor: any SHACLSPARQLExecutor = SHACLDeniedSPARQLExecutor(),
        conformanceDisallows: [any SHACL.Severity]? = nil
    ) {
        self.sparqlExecutor = sparqlExecutor
        self.conformanceDisallows = conformanceDisallows
    }

    /// Validates `dataGraph` against `shapesGraph` (§3.4): the rules of the
    /// shapes graph are run over the data graph first, then each shape's
    /// focus nodes are validated against it.
    ///
    /// - Throws: ``SHACLError/sparqlNotExecuted(_:)`` when a SPARQL-based
    ///   constraint or target cannot be run.
    public func validate(_ dataGraph: Graph, against shapesGraph: SHACLShapesGraph) throws -> SHACLValidationReport {
        let validation = Validation(dataGraph: dataGraph, shapesGraph: shapesGraph, sparqlExecutor: sparqlExecutor)
        try validation.applyRules()
        var results: [SHACLValidationResult] = []
        for shape in shapesGraph.shapes where !shape.isDeactivated {
            for focusNode in try validation.focusNodes(of: shape) {
                results += try validation.results(of: shape, focusNode: focusNode)
            }
        }
        results.sort { $0.precedes($1) }
        let disallowed = results.filter { result in
            conformanceDisallows?.contains { $0 === result.severity } ?? true
        }
        return SHACLValidationReport(conforms: disallowed.isEmpty, results: results)
    }

    /// The focus nodes of `shape` in `dataGraph` (§2.1.3), in a stable
    /// order: the nodes its targets select, its SHACL instances when the
    /// shape is a class, and the nodes that name it with `sh:shape`.
    public func focusNodes(of shape: SHACLShape, in dataGraph: Graph, against shapesGraph: SHACLShapesGraph) throws -> [ObjectTerm] {
        try Validation(dataGraph: dataGraph, shapesGraph: shapesGraph, sparqlExecutor: sparqlExecutor).focusNodes(of: shape)
    }

    /// Validates a data source against a shapes source, each turned into
    /// its graph by its adapter at the boundary.
    public func validate<DataAdapter: SHACLDataGraphAdapting, ShapesAdapter: SHACLShapesGraphAdapting>(
        _ dataSource: DataAdapter.Source,
        adaptedBy dataAdapter: DataAdapter,
        against shapesSource: ShapesAdapter.Source,
        adaptedBy shapesAdapter: ShapesAdapter
    ) throws -> SHACLValidationReport {
        try validate(dataAdapter.adapt(dataSource), against: shapesAdapter.adapt(shapesSource))
    }
}
