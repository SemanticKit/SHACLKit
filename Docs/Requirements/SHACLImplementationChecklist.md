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
  - Added implicit class targeting for node shapes declared as `rdfs:Class`.
  - Added transitive `rdfs:subClassOf` expansion for implicit class targeting.
- [x] `REQ-SHACL-003` Evaluate node shapes and property shapes against RDF terms/triples.
  - Implemented target-to-focus-node resolution over parsed RDF triples.
  - Implemented node/property evaluation path for `sh:minCount` and `sh:maxCount`.
  - Implemented node-shape-level `sh:class` and `sh:nodeKind` checks on focus nodes.
  - Implemented node-shape `sh:closed` enforcement with optional `sh:ignoredProperties`.
  - Implemented `sh:deactivated` skip behavior for deactivated node/property shapes.
  - Implemented SHACL Core property path evaluation subset (`predicate`, `inverse`, `sequence`, `alternative`, `zeroOrMore`, `oneOrMore`, `zeroOrOne`).
- [x] `REQ-SHACL-004` Support SHACL severity levels and result reporting model.
- [x] `REQ-SHACL-005` Generate deterministic validation reports (conforms + detailed results).
  - Added configurable conformance severity policy (`conformanceDisallowedSeverities`) to support `sh:conforms` behavior across warning/info-inclusive and violation-only report modes.
- [x] `REQ-SHACL-006` Constraint components: cardinality (`sh:minCount`, `sh:maxCount`).
- [x] `REQ-SHACL-007` Constraint components: value type checks (`sh:class`, `sh:datatype`, `sh:nodeKind`).
  - Implemented `sh:class` checks for property values.
  - Implemented `sh:datatype` checks with literal datatype inference (`xsd:integer`, typed literals).
  - Added datatype lexical/range validity enforcement for key XSD datatypes (including `xsd:byte` ill-formed literal handling).
  - Implemented `sh:nodeKind` checks (`sh:IRI`, `sh:Literal`, `sh:BlankNode`, `sh:BlankNodeOrIRI`, `sh:BlankNodeOrLiteral`, `sh:IRIOrLiteral`).
- [x] `REQ-SHACL-008` Constraint components: value range/string facets (`sh:minLength`, `sh:maxLength`, `sh:pattern`, `sh:minInclusive`, `sh:maxInclusive`, `sh:minExclusive`, `sh:maxExclusive`).
  - Implemented string facets: `sh:minLength`, `sh:maxLength`, `sh:pattern`.
  - Implemented range facets for numeric literals and first-slice `xsd:dateTime` comparability: `sh:minInclusive`, `sh:maxInclusive`, `sh:minExclusive`, `sh:maxExclusive`.
- [x] `REQ-SHACL-009` Constraint components: set membership (`sh:in`, `sh:hasValue`).
  - Implemented `sh:hasValue` checks.
  - Implemented `sh:in` checks for direct values and RDF collection list syntax.
  - Implemented `sh:languageIn` checks over literal language tags with basic language-range matching.
  - Implemented first-slice property-pair constraints: `sh:equals`, `sh:disjoint`, `sh:lessThan`, and `sh:lessThanOrEquals`.
  - Implemented `sh:uniqueLang` enforcement for duplicate language-tagged property values.
- [x] `REQ-SHACL-010` Constraint components: logical composition (`sh:and`, `sh:or`, `sh:not`, `sh:xone`).
  - Implemented for property-shape values using direct shape references and RDF list syntax.
- [x] `REQ-SHACL-011` Constraint components: shape references (`sh:node`, `sh:property`, qualified value shape family).
  - Implemented `sh:node` evaluation for referenced node shapes.
  - Implemented `sh:property` linked property-shape evaluation and reference diagnostics.
  - Implemented property-shape-to-property-shape nesting (`sh:property` on property shapes) for value-node traversal.
  - Implemented qualified value shape counts (`sh:qualifiedValueShape`, `sh:qualifiedMinCount`, `sh:qualifiedMaxCount`) with first-slice `sh:qualifiedValueShapesDisjoint`.
- [x] `REQ-SHACL-012` Enforce recursion/termination safeguards for cyclic shapes.
- [x] `REQ-SHACL-013` Emit stable machine-readable diagnostics (focus node, path, value, source shape, source constraint).
  - Implemented: `focusNode`, `pathIRI`, `valueNode`, `shapeIRI` (source shape), and `sourceConstraintIRI` on validation results.
- [x] `REQ-SHACL-014` Keep execution side-effect free (pure validation result model).

## Phase 2: Node Expressions and Rules

