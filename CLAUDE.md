# CLAUDE.md

This repo is a source/authoring location for Claude Code skills and agents (see `README.md` for the workflow they form together). It is not itself a plugin and is not auto-loaded by Claude Code — `install.sh` copies its skills and agents into `~/.claude/` (or a project's `.claude/`). After editing a skill or agent here, that copy is stale until the script is re-run; `./install.sh --dry-run` shows what has drifted.

## Delegation

When the user asks to implement, build, ship, or apply a change that has a spec under `specs/`, spawn the `tdd-implementer` agent via the Agent tool. Do **not** invoke `tdd-test-writer` or `spec-tdd-codegen` directly from the main session — `tdd-implementer` owns their ordering, and the whole point of the agent is that the test author and the code author never share a context.

This paragraph is load-bearing, not documentation. Claude Code sessions are frequently given a system-prompt instruction not to use the Agent tool "unless the user, a CLAUDE.md file, or a skill asks for it" — a CLAUDE.md asking for it is one of the three sanctioned ways to authorize the delegation, so removing this section will silently stop the agent from being spawned. The same stanza has to be copied into any repo where this harness is used; `README.md` carries a paste-ready copy.

## Conventions

- **Skills**: one top-level folder per skill, containing `SKILL.md`. Frontmatter is `name` + `description`, plus optionally `context` (`inline` | `fork` — `fork` runs the skill in its own context, which is how the two TDD skills stay isolated from each other). The `description` must be specific enough to trigger correctly (state exactly what phrases/situations invoke it, and what it explicitly does *not* do if it's easily confused with a neighboring skill).
- **Don't let a callee claim its caller's triggers.** A skill that a *skill* or *agent* is supposed to invoke must not advertise the phrases that should route to that caller — on a tie the skill wins (it loads in-context, with no agent spawn), so the entry point gets bypassed by its own sub-step. Descriptions for callee skills should say who invokes them and when, not what the user might type.
- **Agents**: one file per agent under `agents/<name>.md`. Frontmatter fields are `name`, `description`, `tools` (comma-separated allowlist), and optionally `model`. No other frontmatter keys are recognized — anything else is silently ignored. If an agent needs to invoke a skill, say so explicitly in the body and include `Skill` in its `tools` list; there is no frontmatter field for declaring skill dependencies.
- **No plugin packaging.** Don't add `.claude-plugin/plugin.json` or a marketplace manifest unless the project's scope explicitly changes to "installable plugin" — that was a deliberate choice, not an oversight.
- Keep skills and agents composable: a skill/agent should do one job well and explicitly hand off to the next one in the chain (see `README.md`) rather than absorbing its responsibilities.
