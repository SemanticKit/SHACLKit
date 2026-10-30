import Testing

extension Tag {
    /// Decoding a shapes graph into shapes, constraints, targets and rules.
    @Tag static var shapesGraph: Self
    /// Node expressions (SHACL 1.2 Node Expressions).
    @Tag static var nodeExpression: Self
    /// Focus nodes and targets.
    @Tag static var targets: Self
    /// Constraint components of SHACL 1.2 Core.
    @Tag static var constraints: Self
    /// Triple rules (SHACL 1.2 Rules).
    @Tag static var rules: Self
    /// SPARQL-based constraints and targets, and the executor boundary.
    @Tag static var sparql: Self
    /// Validation reports and the graphs they are written as.
    @Tag static var report: Self
    /// Tests from the W3C data-shapes test suites.
    @Tag static var w3c: Self
}
