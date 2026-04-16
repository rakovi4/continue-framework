# PHP/Laravel TDD Idioms

Tech binding for `tdd-rules.md`. Load alongside the universal rules.

## Test Disable Marker

- PHPUnit: `$this->markTestSkipped('RED: ...')` in test method, or `#[Skip('RED: ...')]` attribute (PHPUnit 11+)
- For class-level skip: override `setUp()` with `$this->markTestSkipped('RED: ...')`
- Referenced as "test disable marker" in universal rules
- In RED: add skip after validating prediction
- In GREEN: remove skip (the only test modification allowed)
- In commit discipline: RED commits include skipped tests

## Test Description

- Use `#[TestDox('...')]` attribute on test classes to document the scenario in English
- Test class DSL should match the abstraction level of its `#[TestDox]`

## Stub Pattern

- `throw new \RuntimeException('Not implemented')` for real adapter stubs in RED
- Fakes are functional (not stubbed) -- only real adapters use this pattern

## Domain Stub Examples

- If a test asserts `Column::empty("To Do")`, Column needs only a `name` property -- not a `tasks` array and a separate `Task` class with 4 properties
- When a domain constructor changes (e.g., adding `TaskStatus` to `Task`), patch callers with enum defaults like `TaskStatus::TODO`

## Build Green in RED -- Forbidden Changes

- Never add Eloquent model properties or `$fillable`/`$casts` changes during RED
- Never add Laravel migrations during RED
- Never add new model relationships during RED
- These are implementation, not plumbing -- they belong in GREEN

## GREEN Phase Artifacts

- Production code, Laravel migrations (`php artisan make:migration`), Eloquent models, query scopes

## Coverage Tool

- PHPUnit with Xdebug or PCOV for PHP code coverage
- Reports in `build/reports/coverage/` (Clover XML via `--coverage-clover`)
- Run per-module: domain files checked against usecase coverage, adapter files checked against adapter coverage
- Scan touched files across `backend/*/src/` and `backend/adapters/*/src/`

## Test Filter Flag

- PHPUnit: `--filter ClassName` to run a single test class
- Example: `./vendor/bin/phpunit --filter CreateTaskTest backend/usecase/tests/`
- Acceptance: poll output file for `FAILURES|OK|ERRORS` markers

## 3-Tier Test Architecture -- PHP Specifics

### Test Class
- No `$this->assert*` calls -- these belong in Statements
- No `for`, `while`, `if` -- control flow belongs in Statements
- No private methods, no inner classes

### Scope
- Use `readonly class` with a static `builder()` method that accepts named arguments
- Implementation: class with `DEFAULTS` array and `static builder(mixed ...$overrides): self`
- Example: `$scope = TaskScope::builder(email: 'test@example.com')` -- returns a `TaskScope` with all defaults except email
- Default values via array merge: `[...self::DEFAULTS, ...$overrides]`
- All properties readonly -- scopes are immutable value objects

## Test Data & Isolation -- PHP/Laravel Specifics

- DB adapter tests: `use RefreshDatabase` trait or `DatabaseTransactions` trait
- REST adapter tests: Laravel `TestCase` with `$this->getJson()`, `$this->postJson()` etc.
- Mocking: `Mockery::mock()` for mocks. Reset via `Mockery::close()` in `tearDown()` or automatic with `MockeryPHPUnitIntegration` trait
- Fakes: plain PHP classes implementing port interfaces with in-memory `array` storage

## Assertion Library (PHPUnit)

- Strict equality: `$this->assertEquals($expected, $actual)` or `$this->assertSame($expected, $actual)`
- Non-null (last resort): `$this->assertNotNull($actual)`
- Timestamp bounds: `$this->assertGreaterThan($now->modify('-30 seconds'), $actual)`
- Exception assertions: `$this->expectException(ValidationException::class)`
- Object comparison: `$this->assertEquals($expected, $actual)` -- PHPUnit does deep structural comparison on objects
- List comparison: `$this->assertEquals($expected, $actual)` for ordered, `$this->assertEqualsCanonicalizing($expected, $actual)` for unordered
- Reserve per-field assertions only when custom comparators or field exclusions are needed

## Async Wait Pattern

- **Waiting for side-effect**: polling loop with assertion:
  ```php
  $this->retry(5, function () {
      $this->assertEquals($expected, $this->getActualValue());
  }, 100); // 100ms between retries
  ```
  Or custom polling helper:
  ```php
  $this->waitUntil(fn() => $this->getActualValue() === $expected, timeout: 5);
  ```
- **Negative assertion ("nothing happened")**: poll for a duration, asserting condition holds throughout
- Never use bare `sleep()` as a wait -- always use polling with assertions

## Test Review Grep Patterns

Grep patterns for the test-review-agent checklist. Each entry maps to a checklist item number.

| # | Check | Grep pattern |
|---|-------|-------------|
| 2 | Loose string assertions | `assertStringContainsString\|assertNotNull\|assertNotEmpty` |
| 3 | Range/direction checks | `assertGreaterThan\|assertLessThan\|assertGreaterThanOrEqual` |
| 4 | Loose mock matchers | `withAnyArgs\|Mockery::any()` |
| 6 | Partial collection coverage | `\[0\]` |
| 12 | Assertions in test class | `assert\|expectException\|$this->assert` |
| 21 | Calculated expected values | `ceil\|floor\|round\|intdiv\|fmod` |
| 23 | Private methods in test class | `private function` |
| 26 | HTTP client code in acceptance Statements | `Http::\|->getJson\|->postJson\|->putJson\|->deleteJson\|curl\|fetch(` |

## Test Clock

- Inject a `Clock` interface; use a `FakeClock` in tests with `advance(int $seconds)` method
- Or use Laravel's `Carbon::setTestNow()` for time freezing: `Carbon::setTestNow(now()->addDays(31))`
- Example: `$fakeClock->advance(31 * 24 * 3600)` to expire a 30-day session
