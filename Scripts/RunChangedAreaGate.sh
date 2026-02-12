#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
CONTAINER_TASK="${WORKSPACE_ROOT}/Scripts/ContainerTask.sh"

if [[ ! -x "${CONTAINER_TASK}" ]]; then
  echo "error: missing container task script at ${CONTAINER_TASK}" >&2
  exit 1
fi

BASE_REF="${1:-origin/codex/shacl-phase1-target-resolution}"

if ! git -C "${WORKSPACE_ROOT}" rev-parse --verify -q "${BASE_REF}" >/dev/null; then
  BASE_REF="HEAD~1"
fi

CHANGED_FILES=$(git -C "${WORKSPACE_ROOT}" diff --name-only "${BASE_REF}"..HEAD || true)
if [[ -z "${CHANGED_FILES}" ]]; then
  CHANGED_FILES=$(git -C "${WORKSPACE_ROOT}" diff --name-only || true)
fi

# Root diffs collapse submodule edits to "Frameworks/SHACLKit". Expand to file-level paths.
if grep -q '^Frameworks/SHACLKit$' <<< "${CHANGED_FILES}"; then
  SUBMODULE_CHANGED=$(git -C "${WORKSPACE_ROOT}/Frameworks/SHACLKit" diff --name-only || true)
  if [[ -n "${SUBMODULE_CHANGED}" ]]; then
    while IFS= read -r sub_path; do
      [[ -z "${sub_path}" ]] && continue
      CHANGED_FILES+=$'\n'"Frameworks/SHACLKit/${sub_path}"
    done <<< "${SUBMODULE_CHANGED}"
  fi
fi

if [[ -z "${CHANGED_FILES}" ]]; then
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
    Frameworks/SHACLKit/SHACLKit/*)
      add_filter "coreValidator"
      add_filter "nodeExpressionEvaluator"
      ;;
    Frameworks/SHACLKit/SHACLKitTests/Fixtures/W3CDataShapes/*)
      add_filter "w3c"
      ;;
    Frameworks/SHACLKit/SHACLKitTests/*)
      add_filter "shapesLoaderParses"
      add_filter "focusNodeResolver"
      add_filter "coreValidator"
      add_filter "nodeExpressionEvaluator"
      ;;
    Frameworks/SHACLKit/Scripts/*)
      add_filter "w3cNodeExprShnexEvalSubsetMatchesManifestResults"
      add_filter "w3cCuratedConformanceSubsetMatchesExpectations"
      ;;
    *)
      ;;
  esac
done <<< "${CHANGED_FILES}"

if [[ ${#FILTERS[@]} -eq 0 ]]; then
  echo "[changed-gate] changes are outside SHACLKit scope; running fast conformance gate"
  exec "${SCRIPT_DIR}/RunFastConformanceGate.sh"
fi

CMD=("swift" "test")
FILTER_PATTERN="$(IFS='|'; echo "${FILTERS[*]}")"
CMD+=("--filter" "${FILTER_PATTERN}")
printf -v TEST_COMMAND '%q ' "${CMD[@]}"

echo "[changed-gate] base=${BASE_REF}"
echo "[changed-gate] filters=${FILTERS[*]}"
"${CONTAINER_TASK}" command Frameworks/SHACLKit "${TEST_COMMAND}"
