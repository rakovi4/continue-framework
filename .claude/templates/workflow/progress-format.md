# Progress File Format

How a `progress.md` with no prior file is derived is in
[`bootstrapping.md`](bootstrapping.md); this file is the shape it is derived into.
The file is a structural plan: headings, status checkboxes, and compact control
tokens only. Each checkbox is one physical line and at most 200 characters. Routine
execution evidence belongs in [`worklog-format.md`](worklog-format.md).

## Story

Sections are **tier-major**: all of Tier 1, in category order, then the harvest
boundary, then all of Tier 2 in the same category order. Heading shape is
`## Tier N — {Category} Scenarios ({file})`, so one category file can produce a
section under each tier. Tier 3 never appears — it lives in `tests/tier3/` and is
never implemented (`.claude/templates/spec/tier-ladder.md`).

Tiering changes the *order* of scenarios, never their steps: each new scenario uses
the same three-stage backend-style or frontend sequence wherever its tier puts it.

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
- [~] stage-1 acceptance RED + contract design
- [ ] approve stage-1 contracts
- [ ] stage-2 implementation lanes
- [ ] stage-3 acceptance GREEN

## Tier 1 — Frontend Scenarios (02_UI_Tests.md)

### 1.1 The board renders its columns
- [ ] stage-1 frontend acceptance RED + interface design
- [ ] stage-2 frontend implementation lanes
- [ ] stage-3 frontend acceptance GREEN + demo

## Harvest — Tier 1 → Tier 2

- [ ] harvest

## Tier 2 — Backend Scenarios (01_API_Tests.md)

### 1.4 A duplicate move request is rejected
- [ ] stage-1 acceptance RED + contract design
- [ ] approve stage-1 contracts
- [ ] stage-2 implementation lanes
- [ ] stage-3 acceptance GREEN

## Tier 2 — Security Scenarios (05_Security_Tests.md)

### 2.1 A member cannot open another member's board
- [ ] stage-1 acceptance RED + contract design
- [ ] approve stage-1 contracts
- [ ] stage-2 implementation lanes
- [ ] stage-3 acceptance GREEN
```

Integration (`06_Integration_Tests.md`), Load (`03_Load_Tests.md`) and
Infrastructure (`04_Infrastructure_Tests.md`) sections take the same staged backend
shape, under whichever tier their scenarios landed in.

Frontend sections use the staged frontend shape shown above. Stage 1 freezes shared
interfaces, Stage 2 joins disjoint shared-worktree lanes, and Stage 3 owns final
Selenium verification and demo. Frontend scenarios whose
legacy `red-selenium` through `demo` sequence already started keep that shape; never
replace checkboxes underneath an active cursor.

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

## Task (behavior-change)
```markdown
# Task N: Title — Progress

Type: behavior-change

## Spec
- [x] spec
- [~] design
- [ ] steps discovery

## Change
```

After the approved design, discovery inserts named RED-to-GREEN pairs for every
affected layer.

## Task (bugfix)
Bugfix tasks start with root-cause discovery. Prod-copy fixes prepend `reproduce in
prod-copy`; `steps discovery` inserts scoped TDD steps.

```markdown
# Task N: Title — Progress

Type: bugfix

## Spec
- [x] spec

## Fix: Bug description
- [ ] reproduce in prod-copy          <- only when externally observed
- [~] root cause analysis
- [ ] design
- [ ] steps discovery
```

Every red step precedes the production change that makes it green. Externally
observable changes include an acceptance RED/GREEN pair.

## Task (refactor)
```markdown
# Task N: Title — Progress

Type: refactor

## Spec
- [x] spec
- [~] design
- [ ] refactor (steps discovery)

## Work
```

Discovery fills `## Work` with direct behavior-preserving steps and records
`plan: +N/-N/~N`; at least one count is non-zero. RED/GREEN is forbidden.

## Task (infra or general)

```markdown
# Task N: Title — Progress

Type: infra

## Spec
- [x] spec
- [~] design

## Work

### Step 1: Work-unit title
- [ ] direct implementation intent and verification
```

`general` uses the same shape with `Type: general`. Each spec Work item becomes one
direct step. Infra steps operate through repository-managed infrastructure-as-code.
Choose all task shapes with [`steps-discovery-shapes.md`](steps-discovery-shapes.md).
