#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SWIFT="${SWIFT:-swift}"

BASE_REF="${1:-origin/main}"

if ! git -C "${REPO_ROOT}" rev-parse --verify -q "${BASE_REF}" >/dev/null; then
  BASE_REF="HEAD~1"
fi

CHANGED_FILES=$(git -C "${REPO_ROOT}" diff --name-only "${BASE_REF}"..HEAD || true)
WORKING_TREE_FILES=$(git -C "${REPO_ROOT}" diff --name-only HEAD || true)
if [[ -n "${WORKING_TREE_FILES}" ]]; then
  CHANGED_FILES+=$'\n'"${WORKING_TREE_FILES}"
fi

if [[ -z "${CHANGED_FILES//[[:space:]]/}" ]]; then
  echo "[changed-gate] no changed files detected; running fast conformance gate"
  exec "${SCRIPT_DIR}/RunFastConformanceGate.sh"
fi

FILTERS=()
add_filter() {
  local f="$1"
  local existing
  for existing in "${FILTERS[@]:-}"; do
    if [[ "${existing}" == "${f}" ]]; then
      return
    fi
  done
  FILTERS+=("${f}")
}

while IFS= read -r path; do
  case "${path}" in
    Sources/SHACLKit/*)
      add_filter "coreValidator"
      add_filter "nodeExpressionEvaluator"
      ;;
    Tests/SHACLKitTests/Fixtures/W3CDataShapes/*)
      add_filter "w3c"
      ;;
    Tests/SHACLKitTests/*)
      add_filter "shapesLoaderParses"
      add_filter "focusNodeResolver"
      add_filter "coreValidator"
      add_filter "nodeExpressionEvaluator"
      ;;
    Scripts/*)
      add_filter "w3cNodeExprShnexEvalSubsetMatchesManifestResults"
      add_filter "w3cCuratedConformanceSubsetMatchesExpectations"
      ;;
    *)
      ;;
  esac
done <<< "${CHANGED_FILES}"

if [[ ${#FILTERS[@]} -eq 0 ]]; then
  echo "[changed-gate] changes are outside SHACLKit sources, tests and scripts; running fast conformance gate"
  exec "${SCRIPT_DIR}/RunFastConformanceGate.sh"
fi

FILTER_PATTERN="$(IFS='|'; echo "${FILTERS[*]}")"

echo "[changed-gate] base=${BASE_REF}"
echo "[changed-gate] filters=${FILTERS[*]}"
cd "${REPO_ROOT}"
"${SWIFT}" test --filter "${FILTER_PATTERN}"
