---
name: align-design
description: Align frontend component styling to match HTML mockup pixel-for-pixel. Reads mockup CSS, compares with component, fixes all differences. Use when user wants to match a component to its mockup or mentions /align-design command.
---

# /align-design - Align Component to Mockup

Update a frontend component's appearance to match its HTML mockup exactly.

## Usage
```
/align-design "Registration"
/align-design 02                       # By story number
/align-design RegistrationPage.tsx     # By component file
/align-design                          # Interactive selection
```

## Workflow

1. Load `.claude/tech/{browser-testing}/templates/align-design-checklist.md`
2. **Locate files**: find mockup in `ProductSpecification/stories/NN-story-name/mockups/desktop/` — or `ProductSpecification/stories/done/NN-story-name/mockups/desktop/` when that story has closed (`.claude/rules/workflow.md`, "Resolving a story folder") — and component in `frontend/src/features/`
3. **Extract design tokens**: work through every checklist item from the template
4. **Compare and fix**: for each token, compare mockup value vs component value. Fix mismatches using the template's Common Mismatches table and Styling Approach.
5. **Verify**: frontend build command, frontend test command (from `technology.md` Conventions), Selenium test if exists, visual check

When dispatched as the staged frontend design-alignment lane, run the entire
workflow plus `/design-review`, focused frontend coverage, `/refactor`, and a final
verify-only alignment before returning. Work only inside the coordinator's component
and style manifest. Stage 1 interfaces and other lane manifests are read-only; a
needed conflicting path stops the lane and is reported with evidence. Never stage,
commit, or edit `progress.md`.

Invoke focused coverage in staged-lane report-only mode. Return reachable gaps to
the coordinator without inserting progress steps; the coordinator owns admission
and plan mutation after every lane joins.

## Key Rules

- **NEVER remove `data-testid` attributes** — Selenium tests depend on them
- **NEVER change component behavior** — only styling
- **Match mockup exactly** — use mockup's CSS values, not framework defaults (see template for specifics)
- Divider, login link, and other elements outside `<form>` in mockup must be outside `<form>` in component

## Story Mapping

Read `ProductSpecification/stories.md` for story number resolution.
