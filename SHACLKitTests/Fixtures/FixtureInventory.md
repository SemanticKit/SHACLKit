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
- Invalid shapes graph diagnostics
- Regression and smoke scenarios
- Rules (`sh:TripleRule`) first-slice execution scenarios
- SPARQL extension first-slice scenarios (`sh:sparql` constraints, `sh:target` selectors, sandbox boundary)
- Optional staged W3C conformance corpus sync target (`W3CDataShapes*` from `Knowledge/Inbox/Fixtures` into `SHACLKitTests/Fixtures/W3CDataShapes`)
  - Includes preflight parser/loader coverage across W3C SHACL 1.2 `node-expr/shnex/*.ttl` fixtures.
