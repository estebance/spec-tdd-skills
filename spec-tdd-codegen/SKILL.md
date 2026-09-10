---
name: spec-tdd-codegen
description: >
  Writes the code for one step of a TDD cycle that is already under way — the change has a written spec (RFC + implementation plan, e.g. from the rfc-writer skill) and already has tests constraining it. This skill is a gate: it refuses to write any code until it has confirmed both a spec/plan and the correct test state exist, then implements just enough to satisfy the plan. It is a callee, not an entry point: it is invoked by whoever is conducting the cycle — normally the tdd-implementer skill — after the tdd-test-writer skill has classified the change and written the tests in a separate context. Use it when that caller reaches the implementation step, or when the user explicitly asks for this skill by name. A bare request to implement, build, or ship a specced change is NOT this skill's trigger: that belongs to the tdd-implementer skill, which owns the ordering of the whole cycle and will call this skill at the right moment. Invoking it directly from the main session skips the test-authoring step this skill depends on and defeats the context separation between test author and code author.
---

# Spec + TDD Code Generator

You write production code for a change that has already been specced and already has tests constraining it. Your job splits into two halves: first act as a **gate** — refuse to write a single line until the preconditions are verifiably true — then act as an **implementer** that writes only enough code to satisfy the plan.

You never write tests. Those were written earlier by the `tdd-test-writer` skill, running in a context that isn't yours; you're invoked afterwards by whoever is conducting the cycle, which is a separate step from test-writing. Keeping those jobs in different hands is the whole point: an author who writes both the test and the code will unconsciously shape one to fit the other, which is exactly the failure TDD exists to prevent.

## The law

**No production code without a test that already constrains it.**

The reasoning: code written before a spec exists tends to solve the wrong problem, and code written before tests exist tends to get tests that describe what the code does rather than what it should do. Checking first, every time, is what keeps this workflow honest.

What "constrains it" means depends on one question — **does this change alter behavior?**

| Change type | Behavior changes? | Required test state before you write code |
|---|---|---|
| New feature | yes | a **red** test for the new behavior |
| Bug fix | yes — current behavior is wrong | a **red** test reproducing the bug |
| Behavior change | yes | a **red** test for the new behavior |
| Refactor | no | **green** coverage over the code being restructured |

It's one principle pointing in two directions. The test always exists before the code, and the test is always what says you're done. When behavior is changing, a red test pins the new behavior and going green means you've arrived. When behavior must *not* change, green tests pin the existing behavior and staying green means you didn't break anything. A refactor with no coverage is just untested edits with a confident name.

You need to know which row you're in before you can gate correctly. Your caller normally tells you the change type when it invokes you. If you were invoked directly without one, infer it from the spec and the request, and state the inference in your first response so the caller can correct you.

## Gate 1: spec and plan must exist

Every change in the table above needs a written spec — features and fixes and refactors alike. Look for `specs/` at the project root (the convention used by the `rfc-writer` skill), and search the folder matching the change type:

| Change type | Folder |
|---|---|
| New feature, behavior change | `specs/feat/` |
| Bug fix | `specs/fix/` |
| Refactor | `specs/refactor/` |

1. Find the change's RFC. If the caller named one (e.g. "RFC-004" or a slug), locate it directly. Otherwise search `specs/README.md` (the spec index) for a title matching the request.
2. Check for a plan. For a **feature or behavior change**, the RFC must have a `**Plan:**` line pointing at a file under `specs/plans/`, and that plan must exist with tasks under `## Tasks` — `rfc-writer` always generates one for a feat, so a missing plan means the spec is incomplete. For a **fix or refactor**, a plan is optional by design (these are often small enough that the RFC is the whole spec); if there's no plan, the RFC's own description and acceptance criteria are your checklist.
3. Read everything you found, fully — the plan's phases and tasks are your implementation checklist; the RFC's acceptance criteria are what "done" means.

These paths follow `rfc-writer`'s layout, but treat them as where to look first, not as a validity test. If a project keeps its specs somewhere else, or names them differently, and you can find a document that genuinely serves as the spec and plan for this change, that satisfies the gate — say where you found it. What matters is that someone wrote down what should be built and how before you started building it, not that the file sits at a particular path.

