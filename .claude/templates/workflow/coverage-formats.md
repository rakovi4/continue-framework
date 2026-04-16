# Coverage Agent Formats

## Progress Update Format

Insert coverage steps immediately after the current `green-{layer}` line in the scenario. Each gap gets a `red-{layer}` + `green-{layer}` pair with a `(coverage: ...)` annotation.

**Before:**
```
- [x] green-usecase
- [ ] red-adapter rest
```

**After:**
```
- [x] green-usecase
- [ ] red-usecase (coverage: Title rejects null value)
- [ ] green-usecase (coverage: Title rejects null value)
- [ ] red-adapter rest
```

The `(coverage: ...)` annotation is a short description of the uncovered behavior — enough for the red phase to know what test to write.

## Dead Code Marking

When dead code is found, add an unreachable comment on the dead code line in the source file. The comment format is language-specific — see tech binding for syntax.

The refactor agent will detect and remove these lines.

## Gap-to-Scenario Mapping (--focus mode only)

For each uncovered line, read the production code to understand what behavior it represents, then:

1. **Read the story's test spec** (`tests/01_API_Tests.md`, `tests/05_Security_Tests.md`, `tests/06_Integration_Tests.md`) and **progress.md**.
2. **Search for an existing scenario** whose Gherkin description would exercise the uncovered line.
3. **Report each gap** with its mapping:

```
Uncovered line → scenario mapping:
  L42: TaskNotFoundException when task not found/wrong user
    → Covered by: Scenario 1.1 "Non-existent task returns 404" (pending: red-usecase)
  L97-99: fetch tasks from storage when not cached locally
    → No existing scenario covers this. Run /test-spec to add coverage.
```

## Remediation (--focus mode only)

After gap-to-scenario mapping, update `progress.md` with targeted red/green steps.

### Reachability check

For each uncovered line, determine if the path is **provably** unreachable:
- **Dead code** — branch is structurally impossible: `default` in exhaustive switch, `else` after complete type coverage, code after unconditional `return`. The proof must be language/compiler-level, not convention. A null guard in a public method is NOT dead code — it's reachable by any caller and IS the enforcement mechanism.
- **Reachable** — any branch a caller can trigger but no test covers. This includes defensive checks (null guards, range validation) in public APIs — convention ("null-free domain") does not make code unreachable. → add red/green steps

### Insert steps into progress.md

Find the current `green-{layer}` line in the scenario. Insert coverage steps immediately after it:

```markdown
- [x] green-usecase
- [ ] red-usecase (coverage: Title rejects null value)
- [ ] green-usecase (coverage: Title rejects null value)
- [ ] red-adapter rest
```

Layer matches the current green phase. Description is 5-10 words max.

### Remediation output

```
Coverage gaps found: N (M reachable, K dead code)

Reachable — added to progress.md:
  L12: null/undefined check true branch → red/green-usecase (coverage: Title rejects null value)
  L12: empty-string check false branch → red/green-usecase (coverage: Title accepts valid value)

Dead code — marked with unreachable comment in source, will be removed in refactor:
  L45: `default` in exhaustive switch → added unreachable comment

Steps added to progress.md: 4
```

If all gaps are dead code, report clean and list dead code for refactor. Do not add steps.
