---
name: interview
description: Interactive interview to create interview.md for a story. Asks structured questions about scope, APIs, decisions, and constraints, then generates the handwritten-style context file. Use when user wants to create story specifics or mentions /interview command.
---

# Generate interview.md via Interactive Interview

Conduct a structured interview with the user to gather all context needed for a story, then generate the `interview.md` file that feeds into `/story`, `/mockups`, `/api-spec`, `/test-spec`.

## Usage
```
/interview 5                    # By MVP story number
/interview "Create task"             # By story name
/interview                      # Interactive selection
```

## Workflow

### Phase 1: Context Gathering (Silent)

Before asking any questions, silently read:

1. **Story mapping**: `ProductSpecification/stories.md`
2. **Product description**: `ProductSpecification/BriefProductDescription.txt`
3. **Expected load**: `ProductSpecification/ExpectedLoad.txt`
4. **Existing story spec** (if any): `ProductSpecification/stories/NN-story-name/NN_StoryName.md`
5. **Archived drafts**: `ProductSpecification/Archived/DraftStories/1st-iteration/` (scan for relevant files)
6. **Existing interviews**: ALL existing `ProductSpecification/stories/*/interview.md` files
7. **Existing domain code**: Scan `backend/domain/src/` and `backend/usecase/src/`
8. **Existing adapters**: Scan `backend/adapters/*/src/`
9. **Existing acceptance tests**: Scan `acceptance/`
10. **Existing test cases doc** (if any): `ProductSpecification/stories/NN-story-name/tests/01_API_Tests.md`

### Phase 2: Story Selection

Parse user input to determine target story (same as `/story` skill).
If `interview.md` already exists, warn and ask whether to regenerate or skip.

### Phase 3: Interview

Load `.claude/templates/spec/interview-format.md` for round structure and adaptive questions.

### Phase 4: Generate File

Compile all answers into `interview.md` using the format rules from the template.

### Phase 5: Review & Confirm

1. Show the full content of the generated file
2. Ask: "Does this look complete? Any corrections or additions?"
3. If corrections, update the file
4. Report the file path and suggest running `/story NN` next

## Rules

- NEVER skip the interview — the whole point is interactive knowledge extraction
- NEVER fabricate information — if you don't know, ask
- ALWAYS show what you already found before asking questions (reduce user effort)
- Keep rounds short (1-3 questions max per round)
- Skip irrelevant rounds (e.g., no external API questions for a pure UI story)
- Preserve user's exact wording for decisions and constraints
- The generated file should feel handwritten, not machine-generated
- Do NOT duplicate information already in other interview.md files

## Templates

- `.claude/templates/spec/interview-format.md` — interview rounds, adaptive questions, output format
