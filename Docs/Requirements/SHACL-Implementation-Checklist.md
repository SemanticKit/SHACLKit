# SHACL Implementation Checklist (SHACLKit)

Legend:
- `[ ]` not implemented
- `[~]` partially implemented
- `[x]` implemented

## Source Coverage

- [ ] `SRC-SHACL-SPEC` Shapes Constraint Language (SHACL)
- [ ] `SRC-SHACL-TEST-REPORT` SHACL Test Suite and Implementation Report

## Core Scope

- [x] `REQ-SHACL-000` Create standalone Swift package library (`SHACLKit`) with source/tests/docs scaffolding.
- [ ] `REQ-SHACL-001` Parse/ingest SHACL shapes graph terms required for Core constraints.
- [ ] `REQ-SHACL-002` Resolve targets (`sh:targetClass`, `sh:targetNode`, `sh:targetSubjectsOf`, `sh:targetObjectsOf`).
- [ ] `REQ-SHACL-003` Evaluate node shapes and property shapes against RDF terms/triples.
- [ ] `REQ-SHACL-004` Support SHACL severity levels and result reporting model.
- [ ] `REQ-SHACL-005` Generate deterministic validation reports (conforms + detailed results).
- [ ] `REQ-SHACL-006` Constraint components: cardinality (`sh:minCount`, `sh:maxCount`).
- [ ] `REQ-SHACL-007` Constraint components: value type checks (`sh:class`, `sh:datatype`, `sh:nodeKind`).
- [ ] `REQ-SHACL-008` Constraint components: value range/string facets (`sh:minLength`, `sh:maxLength`, `sh:pattern`, `sh:minInclusive`, `sh:maxInclusive`).
- [ ] `REQ-SHACL-009` Constraint components: set membership (`sh:in`, `sh:hasValue`).
- [ ] `REQ-SHACL-010` Constraint components: logical composition (`sh:and`, `sh:or`, `sh:not`, `sh:xone`).
- [ ] `REQ-SHACL-011` Constraint components: shape references (`sh:node`, `sh:property`, qualified value shape family).
- [ ] `REQ-SHACL-012` Enforce recursion/termination safeguards for cyclic shapes.
- [ ] `REQ-SHACL-013` Emit stable machine-readable diagnostics (focus node, path, value, source shape, source constraint).
- [ ] `REQ-SHACL-014` Keep execution side-effect free (pure validation result model).

## Integration Boundaries

- [ ] `REQ-SHACL-100` Accept RDF data/shapes via package-level graph abstractions (no UI/network coupling).
- [ ] `REQ-SHACL-101` Provide adapter boundary for RDFKit/SemanticKit graph representations.
- [ ] `REQ-SHACL-102` Keep advanced SHACL features (SPARQL-based constraints, SHACL-AF) explicitly out-of-scope until core is complete.
