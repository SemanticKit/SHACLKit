#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../../.." && pwd)"
SOURCE_DIR="$ROOT_DIR/Knowledge/SHACL/Fixtures"
DEST_DIR="$ROOT_DIR/Frameworks/SHACLKit/SHACLKitTests/Fixtures"

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Source fixture directory not found: $SOURCE_DIR"
  exit 1
fi

mkdir -p "$DEST_DIR"

source_files=()
while IFS= read -r line; do
  source_files+=("$line")
done < <(find "$SOURCE_DIR" -maxdepth 1 -type f \( -name '*.ttl' -o -name '*.nt' -o -name '*.nq' -o -name '*.trig' -o -name '*.jsonld' \) | sort)

if [[ ${#source_files[@]} -eq 0 ]]; then
  echo "No canonical SHACL fixture files found in $SOURCE_DIR"
  exit 0
fi

for file in "${source_files[@]}"; do
  base_name="$(basename "$file")"
  cp "$file" "$DEST_DIR/$base_name"
  echo "Synced $base_name"
done

echo "Fixture sync complete: ${#source_files[@]} file(s) copied."
