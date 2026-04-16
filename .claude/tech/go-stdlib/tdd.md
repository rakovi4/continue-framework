# Go/stdlib TDD Idioms

Tech binding for `tdd-rules.md`. Load alongside the universal rules.

## Test Disable Marker

- `t.Skip("TDD Red Phase - reason")` at the start of the test function
- Referenced as "test disable marker" in universal rules
- In RED: add `t.Skip(...)` after validating prediction
- In GREEN: remove `t.Skip(...)` (the only test modification allowed)
- In commit discipline: RED commits include skipped tests

## Test Description

- Use `t.Run("scenario description", func(t *testing.T) { ... })` for subtests
- The subtest name documents the scenario in plain English
- Test class DSL should match the abstraction level of its subtest name

## Stub Pattern

- `panic("not implemented")` for real adapter stubs in RED
- Fakes are functional (not stubbed) — only real adapters use this pattern

## Domain Stub Examples

- If a test asserts `NewColumn("To Do")`, Column needs only a `name` field — not a `tasks []Task` field and a separate `Task` struct with 4 fields
- When a domain constructor changes (e.g., adding `Status` to `Task`), patch callers with zero-value defaults like `StatusTodo`

## Build Green in RED — Go-Specific Forbidden Changes

- Never add `*.sql` migration files (golang-migrate/goose) during RED
- Never add or modify sqlc query files (`.sql` in `queries/`) during RED
- Never add new fields to `*Row` / `*Entity` persistence structs during RED
- Never modify `sqlc.yaml` schema definitions during RED

## GREEN Phase Artifacts

- Production code, SQL migrations (golang-migrate / goose), persistence row structs, repository implementations, sqlc queries

## Coverage Tool

- `go test -coverprofile=coverage.out` for Go code coverage
- Reports in `coverage.out` (text format) and `coverage.html` via `go tool cover -html`
- Run per-module: domain files checked against usecase coverage, adapter files checked against adapter coverage
- Scan touched files across `backend/*/` and `backend/adapters/*/`

## Test Filter Flag

- `go test -run "TestName"` to run a single test or subtest
- Example: `go test ./backend/usecase/... -run "TestCreateTask"`
- Subtests: `go test -run "TestCreateTask/should_create_with_valid_input"`
- Acceptance: poll output file for `FAIL\|ok\|PASS` markers

## 3-Tier Test Architecture — Go Specifics

### Test Class
- No `assert.` / `require.` calls — these belong in Statements
- No `for`, `if` — control flow belongs in Statements
- No unexported helper functions

### Scope
- Use a builder function: `NewTaskScope(opts ...TaskScopeOption) TaskScope`
- Implementation: functional options pattern with `type TaskScopeOption func(*TaskScope)`
- Example: `scope := NewTaskScope(WithEmail("test@example.com"))` — returns a `TaskScope` with all defaults except email
- Default values via a `defaultTaskScope()` function that returns sensible defaults
- All fields unexported with exported getters — scopes are immutable value objects

## Test Data & Isolation — Go Specifics

- DB adapter tests: use test database with transaction rollback or table truncation cleanup
- HTTP adapter tests: `httptest.NewServer` or `httptest.NewRecorder` with chi router
- Mocking: `testify/mock` for mocks, or hand-written fakes implementing port interfaces (preferred for Clean Architecture)
- Fakes: plain Go structs implementing port interfaces with in-memory `map` or `[]T` storage
- Reset before each test via setup in `t.Run` or `TestMain`

## Assertion Library (testify)

- Strict equality: `assert.Equal(t, expected, actual)` or `require.Equal(t, expected, actual)`
- Non-null (last resort): `assert.NotNil(t, actual)`
- Timestamp bounds: `assert.WithinDuration(t, expected, actual, 30*time.Second)`
- Error assertions: `assert.ErrorIs(t, err, domain.ErrValidation)` or `assert.ErrorAs(t, err, &target)`
- No-error: `require.NoError(t, err)` — use `require` (not `assert`) so the test stops on error
- Recursive comparison: `assert.Equal(t, expected, actual)` — testify `Equal` does deep structural comparison by default
- List comparison: `assert.ElementsMatch(t, expected, actual)` for unordered, `assert.Equal(t, expected, actual)` for ordered
- Reserve per-field assertions only when custom comparators or field exclusions are needed

## Async Wait Pattern

- **Waiting for side-effect**: use `assert.Eventually` (testify) or `require.Eventually`:
  ```go
  require.Eventually(t, func() bool {
      return fakeSender.CallCount() > 0
  }, 5*time.Second, 50*time.Millisecond)
  ```
- **Negative assertion ("nothing happened")**: use `assert.Never`:
  ```go
  assert.Never(t, func() bool {
      return fakeSender.CallCount() > 0
  }, 2*time.Second, 200*time.Millisecond)
  ```
- Never use bare `time.Sleep` — always use testify polling assertions

## Test Review Grep Patterns

Grep patterns for the test-review-agent checklist. Each entry maps to a checklist item number.

| # | Check | Grep pattern |
|---|-------|-------------|
| 2 | Loose string assertions | `Contains\|NotNil\|NotEmpty\|NotZero` |
| 3 | Range/direction checks | `Greater\|Less\|InDelta\|WithinDuration` |
| 4 | Loose mock matchers | `mock.Anything` |
| 6 | Partial collection coverage | `\[0\]` |
| 12 | Assertions in test class | `assert\.\|require\.` |
| 21 | Calculated expected values | `math\.\|float64(\|int(\|len(` |
| 23 | Private functions in test file | `^func [a-z]` (unexported helper functions in test files) |
| 26 | HTTP client code in acceptance Statements | `http\.Get\|http\.Post\|http\.NewRequest\|httptest\.\|net/http` |

## Test Clock

- Inject a `Clock` interface; use a `FakeClock` in tests with `Advance(d time.Duration)` method
- Example: `fakeClock.Advance(31 * 24 * time.Hour)` to expire a 30-day session
