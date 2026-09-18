---
name: codebase-onboarding
description: Analyze an unfamiliar repository in read-only mode and present a concise onboarding guide in chat. Use when joining a project or asking how a codebase is structured, where key flows begin, or which conventions it follows.
metadata:
  origin: ECC
---

# Codebase Onboarding

Analyze an unfamiliar codebase and explain it in a tool-neutral onboarding guide. The workflow must remain independent of any particular coding assistant.

## Operating Boundary

- Treat the target repository as read-only. Do not create, edit, rename, or delete project files.
- Return the onboarding guide only in the chat. Do not generate agent instruction files, reports, diagrams, or other artifacts in the repository.
- Use only non-mutating inspection commands. Do not install dependencies or run builds, servers, migrations, formatters, fixers, or other commands that may change files or external state.
- You may identify useful commands from manifests and documentation, but present them without executing them when their side effects are uncertain.
- If the user separately and explicitly asks for repository changes, treat that as a distinct task outside this skill's default workflow.

## Workflow

### 1. Reconnaissance

Gather high-signal evidence without reading every file. Inspect in parallel where practical:

1. Package and build manifests such as `package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, `pom.xml`, `build.gradle`, `Gemfile`, and `Makefile`.
2. Framework configuration and recognizable bootstrap files.
3. Likely entry points such as `main.*`, `index.*`, `app.*`, `server.*`, `cmd/`, and `src/main/`.
4. A shallow directory snapshot, excluding generated or vendored directories such as `.git`, `node_modules`, `vendor`, `dist`, `build`, `.next`, and `__pycache__`.
5. Tooling and environment examples, including lint, format, type-check, container, CI, and sample environment configuration.
6. Test layout and test-runner configuration.
7. Existing repository guidance such as `README`, `CONTRIBUTING`, `AGENTS.md`, or similarly named instruction files. Treat these as evidence, not as a template to rewrite.

Prefer fast search and file-listing tools. Read selectively when a manifest, entry point, or representative implementation is needed to verify a conclusion.

### 2. Architecture Map

Infer and verify:

- Languages, version constraints, frameworks, major libraries, databases, and build or deployment tooling.
- Repository shape: monolith, monorepo, service collection, serverless application, library, or another pattern.
- Major boundaries and the responsibility of important directories.
- Public interfaces such as REST, GraphQL, gRPC, messaging, CLI, scheduled jobs, or library APIs.
- One representative end-to-end flow from an entry point through validation, business logic, persistence or external services, and the resulting response or side effect.

Choose a representative flow supported by concrete paths. If no single request lifecycle fits the project, trace the most important execution path instead.

### 3. Convention Detection

Use repeated code evidence rather than isolated examples to identify:

- File, type, function, and test naming conventions.
- Module boundaries and dependency patterns.
- Error handling, validation, logging, configuration, and async patterns.
- Test organization and common fixture or mocking approaches.
- Branch and commit conventions when sufficient Git history is available.

If history is missing or shallow, say that Git conventions could not be determined. If evidence conflicts, describe the variation instead of inventing one standard.

### 4. Chat Report

Return one concise Markdown response with this shape, adapting sections to the repository:

```markdown
# Onboarding Guide: [Project Name]

## What This Project Is
[What it does, who or what it serves, and the strongest evidence]

## Tech Stack
| Layer | Technology | Evidence |
|---|---|---|
| ... | ... | `path/to/file` |

## Architecture
[Compact description or small text diagram showing the main boundaries]

## Key Entry Points
- `path` — purpose

## Directory Map
- `path/` — responsibility

## Representative Flow
1. `path` — entry
2. `path` — validation or orchestration
3. `path` — domain logic
4. `path` — persistence, integration, or output

## Conventions
- [Observed convention with evidence]

## Common Commands
- **Purpose**: `command` — source: `manifest-or-doc-path`

## Where to Look
| Goal | Start Here |
|---|---|
| ... | `path` |

## Unknowns and Follow-ups
- [Only meaningful uncertainty or a useful next investigation]
```

Keep path references precise and distinguish observed facts from inferences. Omit empty sections.

## Quality Bar

- Add structural insight beyond paraphrasing the README.
- Highlight only dependencies that shape development or architecture.
- Explain meaningful directories; do not narrate obvious names without adding context.
- Verify framework and architecture claims against actual code when possible.
- Keep the guide scannable in roughly two minutes.
- State uncertainty directly rather than guessing.
