---
name: feature-trace
description: Trace one frontend product feature through the existing codebase with a small, evidence-based exploration budget. Use when the user asks where a feature starts, which hooks/services/APIs/state/cache/components it touches, how data travels from user action to rendered effect, or wants a quick feature/API flow without the broad architectural depth and token cost of a full codebase explanation.
---

# Feature Trace

Trace one feature from trigger to visible effect using the minimum code needed to establish the real path.

Optimize for a fast working mental model, not exhaustive architecture documentation.

## Core Rules

1. Trace exactly one feature or narrowly scoped behavior at a time.
2. Read selectively. Search broadly, then open only files needed to prove the path.
3. Prefer actual call sites, imports, query/mutation definitions, route wiring, and component usage over names or folder structure.
4. Never infer behavior from a filename alone. Mark unresolved links as `Unverified`.
5. Follow the main happy path first. Add loading/error/alternate paths only when they materially change the mental model or the user asks.
6. Do not critique architecture unless explicitly asked.
7. Do not explain unrelated project structure, dependencies, conventions, or historical context.
8. Stop once the primary trigger-to-effect path is evidenced.
9. If the flow fans out across several subsystems, has competing implementations, or requires architectural/historical reasoning, flag `Escalate to /how` instead of expanding indefinitely.

## Exploration Budget

Use a staged budget to prevent runaway exploration.

### Pass 1: Locate

Find only enough evidence to identify:
- user/runtime trigger
- UI or route entry point
- likely feature hook/service/action
- network or persistence boundary, if any
- final render/effect

Prefer search/glob/index tools over opening many files.

### Pass 2: Verify

Open the smallest set of files needed to connect the path.

Follow imports and callers/callees only when they are on the primary path. For frontend code, prioritize:
- route/page/screen or initiating component
- event handler/action
- feature hook
- query/mutation or state action
- API client/service
- cache/store update
- consuming component or navigation/effect

### Pass 3: Fill One Gap

If exactly one important edge remains unclear, investigate that edge.

If two or more major edges remain unclear after Pass 2, stop and report them as `Unverified` rather than widening the search without bound.

## Trace Model

Use this model when applicable. Skip stages that do not exist.

`Trigger -> Entry -> Local/URL State -> Hook/Action -> Service -> API/Persistence -> Cache/Store -> Render/Effect`

Interpret each stage as follows:

- **Trigger**: user action, lifecycle event, route transition, timer, websocket event, etc.
- **Entry**: page, route, screen, component, or handler where the behavior enters the frontend.
- **Local/URL State**: form state, component state, search params, route params, derived state.
- **Hook/Action**: feature hook, query/mutation hook, Redux/Zustand action, command, controller.
- **Service**: API wrapper, repository, SDK, domain service, generated client.
- **API/Persistence**: HTTP/GraphQL/RPC endpoint, browser storage, IndexedDB, native bridge, etc.
- **Cache/Store**: query cache, normalized cache, global store, context, invalidation/update behavior.
- **Render/Effect**: rerender, toast, navigation, modal, list update, disabled state, side effect.

Do not force every feature into every stage.

## API Connections

When the feature touches an API, report the concrete connection rather than only the endpoint.

Capture when verified:
- method and path/operation name
- frontend client/wrapper
- query/mutation/action that invokes it
- request inputs relevant to the feature
- response data relevant to the feature
- what happens after success: cache update/invalidation, store write, navigation, rerender
- other obvious feature consumers only if discovered without broad extra exploration

If an API wrapper exists but no real caller is found, label it `Unverified/possibly unused`.

## Data-Flow Lens

When the user asks about data flow, emphasize:
- source of truth
- where input enters
- transformations before request/store write
- server or persistence boundary
- where returned data is stored/cached
- who consumes it
- what causes the UI to update

Keep control-flow details only when needed to explain the data path.

## Output

Be concise. Prefer this format:

### Trace

`Trigger -> Entry -> State -> Hook/Action -> API/Store -> Cache -> Render/Effect`

### Steps

1. **[stage]** — what happens. `path/to/file.ts:Symbol`
2. **[stage]** — what happens. `path/to/file.ts:Symbol`
3. Continue only through the verified primary path.

### Key files

- `path` — why it matters
- `path` — why it matters

### API / state

Include only if relevant:
- **API**: `METHOD /path` via `clientFn` / `useFeatureMutation`
- **Source of truth**: URL / local state / query cache / store / server
- **After success**: invalidation/update/navigation/rerender behavior

### Unverified

List only meaningful gaps. Omit this section when none remain.

### Escalation

Write `Escalate to /how` only when a deeper architectural explanation is justified, followed by one short reason.

## Examples

User: `Trace profile editing.`

Expected scope: edit UI -> form state -> submit handler -> mutation -> API -> cache/store update -> profile UI refresh. Do not map the entire profile subsystem.

User: `Trace search, focus on data flow.`

Expected scope: search input/URL -> query hook -> API -> response transformation/cache -> results render. Emphasize source of truth and cache behavior.

User: `Which feature uses PATCH /users/:id?`

Trace backward from the concrete API client/wrapper to real callers and UI entry points. Stop after the direct product-feature connections are proven; do not inventory the whole application.
