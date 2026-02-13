#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_BASELINE="${SCRIPT_DIR}/../Docs/Requirements/PerformanceBaseline.tsv"
BASELINE_PATH="${DEFAULT_BASELINE}"
MULTIPLIER="1.75"
ABSOLUTE_BUFFER_SECONDS="2"
TIMING_FILE=""
RUN_MODE="auto"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --baseline)
      if [[ "$#" -lt 2 ]]; then
        echo "error: --baseline requires a file path" >&2
        exit 1
      fi
      BASELINE_PATH="$2"
      shift 2
      ;;
    --multiplier)
      if [[ "$#" -lt 2 ]]; then
        echo "error: --multiplier requires a numeric value" >&2
        exit 1
      fi
      MULTIPLIER="$2"
      shift 2
      ;;
    --absolute-buffer)
      if [[ "$#" -lt 2 ]]; then
        echo "error: --absolute-buffer requires a numeric value" >&2
        exit 1
      fi
      ABSOLUTE_BUFFER_SECONDS="$2"
      shift 2
      ;;
    --timing-file)
      if [[ "$#" -lt 2 ]]; then
        echo "error: --timing-file requires a file path" >&2
        exit 1
      fi
      TIMING_FILE="$2"
      RUN_MODE="external"
      shift 2
      ;;
    --run)
      RUN_MODE="auto"
      shift
      ;;
    *)
      echo "Usage: ${0} [--baseline <path>] [--multiplier <value>] [--absolute-buffer <seconds>] [--timing-file <path>] [--run]" >&2
      exit 1
      ;;
  esac
done

if [[ ! -f "${BASELINE_PATH}" ]]; then
  echo "error: baseline file not found at ${BASELINE_PATH}" >&2
  exit 1
fi

if [[ "${RUN_MODE}" == "auto" ]]; then
  TIMING_FILE="$(mktemp)"
  trap 'rm -f "${TIMING_FILE}"' EXIT
  echo "[perf-budget] collecting current timings via layered cycle..."
  "${SCRIPT_DIR}/RunBatchCycle.sh" --sharded --fast --timing-file "${TIMING_FILE}"
fi

if [[ ! -s "${TIMING_FILE}" ]]; then
  echo "error: timing data is empty (${TIMING_FILE})" >&2
  exit 1
fi

python3 - "$BASELINE_PATH" "$TIMING_FILE" "$MULTIPLIER" "$ABSOLUTE_BUFFER_SECONDS" <<'PY'
import sys

baseline_path, timing_path, multiplier_text, absolute_buffer_text = sys.argv[1:5]
multiplier = float(multiplier_text)
absolute_buffer = float(absolute_buffer_text)

baseline = {}
with open(baseline_path, "r", encoding="utf-8") as f:
    for raw in f:
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split("\t")
        if len(parts) < 2:
            continue
        baseline[parts[0]] = float(parts[1])

actual = {}
with open(timing_path, "r", encoding="utf-8") as f:
    for raw in f:
        line = raw.strip()
        if not line:
            continue
        parts = line.split("\t")
        if len(parts) < 2:
            continue
        actual[parts[0]] = float(parts[1])

missing = sorted(k for k in baseline if k not in actual)
if missing:
    print("[perf-budget] FAIL: missing timing labels: " + ", ".join(missing))
    sys.exit(1)

failures = []
for label, baseline_seconds in sorted(baseline.items()):
    elapsed = actual[label]
    max_allowed = baseline_seconds * multiplier + absolute_buffer
    if elapsed > max_allowed:
        failures.append((label, elapsed, max_allowed, baseline_seconds))

for label, baseline_seconds in sorted(baseline.items()):
    elapsed = actual[label]
    max_allowed = baseline_seconds * multiplier + absolute_buffer
    print(
        f"[perf-budget] {label}: elapsed={elapsed:.3f}s baseline={baseline_seconds:.3f}s max={max_allowed:.3f}s"
    )

if failures:
    print("[perf-budget] FAIL: timing budget exceeded")
    for label, elapsed, max_allowed, baseline_seconds in failures:
        print(
            f"  {label}: elapsed {elapsed:.3f}s > max {max_allowed:.3f}s (baseline {baseline_seconds:.3f}s)"
        )
    sys.exit(1)

print("[perf-budget] PASS: all timing budgets satisfied")
PY
