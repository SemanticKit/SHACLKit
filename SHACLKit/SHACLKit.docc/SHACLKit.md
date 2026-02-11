# ``SHACLKit``

SHACL parsing and validation toolkit for RDF graphs.

## Overview

SHACLKit is a Swift package framework focused on Shapes Constraint Language (SHACL) validation. It is scoped to sit above RDF data model/IO layers and provide deterministic, testable conformance checks.

Requirements are tracked in:
- `Docs/Requirements/SHACL-Implementation-Checklist.md`
- `Docs/Requirements/SHACL-Tests-Checklist.md`

## Usage Sketch

```swift
let validator = SHACLCoreValidator()
let result = try validator.validate(dataGraph: dataGraph, shapesGraph: shapesGraph)
print(result.conforms)
```
