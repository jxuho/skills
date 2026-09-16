---
name: explain-branch-rationale
description: Explain why the current branch changed by comparing its latest working tree with the branch starting point, organized as the user-facing UX problem, the root cause in terms of code abstractions, and the abstract solution. Use when preparing a rationale for a senior engineer or reviewer; do not use for a PR body or a line-by-line changelog.
---

# Explain Branch Rationale

Explain the final change at the level of user behavior and software design. Ground the explanation in the current branch rather than relying on earlier plans or conversation summaries.

## Default invocation

When invoked as `$explain-branch-rationale` without additional instructions, treat it as this request:

> 현재 브랜치 변경을 사수에게 설명할 수 있게 정리해줘.

Proceed immediately with the comparison and explanation workflow below. Do not ask the user to repeat or clarify the default request.

## Establish the comparison

1. Use an explicitly supplied PR base or branch start when available.
2. Otherwise resolve the repository's default remote branch and use its merge-base with `HEAD`. Prefer `origin/HEAD`, then `origin/main`, then `main`.
3. Treat that merge-base as the branch starting point.
4. Inspect the latest state, including committed, staged, and unstaged changes. Check untracked files and include them only when they belong to the work being explained.
5. Read the relevant final code and tests. Use commit messages and prior discussion only as supporting context when they agree with the final implementation.

Useful evidence normally includes:

- `git status --short`
- `git log --oneline <merge-base>..HEAD`
- `git diff --stat <merge-base>`
- `git diff <merge-base> -- <relevant paths>`
- focused tests that express the intended behavior

Do not describe an intermediate implementation that the latest code replaced. If the base cannot be resolved confidently, state the assumed base instead of silently inventing one.

## Build the explanation

Write in the user's language and use these three sections in this order.

### 1. Existing problem: UX perspective

Describe concrete user actions followed by incorrect or confusing outcomes. Explain mismatches among what the user sees, what controls allow, and what the system persists.

Avoid implementation names in the opening unless they are necessary to understand the behavior. Prefer examples such as:

- the screen appears reverted but Save still submits the change;
- Undo is enabled but cannot make progress;
- a success message is shown although part of the change was not persisted.

Group related symptoms around the user trust or workflow problem they create.

### 2. Root cause: abstraction perspective

Explain why the old design allowed those outcomes. Identify the mismatched abstraction boundary rather than listing faulty lines.

Useful distinctions include:

- one domain action represented as several unrelated mutations;
- domain state split across owners with different lifecycle rules;
- a low-level utility being asked to provide a higher-level transaction guarantee;
- history capacity or UI availability being confused with dirty or persistence state;
- current state and its rendered projection observing different sources.

Name concrete fields or classes only after explaining the conceptual mismatch. Make clear which abstraction was appropriate for another consumer but unsuitable for this workflow.

### 3. Solution: abstract design

Explain the new responsibility boundaries and invariants before implementation details.

Cover the relevant ideas:

- what now represents one domain transaction;
- which object owns current, past, and future state;
- how branching after Undo behaves;
- how Undo availability is separated from whether data needs saving;
- how Save and Cancel establish a new baseline;
- how the rendered view is refreshed from the authoritative state;
- why shared code was changed or intentionally left unchanged.

Describe important tradeoffs when they explain the design choice, such as a bounded history, feature-local state ownership, or avoiding behavior changes in another feature.

## Output quality

- Optimize for a spoken or review-thread explanation, not a file-by-file summary.
- Lead with why the change was necessary, then explain how the design addresses it.
- Keep code snippets optional and small. Use them only when a state shape materially clarifies the abstraction.
- Distinguish verified behavior from inference. Do not claim browser or server verification without evidence.
- Preserve the actual scope shown by the diff and avoid attributing unrelated working-tree changes to the branch.
- End with a short summary paragraph suitable for answering “why did we change it this way?” when that would help the user.
