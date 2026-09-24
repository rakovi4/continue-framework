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

Build three manifests from the frozen design. Load `stage-2-quality-gates.md`;
the coordinator dispatches each phase of every active lane, including review and
refactor detectors, so workers never nest fan-outs. Use these sequences:

| Lane | Complete sequence | Owns |
|------|-------------------|------|
| Frontend logic | RED → test review → test refactor → GREEN → coverage → refactor | Logic production and test files |
| API client (`layer=frontend-api`) | RED → test review → test refactor → GREEN → coverage → refactor | API-client production and test files |
| Design alignment | Component build → align → design review → test review → coverage → refactor → verify-only align | Component, style, and explicitly owned test files |

A lane with no implementation delta may be omitted with evidence. Small or trivial
changes still require all quality gates; another lane never inherits files
implicitly. Shared Stage 1 interfaces remain read-only.
A lane that needs another lane's path or a frozen-interface change fails with the
conflicting path and evidence instead of editing it.

Workers calculate changed paths only within their manifest against its recorded
baseline; peer-lane edits are never attributed to them. The coordinator separately
rejects every worktree path absent from all manifests. Workers never stage or
commit. Each phase returns its result and changed paths. The coordinator records
only the first terminal result for each dispatched phase and ignores duplicate
completions. Each checkpoint includes the lane, manifest, baseline blobs, resulting
file hashes, and all named evidence required by `stage-2-quality-gates.md`. A GREEN
return alone cannot mark the lane successful. A failure keeps Stage 2 current and
preserves successful disjoint changes.

Publish reviewed RED tests, test refactoring, verified behavior, and final
refactoring separately under the backend template's Commit Publication Lock.
Skip a refactor commit only for an evidenced `NO_CHANGE` result.

On resume, validate every checkpoint's manifest, baseline, result hashes, and checks
against the retained worktree. Preserve only matching successful lanes; redispatch
incomplete or invalidated lanes. A checkpoint is coordinator state, not permission
for a worker to edit either tracking file.

After all required lanes succeed, the coordinator verifies changed paths against
the manifests and recorded baselines, reconciles all quality-gate evidence, and
runs the combined frontend checks. Commit the joined coordinator records after
separate phase publication, mark the checkpoint joined, and advance Stage 3.
Preserve the checkpoint as evidence. Do not launch Stage 3 before
the join succeeds.

Focused coverage runs in report-only lane mode: it returns gaps without editing
`progress.md`. Before completion, the coordinator applies the finding-admission
test, records gap dispositions, and completes admitted follow-ups through the same
quality gates.

## Stage 3 — Selenium GREEN and Demo

Require the committed Stage 2 join. Selenium GREEN removes only the test skip marker
and runs the browser suite. On failure, keep Stage 3 current and identify the
responsible Stage 2 lane or integration seam; the verification step never repairs
production code. After GREEN, run the headed demo and complete the scenario.

## Progress Shape

```markdown
### 1.1 Scenario title
- [~] stage-1 frontend acceptance RED + interface design
- [ ] stage-2 frontend implementation lanes
- [ ] stage-3 frontend acceptance GREEN + demo
```

Legacy frontend scenarios already started with the serial shape keep that shape.
