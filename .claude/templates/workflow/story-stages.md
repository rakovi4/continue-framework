# Whole-Story Execution

After the reviewed specification, one `/continue` invocation runs all remaining
Tier 1 and Tier 2 work in three passes over the existing scenario plan. Tier 3 stays
deferred. Tasks and specification items retain their single-work-unit routes.

## Existing plans and dispatch

Keep scenario headings, checkboxes, tier classifications, progress format, and
`stories.md` calculations. Do not migrate plans or add global stage checkboxes.
An untiered story keeps its full existing implementation scope.

Validate the plan normally, then map every eligible `(category file, scenario
heading)` to its existing checkboxes and executable cases in the invocation work log.
Check that every Then clause is covered. Load relevant summaries and decisions for
this whole scope. Preserve proven completed work on resume; missing evidence is not
proof of completion. Use bounded work-log parts when needed under the existing format.

Select work by the earliest incomplete pass below, across all scenarios, rather
than finishing one scenario's pipeline first. Existing staged checkboxes map directly;
for legacy serial plans, acceptance RED, design, and adapter discovery belong to
Stage 1; implementation RED/GREEN and alignment to Stage 2; acceptance GREEN and demo
to Stage 3. Map required additional steps to their owning pass before dispatch;
unmapped obligations block execution rather than disappearing from the plan.

Mark individual checkboxes complete only when their obligations are satisfied. Keep
`[~]` on the first unfinished checkbox in physical file order and all later unfinished
entries `[ ]`, preserving plan-integrity check 3. The stage pass determines which
pending entry is eligible to execute; the physical cursor need not be that entry.
Report the active pass in progress updates and record its evidence in the work log.

Reuse `parallel-backend-stages.md`, `parallel-frontend-stages.md`, and the `/continue`
dispatch table for lane mechanics and mandatory review, coverage, refactor, and checks.
For story execution this coordinator supersedes their per-scenario stop/approval
boundaries, non-interactive design, worker publication, and immediate demo timing.
The coordinator owns tracking, staging, and commits; workers edit disjoint declared
paths. Coalesce overlapping work, including shared test helpers, before dispatch.

## Stage 1 — All acceptance RED and interactive contract design

Dispatch acceptance writers for every remaining scenario in both tiers and every
applicable category, including browser tests. While they work, interview the user
about material design decisions for the whole story: present concrete alternatives
and consequences, reuse settled decisions, and await answers without blocking
independent RED work. Design workers return questions to the coordinator. Never
infer user agreement from silence or implement a choice awaiting an answer.

Run and review every acceptance case; record predicted and observed failures.
Existing production code does not justify omitting a black-box test. Reuse valid
existing coverage and report already-green cases with evidence. A harness failure
or unavailable service does not count as an expected behavior failure.

In parallel, discover all required adapters and prepare the cross-layer contracts
and skeletons using the existing design templates. Before creating skeletons, choose
their paths under the File Organization rules in `.claude/rules/coding-rules.md`
and include those paths in the lane ownership plan. Reconcile backend/frontend seams
and group the Stage 2 lane plan by architectural boundary across scenarios. Require
complete disjoint ownership and independently testable frozen seams. Stage 1 may
create contracts and skeletons, but must not implement story behavior.

Join the acceptance and design results for the entire scope. Show the consolidated
contracts and lane plan during the interview and resolve outstanding decisions.
Record the user's agreement and frozen contract revision. Satisfy existing design
and contract-approval checkboxes with this joined agreement; do not ask separately
for every scenario or require another `/continue` invocation.

Perform the existing harvest baseline analysis for already-green Tier 2 cases during
this pass, using the pre-story revision and isolated test environment. Retain valid
RED tests for Stage 2 and meaningful already-green tests for final verification.
Do not dispatch a second harvest test-writing pass: mark the existing `harvest`
checkbox `[S]` with a compact work-log pointer once its baseline obligations are
covered here, explaining the replacement in the log. Empty Tier 2 has no cases to
baseline. Never use an already-green result to skip final acceptance verification.

Stage 2 cannot begin until every scenario has reviewed RED or verified already-green
evidence, all material design questions are answered, contracts are frozen, and lane
ownership is complete. Commit the results and finish owed refactoring, then continue.

## Stage 2 — All implementation

Run the complete use-case, adapter, frontend-logic, API-client, and design-alignment
lanes for both tiers against the frozen contracts. Load `stage-2-quality-gates.md`
and dispatch its mandatory test-review, coverage, and refactor phases for each lane.
Reconcile every changed module, production file, test, and helper against the named
checkpoint evidence before completion, including legacy serial routes. Independent
lanes may run concurrently within available capacity; shared boundaries stay under
one owner. Workers never change frozen contracts.

Update the corresponding scenario implementation checkboxes as lanes finish. Do not
advance to Stage 3 until every required implementation lane, follow-up check, and
refactor is complete and committed. Then continue immediately in the same invocation.

## Stage 3 — All acceptance GREEN, then sequential demos

Enable the story's acceptance targets with marker-only edits, verify every case in
both tiers and all applicable categories, and run affected regression checks. This
phase changes neither production code nor test assertions. Include already-green
and previously completed targets in final verification of the joined implementation.

After all acceptance checks pass, run every applicable demo through `/demo`, one at
a time in plan order. Await each result and continue without asking between demos.
Keep combined acceptance-GREEN-plus-demo checkboxes incomplete until their demos
pass; record intermediate GREEN evidence in the log. Scenarios without browser
flows need their acceptance evidence, not invented browser demos.

Finish the existing progress and archive procedure only after every required case,
demo, and remaining obligation is complete. Keep the existing metrics formula.

## Failure and resume

Do not stop after a scenario, lane, commit, tier, or pass. Stop only for completion,
a failed required check, a genuine missing prerequisite/decision, or a user pause.
On failure, keep the affected checkbox incomplete and preserve successful work.
A contract defect reopens the affected design steps and invalidates dependent work;
an implementation defect reopens its lane; a demo failure leaves its demo pending.
Verification reports defects and never repairs production code itself.

On resume, validate retained contracts and lane checkpoints against current files
and commits before reusing evidence. Select the earliest incomplete pass and run
all remaining passes; do not migrate or blindly restart finished work. Changed inputs
invalidate dependent checks and demos. Record durable failure/resume evidence in the
work log. Emit the existing final report once, with suite counts and each demo outcome.
