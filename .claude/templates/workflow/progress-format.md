# Progress File Format

## Story

```markdown
# Story N: Story Title — Progress

## Spec
- [x] interview
- [x] story
- [x] mockups
- [x] api-spec
- [x] test-spec

## Backend Scenarios (01_API_Tests.md)

### Scenario 1: Scenario title
- [x] red-acceptance
- [~] design               <- MANDATORY for every scenario needing new implementation
- [ ] red-usecase
- [ ] green-usecase
- [ ] adapters-discovery
- [ ] green-acceptance

#### After adapters-discovery resolves (example):
- [x] adapters-discovery (h2, rest)
- [ ] red-adapter h2
- [ ] green-adapter h2
- [ ] red-adapter rest
- [ ] green-adapter rest
- [ ] green-acceptance

## Integration Scenarios (06_Integration_Tests.md)

### Scenario title
- [ ] red-acceptance
- [ ] design
- [ ] red-usecase
- [ ] green-usecase
- [ ] adapters-discovery
- [ ] green-acceptance

## Frontend Scenarios (02_UI_Tests.md)

### Scenario 1: Scenario title
- [ ] red-selenium
- [ ] red-frontend
- [ ] green-frontend
- [ ] red-frontend-api
- [ ] green-frontend-api
- [ ] align-design
- [ ] green-selenium
- [ ] demo

## Security Scenarios (05_Security_Tests.md)

### Scenario title
- [ ] red-acceptance
- [ ] design
- [ ] red-usecase
- [ ] green-usecase
- [ ] adapters-discovery
- [ ] green-acceptance

## Load Scenarios (03_Load_Tests.md)

### Scenario title
- [ ] red-acceptance
- [ ] design
- [ ] red-usecase
- [ ] green-usecase
- [ ] adapters-discovery
- [ ] green-acceptance

## Infrastructure Scenarios (04_Infrastructure_Tests.md)

### Scenario title
- [ ] red-acceptance
- [ ] design
- [ ] red-usecase
- [ ] green-usecase
- [ ] adapters-discovery
- [ ] green-acceptance
```

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
- [~] red-adapter h2                  <- CURRENT
- [ ] green-adapter h2

### Step 2: Step description
- [ ] refactor usecase
- [ ] refactor (cleanup)
- [ ] green-acceptance
```
