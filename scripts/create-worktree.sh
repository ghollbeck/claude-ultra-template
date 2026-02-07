#!/bin/bash
# ============================================================================
# Create Git Worktree with Claude Config
# ============================================================================
# Usage: ~/claude-ultra-template/scripts/create-worktree.sh <branch-name> [base-branch]
# ============================================================================

BRANCH_NAME="$1"
BASE_BRANCH="${2:-main}"

if [ -z "$BRANCH_NAME" ]; then
  echo "Usage: create-worktree.sh <branch-name> [base-branch]"
  echo "Example: create-worktree.sh feature/user-dashboard main"
  exit 1
fi

# Must be in a git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "ERROR: Not in a git repository."
  exit 1
fi

PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)")
SAFE_BRANCH=$(echo "$BRANCH_NAME" | tr '/' '-')
WORKTREE_DIR="$(dirname "$(git rev-parse --show-toplevel)")/${PROJECT_NAME}-${SAFE_BRANCH}"

echo "Creating worktree:"
echo "  Branch: $BRANCH_NAME (from $BASE_BRANCH)"
echo "  Path:   $WORKTREE_DIR"
echo ""

# Create worktree
git worktree add "$WORKTREE_DIR" -b "$BRANCH_NAME" "$BASE_BRANCH" 2>/dev/null || \
  git worktree add "$WORKTREE_DIR" "$BRANCH_NAME"

# Run setup on the worktree
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/../setup.sh" "$WORKTREE_DIR"

echo ""
echo "Worktree ready! Start with:"
echo "  cd $WORKTREE_DIR && claude"
echo ""
