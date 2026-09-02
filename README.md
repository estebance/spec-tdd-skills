# Dev Harness

A personal collection of Claude Code skills and agents for spec-driven, test-driven software development. Each piece is a standalone building block; together they form a workflow from raw idea to tested, implemented code.

## Workflow

```
feature-brainstorm  →  rfc-writer  →  tdd-implementer
(explore the idea)     (write RFC     (conduct the cycle:
                         + plan)       tdd-test-writer in a separate
                                       context, then spec-tdd-codegen,
                                       then green + refactor)
```

- **feature-brainstorm** (skill) — open-ended exploration of a problem or idea before anything gets specced. Stays conversational and writes no files, but closes with a *brainstorm brief* in the chat (direction chosen, alternatives rejected and why, constraints, open questions) whose sections line up with the fields `rfc-writer` interviews for.
- **rfc-writer** (skill) — turns a chosen direction into a written RFC under `specs/`, plus a linked implementation plan for feature work.
- **tdd-implementer** (agent) — the entry point for building anything that's been specced. Finds the spec, gets the constraining tests written in a context that isn't its own, implements against the plan, and lands it green with a refactor pass. It owns the sequence, not any single beat of it.
- **tdd-test-writer** (skill) — classifies the change, confirms the spec exists, and writes the failing (or characterization) test that will constrain the implementation, then reports back. Belongs in a context separate from the one writing the code — usually a `general-purpose` subagent, spawned by `tdd-implementer` or directly by Claude.
- **spec-tdd-codegen** (skill) — gated implementation: refuses to write code until a spec exists (from `rfc-writer`) and the tests are in the right state, then implements just enough to satisfy the plan.

The two implementation skills are deliberately caller-agnostic — `tdd-implementer` is the normal way to run them in the right order, but either can be invoked on its own, or from a subagent Claude spawns itself.

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

**Renames need a manual cleanup.** Since the script never deletes, renaming a skill/agent here — or moving one from `agents/` to a skill folder — leaves the old copy installed in the target, where it goes on competing for the same triggers with stale instructions. Delete the orphan by hand after renaming.

Destinations, if you'd rather do it by hand: skill folder → `<target>/skills/<skill-name>/`, agent file → `<target>/agents/<name>.md`.
