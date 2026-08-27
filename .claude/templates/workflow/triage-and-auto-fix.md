# Triage & Auto-Fix

Read by `/continue`, in a **boundary** work unit, after the two review passes return (step 13).

`/continue` owns the predicate, concurrent pass roster, prompts, and partition directly.
This template is its executable decision contract.

**Triage SKIP/RUN predicate (before dispatching the passes).** From the boundary range's changed
paths (`git diff --name-only <range>`), SKIP both passes (no auto-fix; log the reason) iff
**every** path is under `ProductSpecification/` — progress, stories, spec artifacts, `tests/*.md`
case files. Everything else RUNs: any source file (production or test), any infrastructure file,
and every **workflow-governing prompt** under `.claude/**`. A broken edit to the dispatch
contract itself can never skip review. Deterministic, no
agent — and at boundary cadence it RUNs almost always, skipping only a genuinely inert boundary
(a fully-`[S]` scenario, the `## Spec` block).

**Four-way partition.** After the passes return, partition every finding by the fixability tag its
review agent set: **SAFE** → stage for auto-fix; **NEEDS_CYCLE** → run
`.claude/templates/workflow/finding-admission-test.md` over it first — admitted → follow-up plan
(proposed to the user, never auto-applied or inserted), failed → a Stage 3 disposition, never a step in the current
work item; **NEEDS_CLARIFICATION** → quiz
(below); **NO_FIX** → nothing at all, beyond its one line in the report. A PASS verdict can still
carry NO_FIX lines. A finding that is **untagged or carries an unrecognized tag
defaults to NEEDS_CYCLE** — the auto-fixer never touches what it cannot positively read as SAFE.
Collect SAFE findings as `{ source, file, line, problem, suggested_fix }`.

Only a finding carrying observed evidence and a citation to a requirement, acceptance criterion,
repository invariant, or already-landed test that pre-dated the review can pass admission. If either
link is absent, report the failed rule and disposition, then drop it from planning: never insert it
into `progress.md`. Record dispositions in the work log; an admitted block's compact provenance
marker remains as required by the admission test.

**Trivial user recovery.** Route a finding to `NO_FIX` instead of a follow-up when the failure is
immediately visible, its correction is obvious and local to the user, and it cannot cause hidden
data loss, corrupted state, a security breach, or a silently wrong result. Report why recovery is
safe; do not add a checkbox for it.

**Consent precedes plan mutation.** An admitted NEEDS_CYCLE finding is reported as
a proposed cycle. Do not add its test scenario or `progress.md` block until the user
explicitly agrees. Declining drops the proposal; silence is not consent.

**A consented NEEDS_CYCLE follow-up that becomes a scenario is classified immediately.**
Route it through `/design-preview` step 2a and apply
`.claude/guidelines/review-findings-detail.md` "Mid-cycle findings default to Tier 2".
Write a resolved marker, never `Tier: ?`; keep Tier 3 out of `progress.md`; write an
implemented scenario and its progress block together. Put
`<!-- review-origin: boundary -->` below the progress heading to limit review to one
generation. Untiered stories keep their existing behavior.

**Quiz (NEEDS_CLARIFICATION only) — last resort, gated.** Enforce "Consumer obligations" in
`.claude/templates/workflow/clarification-escalation-test.md`: **demote to NEEDS_CYCLE** any finding with
no recommended option or no one-plain-sentence question, batch the rest into **one** `AskUserQuestion` in
the boundary unit (after the passes, before `review-fix:`, never mid-batch), and read a declined quiz as
*you decide* — take each recommendation. Route each answer: behavior-preserving → SAFE stage;
production-behavior-change → NEEDS_CYCLE plan. **TDD guardrail:** the quiz resolves *which* fix, never
whether to bypass "no behavior change without a failing test first."

**Inline SAFE-only auto-fixer.** Apply the staged SAFE findings directly (no subagent — the orchestrator
already holds them) and run the affected tests. **If any go RED, discard that fix (it was mis-tagged) and
re-route the finding to a follow-up — a `review-fix:` commit never lands red.** Land a single trailing
`review-fix:` commit with the fixes that stayed green, **after** the quiz so directly-SAFE and
clarified-then-SAFE fixes share one commit. Commit order per boundary unit: behavior → `refactor:` →
`review-fix:` or `worklog:`. When no SAFE fix survives, commit the post-review log update alone as
`worklog:`; when triage SKIPped, no trailing commit is needed. Non-gating — discarding
an un-committed fix is not a revert; a landed commit is never reverted.

**Terminal review batch.** Consume this partition exactly once. Tests run for SAFE fixes may reject
or re-route a fix, but the trailing `review-fix:` or `worklog:` commit and anything observed while validating it are not a
new boundary and must not dispatch either review pass again. When a marked review-origin block later
closes, report `Review passes: SKIPPED (review-depth guard — review-origin block)` and finish its
ordinary work unit after `/refactor`.
