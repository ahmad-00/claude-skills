#!/usr/bin/env bash
# Build one zip per skill into dist/ (for uploading to the Claude app: Customize > Skills).
# Usage: scripts/package.sh
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$REPO_DIR/plugins/senior-engineers/skills"
DIST="$REPO_DIR/dist"
command -v zip >/dev/null 2>&1 || { echo "error: zip is not installed" >&2; exit 1; }
rm -rf "$DIST" && mkdir -p "$DIST"
cd "$SKILLS_SRC"
for d in */; do
  name="${d%/}"
  [ -f "$name/SKILL.md" ] || continue
  zip -qr "$DIST/$name.zip" "$name" -x "*/.installed-from" "*.DS_Store"
  echo "built dist/$name.zip"
done
