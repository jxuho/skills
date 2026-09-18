---
name: pre-flight-frontend
description: Review a frontend Jira ticket before implementation by combining ticket requirements with evidence from the current local Git branch, then compare feasible implementation options and recommend a default without editing code. Use when the user provides a Jira key such as BPH-123, pastes ticket text, asks how a frontend ticket could be implemented, wants implementation options/trade-offs before coding, or asks for a pre-flight/design review grounded in the existing repository. Start from the frontend architecture and detected framework (React, Next.js, Vue, etc.), but inspect directly relevant shared/API/backend boundaries in the same repository when they materially affect the frontend decision. Retrieve Jira keys through the available Atlassian Rovo Jira connector; otherwise use pasted ticket text. Inspect only the current local repository/branch unless the user explicitly requests another source.
---

# Pre-Flight Frontend

Review a frontend ticket before implementation. Ground meaningful implementation claims in the ticket or current branch. Produce viable options and a recommended default; do not change code during this workflow.

## Operating principle

Be **frontend-first, not frontend-only**.

Start with the user-visible frontend path and the conventions of the detected frontend stack. Cross a frontend boundary only when evidence shows that an API contract, shared package, generated type, server-side frontend layer, or colocated backend implementation materially affects the option choice. Keep that boundary investigation narrow.

If the required behavior lives outside the current repository or cannot be verified from available contracts, do not infer it. Mark it `Requires backend/API verification` and explain which decision depends on it.

## Core rules

1. Treat this as analysis, not implementation. Do not edit source files, install packages, generate code, commit, switch branches, or modify Jira unless the user explicitly asks after the pre-flight is complete.
2. Use repository evidence over architectural guesswork. Prefer imports, call sites, routes, feature logic, data clients, state/cache operations, tests, and sibling features.
3. Stay on the current local branch. Record the branch name and dirty working-tree state, but do not clean or alter it.
4. Keep exploration scoped to the ticket. Search broadly, then open only files needed to prove the relevant flow, precedents, and material external dependencies.
5. Distinguish `Verified`, `Likely`, and `Unverified`. Never invent API behavior, backend semantics, design-system capabilities, or acceptance criteria.
6. Prefer options with repository precedent. Add a new abstraction or dependency only when repeated behavior, constraints, or ticket requirements justify it.
7. Recommend one default when evidence is sufficient. Make the recommendation conditional when a material unknown could change it.
8. Detect the frontend stack from the repository instead of assuming React. Apply framework-specific checks only when that framework is present.

## Workflow

### 1. Resolve the ticket source

Accept either a Jira key or pasted ticket content.

**If the user provides a Jira key such as `BPH-123`:**
- Use the available Atlassian Rovo Jira issue-read action; prefer `getJiraIssue` when available.
- Retrieve at least summary, description, status, issue type, priority, labels, components, links/parent/subtasks when available, and comments when they may contain acceptance criteria or design decisions.
- Request Markdown/plain content when supported.
- Do not update the issue.

**If the user pastes ticket text:**
- Treat the pasted text as the ticket source.
- If both a Jira key and pasted text are present, read Jira too when available and call out meaningful differences rather than silently choosing one.

Extract:
- user-visible goal
- explicit acceptance criteria
- frontend behaviors directly supported by the text
- API/data dependencies mentioned by the ticket
- design/UX constraints
- open questions or contradictions

Do not convert guesses into requirements.

### 2. Snapshot the current repository and detect the stack

Find the Git root and current branch. Read, but do not alter, the working tree.

Prefer running:

```bash
bash scripts/repo_snapshot.sh <repo-root-or-current-directory>
```

If the bundled script cannot be run, gather equivalent information with read-only commands such as:

```bash
git rev-parse --show-toplevel
git branch --show-current
git status --short
```

