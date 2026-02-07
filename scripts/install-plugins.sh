#!/bin/bash
# ============================================================================
# Install Claude Code Plugins
# ============================================================================
# Installs plugins from the local claude-plugins repository
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Look for claude-plugins as sibling directory of the template root
PLUGINS_DIR="$(dirname "$SCRIPT_DIR")/../claude-plugins"
# Resolve to absolute path
PLUGINS_DIR="$(cd "$PLUGINS_DIR" 2>/dev/null && pwd || echo "$PLUGINS_DIR")"

echo "============================================"
echo "  Installing Claude Code Plugins"
echo "============================================"
echo ""

# Check if plugins repo exists
if [ ! -d "$PLUGINS_DIR" ]; then
  echo "ERROR: claude-plugins repo not found at $PLUGINS_DIR"
  echo "Clone it first: git clone https://github.com/2389-research/claude-plugins.git"
  exit 1
fi

# Core development plugins
CORE_PLUGINS=(
  "terminal-title"
  "fresh-eyes-review"
  "documentation-audit"
  "scenario-testing"
  "css-development"
  "better-dev"
  "building-multiagent-systems"
)

# Personal/optional plugins
PERSONAL_PLUGINS=(
  "ceo-personal-os"
  "product-launcher"
)

echo ">>> Installing core plugins..."
for plugin in "${CORE_PLUGINS[@]}"; do
  if [ -d "$PLUGINS_DIR/$plugin" ]; then
    echo "  Installing: $plugin"
    # Copy plugin skills to user skills directory
    if [ -d "$PLUGINS_DIR/$plugin/skills" ]; then
      mkdir -p "$HOME/.claude/skills/$plugin"
      cp -r "$PLUGINS_DIR/$plugin/skills/"* "$HOME/.claude/skills/$plugin/" 2>/dev/null
    fi
    # Copy plugin hooks if present
    if [ -d "$PLUGINS_DIR/$plugin/hooks" ]; then
      mkdir -p "$HOME/.claude/hooks"
      cp -r "$PLUGINS_DIR/$plugin/hooks/"* "$HOME/.claude/hooks/" 2>/dev/null
    fi
    echo "    ✓ Done"
  else
    echo "  ⚠ $plugin not found at $PLUGINS_DIR/$plugin — skipping"
  fi
done

echo ""
echo ">>> Installing personal plugins..."
for plugin in "${PERSONAL_PLUGINS[@]}"; do
  if [ -d "$PLUGINS_DIR/$plugin" ]; then
    echo "  Installing: $plugin"
    if [ -d "$PLUGINS_DIR/$plugin/skills" ]; then
      mkdir -p "$HOME/.claude/skills/$plugin"
      cp -r "$PLUGINS_DIR/$plugin/skills/"* "$HOME/.claude/skills/$plugin/" 2>/dev/null
    fi
    echo "    ✓ Done"
  else
    echo "  ⚠ $plugin not found — skipping"
  fi
done

echo ""
echo "============================================"
echo "  Plugins Installed!"
echo "============================================"
echo ""
echo "Installed to: ~/.claude/skills/"
echo ""
echo "Verify in Claude Code with: /help"
echo ""
