---
name: github-pr-description
description: Draft a concise GitHub pull request description for the ticket completed in the current coding session. Use after implementation when the user asks for a PR description, PR body, or change summary; do not use to create, update, or submit the pull request itself.
---

# GitHub PR Description

Create a paste-ready Markdown PR description grounded in the work completed for the current session's single ticket.

## Gather Evidence

- Inspect the current diff and relevant Git status before drafting.
- Use the session history to understand intent, but prefer the final code and validation results when they differ from an earlier plan.
- Include only changes belonging to the current ticket. Exclude unrelated pre-existing working-tree changes.
- Do not invent ticket identifiers, behavior, validation results, or screenshot URLs. Omit details that cannot be verified.

## Write the Description

Keep the description concise and easy to scan. Prefer short bullet points over paragraphs.

Use exactly these required sections:

```markdown
## Summary

- <why the change was needed and its user or product outcome>

## Changes

- <notable implementation or behavior change>
```

For `Summary`, lead with the concrete user-visible problem that required the
change. Write it so a reviewer can understand the failure without knowing the
implementation:

- Describe the user action or state followed by the incorrect result.
- Prefer plain, concrete wording over abstract statements such as "improves
  consistency" or "fixes state handling."
- Keep implementation details and solution mechanics in `Changes`.
- For a bug fix covering multiple related symptoms, introduce the bullets with
  `This PR fixes the following <feature> issues:` and list each observable
  problem separately.
- For example: `After undoing a move, clicking Save could still submit the area
  reassignment that was supposed to be undone.`

Use one to three problem or outcome bullets. For non-bug work, summarize the
user or product outcome instead.

For `Changes`, group meaningful changes by behavior or responsibility. Usually use two to five bullets. Mention tests only when they were added or materially changed; do not turn routine validation commands into change bullets.

## UI Changes

When the diff changes visible UI behavior, layout, styling, or user-facing states, append this section:

```markdown
## Screenshots

| Before | After |
| --- | --- |
| <!-- Add before screenshot --> | <!-- Add after screenshot --> |
```

- Preserve any real screenshot Markdown or URLs provided by the user and place them in the corresponding cells.
- If screenshots are unavailable, keep the HTML comment placeholders so the table is ready to complete.
- Omit the entire `Screenshots` section for non-UI changes.

## Output Constraints

- Wrap the entire PR description in a single fenced code block tagged `md` so the user can copy the raw Markdown. Do not place any part of the description outside that code block.
- Return only that code block unless the user asks for commentary.
- Do not add a title, ticket link, test plan, checklist, risk section, or deployment notes unless the user requests them.
- Use clear, concrete language and avoid promotional wording.
- Follow repository rules for user-facing copy, including avoiding em dashes.
