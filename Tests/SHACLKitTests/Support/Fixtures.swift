import Foundation
import IRIKit
import RDFCore
import RDFFormats
@testable import SHACLKit

/// The fixtures of the test target, read with RDFKit's Turtle decoder.
enum Fixtures {
    /// The directory the fixtures are in.
    static var root: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures")
    }

    /// The URL of a fixture.
    static func url(_ name: String) -> URL {
        root.appendingPathComponent(name)
    }

    /// The text of a fixture.
    static func text(_ name: String) throws -> String {
        try String(contentsOf: url(name), encoding: .utf8)
    }

    /// A fixture decoded as Turtle, with the fixture's file URL as base IRI.
    static func graph(_ name: String) throws -> Graph {
        try graph(at: url(name))
    }

    /// The Turtle document at `url`, with the URL as base IRI.
    static func graph(at url: URL) throws -> Graph {
        try TurtleDecoder(base: IRI(rawValue: url.absoluteString)).decode(String(contentsOf: url, encoding: .utf8))
    }

    /// A fixture decoded as a shapes graph.
    static func shapes(_ name: String) throws -> SHACLShapesGraph {
        try SHACLShapesGraph(graph(name))
    }

    /// The report of validating the data fixture against the shapes fixture.
    static func validate(
        shapes: String,
        data: String,
        with validator: SHACLValidator = SHACLValidator()
    ) throws -> SHACLValidationReport {
        try validator.validate(graph(data), against: self.shapes(shapes))
    }
}

/// The RDF term a Turtle object spells, with `ex:` for
/// `http://example.com/` and the usual `rdf:`, `rdfs:`, `xsd:` and `sh:`
/// prefixes: `term("ex:alice")`, `term("42")`, `term("\"Bob\"@en")`.
func term(_ turtle: String) -> ObjectTerm {
    let document = """
        PREFIX ex: <http://example.com/>
        PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
        PREFIX sh: <http://www.w3.org/ns/shacl#>
        <urn:x-test:s> <urn:x-test:p> \(turtle) .
        """
    // The fixtures' terms are written by hand and always decode.
    return try! TurtleDecoder().decode(document)[0].object
}

/// The RDF terms Turtle objects spell, as ``term(_:)`` reads them.
func terms(_ turtle: String...) -> Set<ObjectTerm> {
    Set(turtle.map(term))
}

/// The path of a predicate a Turtle object spells.
func predicate(_ turtle: String) -> SHACLPropertyPath {
    .predicate(term(turtle).iri!)
}
