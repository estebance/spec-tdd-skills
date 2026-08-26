---
name: rfc-writer
description: >
  Spec-driven development assistant that writes RFC and implementation plan documents for any software project change — architecture designs, features, bug fixes, or refactors. Use this skill whenever the user wants to write a spec, define a feature, plan a bugfix, document a change, design a system architecture, create an RFC, generate an implementation plan, or start any kind of development work with a written spec first. Also trigger when the user says things like "let's spec this out", "write an RFC for", "I want to add X to my project", "plan this feature", "document this change", "create an implementation plan", "generate a plan for this RFC", "design the architecture for", or describes something they want to build and asks "where do I start?". The skill bootstraps the spec directory structure if it doesn't exist, interviews the user, writes RFC files with sequential IDs, always generates a linked implementation plan for feature RFCs, keeps architecture decisions linked from CLAUDE.md, and can reorganize an existing messy specs folder.
---

# RFC Writer

You help the user practice spec-driven development. Every change starts with a written RFC before any code is touched. Every feature RFC is followed by a detailed implementation plan — not optional, always generated. Architecture RFCs stay linked from `CLAUDE.md` so the project's design is never buried in `specs/`. Your job: set up the right structure, gather context, write the documents, and keep everything organized.

## Directory structure

All specs live under `specs/` in the project root:

```
specs/
├── arch/                # Architecture design RFCs — system structure, infra architecture, ADRs, major design decisions
├── feat/                # Feature RFCs
├── fix/                 # Bug fix RFCs
├── refactor/            # Refactor RFCs
├── plans/               # Detailed technical implementation plans (mandatory for every feat, optional for fix/refactor)
└── README.md            # Spec index — the single source of truth for all files
```

All feature intake goes straight through `feat/` — there's no separate staging folder for raw requirements. If the user hands you a problem description or feature idea, that's the seed of the interview for a new `feat` RFC, not a file to park somewhere first.

## Step 0: Bootstrap, audit, or proceed

### `specs/` doesn't exist yet

Create the full directory structure above. Briefly explain to the user what each folder is for. If there's an existing `docs/` folder with RFC-like content, offer to migrate those files into the new structure.

Also make sure `CLAUDE.md` exists at the project root (create a minimal one if it doesn't) and contains an `## Architecture` section — even if it's just a pointer sentence ("See `specs/arch/` for architectural decisions.") with an empty list underneath. This is where every architecture RFC gets linked from, so the project's design is discoverable without digging through `specs/`.

### `specs/` exists but looks disorganized

Before writing anything new, audit the existing contents:
- Files not following the `<type>-<id>-<slug>.md` naming convention
- Files that appear to be in the wrong subfolder (e.g., a bug fix RFC sitting in `feat/`, or an architecture decision sitting in `refactor/`)
- Missing subfolders (`arch/`, `feat/`, `fix/`, `refactor/`, `plans/`)
- `arch/` docs that aren't linked from `CLAUDE.md`'s `## Architecture` section, or links there pointing at files that no longer exist

Produce a concrete reorganization plan: list each file with a clear before → after, plus any `CLAUDE.md` link fixes needed. Ask the user to confirm before moving or renaming anything. Once confirmed, execute the moves and update the index.

### `specs/` looks healthy

Proceed directly to the RFC workflow.

## File identifiers

Every RFC — across `arch/`, `feat/`, `fix/`, and `refactor/` — gets a unique, sequential, zero-padded 3-digit ID, drawn from one shared counter across all types. Filename format: `<type>-NNN-slug.md`, e.g. `feat-003-user-auth.md`, `arch-002-api-gateway.md`.

To find the next available ID, scan all `.md` files under `specs/`:

```bash
find specs/ -name "*.md" | grep -oE '[a-z]+-[0-9]{3}-' | grep -oE '[0-9]{3}' | sort -n | tail -1
```

Increment by 1, zero-pad to 3 digits. If no files exist yet, start at `001`.

A plan does **not** draw a new ID — it reuses its parent feat's ID, so the pairing is obvious from the filename alone: `feat-003-user-auth.md` pairs with `plans/plan-003-user-auth.md`.

Reference files in prose and in the index as `RFC-NNN` (for RFCs) or `Plan-NNN` (for plans).

## The RFC workflow

### 1. Identify the change type and slug

Determine the type (`arch` / `feat` / `fix` / `refactor`) and a short kebab-case slug. The file path will be: `specs/<type>/<type>-NNN-<slug>.md`

### 2. Interview the user

Ask only what you don't already know from context already shared in conversation. The minimum you need:

- **Why** — What problem does this solve? Who is affected?
- **What** — What will be built or changed? Describe the end state.
- **How** — Key steps, decisions, constraints.
- **Done when** — Concrete, testable acceptance criteria.

For small changes (a simple fix, a refactor), this can be 1–2 exchanges. For large features or architecture decisions, a bit more. Use your judgment — don't over-interview.

### 3. Write the RFC

```markdown
# RFC-NNN: <Title>

**Type:** <arch | feat | fix | refactor>
**Status:** draft
**Created:** <YYYY-MM-DD>
**Slug:** <slug>
**Plan:** <Plan-NNN, only for feat — added once the plan is generated in step 4>

## Problem

<Why this change is needed. What's broken, missing, or suboptimal? Who is affected?>

## Proposed Solution

<What will be built or changed. Be concrete — describe the end state, not the journey.>

## Implementation Plan

<High-level steps — discrete and completable, but not line-by-line detail. That level of detail belongs in a Plan file.>

1. Step one
2. Step two
3. ...

## Acceptance Criteria

<How we know this is done. Each criterion should be independently verifiable.>

- [ ] Criterion one
- [ ] Criterion two

## Open Questions

<Unresolved decisions that need an answer before or during implementation. Delete this section if there are none.>
```

### 4. Link architecture RFCs into CLAUDE.md

If the RFC you just wrote is type `arch`, immediately update `CLAUDE.md`'s `## Architecture` section with a link to it (add the section if it's somehow missing). This isn't optional and isn't something to ask permission for — an architecture decision that isn't linked from `CLAUDE.md` is effectively invisible to future work on the project, including future Claude sessions that rely on `CLAUDE.md` for orientation.

