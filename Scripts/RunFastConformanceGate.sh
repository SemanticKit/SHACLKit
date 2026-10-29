#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SWIFT="${SWIFT:-swift}"

FILTERS=(
  "w3cNodeExprShnexEvalSubsetMatchesManifestResults"
  "w3cNodeExprShnexFixturesParseThroughSHACLLoaders"
  "w3cCuratedConformanceSubsetMatchesExpectations"
  "coreValidatorRuleEvaluationTerminatesForSelfLoopingRule"
  "coreValidatorExecutesSPARQLSelectConstraintThroughExecutorBoundary"
  "coreValidatorExecutesSPARQLAskConstraintThroughExecutorBoundary"
)

FILTER_PATTERN="$(IFS='|'; echo "${FILTERS[*]}")"

echo "[fast-gate] running: ${SWIFT} test --filter ${FILTER_PATTERN}"
cd "${REPO_ROOT}"
"${SWIFT}" test --filter "${FILTER_PATTERN}"
