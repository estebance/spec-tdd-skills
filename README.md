# Dev Harness

A personal collection of Claude Code skills and agents for spec-driven, test-driven software development. Each piece is a standalone building block; together they form a workflow from raw idea to tested, implemented code.

## Workflow

```
feature-brainstorm  →  rfc-writer            →  spec-tdd-codegen / tdd-enforcer
(explore the idea)     (write RFC + plan)       (write failing tests, then implement)
```

- **feature-brainstorm** (skill) — open-ended exploration of a problem or idea before anything gets specced. Stays conversational, produces no files.
- **rfc-writer** (skill) — turns a chosen direction into a written RFC under `specs/`, plus a linked implementation plan for feature work.
- **spec-tdd-codegen** (skill) — gated implementation: refuses to write code until a spec/plan exists (from `rfc-writer`) and failing tests already exist for it, then implements just enough to go green. Designed to run as a subagent.
- **tdd-enforcer** (agent) — enforces red-green-refactor directly: writes a failing test first, then delegates implementation to `spec-tdd-codegen` rather than writing code itself.

## Layout

- Each skill is a top-level folder containing a `SKILL.md` (YAML frontmatter with `name` + `description`, then instructions).
- Each agent is a file under `agents/<name>.md` (YAML frontmatter with `name`, `description`, `tools`, then instructions).

This repo has no plugin packaging (no `.claude-plugin/`) — it's a source/authoring location, not something Claude Code loads automatically from here.

## Installing

Claude Code doesn't load from this repo directly — skills and agents have to live under a `.claude/` directory. `install.sh` copies them there:

```sh
./install.sh --dry-run          # show what would change
./install.sh                    # sync into ~/.claude (all sessions)
./install.sh --target .claude   # sync into a project-local .claude/
```

This repo is the source of truth: anything it defines overwrites the target copy. Skills and agents in the target that this repo doesn't define are left alone. Because these are copies rather than symlinks, the target can drift — re-run the script (or `--dry-run` to check) after editing anything here.

Destinations, if you'd rather do it by hand: skill folder → `<target>/skills/<skill-name>/`, agent file → `<target>/agents/<name>.md`.
