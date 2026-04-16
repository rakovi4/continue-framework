# Node/TypeScript/Express TDD Idioms

Tech binding for `tdd-rules.md`. Load alongside the universal rules.

## Test Disable Marker

- Jest: `xit()` / `xdescribe()` or `it.skip()` / `describe.skip()`
- Vitest: `it.skip()` / `describe.skip()`
- Referenced as "test disable marker" in universal rules
- In RED: add `.skip` after validating prediction
- In GREEN: remove `.skip` (the only test modification allowed)
- In commit discipline: RED commits include skipped tests

## Test Description

- Use `describe("Feature: ...")` with nested `it("should ...")` blocks
- The `describe` block documents the scenario in plain English
- Test class DSL should match the abstraction level of its `describe` text

## Stub Pattern

- `throw new Error("Not implemented")` for real adapter stubs in RED

## Domain Stub Examples

- If a test asserts `Column.empty("To Do")`, Column needs only a `name` field — not a `tasks: Task[]` field and a separate `Task` class with 4 fields
- When a domain constructor changes (e.g., adding `TaskStatus` to `Task`), patch callers with enum defaults like `TaskStatus.TODO`

## Build Green in RED — Forbidden Changes

- Never add ORM schema/migration files during RED
- Never add Prisma `@map` / TypeORM `@Column` decorators during RED
- Never add new persistence entity fields during RED
- These are implementation, not plumbing — they belong in GREEN

## GREEN Phase Artifacts

- Production code, SQL migrations (Prisma Migrate / TypeORM migrations / Knex migrations), persistence entities, ORM repositories

## Coverage Tool

- c8 or istanbul for TypeScript code coverage (Vitest has built-in c8 coverage)
- Reports in `coverage/` (lcov and JSON formats)
- Run per-module: domain files checked against usecase coverage, adapter files checked against adapter coverage
- Scan touched files across `backend/*/src/` and `backend/adapters/*/src/`

## Test Filter Flag

- Jest: `--testPathPattern "ClassName"` or `-- ClassName.test.ts`
- Vitest: `vitest run src/path/to/ClassName.test.ts` or `--reporter verbose`
- Example: `npx vitest run src/usecase/__tests__/TaskTest.ts`
- Acceptance: poll output file for `FAIL|PASS|Tests:` markers

## 3-Tier Test Architecture — TypeScript Specifics

### Test Class
- No `expect()` calls — these belong in Statements
- No `for`, `while`, `if` — control flow belongs in Statements
- No private functions, no nested types/interfaces

### Scope
- Use a static `builder()` method that accepts partial overrides and spreads them over defaults
- Implementation: class with `private static readonly DEFAULTS` and `static builder(overrides?: Partial<T>): Scope`
- Example: `const scope = TaskScope.builder({ email: "test@example.com" })` — returns a `TaskScope` with all defaults except email
- Default values via object spread: `{ ...TaskScope.DEFAULTS, ...overrides }`
- All fields `readonly` — scopes are immutable value objects

## Test Data & Isolation — Node/Express Specifics

- DB adapter tests: use test database with transaction rollback or truncation cleanup
- REST adapter tests: `supertest` with the Express app instance
- Mocking: `jest.fn()` / `vi.fn()` for mocks. Reset before each test via `beforeEach(() => { jest.clearAllMocks() })` or `vi.clearAllMocks()`
- Fakes: plain TypeScript classes implementing port interfaces with in-memory `Map` or `Array` storage

## Assertion Library (Jest/Vitest expect)

- Strict equality: `expect(actual).toEqual(expected)` (deep) or `expect(actual).toBe(expected)` (reference)
- Non-null (last resort): `expect(actual).toBeDefined()`
- Timestamp bounds: `expect(timestamp.getTime()).toBeGreaterThan(now.getTime() - 30_000)`
- Exception assertions: `expect(() => action()).toThrow(ValidationException)`
- Async exception: `await expect(asyncAction()).rejects.toThrow(ValidationException)`
- Recursive comparison: `expect(actual).toEqual(expected)` — Jest/Vitest `toEqual` does deep structural comparison by default
- List comparison: `expect(list).toEqual(expect.arrayContaining(expected))` for unordered, `expect(list).toEqual(expected)` for ordered

## Async Wait Pattern

- **Waiting for side-effect**: use `wait-for-expect` (Awaitility equivalent for JS — polls assertions with timeout):
  ```typescript
  import waitForExpect from "wait-for-expect";

  await waitForExpect(() => {
    expect(mockFn).toHaveBeenCalledWith(expected);
  });
  // Default: 4.5s timeout, 50ms interval. Configurable:
  await waitForExpect(() => { expect(value()).toBe(true); }, 5000, 100);
  ```
- **Negative assertion ("nothing happened")**: use `wait-for-expect` with negated assertion:
  ```typescript
  import waitForExpect from "wait-for-expect";

  // Assert condition holds for the full duration (no early exit)
  await waitForExpect(() => {
    expect(mockFn).not.toHaveBeenCalled();
  }, 2000, 200);
  ```
- Never use bare `await new Promise(r => setTimeout(r, ms))` as a sleep — always use `wait-for-expect` with assertions

## Test Review Grep Patterns

Grep patterns for the test-review-agent checklist. Each entry maps to a checklist item number.

| # | Check | Grep pattern |
|---|-------|-------------|
| 2 | Loose string assertions | `toContain\|toBeDefined\|toBeTruthy\|toBeFalsy` |
| 3 | Range/direction checks | `toBeGreaterThan\|toBeLessThan\|toBeGreaterThanOrEqual` |
| 4 | Loose mock matchers | `expect.any(` |
| 6 | Partial collection coverage | `\[0\]` |
| 12 | Assertions in test class | `expect(` |
| 21 | Calculated expected values | `Math\.\|ceil\|floor\|% \|/ ` |
| 23 | Private functions in test class | `function _\|const _` |
| 26 | HTTP client code in acceptance Statements | `supertest\|request(\|fetch(\|axios\|\.get(\|\.post(\|\.put(\|\.delete(` |

## Test Clock

- Inject a `Clock` interface; use a `FakeClock` in tests with `advance(ms: number)` method
- Example: `fakeClock.advance(31 * 24 * 60 * 60 * 1000)` to expire a 30-day session
