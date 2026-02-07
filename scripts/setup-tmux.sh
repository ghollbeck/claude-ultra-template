#!/bin/bash
# ============================================================================
# tmux Session Setup for Claude Code Ultra
# ============================================================================
# Usage: ~/claude-ultra-template/scripts/setup-tmux.sh [project-name]
#
# Creates a tmux session with named windows:
#   0: claude    — Main Claude Code session
#   1: terminal  — General terminal for manual commands
#   2: tests     — For running tests
#   3: server    — For running dev servers
# ============================================================================

PROJECT_NAME="${1:-$(basename "$(pwd)")}"
SESSION_NAME="claude-${PROJECT_NAME}"

# Check if tmux is available
if ! command -v tmux &>/dev/null; then
  echo "tmux is not installed. Install with: brew install tmux"
  exit 1
fi

# Kill existing session if present
tmux kill-session -t "$SESSION_NAME" 2>/dev/null

# Create new session with named windows
echo "Creating tmux session: $SESSION_NAME"

tmux new-session -d -s "$SESSION_NAME" -n "🚀 claude"
tmux send-keys -t "$SESSION_NAME:0" "echo -ne '\033]0;🚀 ${PROJECT_NAME} | Claude\007'" Enter

tmux new-window -t "$SESSION_NAME" -n "💻 terminal"
tmux send-keys -t "$SESSION_NAME:1" "echo -ne '\033]0;💻 ${PROJECT_NAME} | Terminal\007'" Enter

tmux new-window -t "$SESSION_NAME" -n "🧪 tests"
tmux send-keys -t "$SESSION_NAME:2" "echo -ne '\033]0;🧪 ${PROJECT_NAME} | Tests\007'" Enter

tmux new-window -t "$SESSION_NAME" -n "🌐 server"
tmux send-keys -t "$SESSION_NAME:3" "echo -ne '\033]0;🌐 ${PROJECT_NAME} | Server\007'" Enter

# Go back to first window
tmux select-window -t "$SESSION_NAME:0"

echo ""
echo "tmux session '$SESSION_NAME' created with windows:"
echo "  0: 🚀 claude    — Start Claude Code here"
echo "  1: 💻 terminal  — General commands"
echo "  2: 🧪 tests     — Run tests"
echo "  3: 🌐 server    — Dev server"
echo ""
echo "Attach with: tmux attach -t $SESSION_NAME"
echo "Switch windows: Ctrl+B then 0-3"
echo ""

# Auto-attach
tmux attach -t "$SESSION_NAME"
