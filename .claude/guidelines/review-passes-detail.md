# Boundary Review Passes — Detail

Deferred companion to `.claude/rules/workflow.md` and `.claude/guidelines/workflow-detail.md`.
It holds the *why* of the two commit-time review passes, the boundary cadence they run at,
the triage predicate that may skip them, the three-way partition of their findings, and the
tier a mid-cycle finding's scenario defaults to. `/continue` owns the mechanics. Read it
before running or triaging a review pass.

Every completed story scenario, spec section, or harvest step—and every completed
task—is followed by two **fresh-context** review passes that differ *in kind* from the
in-loop `/test-review` and `/refactor`. Those read the work as it is built and
within the author's framing; these read the finished diff cold:

- `agent-review-agent` — surfaces any problem the diff *contains*, deliberately
  unnarrowed (not bound to a checklist).
- `premortem-agent` — assumes the work shipped and caused an incident, then works
  back to the *missing* guard.

They are independent reads of the same diff, so they run **concurrently with each
other**. At a story boundary they may also overlap an owed `/refactor`; a task waits
until all work joins, then reviews its immutable whole-task range.

At story boundaries they run **before the refactor commit**. In both cadences they
are **not a gate**: a CONCERNS or BLOCK
verdict surfaces as a follow-up and never blocks, reverts, or amends either commit — the
work always lands. This layer exists so a defect that every same-kind gate read past still
meets one reader who did not — the gap that defense-in-depth-by-kind closes. Overlapping
them with `/refactor` is a pure latency win and costs no fidelity: both passes read at the
behavior/correctness altitude, and `/refactor` preserves behavior, so a cold read of the
range is identical whether it lands a second before or a second after the refactor
commit — we take the second that overlaps `/refactor`.

**Stories review once per block; tasks review once in total.** These two passes are the
heaviest single cost in the loop — about 28% of a gated backend scenario's agent-work,
more than every code-writing phase combined — and they used to charge it on *every*
commit. A scenario is six to ten work units, so it was read cold six to ten times, each
read spending the user twice: on the pass's own latency, and on decoding its findings
and working the follow-up steps they generate. Multiplied by every unit, the review
layer cost more than the work it reviewed. So stories review when a block closes,
while tasks wait until all planned work joins and review the whole task once.

**The wider diff is the better read, not merely the cheaper one.** A per-unit pass
sees one slice of a scenario: a red test with no implementation, or an implementation
with the acceptance test still disabled. Half of what it could say is unanswerable
from inside that slice — whether the test guards the behavior, whether the adapter
honours the contract the usecase declared, whether the error path was ever wired up.
It compensates by reporting what it *can* see, which is how one shallow finding
surfaced in three consecutive units. A completed scenario is the smallest diff at
which the questions these passes exist to ask are answerable at all.

**The residual cost is detection latency, and it is real.** A defect introduced in a
scenario's first work unit is now found at the end of the scenario, with the rest of
it already built on top. That is the trade: the fix is bigger when it lands. It is
acceptable because the passes were never the first line — `/test-review` and
`/refactor` still gate every unit, and they are the gates that block — and because a
finding that fires against the whole scenario names the right fix, where the per-unit
version named a symptom that had already moved.

**Triage now only skips genuinely inert boundaries.** The predicate survives,
re-scoped to the boundary range's changed paths, but its job has shrunk: a completed
scenario nearly always touches code, so at this cadence it RUNs almost every time.
What it still catches is the boundary with nothing to read — a scenario every step of
which was `[S]`, a `## Spec` block, a step that only moved progress. So it is one
clause instead of a five-trigger list: SKIP only when every changed path is a
specification artifact under `ProductSpecification/`. The old triggers are implied,
not dropped — storage, auth, money and concurrency changes are all source files, and
any source file, infrastructure file, or **workflow-governing doc** under `.claude/**`
(a broken edit to the dispatch loop is itself high-consequence) is already a RUN.

**The auto-fix closes findings instead of surfacing-and-forgetting them.** A
CONCERNS/BLOCK finding used to become a follow-up that no one acted on. Now each
review agent tags every finding with a fixability class, and `/continue` partitions
them three ways. **SAFE** (behavior-preserving — a doc/comment fix, a dead-code
removal, a test/spec assertion, a rename that updates every reference) is applied
inline and committed. **NEEDS_CYCLE** (the fix would change production behavior)
stays a follow-up, untouched — auto-fixing it would violate "no production behavior
change without a failing test first," so the auto-fixer never promotes it.
**NEEDS_CLARIFICATION** (the concern is real but the fix direction is a judgment
call) becomes an answered decision rather than a dropped follow-up: in the boundary
unit `/continue` asks the user once, and the answer routes the finding to SAFE
(apply) or NEEDS_CYCLE (plan) — the quiz picks *which* fix, never whether to bypass
TDD. Boundary cadence lowers the quiz's frequency by the same factor as the passes'.
**NO_FIX** records a problem the pass intentionally will not route to either fixing path;
it is reported with its disposition and does not expand the current work.

