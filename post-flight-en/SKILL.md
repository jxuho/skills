---
name: post-flight-en
description: >-
  Runs a post-implementation ownership review for a software change. Use when the
  developer invokes "$post-flight-en" with a ticket name or content, or asks to verify that
  they understand and can take responsibility for a change after implementing it,
  especially when AI or a coding agent wrote some or all of the code. Inspect the
  ticket and real diff, assess the developer's understanding without teaching first,
  verify their claims against repository evidence, teach only the gaps that matter,
  require teach-back, and leave durable Markdown checkpoints that can survive
  multiple sessions.
---

# Post Flight EN

Help the developer move from "this code works" to "I understand and can own this change."

The workflow is:

1. Prepare
2. Account
3. Verify
4. Learn
5. Own

Keep these phases separate. Do not leak information from a later phase into an
earlier one.

The developer is not being graded. The purpose is to surface gaps early enough
to close them.

## Invocation

Expected invocation:

    $post-flight-en <ticket name, ticket ID, or ticket content>

Examples:

    $post-flight-en PAY-142
    $post-flight-en Add refund when a paid order is cancelled

Derive a filesystem-safe `ticket-key`.

Store durable state under:

    .codex/ownership/<ticket-key>/postflight/

Use:

    state.md
    01-account.md
    02-verification.md
    03-learning.md
    04-ownership.md

If these files already exist, inspect `state.md` and resume the first incomplete
phase instead of starting over.

Do not rely on conversation memory for completed phases.

---

# Phase 0 — Prepare

## Resolve the change

Determine:

- ticket intent
- concrete change set
- diff base
- current HEAD
- changed files
- relevant surrounding code

Prefer, in order:

1. an explicitly provided PR or diff
2. the current branch compared with its real base branch
3. staged or working-tree changes when they clearly represent the ticket

Record which diff is being reviewed.

If ticket details are not directly available, use the supplied ticket text,
available issue/PR context, branch naming, and commit context.

If ticket intent still cannot be determined, continue with a diff-based review
and record that ticket intent is unavailable. Do not invent requirements.

## Triage the diff

Read the complete diff before questioning the developer.

Select only several regions where misunderstanding would matter most.

Prioritize:

1. authentication, authorization, money, secrets, PII
2. migrations, schema or irreversible state changes
3. transaction boundaries and data integrity
4. concurrency, retries, caching, ordering, timing
5. external side effects and distributed workflows
6. changed contracts, interfaces, error shapes or return semantics
7. new abstractions or dependencies
8. error handling and unhappy paths
9. large additive code that may duplicate or bypass existing behavior
10. observability and how failures would be detected

Skip low-value changes such as simple renames, formatting, and routine logging.

Do not reveal conclusions yet.

Create or update `state.md`:

    ticket: <ticket-key>
    base: <commit>
    head: <commit>
    phase: account
    status: in-progress

---

# Phase 1 — Account

Goal:

Determine what the developer can currently account for in the actual change.

This is an assessment phase, not a teaching phase.

## Rules

Ask one question at a time.

Wait for the developer's answer before deciding the next question.

Ground every question in a concrete changed region. Include a short code snippet
or precise file location so the developer knows exactly what the question refers to.

Ask about understanding that cannot be demonstrated by merely narrating syntax.

Prefer questions about:

- why the change is designed this way
- what state changes
- what happens before and after the changed code
- assumptions the implementation relies on
- failure behavior
- blast radius
- transaction boundaries
- concurrency or retries
- external side effects
- downstream callers
- security boundaries
- operational detection and debugging
- alternatives and trade-offs where material

Examples of useful question shapes:

- "What happens to the rest of the system if this call succeeds but the next one fails?"
- "What guarantees this assumption is true?"
- "Who depends on this changed return behavior?"
- "If this event is delivered twice, what happens?"
- "What would a user observe if this path fails?"
- "Where would you start looking if this broke in production?"

Do not turn this into syntax trivia or a puzzle.

Do not teach the answer during this phase.

Do not verify the answer during this phase.

Do not say "actually, the code does X" even when the developer is wrong.

If the answer merely repeats the code, ask one or two deeper follow-ups.

If the answer appeals to the AI — for example, "Codex chose this" — treat the
underlying reasoning as unaccounted for.

"I don't know" is a useful finding, not a failure.

Do not penalize uncertainty.

## Blind-spot question

End the assessment with:

"Which part of this change do you understand least? If it were wrong, how would
you find out — during review, CI, production, or possibly never?"

## Freeze the result

Write `01-account.md`.

Preserve the developer's important answers as closely as practical.

For each reviewed region record:

    region
    question
    developer answer
    confidence if explicitly expressed
    finding:
      accounted-for | needs-verification | knowledge-gap

Do not rewrite these answers later after discovering the truth.

Mark the file:

    status: frozen

Then update:

    phase: verify

in `state.md`.

---

# Phase 2 — Verify

Goal:

Test the developer's important claims against observable repository evidence.

The question changes from:

