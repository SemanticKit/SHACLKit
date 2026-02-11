# SHACL Implementation Checklist (SHACLKit)

Legend:
- `[ ]` not implemented
- `[~]` partially implemented
- `[x]` implemented

## Source Coverage

- [x] `SRC-SHACL-CORE-1.2` SHACL 1.2 Core (source ingested)
- [x] `SRC-SHACL-NODEEXP-1.2` SHACL 1.2 Node Expressions (source ingested)
- [x] `SRC-SHACL-RULES-1.2` SHACL 1.2 Rules (source ingested)
- [x] `SRC-SHACL-SPARQL-EXT-1.2` SHACL 1.2 SPARQL Extensions (source ingested)
- [x] `SRC-SHACL-1.0` Shapes Constraint Language (SHACL) baseline source ingested
- [x] `SRC-SHACL-TEST-REPORT` SHACL Test Suite and Implementation Report (source ingested)

## Phase 1: Core Scope (In Progress)

- [x] `REQ-SHACL-000` Create standalone Swift package library (`SHACLKit`) with source/tests/docs scaffolding.
- [x] `REQ-SHACL-001` Parse/ingest SHACL shapes graph terms required for Core constraints.
- [x] `REQ-SHACL-002` Resolve targets (`sh:targetClass`, `sh:targetNode`, `sh:targetSubjectsOf`, `sh:targetObjectsOf`).
- [~] `REQ-SHACL-003` Evaluate node shapes and property shapes against RDF terms/triples.
  - Implemented target-to-focus-node resolution over parsed RDF triples.
  - Implemented node/property evaluation path for `sh:minCount` and `sh:maxCount`.
- [x] `REQ-SHACL-004` Support SHACL severity levels and result reporting model.
- [x] `REQ-SHACL-005` Generate deterministic validation reports (conforms + detailed results).
- [~] `REQ-SHACL-006` Constraint components: cardinality (`sh:minCount`, `sh:maxCount`).
- [~] `REQ-SHACL-007` Constraint components: value type checks (`sh:class`, `sh:datatype`, `sh:nodeKind`).
  - Implemented `sh:class` checks for property values.
  - Implemented `sh:datatype` checks with literal datatype inference (`xsd:integer`, typed literals).
  - Implemented subset `sh:nodeKind` checks (`sh:IRI`, `sh:Literal`, `sh:BlankNode`, `sh:IRIOrLiteral`).
- [~] `REQ-SHACL-008` Constraint components: value range/string facets (`sh:minLength`, `sh:maxLength`, `sh:pattern`, `sh:minInclusive`, `sh:maxInclusive`).
  - Implemented string facets: `sh:minLength`, `sh:maxLength`, `sh:pattern`.
- [~] `REQ-SHACL-009` Constraint components: set membership (`sh:in`, `sh:hasValue`).
  - Implemented `sh:hasValue` checks.
  - Implemented subset `sh:in` checks using direct object-list syntax.
- [ ] `REQ-SHACL-010` Constraint components: logical composition (`sh:and`, `sh:or`, `sh:not`, `sh:xone`).
- [~] `REQ-SHACL-011` Constraint components: shape references (`sh:node`, `sh:property`, qualified value shape family).
  - Implemented subset `sh:node` evaluation for referenced node shapes.
- [x] `REQ-SHACL-012` Enforce recursion/termination safeguards for cyclic shapes.
- [~] `REQ-SHACL-013` Emit stable machine-readable diagnostics (focus node, path, value, source shape, source constraint).
  - Implemented: `focusNode`, `pathIRI`, `valueNode`, `shapeIRI` (source shape), and `sourceConstraintIRI` on validation results.
- [ ] `REQ-SHACL-014` Keep execution side-effect free (pure validation result model).

## Phase 2: Node Expressions and Rules

- [ ] `REQ-SHACL-200` Implement SHACL 1.2 Node Expressions evaluation model.
- [ ] `REQ-SHACL-201` Integrate node expression evaluation into constraints/targets where applicable.
- [ ] `REQ-SHACL-210` Implement SHACL 1.2 Rules execution model.
- [ ] `REQ-SHACL-211` Define deterministic rule execution order/termination behavior.

## Phase 3: SHACL SPARQL Extensions

- [ ] `REQ-SHACL-300` Implement SHACL SPARQL-based constraints.
- [ ] `REQ-SHACL-301` Implement SHACL SPARQL targets.
- [ ] `REQ-SHACL-302` Sandboxed/controlled query execution boundary for SPARQL extension evaluation.

## Integration Boundaries

- [ ] `REQ-SHACL-100` Accept RDF data/shapes via package-level graph abstractions (no UI/network coupling).
- [ ] `REQ-SHACL-101` Provide adapter boundary for RDFKit/SemanticKit graph representations.
- [ ] `REQ-SHACL-102` Keep advanced features gated by explicit phase completion and test baselines.
