# Parallel Backend Scenario Stages

Backend-style scenarios use three stages. This applies to backend,
integration, security, load, and infrastructure scenarios. The coordinator alone
owns `progress.md`; every lane owns only its declared files.

## Stage 1 — Acceptance RED and Contract Design

Load `story-quality-checklist.md`; materialize acceptance quality entries before
dispatch. The coordinator runs RED → `/test-review` → test commit → `/refactor` →
separate refactor publication for each acceptance scope, recording each completed
phase. Join only after those entries have valid evidence; design approval cannot
substitute for test review or refactor execution.

Dispatch these lanes concurrently:

| Lane | Responsibility | May change |
|------|----------------|------------|
| Acceptance RED | Write, review, and refactor the disabled black-box test | Acceptance test and its test DSL only |
| Contract design | Plan the design, discover adapters, create the use-case and adapter skeleton, and fix every use-case and port interface | Domain/use-case contracts and adapter skeletons declared before dispatch |

The design lane does not ask the user questions. It makes the best design supported
by the story, existing architecture, and acceptance criterion, and records any
material choice in a decision file. It may inspect the acceptance lane's committed
result if available, but neither lane waits for the other.

### Stage 2 Lane-Plan Gate

The design lane also returns the Stage 2 lane plan. Derive lanes from architectural
execution boundaries, never from the number of files, classes, tests, guards, or
estimated work:

- Plan one complete lane for the scenario's use-case behavior and one for each
  discovered adapter boundary. Collaborating classes inside one boundary stay in
  that lane. If one adapter owns the scenario, one RED agent owns its complete
  focused test surface and one GREEN agent owns the complete production fix.
- Treat `frozen-surfaces` and `writes` as contract and ownership inventories, never
  as lists of test targets. Each lane's RED surface enters through public usecase
  methods or the adapter's public technology-facing entry/implemented port. Internal
  DTOs, mappings, persistence models, security helpers, resolvers, exception
  translators, and similar collaborators are covered through that entry.
- Maximize genuine concurrency by freezing seams that let independent lanes compile
  and test against Stage 1 contracts. A focused composition check for collaborators
  inside one adapter belongs to that single adapter lane. A cross-lane acceptance or
  boot check becoming green only after several lanes join is Stage 3 composition
  verification, not a Stage 2 dependency.
- Every Stage 2 lane must complete its own focused RED-to-GREEN cycle against the
  frozen Stage 1 surface without another lane's new output. Serial Stage 2 lanes are
  invalid. If proposed work has such a dependency, freeze a natural seam in Stage 1
  or coalesce the dependent work into one architectural lane. If neither is sound,
  the design cannot pass approval.
- Enumerate every writable production, test, Statements/fixture/helper, and
  configuration path in the owning lane's manifest, naming the intended Stage 2
  behavior delta for each. A collaborator with no planned delta does not enter
  `writes`. Manifests must be disjoint. If proposed lanes share a writable path or
  need to revise the same focused test surface, coalesce them or redesign ownership
  before approval; never call them lanes and plan to serialize their edits.
- Record frozen Stage 1 contracts as symbol/signature/model surfaces, not whole-file
  ownership. A file may contain both a frozen surface and a Stage 2 method body or
  stub that its lane must implement. The lane may own that file while preserving the
  named surface; a frozen collaborator with no planned behavior delta stays out of
  `writes`.

The coordinator rejects a design result that lacks this gate's evidence. After the
Stage 1 join it records the approved execution shape in the active work-log entry:

```markdown
<!-- stage-2-plan:
usecase: unit={usecase}; writes=[{path}: {delta}, ...]; frozen-surfaces=[...]
adapter-{name}: unit={adapter boundary}; writes=[{path}: {delta}, ...]; frozen-surfaces=[...]
-->
```

Before dispatch, the coordinator records disjoint ownership for both lanes. The
acceptance lane cannot edit contracts or skeletons; the design lane cannot edit the
acceptance test. Workers return their checks and edits without staging or committing.
Only the coordinator publishes and advances the stage after both lanes and acceptance
quality entries complete, keeping reviewed tests and refactoring in separate commits.
It marks Stage 1 done and makes `approve stage-1 contracts` current; Stage 2 stays
pending.

If acceptance RED reports `ALREADY_GREEN`, the design lane may finish its read and
commit only genuinely missing contract artifacts; it must not replace working code.
The coordinator records the result and, after Stage 1 approval, marks Stage 2 `[S]`
with a compact work-log reference before advancing to Stage 3 verification.

Stage 1 closes with a user review of the acceptance test, frozen interfaces, and lane
plan. Approval freezes the use-case and port contracts for Stage 2. The coordinator
records approval by completing its checkbox and advancing Stage 2. Rejection resets
Stage 1 to current, leaves approval and Stage 2 pending, and records the requested
change in the Stage 1 work-log entry. Stage 2 is undispatchable while approval is
not `[x]`.

