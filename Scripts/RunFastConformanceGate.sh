#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
CONTAINER_TASK="${WORKSPACE_ROOT}/Scripts/ContainerTask.sh"

if [[ ! -x "${CONTAINER_TASK}" ]]; then
  echo "error: missing container task script at ${CONTAINER_TASK}" >&2
  exit 1
fi

FILTERS=(
  "w3cNodeExprShnexEvalSubsetMatchesManifestResults"
  "w3cNodeExprShnexFixturesParseThroughSHACLLoaders"
  "w3cCuratedConformanceSubsetMatchesExpectations"
  "coreValidatorRuleEvaluationTerminatesForSelfLoopingRule"
  "coreValidatorExecutesSPARQLSelectConstraintThroughExecutorBoundary"
  "coreValidatorExecutesSPARQLAskConstraintThroughExecutorBoundary"
)

CMD=("swift" "test")
FILTER_PATTERN="$(IFS='|'; echo "${FILTERS[*]}")"
CMD+=("--filter" "${FILTER_PATTERN}")

printf -v TEST_COMMAND '%q ' "${CMD[@]}"

echo "[fast-gate] running: ${TEST_COMMAND}"
"${CONTAINER_TASK}" command Frameworks/SHACLKit "${TEST_COMMAND}"
