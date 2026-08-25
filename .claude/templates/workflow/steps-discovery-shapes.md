# Steps-Discovery Work-Unit Shapes

Classify each planned change before writing its checkbox. The task type sets the
allowed execution discipline; the affected layer selects the concrete checkbox names.

| Task type | Allowed plan shape | Verification |
|-----------|--------------------|--------------|
| `behavior-change`, `bugfix` | Named RED-to-GREEN pair for every affected layer | New failing test, then focused and affected suites |
| `refactor` | One direct behavior-preserving refactoring checkbox per work unit | Existing focused and affected suites |
| `infra`, `general` | One direct implementation checkbox per work unit | Relevant tests, structural checks, or validators |
| `qa` | Manual case checkboxes only | Watched external-environment verification |

RED-to-GREEN is evidence that executable behavior moved from absent or wrong to
present and correct. It is mandatory for the two TDD task types and forbidden for
the four no-TDD types. If discovery in a no-TDD task finds a necessary executable
behavior change, reclassify the task or split that work into a `behavior-change` or
`bugfix` task before implementation.

## Examples

Behavior change:

```markdown
### Step 1: Reject an invalid transition
- [~] red-usecase
- [ ] green-usecase
```

Behavior-preserving code restructuring:

```markdown
### Step 1: Move parsing behind the existing port
- [~] move parsing behind the port and run affected tests
```

Prompt-library change:

```markdown
### Step 1: Define concurrent lane orchestration
- [~] update the workflow contract and run prompt-library checks
```

Do not disguise either direct shape as `red-workflow` / `green-workflow`. A named
workflow pair is reserved for an executable workflow engine with observable behavior
and a real test harness, as defined by `workflow-layer-test.md`.
