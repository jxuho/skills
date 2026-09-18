# Design inspirations

These are design references for this skill, not runtime dependencies and not copied implementations.

## Superpowers — brainstorming and writing plans

Source: https://github.com/obra/superpowers

Useful patterns adopted conceptually:
- do not jump directly from a request into implementation
- explore alternatives before committing to a design
- make implementation plans concrete and repository-aware
- separate design/planning from execution
- verify before claiming completion

This skill narrows those ideas to a pre-implementation frontend ticket review rather than a full software-development lifecycle.

## mblode/agent-skills — planning

Source: https://github.com/mblode/agent-skills/blob/main/skills/planning/SKILL.md

Useful patterns adopted conceptually:
- ground plans in repository evidence
- distinguish plan creation from implementation edits
- prefer explicit decisions and verification criteria

This skill adds Jira intake, frontend-specific data-flow tracing, framework detection, repository precedent checks, narrow cross-boundary verification, and side-by-side implementation options.

## Local feature tracing pattern

The analysis starts with a framework-neutral frontend trace:

`Trigger -> Route/Entry -> UI/URL State -> Feature Logic -> Data Boundary -> Cache/Store -> Render/Effect`

The goal is to prove only the code path needed for the ticket and option comparison rather than documenting the whole application architecture.

The skill is frontend-first, not frontend-only: it may inspect a directly relevant shared/API/backend boundary in the current repository when that evidence can change the frontend implementation choice, while avoiding broad backend exploration.
