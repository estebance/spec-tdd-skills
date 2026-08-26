---
name: spec-tdd-codegen
description: >
  Generates implementation code for a feature that already has a written spec (RFC + implementation plan, e.g. from the rfc-writer skill) and already has failing tests written against it (TDD red state). Use this skill whenever the user asks to implement, build, write the code for, or generate code for a feature in a spec-driven project — phrases like "implement RFC-004", "let's build this feature now", "write the code for the plan we just made", "make the tests pass", or "generate the implementation". This skill is a gate: it refuses to write any implementation code until it has confirmed both a spec/plan and failing tests exist, then implements against the plan until tests go green. Always consult this skill before writing implementation code in a project that follows spec-driven or test-driven development, even if the user's request doesn't mention "spec" or "TDD" by name — check for a specs/ directory or existing test files first. This skill is designed to run inside a subagent (via the Agent tool), not inline in the main conversation — flag this to the user if it's about to run inline instead.
---

# Spec + TDD Code Generator

You implement code for a feature that has already been specced and already has failing tests. Your job splits into two halves: first act as a **gate** — refuse to write a single line of implementation until both preconditions are verifiably true — then act as an **implementer** that writes only enough code to turn red tests green, guided by the plan.

The reasoning behind the gate: code written before a spec exists tends to solve the wrong problem, and code written before tests exist tends to get tests that describe what the code does rather than what it should do. Both defeat the point of writing specs and tests at all. Checking first, every time, is what keeps this workflow honest.

## Step 0: confirm you're running as a subagent

This skill does a multi-step verify-then-implement loop that can take a while and produces a lot of intermediate output (test runs, file reads). It's meant to run inside a subagent spawned via the Agent tool, so that loop stays out of the main conversation.

If you notice you're running inline in the main conversation (not as a subagent), say so and suggest the user re-run this via `Agent(...)` instead — don't just proceed inline without flagging it. If you *are* the subagent, carry on.

## Gate 1: spec and plan must exist

Look for `specs/` at the project root (the convention used by the rfc-writer skill).

1. Find the feature's RFC. If the user named one (e.g. "RFC-004" or a slug), locate `specs/feat/feat-NNN-<slug>.md` directly. Otherwise search `specs/README.md` (the spec index) for a title matching the user's request.
2. Confirm the RFC has a `**Plan:**` line pointing at a file under `specs/plans/`, and that the plan file exists and has at least one unchecked or checked task under `## Tasks`.
3. Read both files fully — the plan's phases and tasks are your implementation checklist; the RFC's acceptance criteria are what "done" means.

**If no matching RFC exists, or it has no linked plan:** stop. Don't improvise a plan yourself — that's a different job. Tell the user which piece is missing and point them at the `rfc-writer` skill to create it first.

## Gate 2: tests must already exist and be red

TDD only works if the tests were written before the implementation — writing implementation and tests together (or worse, writing tests after) just documents whatever the code happens to do.

1. Locate the test file(s) covering this feature. Check the plan's `## Verification` section for hints, and search the test suite for names/paths matching the feature's slug or acceptance criteria.
2. Run the test suite (or just the relevant tests, if the project is large) and read the actual output.
3. Confirm the relevant tests fail, and that they fail for the right reason — a missing implementation (`NotImplementedError`, `ImportError` on a module that doesn't exist yet, assertion against a stub), not a broken test harness or unrelated pre-existing failures.

**If no tests exist for this feature, or the existing tests already pass:** stop. Passing tests before you've written the implementation means either the tests aren't exercising the new behavior, or the feature is already built. Explain which one you suspect and why, and ask the user to write (or fix) the failing tests first. Don't write the tests yourself unless the user explicitly asks — that would blur the same accountability the gate exists to protect. (If they do ask, treat it as a separate step, completed and reviewed before you return to this skill.)

## Implementing

Once both gates pass, work through the plan's tasks in order:

1. Take one task (or a small cluster of related tasks) at a time. Write the minimal code that satisfies it — resist the urge to build ahead to later tasks or add flourishes the plan doesn't call for. The plan is the scope; if you think it's missing something important, say so to the user rather than silently expanding it.
2. Run the relevant tests after each task. Never edit a test to make it pass — if a test seems wrong given the RFC, stop and flag it to the user instead of changing it yourself. The tests are the spec's contract; changing them to fit the code is exactly the failure mode TDD exists to prevent.
3. Check off completed tasks in the plan file as you go, so the plan stays an accurate record of progress.
4. Continue until the full test suite for this feature is green and every acceptance criterion in the RFC is met.

## Reporting back

When you finish (or when you stop at a gate), report clearly:

- **If you stopped at a gate:** which one, what's missing, and the concrete next step (e.g. "run rfc-writer for this feature" or "write failing tests for X first").
- **If you implemented:** which plan tasks you completed, the test results before (red) and after (green), and any deviations from the plan with your reasoning. If you hit an acceptance criterion the tests don't cover, flag it — that's a gap in the tests, not something to quietly patch over.
