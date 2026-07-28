# Progress File Format

How a `progress.md` with no prior file is derived is in
[`bootstrapping.md`](bootstrapping.md); this file is the shape it is derived into.

## Story

Sections are **tier-major**: all of Tier 1, in category order, then the harvest
boundary, then all of Tier 2 in the same category order. Heading shape is
`## Tier N — {Category} Scenarios ({file})`, so one category file can produce a
section under each tier. Tier 3 never appears — it lives in `tests/tier3/` and is
never implemented (`.claude/templates/spec/tier-ladder.md`).

Tiering changes the *order* of scenarios, never their steps: each scenario runs the
same TDD cycle wherever its tier puts it.

A scenario heading is the test file's `### N.M Title` **verbatim** — not renumbered,
not relabelled `Scenario 1`. One category file feeds two tier sections, so
per-section renumbering would restart both at 1 and a `progress.md` heading would no
longer map to any test-file scenario; journey summaries and decision records key on
that exact string (`.claude/agents/tiering-agent.md`, "Moving between `tests/` and
`tier3/`"). The numbers within a tier's section are therefore sparse — the other
tier's scenarios are the gaps — and that is correct.

```markdown
# Story N: Story Title — Progress

## Spec
- [x] interview
- [x] story
- [x] mockups
- [x] api-spec
- [x] test-spec

## Tier 1 — Backend Scenarios (01_API_Tests.md)

### 1.1 A member opens a board they own
- [x] red-acceptance
- [~] design               <- MANDATORY for every scenario needing new implementation
- [ ] red-usecase
- [ ] green-usecase
- [ ] adapters-discovery
- [ ] green-acceptance

#### After adapters-discovery resolves (example):
- [x] adapters-discovery (storage, rest)
- [ ] red-adapter storage
- [ ] green-adapter storage
- [ ] red-adapter rest
- [ ] green-adapter rest
- [ ] green-acceptance

## Tier 1 — Frontend Scenarios (02_UI_Tests.md)

### 1.1 The board renders its columns
- [ ] red-selenium
- [ ] red-frontend
- [ ] green-frontend
- [ ] red-frontend-api
- [ ] green-frontend-api
- [ ] align-design
- [ ] green-selenium
- [ ] demo

## Harvest — Tier 1 → Tier 2

- [ ] harvest

## Tier 2 — Backend Scenarios (01_API_Tests.md)

### 1.4 A duplicate move request is rejected
- [ ] red-acceptance
- [ ] design
- [ ] red-usecase
- [ ] green-usecase
- [ ] adapters-discovery
- [ ] green-acceptance

## Tier 2 — Security Scenarios (05_Security_Tests.md)

### 2.1 A member cannot open another member's board
- [ ] red-acceptance
- [ ] design
- [ ] red-usecase
- [ ] green-usecase
- [ ] adapters-discovery
- [ ] green-acceptance
```

Integration (`06_Integration_Tests.md`), Load (`03_Load_Tests.md`) and
Infrastructure (`04_Infrastructure_Tests.md`) sections take the same six-step
backend shape, under whichever tier their scenarios landed in.

### The harvest boundary

One `- [ ] harvest` checkbox sits between the last Tier 1 section and the first
Tier 2 one, in its own `## Harvest — Tier 1 → Tier 2` section. It is a work-unit
checkbox, not a scenario: it carries no `### ` heading, so it never counts toward
the scenario totals in `stories.md`. What it dispatches is in
`.claude/skills/harvest/SKILL.md`.

A story with no Tier 2 scenarios still gets the boundary. Harvest's baseline check
is what confirms Tier 1 actually delivered the feature, and a story that skipped it
because nothing followed would be the one story where nobody checked.

### Untiered stories

A `progress.md` whose sections carry no `Tier N —` prefix is **untiered**: flat
category sections, no harvest checkbox, today's ordering. This shape stays valid
indefinitely — it is a permanent branch, not a transitional one. Stories specced
before tiering existed are never re-bootstrapped into the tier-major shape by
`/continue`; `/retier` is the only thing that converts one, and only while **no
checkbox below its `## Spec` section is `[x]`** (`.claude/skills/retier/SKILL.md`).
Reordering a story underneath its own in-flight work unit would strand it.

## Task (bug)

Bug tasks start with discovery, not pre-planned TDD steps. `steps-discovery` is a gate (analogous to `adapters-discovery` in stories) -- it expands in place into concrete TDD steps once the root cause is known. A `design` step (`/design-preview`) runs before `steps discovery` so the steps are planned against an approved fix approach. Prod-copy bugs prepend a `reproduce in prod-copy` step. When the gate resolves, its marker MUST record the hazard scan (`scanned all _index.md groups; GAPs: …`) — a bare `[x] steps discovery` is an unscanned gate (see "Hazard scan at steps discovery" in `.claude/guidelines/workflow-detail.md`).

```markdown
# Task N: Title — Progress

Type: bug

## Spec
- [x] spec

## Fix: Bug description
- [x] reproduce in prod-copy          <- only for prod-copy bugs
- [~] root cause analysis             <- CURRENT
- [ ] design                          <- /design-preview; [S] when fix approach is obvious
- [ ] steps discovery
```

After `steps discovery` resolves, `/continue` replaces it with concrete TDD steps for the affected layer(s), e.g.:

```markdown
## Fix: Bug description
- [x] reproduce in prod-copy
- [x] root cause analysis
- [x] design
- [x] steps discovery (scope: frontend logic + component; scanned all _index.md groups; GAPs: none fired)
- [~] red-frontend                    <- CURRENT
- [ ] green-frontend
- [ ] align-design
- [ ] demo
```

When the fix changes externally observable behavior (or tightens acceptance-level test infrastructure such as an external-service mock), discovery must also schedule a `red-acceptance` + `green-acceptance` pair (see "Acceptance red when application behavior changes" in `.claude/guidelines/workflow-detail.md`). All red steps land before the first green when one production fix resolves every red surface:

```markdown
## Fix: Bug description
- [x] root cause analysis
- [x] design
- [x] steps discovery (scope: adapter X production code + adapter-test stubs + acceptance mock; scanned all _index.md groups; GAPs: 1 folded → red-acceptance for outbound re-attempt idempotency)
- [~] red-adapter X                   <- CURRENT (tighten adapter-test stubs, predict failure)
- [ ] red-acceptance                  (tighten acceptance mock, predict failure in affected flows)
- [ ] green-adapter X                 (single production fix — resolves both red surfaces)
- [ ] green-acceptance                (verification only; no production or test changes)
```

## Task (refactoring)

```markdown
# Task N: Title — Progress

Type: refactoring

## Spec
- [x] spec

## Fix

### Step 1: Step description
- [~] red-adapter storage             <- CURRENT
- [ ] green-adapter storage

### Step 2: Step description
- [ ] refactor usecase
- [ ] refactor (cleanup)
- [ ] green-acceptance
```

## Blocks and boundaries

A **block** is the unit the commit-time review passes fire at the end of
(`.claude/skills/continue/SKILL.md`, "Boundary Review Passes"), and it is read straight off
the shapes above — no extra syntax, no marker. A block is a story scenario's `### N.M {Title}`
heading and its steps; a refactoring task's `### Step N: …` and its steps; a bug task's whole
`## Fix: …` section (its steps carry no `### ` heading); or a `## Spec` / `## Harvest — Tier 1
→ Tier 2` section. Slice one from its heading to the next heading of same or higher level.

A block is **closed** when that slice holds no `- [ ]` and no `- [~]` line — every step reads
`[x]` or `[S]` — and the work unit whose commit closes it is a **boundary**. The block's
**first commit** is the oldest commit whose `progress.md` already shows one of its steps
`[x]`/`[S]`; walking `git log --follow` over `progress.md` newest-to-oldest finds it, and
`{that commit}~1..HEAD` is everything the block cost — the range a boundary reviews. Nothing
in the file records any of this: it is recomputed from the checkboxes each time, so a plan
written before boundaries existed reads identically and no actor can leave a stale one behind.