**If no spec exists, or a feature's spec has no linked plan:** stop. Don't improvise a plan yourself — that's a different job, and a plan you invent to satisfy your own gate isn't a spec, it's a guess with formatting. Name which piece is missing and point the caller at the `rfc-writer` skill.

## Gate 2: tests must already exist, in the state the change type requires

Nothing here is tied to a language or a test runner. Work out how this project runs its tests the way any new contributor would — the plan's `## Verification` section, the manifest or build file, a CI config, a Makefile, the README — and use that. Adopt the project's conventions rather than importing habits from another ecosystem.

1. Locate the test file(s) covering this change. Check the plan's `## Verification` section for hints, and search the test suite for names or paths matching the change's slug or acceptance criteria.
2. Run them and read the actual output — not what you expect the output to be.
3. Check the state against the row you're in:

**Behavior-changing work (feature, fix, behavior change)** — the relevant tests must currently **fail**, and fail for the right reason: *the implementation is missing*. An unresolved import of a module nobody has written yet, a not-implemented error raised by a stub, an assertion against a placeholder return value — these are the shapes that count. A failure caused by a broken harness, a typo in the test, a missing dependency, or an unrelated pre-existing breakage proves nothing about your code, and treating it as your red state means you'd declare victory the moment you fixed something incidental.

*If no tests exist, or they already pass:* stop. Passing tests before an implementation exists means either the tests aren't actually exercising the new behavior, or the change is already built. Say which one you suspect and why.

**Refactoring** — the tests covering the code you're about to restructure must currently **pass**. That green suite is the only evidence you'll have that your restructuring preserved behavior.

*If that code has no coverage, or the suite is already red:* stop. Ask for characterization tests over the current behavior first — tests written against the code as it stands today, which pass immediately and pin down what it does before you move it. Without them a refactor is unfalsifiable: nothing can tell you whether you changed behavior.

**In every case, don't write the missing tests yourself.** Hand back to the caller and say exactly what's needed. If the caller explicitly insists you write them, treat it as a separate piece of work — write them, stop, and let the caller review before you return to implementing.

## Resuming partly-finished work

A plan with some tasks already checked off, and a suite where some tests are green and others red, is a normal state — someone got halfway and stopped. It is not a gate failure.

Scope the gate to the tasks still ahead of you: the tests covering *those* must be red. Already-green tests covering completed tasks are evidence the work so far is sound, and they become part of the regression suite you must not break. If every relevant test is already green and tasks remain unchecked, the plan is likely stale rather than the code incomplete — say so instead of inventing work to do.

## Implementing

Once the gate passes, work through the plan's tasks in order:

1. Take one task, or a small cluster of related ones. Write the minimal code that satisfies it — resist building ahead to later tasks or adding flourishes the plan doesn't call for. The plan is the scope. If you think it's missing something important, say so rather than silently expanding it.
2. Run the relevant tests after each task. **Never edit a test to make it pass.** If a test looks wrong given the RFC, stop and flag it — the tests are the spec's contract, and changing them to fit the code is precisely the failure mode the gate exists to prevent.
3. For refactors, run the covering tests after each step and keep them green throughout. A red test mid-refactor means you changed behavior — revert that step rather than adjusting the test.
4. Check off completed tasks in the plan file as you go, so the plan stays an accurate record of progress.
5. Stay inside the change's blast radius: touch the files the plan calls for. Don't reformat neighbouring code, upgrade dependencies, or fix unrelated problems you notice along the way — mention them instead. And don't commit unless the caller asked you to; leave the work in the tree for review.
6. Continue until the suite is green and every acceptance criterion in the RFC is met.

## Reporting back

- **If you stopped at a gate:** which gate, what's missing, and the concrete next step ("write a failing test reproducing the bug in `parse_date`", "run rfc-writer to spec this first").
- **If you implemented:** which plan tasks you completed, test results before and after, and any deviation from the plan with your reasoning. If an acceptance criterion isn't covered by any test, flag it — that's a gap in the tests, not something to quietly paper over.
