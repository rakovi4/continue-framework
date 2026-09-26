# Story Quality Checklist

The coordinator materializes required quality phases in `progress.md` before
dispatching their writers. These are executable obligations, not a closing summary.
Use this contract for whole-story, staged, and legacy serial story execution.

## Plan shape and ownership

Append one `## Quality gates` section after the scenario sections, with no `###`
headings. Keep scenario headings, tiers, and existing checkboxes unchanged. These
entries do not count as scenarios; they do block stage completion and story archive.
Each line uses `quality stage-{N} {scope-id} {phase}` plus a compact work-log pointer
when completed. Scope ids are stable, unique within their stage, and resolve to
owned paths and scenario mappings in the work log, never to an unspecified "all".

Before Stage 1 writers start, add two entries per acceptance scope: `test-review`
and `refactor`. Scope may batch cases with shared helpers; reconcile every backend
and browser case across all applicable categories in both tiers, plus every test,
Statements, client, fixture, and
helper with one owner. Batching never permits sampling or omitted files.

Before freezing the Stage 2 plan, add entries per implementation lane from the
table below. Include every adapter, usecase, frontend logic/API, design lane, and
admitted follow-up. Domain and wiring paths belong to an explicit lane. Derive
the checklist from the manifest, not from whichever skills happened to run.

| Stage/scope | Required phases, in dependency order |
|-------------|--------------------------------------|
| Stage 1 acceptance | `test-review`, `refactor` |
| Stage 2 RED/GREEN lane | `test-review`, `red-refactor`, `coverage`, `green-refactor` |
| Stage 2 design alignment | `design-review`, `test-review`, `coverage`, `green-refactor`, `align-verify` |

```markdown
## Quality gates
- [ ] quality stage-1 acceptance-api test-review
- [ ] quality stage-1 acceptance-api refactor
- [ ] quality stage-1 acceptance-browser test-review
- [ ] quality stage-1 acceptance-browser refactor
- [ ] quality stage-2 backend-usecase test-review
- [ ] quality stage-2 backend-usecase red-refactor
- [ ] quality stage-2 backend-usecase coverage
- [ ] quality stage-2 backend-usecase green-refactor
```

Repeat the applicable rows for every actual scope. The example is not a fixed
roster. A legitimately omitted implementation lane has no rows and needs its
existing omission evidence; a present lane cannot omit a required phase.

## Execution and evidence

Dispatch each entry through `/continue`'s named skill routing, inside its owning
stage, using `quality-execution.md` for worker reuse and overlapping independent
phases. Checklist dependency order does not prohibit early read-only inspection;
inspection alone cannot complete a refactor entry. A returned test review may enter
RED refactoring after test publication while its joined verification remains pending.
`test-review` means `/test-review`; all refactor phases mean `/refactor`;
`coverage` means `/test-coverage`; design phases use `/design-review` and
`/align-design` verify-only. The parent stage and its quality entries advance
together; they are not duplicate executions or new invocation boundaries.

After each awaited phase, record one compact result under `quality-execution.md`,
linking its manifest, checked inputs, execution/reuse evidence, and verification.
Include the scope-worker or detector/fixer references required by the selected mode;
a retrospective claim that it ran is insufficient. Reuse complete inventories and
reports by reference instead of copying them into each checkpoint.
Refactor also records the behavior/test commit and separate
refactor commit, or the completed scan's `NO_CHANGE`. Preserve the fuller named
evidence in `stage-2-quality-gates.md`. Then mark that entry `[x]` with its work-log
pointer and publish through the coordinator. If a phase requires joined verification,
its returned findings alone cannot close the entry; await that verification first.
Never pre-check future phases or
bulk-check the section because the implementation or suite passed.

Required quality entries cannot be `[S]`. No findings means a completed scan, not
permission to skip it. A coverage or review phase with no applicable targets still
runs its scope assessment and records why; it is not an unexecuted success.
Capacity limits queue phases. Missing tools or failed checks leave them pending.

## Stage and completion gates

Before starting Stage 2, every Stage 1 quality entry must be `[x]` with valid
evidence. Before starting Stage 3, every Stage 2 entry must meet the same condition.
Do not mark a parent stage complete while any of its required entries is missing,
pending, skipped, or unsupported. Verify this again before archive; passing tests,
an informal "reviewed" statement, or coverage percentages cannot replace execution.

## Adoption and resume

For an active story, reconcile this section before selecting a pass on every
`/continue`: add missing required rows without replacing or reordering scenario
steps, and preserve only entries supported by evidence for the retained files.
An absent section or an already-checked parent is not evidence that its phases ran.
Reset unsupported `[x]` or `[S]` quality entries to `[ ]` and reopen affected parent
stages; select the earliest incomplete pass. Do not rerun proven unchanged writers
or invent historical RED failures to recover missing reviews. Run the missing
skills against retained code and record the recovery explicitly.

Track each phase's input/output revisions through subsequent recorded phases.
Behavior-preserving refactoring and marker-only enable edits do not erase an earlier
review; changed assertions or setup require review again. Unrecorded edits or added
paths invalidate affected evidence. Refresh coverage and refactor after fixes.
Reused evidence must cover the complete scope and its retained revision chain,
including check-relevant dependency context under `quality-execution.md`. Unchanged
paths alone cannot validate checks involving changed collaborators.
Update the single physical `[~]` cursor after reconciliation;
the shared stage scheduler, not checklist line order, controls concurrency.

This is a bounded addition of existing obligations, not finding-driven scope
expansion. Do not apply it retroactively to archived stories unless the user asks
to reopen their implementation. A resumed unfinished story must reconcile it even
if all its old scenario checkboxes were marked complete.
