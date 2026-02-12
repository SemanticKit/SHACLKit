#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
CONTAINER_TASK="${WORKSPACE_ROOT}/Scripts/ContainerTask.sh"

if [[ ! -x "${CONTAINER_TASK}" ]]; then
  echo "error: missing container task script at ${CONTAINER_TASK}" >&2
  exit 1
fi

BUILD_KEY_BASE="${CONTAINERBUILDKEY:-shard}"
LOG_DIR="${WORKSPACE_ROOT}/Frameworks/SHACLKit/.build/test-shards"
mkdir -p "${LOG_DIR}"
MODE="auto"

for arg in "$@"; do
  case "${arg}" in
    --parallel)
      MODE="parallel"
      ;;
    --sequential)
      MODE="sequential"
      ;;
    --auto)
      MODE="auto"
      ;;
    *)
      echo "Usage: ${0} [--auto|--parallel|--sequential]" >&2
      exit 1
      ;;
  esac
done

run_shard() {
  local name="$1"
  local build_key="$2"
  shift 2
  local filters=("$@")

  local cmd=("swift" "test")
  local filter
  for filter in "${filters[@]}"; do
    cmd+=("--filter" "${filter}")
  done

  printf -v test_command '%q ' "${cmd[@]}"
  echo "[shard:${name}] ${test_command}"

  (
    CONTAINERBUILDKEY="${build_key}" "${CONTAINER_TASK}" command Frameworks/SHACLKit "${test_command}"
  ) >"${LOG_DIR}/${name}.log" 2>&1
}

run_parallel() {
  run_shard core "${BUILD_KEY_BASE}-core" coreValidator &
  PID_CORE=$!
  run_shard expr "${BUILD_KEY_BASE}-expr" nodeExpressionEvaluator shapesLoaderParses focusNodeResolver &
  PID_EXPR=$!
  run_shard w3c "${BUILD_KEY_BASE}-w3c" w3c &
  PID_W3C=$!

  local fail=0
  local pid
  for pid in "${PID_CORE}" "${PID_EXPR}" "${PID_W3C}"; do
    if ! wait "${pid}"; then
      fail=1
    fi
  done
  return "${fail}"
}

run_sequential() {
  run_shard core "${BUILD_KEY_BASE}-core" coreValidator
  run_shard expr "${BUILD_KEY_BASE}-expr" nodeExpressionEvaluator shapesLoaderParses focusNodeResolver
  run_shard w3c "${BUILD_KEY_BASE}-w3c" w3c
}

if [[ "${MODE}" == "parallel" ]]; then
  if run_parallel; then
    echo "[sharded] all shards passed in parallel. Logs: ${LOG_DIR}"
    exit 0
  fi
  echo "[sharded] parallel mode failed. Logs: ${LOG_DIR}" >&2
  exit 1
fi

if [[ "${MODE}" == "sequential" ]]; then
  run_sequential
  echo "[sharded] all shards passed sequentially. Logs: ${LOG_DIR}"
  exit 0
fi

if run_parallel; then
  echo "[sharded] all shards passed in parallel. Logs: ${LOG_DIR}"
  exit 0
fi

if grep -R -q "failed to bootstrap container" "${LOG_DIR}"; then
  echo "[sharded] parallel bootstrap failed on this host, retrying shards sequentially..."
  run_sequential
  echo "[sharded] all shards passed sequentially. Logs: ${LOG_DIR}"
  exit 0
fi

echo "[sharded] one or more shards failed. Logs: ${LOG_DIR}" >&2
exit 1
