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
TIMING_FILE=""
ENFORCE_BUDGET="0"
BUDGET_BASELINE=""
BUDGET_MULTIPLIER=""
BUDGET_ABSOLUTE_BUFFER=""
TIMING_FILE_IS_TEMP="0"

run_timed() {
  local label="$1"
  shift
  local started_at=$SECONDS
  "$@"
  local elapsed=$((SECONDS - started_at))
  echo "[timing] ${label}: ${elapsed}s"
  if [[ -n "${TIMING_FILE}" ]]; then
    printf '%s\t%s\n' "${label}" "${elapsed}" >> "${TIMING_FILE}"
  fi
}
while [[ "$#" -gt 0 ]]; do
  arg="$1"
  case "${arg}" in
    --sharded)
      MODE="sharded"
      shift
      ;;
    --full)
      MODE="full"
      shift
      ;;
    --changed)
      GATE_MODE="changed"
      shift
      ;;
    --fast)
      GATE_MODE="fast"
      shift
      ;;
    --skip-linux-smoke)
      RUN_LINUX_SMOKE="0"
      shift
      ;;
    --linux-smoke)
      RUN_LINUX_SMOKE="1"
      shift
      ;;
    --timing-file)
      if [[ "$#" -lt 2 ]]; then
        echo "error: --timing-file requires a path" >&2
        exit 1
      fi
      TIMING_FILE="$2"
      shift 2
      ;;
    --enforce-budget)
      ENFORCE_BUDGET="1"
      shift
      ;;
    --budget-baseline)
      if [[ "$#" -lt 2 ]]; then
        echo "error: --budget-baseline requires a path" >&2
        exit 1
      fi
      BUDGET_BASELINE="$2"
      shift 2
      ;;
    --budget-multiplier)
      if [[ "$#" -lt 2 ]]; then
        echo "error: --budget-multiplier requires a numeric value" >&2
        exit 1
      fi
      BUDGET_MULTIPLIER="$2"
      shift 2
      ;;
    --budget-absolute-buffer)
      if [[ "$#" -lt 2 ]]; then
        echo "error: --budget-absolute-buffer requires a numeric value" >&2
        exit 1
      fi
      BUDGET_ABSOLUTE_BUFFER="$2"
      shift 2
      ;;
    *)
      echo "Usage: ${0} [--full|--sharded] [--fast|--changed] [--linux-smoke|--skip-linux-smoke]" >&2
      echo "  --sharded: fast gate + sharded validation (with shard-level fallback)" >&2
      echo "  --full: fast gate + full legacy suite" >&2
      echo "  --changed: changed-area gate instead of fast gate" >&2
      echo "  --skip-linux-smoke: skip Linux smoke pass between gate and full validation" >&2
      echo "  --timing-file <path>: append tab-separated timing rows (label, elapsed-seconds)" >&2
      echo "  --enforce-budget: validate timings against performance baseline after cycle completes" >&2
      echo "  --budget-baseline <path>: baseline TSV path for budget enforcement" >&2
      echo "  --budget-multiplier <value>: baseline multiplier override for budget enforcement" >&2
      echo "  --budget-absolute-buffer <seconds>: absolute seconds buffer override for budget enforcement" >&2
      exit 1
      ;;
  esac
done

if [[ "${ENFORCE_BUDGET}" == "1" ]] && [[ -z "${TIMING_FILE}" ]]; then
  TIMING_FILE="$(mktemp)"
  TIMING_FILE_IS_TEMP="1"
fi

if [[ -n "${TIMING_FILE}" ]]; then
  mkdir -p "$(dirname "${TIMING_FILE}")"
  : > "${TIMING_FILE}"
fi

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

if [[ "${ENFORCE_BUDGET}" == "1" ]]; then
  CHECK_SCRIPT="${SCRIPT_DIR}/CheckPerformanceBudget.sh"
  if [[ ! -x "${CHECK_SCRIPT}" ]]; then
    echo "error: missing executable budget checker at ${CHECK_SCRIPT}" >&2
    exit 1
  fi
  CHECK_CMD=("${CHECK_SCRIPT}" "--timing-file" "${TIMING_FILE}")
  if [[ -n "${BUDGET_BASELINE}" ]]; then
    CHECK_CMD+=("--baseline" "${BUDGET_BASELINE}")
  fi
  if [[ -n "${BUDGET_MULTIPLIER}" ]]; then
    CHECK_CMD+=("--multiplier" "${BUDGET_MULTIPLIER}")
  fi
  if [[ -n "${BUDGET_ABSOLUTE_BUFFER}" ]]; then
    CHECK_CMD+=("--absolute-buffer" "${BUDGET_ABSOLUTE_BUFFER}")
  fi
  "${CHECK_CMD[@]}"
fi

if [[ "${TIMING_FILE_IS_TEMP}" == "1" ]]; then
  rm -f "${TIMING_FILE}"
fi