### 5. Generate the implementation plan

For a `feat` RFC, always generate a linked implementation plan — don't ask, just do it. A feature isn't done being specced until the plan exists.

For `fix` and `refactor` RFCs, ask: "Want me to generate a detailed implementation plan for this?" — these are often small enough that the RFC itself is sufficient.

A plan lives at `specs/plans/plan-NNN-<slug>.md`, reusing the parent RFC's numeric ID (see [File identifiers](#file-identifiers)). It references the parent RFC and breaks the work into phases and granular tasks — the kind of thing you'd execute step by step, like Claude Code's plan mode. Once the plan exists, add the `**Plan:**` line back into the RFC header pointing to it.

#### Plan format

```markdown
# Plan-NNN: <Title> — Implementation Plan

**RFC:** RFC-<parent-id>
**Status:** draft
**Created:** <YYYY-MM-DD>

## Overview

<One paragraph: what this plan covers and the overall approach.>

## Prerequisites

<Anything that must be true before starting — other RFCs completed, environment setup, data migrations, etc. Leave blank if none.>

## Tasks

### Phase 1: <Phase name>

- [ ] **Task 1.1** — <specific, actionable step>
  - Files: `path/to/file.ts`
  - Notes: <relevant detail, edge case, or decision>
- [ ] **Task 1.2** — <specific, actionable step>

### Phase 2: <Phase name>

- [ ] **Task 2.1** — ...

## Verification

<How to confirm the plan was executed correctly — test commands, expected outputs, smoke tests.>
```

### 6. Update the spec index

After writing any file, update `specs/README.md`. Create it if it doesn't exist. Add the new row; never remove or reorder existing rows.

```markdown
# Spec Index

| ID | Type | Title | Status | Created |
|----|------|-------|--------|---------|
| [RFC-001](arch/arch-001-api-gateway-design.md) | arch | API Gateway Design | draft | 2024-01-15 |
| [RFC-002](feat/feat-002-user-auth.md) | feat | User Authentication | draft | 2024-01-15 |
| [Plan-002](plans/plan-002-user-auth.md) | plan | User Auth — Implementation Plan | draft | 2024-01-15 |
| [RFC-003](fix/fix-003-login-crash.md) | fix | Login Crash Fix | draft | 2024-01-16 |
```

## Principles

**Stay lean.** A good RFC for a small bugfix might be 15 lines. A plan for a large feature might be 100 lines. Don't pad.

**Be concrete.** "Implement the feature" is not a step. "Add `POST /api/sessions` endpoint that validates credentials against the users table" is a step.

**Write for a future reader.** The document should make sense to someone who wasn't in the conversation — including the user themselves in three months.

**Extract before asking.** If the user already shared context in conversation or `CLAUDE.md` already documents relevant constraints, extract what you can from there before firing off interview questions.

**Architecture stays visible.** Every `arch/` doc is linked from `CLAUDE.md`'s `## Architecture` section — that's how the rest of the project, and future Claude sessions, discover the design without hunting through `specs/`.

**Every feature ships with a plan.** A `feat` RFC without a linked plan is incomplete. Generate the plan automatically as part of writing the feat — don't ask.

**IDs are permanent.** Once a file is written and indexed as `RFC-NNN`, that ID never changes — even if the file is moved or renamed during reorganization. A plan's ID is tied to its parent feat's ID for the same reason.
