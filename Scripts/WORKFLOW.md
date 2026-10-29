# SHACLKit Test Workflow

Run these scripts from anywhere; each one changes to the repository root before it calls SwiftPM.
They call `swift` from `PATH`. Set `SWIFT` to use another toolchain driver, for example `SWIFT=/path/to/swift ./Scripts/RunLegacyFull.sh`.

## 1) Legacy Full (stable baseline)
Use this when you want a single authoritative result with minimal orchestration.

Command:
```bash
./Scripts/RunLegacyFull.sh
```

Behavior:
- Runs `swift test` at the repository root
- Full suite only

## 2) Layered Cycle (fast + fallback)
Use this for active development cycles where faster feedback is needed.

Command (recommended):
```bash
./Scripts/RunLayeredCycle.sh --sharded
```

Behavior:
1. Changed-area gate (filters chosen from the diff against `origin/main` plus uncommitted changes; falls back to the fast gate)
2. Sharded validation (`core`, `expr`, `w3c`), each shard in its own `--scratch-path` so they can build in parallel
3. Batch runner emits per-step wall-time (`[timing] ...`) for cycle speed tracking

Optional modes:
```bash
./Scripts/RunBatchCycle.sh --full
./Scripts/RunBatchCycle.sh --sharded --changed
./Scripts/RunBatchCycle.sh --sharded --fast
./Scripts/RunShardedTests.sh --parallel
./Scripts/RunShardedTests.sh --sequential
./Scripts/RunChangedAreaGate.sh [<base-ref>]
./Scripts/ReportW3CPropertyGaps.sh
```

## Quick recommendations
- During feature work: use layered mode.
- Before release/merge gates: run legacy full mode.
- If layered mode fails at fast gate: fix there before running full suite.

## Logs
Sharded logs are written to:
- `.build/test-shards/`

## Coverage Planning
Generate an up-to-date report of uncurated SHACL 1.2 property fixtures and parser-blocked cases:
```bash
./Scripts/ReportW3CPropertyGaps.sh
```
