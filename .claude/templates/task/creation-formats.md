# Task Creation Formats

## Usage Examples

```
/task bug "Modal scroll broken"
/task refactoring "TaskBoard aggregate"
/task qa "Smoke short list"
/task                                        # Interactive
```

## spec.md Format

At creation a **bug** spec captures only the observable problem and how to
reproduce it — describe the problem as thoroughly as possible. Do NOT pre-fill a
root cause, a proposed Solution, affected layers, or Key Files: those are
produced later by the discovery sequence (`root cause analysis` records the
cause and key files in `spec.md`; `design` settles the fix approach). Pre-baking
a solution at creation commits to an assumption before any investigation has run.

**Refactoring** and **qa** specs do state a Solution at creation (the intended
structural change / when-to-run), since there is no unknown cause to discover.

```markdown
# Task {N}: {Title}

Type: {bug|refactoring|qa}

## Problem

{description — for a bug, as thorough as possible: symptoms, observed vs.
expected, environment, frequency, any captured response/error}

## Solution  <- refactoring and qa only (omit for bug — produced during design)

{description}

## Key Files  <- refactoring only (omit for qa; for a bug, key files are
                 recorded by root cause analysis, not at creation)

- {file paths}

## Reproduction  <- bug only

{steps}

## Cases  <- qa only (omit Key Files and Reproduction)

1. {one-line case expressing intent — no Gherkin, no implementation detail}
2. ...
```

## progress.md Formats

### Bug (any layer)

Bug tasks do NOT pre-plan TDD steps at creation time. The progress file starts with a discovery sequence; concrete TDD steps are inserted by `/continue` once `steps-discovery` resolves (see Task Workflow Detail in `.claude/guidelines/workflow-detail.md`). This applies to every bug regardless of affected layer -- backend, frontend, or both.

```markdown
# Task {N}: {Title} -- Progress

Type: bug

## Spec
- [x] spec

## Fix: {bug description}
- [ ] root cause analysis
- [ ] design
- [ ] steps discovery
```

### Bug (prod-copy)

When the bug is observed in prod-copy (or any external environment that needs explicit reproduction before investigation), prepend a `reproduce in prod-copy` step:

```markdown
# Task {N}: {Title} -- Progress

Type: bug

## Spec
- [x] spec

## Fix: {bug description}
- [ ] reproduce in prod-copy
- [ ] root cause analysis
- [ ] design
- [ ] steps discovery
```

### Refactoring

```markdown
# Task {N}: {Title} -- Progress

Type: refactoring

## Spec
- [x] spec

## Fix

### Step 1: {description}
- [ ] red-adapter h2
- [ ] green-adapter h2

### Step 2: {description}
- [ ] refactor usecase
- [ ] refactor (cleanup)
- [ ] green-acceptance
```

### QA

QA tasks define a reusable manual checklist (smoke / regression) verified against an external environment. There is no TDD cycle and no production code change. `progress.md` mirrors `spec.md`'s Cases section as checkboxes; the tester ticks `[ ]` -> `[x]` during a session. Failed cases stay `[ ]` and a separate bug task is filed for the failure -- never overload the checkbox with a fail marker.

```markdown
# Task {N}: {Title} -- Progress

Type: qa

## Spec
- [x] spec

## Cases
- [ ] {case 1 -- short intent}
- [ ] {case 2 -- short intent}
- [ ] {case 3 -- short intent}
```
