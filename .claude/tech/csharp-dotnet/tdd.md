# C#/ASP.NET Core TDD Idioms

Tech binding for `tdd-rules.md`. Load alongside the universal rules.

## Test Disable Marker

- xUnit: `[Fact(Skip = "RED: ...")]` or `[Theory(Skip = "RED: ...")]` on test methods
- NUnit: `[Ignore("RED: ...")]` on test methods/classes
- Referenced as "test disable marker" in universal rules
- In RED: add `Skip` / `Ignore` after validating prediction
- In GREEN: remove `Skip` / `Ignore` (the only test modification allowed)
- In commit discipline: RED commits include skipped tests

## Test Description

- xUnit: use `[Fact(DisplayName = "...")]` on test methods to document the scenario in English
- NUnit: use `[Test, Description("...")]` on test methods
- Test class DSL should match the abstraction level of its display name

## Stub Pattern

- `throw new NotImplementedException()` for real adapter stubs in RED
- Fakes are functional (not stubbed) — only real adapters use this pattern

## Domain Stub Examples

- If a test asserts `Column.Empty("To Do")`, Column needs only a `Name` property — not a `List<Task> Tasks` property and a separate `Task` class with 4 properties
- When a domain constructor changes (e.g., adding `TaskStatus` to `Task`), patch callers with enum defaults like `TaskStatus.Todo`

## Build Green in RED — Forbidden Changes

- Never add EF Core `[Column]` attributes or `OnModelCreating` configuration during RED
- Never add EF Core migrations during RED
- Never add new EF Core entity properties during RED
- These are implementation, not plumbing — they belong in GREEN

## GREEN Phase Artifacts

- Production code, EF Core migrations (`dotnet ef migrations add`), EF Core entities, DbContext configuration

## Coverage Tool

- Coverlet for C# code coverage (integrates with `dotnet test`)
- Reports in `TestResults/` (Cobertura XML format)
- Run per-module: domain files checked against usecase coverage, adapter files checked against adapter coverage
- Scan touched files across `backend/*/` and `backend/Adapters/*/`

## Test Filter Flag

- dotnet: `--filter "FullyQualifiedName~ClassName"` to run a single test class
- Example: `dotnet test backend/Usecase.Tests --filter "FullyQualifiedName~TaskTest"`
- Acceptance: poll output file for `Failed|Passed` markers

## 3-Tier Test Architecture — C# Specifics

### Test Class
- Assertion library calls to grep for: `Assert.` and `.Should()` — both belong in Statements only

### Scope
- Use a `record` with a `static Builder(...)` method that returns a new scope with overridden fields
- Implementation: record with `static readonly` defaults and `static Builder(...)` factory using `with` expression
- Example: `var scope = TaskScope.Builder(email: "test@example.com")` — returns a `TaskScope` with all defaults except email
- Default values via `with` expression: `Defaults with { Email = email }`
- All properties `init`-only — scopes are immutable value objects

## Test Data & Isolation — C#/ASP.NET Core Specifics

- DB adapter tests: `WebApplicationFactory<T>` with test database + transaction rollback or fixture cleanup
- REST adapter tests: `WebApplicationFactory<T>` + `HttpClient` from test server
- Mocking: `Moq` (`Mock<T>`) or `NSubstitute` (`Substitute.For<T>()`). Reset before each test via constructor (xUnit creates new instance per test) or `[SetUp]` (NUnit)
- Fakes: plain C# classes implementing port interfaces with in-memory `Dictionary` or `List` storage

## Assertion Library (FluentAssertions / xUnit Assert)

- Strict equality: `actual.Should().Be(expected)` or `Assert.Equal(expected, actual)`
- Non-null (last resort): `actual.Should().NotBeNull()` or `Assert.NotNull(actual)`
- Timestamp bounds: `actual.Should().BeAfter(now.AddSeconds(-30))`
- Exception assertions: `act.Should().Throw<ValidationException>()` or `Assert.Throws<ValidationException>(() => act())`
- Async exception: `await act.Should().ThrowAsync<ValidationException>()`
- Recursive comparison: `actual.Should().BeEquivalentTo(expected)` — FluentAssertions does deep structural comparison
- List comparison: `list.Should().BeEquivalentTo(expected)` for unordered, `list.Should().Equal(expected)` for ordered
- Reserve per-field assertions only when custom options or member exclusions are needed

## Async Wait Pattern (Polly / polling loop)

- **Waiting for side-effect**: use `Polly` retry or manual polling with `Task.Delay`:
  ```csharp
  await Policy
      .HandleResult<bool>(r => !r)
      .WaitAndRetryAsync(50, _ => TimeSpan.FromMilliseconds(100))
      .ExecuteAsync(async () => await CheckConditionAsync());
  ```
- **Negative assertion ("nothing happened")**: poll for a duration, asserting the condition holds throughout:
  ```csharp
  var deadline = DateTime.UtcNow.AddSeconds(2);
  while (DateTime.UtcNow < deadline)
  {
      mockService.Verify(x => x.Execute(), Times.Never);
      await Task.Delay(200);
  }
  ```

## Test Review Grep Patterns

Grep patterns for the test-review-agent checklist. Each entry maps to a checklist item number.

| # | Check | Grep pattern |
|---|-------|-------------|
| 2 | Loose string assertions | `Contain\|NotBeNull\|NotBeEmpty\|NotBeNullOrEmpty` |
| 3 | Range/direction checks | `BeGreaterThan\|BeLessThan\|BeInRange\|BeAfter\|BeBefore` |
| 4 | Loose mock matchers | `It.IsAny<` |
| 6 | Partial collection coverage | `\[0\]` |
| 12 | Assertions in test class | `Should()\|Assert\.` |
| 21 | Calculated expected values | `Math\.\|Ceiling\|Floor\|% \|/ \(double\)` |
| 23 | Private methods or inner types in test class | `private .* \|private record\|private class\|private sealed` |
| 26 | HTTP client code in acceptance Statements | `HttpClient\|\.GetAsync\|\.PostAsync\|\.PutAsync\|\.DeleteAsync\|SendAsync` |

## Test Clock

- Inject an `IClock` interface; use a `FakeClock` in tests with `Advance(TimeSpan)` method
- Example: `fakeClock.Advance(TimeSpan.FromDays(31))` to expire a 30-day session
