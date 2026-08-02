---
name: harvest
description: Batch the Tier 2 acceptance scenarios that are already green at the Tier 1 → Tier 2 boundary — run every remaining Tier 2 acceptance scenario through red-agent concurrently, then baseline the green ones against the pre-story build. Use when /continue reaches a `- [ ] harvest` checkbox, or the user mentions /harvest.
---

# /harvest — Tier 1 → Tier 2 Boundary Batch

Dispatched by `/continue` from the `- [ ] harvest` checkbox that sits between the
last Tier 1 section and the first Tier 2 one in a tier-major `progress.md`
(`.claude/templates/workflow/progress-format.md`). Untiered stories have no such
checkbox and never reach this skill.

**Why a skill, not an inline `/continue` phase.** Harvest fans out concurrent
`red-agent`s, then stops the backend and boots a second build of the application to
baseline the result — far past what an inline gate like `adapters-discovery` does.
**Run it inline in the main agent** (like `green-acceptance` and the `story` spec
item): it dispatches its own sub-agents, which must not nest inside a wrapper agent.

**What it buys.** Many Tier 2 scenarios already pass the moment Tier 1 is green.
Discovering that one `red-acceptance` work unit at a time pays a full unit each. One
batch step runs them all at once.

**Scope: acceptance level only.** Only black-box-over-HTTP acceptance tests can be
pointed at a differently-built application; usecase and adapter tests compile against
production classes and cannot be baselined (`CLAUDE.md`). Harvest touches
`acceptance/` test code and `progress.md` — never production code.

## The batch

1. Read `tests/*.md` and collect every scenario carrying an inline `Tier: 2` marker
   (`grep -F 'Tier: 2'` per file, per `.claude/templates/spec/tier-ladder.md`) whose
   acceptance step is not yet done. These are the harvest set.
2. Fan out **one `red-agent` per scenario, concurrently** (dispatch them in a single
   message — layer `acceptance`, given the scenario name and story folder). Each runs
   its **normal** red-acceptance workflow — no harvest-special writer mode.
3. `red-agent` self-partitions per its own rules:
   - **Green as-is** (the test passes the moment it is written): red-agent marks the
     scenario's `red-acceptance` `[x]` and every other step for that scenario `[S]` —
     its standard "test already passes" branch. The scenario is resolved.
   - **Red**: red-agent produces the normal disabled `red-acceptance` deliverable and
     the scenario continues its ordinary Tier 2 cycle later. Nothing is deleted — the
     red test *is* the start of that cycle.

Read the build/run/test commands from `ProductSpecification/technology.md`; never
hardcode them here.

## The earned-red baseline check (green scenarios only)

**Greenness alone does not establish that a test can fail.** A strict assertion
against the wrong endpoint is green forever, and red-agent never observes a red for
the green-as-is tests — it skips straight to done. Recover the red→green transition
for the whole green batch with one check:

Run the **green tests** against the application **built from the commit before this
story began** (every story has a clear starting point in the history — use the last
commit before its first implementation commit), using the **current** test code.

- Stop the backend (`/stop-backend` — the port-based script), then build and boot the
  baseline commit's backend on the **configured port from `infrastructure/.env`**. That
  port corresponds to this repo's directory index, so it never contends with another
  session; within this session, stop-then-start reuses it cleanly.
- Point the **current** acceptance tests at that running app over HTTP. (Checking the
  old commit out and running the tests *there* would fail to compile — they need the
  DSL and Statements built during Tier 1 — which is why the current tests run against
  the old *running* app instead.) Build and boot are long: start each as a persistent,
  pollable command and use ≤30s polls per the interaction rule.
- **Teardown is mandatory on every exit path.** On success, failure, or abort: stop
  the baseline app (kill only the PID you started) and restore the normal backend
  before reporting. Never leave the baseline build running on the port.

Read each green test's baseline result:

| At baseline | Now | Verdict |
|---|---|---|
| RED, or 404 (endpoint genuinely absent) | GREEN | **Earned.** The transition was observed for the batch at one build's cost. Keep the `[S]` resolution. |
| GREEN | GREEN | **Not covering Tier 1 work.** Either something pre-existing implements it — legitimate: keep `[S]` but *name what implements it* — or the assertion is inert: delete the test and let the scenario take its normal cycle. |

If the baseline app fails to boot or the whole batch errors (backend unreachable, not
assertion failures), **do not score** — abort, restore, and report. An errored batch
run is not evidence a test is inert.

## Empty Tier 2

A story with no Tier 2 scenarios still runs harvest — the boundary is not skipped
(`progress-format.md`). The batch has nothing to run, but the baseline check still
runs against the **Tier 1** acceptance suite: it is the one check that confirms Tier 1
actually delivered the feature, and the story with nothing following is precisely the
one where skipping it means nobody ever checked.

## Commit

One behavior commit: any kept/deleted test changes, `[S]` marks (each naming what
implements it), and the `progress.md` advance (`- [x] harvest`, next Tier 2 step to
`[~]`). Task/story prefix as usual. `/continue` then owns the `/refactor` batch and
triage. `## Harvest — Tier 1 → Tier 2` is a one-checkbox block, so ticking it always
closes the block: harvest is a **boundary**, and its `acceptance/**` diff is source, so
triage RUNs the review passes over it. That is deliberate — the batch deletes tests it
judged inert and resolves whole scenarios to `[S]`, which is exactly the kind of call a
cold read should see once.

The cost is one backend build and boot, amortized across the entire Tier 2 batch.

## Agent logging

The `red-agent`s log per `.claude/guidelines/agent-logging.md` (red-agent rows).
Harvest itself emits batch milestones under the `harvest` slot: `START` (batch size),
`RUN` (green/red split), `PASS`/`SKIP` per baseline verdict, `DONE` (kept, `[S]`,
deleted counts). See the `harvest` row in that file.
