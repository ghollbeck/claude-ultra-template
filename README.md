# Claude Code Ultra

A self-orchestrating agent framework for long-running Claude Code sessions. Provides predefined agents, skills, hooks, slash commands, and MCP integrations — deploy once, use everywhere.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Install](#quick-install)
3. [Deploying to a Project](#deploying-to-a-project)
4. [What Gets Installed](#what-gets-installed)
5. [Slash Commands](#slash-commands)
6. [Agents](#agents)
7. [MCP Tools](#mcp-tools)
8. [Hooks](#hooks)
9. [Prompting Guide](#prompting-guide)
10. [Working with Prompt Trails](#working-with-prompt-trails)
11. [Git Worktrees](#git-worktrees)
12. [tmux Sessions](#tmux-sessions)
13. [Plugins](#plugins)
14. [Resetting Settings](#resetting-settings)
15. [File Structure](#file-structure)
16. [Customization](#customization)

---

## Prerequisites

- **Claude Code CLI** (v2.1+) — [Install docs](https://docs.anthropic.com/en/docs/claude-code)
- **Node.js** (v18+) — Required for MCP servers (`npx`)
- **tmux** (optional) — `brew install tmux`
- **jq** (optional, for reset script) — `brew install jq`

---

## Quick Install

### Step 1: Clone this repo

```bash
git clone https://github.com/YOUR_ORG/85_CLAUDE_CODE_ULTRA.git
cd 85_CLAUDE_CODE_ULTRA
```

### Step 2: Set up environment variables

Copy the template and fill in your API keys:

```bash
cat claude-ultra-template/.env.template
```

Add them to your shell profile (`~/.zshenv` or `~/.bashrc`):

```bash
# Required
export GITHUB_TOKEN="ghp_your_github_token"

# Optional (for specific MCPs)
export SUPABASE_ACCESS_TOKEN="your-supabase-token"
export RENDER_API_KEY="your-render-key"
export PERPLEXITY_API_KEY="pplx-your-key"
export SLACK_BOT_TOKEN="xoxb-your-slack-token"
export SLACK_TEAM_ID="T01234567"
```

Then reload: `source ~/.zshenv`

### Step 3: Configure global MCP servers

Copy the MCP configuration to your global Claude settings:

```bash
# Create or update ~/.claude/mcp.json with your MCP servers.
# See the "MCP Tools" section below for the full configuration.
```

### Step 4: Set global permissions

```bash
# Create or update ~/.claude/settings.json:
cat > ~/.claude/settings.json << 'EOF'
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "permissions": {
    "allow": [
      "Read", "Write", "Edit", "Bash",
      "WebSearch", "WebFetch", "mcp__*"
    ],
    "deny": []
  }
}
EOF
```

### Step 5: Deploy to your project

```bash
./claude-ultra-template/setup.sh /path/to/your/project
```

### Step 6 (optional): Install plugins

If you have the [claude-plugins](https://github.com/2389-research/claude-plugins) repo cloned as a sibling directory:

```bash
./claude-ultra-template/scripts/install-plugins.sh
```

---

## Deploying to a Project

The setup script copies the full `.claude/` configuration and `CLAUDE.md` into any project:

```bash
# Deploy to an existing project
./claude-ultra-template/setup.sh /path/to/project

# Deploy to a new project
mkdir /path/to/new-project
./claude-ultra-template/setup.sh /path/to/new-project

# Deploy with a git worktree
./claude-ultra-template/setup.sh /path/to/project --worktree feature/my-feature
```

**What the setup script does:**
1. Copies `.claude/agents/`, `.claude/commands/`, `.claude/skills/` (always updates)
2. Copies `.claude/hooks/` (only new hooks, won't overwrite existing)
3. Copies `.claude/settings.json` (only if not present)
4. Copies `CLAUDE.md` (only if not present)
5. Creates `.claude/logs/` directory structure
6. Adds `.claude/logs/` to `.gitignore`
7. Makes all hooks executable

**Safe to re-run** — it merges, never overwrites your customizations.

---

## What Gets Installed

```
your-project/
├── CLAUDE.md                          # Project instructions for Claude
└── .claude/
    ├── settings.json                  # Hooks configuration
    ├── agents/                        # 9 specialist agents
    │   ├── backend-dev.md
    │   ├── frontend-dev.md
    │   ├── debug.md
    │   ├── reviewer.md
    │   ├── integration-check.md
    │   ├── code-sentinel.md
    │   ├── archivist.md
    │   ├── fresh-eyes.md
    │   └── mermaid-architect.md
    ├── commands/                       # 5 slash commands
    │   ├── prompt-trail-creator.md
    │   ├── fresh-eyes.md
    │   ├── create-skill.md
    │   ├── reset-settings.md
    │   └── setup-worktree.md
    ├── skills/                         # 2 auto-detected skills
    │   ├── prompt-trail-creator/SKILL.md
    │   └── create-agent-skills/SKILL.md
    ├── hooks/                          # 4 event hooks
    │   ├── session-start.sh
    │   ├── pre-tool-use.sh
    │   ├── post-tool-use.sh
    │   └── subagent-stop.sh
    └── logs/                           # Centralized logging (gitignored)
        ├── sessions/
        ├── agents/
        ├── progress/
        ├── reviews/
        └── prompt-trails/
```

---

## Slash Commands

Use these inside Claude Code by typing the command name:

| Command | What It Does |
|---------|-------------|
| `/prompt-trail-creator` | Interactive 3-phase workflow: explores your codebase, asks clarifying questions, then generates a numbered prompt trail with agent assignments, tool selections, and validation steps per step. **Start here for any non-trivial task.** |
| `/fresh-eyes` | Spawns the `@fresh-eyes` agent to review all changes with zero prior context. Runs tests, reads git diff, checks logs, screenshots UI. Returns APPROVED / NEEDS_FIXES / MAJOR_ISSUES. |
| `/create-skill` | Generates a new Claude Code skill on demand. Asks what it should do, designs the structure, creates SKILL.md files, and installs them. |
| `/reset-settings` | Nuclear reset of Claude settings to template defaults. Backs up current settings first. Use when configs get corrupted. |
| `/setup-worktree` | Creates a git worktree for parallel branch work. Copies Claude config into the new worktree automatically. |

---

## Agents

Agents are specialist subagents spawned via the `Task` tool. Each has a defined scope and output format.

| Agent | Scope | When to Use | Key Behavior |
|-------|-------|-------------|-------------|
| `backend-dev` | Python/FastAPI | Any backend code changes | Creates Alembic migrations, writes pytest tests, uses Supabase MCP |
| `frontend-dev` | TypeScript/React | Any frontend code changes | Tailwind + custom CSS, uses Puppeteer for visual verification |
| `debug` | Bug investigation | Persistent bugs, failing tests | Max 5 attempts with hypothesis tracking (Ralph Wiggum pattern). Escalates if stuck. |
| `reviewer` | Code review | Before merging | CRITICAL/HIGH/MEDIUM/LOW/NITPICK findings. Review-only, never modifies code. |
| `integration-check` | Wiring verification | After creating new files | Detects ORPHANED_FILE, DEAD_IMPORT, MISSING_EXPORT, CIRCULAR_RISK |
| `code-sentinel` | Security audit | Auth code, user input, APIs | OWASP Top 10 + FastAPI-specific + frontend-specific checks. Report-only. |
| `archivist` | Logging | Progress tracking, session notes | Manages `.claude/logs/` with naming conventions and agent counter |
| `fresh-eyes` | Final validation | End of long tasks (auto) or manual | Zero prior context. Runs tests, reads diff, screenshots UI, comprehensive checklist. |
| `mermaid-architect` | Diagrams | Architecture docs, task summaries | Generates Mermaid diagrams: architecture, data flow, component, task flow |

### How agents are used

Claude automatically uses agents when you invoke slash commands or when a prompt trail step specifies one. You can also reference them directly:

```
Use the @debug agent to investigate why the login endpoint returns 500.
```

```
Run @integration-check on the files I just created.
```

---

## MCP Tools

These are configured globally in `~/.claude/mcp.json` and available in every project.

| MCP | What It Does | Example Usage |
|-----|-------------|---------------|
| **Supabase** | Database operations, auth management | "Query the users table", "Create a migration" |
| **DeepWiki** | Documentation lookup for libraries | "How does FastAPI dependency injection work?" |
| **Render** | Deployment management | "Deploy the latest commit", "Check service status" |
| **GitHub** | PRs, issues, repo operations | "Create a PR for this branch", "List open issues" |
| **Perplexity** | Web search and research | "Find the latest React 19 migration guide" |
| **Puppeteer** | Browser automation, screenshots | "Screenshot the login page", "Click the submit button" |
| **Slack** | Team notifications | "Post a status update to #dev" |

### MCP Configuration

Add to `~/.claude/mcp.json`:

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server-supabase@latest"],
      "env": {
        "SUPABASE_PROJECT_REF": "your-project-ref",
        "SUPABASE_ACCESS_TOKEN": "your-access-token"
      }
    },
    "mcp-deepwiki": {
      "command": "npx",
      "args": ["-y", "mcp-deepwiki@latest"]
    },
    "render": {
      "url": "https://mcp.render.com/mcp",
      "headers": {
        "Authorization": "Bearer your-render-api-key"
      }
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your-github-token"
      }
    },
    "perplexity": {
      "command": "npx",
      "args": ["-y", "@perplexity-ai/mcp-server"],
      "env": {
        "PERPLEXITY_API_KEY": "your-perplexity-key",
        "PERPLEXITY_TIMEOUT_MS": "600000"
      }
    },
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    },
    "slack": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "xoxb-your-token",
        "SLACK_TEAM_ID": "T01234567"
      }
    }
  }
}
```

---

## Hooks

Hooks fire automatically on Claude Code events. They're configured in `.claude/settings.json`.

| Hook | Event | What It Does |
|------|-------|-------------|
| `session-start.sh` | SessionStart | Sets terminal title (emoji + project + date), creates session log file |
| `pre-tool-use.sh` | PreToolUse (Edit/Write/Bash) | Security gate: blocks hook modification, `rm -rf /`, `chmod 777`, `eval()` |
| `post-tool-use.sh` | PostToolUse (Edit/Write) | Logs every file edit to `.claude/logs/.edit-log.jsonl` |
| `subagent-stop.sh` | SubagentStop | Tracks agent completion, increments the agent counter |

---

## Prompting Guide

### For quick tasks (< 30 minutes)

Just tell Claude what you need. The right agent is selected automatically.

```
Fix the 500 error on the /api/users endpoint.
```

```
Add a dark mode toggle to the settings page.
```

```
Write tests for the authentication middleware.
```

### For complex tasks (multi-file, multi-step)

Start with the prompt trail creator:

```
/prompt-trail-creator
```

It will:
1. **Explore** your codebase to understand the current state
2. **Ask** you 2-5 clarifying questions
3. **Present** an architecture plan with agent assignments
4. **Generate** numbered prompt trail files in `.claude/logs/prompt-trails/`

Then execute the trail:

```
Run step 01 from the prompt trail at .claude/logs/prompt-trails/2025-02-07_user-dashboard/01_backend-api.md
```

### For validation

Run fresh eyes manually anytime:

```
/fresh-eyes
```

Or it runs automatically at the end of long-running prompt trails.

### For debugging

```
Use the @debug agent to investigate: [describe the problem]
```

The debug agent uses a structured hypothesis-testing loop with max 5 attempts before escalating.

### For security review

```
Run @code-sentinel on the authentication module.
```

Reports findings only. Never modifies code.

### For architecture diagrams

```
Use @mermaid-architect to diagram the current system architecture.
```

---

## Working with Prompt Trails

Prompt trails are the core workflow for complex tasks. They live in `.claude/logs/prompt-trails/`.

### Structure

```
.claude/logs/prompt-trails/2025-02-07_user-dashboard/
├── 00_masterplan.md        # Overview: goal, components, agent pipeline, success criteria
├── 01_backend-api.md       # Step 1: @backend-dev creates API endpoints
├── 02_database.md          # Step 2: @backend-dev creates migrations
├── 03_frontend-ui.md       # Step 3: @frontend-dev builds UI components
├── 04_integration.md       # Step 4: @integration-check verifies wiring
├── 05_review.md            # Step 5: @reviewer checks code quality
├── 06_validation.md        # Step 6: @fresh-eyes final validation + @mermaid-architect diagram
```

### Each step file contains

- **Agent assignment** — which agent executes this step
- **Dependencies** — which steps must be complete first
- **Implementation instructions** — specific enough to execute without ambiguity
- **Files to create/modify** — exact paths and what to do
- **Validation commands** — test commands to verify the step worked
- **Commit message** — enforce atomic commits
- **Next step pointer** — linked list to the next file

### Running a prompt trail

```
Read .claude/logs/prompt-trails/2025-02-07_user-dashboard/00_masterplan.md and execute the trail starting from step 01.
```

Or step by step:

```
Execute step 01 from .claude/logs/prompt-trails/2025-02-07_user-dashboard/01_backend-api.md
```

---

## Git Worktrees

For parallel work on multiple branches:

```
# Inside Claude Code
/setup-worktree

# Or from terminal
./claude-ultra-template/scripts/create-worktree.sh feature/user-dashboard main
```

This creates:
- A new worktree at `../your-project-feature-user-dashboard/`
- A fresh copy of `.claude/` configuration in the worktree
- Independent `.claude/logs/` (separate from main)
- A new branch off the base branch

Start Claude in the worktree:

```bash
cd ../your-project-feature-user-dashboard
claude
```

---

## tmux Sessions

```bash
./claude-ultra-template/scripts/setup-tmux.sh my-project
```

Creates a tmux session with 4 named windows:

| Window | Name | Purpose |
|--------|------|---------|
| 0 | claude | Main Claude Code session |
| 1 | terminal | General terminal commands |
| 2 | tests | Running test suites |
| 3 | server | Dev server (frontend/backend) |

**Keyboard shortcuts:**
- `Ctrl+B` then `0-3` — switch windows
- `Ctrl+B` then `d` — detach session
- `tmux attach -t claude-my-project` — reattach

---

## Plugins

Optional plugins from [2389-research/claude-plugins](https://github.com/2389-research/claude-plugins). Clone the repo as a sibling directory, then run:

```bash
./claude-ultra-template/scripts/install-plugins.sh
```

**Core plugins installed:**

| Plugin | What It Does |
|--------|-------------|
| `terminal-title` | Auto-updates terminal title with emoji + project + topic |
| `fresh-eyes-review` | Pre-commit validation skill |
| `documentation-audit` | Verifies docs match codebase reality |
| `scenario-testing` | Test-driven development with real dependencies |
| `css-development` | CSS workflows with Tailwind composition |
| `better-dev` | General development best practices |
| `building-multiagent-systems` | Multi-agent coordination patterns |

**Personal plugins (optional):**

| Plugin | What It Does |
|--------|-------------|
| `ceo-personal-os` | CEO productivity frameworks and coaching |
| `product-launcher` | Launch materials generation for products |

---

## Resetting Settings

When settings get corrupted or overwritten:

```bash
# Inside Claude Code
/reset-settings

# Or from terminal
./claude-ultra-template/scripts/reset-claude-settings.sh
```

This:
1. Backs up current `~/.claude/settings.json` with timestamp
2. Restores global settings (permissions, env vars)
3. Backs up and restores project `.claude/settings.json` (hooks)
4. Makes hooks executable again

---

## File Structure

```
claude-ultra-template/
├── README.md                          # This file
├── CLAUDE.md                          # Master project instructions template
├── setup.sh                           # Main setup script (deploy to any project)
├── .env.template                      # Environment variable template
├── .claude/
│   ├── settings.json                  # Hook configuration
│   ├── agents/                        # 9 specialist agent definitions
│   │   ├── archivist.md               # Logging & knowledge management
│   │   ├── backend-dev.md             # Python/FastAPI specialist
│   │   ├── code-sentinel.md           # Security audit (report-only)
│   │   ├── debug.md                   # Deep-dive debugging
│   │   ├── fresh-eyes.md              # Final validation review
│   │   ├── frontend-dev.md            # TypeScript/React specialist
│   │   ├── integration-check.md       # Code wiring verification
│   │   ├── mermaid-architect.md       # Diagram generation
│   │   └── reviewer.md               # Code quality review
│   ├── commands/                      # 5 slash commands
│   │   ├── prompt-trail-creator.md    # THE main planning command
│   │   ├── fresh-eyes.md             # Run validation review
│   │   ├── create-skill.md           # Generate new skills
│   │   ├── reset-settings.md         # Reset to defaults
│   │   └── setup-worktree.md         # Create git worktree
│   ├── skills/                        # Auto-detected skills
│   │   ├── prompt-trail-creator/
│   │   │   └── SKILL.md
│   │   └── create-agent-skills/
│   │       └── SKILL.md
│   └── hooks/                         # Event hooks
│       ├── session-start.sh           # Terminal title + session log
│       ├── pre-tool-use.sh            # Security gate
│       ├── post-tool-use.sh           # Edit audit trail
│       └── subagent-stop.sh           # Agent tracking
└── scripts/
    ├── setup-tmux.sh                  # tmux session creator
    ├── install-plugins.sh             # Plugin installer
    ├── reset-claude-settings.sh       # Settings reset (terminal)
    └── create-worktree.sh             # Git worktree creator
```

---

## Customization

### Editing CLAUDE.md

The `CLAUDE.md` file is the master instruction set for Claude. After deploying to a project, edit the project's copy to:

- Change the tech stack section to match your project
- Add project-specific conventions
- Adjust the agent roster (add/remove agents)
- Modify logging conventions

The template copy won't overwrite an existing project `CLAUDE.md`.

### Adding agents

Create a new `.md` file in `.claude/agents/`:

```markdown
# Agent Name — Description

You are a specialist in [domain].

## Rules
1. [Rule 1]
2. [Rule 2]

## Output Format
[Define expected output structure]
```

### Adding skills

Create `.claude/skills/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: Keywords that trigger auto-detection
---

# My Skill

## When This Skill Applies
[Trigger scenarios]

## Workflow
[Steps]
```

Or use `/create-skill` inside Claude Code to generate one interactively.

### Adding slash commands

Create `.claude/commands/my-command.md`:

```markdown
# /my-command — Description

[Instructions for Claude when this command is invoked]
```

### Modifying hooks

Hooks are in `.claude/hooks/`. The pre-tool-use hook blocks modification of hook files for safety. To edit hooks:

1. Edit them directly from terminal (not via Claude Code)
2. Or use `/reset-settings` to restore defaults first

---

## Logging

All logs go to `.claude/logs/` (gitignored). This directory is created by the setup script.

| Directory | Contents | Naming |
|-----------|----------|--------|
| `sessions/` | Session start/end notes | `YYYY-MM-DD_HHMM_session.md` |
| `agents/` | Individual agent run logs | `agent-NNN_YYYY-MM-DD_type_topic.md` |
| `progress/` | Task progress tracking | `YYYY-MM-DD_topic_progress.md` |
| `reviews/` | Code review and audit results | `YYYY-MM-DD_review-type_topic.md` |
| `prompt-trails/` | Generated implementation plans | `YYYY-MM-DD_topic/00_masterplan.md` |

The agent counter (`.claude/logs/.agent-counter`) tracks sequential agent numbers across sessions.

---

## Settings Hierarchy

Claude Code reads settings from multiple locations, in order:

| File | Scope | Contains |
|------|-------|----------|
| `~/.claude/settings.json` | Global (all projects) | Permissions, env vars |
| `~/.claude/mcp.json` | Global (all projects) | MCP server configurations |
| `project/.claude/settings.json` | Project-specific | Hook configurations |
| `project/CLAUDE.md` | Project-specific | Instructions, conventions, agent roster |

**Key rule:** MCPs go in `~/.claude/mcp.json` only (global). Hooks go in project `.claude/settings.json` only (per-project).

---

## License

MIT
