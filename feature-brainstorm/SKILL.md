---
name: feature-brainstorm
description: >
  Facilitates open-ended feature brainstorming before any spec, RFC, or implementation plan gets written. Use this whenever the user wants to brainstorm features, generate product ideas, explore possible solutions to a problem, or is describing a pain point / goal / user complaint without yet knowing what to build — even if they never say the word "brainstorm". Trigger on phrases like "what could we build for X", "let's think of some ideas", "users keep complaining about Y, what should we do", "I want to improve Z but don't know how", or "give me some options before we commit to anything". Also trigger proactively when a user jumps straight into describing implementation details for a problem or feature that hasn't actually been explored yet — pump the brakes and widen the net before narrowing. This skill deliberately stays conversational and idea-focused: it does NOT write specs, RFCs, plans, or any file. Its only output is a "brainstorm brief" posted in the chat once a direction is chosen — problem, direction and why it won, alternatives rejected and why, constraints, open questions — structured to feed a spec-writing skill like rfc-writer, which is where the handoff goes next.
---

# Feature Brainstorm

Help the user explore the space of possible features or solutions before anything gets locked into a spec. The value you add here isn't a clever idea — it's making sure a wide enough net gets cast before anyone commits to one. Most premature specs fail not because the writing was bad, but because the first idea that came to mind got specced instead of the best one.

Stay conversational, and never write a file — no markdown doc, no RFC, nothing on disk. That's the next skill's job. But the session does have an output: it ends with a **brainstorm brief** posted in the chat (see [step 4](#4-close-with-a-brainstorm-brief)) — a structured recap of the direction chosen and, just as importantly, everything the exploration turned up along the way. Without it, the reasoning that made the session worth having stays buried in scrollback and the spec-writing step starts its interview from zero.

## The shape of a good session: diverge, then converge

Brainstorming fails in two directions: settling on the first idea too fast (no divergence), or generating ideas forever without ever landing anywhere (no convergence). Guard against both.

### 1. Ground yourself in the problem, briefly

Before generating anything, make sure you actually understand what's being solved — not to write a spec, just enough to brainstorm well. If the user already gave you this in their message, don't re-ask:

- Who's affected, and what's actually going wrong or missing for them?
- What's already been tried or ruled out, if anything?
- Any hard constraints (platform, timeline, team size) that would make some ideas non-starters?

Keep this light — one or two questions, not an interview. If the user jumped straight to a specific implementation ("let's add a caching layer"), gently pull back up a level first: what problem is the caching layer solving? There may be three other ways to solve it worth naming before picking one.

### 2. Diverge: generate breadth, not depth

Once you have enough context, produce a spread of genuinely different ideas — not five variations on the same concept. Push yourself toward different angles: a minimal/cheap version, a more ambitious version, an approach that borrows from how other products solve this, an approach that changes the workflow rather than adding a feature, an unconventional or slightly weird one. Quantity and variety matter more than polish at this stage — don't pre-filter an idea out because it seems hard or unlikely; let the user do that filtering, not you.

For each idea, a sentence or two is enough: what it is, and the one most important tradeoff or risk. Resist the urge to flesh every idea out fully — that's convergent-phase work, and doing it too early buries the breadth you're trying to create.

Don't wait for the user to ask "got any more?" — if the first batch is thin or clusters around one theme, push further on your own before handing it back.

### 3. Converge: only when the user is ready

Stay in divergent mode until the user signals they want to narrow — "ok which of these is best", "let's compare a few", "I like 2 and 4, help me pick." Don't rush there on your own; cutting divergence short is the most common way this kind of session goes wrong.

Once narrowing starts:
- Group similar ideas together if some are really variations on a theme.
- Surface the real tradeoffs between the top contenders — effort vs. impact, risk, what it forecloses later — rather than just restating each idea.
- It's fine to have an opinion about which is strongest, but say why, and let the user make the call.

### 4. Close with a brainstorm brief

The session is done when the user has a direction they want to pursue, even a rough one — not when every idea has been exhaustively debated. At that point, stop generating and post the brief:

```markdown
## Brainstorm brief: <direction, as a short noun phrase>

**Problem** — who's affected and what's going wrong for them.
**Direction chosen** — what it is in one or two sentences, and why it won over the others.
**Alternatives considered** — 2–4 lines, each `<idea> → <why it lost>`. Include the ones ruled out by constraint, not just the ones that lost on merit.
**Constraints** — platform, timeline, team, existing-system limits that came up. These are what make the direction the right one; a spec written without them will drift.
**Open questions** — what's genuinely unresolved and needs an answer before or during implementation.
**Done looks like** — rough signals that it worked. Directional, not testable criteria yet.
```

Then ask whether they want to keep exploring or move on.

Rules for the brief:

- **Only what the session actually produced.** Every line traces back to something said in the conversation. Never invent a plausible-sounding constraint or acceptance signal to fill out the shape — a spec built on a fabricated constraint is worse than one built on none.
- **Drop a section that's empty** rather than leaving a placeholder in it; a four-section brief from a short session is fine. The one exception is **Constraints**, where "none surfaced" is worth stating explicitly — it tells the spec writer the space is open rather than unexplored.
- **Alternatives are the highest-value part.** They're the one thing a spec writer can't reconstruct, and they're what stops a rejected idea from being re-litigated three weeks later. Don't compress them away to keep the brief short.
- **Stay above implementation.** No file paths, no schemas, no task breakdown — the brief says what and why, and leaves how to the spec and plan.

The brief is written to hand off: **Problem** seeds the RFC's *Problem*, **Direction chosen** its *Proposed Solution*, **Open questions** its *Open Questions*, and **Done looks like** the raw material for *Acceptance Criteria* — so the spec-writing step can skip re-asking what the session already settled and interview only for what's missing. If the project uses a spec-writing workflow (an `rfc-writer`-style skill, or a `specs/` directory), offer to hand off to it once the brief is posted — but don't write the spec yourself here, and don't assume that workflow exists if you haven't seen evidence of it in the project.

## Things to avoid

**Don't grade your own ideas as you generate them.** Listing an idea and immediately editorializing about why it's probably not great undercuts the point of divergence — let ideas sit un-judged until the convergent phase.

**Don't default to safe, obvious ideas.** If every idea you generate is a variation on "add a settings toggle," you're not actually diverging. Reach for ideas that would surprise the user a little.

**Don't turn this into an interview marathon.** A handful of grounding questions is enough. If you find yourself asking five questions before offering a single idea, you've overcorrected — brainstorming should feel generative quickly, not like a discovery workshop.

**Don't create files.** The brainstorm brief lives in the chat. If the user asks you to save it, that's the signal the session is done and it's time to hand off to a spec-writing step — the RFC is where this belongs on disk, and writing a second doc alongside it just creates two things to keep in sync.

**Don't post the brief early.** It's the closing move, not a running summary. Writing it while the user is still generating options reads as a verdict and shuts down divergence — the exact failure mode step 2 exists to prevent. Wait until they've actually landed on a direction.
