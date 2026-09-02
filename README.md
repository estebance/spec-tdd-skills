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

The two implementation skills stay caller-agnostic in their *mechanics* — either can be invoked on its own, or from a subagent Claude spawns itself — but their descriptions deliberately do **not** advertise the entry-point phrases ("implement RFC-004", "build this feature"). Those route to `tdd-implementer`, which then calls the skills in order. Without that split the skills win the trigger on a tie (a skill loads in-context, with no agent spawn), and the agent that exists to enforce the ordering never gets spawned at all.

## Layout

- Each skill is a top-level folder containing a `SKILL.md` (YAML frontmatter with `name` + `description`, optionally `context: inline | fork`, then instructions).
- Each agent is a file under `agents/<name>.md` (YAML frontmatter with `name`, `description`, `tools`, optionally `model`, then instructions). Other keys — a `skills:` list, say — are silently ignored; declare skill dependencies in the body and put `Skill` in `tools`.

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

## One more step per project: authorize the delegation

Installing the files is not enough to get `tdd-implementer` spawned. Claude Code sessions are frequently given a system-prompt instruction not to use the Agent tool *"unless the user, a CLAUDE.md file, or a skill asks for it"* — so unless something asks, Claude does the work itself in the main context and the agent sits unused. A `CLAUDE.md` asking for it is one of the three sanctioned ways to authorize it, and it's the only one that doesn't require re-typing the request every session.

Paste this into the `CLAUDE.md` of any repo where you want the workflow to route itself:

```markdown
## Delegation

When I ask to implement, build, ship, or apply a change that has a spec under `specs/`,
spawn the `tdd-implementer` agent via the Agent tool. Do not invoke `tdd-test-writer` or
`spec-tdd-codegen` directly from the main session — `tdd-implementer` owns their ordering,
and the point of the agent is that the test author and the code author never share a context.
```

Skills don't need this — they're invoked from the main context and aren't covered by the restriction. It's only agent spawning that has to be asked for.
