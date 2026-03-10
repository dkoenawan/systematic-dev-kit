#!/usr/bin/env bash
# validate-spec.sh
# PostToolUse hook for the Write tool.
# Reads JSON input from stdin. If the written file is under specs/, validates
# that it contains all required spec sections. Exits 2 (blocking) on failure.

set -euo pipefail

# Read the full tool input JSON from stdin
input=$(cat)

# Extract the file_path from the Write tool input
file_path=$(echo "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')

# Skip validation if file_path is empty or not under specs/
if [[ -z "$file_path" ]]; then
  exit 0
fi

# Normalize path — strip leading ./ if present
file_path="${file_path#./}"

# Only validate files under the specs/ directory
if [[ "$file_path" != specs/* ]]; then
  exit 0
fi

echo "[validate-spec] Validating spec file: $file_path"

# Check file exists on disk
if [[ ! -f "$file_path" ]]; then
  echo "[validate-spec] ERROR: Spec file does not exist on disk: $file_path"
  echo "[validate-spec] The Write tool reported success but the file is missing. Re-generate the spec file."
  exit 2
fi

# Required sections (must appear as markdown headings in the file)
required_sections=(
  "Feature Summary"
  "Database Layer"
  "Backend Layer"
  "Frontend Layer"
  "Implementation Order"
  "Open Questions"
)

missing=()
for section in "${required_sections[@]}"; do
  if ! grep -qi "## .*${section}" "$file_path" 2>/dev/null; then
    missing+=("$section")
  fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "[validate-spec] ERROR: Spec file is missing required sections:"
  for s in "${missing[@]}"; do
    echo "  - $s"
  done
  echo ""
  echo "[validate-spec] The spec at '$file_path' is incomplete. Add the missing sections"
  echo "[validate-spec] using the structure from skills/plan/template.md before finishing."
  exit 2
fi

echo "[validate-spec] OK: All required sections present in $file_path"
exit 0
