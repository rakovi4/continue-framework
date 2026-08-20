# Parallel Frontend Scenario Stages

Frontend scenarios use one shared worktree. The coordinator alone owns
`progress.md`, staging, commits, and stage transitions. Before every dispatch it
records the file manifest and each path's baseline in the active work-log record;
manifests must be disjoint. A manifest path already dirty before dispatch makes the
lane undispatchable: never mix a worker edit with pre-existing work in one file.

## Stage 1 — Acceptance RED and Interface Design

Dispatch Selenium RED and frontend design concurrently. Selenium RED owns its test
and Statements files. Design owns only the declared shared component, logic,
API-client, type, and test-interface files. Design is non-interactive: it infers the
best supported design and prepares interfaces without implementing lane behavior.
Shared contracts must live in interface-only files. Reject Stage 1 when a frozen
contract is co-located with production behavior a Stage 2 lane must implement.

Join both results once. Reject a worker that staged, committed, edited
`progress.md`, or touched an undeclared path. After both succeed, the coordinator
runs their checks together, stages explicit owned paths, commits once, and advances
Stage 2. Every Stage 1 interface becomes read-only for Stage 2.

## Stage 2 — Implementation Lanes

Build three manifests from the frozen design and dispatch all non-trivial lanes:

| Lane | Complete sequence | Owns |
|------|-------------------|------|
| Frontend logic | RED → test review → GREEN → refactor | Logic production and test files |
| API client (`layer=frontend-api`) | RED → test review → GREEN → refactor | API-client production and test files |
| Design alignment | Component build → align → design review → focused coverage → refactor → verify-only align | Component and style files |

Skipped trivial logic or API behavior is recorded by the coordinator; another lane
does not inherit its files implicitly. Shared Stage 1 interfaces remain read-only.
A lane that needs another lane's path or a frozen-interface change fails with the
conflicting path and evidence instead of editing it.

Workers calculate changed paths only within their manifest against its recorded
baseline; peer-lane edits are never attributed to them. The coordinator separately
rejects every worktree path absent from all manifests. Workers never stage or
commit. Each returns status, checks, and changed paths. The
coordinator records only the first terminal result for each lane and ignores late or
duplicate completions. After each success it writes a coordinator-owned checkpoint
to the active work-log entry containing the lane, manifest, baseline blobs, resulting
file hashes, and checks. A failure keeps Stage 2 current and preserves successful
disjoint changes.

`<!-- frontend-lanes: logic=PASS manifest=... baseline=... result=... checks=... -->`

On resume, validate every checkpoint's manifest, baseline, result hashes, and checks
against the retained worktree. Preserve only matching successful lanes; redispatch
incomplete or invalidated lanes. A checkpoint is coordinator state, not permission
for a worker to edit either tracking file.

After all required lanes succeed, the coordinator verifies changed paths against
the manifests and clean baselines, runs the combined frontend checks, stages
explicit paths, commits once, marks the checkpoint joined, and advances Stage 3.
Preserve the checkpoint as evidence. Do not launch Stage 3 before
the join succeeds.

Focused coverage runs in report-only lane mode: it returns gaps without editing
`progress.md`. After the join, the coordinator applies the finding-admission test
and alone records any admitted follow-up.

## Stage 3 — Selenium GREEN and Independent Review

Require the committed Stage 2 join, then dispatch three independent reads of that
state concurrently:

- Selenium GREEN removes only the test skip marker and runs the browser suite.
- `agent-review-agent` and `premortem-agent` read the immutable Stage 1+2 range.

Join all three exactly once before changing progress. Review workers never edit the
tree. On Selenium failure, keep Stage 3 current and identify the responsible Stage 2
lane or integration seam; the verification lane never repairs production code.
After GREEN, run the headed demo, then partition review findings. Apply SAFE fixes
only after the join so they cannot race verification.

Persist the joined review result with the exact Stage 2 commit as a coordinator
checkpoint in the active work-log record. A retry against that commit reuses it
and dispatches only Selenium. If failure requires a Stage 2 repair, invalidate the
old checkpoint; after the repaired Stage 2 join, dispatch a new review generation
once over the updated range. Late results from an invalidated generation are ignored.

An admitted `NEEDS_CYCLE` remains a proposal. Complete Stage 3 and append a
`resolve stage-3 cycle proposals` decision checkpoint with a durable pointer to its
work-log record; insert no implementation steps until the user explicitly agrees. Rejection
completes the checkpoint without insertion, and silence never advances it. With no
proposal, Stage 3 closes the scenario.

This review batch reads Stage 1+2 because Stage 1 already reviewed the Selenium test
content and Stage 3 guards the remove-marker-only delta by running it. Consume the
batch once per Stage 2 commit; scenario closure must not dispatch a duplicate
boundary review.

## Progress Shape

```markdown
### 1.1 Scenario title
- [~] stage-1 frontend acceptance RED + interface design
- [ ] stage-2 frontend implementation lanes
- [ ] stage-3 frontend acceptance GREEN + review
```

Legacy frontend scenarios already started with the serial shape keep that shape.
