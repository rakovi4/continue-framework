# Steps-Discovery Work-Unit Shapes

Classify each planned change before writing its checkbox. Task type does not select
the shape.

| Change | Plan shape | Verification |
|--------|------------|--------------|
| Executable code behavior changes | Named RED-to-GREEN pair for the affected layer | New failing test, then focused and affected suites |
| Executable code is restructured without behavior change | One direct refactoring checkbox | Existing focused and affected suites |
| Documentation, prompt-library, planning, or non-executable configuration changes | One direct implementation checkbox | Relevant structural checks or validators |

RED-to-GREEN is evidence that executable behavior moved from absent or wrong to
present and correct. When there is no executable behavior transition to demonstrate,
inventing RED produces ceremony rather than evidence.

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
