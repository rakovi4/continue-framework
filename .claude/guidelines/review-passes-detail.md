# Boundary Review Passes — Detail

Deferred companion to `.claude/rules/workflow.md` and `.claude/guidelines/workflow-detail.md`.
It holds the *why* of the two commit-time review passes, the boundary cadence they run at,
the triage predicate that may skip them, the three-way partition of their findings, and the
tier a mid-cycle finding's scenario defaults to. `/continue` owns the mechanics. Read it
before running or triaging a review pass.

Every **completed block** — a story scenario in any sequence (backend, frontend,
integration, security, load, infra), a task step, a bug task's whole fix — is
followed by two **fresh-context** review passes that differ *in kind* from the
in-loop `/test-review` and `/refactor`. Those read the work as it is built and
within the author's framing; these read the finished diff cold:

- `agent-review-agent` — surfaces any problem the diff *contains*, deliberately
  unnarrowed (not bound to a checklist).
- `premortem-agent` — assumes the work shipped and caused an incident, then works
  back to the *missing* guard.

They are independent reads of the same diff, so they run **concurrently with each other
and in the same batch as `/refactor`** — overlapping it rather than adding a serial tail
to the unit. The boundary unit's behavior commit lands first; the passes read the
block's **immutable committed range** while `/refactor` mutates the tree toward a
separate refactor commit, so there is no read/write race. The cost is that they do not
see `/refactor`'s behavior-preserving delta, which its own green test run already gates.

They run **before the refactor commit** but are **not a gate**: a CONCERNS or BLOCK
verdict surfaces as a follow-up and never blocks, reverts, or amends either commit — the
work always lands. This layer exists so a defect that every same-kind gate read past still
meets one reader who did not — the gap that defense-in-depth-by-kind closes. Overlapping
them with `/refactor` is a pure latency win and costs no fidelity: both passes read at the
behavior/correctness altitude, and `/refactor` preserves behavior, so a cold read of the
range is identical whether it lands a second before or a second after the refactor
commit — we take the second that overlaps `/refactor`.

**The cadence is one pass per block, not one per work unit.** These two passes are the
heaviest single cost in the loop — about 28% of a gated backend scenario's agent-work,
more than every code-writing phase combined — and they used to charge it on *every*
commit. A scenario is six to ten work units, so it was read cold six to ten times, each
read spending the user twice: on the pass's own latency, and on decoding its findings
and working the follow-up steps they generate. Multiplied by every unit, the review
layer cost more than the work it reviewed. So the passes now fire **once, at the moment
a block closes** — a story scenario, a task step, a bug task's whole fix — over every
commit of that block at once.

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

## Mid-cycle findings default to Tier 2

A `NEEDS_CYCLE` follow-up that is acted on as a **net-new scenario** enters a story
whose scenarios were already sorted by consequence of failure at spec time.
`tiering-agent` runs once, at `/test-spec`, so nothing tiers a scenario born after
it, and the sorted set carries no default for a newcomer. Left undefined, the
newcomer lands where the work is happening — in Tier 1 — and Tier 1 re-bloats
mid-flight as far as review findings accumulate: the split undone by the loop that
runs after it.

So the default is **Tier 2**, and resolved — never `Tier: ?`. That form means
"drafted, awaiting the comparative pass" (`.claude/templates/spec/tier-ladder.md`,
"The marker"), and `tiering-agent` runs at spec time only; the sole thing that
re-dispatches it is `/retier`, over a story still at 0%. Tier 2 is *usually* what the
finding's own content argues for, too: a review pass reads a commit whose tests are
green, so what it typically reports is not "the feature does not work at all" (Tier 1)
but "the product is unsafe or incorrect under conditions that will occur in
production" — Tier 2's definition, verbatim.

**Usually, not always — so re-read the ladder rather than trusting the default.**
Green tests prove only that the *written* scenarios pass. A deliberately unnarrowed
cold read finds the feature broken for cases nobody wrote: a wrong response field, a
500 on a legitimate input. Every **BLOCK** verdict is of this kind by definition —
data loss, double effect, leak, corruption, a broken core invariant. Those are
`tier-ladder.md`'s Tier 1 sentence verbatim: the feature does not work for its primary
user. Such a finding is **Tier 1**, and putting it there is the expected outcome, not a
deviation that owes an argument — the point of tiering is that Tier 1 is built first,
so a scenario discovered *during* Tier 1 to belong in Tier 1 simply joins it, with its
steps in the Tier 1 section where they will be worked now. Deferring a corruption
finding behind the whole of Tier 2 would also lean on the wrong tie-break: "a wrong
1-vs-2 call self-corrects the moment someone demos the feature" holds for a broken
button and not for silent data loss, which no demo surfaces.

**The default is the guard here, because the floor cannot be.** The pinned floor
reads a provenance token, and a review-pass finding has no route to stamp: the
passes are deliberately open-ended rather than a closed catalogue, which is exactly
what makes them complementary to the hazard scan. A token reaches such a scenario
only if the mid-cycle scan at `/design-preview` step 2a fires a group over it — and
that scan is also where the scenario gets written with its marker (see "Net-New
Scenarios Introduced Mid-Cycle" in `.claude/guidelines/workflow-detail.md`). So a
mis-tier here is not mechanically catchable the way a spec-time one is, and a default
that already sits above Tier 3 is what stands in for the check.

Both deviations therefore need a stated reason, and they are not symmetric — the
same asymmetry the ladder's tie-breaks rest on. Promoting to Tier 1 costs ordering
and self-corrects the moment someone demos the feature. Demoting to `tier3/` means
the guard is never built, so it needs the positive judgment the ladder requires
(name the degradation, say why it is acceptable) and is forbidden outright when the
mid-cycle scan stamped a floor-pinned token.

**A marker alone changes no ordering, and the writer is deliberately unnamed.** The
tier lives in the test file, but `/continue` never re-derives an existing
`progress.md`, so a scenario whose marker says Tier 2 and whose steps nobody added is
a scenario that will never be built — the failure mode this rule exists to prevent,
reintroduced one layer down. The steps therefore go into the matching section of the
scenario's own tier, at the end, in the same `review-fix:` commit as the test file.
Boundary cadence is what makes that unconditional: the passes fire only when the block
they read has closed, so there is no in-flight cycle for a block placed above the cursor
to abandon — the deferral the old per-unit cadence needed is gone, and with it the
marker-without-steps window it opened. Which actor writes them is *not* fixed, because
`progress.md` already has many writers and naming one more does not stop the others;
instead every resume runs the plan-integrity check
(`.claude/templates/workflow/plan-integrity-check.md`), whose marker↔plan agreement check
is what actually catches a scenario left in the test files with no steps.

**A finding can land after its item was flipped to Done — and now usually does.** The
`done/` move and the Done-table row-move ride the *behavior* commit, and the passes run
after it, so on a work item's final unit a finding may need steps in a plan already
declared complete — in a folder `/continue`'s resolver no longer matches. That final unit
is always a boundary, so this is no longer the rare case it was under per-unit cadence: a
bug task, whose entire fix is one block, meets it on the only pass it ever runs. Then the
`review-fix:` commit that lands the steps also reopens the item: the item comes back out of
`done/` — for a story its **Done**-table row returns to **In Progress** in the same commit as
the folder, both halves of the completion fact reversing together — and the newcomer's first
step becomes the plan's only `[~]`. Reopening is honest about what happened; leaving the steps in a
done-flipped plan makes them unreachable, which is how a surfaced finding turns into a
silently dropped one.

Scope: a tier-major story. An untiered story has no tiers to default into and keeps
today's behaviour — the permanent branch, not a transitional one.
