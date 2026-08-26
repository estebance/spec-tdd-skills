---
name: feature-brainstorm
description: >
  Facilitates open-ended feature brainstorming before any spec, RFC, or implementation plan gets written. Use this whenever the user wants to brainstorm features, generate product ideas, explore possible solutions to a problem, or is describing a pain point / goal / user complaint without yet knowing what to build — even if they never say the word "brainstorm". Trigger on phrases like "what could we build for X", "let's think of some ideas", "users keep complaining about Y, what should we do", "I want to improve Z but don't know how", or "give me some options before we commit to anything". Also trigger proactively when a user jumps straight into describing implementation details for a problem that hasn't actually been explored yet — pump the brakes and widen the net before narrowing. This skill deliberately stays conversational and idea-focused: it does NOT write specs, RFCs, or plans (hand off to a spec-writing skill like rfc-writer once a direction is chosen).
---

# Feature Brainstorm

Help the user explore the space of possible features or solutions before anything gets locked into a spec. The value you add here isn't a clever idea — it's making sure a wide enough net gets cast before anyone commits to one. Most premature specs fail not because the writing was bad, but because the first idea that came to mind got specced instead of the best one.

Stay conversational. Never produce a written deliverable (no files, no markdown doc, no RFC) — the output of this skill is a sharper shared understanding in the chat, not an artifact. If the user wants a doc, that's the next skill's job, not this one.

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

### 4. Know when you're done

The session is done when the user has a direction they want to pursue, even a rough one — not when every idea has been exhaustively debated. At that point, name what they've landed on in one sentence and ask if they want to keep exploring or move on. If they're ready to move on and the project uses a spec-writing workflow (e.g. an `rfc-writer`-style skill, or a `specs/` directory), suggest handing off to it — but don't write the spec yourself here, and don't assume that workflow exists if you haven't seen evidence of it in the project.

## Things to avoid

**Don't grade your own ideas as you generate them.** Listing an idea and immediately editorializing about why it's probably not great undercuts the point of divergence — let ideas sit un-judged until the convergent phase.

**Don't default to safe, obvious ideas.** If every idea you generate is a variation on "add a settings toggle," you're not actually diverging. Reach for ideas that would surprise the user a little.

**Don't turn this into an interview marathon.** A handful of grounding questions is enough. If you find yourself asking five questions before offering a single idea, you've overcorrected — brainstorming should feel generative quickly, not like a discovery workshop.

**Don't write anything down as a deliverable.** If the user asks you to save the list, a plain recap in the chat is fine, but resist creating a formal doc — that's a signal the session is actually done and it's time to hand off to a spec-writing step.
