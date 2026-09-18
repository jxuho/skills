# Post Flight 출력 템플릿

## state.md

````markdown
# Post Flight State

- ticket: <ticket-key>
- base: <commit-or-reference>
- head: <commit>
- phase: account | verify | learn | own | complete
- status: in-progress | complete
- updated-at: <timestamp if available>
````

## 01-account.md

````markdown
# Account

status: frozen

## 검토 범위
- base: ...
- head: ...
- selected regions: ...

## <region>

Anchor:
`path/to/file:line-range`

Snippet:
```text
<short redacted snippet>
```

Q: <question>

A: "<developer answer verbatim>"

Finding: accounted-for | needs-verification | knowledge-gap

## Blind spot

Q: <blind-spot question>

A: "<developer answer verbatim>"
````

## 02-verification.md

````markdown
# Verification

## <claim title>

Claim:
"<frozen claim from Account>"

Result: CONFIRMED | DISPROVED | UNVERIFIED

Evidence:
- ...

Reasoning:
...

Remaining uncertainty:
...
````

## 03-learning.md

````markdown
# Learning

## <gap>

Original belief / uncertainty:
"..."

Verified reality:
...

Explanation:
...

Teach-back:
"<developer's own words>"

Status: learned | unresolved
````

## 04-ownership.md

```markdown
# Ownership — <ticket-key>

## Ticket intent
...

## Actual system change
...

## I can account for
- ...

## Corrected mental models
- Before: ...
  Now: ...

## Learned
- ...

## Remaining uncertainty
- ...

## If this breaks
- First inspect: ...
- Evidence to check: ...
- Likely failure boundary: ...

## Optional pre-flight reconciliation
### Confirmed
- ...
### Expanded
- ...
### Corrected
- ...
```
