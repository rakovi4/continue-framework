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

### Phase 4: Output

1. Determine story number from `ProductSpecification/stories.md`
2. Convert story name to kebab-case for folder name (e.g., "Login/Logout" → "01-login-logout")
3. Create folder if needed: `ProductSpecification/stories/NN-story-name/`
4. Create both files

### Phase 5: Summary

Report: main spec path + line count, notes file path, confirmation.

## Design Constraints

- **Language**: English
- **Main file brevity**: Target ~50 lines max — ruthlessly cut fluff
- **Notes completeness**: All warnings, suggestions, technical details go to Notes file
- **Archived drafts**: Use as reference but apply new compact format
- **No redundancy**: If it's in main file, don't repeat in notes
- Check if spec already exists before creating (avoid duplicates)