- [~] `REQ-SHACL-200` Implement SHACL 1.2 Node Expressions evaluation model.
  - Implemented subset evaluator for `sh:union` and `sh:intersection`, including nested expressions and `sh:this`.
  - Added synthesized RDF-list-backed node-expression definitions for list-head blank nodes used as expression terms.
  - Implemented first-slice `shnex:nodes`, `shnex:exists`, `shnex:count`, `shnex:var`, `shnex:distinct`, `shnex:instancesOf`, `shnex:nodesMatching`, `shnex:matchAll`, `shnex:filterShape`, `shnex:concat`, `shnex:remove`, `shnex:flatMap`, `shnex:limit`, `shnex:offset`, `shnex:findFirst`, `shnex:orderBy` (with `shnex:desc`), `shnex:min`, `shnex:max`, and `shnex:sum`.
  - Added ordered-evaluation API for node expressions to preserve manifest-defined ordering/cardinality where applicable.
  - Added evaluator-level scoped variable bindings for `shnex:var` while preserving `focusNode` fallback behavior.
  - Implemented first-slice `shnex:if` / `shnex:then` / `shnex:else`.
  - Implemented first-slice `shnex:pathValues` with optional `shnex:focusNode` expression chaining.
- [~] `REQ-SHACL-201` Integrate node expression evaluation into constraints/targets where applicable.
  - Integrated subset into property-shape evaluation via `sh:expression` as a value source.
  - Added shape-graph validation for missing/unknown node-expression references.
  - Added direct literal acceptance for decimal `sh:expression` terms during shape-graph reference validation.
  - Added `sh:expression` constraint evaluation for node shapes and path-backed property shapes.
  - Added target resolution support for `sh:targetNode` values that reference node-expression definitions.
  - Added first-slice `sh:nodeByExpression` support for node-shape and property-shape conformance checks.
- [~] `REQ-SHACL-210` Implement SHACL 1.2 Rules execution model.
  - Implemented first-slice `sh:TripleRule` support (`sh:rule`, `sh:condition`, `sh:subject`, `sh:predicate`, `sh:object`).
  - Added `sh:condition` support for both node-shape and property-shape condition references.
  - Rules execute against resolved focus nodes and feed generated triples back into validation.
- [~] `REQ-SHACL-211` Define deterministic rule execution order/termination behavior.
  - Implemented deterministic ordering by shape IRI, focus node, `sh:order` (default `0`), and rule IRI.
  - Added bounded fixpoint iteration with stop-on-no-growth semantics.

## Phase 3: SHACL SPARQL Extensions

- [~] `REQ-SHACL-300` Implement SHACL SPARQL-based constraints.
  - Added first-slice parsing and execution hooks for `sh:sparql` constraints (`sh:select`/`sh:ask`) through an explicit executor boundary.
  - Added first-slice execution for property-shape `sh:sparql` constraints against resolved property values.
  - Added execution for directly targeted property-shape `sh:sparql` constraints.
  - Added recursive execution for nested property-shape `sh:sparql` constraints.
  - Added `sh:message` parsing/propagation for SPARQL constraint violations on node and property shapes.
- [~] `REQ-SHACL-301` Implement SHACL SPARQL targets.
  - Added first-slice parsing and focus-node resolution hooks for `sh:target` with `sh:select` through an explicit executor boundary.
  - Added first-slice support for `sh:targetNode` values backed by inline `sh:select` resources.
  - Added shape-graph validation for property-shape SPARQL targets requiring `sh:select`.
  - Added first-slice execution for directly targeted property-shape SPARQL targets.
  - Added shape-graph validation for `sh:targetNode` SPARQL resources requiring `sh:select`.
  - Removed loader gating for `sh:prefixes` so SPARQL shape definitions with prefix declarations load through validation paths.
- [~] `REQ-SHACL-302` Sandboxed/controlled query execution boundary for SPARQL extension evaluation.
  - Added `SHACLSPARQLExecutor` protocol with default-deny executor (`SHACLDeniedSPARQLExecutor`) requiring explicit opt-in for SPARQL evaluation.
  - Added `SHACLGuardedSPARQLExecutor` wrapper with keyword and query-length policy enforcement before delegating to a backing executor.
  - Expanded default guarded policy coverage to block `MINUS`, `VALUES`, and rebinding of pre-bound SHACL variables (`?this`, `?path`, `?value`).
  - Added guarded policy enforcement requiring `SELECT` queries to reference pre-bound `?this`.

## Integration Boundaries

- [x] `REQ-SHACL-100` Accept RDF data/shapes via package-level graph abstractions (no UI/network coupling).
- [x] `REQ-SHACL-101` Provide adapter boundary for RDFKit/SemanticKit graph representations.
  - Added adapter protocols, type-erased adapter wrappers, and adapter-driven validation entrypoint for external graph sources.
- [x] `REQ-SHACL-102` Keep advanced features gated by explicit phase completion and test baselines.
