#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
CONTAINER_TASK="${WORKSPACE_ROOT}/Scripts/ContainerTask.sh"
FAST_GATE="${SCRIPT_DIR}/RunFastConformanceGate.sh"
LINUX_SMOKE="${SCRIPT_DIR}/RunLinuxSmoke.sh"
CHANGED_GATE="${SCRIPT_DIR}/RunChangedAreaGate.sh"
SHARDED="${SCRIPT_DIR}/RunShardedTests.sh"

MODE="full"
GATE_MODE="fast"
RUN_LINUX_SMOKE="1"

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
    --skip-linux-smoke)
      RUN_LINUX_SMOKE="0"
      ;;
    --linux-smoke)
      RUN_LINUX_SMOKE="1"
      ;;
    *)
      echo "Usage: ${0} [--full|--sharded] [--fast|--changed] [--linux-smoke|--skip-linux-smoke]" >&2
      echo "  --sharded: fast gate + sharded validation (with shard-level fallback)" >&2
      echo "  --full: fast gate + full legacy suite" >&2
      echo "  --changed: changed-area gate instead of fast gate" >&2
      echo "  --skip-linux-smoke: skip Linux smoke pass between gate and full validation" >&2
      exit 1
      ;;
  esac
done

if [[ "${GATE_MODE}" == "changed" ]]; then
  echo "[batch-cycle] step 1/3: changed-area gate"
  run_timed "step1-changed-gate" "${CHANGED_GATE}"
else
  echo "[batch-cycle] step 1/3: fast conformance gate"
  run_timed "step1-fast-gate" "${FAST_GATE}"
fi

if [[ "${RUN_LINUX_SMOKE}" == "1" ]]; then
  echo "[batch-cycle] step 2/3: Linux smoke validation"
  run_timed "step2-linux-smoke" "${LINUX_SMOKE}"
else
  echo "[batch-cycle] step 2/3: Linux smoke validation skipped"
fi

echo "[batch-cycle] step 3/3: validation mode = ${MODE}"
if [[ "${MODE}" == "sharded" ]]; then
  run_timed "step3-sharded" "${SHARDED}"
else
  run_timed "step3-full" "${CONTAINER_TASK}" test Frameworks/SHACLKit
fi

echo "[batch-cycle] complete"
