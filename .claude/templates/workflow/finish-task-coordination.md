# Finish-Task Coordination

Use this template only from `/finish-task`. It coordinates every remaining item in
any tracked task; it does not redefine the task type's internal execution, testing,
review, or human-observation sequence.

## Initial Scheduling Pass

1. Resolve `ProductSpecification/tasks/N-*/progress.md`, then `tasks/done/`, exactly
   as `/continue` does. Run the plan-integrity check before dispatching anything.
2. Read the task spec, progress, carryover, relevant decisions, and work-log records
   required by every currently reachable step. Inspect the affected acceptance,
   production, environment, or test surfaces that apply to its type.
3. Build a dependency graph for all remaining work units. Mark user decisions,
   discovery results, contracts, tests, generated artifacts, and shared writable
   files that unblock later work.
   For a QA task, record one serial `/qa-run` route and skip lane preparation.
4. Where parallel work is plausible, prepare the seam first: settle required design
   decisions, freeze interfaces and data shapes, declare disjoint writable-path
   manifests, record baseline blobs, and name the combined verification at the join.
   Do not dispatch a lane that still needs an unfrozen result from another lane.
5. Compare likely critical-path time saved with the cost of preparing the lane,
   transferring context, gaining traction, joining, reviewing, and re-running
   checks. Keep work in the parent when there is only one meaningful ready unit,
   the units are tiny, ownership overlaps, or delegation is unlikely to finish
   sooner.

Treat frontend and backend as separate candidates explicitly. They may run together
when the HTTP/event contract is frozen, their files and focused tests are disjoint,
and neither needs the other's uncommitted behavior. Otherwise finish or freeze the
contract-producing unit first and reassess.

## Lane Contract

Every delegated lane receives the maximum conversation history the platform can
provide plus a task-specific context packet containing:

- task identity, type, goal, current progress, and the exact work-unit intent;
- spec, approved design, relevant decisions, carryover, and required work-log facts;
- current-state acceptance tests and production files already inspected by the
  parent, including prior failed approaches or user corrections;
- frozen surfaces, owned writable paths with baselines, forbidden paths, dependencies,
  required checks, completion evidence, and the join condition.

A summary alone is not sufficient context. Use the platform's maximum-history
delegation. A worker never edits `progress.md` or the coordinator's work-log,
stages files, commits, archives the task, or expands its ownership. It stops with
evidence when it discovers an ownership collision or an invalid frozen surface.

The parent reviews every returned diff and re-runs the joined checks. Worker
self-assessment is not evidence. Reject undeclared paths, changed frozen surfaces,
missing required phases, and results that depend on another lane's uncommitted
output.

## Publication and Progress

Implementation may overlap; publication is serialized by the parent. Publish only
after the owning lane's complete task-type sequence and checks succeed. Stage
explicit owned paths, preserve its required commits and records, and advance
`progress.md` in its defined order. Never run several autonomous task coordinators
against one task or let parallel workers race the task cursor.

If two progress units are independent but their commits must appear in plan order,
workers may prepare both concurrently. The parent validates and publishes them one
at a time, rechecking the later result against the new `HEAD` before advancing it.
A result invalidated by an earlier publication is revised or rerun, never recorded
as complete from its old baseline.

## Five-Minute Readiness Monitor

Start exactly one recurrent wake-up after the initial scheduling pass and keep it
active while the task is running. Every five minutes it prompts the parent to inspect
the live agent roster, the committed task cursor, completed lane results, newly
frozen surfaces, available capacity, and the remaining dependency graph. Dispatch
newly ready work only when it passes the same independence and speedup tests.

The timer is a backstop, not a dispatch delay: reassess immediately whenever a lane
joins or a work unit commits. A tick does not create work, duplicate an active lane,
or relax TDD order. Load the platform procedure referenced by `/finish-task` and use
its required context-delivering mechanism; never substitute a detached timer.

Cancel the Monitor or terminate the Codex cell when the task completes, a required
user decision pauses execution, or a sub-skill failure stops the workflow. Before
starting or resuming, reuse an already-active monitor for this invocation instead of
creating another.

## Task-Type Routing

- **Bug and refactoring:** execute `/continue task N` semantics for each work unit
  through its last owed commit. Preserve all discovery, TDD, approval, refactor,
  coverage, boundary-review, and work-log requirements.
- **QA:** execute `/qa-run task N` as the owning workflow and continue through every
  remaining case while the tester keeps the watched session active. Preserve its
  one-action-at-a-time browser interaction, screenshots, acknowledgements, verdict
  rules, bug filing, and commit behavior. The entire QA route is serial: do not
  dispatch parallel agents for cases, setup, observation, diagnosis, or supporting
  work. Monitor ticks may report that no parallel work is eligible, but cannot
  dispatch anything while the QA task is active.
- **Any other or future type:** use the workflow named by its task definition. When
  none exists, execute each checkbox with `/continue`'s direct inline fallback.
  Never reject a tracked task merely because its type is unfamiliar.

## Completion Loop

Execute the task-type route for the next item through its last owed commit or verdict.
On success, retain its required report facts, skip only the owning workflow's normal
intermediate stop, re-run plan integrity, refresh the dependency graph, and execute
the next item or ready parallel batch. Do not skip any route-specific approval,
review, test, observation, evidence, or record to keep the outer loop moving.

When a genuine user decision is required, ask it within the active `/finish-task`
workflow and resume the same coordinator after the answer; do not ask the user to
invoke another task-execution skill. On a sub-skill failure or a QA case requiring
tester acknowledgement, preserve the current item and follow its owning workflow.

Completion requires zero `[ ]` and `[~]` checkboxes, a staged completion check, the
task folder moved to `ProductSpecification/tasks/done/`, and all required commits
present. Then stop the recurrent wake-up and emit one aggregate report covering
every completed item and every report field required by its owning workflow,
including checks, verdicts, findings, commits, and the archived task location.
