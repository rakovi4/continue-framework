---
name: design-review
description: Review frontend component for hardcoded mockup placeholder data after align-design. Flags emails, dates, prices, and other user-specific values that should be dynamic. Use when user mentions /design-review command.
---

# /design-review - Mockup Placeholder Data Review

## Usage
```
/design-review                           # Interactive — find component from current story progress
/design-review 12                        # By story number
/design-review BoardPage.tsx             # By component file
```

## File Resolution

1. **By story number**: Read `ProductSpecification/stories.md` to resolve story name → find `ProductSpecification/stories/NN-story-name/mockups/desktop/*.html` for the mockup, falling back to `ProductSpecification/stories/done/NN-story-name/mockups/desktop/*.html` for a story in the **Done** table (`.claude/rules/workflow.md`, "Resolving a story folder"), and `frontend/src/features/{feature}/components/*.tsx` for the component
2. **By component path**: Find the component directly, locate the matching mockup from the story directory
3. **Interactive**: Read current story's `progress.md`, find the active `align-design` step, resolve from there

## Workflow

1. Load `.claude/agents/design-review-agent.md`
2. Locate the component TSX file(s) and the mockup HTML
3. Run the agent's review workflow against the component
4. Output the review table and verdict

## Available Templates

| Template | Purpose |
|----------|---------|
| `.claude/tech/{browser-testing}/templates/design-review-patterns.md` | Anti-patterns (BAD → GOOD), output format, verdict examples |

## Gate Behavior

- **PASS** → proceed to `/refactor` as normal
- **FAIL** → do NOT proceed to `/refactor`. Fix the flagged violations in the component first, then re-run `/design-review`

In a staged frontend design-alignment lane, review only the component files in that
lane's manifest. A flagged fix outside the manifest or in a frozen Stage 1 interface
is an ownership conflict: return FAIL with the path and finding, and let the
coordinator reconcile it. Do not edit files, stage, commit, or advance progress.
