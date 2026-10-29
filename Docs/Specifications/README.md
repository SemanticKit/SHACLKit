# SHACL Specifications

SHACLKit follows the W3C SHACL documents below. Each one is published by the W3C Data Shapes Working Group from the [w3c/data-shapes](https://github.com/w3c/data-shapes) repository.

## Source Inventory

- `SRC-SHACL-CORE-1.2` [SHACL 1.2 Core](https://www.w3.org/TR/shacl12-core/)
- `SRC-SHACL-NODEEXP-1.2` [SHACL 1.2 Node Expressions](https://www.w3.org/TR/shacl12-node-expr/)
- `SRC-SHACL-RULES-1.2` [SHACL 1.2 Inference Rules](https://www.w3.org/TR/shacl12-inference-rules/)
- `SRC-SHACL-SPARQL-EXT-1.2` [SHACL 1.2 SPARQL-Related Features](https://www.w3.org/TR/shacl12-sparql/)
- `SRC-SHACL-1.0` [Shapes Constraint Language (SHACL)](https://www.w3.org/TR/shacl/)
- `SRC-SHACL-TEST-REPORT` [SHACL Test Suite and Implementation Report](https://w3c.github.io/data-shapes/data-shapes-test-suite/)

The test suites themselves are vendored as fixtures under `Tests/SHACLKitTests/Fixtures/W3CDataShapes` (see `SourceInventory.md` there).

## Scope for SHACLKit

- Phase 1: SHACL Core validation engine and deterministic report model.
- Phase 2: Node Expressions and Rules.
- Phase 3: SHACL SPARQL extensions (after Core conformance baseline is stable).

Tracking documents:

- `Docs/Requirements/SHACLImplementationChecklist.md`
- `Docs/Requirements/SHACLTestsChecklist.md`
