# SHACLKit Test Workflow

This project supports two execution modes:

## 1) Legacy Full (stable baseline)
Use this when you want a single authoritative result with minimal orchestration.

Command:
```bash
./Frameworks/SHACLKit/Scripts/RunLegacyFull.sh
```

Behavior:
- Runs `./Scripts/ContainerTask.sh test Frameworks/SHACLKit`
- Full suite only

## 2) Layered Cycle (fast + fallback)
Use this for active development cycles where faster feedback is needed.

Command (recommended):
```bash
./Frameworks/SHACLKit/Scripts/RunLayeredCycle.sh --sharded
```

Behavior:
1. Changed-area gate (auto-selected filters from current diff; falls back to fast gate)
2. Linux smoke validation pass through container workflow
3. Sharded validation (`core`, `expr`, `w3c`)
4. Automatic fallback from parallel to sequential shards on hosts where parallel container bootstrap is unsupported
5. Batch runner emits per-step wall-time (`[timing] ...`) for cycle speed tracking

Optional modes:
```bash
./Frameworks/SHACLKit/Scripts/RunBatchCycle.sh --full
./Frameworks/SHACLKit/Scripts/RunBatchCycle.sh --sharded --changed
./Frameworks/SHACLKit/Scripts/RunBatchCycle.sh --sharded --fast
./Frameworks/SHACLKit/Scripts/RunBatchCycle.sh --sharded --skip-linux-smoke
./Frameworks/SHACLKit/Scripts/RunShardedTests.sh --parallel
./Frameworks/SHACLKit/Scripts/RunShardedTests.sh --sequential
./Frameworks/SHACLKit/Scripts/RunShardedTests.sh --auto
./Frameworks/SHACLKit/Scripts/RunChangedAreaGate.sh [<base-ref>]
./Frameworks/SHACLKit/Scripts/RunLinuxSmoke.sh
./Frameworks/SHACLKit/Scripts/ReportW3CPropertyGaps.sh
```

## Quick recommendations
- During feature work: use layered mode.
- Before release/merge gates: run legacy full mode.
- If layered mode fails at fast gate: fix there before running full suite.

## Logs
Sharded logs are written to:
- `Frameworks/SHACLKit/.build/test-shards/`

## Coverage Planning
Generate an up-to-date report of uncurated SHACL 1.2 property fixtures and parser-blocked cases:
```bash
./Frameworks/SHACLKit/Scripts/ReportW3CPropertyGaps.sh
```
