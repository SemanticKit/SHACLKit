# SHACL Tests Checklist (SHACLKitTests)

Legend:
- `[ ]` not implemented
- `[~]` partially implemented
- `[x]` implemented

## Test Infrastructure

- [x] `TEST-SHACL-000` Create test target and fixtures directory (`Tests/SHACLKitTests/Fixtures`).
- [x] `TEST-SHACL-001` Add canonical SHACL Core fixture corpus.
  - The canonical fixtures live in this repository under `Tests/SHACLKitTests/Fixtures`.
- [x] `TEST-SHACL-003` Add curated W3C fixture-pack sync target for conformance expansion.
  - The curated W3C corpus lives under `Tests/SHACLKitTests/Fixtures/W3CDataShapes`, imported from https://github.com/w3c/data-shapes (see its `SourceInventory.md`).
  - Added smoke coverage asserting curated fixture availability in the test bundle.
  - Added curated conformance subset harness with explicit per-case expectations.
  - Added W3C-aligned coverage for node-shape datatype/string/range/`hasValue`/`in` cases plus implicit class targeting behavior.
- [x] `TEST-SHACL-002` Add helper loaders for data graph + shapes graph fixture pairs.
- [x] `TEST-SHACL-004` Add speed-cycle test runners for fast gate and sharded execution.
  - Added `Scripts/RunFastConformanceGate.sh` (targeted high-signal conformance checks).
  - Added `Scripts/RunShardedTests.sh` (parallel `core` / `expr` / `w3c` shards, each with its own SwiftPM scratch path).
  - Added `Scripts/RunBatchCycle.sh` to enforce batched workflow (`fast gate` + one final full or sharded pass).

## Phase 1: Core Behavior Tests

- [x] `TEST-SHACL-010` Target selection tests for all core target selectors.
  - Added coverage for `sh:targetNode` selectors backed by node-expression definitions.
  - Added coverage for `sh:targetNode` selectors backed by `shnex:nodes`.
  - Added coverage for `sh:targetNode` selectors backed by `shnex:pathValues` + explicit `shnex:focusNode`.
  - Added SHACL 1.2 `sh:targetWhere` fixture coverage to verify target-shape-filtered focus-node resolution.
  - Added SHACL 1.2 `sh:ShapeClass` implicit targeting coverage (`targetClassImplicit-002`).
  - Added SHACL 1.2 `sh:shape` selector coverage (`shape-001`) for data-driven shape targeting.
  - Added regression coverage ensuring empty target outputs are ignored, including empty `shnex:nodes ()`.
  - Added curated W3C core target selector subset coverage (`targetNode`, `targetClass`, implicit `targetClass`, `targetSubjectsOf`, `targetObjectsOf`, `multipleTargets`).
  - Added curated W3C core path conformance subset coverage (inverse/alternative/sequence and cardinality path operators).
  - Expanded curated SHACL 1.2 core path conformance subset coverage, including wrapper + split data/shapes cases for `path-complex-002` and `path-unused-001`.
- [x] `TEST-SHACL-015` Focus-node resolution tests over RDF triples for single and multi-shape target sets.
- [x] `TEST-SHACL-011` Node shape validation pass/fail matrix.
  - Covered node-shape-level `sh:class` and `sh:nodeKind` pass/fail fixtures with matrix assertions.
  - Added curated W3C node-shape conformance subset coverage for `closed-001` and `closed-002`.
  - Expanded curated SHACL 1.2 node-shape conformance subset coverage for `closed-001` and `closed-002`.
  - Expanded curated SHACL 1.2 node-shape conformance subset coverage for conforming `closed-003` and `closed-004`.
  - Expanded curated SHACL 1.2 complex conformance subset coverage for `personexample` and `shacl-shacl`.
  - Expanded curated SHACL 1.2 SHACL-for-SHACL direct graph coverage for `shacl-shacl-data-shapes`.
  - Added curated W3C complex conformance subset coverage for `personexample` and `shacl-shacl`.
- [x] `TEST-SHACL-012` Property shape validation pass/fail matrix.
  - Covered fixture matrix assertions across implemented property-shape constraint components.
  - Added curated W3C node-shape conformance subset coverage for property-pair constraints (`equals-001`, `disjoint-001`).
  - Expanded curated SHACL 1.2 node-shape conformance subset coverage for property-pair constraints (`equals-001`, `disjoint-001`).
  - Added curated W3C property-shape conformance subset coverage for property-pair constraints (`lessThan-001`, `lessThan-002`, `lessThanOrEquals-001`).
  - Expanded curated W3C property-shape conformance subset coverage across cardinality, type, string/range, logical, shape-reference, and nested `sh:property` cases.
