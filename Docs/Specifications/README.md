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

## Vocabularies

The SHACL vocabulary is not written by hand: the `SHACL` and `SHNEX` targets translate the documents the Working Group publishes into Swift on every build, with RDFKit's `RDFTranslatorPlugin`. Each document is stored byte for byte as its source gives it.

| File | Source | sha256 |
|---|---|---|
| `Sources/SHACL/shacl.ttl` | [`shacl12-vocabularies/shacl.ttl`](https://github.com/w3c/data-shapes/blob/a6ed26f7385d6e03eeb8441d72d3c172d27657c7/shacl12-vocabularies/shacl.ttl) in github.com/w3c/data-shapes at commit a6ed26f (2026-10-25) | `f210919274934710e9bef6b59b2409df4fe7cdaff25b5708e428e3e186763857` |
| `Sources/SHNEX/shnex.ttl` | [`shacl12-vocabularies/shnex.ttl`](https://github.com/w3c/data-shapes/blob/a6ed26f7385d6e03eeb8441d72d3c172d27657c7/shacl12-vocabularies/shnex.ttl) in github.com/w3c/data-shapes at commit a6ed26f (2026-10-25) | `c4e5d7706e00685d6e9139855627d800215d3bb9aa657f23b529da12ada5bee3` |
