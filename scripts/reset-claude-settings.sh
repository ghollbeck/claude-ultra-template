#!/bin/bash
# ============================================================================
# Reset Claude Settings to Template Defaults
# ============================================================================
# Backs up current settings and restores from template.
# Use when settings get corrupted or overwritten.
# ============================================================================

TEMPLATE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "============================================"
echo "  Resetting Claude Code Settings"
echo "============================================"
echo ""

# Backup global settings
if [ -f "$HOME/.claude/settings.json" ]; then
  BACKUP="$HOME/.claude/settings.json.bak.$TIMESTAMP"
  cp "$HOME/.claude/settings.json" "$BACKUP"
  echo ">>> Backed up global settings to: $BACKUP"
fi

# Restore global settings
echo ">>> Restoring global settings..."
cat > "$HOME/.claude/settings.json" << 'SETTINGS'
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "permissions": {
    "allow": [
      "Read",
      "Write",
      "Edit",
      "Bash",
      "WebSearch",
      "WebFetch",
      "mcp__*"
    ],
    "deny": []
  },
  "mcpServers": {
    "supabase": {
      "transport": "stdio",
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server-supabase@latest"],
      "env": {
        "SUPABASE_PROJECT_REF": "${SUPABASE_PROJECT_REF}",
        "SUPABASE_ACCESS_TOKEN": "${SUPABASE_ACCESS_TOKEN}"
      }
    },
    "mcp-deepwiki": {
      "transport": "stdio",
      "command": "npx",
      "args": ["-y", "mcp-deepwiki@latest"]
    },
    "render": {
      "url": "https://mcp.render.com/mcp",
      "headers": {
        "Authorization": "Bearer ${RENDER_API_KEY}"
      }
    },
    "github": {
      "transport": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "perplexity": {
      "transport": "stdio",
      "command": "npx",
      "args": ["-y", "@perplexity-ai/mcp-server"],
      "env": {
        "PERPLEXITY_API_KEY": "${PERPLEXITY_API_KEY}",
        "PERPLEXITY_TIMEOUT_MS": "600000"
      }
    },
    "puppeteer": {
      "transport": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    },
    "slack": {
      "transport": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}",
        "SLACK_TEAM_ID": "${SLACK_TEAM_ID}"
      }
    }
  }
}
SETTINGS

echo ">>> Global settings restored."
echo ""

# Backup project settings if in a project
if [ -f ".claude/settings.json" ]; then
  BACKUP=".claude/settings.json.bak.$TIMESTAMP"
  cp ".claude/settings.json" "$BACKUP"
  echo ">>> Backed up project settings to: $BACKUP"
  cp "$TEMPLATE_DIR/.claude/settings.json" ".claude/settings.json"
  echo ">>> Project settings restored."
fi

# Make hooks executable
if [ -d ".claude/hooks" ]; then
  chmod +x .claude/hooks/*.sh 2>/dev/null
  echo ">>> Hooks made executable."
fi

echo ""
echo "============================================"
echo "  Settings Reset Complete!"
echo "============================================"
echo ""
echo "IMPORTANT: Environment variables needed in ~/.zshenv:"
echo "  export SUPABASE_PROJECT_REF='your-project-ref'"
echo "  export SUPABASE_ACCESS_TOKEN='your-token'"
echo "  export RENDER_API_KEY='your-token'"
echo "  export GITHUB_TOKEN='your-github-pat'"
echo "  export PERPLEXITY_API_KEY='your-key'"
echo "  export SLACK_BOT_TOKEN='your-token'"
echo "  export SLACK_TEAM_ID='your-team-id'"
echo ""
echo "Restart Claude Code for changes to take effect."
echo ""