- [x] `TEST-SHACL-013` Severity propagation tests (`Violation`, `Warning`, `Info`).
  - Added curated W3C misc conformance subset coverage for severity/message/deactivated behavior (`severity-001`, `severity-002`, `message-001`, `deactivated-001`, `deactivated-002`).
  - Expanded curated SHACL 1.2 misc conformance subset coverage for `message-001`, `severity-001/002`, and `deactivated-001/002`.
  - Added curated W3C validation-report conformance policy coverage for `conformance-disallows-001` / `conformance-disallows-002`.
- [x] `TEST-SHACL-014` Report model shape and deterministic ordering assertions.
  - Expanded curated SHACL 1.2 validation-report coverage for shared nested property-shape reporting (`shared-data/shared-shapes` and wrapper `shared.ttl`).

## Phase 1: Constraint Component Coverage

- [x] `TEST-SHACL-020` Cardinality component tests.
- [x] `TEST-SHACL-021` Type constraint tests (`class`, `datatype`, `nodeKind`).
  - Covered `class`, `datatype`, and all `nodeKind` fixtures.
  - Added curated W3C node-shape conformance subset coverage for `nodeKind-002` (RDF-list `sh:nodeKind` form).
  - Added curated W3C node-shape conformance subset coverage for `class-001`, `datatype-001`, and `nodeKind-001`.
  - Added curated W3C node-shape conformance subset coverage for `datatype-002`, `class-002`, and `class-003`.
  - Added curated W3C property-shape ill-formed datatype coverage (`datatype-ill-formed`) for lexical/range validation.
- [x] `TEST-SHACL-022` String/range facet tests.
  - Covered `minLength`, `maxLength`, and `pattern` fixtures.
  - Added fixture/test coverage for SHACL 1.2 `sh:singleLine`, including `false` no-op behavior.
  - Added curated W3C property-shape conformance subset coverage for `singleLine-001` after parser triple-quoted literal support.
  - Added curated W3C node-shape conformance subset coverage for dateTime range boundaries (`minInclusive-002`, `minInclusive-003`).
  - Added curated W3C node-shape conformance subset coverage for exclusive numeric bounds (`minExclusive-001`, `maxExclusive-001`).
  - Added curated W3C node-shape conformance subset coverage for `pattern-002`.
  - Expanded curated SHACL 1.2 node-shape conformance subset coverage for `minLength-001`, `maxLength-001`, `pattern-001`, `pattern-002`, `minExclusive-001`, `maxExclusive-001`, `maxInclusive-001`, and `minInclusive-001/002/003`.
  - Covered integer range fixtures for `minInclusive` and `maxInclusive`, including non-numeric values.
- [x] `TEST-SHACL-023` Membership/value constraint tests (`in`, `hasValue`).
  - Covered `hasValue` and `in` fixtures, including RDF list-based `sh:in`.
  - Added curated W3C node-shape conformance subset coverage for `hasValue-001` and `in-001`.
  - Added curated W3C property-shape conformance subset coverage for SHACL 1.2 `someValue-001`.
  - Added curated W3C property-shape conformance subset coverage for SHACL 1.2 `memberShape-001`.
  - Added curated W3C property-shape conformance subset coverage for SHACL 1.2 `uniqueMembers-001`.
  - Added curated W3C property-shape conformance subset coverage for SHACL 1.2 `minListLength-001` and `maxListLength-001`.
  - Added curated W3C property-shape conformance subset coverage for SHACL 1.2 `reifierShape-001` and `reifierShape-002`.
  - Added curated W3C node-shape conformance subset coverage for `languageIn-001`.
  - Added curated W3C property-shape conformance subset coverage for `uniqueLang-001` and `uniqueLang-002`.
- [x] `TEST-SHACL-024` Logical constraint tests (`and`, `or`, `not`, `xone`).
  - Covered fixtures for `and`, `or`, `not`, and `xone` across direct shape references and RDF list syntax.
  - Added curated W3C node-shape logical conformance subset coverage (`and-001`, `and-002`, `or-001`, `not-001`, `not-002`, `xone-001`, `xone-duplicate`).
  - Expanded curated SHACL 1.2 node-shape logical conformance subset coverage for `and-001`, `and-002`, `or-001`, `not-001`, `not-002`, `xone-001`, and `xone-duplicate`.
  - Expanded curated SHACL 1.2 node-shape split data/shapes coverage for `xone-duplicate-data` + `xone-duplicate-shapes`.
- [x] `TEST-SHACL-025` Shape-reference and qualified shape tests.
  - Covered `sh:node` fixtures, qualified value shape count fixtures, and invalid reference diagnostics.
  - Added curated W3C node-shape conformance subset coverage for `class-001`, `node-001`, and `qualified-001`.
  - Expanded curated SHACL 1.2 node-shape conformance subset coverage for `node-001` and `qualified-001`.
  - Expanded curated SHACL 1.2 node-shape wrapper-manifest coverage for `qualified-001`.
  - Added curated W3C property-shape qualified disjoint coverage (`qualifiedMinCountDisjoint-001`, `qualifiedValueShapesDisjoint-001`).

