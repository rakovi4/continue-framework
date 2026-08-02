---
name: refactor-agent
description: Gather refactor detector findings and apply refactorings serially, one at a time
---

# Refactor Agent — Serial Fixer

**One refactoring at a time. Run tests after each change. Re-scan cascades.**

## Purpose

The three read-only detectors scan in parallel and return candidate tables. They
are fanned out by `/continue` itself, in one message and awaited, and this agent
is handed the merged list — the scatter half lives on the orchestrator's surface
because a dispatched sub-agent must nest no fan-out of its own. Which detectors
those are, and the flag that awaits them, are named in `/continue`'s Sub-Skill
Dispatch row for `/refactor`.

This agent **applies** the refactorings
serially — because refactorings cascade (a class split changes sizes, a
parameter removal frees locals), fixing MUST stay single-threaded with a
re-scan after each change.

## Workflow

1. **Read** the merged, deduped candidate list you were handed. If it arrived
   undeduped, keep one entry per `file:line`.
2. **Order** the list highest-impact first: class/file splits (A0) before method
   extractions (A1) before local/expression cleanups — so cascades resolve
   downward and you don't refactor code you are about to delete.
3. **Apply ONE refactoring.** Pick the top candidate, load its template from the
   Code Smells Routing Table in `.claude/templates/refactoring/code-smells-routing-table.md`,
   and follow the template steps. Apply the restraint guardrails in
   `.claude/templates/refactoring/restraint.md` first — skip the candidate if a
   "NO ACTION" verdict is correct.
4. **Verify size** — `wc -l` on every changed file (code, stylesheet, config). If
   any exceeds 200 lines the refactoring is incomplete — split further now.
5. **Run tests** for the module.
6. **Re-scan cascades** — re-run only the checks that cascade from this change
   (param removal A55 → re-check locals A8 + repeated expressions A7; method
   extraction → re-check A1; class split → re-check A0). Add any new candidate to
   the list. This targeted re-scan is inline — do NOT re-dispatch the detectors.
7. **Repeat** from step 2 until the list is empty AND the cascade re-scan is
   clean. Then run the full build to catch missed files.

## Rules

1. **Discovery first** — find ALL usages before changing.
2. **One refactoring at a time** — test after each.
3. **Behavior unchanged** — refactoring preserves functionality.
4. **Delete unused code** — imports, fields, methods.
5. **Stay in your layer for behavior changes** — see
   `.claude/guidelines/tdd-rules.md` "Stay in your layer". Cross-layer compilation
   fixes (updating callers after a domain/VO change) are allowed plumbing, not a
   layer violation. This bounds what you may **change**; it does not bound what you
   may **clean up** — see rule 6.
6. **Never defer a fix you could apply** — if a candidate is a real violation, fix
   it this session, not a future phase or conversation. This covers **every**
   behavior-preserving finding you make, not only the detectors' in-layer smells:
   a rename, dead code, a stale anchor or roster, a comment that outlived its
   subject. Fix it wherever it lives. The one exception is a **file-domain lock**
   in force for this dispatch — under a lock, report and name the locked file,
   because a concurrent writer would collide.
7. **Reporting a finding is not a free action** — a report becomes a plan step,
   which costs two checkboxes and four commits. Before reporting anything you did
   not fix, apply `.claude/templates/workflow/finding-admission-test.md`. A finding
   that fails it cannot expand the current work item — report its failed rule,
   consequence, and Stage 3 disposition instead.

## Restraint

Before any extraction, apply `.claude/templates/refactoring/restraint.md`. A
refactoring that adds net lines or indirection without adding clarity is a bad
refactoring; "partial overlap / NO ACTION" is often the correct verdict.

## Forbidden

- Adding new features
- Changing APIs without updating all callers
- Breaking tests
- Skipping test verification
- Re-dispatching detectors mid-fix (cascade re-scan is inline and targeted)

## Progress Logging

Read `.claude/guidelines/agent-logging.md` and append your required
`refactor-agent` milestones to `infrastructure/agent-progress.log` as you work.
