# SHACL Tests Checklist (SHACLKitTests)

Legend:
- `[ ]` not implemented
- `[~]` partially implemented
- `[x]` implemented

## Test Infrastructure

- [x] `TEST-SHACL-000` Create test target and fixtures directory (`SHACLKitTests/Fixtures`).
- [ ] `TEST-SHACL-001` Add canonical SHACL Core fixture corpus copied from Knowledge master set.
- [ ] `TEST-SHACL-002` Add helper loaders for data graph + shapes graph fixture pairs.

## Core Behavior Tests

- [ ] `TEST-SHACL-010` Target selection tests for all core target selectors.
- [ ] `TEST-SHACL-011` Node shape validation pass/fail matrix.
- [ ] `TEST-SHACL-012` Property shape validation pass/fail matrix.
- [ ] `TEST-SHACL-013` Severity propagation tests (`Violation`, `Warning`, `Info`).
- [ ] `TEST-SHACL-014` Report model shape and deterministic ordering assertions.

## Constraint Component Coverage

- [ ] `TEST-SHACL-020` Cardinality component tests.
- [ ] `TEST-SHACL-021` Type constraint tests (`class`, `datatype`, `nodeKind`).
- [ ] `TEST-SHACL-022` String/range facet tests.
- [ ] `TEST-SHACL-023` Membership/value constraint tests (`in`, `hasValue`).
- [ ] `TEST-SHACL-024` Logical constraint tests (`and`, `or`, `not`, `xone`).
- [ ] `TEST-SHACL-025` Shape-reference and qualified shape tests.

## Robustness and Regression

- [ ] `TEST-SHACL-030` Recursion/cycle guard tests.
- [ ] `TEST-SHACL-031` Invalid shapes graph diagnostics tests.
- [ ] `TEST-SHACL-032` Large graph smoke test for baseline performance.
- [ ] `TEST-SHACL-033` Regression suite for previously fixed defects.
