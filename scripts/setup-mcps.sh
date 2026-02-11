#!/bin/bash
# ============================================================================
# Claude Code Ultra — Register MCP Servers
# ============================================================================
# Registers all MCP servers using `claude mcp add` (the proper way).
# Reads tokens from environment variables. Run once per machine.
#
# Usage: ./scripts/setup-mcps.sh [--scope user|project]
# Default scope: user (global, available in all projects)
# ============================================================================

set -e

SCOPE="${1:---scope}"
SCOPE_VAL="${2:-user}"

# If first arg is --scope, use it; otherwise default to user scope
if [[ "$1" == "--scope" ]]; then
  SCOPE_FLAG="-s $SCOPE_VAL"
elif [[ "$1" == "--project" ]]; then
  SCOPE_FLAG="-s project"
else
  SCOPE_FLAG="-s user"
fi

echo "============================================"
echo "  Registering MCP Servers"
echo "  Scope: ${SCOPE_FLAG}"
echo "============================================"
echo ""

# Check claude CLI exists
if ! command -v claude &>/dev/null; then
  echo "ERROR: claude CLI not found. Install Claude Code first."
  exit 1
fi

# ---- DeepWiki (no auth needed) ----
echo ">>> DeepWiki..."
claude mcp add mcp-deepwiki $SCOPE_FLAG -- npx -y mcp-deepwiki@latest 2>/dev/null && echo "    OK" || echo "    (already exists or failed)"

# ---- Puppeteer (no auth needed) ----
echo ">>> Puppeteer..."
claude mcp add puppeteer $SCOPE_FLAG -- npx -y @modelcontextprotocol/server-puppeteer 2>/dev/null && echo "    OK" || echo "    (already exists or failed)"

# ---- GitHub ----
if [ -n "$GITHUB_TOKEN" ]; then
  echo ">>> GitHub..."
  claude mcp add github $SCOPE_FLAG \
    -e GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_TOKEN" \
    -- npx -y @modelcontextprotocol/server-github 2>/dev/null && echo "    OK" || echo "    (already exists or failed)"
else
  echo ">>> GitHub — SKIPPED (set GITHUB_TOKEN in ~/.zshenv)"
fi

# ---- Supabase ----
if [ -n "$SUPABASE_ACCESS_TOKEN" ]; then
  SUPABASE_REF="${SUPABASE_PROJECT_REF:?Set SUPABASE_PROJECT_REF in ~/.zshenv}"
  echo ">>> Supabase..."
  claude mcp add supabase $SCOPE_FLAG \
    -e SUPABASE_PROJECT_REF="$SUPABASE_REF" \
    -e SUPABASE_ACCESS_TOKEN="$SUPABASE_ACCESS_TOKEN" \
    -- npx -y @supabase/mcp-server-supabase@latest 2>/dev/null && echo "    OK" || echo "    (already exists or failed)"
else
  echo ">>> Supabase — SKIPPED (set SUPABASE_ACCESS_TOKEN in ~/.zshenv)"
fi

# ---- Perplexity ----
if [ -n "$PERPLEXITY_API_KEY" ]; then
  echo ">>> Perplexity..."
  claude mcp add perplexity $SCOPE_FLAG \
    -e PERPLEXITY_API_KEY="$PERPLEXITY_API_KEY" \
    -e PERPLEXITY_TIMEOUT_MS="600000" \
    -- npx -y @perplexity-ai/mcp-server 2>/dev/null && echo "    OK" || echo "    (already exists or failed)"
else
  echo ">>> Perplexity — SKIPPED (set PERPLEXITY_API_KEY in ~/.zshenv)"
fi

# ---- Slack ----
if [ -n "$SLACK_BOT_TOKEN" ]; then
  echo ">>> Slack..."
  claude mcp add slack $SCOPE_FLAG \
    -e SLACK_BOT_TOKEN="$SLACK_BOT_TOKEN" \
    -e SLACK_TEAM_ID="${SLACK_TEAM_ID}" \
    -- npx -y @modelcontextprotocol/server-slack 2>/dev/null && echo "    OK" || echo "    (already exists or failed)"
else
  echo ">>> Slack — SKIPPED (set SLACK_BOT_TOKEN in ~/.zshenv)"
fi

# ---- Render ----
if [ -n "$RENDER_API_KEY" ]; then
  echo ">>> Render..."
  claude mcp add render $SCOPE_FLAG \
    -t http \
    --url "https://mcp.render.com/mcp" \
    --header "Authorization: Bearer $RENDER_API_KEY" 2>/dev/null && echo "    OK" || echo "    (already exists or failed)"
else
  echo ">>> Render — SKIPPED (set RENDER_API_KEY in ~/.zshenv)"
fi

echo ""
echo "============================================"
echo "  MCP Registration Complete"
echo "============================================"
echo ""
echo "Verify with: claude mcp list"
echo ""
echo "MCPs that were skipped need their env vars set in ~/.zshenv:"
echo "  export GITHUB_TOKEN='ghp_...'"
echo "  export SUPABASE_ACCESS_TOKEN='sbp_...'"
echo "  export PERPLEXITY_API_KEY='pplx-...'"
echo "  export SLACK_BOT_TOKEN='xoxb-...'"
echo "  export SLACK_TEAM_ID='T...'"
echo "  export RENDER_API_KEY='rnd_...'"
echo ""