Identify only the stack relevant to the ticket:
- application/framework: React, Next.js, Remix, Vue/Nuxt, Svelte/SvelteKit, Angular, Solid, or other
- routing/navigation model
- data fetching and mutation model
- local/global/server/URL state tools
- forms and validation
- styling/design system
- generated clients/types or schema tooling
- test framework and test layers
- monorepo/workspace boundaries when present

Do not assume a library because it is common in the ecosystem; verify it from package/config/import evidence.

### 3. Locate the existing frontend feature path

Use a staged exploration budget.

**Pass 1 — Locate**
- Search ticket nouns, route names, visible UI labels, operation names, component names, and adjacent feature terminology.
- Identify likely route/page entry, initiating UI, feature logic, data boundary, state/cache layer, and final render/effect.

**Pass 2 — Verify**
Open the smallest set of files needed to connect the primary path. Prioritize:
- route/page/screen or framework entry
- component/event handler
- feature hook/controller/composable/store action
- query/mutation/loader/action/server-function when present
- API client/service/generated operation
- cache invalidation/store write/URL update
- consuming component, navigation, or visible effect
- tests for the same or neighboring behavior

Use this framework-neutral trace model when applicable:

`Trigger -> Route/Entry -> UI/URL State -> Feature Logic -> Data Boundary -> Cache/Store -> Render/Effect`

Specialize it to the repository instead of forcing every stage to exist.

**Pass 3 — Resolve one material gap**
Investigate one remaining gap if it materially affects the option choice. If multiple major gaps remain, stop widening the search and report them as `Unverified`.

### 4. Cross the frontend boundary only when necessary

Do this only after the frontend path is understood.

Inspect a directly relevant boundary when it can change the frontend design, for example:
- OpenAPI/GraphQL schema or generated frontend types
- shared validation/domain package
- Next.js route handler/server action or equivalent frontend server layer
- a colocated API implementation in the same monorepo
- feature flag or permission contract

Keep the investigation to the concrete contract or behavior needed for the ticket. Do not map unrelated backend architecture.

If the dependency is outside the current repository, unavailable, or still ambiguous, record:
- `Requires backend/API verification`
- the exact contract or behavior to confirm
- which implementation option(s) depend on it

Do not fetch another repository unless the user explicitly requests it.

### 5. Identify repository precedents and constraints

Before inventing options, look for 1–3 nearby precedents that answer questions such as:
- Where does similar state live?
- How do sibling screens fetch or mutate data?
- Does the repo favor URL, local, server, context, or global state for this behavior?
- How are cache updates/invalidation or navigation refreshes handled?
- Which design-system components already cover the UI?
- How are feature flags, permissions, analytics, errors, loading, and empty states handled?
- What test layer normally protects this behavior?
- Does the framework impose a server/client, loader/action, hydration, or rendering boundary that matters here?

Separate a project convention from a one-off implementation. Treat something as a convention only when multiple call sites or an explicit project rule support it.

### 6. Construct feasible implementation options

Usually produce 2–4 materially different options. Do not create fake alternatives that differ only in naming or file placement.

Where applicable, cover:
- a minimal/local change with the smallest coherent surface
- a convention-aligned option that reuses an existing feature pattern
- a shared abstraction only if repeated behavior or near-term reuse is evidenced
- a state/data-boundary alternative when the ticket genuinely permits more than one source-of-truth model
- a contract-dependent option only when the dependency and verification need are explicit

For each option specify:
- **Approach** — how it works end to end
- **Likely files/symbols** — existing files to modify and new files only if needed
- **State/data flow** — source of truth, request path, cache/store/URL behavior, visible effect
- **Repository fit** — precedent it follows or breaks
- **External dependency** — API/shared/backend assumption, only when relevant
- **Advantages** — concrete benefits for this ticket/repo
- **Costs/risks** — complexity, coupling, stale state, duplication, rendering hazards, accessibility, testing, or contract uncertainty
- **Tests** — unit/component/integration/e2e changes that would give confidence
- **Unknowns** — anything that could invalidate the option

