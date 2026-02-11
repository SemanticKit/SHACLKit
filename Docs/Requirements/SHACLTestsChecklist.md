# SHACL Tests Checklist (SHACLKitTests)

Legend:
- `[ ]` not implemented
- `[~]` partially implemented
- `[x]` implemented

## Test Infrastructure

- [x] `TEST-SHACL-000` Create test target and fixtures directory (`SHACLKitTests/Fixtures`).
- [x] `TEST-SHACL-001` Add canonical SHACL Core fixture corpus copied from Knowledge master set.
  - Canonical fixtures now live in `Knowledge/SHACL/Fixtures` and sync via `Scripts/SyncFixturesFromKnowledge.sh`.
- [x] `TEST-SHACL-003` Add curated W3C fixture-pack sync target for conformance expansion.
  - Optional corpus sync now materializes under `SHACLKitTests/Fixtures/W3CDataShapes` from newest `Knowledge/Inbox/Fixtures/W3CDataShapes*`.
  - Added smoke coverage asserting curated fixture availability in the test bundle.
  - Added curated conformance subset harness with explicit per-case expectations and SemanticKit parser preflight for fixture ingestion.
  - Added W3C-aligned coverage for node-shape datatype/string/range/`hasValue`/`in` cases plus implicit class targeting behavior.
- [x] `TEST-SHACL-002` Add helper loaders for data graph + shapes graph fixture pairs.

## Phase 1: Core Behavior Tests

- [x] `TEST-SHACL-010` Target selection tests for all core target selectors.
  - Added coverage for `sh:targetNode` selectors backed by node-expression definitions.
  - Added coverage for `sh:targetNode` selectors backed by `shnex:nodes`.
  - Added coverage for `sh:targetNode` selectors backed by `shnex:pathValues` + explicit `shnex:focusNode`.
  - Added regression coverage ensuring empty target outputs are ignored, including empty `shnex:nodes ()`.
  - Added curated W3C core target selector subset coverage (`targetNode`, `targetClass`, implicit `targetClass`, `targetSubjectsOf`, `targetObjectsOf`, `multipleTargets`).
  - Added curated W3C core path conformance subset coverage (inverse/alternative/sequence and cardinality path operators).
- [x] `TEST-SHACL-015` Focus-node resolution tests over RDF triples for single and multi-shape target sets.
- [x] `TEST-SHACL-011` Node shape validation pass/fail matrix.
  - Covered node-shape-level `sh:class` and `sh:nodeKind` pass/fail fixtures with matrix assertions.
  - Added curated W3C node-shape conformance subset coverage for `closed-001` and `closed-002`.
  - Added curated W3C complex conformance subset coverage for `personexample` and `shacl-shacl`.
- [x] `TEST-SHACL-012` Property shape validation pass/fail matrix.
  - Covered fixture matrix assertions across implemented property-shape constraint components.
  - Added curated W3C node-shape conformance subset coverage for property-pair constraints (`equals-001`, `disjoint-001`).
  - Added curated W3C property-shape conformance subset coverage for property-pair constraints (`lessThan-001`, `lessThan-002`, `lessThanOrEquals-001`).
  - Expanded curated W3C property-shape conformance subset coverage across cardinality, type, string/range, logical, shape-reference, and nested `sh:property` cases.
- [x] `TEST-SHACL-013` Severity propagation tests (`Violation`, `Warning`, `Info`).
  - Added curated W3C misc conformance subset coverage for severity/message/deactivated behavior (`severity-001`, `severity-002`, `message-001`, `deactivated-001`, `deactivated-002`).
- [x] `TEST-SHACL-014` Report model shape and deterministic ordering assertions.

## Phase 1: Constraint Component Coverage

- [x] `TEST-SHACL-020` Cardinality component tests.
- [x] `TEST-SHACL-021` Type constraint tests (`class`, `datatype`, `nodeKind`).
  - Covered `class`, `datatype`, and all `nodeKind` fixtures.
  - Added curated W3C node-shape conformance subset coverage for `datatype-002`, `class-002`, and `class-003`.
  - Added curated W3C property-shape ill-formed datatype coverage (`datatype-ill-formed`) for lexical/range validation.
