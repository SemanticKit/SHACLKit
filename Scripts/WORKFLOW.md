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
2. Sharded validation (`core`, `expr`, `w3c`)
3. Automatic fallback from parallel to sequential shards on hosts where parallel container bootstrap is unsupported
4. Batch runner emits per-step wall-time (`[timing] ...`) for cycle speed tracking

Optional modes:
```bash
./Frameworks/SHACLKit/Scripts/RunBatchCycle.sh --full
./Frameworks/SHACLKit/Scripts/RunBatchCycle.sh --sharded --changed
./Frameworks/SHACLKit/Scripts/RunBatchCycle.sh --sharded --fast
./Frameworks/SHACLKit/Scripts/RunShardedTests.sh --parallel
./Frameworks/SHACLKit/Scripts/RunShardedTests.sh --sequential
./Frameworks/SHACLKit/Scripts/RunShardedTests.sh --auto
./Frameworks/SHACLKit/Scripts/RunChangedAreaGate.sh [<base-ref>]
```

## Quick recommendations
- During feature work: use layered mode.
- Before release/merge gates: run legacy full mode.
- If layered mode fails at fast gate: fix there before running full suite.

## Logs
Sharded logs are written to:
- `Frameworks/SHACLKit/.build/test-shards/`
