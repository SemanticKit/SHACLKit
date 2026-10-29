#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FULL="${SCRIPT_DIR}/RunLegacyFull.sh"
FAST_GATE="${SCRIPT_DIR}/RunFastConformanceGate.sh"
CHANGED_GATE="${SCRIPT_DIR}/RunChangedAreaGate.sh"
SHARDED="${SCRIPT_DIR}/RunShardedTests.sh"

MODE="full"
GATE_MODE="fast"

run_timed() {
  local label="$1"
  shift
  local started_at=$SECONDS
  "$@"
  local elapsed=$((SECONDS - started_at))
  echo "[timing] ${label}: ${elapsed}s"
}
for arg in "$@"; do
  case "${arg}" in
    --sharded)
      MODE="sharded"
      ;;
    --full)
      MODE="full"
      ;;
    --changed)
      GATE_MODE="changed"
      ;;
    --fast)
      GATE_MODE="fast"
      ;;
    *)
      echo "Usage: ${0} [--full|--sharded] [--fast|--changed]" >&2
      echo "  --sharded: fast gate + sharded validation (with shard-level fallback)" >&2
      echo "  --full: fast gate + full legacy suite" >&2
      echo "  --changed: changed-area gate instead of fast gate" >&2
      exit 1
      ;;
  esac
done

if [[ "${GATE_MODE}" == "changed" ]]; then
  echo "[batch-cycle] step 1/2: changed-area gate"
  run_timed "step1-changed-gate" "${CHANGED_GATE}"
else
  echo "[batch-cycle] step 1/2: fast conformance gate"
  run_timed "step1-fast-gate" "${FAST_GATE}"
fi

echo "[batch-cycle] step 2/2: validation mode = ${MODE}"
if [[ "${MODE}" == "sharded" ]]; then
  run_timed "step2-sharded" "${SHARDED}"
else
  run_timed "step2-full" "${FULL}"
fi

echo "[batch-cycle] complete"
