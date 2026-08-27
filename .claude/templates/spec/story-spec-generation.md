# Story Spec Generation — `/continue`-Internal Template

Loaded by `/continue` when a story's spec-phase `story` step is the next work
unit. This is not a user-facing skill: the caller has already resolved the
target story (number, name, folder) from `ProductSpecification/stories.md`
before loading this template. `/continue` dispatches spec generation only
here — never via the `/story` skill, which adds new stories to the Backlog
table and generates no spec.

## Input (provided by the caller)

- Story number and name, resolved via `ProductSpecification/stories.md`
- Story folder: `ProductSpecification/stories/NN-story-name/` — the folder the story resolved to, which is `stories/done/NN-story-name/` for a story that has closed (`.claude/rules/workflow.md`, "Resolving a story folder"). Confirm both are empty before creating one: a spec generated into a second folder beside an archived original re-specs shipped behavior

## Phase 1: Context Gathering

Before generating any specification, read and understand:

1. **Product description**: `ProductSpecification/BriefProductDescription.md`
2. **Story mapping**: `ProductSpecification/stories.md`
3. **Expected load**: `ProductSpecification/ExpectedLoad.md`
4. **Archived drafts**: `ProductSpecification/Archived/DraftStories/1st-iteration/`
   — find the draft related to this story, if one exists
5. **What the areas this story touches already do**: the acceptance tests **of those
   areas** — test class names, scenario descriptions, Statements — never a sweep of
   `stories/*/NN_StoryName.md`, which reconstructs the present from a pile of deltas
   (`.claude/rules/workflow.md`, "Where the Current State Lives"). Only **enabled** tests
   count as shipped — one still carrying its disable/skip marker is a pending increment,
   not shipped behavior. Where the suite is silent about an area, read that area's
   production code and note what you found in the Notes file, never as current-state prose
   in the spec itself — silence is not evidence of absence. In a repo with no acceptance suite yet, say so
   explicitly and fall back to the story folders. Open an earlier story's spec only for
   a **named** precedent: the deliberate non-goal or the decision this story extends or
   contradicts
6. **Story-specific context** (optional): `interview.md` in the story folder resolved in **Input** above
   - If present, read it for additional context, external documentation, and special instructions
   - Classify every relevant interview fact before drafting: observable behavior,
     business rules, and user-facing constraints feed the main spec; implementation
     choices, architecture, data/storage design, algorithms, technology, protocols,
     endpoint mechanics, deployment, and integration mechanics feed the Notes file

## Phase 2: Generate Specifications

Load `.claude/templates/spec/story-templates.md` for document structure.

Generate **two files**:
- Main spec: `NN_StoryName.md` (~50 lines max, domain language only)
- Notes file: `NN_StoryName_Notes.md` (implementation context, warnings, suggestions)

The main spec describes what the user can do, the business rules that govern it,
and the observable outcomes. It must not name or prescribe implementation machinery.
If a technical constraint affects observable behavior, translate its effect into a
domain requirement in the main spec and record the technical cause only in Notes.

## Phase 3: Output

1. Use the story folder provided by the caller (see Input) — never re-derive the
   folder name from the story name; the caller is the single folder-resolution
   authority. Create that exact folder if it does not exist yet.
2. Create both files

## Phase 4: Summary

Report: main spec path + line count, notes file path, and confirmation.

## Design Constraints

- **Language**: English
- **Main file brevity**: Target ~50 lines max — ruthlessly cut fluff
- **Domain-only main spec**: Use the vocabulary of users and the business domain;
  describe behavior, rules, constraints, and outcomes without implementation terminology
- **Notes completeness**: All implementation choices, architecture, technology,
  integration mechanics, warnings, suggestions, and technical details go to Notes
- **Technical limitations**: Put the mechanism in Notes; put only its observable effect,
  expressed as a domain rule, in the main spec
- **Archived drafts**: Use as reference but apply new compact format
- **No redundancy**: If it's in main file, don't repeat in notes
- Check if spec already exists before creating (avoid duplicates)
