# Red Phase Formats

## Failure Prediction Format (Single Method)

```
PREDICTED FAILURE:
- Type: [CompilationError | AssertionError | Exception]
- Message: "[expected error/assertion message]"
- Reason: "[why this failure is expected]"
```

## Failure Prediction Format (Multiple Methods -- Adapter Tests)

```
PREDICTED FAILURES:
1. {testMethodName}:
   - Type: AssertionError
   - Message: "..."
   - Reason: "..."
2. {testMethodName}:
   - Type: AssertionError
   - Message: "..."
   - Reason: "..."
```

## Output Summary Format

```
## Summary

**Files created:**
- `path/to/TestFile`

**Test method:** `testMethodName`

**Predicted failure:**
- Type: AssertionError
- Message: "expected message"
- Reason: reason

**Actual failure:**
actual error output

**Comparison:**
| Field   | Predicted                  | Actual                     | Match? |
|---------|----------------------------|----------------------------|--------|
| Type    | AssertionError             | AssertionError             | YES    |
| Message | "..."                      | "..."                      | YES    |

**Verdict:** ALL YES → test disable marker added

**Test status:** {tech-specific disable marker with reason}

**Next step:** Implement feature using /green-{layer} command
```

## Domain Field Gate Table

Before writing domain classes, produce this table for each field:

```
| Class.field         | Statements reference (method + line) | Verdict  |
|---------------------|--------------------------------------|----------|
| Column.name         | assertEmptyBoard -> Column.empty("To Do") | KEEP  |
| Column.tasks        | (none -- no Statements line reads .tasks) | REMOVE  |
```

"The recursive comparator compares all fields" is not a valid justification for KEEP -- remove the field so the comparator has nothing extra to compare.

## Prediction Comparison Table

After running the test, write this field-by-field comparison:

```
| Field   | Predicted | Actual | Match? |
|---------|-----------|--------|--------|
| Type    | ...       | ...    | YES/NO |
| Message | ...       | ...    | YES/NO |
| Status  | ...       | ...    | YES/NO |
```

Zero NOs -- add the test disable marker. Any NO -- do NOT disable, fix and re-run.

## Frontend Skip Convention

For frontend layers, use `it.skip(...)` instead of the backend test disable marker. Add a comment above with the actual failure reason.

## Test Disable Marker Rules

After verified failure, the disable marker message MUST include the actual failure reason (not a generic "TDD Red Phase" label alone).

For adapter test classes with multiple test methods, use **class-level** disable marker (one marker disables all methods). Individual per-method markers are unnecessary when the entire class covers one port method.
