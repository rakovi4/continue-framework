# Java/Spring TDD Idioms

Tech binding for `tdd-rules.md`. Load alongside the universal rules.

## Test Disable Marker

- JUnit 5: `@Disabled` annotation on test methods/classes
- Referenced as "test disable marker" in universal rules
- In RED: add `@Disabled` after validating prediction
- In GREEN: remove `@Disabled` (the only test modification allowed)
- In commit discipline: RED commits include `@Disabled` tests

## Test Description

- Use `@Description("...")` on test classes to document the scenario in English
- Test class DSL should match the abstraction level of its `@Description`

## Stub Pattern

- `throw new UnsupportedOperationException()` for real adapter stubs in RED
- `return null` as an alternative minimal stub
- Fakes are functional (not stubbed) — only real adapters use this pattern

## Domain Stub Examples

- If a test asserts `Column.empty("To Do")`, Column needs only a `name` field — not a `List<Task> tasks` field and a separate `Task.java` with 4 fields
- When a domain constructor changes (e.g., adding `TaskStatus` to `Task`), patch callers with enum defaults like `TaskStatus.TODO`

## Build Green in RED — Forbidden Changes

- Never add JPA `@Column` annotations during RED
- Never add Liquibase migrations during RED
- Never add new JPA entity fields during RED
- These are implementation, not plumbing — they belong in GREEN

## GREEN Phase Artifacts

- Production code, SQL migrations (Liquibase), JPA entities, Spring Data repositories

## Coverage Tool

- JaCoCo for Java code coverage
- Reports in `build/reports/jacoco/` (XML format)
- Run per-module: domain files checked against usecase JaCoCo, adapter files checked against adapter JaCoCo
- Scan touched files across `backend/*/src/main/` and `backend/adapters/*/src/main/`

## Test Filter Flag

- Gradle: `--tests "*ClassName*"` to run a single test class
- Example: `./gradlew :usecase:test --tests "*TaskTest*"`
- Acceptance: poll output file for `FAILED|BUILD SUCCESSFUL|BUILD FAILED`

## 3-Tier Test Architecture — Java Specifics

### Test Class
- No `assertThat`, no `assertThatThrownBy` — these belong in Statements
- No `for`, `while`, `if` — control flow belongs in Statements
- No private methods, no inner records/classes

### Scope
- Lombok `@Builder` with `@Builder.Default` values for optional fields
- Example: `@Builder.Default Optional<String> email = Optional.empty()`

## Test Data & Isolation — Java/Spring Specifics

- H2 adapter tests: `@DataJpaTest` + `FixtureCleanerExtension`
- REST adapter tests: `@SpringBootTest` + `MockMvc`
- Mockito: reset mocks/fakes before each test (`@BeforeEach` reset or `Mockito.reset()`)

## Assertion Library (AssertJ)

- Strict equality: `assertThat(actual).isEqualTo(expected)`
- Non-null (last resort): `assertThat(actual).isNotNull()`
- Timestamp bounds: `assertThat(timestamp).isAfter(now.minus(Duration.ofSeconds(30)))`
- Exception assertions: `assertThatThrownBy(() -> ...).isInstanceOf(ValidationException.class)`
- Recursive comparison: `assertThat(actual).usingRecursiveComparison().isEqualTo(expected)`
- List recursive comparison: `assertThat(list).usingRecursiveFieldByFieldElementComparator().containsExactlyInAnyOrderElementsOf(expected)`
- Reserve per-field assertions only when custom comparators or field exclusions are needed

## Async Wait Pattern (Awaitility)

- **Negative assertion**: `Awaitility.await().during(Duration).atMost(Duration).untilAsserted(...)`
- **Waiting for side-effect**: `Awaitility.await().atMost(...).untilAsserted(...)`
- Never use `Thread.sleep` — always use Awaitility polling

## Test Review Grep Patterns

Grep patterns for the test-review-agent checklist. Each entry maps to a checklist item number.

| # | Check | Grep pattern |
|---|-------|-------------|
| 2 | Loose string assertions | `contains(\|isNotNull\|isNotEmpty\|isNotBlank` |
| 3 | Range/direction checks | `isGreaterThan\|isLessThan\|isBetween\|isAfter\|isBefore` |
| 4 | Loose mock matchers | `any(` |
| 6 | Partial collection coverage | `get(0)` |
| 12 | Assertions in test class | `assertThat\|assertThatThrownBy` |
| 21 | Calculated expected values | `Math\.\|ceil\|floor\|% \|/ \(double\)\|totalElements.*pageSize` |
| 23 | Private methods or inner types in test class | `private .* \|private record\|private class\|private static` |
| 26 | HTTP client code in acceptance Statements | `RestAssured\|given()\|baseUri\|\.get(\|\.post(\|\.put(\|\.delete(\|HttpClient\|fetch(` |

## Test Clock

- `MutableClock.advance(Duration)` to simulate time passing
- Example: `clock.advance(Duration.ofDays(31))` to expire a 30-day session
