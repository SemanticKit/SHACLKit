#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SWIFT="${SWIFT:-swift}"

echo "[legacy-full] running full SHACLKit suite"
cd "${REPO_ROOT}"
"${SWIFT}" test
