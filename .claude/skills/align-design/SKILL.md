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
2. **Locate files**: find mockup in `ProductSpecification/stories/NN-story-name/mockups/desktop/` and component in `frontend/src/features/`
3. **Extract design tokens**: work through every checklist item from the template
4. **Compare and fix**: for each token, compare mockup value vs component value. Fix mismatches using the template's Common Mismatches table and Styling Approach.
5. **Verify**: frontend build command, frontend test command (from `technology.md` Conventions), Selenium test if exists, visual check

## Key Rules

- **NEVER remove `data-testid` attributes** — Selenium tests depend on them
- **NEVER change component behavior** — only styling
- **Match mockup exactly** — use mockup's CSS values, not framework defaults (see template for specifics)
- Divider, login link, and other elements outside `<form>` in mockup must be outside `<form>` in component

## Story Mapping

Read `ProductSpecification/stories.md` for story number resolution.