## Phase 2: Node Expressions and Rules

- [x] `TEST-SHACL-200` Node expression conformance fixtures.
  - Added fixtures/tests for `sh:union` and `sh:intersection` subset evaluation, nesting, and cycle handling.
  - Added fixture coverage for bare Turtle boolean literals in node-expression members.
  - Added W3C SHACL 1.2 `node-expr/shnex` fixture preflight coverage through the SHACLKit data/shapes graph loaders.
  - Added W3C SHACL 1.2 `sht:EvalNodeExpr` manifest-evaluation subset harness (ordered and multiset comparison modes).
  - Expanded W3C manifest-evaluation subset to include `constant.ttl`, `empty.ttl`, and `list.ttl`.
  - Expanded W3C manifest-evaluation subset to include `filterShape.ttl` and `intersection.ttl`.
  - Added fixture/test coverage for evaluator-scoped `shnex:var` bindings (`focusNode`, bound variable, and unbound variable behavior).
  - Added fixtures/tests for `shnex:nodes`, `shnex:exists`, `shnex:count`, `shnex:var`, `shnex:distinct`, `shnex:instancesOf`, `shnex:nodesMatching`, `shnex:matchAll`, `shnex:filterShape`, `shnex:concat`, `shnex:remove`, `shnex:flatMap`, `shnex:limit`, `shnex:offset`, `shnex:findFirst`, `shnex:orderBy` (with `shnex:desc`), `shnex:min`, `shnex:max`, and `shnex:sum`.
  - Added fixtures/tests for `shnex:if` / `shnex:then` / `shnex:else`.
  - Added fixtures/tests for `shnex:pathValues` with nested `shnex:focusNode` expression chaining.
  - Added fixtures/tests for property-shape `sh:expression` value derivation (conforming and violation cases).
  - Added invalid-shapes diagnostic coverage for unknown node-expression references.
  - Added fixtures/tests for `sh:expression` constraints on node shapes and path-backed property shapes.
  - Added fixtures/tests for first-slice `sh:nodeByExpression` behavior on node and property shapes.
  - Expanded curated SHACL 1.2 node-shape conformance subset coverage for `nodeByExpression-001`.
  - Added fixture/test coverage for decimal literal `sh:expression` terms to ensure shape-graph validation treats them as direct literals.
- [x] `TEST-SHACL-210` Rule evaluation fixtures (order, repeatability, termination).
  - Added `sh:TripleRule` fixtures and tests covering rule parsing, execution, repeatability, and self-loop termination behavior.
  - Added `sh:order` parsing/execution ordering coverage for triple rules.
  - Added fixtures/tests proving all `sh:condition` entries must conform before triple-rule emission.
  - Added fixtures/tests for property-shape `sh:condition` gating behavior.
  - Added SHACL 1.2 rules `eval` data/result TTL preflight coverage through SHACLKit graph loaders.
  - Rules preflight now includes negation result fixtures after single-quoted literal parser support.
  - Added SHACL 1.2 rules manifest preflight coverage for `manifest-rules.ttl` and nested rules manifests (`eval`, `stratification`, `syntax`, `wellformed`) through the SHACLKit graph loaders.
  - Added rules eval manifest artifact-resolution checks ensuring each `srt:RulesEvalTest` entry references existing ruleset/data/result files.
  - Added rules syntax/wellformed/stratification manifest artifact checks ensuring all referenced `.srl` ruleset files exist.
  - Added manifest-driven `.srl` preflight conformance checks asserting positive/negative expectations across `syntax`, `wellformed`, and `stratification` suites.

## Phase 3: SHACL SPARQL Extensions

- [x] `TEST-SHACL-300` SPARQL constraint fixtures.
  - Added first-slice fixture/tests for `sh:sparql` + (`sh:select`, `sh:ask`) constraint execution through an injected executor boundary.
  - Added first-slice fixture/tests for property-shape `sh:sparql` constraint execution through the same executor boundary.
  - Added first-slice fixture/tests for directly targeted property-shape `sh:sparql` constraints.
  - Added first-slice fixture/tests for nested property-shape `sh:sparql` constraints.
  - Added fixture/tests for SPARQL `sh:message` propagation on node-shape and property-shape violations.
  - Added fixture/tests proving `sh:prefixes` declarations are applied to executor-bound SPARQL query text (prefix lines injected at runtime).
  - Added regression fixture/test proving runtime prefix injection does not duplicate prefixes already declared inline in query text.
  - Added regression fixture/test proving runtime prefix injection order is deterministic (sorted by prefix label).
  - Added regression fixture/test proving runtime prefix injection still occurs when query string literals contain `prefix <label>:` text that is not an actual `PREFIX` directive.
  - Added fixture/tests for default-prefix (`sh:prefix ""`) declarations on SPARQL constraints to verify runtime `PREFIX : <...>` injection.
  - Added regression fixture/test proving runtime injection does not duplicate already-inline default-prefix (`PREFIX :`) declarations.
  - Added W3C SHACL 1.2 SPARQL suite parser/data-loader preflight coverage across `sparql/{component,node,property,pre-binding,targets}` fixture trees.
  - Added executor-backed W3C SPARQL conformance subset validation coverage (`node/sparql-001`, `pre-binding/pre-binding-001`).
