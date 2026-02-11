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
- Node expressions (`union`, `intersection`, `shnex:nodes`, `shnex:exists`, `shnex:count`, `shnex:min`, `shnex:max`, `shnex:if`, `shnex:pathValues`)
- Severity/report diagnostics
- Invalid shapes graph diagnostics
- Regression and smoke scenarios
- Rules (`sh:TripleRule`) first-slice execution scenarios
- SPARQL extension first-slice scenarios (`sh:sparql` constraints, `sh:target` selectors, sandbox boundary)
- Optional staged W3C conformance corpus sync target (`W3CDataShapes*` from `Knowledge/Inbox/Fixtures` into `SHACLKitTests/Fixtures/W3CDataShapes`)