An admitted NEEDS_CYCLE is only a proposal until the user explicitly agrees. The
review batch may name and recommend the cycle, but it cannot add scenario or progress
steps on silence or by default. Consent turns the proposal into the mid-cycle
scenario described below.

Staged backend and frontend Stage 3 are the explicit range exception: review runs beside
acceptance GREEN over immutable Stage 1+2; Stage 1 reviewed test content and Stage 3
execution guards the delta. The coordinator joins once, applies SAFE fixes afterward,
and then closes the scenario. An admitted cycle is stored only as a decision checkpoint until
the user explicitly agrees; silence cannot mutate the plan.

**A finding does not enlarge the reviewed work merely because it is real.** Expansion
requires observed evidence that the work violates a requirement, acceptance criterion,
repository invariant, or test that pre-dated the finding. Importance is assessed
separately: a serious defect outside that promise is escalated as a release concern, an
unrelated lower-consequence defect is preserved as a named follow-up, and an unproven risk
gets one bounded reproduction attempt. This keeps the finish line open to contrary evidence
without letting each review invent a broader promise for the work it reviewed. The complete
gate and disposition table live in `finding-admission-test.md`.

**Do not plan work the user can trivially recover themselves.** A finding stays `NO_FIX`
when its failure is immediately visible to the user, the correction is obvious and local,
and it risks no hidden data loss, corrupted state, security boundary, or silently wrong
result. Report it once, but do not turn ordinary user recovery into implementation work.
Review follow-ups are for guards the system must own, not every detectable inconvenience.

**Escalation is the last resort, and the bar is deliberately high.** A quiz is not
the neutral, safe choice it looks like from inside a review pass. It halts a work
unit and spends the user's attention twice: once decoding a question written in the
diff's vocabulary rather than the product's, and again discovering the answer was
derivable from a rule file all along. That second cost is the corrosive one — it
teaches the user that the pause is usually not worth reading, which is how a genuine
escalation later gets waved through. So a review pass that can name the better
direction is required to name it and own the decision in its report, and the
`NEEDS_CLARIFICATION` tag is reserved for a choice that turns on product intent, a
business rule, or a priority the repo records nowhere. The three checks that
implement this — not derivable, no better option, statable in one plain sentence —
are in `.claude/templates/workflow/clarification-escalation-test.md`, which both
agents and `/continue` read; that file also carries the consumer's obligation to
demote an ill-formed finding rather than ask about it, and the reading of two passes
converging on one contradiction.

**The auto-fix stays non-gating and separately reviewable.** The SAFE fixes land in
their own trailing `review-fix:` commit, on top of the behavior and refactor
commits, so they are distinguishable from and reviewable independently of the work
they correct. A SAFE tag is fallible, so the auto-fixer runs the affected tests
after applying and discards any fix that goes red — re-routing it to a follow-up —
so a `review-fix:` commit never lands red, and dropping an un-committed change is
not a revert. The passes and their auto-fix stay non-gating throughout: the
behavior and refactor commits land regardless of verdict, and the only two gates
that block a commit remain `/test-review` and `/refactor`.

`/continue` owns the dispatch mechanics — detecting the boundary off the staged
`progress.md`, deriving the boundary range, the surface-don't-block handling, the
triage SKIP/RUN predicate, the three-way partition, the quiz, and the inline
SAFE-only auto-fixer — in its "Boundary Review Passes", "Triage & Auto-Fix", and
"Sub-Skill Dispatch" sections. This file holds the *why*; it does not restate the
mechanics.

## Why mid-cycle findings need a resolved tier

A `NEEDS_CYCLE` follow-up that is acted on as a **net-new scenario** enters a story
whose scenarios were already sorted by consequence of failure at spec time.
`tiering-agent` runs once, at `/test-spec`, so nothing tiers a scenario born after
it, and the sorted set carries no default for a newcomer. Left undefined, the
newcomer can land where the work is happening — in Tier 1 — and re-bloat the happy
path with work that was not part of the story's primary promise.

Tiering ran before this scenario existed, so its marker must be resolved at admission,
never left as `Tier: ?`. The default, exceptions, and placement mechanics live in
`.claude/guidelines/review-findings-detail.md`; do not duplicate them here.

Placement, plan-integrity, reopening, and untiered-story mechanics live in
`.claude/guidelines/review-findings-detail.md`.
