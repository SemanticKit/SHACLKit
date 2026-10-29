#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SWIFT="${SWIFT:-swift}"

LOG_DIR="${REPO_ROOT}/.build/test-shards"
mkdir -p "${LOG_DIR}"
MODE="parallel"

for arg in "$@"; do
  case "${arg}" in
    --parallel|--auto)
      MODE="parallel"
      ;;
    --sequential)
      MODE="sequential"
      ;;
    *)
      echo "Usage: ${0} [--parallel|--sequential]" >&2
      echo "  --parallel (default, alias --auto): run the shards at once, each in its own scratch path" >&2
      echo "  --sequential: run the shards one after another" >&2
      exit 1
      ;;
  esac
done

# Each shard builds into its own scratch path so parallel shards never share a build directory.
run_shard() {
  local name="$1"
  shift
  local filters=("$@")

  local filter_pattern
  filter_pattern="$(IFS='|'; echo "${filters[*]}")"
  echo "[shard:${name}] ${SWIFT} test --filter ${filter_pattern}"

  (
    cd "${REPO_ROOT}"
    "${SWIFT}" test --scratch-path "${REPO_ROOT}/.build/shard-${name}" --filter "${filter_pattern}"
  ) >"${LOG_DIR}/${name}.log" 2>&1
}

run_parallel() {
  run_shard core coreValidator &
  local pid_core=$!
  run_shard expr nodeExpressionEvaluator shapesLoaderParses focusNodeResolver &
  local pid_expr=$!
  run_shard w3c w3c &
  local pid_w3c=$!

  local fail=0
  local pid
  for pid in "${pid_core}" "${pid_expr}" "${pid_w3c}"; do
    if ! wait "${pid}"; then
      fail=1
    fi
  done
  return "${fail}"
}

run_sequential() {
  # Collect failures explicitly: this function runs as an `if` condition,
  # where bash ignores `set -e`, so a failing shard must not be masked.
  local fail=0
  run_shard core coreValidator || fail=1
  run_shard expr nodeExpressionEvaluator shapesLoaderParses focusNodeResolver || fail=1
  run_shard w3c w3c || fail=1
  return "${fail}"
}

if [[ "${MODE}" == "sequential" ]]; then
  if run_sequential; then
    echo "[sharded] all shards passed sequentially. Logs: ${LOG_DIR}"
    exit 0
  fi
  echo "[sharded] a shard failed. Logs: ${LOG_DIR}" >&2
  exit 1
fi

if run_parallel; then
  echo "[sharded] all shards passed in parallel. Logs: ${LOG_DIR}"
  exit 0
fi
echo "[sharded] one or more shards failed. Logs: ${LOG_DIR}" >&2
exit 1
