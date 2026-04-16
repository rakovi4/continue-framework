---
name: mockups
description: Generate HTML interface mockups for user stories. Use when user wants to create UI mockups, prototypes, or mentions /mockups command.
---

# Generate Interface Mockups

Create production-quality HTML mockups for a user story with mandatory desktop/mobile parity.

## Usage
```
/mockups "Story name"
/mockups 5                    # By MVP story number
/mockups                      # Interactive selection
```

## Phase 1: Context Gathering

Read these files before generating anything:

1. **Conventions**: `ProductSpecification/ui/ui-conventions.md` (the single authority for all design rules)
2. **Templates**: `ProductSpecification/ui/templates/` (browse what's available)
3. `ProductSpecification/BriefProductDescription.txt`
4. `ProductSpecification/stories.md` (story number lookup)
5. Story spec: `ProductSpecification/stories/NN-story-name/NN_StoryName.md`
6. Landing page: `Landing/index.html` (brand reference)
7. If exists: `ProductSpecification/stories/NN-story-name/interview.md`

## Phase 2: Story Selection

Parse user input (by name, by number, or interactive).

## Phase 3: Screen Plan (MANDATORY GATE)

You MUST complete this phase fully before writing any HTML file.

1. **Extract all screen states** from the story spec's "Screen States" section. MUST include every state (never skip, merge, or combine).
2. **Map states to filenames** for BOTH desktop AND mobile. Every desktop file MUST have a mobile counterpart.
3. **Parity check** — desktop files = N, mobile files = N. Fix if counts differ.

**NEVER proceed to Phase 4 until the Screen Plan table is complete with equal counts.**

## Phase 4: Generate Mockups

Load `.claude/templates/ui/mockup-generation-rules.md` for all generation rules, output location, template usage, format, and completion check.

## Phase 5: Screenshots

Run `/screenshot` for both desktop and mobile directories.

## Phase 6: Summary

Report: Screen Plan table, total files, screenshot locations, design decisions, whether conventions were updated.

## Pre-flight Checklist

- [ ] Every screen state from the spec has a mockup
- [ ] Desktop file count equals mobile file count
- [ ] All patterns match `ui-conventions.md`
- [ ] Sidebar matches `sidebar.html` template exactly
- [ ] Interface text is in Russian
- [ ] Screenshots generated for both desktop and mobile
- [ ] Existing mockups checked (ask user before overwriting)
- [ ] If new UI patterns introduced, `ui-conventions.md` updated

## Templates

- `.claude/templates/ui/mockup-generation-rules.md` — generation rules, format, templates, completion check
- `.claude/templates/ui/icon-reference.md` — icon name lookup
