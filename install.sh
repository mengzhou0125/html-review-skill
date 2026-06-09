#!/usr/bin/env bash
#
# html-review-skill · installer
#
# Usage (from a local clone):
#   ./install.sh
#
# Idempotent — re-run to update. Copies this skill to ~/.claude/skills/html-review-skill/.

set -euo pipefail

SKILL_NAME="html-review-skill"
SKILL_DIR="$HOME/.claude/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$SKILL_DIR"

target="$SKILL_DIR/$SKILL_NAME"
rm -rf "$target"
mkdir -p "$target"

for item in SKILL.md references specs; do
  if [ -e "$SCRIPT_DIR/$item" ]; then
    cp -r "$SCRIPT_DIR/$item" "$target/"
  fi
done

echo "✓ Installed: $SKILL_NAME → $target"
echo ""
echo "Next:"
echo "  · trigger with:  render this doc as a review HTML  /  /html-review"
echo "  · default visual style: DNA1 (bundled at specs/dna1-default.md)"
echo "  · to use a different spec:  pass --spec=<path>  or  drop a design.md into <project>/.claude/"
echo ""
echo "For DNA1-compliance auditing, see:"
echo "  https://github.com/mengzhou0125/evidence-poet-design-system  (install just the auditor: ./install.sh auditor)"
