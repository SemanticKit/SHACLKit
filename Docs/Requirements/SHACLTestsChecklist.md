# SHACL Tests Checklist (SHACLKitTests)

Legend:
- `[ ]` not implemented
- `[~]` partially implemented
- `[x]` implemented

## Test Infrastructure

- [x] `TEST-SHACL-000` Create test target and fixtures directory (`SHACLKitTests/Fixtures`).
- [x] `TEST-SHACL-001` Add canonical SHACL Core fixture corpus copied from Knowledge master set.
  - Canonical fixtures now live in `Knowledge/SHACL/Fixtures` and sync via `Scripts/SyncFixturesFromKnowledge.sh`.
- [x] `TEST-SHACL-002` Add helper loaders for data graph + shapes graph fixture pairs.

## Phase 1: Core Behavior Tests

- [x] `TEST-SHACL-010` Target selection tests for all core target selectors.
  - Added coverage for `sh:targetNode` selectors backed by node-expression definitions.
  - Added regression coverage ensuring empty target outputs are ignored.
- [x] `TEST-SHACL-015` Focus-node resolution tests over RDF triples for single and multi-shape target sets.
- [x] `TEST-SHACL-011` Node shape validation pass/fail matrix.
  - Covered node-shape-level `sh:class` and `sh:nodeKind` pass/fail fixtures with matrix assertions.
- [x] `TEST-SHACL-012` Property shape validation pass/fail matrix.
  - Covered fixture matrix assertions across implemented property-shape constraint components.
- [x] `TEST-SHACL-013` Severity propagation tests (`Violation`, `Warning`, `Info`).
- [x] `TEST-SHACL-014` Report model shape and deterministic ordering assertions.

## Phase 1: Constraint Component Coverage

- [x] `TEST-SHACL-020` Cardinality component tests.
- [x] `TEST-SHACL-021` Type constraint tests (`class`, `datatype`, `nodeKind`).
  - Covered `class`, `datatype`, and all `nodeKind` fixtures.
- [x] `TEST-SHACL-022` String/range facet tests.
  - Covered `minLength`, `maxLength`, and `pattern` fixtures.
  - Covered integer range fixtures for `minInclusive` and `maxInclusive`, including non-numeric values.
- [x] `TEST-SHACL-023` Membership/value constraint tests (`in`, `hasValue`).
  - Covered `hasValue` and `in` fixtures, including RDF list-based `sh:in`.
- [x] `TEST-SHACL-024` Logical constraint tests (`and`, `or`, `not`, `xone`).
  - Covered fixtures for `and`, `or`, `not`, and `xone` across direct shape references and RDF list syntax.
- [x] `TEST-SHACL-025` Shape-reference and qualified shape tests.
  - Covered `sh:node` fixtures, qualified value shape count fixtures, and invalid reference diagnostics.

## Phase 2: Node Expressions and Rules

- [~] `TEST-SHACL-200` Node expression conformance fixtures.
  - Added fixtures/tests for `sh:union` and `sh:intersection` subset evaluation, nesting, and cycle handling.
  - Added fixture coverage for bare Turtle boolean literals in node-expression members.
  - Added fixtures/tests for property-shape `sh:expression` value derivation (conforming and violation cases).
  - Added invalid-shapes diagnostic coverage for unknown node-expression references.
  - Added fixtures/tests for `sh:expression` constraints on node shapes and path-backed property shapes.
  - Added fixtures/tests for first-slice `sh:nodeByExpression` behavior on node and property shapes.
- [~] `TEST-SHACL-210` Rule evaluation fixtures (order, repeatability, termination).
  - Added `sh:TripleRule` fixtures and tests covering rule parsing, execution, repeatability, and self-loop termination behavior.

## Phase 3: SHACL SPARQL Extensions

- [~] `TEST-SHACL-300` SPARQL constraint fixtures.
  - Added first-slice fixture/tests for `sh:sparql` + `sh:select` constraint execution through an injected executor boundary.
- [~] `TEST-SHACL-301` SPARQL target fixtures.
  - Added first-slice fixture/tests for `sh:target` + `sh:select` focus-node resolution through an injected executor boundary.
- [~] `TEST-SHACL-302` SPARQL extension sandbox/guard behavior tests.
  - Added default-deny executor behavior test coverage proving SPARQL evaluation requires explicit sandboxed executor injection.

## Robustness and Regression

- [x] `TEST-SHACL-030` Recursion/cycle guard tests.
- [x] `TEST-SHACL-031` Invalid shapes graph diagnostics tests.
  - Covered missing `sh:path`, missing referenced property shape, missing referenced node shape, missing referenced node expression, and missing `sh:nodeByExpression` reference failures.
- [x] `TEST-SHACL-032` Large graph smoke test for baseline performance.
- [x] `TEST-SHACL-033` Regression suite for previously fixed defects.
  - Added deterministic regression coverage for prior cycle/severity behavior.
  - Added consolidated regression checks for phase-gating, qualified counts, and non-numeric range handling.
