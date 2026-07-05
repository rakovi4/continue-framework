---
name: story
description: Generate story specifications from MVP stories list. Use when user wants to create detailed story documentation or mentions /story command.
---

# Generate Story Specification

Generate detailed story specifications following the established format, based on MVP stories list and product context.

## Usage
```
/story "Story name"
/story 5                    # By MVP story number
/story                      # Interactive selection
```

## Workflow

### Phase 1: Context Gathering

Before generating any specification, read and understand:

1. **Product description**: `ProductSpecification/BriefProductDescription.txt`
2. **Story mapping**: `ProductSpecification/stories.md`
3. **Expected load**: `ProductSpecification/ExpectedLoad.txt`
4. **Archived drafts**: `ProductSpecification/Archived/DraftStories/1st-iteration/`
5. **Existing specifications**: `ProductSpecification/stories/*/NN_StoryName.md`
6. **Story-specific context** (optional): `ProductSpecification/stories/NN-story-name/interview.md`
   - If present, read it for additional context, external documentation, and special instructions

### Phase 2: Story Selection

Parse user input to determine target story:
- **By name**: `/story "Login/Logout"` — Match story name via `ProductSpecification/stories.md`
- **By number**: `/story 5` — Story #5 via `ProductSpecification/stories.md`
- **Interactive**: `/story` — List available MVP stories, ask user to choose

Find related archived draft in `ProductSpecification/Archived/DraftStories/1st-iteration/` if exists.

### Phase 3: Generate Specifications

Load `.claude/templates/spec/story-templates.md` for document structure.

Generate **two files**:
- Main spec: `NN_StoryName.md` (~50 lines max, implementation-focused)
- Notes file: `NN_StoryName_Notes.md` (warnings, suggestions, technical details)

### Phase 4: Hazard Catalogue Scan

Before output, scan the drafted spec against the hazard catalogue — the spec-time,
closed-list complement to the open-ended commit-time review passes. Per
`.claude/guidelines/hazard-catalogue/_index.md` (read its "How to apply it"), fan out
one `hazard-scan-agent` per group in the index's **Groups** list — iterate that list,
never a hand-copied set, or a newly-added group goes unchecked — each carrying the
drafted spec, `_index.md`, and its one group file; dispatch them concurrently, collect
each pass's GAPs and seam flags, then run one synthesis pass (per `_index.md`'s "Reason
across the seams") over the index-named seams and every flagged seam. Fold every GAP back
into the spec as an explicit requirement or constraint (and its Notes file) so test-spec
and design-preview inherit it. At story altitude the guard is a named requirement, not yet
a test — but it must be specific enough that a downstream test could go red on it. An
unresolved GAP blocks Phase 5: fold every fired-trigger GAP in, or explicitly dismiss it
with a reason, before output.

### Phase 5: Output

1. Determine story number from `ProductSpecification/stories.md`
2. Convert story name to kebab-case for folder name (e.g., "Login/Logout" → "01-login-logout")
3. Create folder if needed: `ProductSpecification/stories/NN-story-name/`
4. Create both files

### Phase 6: Summary

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
