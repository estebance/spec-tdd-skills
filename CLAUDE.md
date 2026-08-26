# CLAUDE.md

This repo is a source/authoring location for Claude Code skills and agents (see `README.md` for the workflow they form together). It is not itself a plugin and is not auto-loaded by Claude Code — pieces get copied or symlinked into `~/.claude/` or a target project's `.claude/`.

## Conventions

- **Skills**: one top-level folder per skill, containing `SKILL.md`. Frontmatter is `name` + `description` only — the `description` must be specific enough to trigger correctly (state exactly what phrases/situations invoke it, and what it explicitly does *not* do if it's easily confused with a neighboring skill).
- **Agents**: one file per agent under `agents/<name>.md`. Frontmatter fields are `name`, `description`, `tools` (comma-separated allowlist), and optionally `model`. No other frontmatter keys are recognized — anything else is silently ignored. If an agent needs to invoke a skill, say so explicitly in the body and include `Skill` in its `tools` list; there is no frontmatter field for declaring skill dependencies.
- **No plugin packaging.** Don't add `.claude-plugin/plugin.json` or a marketplace manifest unless the project's scope explicitly changes to "installable plugin" — that was a deliberate choice, not an oversight.
- Keep skills and agents composable: a skill/agent should do one job well and explicitly hand off to the next one in the chain (see `README.md`) rather than absorbing its responsibilities.