Avoid numeric scoring unless the user explicitly asks for it. Prefer direct trade-offs.

### 7. Recommend a default

Choose one option when the evidence supports it. Base the recommendation on, in order:
1. satisfying explicit ticket behavior
2. consistency with verified repository patterns
3. smallest coherent change surface
4. clear source of truth and predictable data flow
5. fit with the detected framework's rendering/data model
6. testability and reversibility
7. avoiding speculative abstractions or new dependencies

State why the default is preferable **for this repository and ticket**, not in general.

If a missing API contract, UX decision, or product rule could flip the choice, use a conditional recommendation such as: `Prefer Option B if the endpoint supports X; otherwise use Option A.`

### 8. Stop before implementation

End after the review. Do not start editing code merely because one option is recommended. The user should be able to choose or revise the direction first.

## Output format

Use this structure, adapting section depth to ticket complexity:

```markdown
# Pre-flight: BPH-123 — <ticket title>

## Ticket readout
- Goal: ...
- Acceptance criteria: ...
- Open/ambiguous: ...

## Detected frontend context
- Framework/runtime: ...
- Routing/data/state/testing: ...
- Branch: ...

## Current code path
`Trigger -> Entry -> State -> Feature Logic -> Data Boundary -> Cache/Store -> Render/Effect`

1. `path/to/file.tsx:Symbol` — verified behavior
2. `path/to/file.ts:Symbol` — verified behavior

## Relevant repo patterns
- `path/to/example` — what precedent it establishes

## Constraints / external dependencies
- Verified: ...
- Requires backend/API verification: ...
- Unverified: ...

## Option A — <name>
**Approach:** ...
**Likely changes:** ...
**Data/state flow:** ...
**Repository fit:** ...
**External dependency:** ...
**Advantages:** ...
**Costs/risks:** ...
**Tests:** ...

## Option B — <name>
...

## Recommended default
**Option B**, because ...

## Before implementation
- decision or information that should be confirmed, only when material
```

Keep file references concrete (`path:Symbol`, and line numbers when readily available). Avoid dumping the entire repository architecture.

## Frontend-specific checks

Apply only checks supported by the detected stack and relevant to the ticket:
- component/view ownership and data/prop boundaries
- URL vs local vs server vs global state source of truth
- query keys, mutations, invalidation, optimistic updates, loaders/actions, or equivalent data lifecycle
- selectors/actions/composables/context/store behavior when present
- derived-state, effect/watcher, hydration, and stale-data hazards
- forms, validation, disabled/loading/submitting states
- error and empty states
- accessibility, focus, keyboard, and semantic behavior for interactive UI
- design-system reuse before custom primitives
- generated API/types and whether regeneration is required
- feature flags, permissions, analytics, i18n
- framework rendering boundaries such as client/server components or SSR/CSR when present
- tests adjacent to the touched behavior

Do not prescribe a library the repository does not already use unless every existing path is unsuitable and the trade-off is explicitly justified.

## Framework adaptations

Use these only when detected:

- **React/Next.js**: inspect hooks, context/state libraries, query/mutation lifecycle, client/server component boundaries, route handlers/server actions, and cache/revalidation behavior when applicable.
- **Vue/Nuxt**: inspect composables, Pinia/Vuex when present, refs/computed/watch behavior, route data, server/API utilities, and SSR/hydration boundaries when applicable.
- **Svelte/SvelteKit**: inspect stores/runes, load/actions, form actions, invalidation, and server/client boundaries when applicable.
- **Angular**: inspect components/services, signals/RxJS, route resolvers/guards, dependency injection boundaries, and change-detection implications when applicable.
- **Other frameworks**: infer the equivalent primitives from repository evidence rather than importing assumptions from another ecosystem.

## Reference patterns

See `references/inspirations.md` for the external planning/skill patterns that informed this workflow. They are design references, not runtime dependencies.
