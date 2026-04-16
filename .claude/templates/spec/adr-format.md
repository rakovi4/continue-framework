# ADR Format Template

Save to `ProductSpecification/stories/NN-story-name/decisions/{slug}-decision.md`.

Absolute minimum. If an agent can infer it — omit it. No code snippets, no implementation steps, no prose that restates the obvious.

```markdown
# Decision: {Title}

**Date**: {YYYY-MM-DD} **Scenarios**: {numbers}

{Why}: 1 sentence — what forced the decision.

| Rejected | Why |
|----------|-----|
| {option} | {reason} |

**Chosen**: {approach}

## Model

{Bullet list: entities, methods, fields, ports. Only what changes or is new.}

## Edge Cases

| Case | Behavior |
|------|----------|
| {case} | {what happens} |
```

Omit Edge Cases when there are none. Never include: code snippets, implementation steps, consequences (unless non-obvious trade-off).
