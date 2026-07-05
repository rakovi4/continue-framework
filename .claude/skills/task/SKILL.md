---
name: task
description: Create a new task (bug, refactoring, or qa) with spec and progress tracking. Use when user wants to create a task or mentions /task command.
---

# /task - Create Task

## Input

- **type** (optional): `bug`, `refactoring`, or `qa`
- **title** (optional): Short title (2-5 words)

## Workflow

### 1. Determine Task Number

List ALL directories under `ProductSpecification/tasks/` AND `ProductSpecification/tasks/done/` (use `ls`). For EACH folder, extract the leading integer (e.g., `1-refactoring-task-entity` -> `1`, `2-bug-modal-scroll` -> `2`). List every extracted number explicitly, then pick the max. Next number = max + 1. If no folders exist, start at 1. **All task types share one global sequence** -- a bug after refactoring task 1 gets number 2, not 1. Done tasks still occupy their numbers.

**Verification (mandatory):** Before creating the folder, confirm that NO existing folder starts with the chosen number. Run `ls ProductSpecification/tasks/ | grep "^{N}-"` -- if it returns results, increment N and re-check.

### 2. Determine Type and Title

If arguments provided, parse type (`bug`, `refactoring`, or `qa`) and title from args.
If no arguments, ask interactively: type and short title (2-5 words).

### 3. Create Folder

Create `ProductSpecification/tasks/{N}-{type}-{slug}/` where slug is lowercase-hyphenated title.

### 4. Interactive Spec (2-3 rounds)

Gather from user:

**Bug:** Problem (as thorough as possible — symptoms, observed vs. expected, environment, frequency, any captured response/error) and Reproduction steps. Do NOT gather a Solution, Affected Layers, or Key Files at creation — those are produced by the discovery sequence (root cause analysis records the cause and key files in `spec.md`; design settles the fix approach; steps discovery scopes the layers). Describe the problem fully; defer every claim about the fix.

**Refactoring:** Problem, Solution, Affected Layers (domain, usecase, h2, rest, email, frontend), Key Files, and numbered steps with clear scope.

**QA only:** Problem (why this checklist exists), Solution (when to run, environment, session duration), Cases (numbered one-line items expressing intent — no Gherkin, no implementation detail). No Affected Layers, no Key Files (QA tasks don't change code).

### 5. Generate spec.md

Write `ProductSpecification/tasks/{N}-{type}-{slug}/spec.md` using the format in `.claude/templates/task/creation-formats.md`.

### 6. Generate progress.md

Select fix profile based on type and affected layers:

| Type / Affected Layers | Section |
|------------------------|---------|
| Bug — any layer (backend, frontend, or both) | `## Fix: {description}` discovery-first: `[ ] root cause analysis` → `[ ] design` → `[ ] steps discovery`. Prepend `[ ] reproduce in prod-copy` when the bug is observed in prod-copy. Concrete TDD steps (including any `adapters-discovery`) are inserted by `/continue` at `steps discovery`. |
| Refactoring | `## Fix` with user-defined steps |
| QA | `## Cases` with one `[ ]` checkbox per case (no TDD sub-steps) |

Write `ProductSpecification/tasks/{N}-{type}-{slug}/progress.md` using the matching format from the template. Bug tasks are discovery-first regardless of affected layer — never pre-plant `adapters-discovery` at creation; it is a sub-step `steps discovery` inserts, not the bug gate. Refactoring steps are user-defined from step 4. QA tasks mirror the `## Cases` section of `spec.md` as checkboxes — the tester ticks them during a session.

### 7. Review and Commit

Show spec.md and progress.md to user for review. Commit both files.

## Rules

- Task numbers are global and sequential across all types
- Slug uses lowercase-hyphenated title (max 5 words)
- Commit message: `task: spec (Task {N}, {title})`

## Templates

- `.claude/templates/task/creation-formats.md` -- spec.md format, progress.md formats
