#!/bin/bash
# ============================================================================
# Claude Ultra — Install agents, skills, hooks, commands & MCP setup
# ============================================================================
# Usage: install-to-project.sh <target-project-path>
#
# Example:
#   install-to-project.sh /path/to/your/project
#   install-to-project.sh .    (current directory)
# ============================================================================

set -e

# Source is always relative to where this script lives
SRC="$(cd "$(dirname "$0")/.." && pwd)"

# Target is the argument (required)
if [ -z "$1" ]; then
  echo "Usage: install-to-project.sh <target-project-path>"
  echo ""
  echo "Example:"
  echo "  install-to-project.sh /path/to/my/project"
  echo "  install-to-project.sh ."
  exit 1
fi

DST="$(cd "$1" && pwd)"

echo "============================================"
echo "  Claude Ultra Installer"
echo "  From: $SRC"
echo "  To:   $DST"
echo "============================================"
echo ""

# Ensure .claude dir exists
mkdir -p "$DST/.claude/skills" "$DST/scripts"

# Copy agents
if [ -d "$DST/.claude/agents" ]; then
  echo ">>> agents/ — already exists, updating..."
  cp -r "$SRC/.claude/agents/"* "$DST/.claude/agents/"
else
  echo ">>> agents/ — installing..."
  cp -r "$SRC/.claude/agents" "$DST/.claude/agents"
fi

# Copy commands
if [ -d "$DST/.claude/commands" ]; then
  echo ">>> commands/ — already exists, updating..."
  cp -r "$SRC/.claude/commands/"* "$DST/.claude/commands/"
else
  echo ">>> commands/ — installing..."
  cp -r "$SRC/.claude/commands" "$DST/.claude/commands"
fi

# Copy hooks
if [ -d "$DST/.claude/hooks" ]; then
  echo ">>> hooks/ — already exists, updating..."
  cp -r "$SRC/.claude/hooks/"* "$DST/.claude/hooks/"
else
  echo ">>> hooks/ — installing..."
  cp -r "$SRC/.claude/hooks" "$DST/.claude/hooks"
fi

# Copy skills (merge, don't overwrite existing)
for skill_dir in "$SRC/.claude/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  if [ -d "$DST/.claude/skills/$skill_name" ]; then
    echo ">>> skill/$skill_name — already exists, updating..."
    cp -r "$skill_dir"* "$DST/.claude/skills/$skill_name/"
  else
    echo ">>> skill/$skill_name — installing..."
    cp -r "$skill_dir" "$DST/.claude/skills/$skill_name"
  fi
done

# Copy settings.json (hooks config) — only if not present
if [ -f "$DST/.claude/settings.json" ]; then
  echo ">>> settings.json — already exists, skipping (delete to reinstall)"
else
  echo ">>> settings.json — installing..."
  cp "$SRC/.claude/settings.json" "$DST/.claude/settings.json"
fi

# Copy MCP setup script
echo ">>> scripts/setup-mcps.sh — installing..."
cp "$SRC/scripts/setup-mcps.sh" "$DST/scripts/setup-mcps.sh"

# Make everything executable
chmod +x "$DST/scripts/"*.sh "$DST/.claude/hooks/"*.sh 2>/dev/null

echo ""
echo "============================================"
echo "  Done!"
echo "============================================"
echo ""
echo "Installed: agents, commands, hooks, skills, settings, setup-mcps.sh"
echo ""
echo "Next: run MCP registration (one-time):"
echo "  $DST/scripts/setup-mcps.sh"
echo ""
