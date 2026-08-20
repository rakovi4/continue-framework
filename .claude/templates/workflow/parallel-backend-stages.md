# Parallel Backend Scenario Stages

Backend-style scenarios use three human-reviewed stages. This applies to backend,
integration, security, load, and infrastructure scenarios. The coordinator alone
owns `progress.md`; every lane owns only its declared files.

## Stage 1 — Acceptance RED and Contract Design

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
Stage 1 join it records the approved execution shape next to the Stage 2 checkbox:

```markdown
- [ ] stage-2 implementation lanes
<!-- stage-2-plan:
usecase: unit={usecase}; writes=[{path}: {delta}, ...]; frozen-surfaces=[...]
adapter-{name}: unit={adapter boundary}; writes=[{path}: {delta}, ...]; frozen-surfaces=[...]
-->
```

Before dispatch, the coordinator records disjoint ownership for both lanes. The
acceptance lane cannot edit contracts or skeletons; the design lane cannot edit the
acceptance test. Each lane runs its own required checks and commits its own files.
Only the coordinator advances the stage in `progress.md` after both commits exist.
It marks Stage 1 done and makes `approve stage-1 contracts` current; Stage 2 stays
pending.

If acceptance RED reports `ALREADY_GREEN`, the design lane may finish its read and
commit only genuinely missing contract artifacts; it must not replace working code.
The coordinator records the result and, after Stage 1 approval, marks Stage 2 `[S]`
with the reason before advancing to Stage 3 verification.

Stage 1 closes with a user review of the acceptance test, frozen interfaces, and lane
plan. Approval freezes the use-case and port contracts for Stage 2. The coordinator
records approval by completing its checkbox and advancing Stage 2. Rejection resets
Stage 1 to current, leaves approval and Stage 2 pending, and records the requested
change in the Stage 1 dispatch context. Stage 2 is undispatchable while approval is
not `[x]`.

## Stage 2 — Implementation Lanes

After approval, dispatch one complete RED-to-GREEN lane for the use case and one
for each discovered adapter. Start all independent lanes together, bounded by the
platform's available agent capacity; queue surplus lanes. Each lane owns its test
and production files and runs this sequence without an internal user pause:

1. RED, test review, and behavior commit
2. GREEN, focused coverage, and behavior commit
3. refactor and refactor commit when that lane changed executable code

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

Every lane returns its commit identities, checks, status, and owned paths. As part
of each successful publication lock, the coordinator immediately stores that lane
in an HTML comment below the Stage 2 checkbox and commits the checkpoint before
releasing the lock; lane agents still never edit `progress.md`. This closes the
interruption window between publication and durable recognition.

On resume, require the recorded commit to be an ancestor of `HEAD` and compare each
owned path at `HEAD` with that lane's committed tree. Preserve the lane only when
both checks match; dispatch failed, missing, reverted, or invalidated lanes. A failed
lane leaves the stage `[~]`, names itself and its failure, and does not cancel or
roll back successful independent lanes.

```markdown
- [~] stage-2 implementation lanes
<!-- lanes: usecase=abc123 PASS; storage=def456 PASS; rest=FAILED timeout -->
```

### Commit Publication Lock

Implementation and tests remain concurrent. Only publication is serialized:

1. A lane finishes changes and checks without staging.
2. It requests the coordinator's commit lock.
3. Under the lock it verifies its owned-path diff, stages explicit owned paths, and
   commits. Unrelated unstaged paths do not block publication and are never staged.
4. The coordinator commits that lane's `progress.md` checkpoint, then releases the
   lock.
5. The lane never uses a shared catch-all stage command or edits `progress.md`.

The coordinator grants one publisher at a time. A failed commit releases the lock,
leaves the lane incomplete, and cannot expose stage completion. After every required
implementation lane succeeds, run targeted coverage follow-up lanes concurrently
only for concrete gaps reported by their focused coverage runs. Coalesce gaps that
target the same test file into one lane; never create serial follow-up lanes for one
path. Concurrent writers never share a path. A follow-up owns the named test file,
commits under the same lock, and must pass before Stage 2 advances.

Only the coordinator marks Stage 2 done after all required lanes and admitted
coverage follow-ups have durable commits. It advances directly to Stage 3 in the
coordinator commit and stops at that work-unit boundary.

## Stage 3 — Acceptance GREEN and Independent Review

Dispatch these read/write-independent lanes concurrently:

- Acceptance GREEN enables only the disabled black-box test and runs the acceptance
  suite. It writes no production code.
- `agent-review-agent` and `premortem-agent` read the immutable Stage 1 and Stage 2
  commit range. They do not wait for acceptance GREEN and do not edit files.

Join all three results before changing progress. On acceptance failure, mark Stage 3
pending, reset the implicated Stage 2 lane and Stage 2 checkbox to current, and
invalidate that lane's checkpoint. The acceptance lane
never repairs production code. After acceptance succeeds, partition review
findings with `triage-and-auto-fix.md` and apply admitted SAFE fixes only after the
join, so they cannot race the acceptance lane.

An admitted `NEEDS_CYCLE` is a proposal, not cycle plan state. Complete and commit
Stage 3, append a `resolve stage-3 cycle proposals` decision checkbox, and store the
proposals in an adjacent HTML comment. This ends the Stage 3 work unit at a legal
commit boundary. The later decision work unit adds cycle checkboxes only after
explicit agreement; rejection completes the decision without adding them. With no
proposal, Stage 3 completes the scenario directly.

Stage 3's review agents intentionally read the immutable Stage 1+2 range while
acceptance GREEN enables the test concurrently. This is the staged-backend exception
to the ordinary completed-block range: Stage 1 already reviewed the test content,
and Stage 3's suite execution guards the remove-marker-only change. Consume this
review batch once; closure does not dispatch a duplicate boundary batch.

## Progress Shape

```markdown
### 1.1 Scenario title
- [~] stage-1 acceptance RED + contract design
- [ ] approve stage-1 contracts
- [ ] stage-2 implementation lanes
- [ ] stage-3 acceptance GREEN + review
```

Legacy scenarios already started with the serial checkbox shape keep that shape.
Do not rewrite an in-flight scenario underneath its current cursor.
