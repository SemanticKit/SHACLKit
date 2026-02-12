#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
CONTAINER_TASK="${WORKSPACE_ROOT}/Scripts/ContainerTask.sh"
FAST_GATE="${SCRIPT_DIR}/RunFastConformanceGate.sh"
SHARDED="${SCRIPT_DIR}/RunShardedTests.sh"

MODE="full"
for arg in "$@"; do
  case "${arg}" in
    --sharded)
      MODE="sharded"
      ;;
    --full)
      MODE="full"
      ;;
    *)
      echo "Usage: ${0} [--full|--sharded]" >&2
      exit 1
      ;;
  esac
done

echo "[batch-cycle] step 1/2: fast conformance gate"
"${FAST_GATE}"

echo "[batch-cycle] step 2/2: validation mode = ${MODE}"
if [[ "${MODE}" == "sharded" ]]; then
  "${SHARDED}"
else
  "${CONTAINER_TASK}" test Frameworks/SHACLKit
fi

echo "[batch-cycle] complete"
