#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE_ROOT="$ROOT_DIR/SHACLKitTests/Fixtures/W3CDataShapes"
PROP_DIR="$FIXTURE_ROOT/shacl12-test-suite/tests/core/property"
MANIFEST="$FIXTURE_ROOT/W3CCuratedConformanceManifest.tsv"

if [[ ! -d "$PROP_DIR" ]]; then
  echo "[error] Missing property fixture directory: $PROP_DIR" >&2
  exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
  echo "[error] Missing curated manifest: $MANIFEST" >&2
  exit 1
fi

echo "W3C SHACL 1.2 Property Gap Report"
echo "manifest: $MANIFEST"
echo "source:   $PROP_DIR"
echo
printf "%-26s %-10s %s\n" "fixture" "blocked?" "reason"
printf "%-26s %-10s %s\n" "--------------------------" "----------" "-----------------------------"

missing_count=0
blocked_count=0
tmp_list="$(mktemp)"
find "$PROP_DIR" -maxdepth 1 -type f -name "*.ttl" -print | sort > "$tmp_list"
while IFS= read -r abs_path; do
  file_name="$(basename "$abs_path")"
  [[ "$file_name" == "manifest.ttl" ]] && continue
  rel_path="shacl12-test-suite/tests/core/property/$file_name"
  if awk -F '\t' -v rel="$rel_path" '$2==rel || $3==rel { found=1 } END { exit(found ? 0 : 1) }' "$MANIFEST"; then
    continue
  fi

  missing_count=$((missing_count + 1))
  blocked="no"
  reason="not yet curated"

  if rg -q '"""' "$abs_path"; then
    blocked="yes"
    reason="uses triple-quoted Turtle literal"
    blocked_count=$((blocked_count + 1))
  elif rg -q 'sh:sourceConstraintComponent sh:(MemberShape|ReifierShape|UniqueMembers|MinListLength|MaxListLength|SomeValue|SingleLine)ConstraintComponent' "$abs_path"; then
    reason="requires unshipped/partial SHACL 1.2 constraint"
  fi

  printf "%-26s %-10s %s\n" "$file_name" "$blocked" "$reason"
done < "$tmp_list"
rm -f "$tmp_list"

echo
echo "summary:"
echo "  missing fixtures: $missing_count"
echo "  parser-blocked:   $blocked_count"
