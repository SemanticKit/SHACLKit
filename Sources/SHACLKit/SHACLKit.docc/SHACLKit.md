# ``SHACLKit``

SHACL 1.2 validation of RDFCore graphs, translated from shapes graphs.

## Overview

SHACL is an expression language outside the Swift runtime, so SHACLKit is a
translator. A shapes graph is read with a format's decoder from RDFKit's
`RDFFormats` into an RDFCore `Graph`, and ``SHACLShapesGraph`` decodes it:
each shape node becomes a ``SHACLShape`` object, and the shapes it refers to
are those objects. SHACL's own terms (`sh:minCount`, `sh:Violation`,
`sh:MinCountConstraintComponent`) are declared in the ``SHACL`` ontology's
`var body`. Their IRIs are read only where a shapes graph is decoded and
where a report is written as RDF.

A data graph is an RDFCore `Graph` too: decoded from a document, or made
from an app's typed values by a ``SHACLDataGraphAdapting`` adapter.

```swift
let shapes = try SHACLShapesGraph(TurtleDecoder().decode(shapesTurtle))
let data = try TurtleDecoder().decode(dataTurtle)
let report = try SHACLValidator().validate(data, against: shapes)
report.conforms
report.results.first?.sourceConstraintComponent === SHACL.MinCountConstraintComponent
report.graph // the sh:ValidationReport, as RDF
```

Requirements are tracked in:
- `Docs/Requirements/SHACLImplementationChecklist.md`
- `Docs/Requirements/SHACLTestsChecklist.md`

## Topics

### Validating

- ``SHACLValidator``
- ``SHACLValidationReport``
- ``SHACLValidationResult``

### Shapes

- ``SHACLShapesGraph``
- ``SHACLShape``
- ``SHACLConstraint``
- ``SHACLTarget``
- ``SHACLPropertyPath``
- ``SHACLNodeExpression``
- ``SHACLTripleRule``

### Vocabulary

- ``SHACL``
- ``SHNEX``

### SPARQL

- ``SHACLSPARQLExecutor``
- ``SHACLSPARQLQuery``
- ``SHACLGuardedSPARQLExecutor``
- ``SHACLDeniedSPARQLExecutor``

### Boundary adapters

- ``SHACLDataGraphAdapting``
- ``SHACLShapesGraphAdapting``
- ``AnySHACLDataGraphAdapter``
- ``AnySHACLShapesGraphAdapter``
