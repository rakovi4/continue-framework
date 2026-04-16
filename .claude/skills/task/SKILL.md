---
name: task
description: Create a new task (bug or refactoring) with spec and progress tracking. Use when user wants to create a task or mentions /task command.
---

# /task - Create Task

## Input

- **type** (optional): `bug` or `refactoring`
- **title** (optional): Short title (2-5 words)

## Workflow

### 1. Determine Task Number

List ALL directories under `ProductSpecification/tasks/` AND `ProductSpecification/tasks/done/` (use `ls`). For EACH folder, extract the leading integer (e.g., `1-refactoring-task-entity` -> `1`, `2-bug-modal-scroll` -> `2`). List every extracted number explicitly, then pick the max. Next number = max + 1. If no folders exist, start at 1. **All task types share one global sequence** -- a bug after refactoring task 1 gets number 2, not 1. Done tasks still occupy their numbers.

**Verification (mandatory):** Before creating the folder, confirm that NO existing folder starts with the chosen number. Run `ls ProductSpecification/tasks/ | grep "^{N}-"` -- if it returns results, increment N and re-check.

### 2. Determine Type and Title

If arguments provided, parse type (`bug` or `refactoring`) and title from args.
If no arguments, ask interactively: type and short title (2-5 words).

### 3. Create Folder

Create `ProductSpecification/tasks/{N}-{type}-{slug}/` where slug is lowercase-hyphenated title.

### 4. Interactive Spec (2-3 rounds)

Gather from user:

**All types:** Problem, Solution, Affected Layers (domain, usecase, h2, rest, email, frontend), Key Files.

**Bug only:** Reproduction steps.

**Refactoring only:** Numbered steps with clear scope.

### 5. Generate spec.md

Write `ProductSpecification/tasks/{N}-{type}-{slug}/spec.md` using the format in `.claude/templates/task/creation-formats.md`.

### 6. Generate progress.md

Select fix profile based on type and affected layers:

| Affected Layers | Section |
|-----------------|---------|
| Backend only | `## Backend` (standard backend sequence with `[ ] adapters-discovery`) |
| Frontend only | `## Frontend` (standard frontend sequence) |
| Both | `## Backend` + `## Frontend` |
| Refactoring | `## Fix` with user-defined steps |

Write `ProductSpecification/tasks/{N}-{type}-{slug}/progress.md` using the matching format from the template. Bug tasks use `[ ] adapters-discovery` -- adapter discovery runs when this step is reached. Refactoring steps are user-defined from step 4.

### 7. Review and Commit

Show spec.md and progress.md to user for review. Commit both files.

## Rules

- Task numbers are global and sequential across all types
- Slug uses lowercase-hyphenated title (max 5 words)
- Commit message: `task: spec (Task {N}, {title})`

## Templates

- `.claude/templates/task/creation-formats.md` -- spec.md format, progress.md formats
