# Story Spec Generation — `/continue`-Internal Template

Loaded by `/continue` when a story's spec-phase `story` step is the next work
unit. This is not a user-facing skill: the caller has already resolved the
target story (number, name, folder) from `ProductSpecification/stories.md`
before loading this template. `/continue` dispatches spec generation only
here — never via the `/story` skill, which adds new stories to the Backlog
table and generates no spec.

## Input (provided by the caller)

- Story number and name, resolved via `ProductSpecification/stories.md`
- Story folder: `ProductSpecification/stories/NN-story-name/`

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
   (`.claude/rules/workflow.md`, "Where the Current State Lives"). Where the suite is
   silent about an area, read that area's production code and record what you found —
   silence is not evidence of absence. In a repo with no acceptance suite yet, say so
   explicitly and fall back to the story folders. Open an earlier story's spec only for
   a **named** precedent: the deliberate non-goal or the decision this story extends or
   contradicts
6. **Story-specific context** (optional): `ProductSpecification/stories/NN-story-name/interview.md`
   - If present, read it for additional context, external documentation, and special instructions

## Phase 2: Generate Specifications

Load `.claude/templates/spec/story-templates.md` for document structure.

Generate **two files**:
- Main spec: `NN_StoryName.md` (~50 lines max, implementation-focused)
- Notes file: `NN_StoryName_Notes.md` (warnings, suggestions, technical details)

## Phase 3: Hazard Catalogue Scan

Before output, scan the drafted spec against the hazard catalogue — the spec-time,
closed-list complement to the open-ended commit-time review passes. Dispatch it exactly
as `.claude/guidelines/hazard-catalogue/_index.md` prescribes (read its "How to apply
it", "The dispatch shape"); the artifact under scan is the **drafted spec**.

Fold every GAP back into the spec as an explicit requirement or constraint (and its Notes
file) so test-spec and design-preview inherit it. At story altitude the guard is a named
requirement, not yet a test — but it must be specific enough that a downstream test could
go red on it. An unresolved GAP blocks Phase 4: fold every fired-trigger GAP in, or
explicitly dismiss it with a reason, before output.

**Nothing is stamped here, and nothing is lost by that.** A story draft has no numbered
scenarios, so a COVERED line names its guard in the spec's own terms and there is no
marker to carry the group id (`.claude/agents/hazard-scan-agent.md`, "A COVERED class is a
route too"). The token is recovered one step later: `/test-spec` re-scans the drafted test
files, reports the same class COVERED against a `### N.M Title`, and stamps the id there.
That is why a guard which enters as a story-level requirement — one the drafter got
*right*, so no downstream GAP ever fires on it — still reaches tiering with its provenance
instead of arriving bare.

## Phase 4: Output

1. Use the story folder provided by the caller (see Input) — never re-derive the
   folder name from the story name; the caller is the single folder-resolution
   authority. Create that exact folder if it does not exist yet.
2. Create both files

## Phase 5: Summary

Report: main spec path + line count, notes file path, confirmation, and the hazard-scan
result — the group set scanned (the `_index.md` **Groups** list at scan time, so a later
group addition can re-trigger per `_index.md`'s "A new group obligates a re-scan"), each
group's verdict, and every GAP's disposition (folded → named requirement, or dismissed
with reason).

## Design Constraints

- **Language**: English
- **Main file brevity**: Target ~50 lines max — ruthlessly cut fluff
- **Notes completeness**: All warnings, suggestions, technical details go to Notes file
- **Archived drafts**: Use as reference but apply new compact format
- **No redundancy**: If it's in main file, don't repeat in notes
- Check if spec already exists before creating (avoid duplicates)
