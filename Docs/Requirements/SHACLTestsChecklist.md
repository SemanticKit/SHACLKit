# SHACL Tests Checklist (SHACLKitTests)

Legend:
- `[ ]` not implemented
- `[~]` partially implemented
- `[x]` implemented

## Test Infrastructure

- [x] `TEST-SHACL-000` Create test target and fixtures directory (`SHACLKitTests/Fixtures`).
- [~] `TEST-SHACL-001` Add canonical SHACL Core fixture corpus copied from Knowledge master set.
- [x] `TEST-SHACL-002` Add helper loaders for data graph + shapes graph fixture pairs.

## Phase 1: Core Behavior Tests

- [x] `TEST-SHACL-010` Target selection tests for all core target selectors.
- [x] `TEST-SHACL-015` Focus-node resolution tests over RDF triples for single and multi-shape target sets.
- [~] `TEST-SHACL-011` Node shape validation pass/fail matrix.
  - Covered node-shape-level `sh:class` and `sh:nodeKind` pass/fail fixtures.
- [~] `TEST-SHACL-012` Property shape validation pass/fail matrix.
- [x] `TEST-SHACL-013` Severity propagation tests (`Violation`, `Warning`, `Info`).
- [x] `TEST-SHACL-014` Report model shape and deterministic ordering assertions.

## Phase 1: Constraint Component Coverage

- [x] `TEST-SHACL-020` Cardinality component tests.
- [x] `TEST-SHACL-021` Type constraint tests (`class`, `datatype`, `nodeKind`).
  - Covered `class`, `datatype`, and all `nodeKind` fixtures.
- [x] `TEST-SHACL-022` String/range facet tests.
  - Covered `minLength`, `maxLength`, and `pattern` fixtures.
  - Covered integer range fixtures for `minInclusive` and `maxInclusive`, including non-numeric values.
- [~] `TEST-SHACL-023` Membership/value constraint tests (`in`, `hasValue`).
  - Covered `hasValue` and subset `in` fixtures.
- [~] `TEST-SHACL-024` Logical constraint tests (`and`, `or`, `not`, `xone`).
  - Covered subset fixtures for `and`, `or`, `not`, and `xone` with direct shape-IRI object syntax.
- [~] `TEST-SHACL-025` Shape-reference and qualified shape tests.
  - Covered subset `sh:node` fixture.
  - Covered subset qualified value shape count fixtures.

## Phase 2: Node Expressions and Rules

- [ ] `TEST-SHACL-200` Node expression conformance fixtures.
- [ ] `TEST-SHACL-210` Rule evaluation fixtures (order, repeatability, termination).

## Phase 3: SHACL SPARQL Extensions

- [ ] `TEST-SHACL-300` SPARQL constraint fixtures.
- [ ] `TEST-SHACL-301` SPARQL target fixtures.
- [ ] `TEST-SHACL-302` SPARQL extension sandbox/guard behavior tests.

## Robustness and Regression

- [x] `TEST-SHACL-030` Recursion/cycle guard tests.
- [~] `TEST-SHACL-031` Invalid shapes graph diagnostics tests.
  - Covered missing `sh:path`, missing referenced property shape, and missing referenced node shape failures.
- [x] `TEST-SHACL-032` Large graph smoke test for baseline performance.
- [~] `TEST-SHACL-033` Regression suite for previously fixed defects.
  - Added deterministic regression coverage for prior cycle/severity behavior.
