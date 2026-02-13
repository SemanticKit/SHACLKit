#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OUTPUT="${SCRIPT_DIR}/../Docs/Requirements/PerformanceBaseline.tsv"
RUNS=3
OUTPUT_PATH="${DEFAULT_OUTPUT}"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --runs)
      if [[ "$#" -lt 2 ]]; then
        echo "error: --runs requires a numeric value" >&2
        exit 1
      fi
      RUNS="$2"
      shift 2
      ;;
    --output)
      if [[ "$#" -lt 2 ]]; then
        echo "error: --output requires a file path" >&2
        exit 1
      fi
      OUTPUT_PATH="$2"
      shift 2
      ;;
    *)
      echo "Usage: ${0} [--runs <count>] [--output <path>]" >&2
      exit 1
      ;;
  esac
done

if ! [[ "${RUNS}" =~ ^[0-9]+$ ]] || [[ "${RUNS}" -lt 1 ]]; then
  echo "error: --runs must be a positive integer" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

echo "[perf-baseline] collecting ${RUNS} run(s) via layered cycle..."
for run in $(seq 1 "${RUNS}"); do
  timing_file="${TMP_DIR}/run-${run}.tsv"
  echo "[perf-baseline] run ${run}/${RUNS}"
  "${SCRIPT_DIR}/RunBatchCycle.sh" --sharded --fast --timing-file "${timing_file}"
done

mkdir -p "$(dirname "${OUTPUT_PATH}")"
{
  echo "# SHACLKit timing baseline"
  echo "# generated_at_utc: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "# mode: RunBatchCycle --sharded --fast"
  echo -e "# label\tmedian_seconds\truns"
} > "${OUTPUT_PATH}"

cat "${TMP_DIR}"/run-*.tsv \
  | awk -F '\t' '
{
  label = $1
  value = $2 + 0
  counts[label]++
  values[label, counts[label]] = value
}
END {
  for (label in counts) {
    n = counts[label]
    for (i = 1; i <= n; i++) {
      sorted[i] = values[label, i]
    }
    for (i = 1; i <= n; i++) {
      for (j = i + 1; j <= n; j++) {
        if (sorted[i] > sorted[j]) {
          tmp = sorted[i]
          sorted[i] = sorted[j]
          sorted[j] = tmp
        }
      }
    }
    if (n % 2 == 1) {
      median = sorted[(n + 1) / 2]
    } else {
      median = (sorted[n / 2] + sorted[n / 2 + 1]) / 2
    }
    printf "%s\t%.3f\t%d\n", label, median, n
    delete sorted
  }
}' \
  | sort >> "${OUTPUT_PATH}"

echo "[perf-baseline] wrote baseline: ${OUTPUT_PATH}"