## Stage 2 — Implementation Lanes

For whole-story execution, use `story-stages.md`'s shared backend/frontend queue;
the sequence below advances each backend lane within that queue.

After approval, the coordinator advances one lane for the use case and one for each
discovered adapter. Each is a coordinator-owned state machine, not one autonomous
worker; the coordinator dispatches every phase so no worker must nest a fan-out.
Load `stage-2-quality-gates.md` for mandatory scope, evidence, and completion gates.

For each lane:
1. Dispatch its RED writer. Require the predicted raw failure and test-only owned
   paths before any production writer starts.
2. After raw RED is observed, start the GREEN writer and `/test-review` as sibling
   work, bounded by available capacity. Test-review may complete validation omitted
   by the RED writer; GREEN owns production paths only.
3. Join the reviewed test and production candidate. Reject overlapping writes;
   commit the reviewed disabled test from explicit test paths while production edits
   remain unstaged. Dispatch `/refactor` for every test and helper, publish its
   changes separately, then enable and run against the candidate. A test defect
   returns to test-review; an implementation failure returns to GREEN.
4. When the complete reviewed target and module suite pass, dispatch focused
   `/test-coverage` for every touched production module. Commit the verified
   production paths plus the marker-only enable delta as GREEN, then dispatch
   `/refactor` over all lane production and test paths and publish changes separately.
5. Complete admitted follow-ups, verify the final result, and reconcile the lane's
   quality-gate evidence before reporting it complete.

Stage 1 contracts are read-only in every Stage 2 ownership declaration. A lane that
finds a contract defect fails with evidence; it never edits the frozen interface.

Before dispatch:

1. Normalize the plan: merge subdivisions of one boundary; reject per-internal-type
   test targets, overlapping writes, missing behavior deltas, and frozen-surface
   changes. Reconstruct a missing legacy plan. If normalization requires a contract
   change, return to Stage 1.
2. Reject every dependency between lanes. Merge the work when it belongs to one
   boundary; otherwise return to Stage 1 and freeze a seam.
3. Start every lane immediately, up to agent capacity. Surplus lanes wait only for
   capacity; they are not serial dependencies.

Only publication is serialized. A shared worktree, build visibility, or the
version-control index never justifies serial implementation; disjoint manifests bound
edits, and the publication lock serializes index writes.

Every lane checkpoint records the named results from `stage-2-quality-gates.md`,
RED/GREEN and separate refactor commits, or its pending phase. The coordinator
stores each published phase in the active work log before releasing the lock;
workers edit neither tracking file.

On resume, require the recorded commit to be an ancestor of `HEAD` and compare each
owned path at `HEAD` with that lane's committed tree. Preserve the lane only when
both checks match; dispatch failed, missing, reverted, or invalidated lanes. A failed
lane leaves the stage `[~]`, names itself and its failure, and does not cancel or
roll back successful independent lanes.

Compact lane summaries link to the complete quality-gate evidence; `NO_CHANGE`
without a recorded completed refactor scan is incomplete.

### Commit Publication Lock

Implementation and tests remain concurrent. Only publication is serialized:

1. A worker finishes its phase without staging.
2. After joining that phase's prerequisites, the coordinator takes the commit lock.
3. Under the lock the coordinator verifies ownership, stages explicit phase paths,
   commits, and records the checkpoint. Unrelated paths are never staged.
4. Workers never commit, use a shared catch-all stage command, or edit tracking state.

The coordinator grants one publisher at a time. A failed commit releases the lock
and leaves the phase incomplete. After the implementation candidates join,
run targeted coverage follow-up lanes concurrently only for concrete gaps reported
by focused coverage. Coalesce gaps that target the same test file into one lane;
never create serial follow-up lanes for one path. Concurrent writers never share a
path. A follow-up owns the named test file, passes the same quality gates, and
publishes under the same lock before Stage 2 advances.

Only the coordinator marks Stage 2 done after all required lanes and admitted
coverage follow-ups have durable commits and complete quality-gate evidence.
It advances directly to Stage 3 in the coordinator commit and stops at that
work-unit boundary.

## Stage 3 — Acceptance GREEN

Enable only the disabled black-box test and run the acceptance
suite. This stage writes no production code. On acceptance failure, mark Stage 3
pending, reset the implicated Stage 2 lane and Stage 2 checkbox to current, and
invalidate that lane's checkpoint. The acceptance lane
never repairs production code. Acceptance success completes the scenario.

## Progress Shape

```markdown
### 1.1 Scenario title
- [~] stage-1 acceptance RED + contract design
- [ ] approve stage-1 contracts
- [ ] stage-2 implementation lanes
- [ ] stage-3 acceptance GREEN
```

Legacy scenarios already started with the serial checkbox shape keep that shape.
Do not rewrite an in-flight scenario underneath its current cursor.
