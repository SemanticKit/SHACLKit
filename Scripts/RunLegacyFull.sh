#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
CONTAINER_TASK="${WORKSPACE_ROOT}/Scripts/ContainerTask.sh"

if [[ ! -x "${CONTAINER_TASK}" ]]; then
  echo "error: missing container task script at ${CONTAINER_TASK}" >&2
  exit 1
fi

echo "[legacy-full] running full SHACLKit suite"
"${CONTAINER_TASK}" test Frameworks/SHACLKit