- [x] `TEST-SHACL-301` SPARQL target fixtures.
  - Added first-slice fixture/tests for `sh:target` + `sh:select` focus-node resolution through an injected executor boundary.
  - Added first-slice fixture/tests for `sh:targetNode` + inline `sh:select` focus-node resolution through the same executor boundary.
  - Added first-slice fixture/tests for directly targeted property-shape SPARQL targets.
  - Added first-slice fixture/tests for directly targeted property-shape `sh:targetNode` inline `sh:select` targets.
  - Added fixture/tests proving target-query `sh:prefixes` declarations are applied to executor-bound `sh:select` text.
  - Added fixture/test coverage proving SPARQL constraints with `sh:prefixes` declarations are accepted by loader/validator paths and flow through executor-bound query text.
  - Added fixture/tests for default-prefix (`sh:prefix ""`) declarations on SPARQL targets to verify runtime `PREFIX : <...>` injection.
  - Added regression fixture/test proving runtime injection does not duplicate already-inline default-prefix (`PREFIX :`) declarations on SPARQL targets.
  - Added recursive SPARQL manifest artifact-resolution checks validating `mf:include` trees and `sht:dataGraph`/`sht:shapesGraph` references resolve to existing local fixture artifacts.
  - Added executor-backed W3C SPARQL target conformance subset validation coverage (`targets/targetNode-select-001`).
- [x] `TEST-SHACL-302` SPARQL extension sandbox/guard behavior tests.
  - Added default-deny executor behavior test coverage proving SPARQL evaluation requires explicit sandboxed executor injection for both `sh:select` and `sh:ask`.
  - Added guarded-executor policy coverage for keyword blocking, query-length blocking, and allowed-query pass-through behavior.
  - Added guarded-policy coverage for blocking `MINUS`, `VALUES`, and rebinding of pre-bound SHACL variables (`?this`, `?path`, `?value`).
  - Added guarded-policy coverage requiring `SELECT` query text to reference pre-bound `?this`/`$this`, while allowing `ASK` constraints without explicit `this` references.
  - Added guarded-policy regression coverage proving disallowed keywords inside string literals are not blocked as executable keywords.
  - Added guarded-policy regression coverage proving disallowed keywords inside line comments are not blocked as executable keywords.
  - Added guarded-policy regression coverage proving string-literal `'?this'` text does not satisfy required pre-bound `?this` reference checks.
  - Added guarded-policy regression coverage proving line-comment `?this` text does not satisfy required pre-bound `?this` reference checks.
  - Added guarded-policy regression coverage proving string-literal `'?path'` and `'?value'` text does not trigger pre-bound rebind blocking.
  - Added guarded-policy regression coverage proving line-comment `AS ?path` and `AS ?value` text does not trigger pre-bound rebind blocking.
  - Added guarded-policy regression coverage proving line-comment `AS $path` and `AS $value` text does not trigger pre-bound rebind blocking.
  - Added guarded-policy coverage for `$this` pre-bound variable parity (`$this` accepted as required pre-bound reference, and `AS $this` blocked as rebinding).
  - Added guarded-policy coverage for `AS $path` and `AS $value` rebinding blocks alongside existing `?path`/`?value` coverage.

## Robustness and Regression

- [x] `TEST-SHACL-030` Recursion/cycle guard tests.
- [x] `TEST-SHACL-031` Invalid shapes graph diagnostics tests.
  - Covered missing `sh:path`, missing referenced property shape, missing referenced node shape, missing referenced node expression, and missing `sh:nodeByExpression` reference failures.
  - Added coverage for missing `sh:node` references on node shapes.
  - Added coverage for property-shape SPARQL targets missing required `sh:select`.
  - Added coverage for `sh:targetNode` resources that resolve to SPARQL targets missing required `sh:select`.
- [x] `TEST-SHACL-032` Large graph smoke test for baseline performance.
- [x] `TEST-SHACL-033` Regression suite for previously fixed defects.
  - Added deterministic regression coverage for prior cycle/severity behavior.
  - Added consolidated regression checks for phase-gating, qualified counts, and non-numeric range handling.
