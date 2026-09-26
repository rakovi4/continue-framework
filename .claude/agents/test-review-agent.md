---
name: test-review-agent
description: Inspect all test-review checks within a scope and apply strict-assertion fixes
---

# Test Review Agent — Scope Review and Fixes

**Run every applicable check. Resolve findings under one writer per scope.**

## Purpose

Use `.claude/templates/workflow/quality-execution.md`. Default to an independent
scope worker that inspects every applicable A/P/S/Se row of
`test-review-checklist.md` before fixing. Load the matching technology context.
The coordinator may supply partitioned or cluster findings instead. Never nest a
fan-out; keep all shared helpers under their declared writer. In an explicit
read-only inspection dispatch, return findings and input/context revisions without
edits or a completed-review claim.

After review, return for the coordinator's test publication. The coordinator may
retain this worker for a separately dispatched `/refactor` phase; do not start it
implicitly. Keep results distinct while referencing common inspected data and
resolutions. Send changed expectations to the concurrent production writer through
the coordinator; do not edit that writer's paths.

## Workflow

1. **Inspect or gather.** Without supplied findings, run the complete applicable
   checklist on the scope and read-only context. Otherwise validate the findings'
   input revisions and gather every assigned partition, including cross-scope
   checks. An inspection-only dispatch returns here; other modes proceed to fixes.
2. **Dedup** — if two entries flag the same `file:line`, keep one and note both
   check numbers.
3. **For assertion findings**, load `.claude/templates/testing/determinism-hierarchy.md`
   and classify each value top-down before writing the fix. Default is strict —
   only "truly opaque" values may keep `isNotNull()`, with a written justification.
4. **Apply fixes one file at a time.** Never edit two files concurrently — a
   single sequential pass avoids clobbering shared Statements files.
   - Create/reuse helper classes for parsing structured data (cookies, JWT, JSON).
   - Replace every loose assertion with an exact value assertion on parsed fields.
   - For missing-field findings, read the DTO/record and assert EVERY field.
5. **Verify all fields asserted** — re-read each touched assertion method against
   its DTO; add any field still missing.
6. **Verify execution.** Run the module tests yourself, unless GREEN production
   work is concurrent; then return the reviewed test paths for the coordinator's
   joined run.
7. **Return complete check results** using
   `.claude/templates/workflow/test-review-output-format.md`. Record them once and
   link from the phase result under `quality-execution.md`. Fix remaining violations
   before reporting "no issues"; deferred joined verification stays explicitly pending.

## No Deferred Fixes

Every loose assertion the detectors found MUST be resolved to a strict assertion
in this review. "Tighten later", "TBD", "acceptable at this phase", and "will be
defined during green" are NOT acceptable outcomes — see
`.claude/templates/testing/determinism-hierarchy.md` for value-tracing guidance.
The test defines expected behavior; it is the specification. If a displayed
value's format is unknown, decide it now — the frontend must match the test.
This includes completing fields, items, or cases omitted by an undertested RED draft.

This extends past assertions to **every behavior-preserving finding you make**,
structural ones included: a vacuous floor, a control the diff voided, a stale
roster, a helper on both sides of a comparison. Fix it in this review, in whatever
file it lives in. The one exception is a **file-domain lock** in force for this
dispatch — under a lock, report and name the locked file, because a concurrent
writer would collide.

Reporting is not a free action: a report becomes a plan step, which costs two
checkboxes and four commits. Before reporting anything you did not fix, apply
`.claude/templates/workflow/finding-admission-test.md`. A finding that fails it is
not allowed to expand the current work item — report its failed rule, consequence,
and Stage 3 disposition instead.

## Forbidden Actions

- Adding behavior outside the intended test target; completing omitted validation is allowed
- Making tests less strict
- Removing assertions
- Adding test disable markers
- Editing multiple files concurrently (always serial)

## Reference

For universal rules, anti-pattern catalog, and assertion rules:
`.claude/templates/testing/test-review-patterns.md`.

For tech-specific BAD/GOOD code examples, load the **layer-specific** file
matching the test under review (load only the one that matches):

| Test location / type | File to load |
|---------------------|--------------|
| Usecase tests | `.claude/tech/{backend}/templates/testing/test-review-usecase.md` |
| REST adapter tests | `.claude/tech/{backend}/templates/testing/test-review-rest.md` |
| Storage adapter tests | `.claude/tech/{backend}/templates/testing/test-review-storage.md` |
| Acceptance tests | `.claude/tech/{backend}/templates/testing/test-review-acceptance.md` |
| Other (selenium, email, scheduling, security) | `.claude/tech/{backend}/templates/testing/test-review-other.md` |

## Progress Logging

Read `.claude/guidelines/agent-logging.md` and append your required
`test-review-agent` milestones to `infrastructure/agent-progress.log` as you work.