"What do you think happens?"

to:

"What evidence tells us what actually happens?"

## Build verification targets

Use claims from `01-account.md`.

Prioritize:

- high-risk claims
- uncertain claims
- assumptions with broad blast radius
- claims about failure modes
- claims where the developer said "I don't know"
- claims affecting correctness, security or data integrity

Do not attempt to verify every trivial statement.

## Gather evidence

Use the strongest practical evidence available:

- surrounding implementation
- callers and callees
- database schema and constraints
- configuration
- static analysis or type checking
- existing tests
- targeted new or temporary tests when appropriate
- local execution
- logs or traces available in the development environment
- framework behavior documented by authoritative sources when repository
  evidence alone is insufficient

Prefer targeted verification over broad test suites when a narrow test answers
the question.

Do not perform destructive operations or mutate production systems.

## Classify each claim

Use only:

    CONFIRMED
    DISPROVED
    UNVERIFIED

For each verification include:

    claim
    result
    evidence
    reasoning
    remaining uncertainty

`UNVERIFIED` is legitimate. Never manufacture certainty.

Write `02-verification.md`.

Never modify `01-account.md`.

Then update:

    phase: learn

in `state.md`.

---

# Phase 3 — Learn

Goal:

Close the most valuable understanding gaps found in Account and Verify.

Do not teach everything that could possibly be learned from the diff.

Teach only gaps that materially improve the developer's ability to understand,
debug, modify, or operate this change.

Prioritize:

- DISPROVED mental models
- explicit "I don't know" findings
- high-risk UNVERIFIED areas where conceptual understanding is missing
- concepts central to how this ticket works
- misconceptions likely to recur in future tickets

## Teaching loop

For each selected gap:

1. State the gap clearly.
2. Explain the mechanism using this repository's actual code and architecture.
3. Connect it to the ticket's behavior.
4. Explain one meaningful failure mode or trade-off.
5. Ask the developer to teach it back in their own words.

Do not ask merely:

"Do you understand?"

Require recall.

Useful teach-back questions include:

- "Explain the flow from request to final side effect in your own words."
- "Why is this transaction boundary here?"
- "What happens if this step fails after the previous one succeeds?"
- "Why does this handler need to be idempotent?"
- "If this breaks in production, where would you investigate first?"

If the teach-back still reveals a gap, explain only the missing part and try again.

Do not use numeric scores.

A gap becomes `learned` only when the developer can explain the important causal
relationship and practical consequence in their own words.

Otherwise mark it:

    unresolved

Write `03-learning.md` containing:

    gap
    original belief or uncertainty
    verified reality
    explanation
    developer teach-back
    status: learned | unresolved

Then update:

    phase: own

in `state.md`.

---

# Phase 4 — Own

Goal:

Create a compact, durable model of what the developer now understands about the
ticket and what remains uncertain.

Read:

- ticket intent
- actual diff
- `01-account.md`
- `02-verification.md`
- `03-learning.md`

If an optional pre-flight artifact exists for this ticket, read it only now.
Do not use pre-flight answers to influence the Account phase.

## Reconcile

Organize the result into:

### Ticket intent

What behavior or system property the ticket was meant to change.

### Actual system change

Describe the important runtime or data-flow change, not a file-by-file changelog.

### I can account for

Important mechanisms the developer demonstrated and verification supported.

### Corrected mental models

Beliefs from Account that evidence disproved and were subsequently corrected.

### Learned

Important concepts or system behavior learned during this post-flight.

### Remaining uncertainty

Anything still unresolved or unverified.

Do not hide uncertainty to make the result look complete.

### If this breaks

Record a short debugging orientation:

- first place to inspect
- useful log / metric / state / test
- likely boundary where failure could occur

## Optional pre-flight reconciliation

If a pre-flight artifact exists, add:

    Confirmed
    Expanded
    Corrected

Use it only as historical comparison.

Never rewrite the original pre-flight file.

## Finish

Write `04-ownership.md`.

Keep it concise enough to reread later.

Do not produce a score.

Do not claim the developer "fully understands" the system.

Prefer explicit statements of what is understood and what remains uncertain.

Update `state.md`:

    phase: complete
    status: complete

---

# Change-set drift

A post-flight can span multiple sessions.

At the beginning of every resumed phase, compare the recorded HEAD with the
current change set.

If the diff changed materially:

- preserve all frozen files
- record the new HEAD
- identify newly introduced high-risk regions
- run Account only for those new regions before verifying them
- append rather than rewriting historical answers

Do not silently treat old answers as covering new code.

---

# Interaction style

Be curious and collaborative, not prosecutorial.

The developer should feel safe saying:

"I don't know."

The skill succeeds when it discovers an important misunderstanding and helps
the developer close it.

Do not optimize for finishing quickly at the expense of discovering real gaps.

At the same time, do not interrogate every line.

Focus on the few parts of the change that matter most for ownership.

Core rule:

Account first.
Verify second.
Teach third.
Rewrite history never.