- [x] `TEST-SHACL-022` String/range facet tests.
  - Covered `minLength`, `maxLength`, and `pattern` fixtures.
  - Added curated W3C node-shape conformance subset coverage for dateTime range boundaries (`minInclusive-002`, `minInclusive-003`).
  - Added curated W3C node-shape conformance subset coverage for exclusive numeric bounds (`minExclusive-001`, `maxExclusive-001`).
  - Added curated W3C node-shape conformance subset coverage for `pattern-002`.
  - Covered integer range fixtures for `minInclusive` and `maxInclusive`, including non-numeric values.
- [x] `TEST-SHACL-023` Membership/value constraint tests (`in`, `hasValue`).
  - Covered `hasValue` and `in` fixtures, including RDF list-based `sh:in`.
  - Added curated W3C node-shape conformance subset coverage for `languageIn-001`.
  - Added curated W3C property-shape conformance subset coverage for `uniqueLang-001` and `uniqueLang-002`.
- [x] `TEST-SHACL-024` Logical constraint tests (`and`, `or`, `not`, `xone`).
  - Covered fixtures for `and`, `or`, `not`, and `xone` across direct shape references and RDF list syntax.
  - Added curated W3C node-shape logical conformance subset coverage (`and-001`, `and-002`, `or-001`, `not-001`, `not-002`, `xone-001`, `xone-duplicate`).
- [x] `TEST-SHACL-025` Shape-reference and qualified shape tests.
  - Covered `sh:node` fixtures, qualified value shape count fixtures, and invalid reference diagnostics.
  - Added curated W3C node-shape conformance subset coverage for `class-001`, `node-001`, and `qualified-001`.
  - Added curated W3C property-shape qualified disjoint coverage (`qualifiedMinCountDisjoint-001`, `qualifiedValueShapesDisjoint-001`).

## Phase 2: Node Expressions and Rules

- [~] `TEST-SHACL-200` Node expression conformance fixtures.
  - Added fixtures/tests for `sh:union` and `sh:intersection` subset evaluation, nesting, and cycle handling.
  - Added fixture coverage for bare Turtle boolean literals in node-expression members.
  - Added fixtures/tests for `shnex:nodes`, `shnex:exists`, and `shnex:count`.
  - Added fixtures/tests for `shnex:if` / `shnex:then` / `shnex:else`.
  - Added fixtures/tests for `shnex:pathValues` with nested `shnex:focusNode` expression chaining.
  - Added fixtures/tests for property-shape `sh:expression` value derivation (conforming and violation cases).
  - Added invalid-shapes diagnostic coverage for unknown node-expression references.
  - Added fixtures/tests for `sh:expression` constraints on node shapes and path-backed property shapes.
  - Added fixtures/tests for first-slice `sh:nodeByExpression` behavior on node and property shapes.
- [~] `TEST-SHACL-210` Rule evaluation fixtures (order, repeatability, termination).
  - Added `sh:TripleRule` fixtures and tests covering rule parsing, execution, repeatability, and self-loop termination behavior.
  - Added fixtures/tests proving all `sh:condition` entries must conform before triple-rule emission.

## Phase 3: SHACL SPARQL Extensions

- [~] `TEST-SHACL-300` SPARQL constraint fixtures.
  - Added first-slice fixture/tests for `sh:sparql` + (`sh:select`, `sh:ask`) constraint execution through an injected executor boundary.
- [~] `TEST-SHACL-301` SPARQL target fixtures.
  - Added first-slice fixture/tests for `sh:target` + `sh:select` focus-node resolution through an injected executor boundary.
- [~] `TEST-SHACL-302` SPARQL extension sandbox/guard behavior tests.
  - Added default-deny executor behavior test coverage proving SPARQL evaluation requires explicit sandboxed executor injection for both `sh:select` and `sh:ask`.

## Robustness and Regression

- [x] `TEST-SHACL-030` Recursion/cycle guard tests.
- [x] `TEST-SHACL-031` Invalid shapes graph diagnostics tests.
  - Covered missing `sh:path`, missing referenced property shape, missing referenced node shape, missing referenced node expression, and missing `sh:nodeByExpression` reference failures.
  - Added coverage for missing `sh:node` references on node shapes.
- [x] `TEST-SHACL-032` Large graph smoke test for baseline performance.
- [x] `TEST-SHACL-033` Regression suite for previously fixed defects.
  - Added deterministic regression coverage for prior cycle/severity behavior.
  - Added consolidated regression checks for phase-gating, qualified counts, and non-numeric range handling.
