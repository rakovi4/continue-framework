---
name: interview
description: Interactive interview to create interview.md for a story. Asks structured questions about scope, APIs, decisions, and constraints, then generates the handwritten-style context file. Use when user wants to create story specifics or mentions /interview command.
---

# Generate interview.md via Interactive Interview

Conduct a structured interview with the user to gather all context needed for a story, then generate the `interview.md` file that feeds into the story spec step (dispatched by `/continue`), `/mockups`, `/api-spec`, `/test-spec`.

## Usage
```
/interview 5                    # By MVP story number
/interview "Create task"             # By story name
/interview                      # Interactive selection
```

## Workflow

### Phase 1: Context Gathering (Silent)

Before asking any questions, silently read. **Resolve the target story first** (Phase 2's parse step) — items 4, 6, 9 and 10 are scoped to it and cannot be read before it is known:

1. **Story mapping**: `ProductSpecification/stories.md`
2. **Product description**: `ProductSpecification/BriefProductDescription.md`
3. **Expected load**: `ProductSpecification/ExpectedLoad.md`
4. **Existing story spec** (if any): `ProductSpecification/stories/NN-story-name/NN_StoryName.md`
5. **Archived drafts**: `ProductSpecification/Archived/DraftStories/1st-iteration/` (scan for relevant files)
6. **A named precedent, if this story has one**: the `interview.md` or `decisions/*-decision.md` of the *specific* earlier story whose decision this one extends or contradicts — under `stories/` or `stories/done/`, and most often the latter, since a story with a settled decision is usually closed (`.claude/rules/workflow.md`, "Resolving a story folder"). Never all `stories/*/interview.md` — that sweep reconstructs the present from a pile of deltas; item 9 answers that question instead. Asking *whether* a precedent exists at all has its own permitted form — a keyword-scoped grep across `stories/**` including `done/` (`.claude/rules/workflow.md`, "Asking *whether* a non-goal or a rationale exists is not the banned sweep")
7. **Existing domain code**: Scan `backend/domain/src/` and `backend/usecase/src/`
8. **Existing adapters**: Scan `backend/adapters/*/src/`
9. **What the areas this story touches already do**: the acceptance tests **of those areas** — test class names, scenario descriptions, Statements. This is the current state, not the story folders (`.claude/rules/workflow.md`, "Where the Current State Lives"). Only **enabled** tests count as shipped — one still carrying its disable/skip marker is a pending increment, not shipped behavior. Where the suite is silent about an area, read that area's production code and say so in the interview — items 7-8 for a backend behavior, the frontend source for a UI-only one, which Phase 1 does not otherwise scan; silence is not evidence of absence. In a repo with no acceptance suite yet, say so explicitly and fall back to the story folders
10. **Existing test cases doc** (if any): `ProductSpecification/stories/NN-story-name/tests/01_API_Tests.md`

Items 4, 6 and 10 resolve `stories/NN-story-name/` first, then `stories/done/NN-story-name/` (`.claude/rules/workflow.md`, "Resolving a story folder"). "Not found" for items 4 and 10 means both came back empty — a closed story's spec and tests are in the archive, and reading them as absent is what turns a revisit into a from-scratch re-interview.

### Phase 2: Story Selection

Parse user input to determine target story: match by name or number via `ProductSpecification/stories.md`, or list available stories for interactive selection.
If `interview.md` already exists, warn and ask whether to regenerate or skip.

### Phase 3: Interview

Load `.claude/templates/spec/interview-format.md` for round structure and adaptive questions.

### Phase 4: Generate File

Compile all answers into `interview.md` using the format rules from the template.

### Phase 5: Review & Confirm

1. Show the full content of the generated file
2. Ask: "Does this look complete? Any corrections or additions?"
3. If corrections, update the file
4. Report the file path and suggest running `/continue NN` next (it dispatches the story spec step)

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
