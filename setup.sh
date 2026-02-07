#!/bin/bash
# ============================================================================
# Claude Code Ultra — Project Setup Script
# ============================================================================
# Usage:
#   ./setup.sh /path/to/project [--worktree branch-name]
#
# What it does:
#   1. Copies .claude/ config into the target project
#   2. Copies CLAUDE.md template
#   3. Creates centralized log directories
#   4. Makes hooks executable
#   5. Optionally creates a git worktree
#   6. Starts tmux session (if available)
# ============================================================================

set -e

# Resolve template dir from script location (works when cloned anywhere)
TEMPLATE_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${1:-.}"
WORKTREE_BRANCH=""

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --worktree) WORKTREE_BRANCH="$2"; shift ;;
    *) TARGET_DIR="$1" ;;
  esac
  shift
done

# Resolve absolute path
TARGET_DIR=$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")

echo "============================================"
echo "  Claude Code Ultra — Project Setup"
echo "============================================"
echo "Template: $TEMPLATE_DIR"
echo "Target:   $TARGET_DIR"
echo ""

# Check template exists
if [ ! -d "$TEMPLATE_DIR/.claude" ]; then
  echo "ERROR: Template not found at $TEMPLATE_DIR"
  echo "Run the initial setup first."
  exit 1
fi

# Handle worktree creation
if [ -n "$WORKTREE_BRANCH" ]; then
  PROJECT_NAME=$(basename "$TARGET_DIR")
  WORKTREE_DIR="$(dirname "$TARGET_DIR")/${PROJECT_NAME}-${WORKTREE_BRANCH}"
  echo "Creating worktree: $WORKTREE_DIR (branch: $WORKTREE_BRANCH)"
  cd "$TARGET_DIR"
  git worktree add "$WORKTREE_DIR" -b "$WORKTREE_BRANCH" 2>/dev/null || \
    git worktree add "$WORKTREE_DIR" "$WORKTREE_BRANCH"
  TARGET_DIR="$WORKTREE_DIR"
  echo "Worktree created at: $TARGET_DIR"
  echo ""
fi

# Create target directory if needed
mkdir -p "$TARGET_DIR"

# Copy .claude/ config (don't overwrite existing hooks if present)
echo ">>> Copying .claude/ configuration..."
if [ -d "$TARGET_DIR/.claude" ]; then
  echo "    .claude/ exists — merging (not overwriting existing files)..."
  # Copy agents, commands, skills (always update)
  mkdir -p "$TARGET_DIR/.claude/agents" "$TARGET_DIR/.claude/commands" "$TARGET_DIR/.claude/skills"
  cp -r "$TEMPLATE_DIR/.claude/agents/" "$TARGET_DIR/.claude/agents/"
  cp -r "$TEMPLATE_DIR/.claude/commands/" "$TARGET_DIR/.claude/commands/"
  cp -r "$TEMPLATE_DIR/.claude/skills/" "$TARGET_DIR/.claude/skills/"
  # Copy hooks only if not present
  mkdir -p "$TARGET_DIR/.claude/hooks"
  for hook in "$TEMPLATE_DIR/.claude/hooks/"*.sh; do
    hookname=$(basename "$hook")
    if [ ! -f "$TARGET_DIR/.claude/hooks/$hookname" ]; then
      cp "$hook" "$TARGET_DIR/.claude/hooks/$hookname"
    fi
  done
  # Copy settings.json only if not present
  if [ ! -f "$TARGET_DIR/.claude/settings.json" ]; then
    cp "$TEMPLATE_DIR/.claude/settings.json" "$TARGET_DIR/.claude/settings.json"
  fi
else
  cp -r "$TEMPLATE_DIR/.claude" "$TARGET_DIR/.claude"
fi

# Copy CLAUDE.md (only if not present — never overwrite project-specific CLAUDE.md)
if [ ! -f "$TARGET_DIR/CLAUDE.md" ]; then
  echo ">>> Copying CLAUDE.md template..."
  cp "$TEMPLATE_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
else
  echo ">>> CLAUDE.md already exists — skipping (preserving project-specific config)"
fi

# Create log directories
echo ">>> Creating centralized log directories..."
mkdir -p "$TARGET_DIR/.claude/logs/"{sessions,agents,progress,reviews,prompt-trails}

# Initialize agent counter
if [ ! -f "$TARGET_DIR/.claude/logs/.agent-counter" ]; then
  echo "0" > "$TARGET_DIR/.claude/logs/.agent-counter"
fi

# Make hooks executable
echo ">>> Making hooks executable..."
chmod +x "$TARGET_DIR/.claude/hooks/"*.sh 2>/dev/null || true

# Add .claude/logs/ to .gitignore if not present
if [ -f "$TARGET_DIR/.gitignore" ]; then
  if ! grep -q ".claude/logs/" "$TARGET_DIR/.gitignore" 2>/dev/null; then
    echo "" >> "$TARGET_DIR/.gitignore"
    echo "# Claude Code logs (session-specific, not committed)" >> "$TARGET_DIR/.gitignore"
    echo ".claude/logs/" >> "$TARGET_DIR/.gitignore"
    echo ">>> Added .claude/logs/ to .gitignore"
  fi
else
  cat > "$TARGET_DIR/.gitignore" << 'GITIGNORE'
# Claude Code logs (session-specific, not committed)
.claude/logs/
GITIGNORE
  echo ">>> Created .gitignore with .claude/logs/ exclusion"
fi

echo ""
echo "============================================"
echo "  Setup Complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "  cd $TARGET_DIR"
if command -v tmux &>/dev/null; then
  PROJECT_NAME=$(basename "$TARGET_DIR")
  echo "  $TEMPLATE_DIR/scripts/setup-tmux.sh $PROJECT_NAME"
fi
echo "  claude"
echo ""
echo "Inside Claude Code:"
echo "  /prompt-trail-creator  — Plan a new task"
echo "  /fresh-eyes            — Run final validation"
echo "  /create-skill          — Generate a new skill"
echo "  /reset-settings        — Reset settings to defaults"
echo ""
