# Fixture Inventory

This directory contains SHACLKit test fixtures grouped by constraint family.

Sync source of truth:
- Canonical inbox path: `./Knowledge/SHACL/Fixtures`
- Sync command: `./Scripts/SyncFixturesFromKnowledge.sh`

Current local families:
- Targets and focus resolution
- Cardinality
- Type constraints (`class`, `datatype`, `nodeKind`)
- String and range facets
- Membership/value constraints (`hasValue`, `in` direct/list)
- Logical constraints (`and`, `or`, `not`, `xone` direct/list)
- Shape references (`node`, qualified value shape counts)
- Node expressions (`union`, `intersection`, `shnex:nodes`, `shnex:exists`, `shnex:count`, `shnex:var`, `shnex:distinct`, `shnex:instancesOf`, `shnex:nodesMatching`, `shnex:matchAll`, `shnex:filterShape`, `shnex:concat`, `shnex:remove`, `shnex:flatMap`, `shnex:limit`, `shnex:offset`, `shnex:findFirst`, `shnex:orderBy`, `shnex:desc`, `shnex:min`, `shnex:max`, `shnex:sum`, `shnex:if`, `shnex:pathValues`)
- Severity/report diagnostics
  - Includes W3C validation-report `conformanceDisallows` policy scenarios.
- Invalid shapes graph diagnostics
- Regression and smoke scenarios
- Rules (`sh:TripleRule`) first-slice execution scenarios
  - Includes node-shape/property-shape `sh:condition` gating and `sh:order` fixtures.
- SPARQL extension first-slice scenarios (`sh:sparql` constraints, `sh:target` selectors, sandbox boundary)
  - Includes guarded-executor policy fixtures for blocked keyword queries.
  - Includes property-shape `sh:sparql` constraint fixtures.
  - Includes directly targeted property-shape `sh:sparql` constraint fixtures.
  - Includes nested property-shape `sh:sparql` constraint fixtures.
  - Includes `sh:targetNode` inline `sh:select` target fixtures.
  - Includes directly targeted property-shape SPARQL target fixtures.
  - Includes directly targeted property-shape `sh:targetNode` inline `sh:select` fixtures.
  - Includes prefix-injection regressions for inline-prefix deduplication and deterministic multi-prefix ordering.
  - Includes prefix-injection regression where string literals contain `prefix` markers.
  - Includes default-prefix (`sh:prefix ""`) injection fixtures for both SPARQL constraints and SPARQL targets.
- Optional staged W3C conformance corpus sync target (`W3CDataShapes*` from `Knowledge/Inbox/Fixtures` into `SHACLKitTests/Fixtures/W3CDataShapes`)
  - Includes preflight parser/loader coverage across W3C SHACL 1.2 `node-expr/shnex/*.ttl` fixtures.
  - Includes subset `sht:EvalNodeExpr` manifest-result verification for W3C SHACL 1.2 `node-expr/shnex` fixtures.
