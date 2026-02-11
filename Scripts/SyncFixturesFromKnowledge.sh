#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../../.." && pwd)"
SOURCE_DIR="$ROOT_DIR/Knowledge/SHACL/Fixtures"
INBOX_FIXTURES_DIR="$ROOT_DIR/Knowledge/Inbox/Fixtures"
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

# Optionally sync the newest staged W3C Data Shapes curated fixture bundle from Knowledge/Inbox/Fixtures.
latest_w3c_dir=""
if [[ -d "$INBOX_FIXTURES_DIR" ]]; then
  while IFS= read -r dir; do
    latest_w3c_dir="$dir"
  done < <(find "$INBOX_FIXTURES_DIR" -maxdepth 1 -mindepth 1 -type d -name 'W3CDataShapes*' | sort)
fi

if [[ -n "$latest_w3c_dir" ]]; then
  w3c_dest="$DEST_DIR/W3CDataShapes"
  rm -rf "$w3c_dest"
  mkdir -p "$w3c_dest"
  cp -R "$latest_w3c_dir"/. "$w3c_dest"/
  echo "Synced W3C curated fixtures from $(basename "$latest_w3c_dir") to SHACLKitTests/Fixtures/W3CDataShapes"
else
  echo "No W3CDataShapes* directory found under $INBOX_FIXTURES_DIR (skipping optional W3C sync)."
fi
