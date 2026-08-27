---
name: task
description: Create a behavior-change, bugfix, refactor, infra, general, or QA task with spec and progress tracking. Use when the user wants to create a task or mentions /task.
---

# /task - Create Task

## Input

- **type** (optional): `behavior-change`, `bugfix`, `refactor`, `infra`, `general`, or `qa`
- **title** (optional): short title of two to five words

## Workflow

1. List every directory under `ProductSpecification/tasks/` and
   `ProductSpecification/tasks/done/`. Extract and show every leading integer; the
   next global task number is the maximum plus one, or 1 when none exist. Before
   creation, verify no folder in either location starts with that number.
2. Parse the canonical type and title. If either is missing, ask for it.
3. Create `ProductSpecification/tasks/{N}-{type}-{slug}/`, with a lowercase,
   hyphenated slug of at most five words.
4. Gather the type-specific spec in two or three rounds:
   - **behavior-change:** problem, current and expected observable behavior,
     constraints, and likely key files; do not pre-plan TDD steps.
   - **bugfix:** symptoms, observed versus expected behavior, environment,
     frequency, captured errors, and reproduction; do not ask for a cause,
     solution, affected layers, or key files.
   - **refactor:** structural problem, behavior-preserving outcome, constraints,
     and likely key files; do not pre-plan implementation steps.
   - **infra:** problem, intended infrastructure-as-code outcome, constraints,
     likely files, and bounded direct work units. Never plan manual remote changes.
   - **general:** problem, intended outcome, constraints, likely files, and bounded
     direct work units.
   - **qa:** why and when to run the checklist, target environment, session
     duration, and numbered one-line cases; omit affected layers and key files.
5. Generate `spec.md` and `progress.md` from
   `.claude/templates/task/creation-formats.md`:
   - `behavior-change`: `design` then `steps discovery`; discovery inserts TDD.
   - `bugfix`: root-cause-first discovery; discovery inserts TDD.
   - `refactor`: design and discovery insert direct behavior-preserving steps.
   - `infra` and `general`: `design`, then one direct step per Work item.
   - `qa`: `design`, then one manual checkbox per case.
6. Show both files for review, then commit them as
   `task: spec (Task {N}, {title})`.

## Invariants

- Only `behavior-change` and `bugfix` use RED-to-GREEN work units.
- `refactor`, `infra`, `general`, and `qa` never receive RED/GREEN checkboxes.
- If a no-TDD task requires a behavior change, reclassify it or split out a TDD
  task before implementation.
- All types share one global number sequence, including archived tasks.
