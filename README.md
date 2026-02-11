# Claude Code Ultra

A self-orchestrating agent framework for long-running Claude Code sessions. Predefined agents, skills, hooks, slash commands, and MCP integrations — deploy to any project with one command.

---

## Table of Contents

- [Claude Code Ultra](#claude-code-ultra)
  - [Table of Contents](#table-of-contents)
  - [Quick Start](#quick-start)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
    - [Step 1: Clone the template](#step-1-clone-the-template)
    - [Step 2: Set up environment variables](#step-2-set-up-environment-variables)
    - [Step 3: Configure global settings](#step-3-configure-global-settings)
    - [Step 4: Deploy to your project](#step-4-deploy-to-your-project)
  - [Deploying to a Project](#deploying-to-a-project)
  - [What Gets Deployed](#what-gets-deployed)
  - [Usage](#usage)
    - [Slash Commands](#slash-commands)
    - [Prompting Guide](#prompting-guide)
    - [Working with Prompt Trails](#working-with-prompt-trails)
  - [Agents](#agents)
  - [MCP Tools](#mcp-tools)
    - [WhatsApp MCP (Separate Setup — Local Only)](#whatsapp-mcp-separate-setup--local-only)
      - [Step 1: Clone and build](#step-1-clone-and-build)
      - [Step 2: Pair with WhatsApp](#step-2-pair-with-whatsapp)
      - [Step 3: Register as project-local MCP](#step-3-register-as-project-local-mcp)
      - [Step 4: Add security guardrails to CLAUDE.md](#step-4-add-security-guardrails-to-claudemd)
  - [Hooks](#hooks)
  - [tmux Sessions](#tmux-sessions)
  - [Git Worktrees](#git-worktrees)
  - [Plugins (Optional)](#plugins-optional)
  - [Resetting Settings](#resetting-settings)
  - [Customization](#customization)
    - [CLAUDE.md — What to Personalize](#claudemd--what-to-personalize)
    - [Adding a new agent](#adding-a-new-agent)
    - [Adding a new skill (auto-detected)](#adding-a-new-skill-auto-detected)
    - [Adding a new slash command](#adding-a-new-slash-command)
    - [Editing hooks](#editing-hooks)
  - [Settings Hierarchy](#settings-hierarchy)
  - [Repository Structure](#repository-structure)
  - [Logging](#logging)
  - [License](#license)

---

## Quick Start

```bash
# 1. Clone
git clone https://github.com/ghollbeck/claude-ultra-template.git
cd claude-ultra-template

# 2. Deploy to your project
./setup.sh /path/to/your/project

# 3. Start coding
cd /path/to/your/project
claude
```

Inside Claude Code, you now have access to all agents, commands, and skills:

```
/prompt-trail-creator    Plan a complex task
/fresh-eyes              Validate all changes
/create-skill            Generate a new skill
```

---

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) (v2.1+)
- [Node.js](https://nodejs.org/) (v18+) — required for MCP servers via `npx`
- macOS or Linux

**Optional:**
- `tmux` — `brew install tmux` (for multi-window terminal sessions)
- `jq` — `brew install jq` (used by the settings reset script)

---

## Installation

### Step 1: Clone the template

```bash
git clone https://github.com/ghollbeck/claude-ultra-template.git
```

You can clone it anywhere. All scripts resolve paths relative to their own location.

### Step 2: Set up environment variables

Check what's needed:

```bash
cat claude-ultra-template/.env.template
```

Add your keys to `~/.zshenv` (or `~/.bashrc`):

```bash
# GitHub (required for GitHub MCP)
export GITHUB_TOKEN="ghp_your_token"

# Optional — only needed if you use these MCPs
export SUPABASE_PROJECT_REF="your-project-ref"
export SUPABASE_ACCESS_TOKEN="your-supabase-token"
export RENDER_API_KEY="your-render-key"
export PERPLEXITY_API_KEY="pplx-your-key"
export SLACK_BOT_TOKEN="xoxb-your-slack-token"
export SLACK_TEAM_ID="T01234567"
```

Reload your shell: `source ~/.zshenv`

### Step 3: Configure global settings

**Permissions** — create or update `~/.claude/settings.json`:

```json
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
```

**MCPs** — create or update `~/.claude/mcp.json` (see [MCP Tools](#mcp-tools) for the full config). MCPs are configured globally so they're available in every project.

### Step 4: Deploy to your project

Run this in the folder where you have cloned this repo to. so ....../claude-ultra-template or so and the within there, run this 

```bash
./setup.sh /path/to/your/project
```
(/path/to/your/project = where you want to use your agent)

Done. Open Claude Code in that project and everything is ready.

---

## Deploying to a Project

```bash
# Existing project
./setup.sh /path/to/project

# New project
mkdir /path/to/new-project && ./setup.sh /path/to/new-project

# With git worktree
./setup.sh /path/to/project --worktree feature/my-feature
```

**What `setup.sh` does:**

| Step | Action | Overwrites? |
|------|--------|-------------|
| 1 | Copies `.claude/agents/`, `.claude/commands/`, `.claude/skills/` | Yes (always updates) |
| 2 | Copies `.claude/hooks/*.sh` | No (only new hooks) |
| 3 | Copies `.claude/settings.json` | No (only if missing) |
| 4 | Copies `CLAUDE.md` | No (only if missing) |
| 5 | Creates `.claude/logs/` directories | Creates if missing |
| 6 | Adds `.claude/logs/` to `.gitignore` | Appends if not present |
| 7 | Makes hooks executable | Always |

**Safe to re-run.** It merges — never overwrites your project-specific customizations in hooks, settings, or CLAUDE.md.

---

## What Gets Deployed

After running `setup.sh`, your project gets:

```
your-project/
├── CLAUDE.md                              # Project instructions for Claude
└── .claude/
    ├── settings.json                      # Hook configurations
    ├── agents/                            # 9 specialist agents
    │   ├── archivist.md                   #   Logging & knowledge management
    │   ├── backend-dev.md                 #   Python/FastAPI specialist
    │   ├── code-sentinel.md               #   Security audit (report-only)
    │   ├── debug.md                       #   Deep-dive debugging
    │   ├── fresh-eyes.md                  #   Final validation (zero context)
    │   ├── frontend-dev.md                #   TypeScript/React specialist
    │   ├── integration-check.md           #   Code wiring verification
    │   ├── mermaid-architect.md           #   Mermaid diagram generation
    │   └── reviewer.md                    #   Code quality review
    ├── commands/                           # 5 slash commands
    │   ├── prompt-trail-creator.md        #   THE main planning command
    │   ├── fresh-eyes.md                  #   Run validation review
    │   ├── create-skill.md                #   Generate new skills
    │   ├── reset-settings.md              #   Reset to defaults
    │   └── setup-worktree.md              #   Create git worktree
    ├── skills/                             # 2 auto-detected skills
    │   ├── prompt-trail-creator/SKILL.md
    │   └── create-agent-skills/SKILL.md
    ├── hooks/                              # 4 event hooks
    │   ├── session-start.sh               #   Terminal title + session log
    │   ├── pre-tool-use.sh                #   Security gate
    │   ├── post-tool-use.sh               #   Edit audit trail
    │   └── subagent-stop.sh               #   Agent completion tracking
    └── logs/                               # Centralized logging (gitignored)
        ├── sessions/
        ├── agents/
        ├── progress/
        ├── reviews/
        └── prompt-trails/
```

---

## Usage

### Slash Commands

Type these inside Claude Code:

| Command | What It Does |
|---------|-------------|
| `/prompt-trail-creator` | Interactive 3-phase workflow: (1) explores codebase, (2) asks clarifying questions, (3) generates numbered prompt trail files with agent assignments, tool selections, and validation steps. **Start here for any non-trivial task.** |
| `/fresh-eyes` | Spawns the `@fresh-eyes` agent with zero prior context. Runs tests, reads git diff, checks logs, screenshots UI. Returns APPROVED / NEEDS_FIXES / MAJOR_ISSUES. |
| `/create-skill` | Generates a new Claude Code skill interactively. Asks what it should do, designs the file structure, creates SKILL.md files, and installs them. |
| `/reset-settings` | Nuclear reset of Claude settings to template defaults. Backs up current settings first. Use when configs get corrupted. |
| `/setup-worktree` | Creates a git worktree for parallel branch work. Copies Claude config into the new worktree automatically. |

### Prompting Guide

**Quick tasks** — just describe what you need:

```
Fix the 500 error on the /api/users endpoint.
```
```
Add a dark mode toggle to the settings page.
```
```
Write tests for the authentication middleware.
```

Claude selects the right agent automatically.

**Complex tasks** — use the prompt trail creator:

```
/prompt-trail-creator
```

Then describe your task. It will explore your code, ask questions, and generate a step-by-step plan.

**Validation** — run anytime:

```
/fresh-eyes
```

Runs automatically at the end of long prompt trails.

**Debugging** — structured investigation:

```
Use the @debug agent to investigate why the login endpoint returns 500.
```

Max 5 attempts with hypothesis tracking. Escalates if stuck.

**Security review** — report-only:

```
Run @code-sentinel on the authentication module.
```

**Architecture diagrams** — Mermaid output:

```
Use @mermaid-architect to diagram the current system architecture.
```

### Working with Prompt Trails

Prompt trails are the core workflow for complex, multi-file tasks.

**What they are:** Numbered markdown files, each containing instructions for one agent to execute one step. They form a linked list — each step points to the next.

**Where they live:** `.claude/logs/prompt-trails/YYYY-MM-DD_topic/`

**Structure:**

```
.claude/logs/prompt-trails/2025-02-07_user-dashboard/
├── 00_masterplan.md      # Goal, components, agent pipeline, success criteria
├── 01_backend-api.md     # @backend-dev: create API endpoints
├── 02_database.md        # @backend-dev: create migrations
├── 03_frontend-ui.md     # @frontend-dev: build UI components
├── 04_integration.md     # @integration-check: verify wiring
├── 05_review.md          # @reviewer: check code quality
└── 06_validation.md      # @fresh-eyes: final validation + @mermaid-architect diagram
```

**Each step file specifies:**
- Agent assignment (which agent runs this step)
- Dependencies (which steps must complete first)
- Implementation instructions (specific enough to execute without ambiguity)
- Files to create/modify (exact paths)
- Validation commands (test commands to verify the step)
- Commit message template
- Next step pointer

**Running a trail:**

```
Read .claude/logs/prompt-trails/2025-02-07_user-dashboard/00_masterplan.md
and execute the trail starting from step 01.
```

Or one step at a time:

```
Execute step 03 from .claude/logs/prompt-trails/2025-02-07_user-dashboard/03_frontend-ui.md
```

---

## Agents

Specialist subagents, each with a defined scope and output format:

| Agent | Scope | Key Behavior |
|-------|-------|-------------|
| `backend-dev` | Python/FastAPI | Creates Alembic migrations, writes pytest tests, uses Supabase MCP |
| `frontend-dev` | TypeScript/React | Tailwind + custom CSS, uses Puppeteer for visual verification |
| `debug` | Bug investigation | Max 5 attempts with hypothesis tracking (Ralph Wiggum pattern). Escalates if stuck. |
| `reviewer` | Code review | CRITICAL/HIGH/MEDIUM/LOW/NITPICK findings. Review-only — never modifies code. |
| `integration-check` | Wiring verification | Detects ORPHANED_FILE, DEAD_IMPORT, MISSING_EXPORT, CIRCULAR_RISK |
| `code-sentinel` | Security audit | OWASP Top 10 + framework-specific checks. Report-only — never modifies code. |
| `archivist` | Logging | Manages `.claude/logs/` with naming conventions and sequential agent counter |
| `fresh-eyes` | Final validation | Zero prior context. Runs tests, reads diff, screenshots UI. |
| `mermaid-architect` | Diagrams | Architecture, data flow, component, and task flow Mermaid diagrams |

**Invoke agents directly:**

```
Use the @debug agent to investigate why tests are failing.
Run @integration-check on the files I just created.
Run @code-sentinel on the authentication module.
```

Or let the prompt trail creator assign them automatically.

---

## MCP Tools

Configure these globally in `~/.claude/mcp.json` so they're available in every project:

| MCP | Purpose | Example Prompt |
|-----|---------|----------------|
| **Supabase** | Database, auth | "Query the users table" |
| **DeepWiki** | Library docs | "How does FastAPI dependency injection work?" |
| **Render** | Deployment | "Deploy the latest commit" |
| **GitHub** | PRs, issues | "Create a PR for this branch" |
| **Perplexity** | Web research | "Find the latest React 19 migration guide" |
| **Puppeteer** | Browser automation | "Screenshot the login page" |
| **Chrome DevTools** | Performance, debugging, browser control | "Check performance of the homepage" |
| **Slack** | Notifications | "Post status update to #dev" |

<details>
<summary><strong>Full MCP configuration (click to expand)</strong></summary>

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
    "chrome-devtools": {
      "command": "npx",
      "args": ["chrome-devtools-mcp@latest"]
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

</details>

i think before claude sees the mcps, you either have to resatart claude or even run claude mcp list or claude /mcp


All MCPs are optional. The framework works without them — they just add capabilities.

### WhatsApp MCP (Separate Setup — Local Only)

The WhatsApp MCP is **not included** in the global `setup-mcps.sh` script. It connects to your personal WhatsApp account via the Baileys library and must be configured **per-project** (local scope only, never global).

**Why separate?** It holds your WhatsApp session credentials locally and should only be active in projects where you explicitly want WhatsApp access.

#### Step 1: Clone and build

```bash
git clone https://github.com/jlucaso1/whatsapp-mcp-ts.git
cd whatsapp-mcp-ts
npm install
```

#### Step 2: Pair with WhatsApp

```bash
npx tsx src/main.ts
```

On first run, it shows a QR code. Scan it with WhatsApp on your phone (Linked Devices > Link a Device). Credentials are saved to `./auth_info/` — subsequent runs reconnect automatically.

#### Step 3: Register as project-local MCP

In the project where you want WhatsApp access:

```bash
claude mcp add whatsapp -s project -- node /path/to/whatsapp-mcp-ts/src/main.ts
```

Or add manually to your **project's** `.claude/mcp.json` (not the global one):

```json
{
  "mcpServers": {
    "whatsapp": {
      "command": "node",
      "args": ["/path/to/whatsapp-mcp-ts/src/main.ts"],
      "timeout": 15
    }
  }
}
```

#### Step 4: Add security guardrails to CLAUDE.md

The template `CLAUDE.md` already includes WhatsApp security rules. Update the allowed recipient number in your project's `CLAUDE.md`:

```markdown
# WhatsApp MCP — Security
- Send messages ONLY to: `+1XXXXXXXXXX`  ← your allowed number
```

This ensures Claude can only message the number you specify — never anyone else.

---

## Hooks

Fire automatically on Claude Code events. Configured in `.claude/settings.json`:

| Hook | Trigger | What It Does |
|------|---------|-------------|
| `session-start.sh` | SessionStart | Sets terminal title with emoji + project + date. Creates session log file. |
| `pre-tool-use.sh` | PreToolUse (Edit, Write, Bash) | Security gate: blocks hook file modification, `rm -rf /`, `chmod 777`, `eval()`. |
| `post-tool-use.sh` | PostToolUse (Edit, Write) | Appends every file edit to `.claude/logs/.edit-log.jsonl` for audit trail. |
| `subagent-stop.sh` | SubagentStop | Logs agent completion event. Increments sequential agent counter. |

---

## tmux Sessions

```bash
./scripts/setup-tmux.sh my-project
```

Creates a tmux session with 4 named windows:

| Window | Name | Purpose |
|--------|------|---------|
| 0 | claude | Main Claude Code session |
| 1 | terminal | General terminal commands |
| 2 | tests | Running test suites |
| 3 | server | Dev server |

Switch windows: `Ctrl+B` then `0`-`3`. Detach: `Ctrl+B` then `d`. Reattach: `tmux attach -t claude-my-project`.

---

## Git Worktrees

Work on multiple branches in parallel, each with its own Claude config:

```bash
# Inside Claude Code
/setup-worktree

# Or from terminal
./scripts/create-worktree.sh feature/user-dashboard main
```

Creates a worktree at `../your-project-feature-user-dashboard/` with a full `.claude/` copy and independent logs. Start Claude there with:

```bash
cd ../your-project-feature-user-dashboard && claude
```

---

## Plugins (Optional)

Extra skills from [2389-research/claude-plugins](https://github.com/2389-research/claude-plugins).

Clone it as a **sibling directory** of this template, then run the installer:

```bash
# From the parent directory of claude-ultra-template:
git clone https://github.com/2389-research/claude-plugins.git
cd claude-ultra-template
./scripts/install-plugins.sh
```

**Plugins installed:**

| Plugin | What It Does |
|--------|-------------|
| `terminal-title` | Auto-updates terminal title with emoji + project + topic |
| `fresh-eyes-review` | Pre-commit validation skill |
| `documentation-audit` | Verifies docs match codebase |
| `scenario-testing` | Test-driven development with real dependencies |
| `css-development` | CSS workflows with Tailwind composition |
| `better-dev` | General development best practices |
| `building-multiagent-systems` | Multi-agent coordination patterns |
| `ceo-personal-os` | CEO productivity frameworks |
| `product-launcher` | Product launch materials generation |

Plugins install to `~/.claude/skills/` (globally available).

---

## Resetting Settings

When configs get corrupted or overwritten:

```bash
# Inside Claude Code
/reset-settings

# Or from terminal
./scripts/reset-claude-settings.sh
```

This backs up current settings (timestamped), restores global permissions and MCP configs, restores project hooks, and makes hook scripts executable again.

---

## Customization

### CLAUDE.md — What to Personalize

The `CLAUDE.md` template defines Claude's behavior: tech stack, conventions, agent roster, logging rules, commit protocol. After deploying, edit the **project copy** to match your stack. The template never overwrites an existing project `CLAUDE.md`.

**You MUST customize these sections after deploying:**

| Section | What to Change | Example in Template |
|---------|---------------|---------------------|
| **Names & nicknames** | Replace with your own names/aliases. Claude uses these to address you. | `"Gáborovka"` (casual), `"Gabriel Mayflower"` (formal), `"Mr. Rosengarten"` (delivering work) |
| **Our Relationship** | Update the personality description to match your working style | `"Gáborovka is smart, but not infallible..."` |
| **Tech Stack** | Change to your actual stack (language, framework, DB, deployment) | Python/FastAPI + TypeScript/React + Supabase + Render |
| **WhatsApp allowed number** | If using WhatsApp MCP, set your allowed recipient number | `WHATSAPP_ALLOWED_RECIPIENT` env var reference |

**Quick find-and-replace after deploy:**

```bash
# In your project's CLAUDE.md, replace these placeholders:
# "Gáborovka"         → your casual nickname
# "Gabriel Mayflower" → your formal name
# "Mr. Rosengarten"   → your completion-delivery name
```

Everything else (git protocol, agent roster, logging rules, decision framework) works out of the box and only needs editing if your workflow differs.

### Adding a new agent

Create `.claude/agents/my-agent.md`:

```markdown
# My Agent — Description

You are a specialist in [domain].

## Rules
1. [Constraint 1]
2. [Constraint 2]

## Output Format
[Expected structure]
```

### Adding a new skill (auto-detected)

Create `.claude/skills/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: Trigger keywords for auto-detection
---

# My Skill

## When This Skill Applies
[Trigger scenarios]

## Workflow
[Steps]
```

Or use `/create-skill` inside Claude Code to generate one interactively.

### Adding a new slash command

Create `.claude/commands/my-command.md`:

```markdown
# /my-command — Short description

[Instructions for Claude when this command is invoked]
```

### Editing hooks

The pre-tool-use hook blocks modification of hook files from inside Claude Code (security). To edit hooks, either:
1. Edit directly from your terminal/editor
2. Run `/reset-settings` to restore defaults first

---

## Settings Hierarchy

Claude Code reads from multiple locations:

| File | Scope | Contains |
|------|-------|----------|
| `~/.claude/settings.json` | Global | Permissions, env vars |
| `~/.claude/mcp.json` | Global | MCP server configs |
| `project/.claude/settings.json` | Per-project | Hook configurations |
| `project/CLAUDE.md` | Per-project | Instructions, conventions, agent roster |

**Rule of thumb:** MCPs in `mcp.json` (global, available everywhere). Hooks in project `settings.json` (per-project). Never mix them.

---

## Repository Structure

```
claude-ultra-template/
├── README.md                    # This file
├── CLAUDE.md                    # Master project instructions template
├── CLAUDE_HarperReed.md         # Alternative CLAUDE.md example (Harper Reed style)
├── setup.sh                     # Deploy to any project (portable)
├── .env.template                # Environment variable reference
├── .gitignore                   # Git exclusions
├── .claude/
│   ├── settings.json            # Hook configuration
│   ├── agents/                  # 9 specialist agents
│   ├── commands/                # 5 slash commands
│   ├── skills/                  # 2 auto-detected skills
│   └── hooks/                   # 4 event hooks
└── scripts/
    ├── setup-mcps.sh            # Register MCP servers via claude CLI
    ├── install-to-project.sh    # Alternative installer (agents, skills, hooks only)
    ├── setup-tmux.sh            # tmux session creator
    ├── install-plugins.sh       # Plugin installer (needs claude-plugins sibling)
    ├── reset-claude-settings.sh # Settings reset from terminal
    └── create-worktree.sh       # Git worktree creator
```

---

## Logging

All logs go to `.claude/logs/` in the deployed project (gitignored):

| Directory | Contents | Naming Pattern |
|-----------|----------|----------------|
| `sessions/` | Session start/end notes | `YYYY-MM-DD_HHMM_session.md` |
| `agents/` | Individual agent logs | `agent-NNN_YYYY-MM-DD_type_topic.md` |
| `progress/` | Task progress | `YYYY-MM-DD_topic_progress.md` |
| `reviews/` | Code reviews, audits | `YYYY-MM-DD_review-type_topic.md` |
| `prompt-trails/` | Implementation plans | `YYYY-MM-DD_topic/00_masterplan.md` |

Agent counter (`.claude/logs/.agent-counter`) tracks sequential agent numbers across sessions — never resets.

---

## License

MIT
