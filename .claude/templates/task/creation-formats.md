# Task Creation Formats

## Usage Examples

```
/task behavior-change "Reject invalid transition"
/task bugfix "Modal scroll broken"
/task refactor "Simplify task aggregate"
/task infra "Add health probe"
/task general "Update contributor guide"
/task qa "Smoke short list"
/task
```

## spec.md Format

The six canonical types are `behavior-change`, `bugfix`, `refactor`, `infra`,
`general`, and `qa`. Only `behavior-change` and `bugfix` use TDD.

- A **behavior-change** spec captures current and expected observable behavior,
  constraints, and likely files. Design and steps discovery produce the TDD plan.
- A **bugfix** spec captures only the observable problem and reproduction. Root
  cause, solution, affected layers, and key files are discovered later.
- A **refactor** spec captures the structural problem and behavior-preserving
  outcome. It never contains a behavior change or RED-to-GREEN plan.
- **Infra** and **general** specs capture the problem, intended outcome,
  constraints, likely files, and bounded direct work units.
- A **qa** spec captures why and when to run a reusable manual checklist plus its
  cases. It changes no production code.

```markdown
# Task {N}: {Title}

Type: {behavior-change|bugfix|refactor|infra|general|qa}

## Problem

{description}

## Current Behavior  <- behavior-change only

{externally observable behavior before the change}

## Expected Behavior  <- behavior-change only

{externally observable behavior after the change}

## Solution  <- refactor, infra, general, and qa only

{intended outcome; behavior-preserving for refactor}

## Constraints  <- omit only when none are known

- {constraint}

## Key Files  <- behavior-change, refactor, infra, and general only

- {likely file path}

## Reproduction  <- bugfix only

{steps, environment, frequency, and captured response/error}

## Work  <- infra and general only

1. {bounded direct work unit}
2. ...

## Cases  <- qa only

1. {one-line case expressing intent; no Gherkin or implementation detail}
2. ...
```

## progress.md Formats

### Behavior change

```markdown
# Task {N}: {Title} -- Progress

Type: behavior-change

## Spec
- [x] spec
- [~] design
- [ ] steps discovery

## Change
```

`steps discovery` fills `## Change` with scoped, named RED-to-GREEN pairs for every
affected layer.

### Bugfix

```markdown
# Task {N}: {Title} -- Progress

Type: bugfix

## Spec
- [x] spec

## Fix: {bug description}
- [ ] reproduce in prod-copy          <- only when externally observed
- [ ] root cause analysis
- [ ] design
- [ ] steps discovery
```

`steps discovery` appends scoped RED-to-GREEN pairs.

### Refactor

```markdown
# Task {N}: {Title} -- Progress

Type: refactor

## Spec
- [x] spec
- [~] design
- [ ] refactor (steps discovery)

## Work
```

Discovery fills `## Work` with direct behavior-preserving refactoring steps.

### Infra or general

```markdown
# Task {N}: {Title} -- Progress

Type: {infra|general}

## Spec
- [x] spec
- [~] design

## Work

### Step 1: {work-unit title}
- [ ] {direct implementation intent and verification}
```

Each `spec.md` Work item becomes one step. Infra work changes repository-managed
infrastructure-as-code; it never mutates remote infrastructure manually.

### QA

```markdown
# Task {N}: {Title} -- Progress

Type: qa

## Spec
- [x] spec
- [~] design

## Cases
- [ ] {case 1 -- short intent}
- [ ] {case 2 -- short intent}
```

QA cases are human-run checklist items. Failed cases remain unchecked and produce a
separate `bugfix` task.

`progress.md` is the source of truth for state. Routine evidence belongs in
`worklog/`; noteworthy cross-conversation context belongs in journey summaries
written only by `/handoff`.
