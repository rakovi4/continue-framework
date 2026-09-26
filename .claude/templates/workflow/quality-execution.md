# Quality Execution

Load for `/test-review`, `/refactor`, and story quality scheduling. Every required
skill still executes and returns its own result; batching changes dispatch, not
check applicability, ownership, publication boundaries, or completion obligations.

## Jobs and capacity

Default to one quality worker per coherent scope, independent of that scope's
RED/GREEN author. It runs every applicable checklist cluster, reading targets and
context once. Schedule independent scopes concurrently in the shared stage queue.
Do not make one full-scope agent per cluster the default. A worker never nests a
fan-out. Keep shared helpers under one writer.

For a large scope, the coordinator may partition inspection by cohesive capability.
Each partition runs all applicable clusters. Assign one inspector the cross-partition
ownership, duplication, and interaction checks, with read access to the complete
scope. Gather all partition results before granting fixes. Cluster fan-out remains
available when it shortens the critical path and capacity can start the complete
roster together; record that choice. Never turn a cluster fan-out into successive
full-scope scans merely because only one slot is available: use a combined worker.

Refill free slots when jobs finish. Prefer ready jobs that unblock the next lane
phase; age waiting jobs to prevent starvation and preserve backend/frontend fairness.
Do not reserve idle slots for future phases or drain one lane before serving peers.
Capacity queues work; it never skips a gate. One available worker necessarily runs
jobs sequentially, but must not multiply them into separate checklist dispatches.

## Phase handoffs

After raw RED, start GREEN production work beside independent test quality work on
disjoint paths. Test quality runs `/test-review`, returns for coordinator publication
of reviewed tests, then receives an explicit `/refactor` dispatch. Reuse the same
quality worker when supported; otherwise pass its result references. Neither worker
may infer permission to run the next phase or commit. Do not wait for the production
candidate before test refactoring. Forward changed test expectations to its writer.

During concurrent production edits, verify test refactoring against stable frozen
contracts/stubs in an isolated test snapshot; preserve the expected raw RED failures
and passing harness checks. Do not accept a run against changing production files or
skipped tests as verification. Join reviewed/refactored tests with the returned
production candidate, enable, then run the complete focused suite. When review
execution is owed at the join, its gate stays pending while published tests enter RED refactoring;
that pending verification is not a dependency on starting test refactoring. Complete
the gate only after joined checks pass.

After joined tests pass, dispatch report-only coverage and read-only `/refactor`
inspection concurrently on the same stable candidate. Pin owned paths, dependency
context, test/build configuration, and report inputs; prevent writes to these inputs
while readers run. Isolate build/report outputs where concurrent runs would collide.
Peer lanes may keep working on disjoint inputs. If an input changes, invalidate the
affected result rather than accepting mixed revisions.

Join coverage and inspection. Apply admitted coverage follow-ups through the existing
TDD/review requirements, refresh affected coverage and inspection, and publish verified
behavior. Only then grant the refactor worker write ownership and resume it with the
retained findings. Inspection alone cannot complete `green-refactor`, even if empty:
validate revisions, resolve findings, run affected checks, then return a completed
result or evidenced `NO_CHANGE`. Publish refactoring separately. One fixer per writable
scope applies one change at a time; disjoint scopes may have concurrent fixers.

Design lanes preserve build/alignment/design-review prerequisites and final verify-only
alignment; the same coverage/inspection overlap applies once their joined tests pass.
Stage 1 uses the same review/publication/refactor handoff alongside contract design.

## Reuse and invalidation

Each mandatory GREEN refactor accounts for the complete production and test scope.
Inspect all new or changed production. Reuse individual completed RED test checks
only with the prior result, matching target revisions, and matching inputs relevant
to that check. Record referenced collaborators/contracts, helpers, configuration,
and sibling inventories where the check depends on them. Unknown context means
recheck. File hashes alone cannot validate relationship checks.

Always inspect final production/test interactions, capability boundaries, and
cross-file duplication against the completed implementation. Recheck changed tests,
helpers, new files, and checks affected by changed dependencies. Marker-only enables
and recorded behavior-preserving edits preserve assertion-review evidence, not an
automatic exemption from structural checks. Resolve overlaps between review and
refactor findings once and link the resolution from both results; a shared observation
satisfies both only if both check definitions and inputs were actually examined.

After fixes, rescan affected checks and interactions, not every unaffected lane.
Refresh coverage when executable code, tests, or measurement inputs change. Never
reuse percentages across source changes. Keep per-change refactor verification;
run the combined build at the stage join once on stable final inputs, rather than
once per lane. Standalone refactors retain their final build. A failing check blocks
completion under the existing failure rules.

## Evidence and measurement

Keep one versioned manifest per scope and one compact result per phase in `worklog/`.
Reference shared inventories, reports, and prior results; do not copy them into each
checkpoint. A result records skill/mode, worker reference, input/output revisions,
checks executed or reused with supporting references, findings/resolutions,
verification/report links, and publication commit or evidenced `NO_CHANGE`.
Enumeration data and B13 MOVE/KEEP evidence remain required; store each once and link
it from dependent checks. Explain failures and material decisions, not routine polls.

For each dispatched job record ready/start/finish timestamps, scope, phase, and wait
reason (capacity, prerequisite, input lock, or build-resource contention). Record
rescan scope and invalidating change. Derive gate wall time, summed worker duration,
and repeat scans from those records; distinguish these from tool/model compute time.
Use the same story baseline and obligations when comparing runs. Never claim a speedup
from fewer dispatches alone. Progress entries remain the blocking completion ledger,
not a second execution queue or duplicate report.
