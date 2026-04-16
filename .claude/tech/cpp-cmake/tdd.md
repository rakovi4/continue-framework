# C++/CMake TDD Idioms

Tech binding for `tdd-rules.md`. Load alongside the universal rules.

## Test Disable Marker

- Google Test: prefix test name with `DISABLED_` (e.g., `TEST_F(TaskTest, DISABLED_should_create_task)`)
- Referenced as "test disable marker" in universal rules
- In RED: add `DISABLED_` prefix after validating prediction
- In GREEN: remove `DISABLED_` prefix (the only test modification allowed)
- In commit discipline: RED commits include `DISABLED_` tests

## Test Description

- Google Test provides test names as descriptions. Use descriptive `snake_case` test names that document the scenario.
- For additional context, use comments above the test or `SCOPED_TRACE("description")` inside.

## Stub Pattern

- `throw std::logic_error("Not implemented")` for real adapter stubs in RED
- Fakes are functional (not stubbed) — only real adapters use this pattern

## Domain Stub Examples

- If a test asserts `Column::empty("To Do")`, Column needs only a `name_` field — not a `std::vector<Task> tasks_` field and a separate `Task` class with 4 fields
- When a domain constructor changes (e.g., adding `TaskStatus` to `Task`), patch callers with enum defaults like `TaskStatus::kTodo`

## Build Green in RED — Forbidden Changes

- Never add SQLite schema migrations during RED
- Never add new SQLite row struct fields during RED
- Never add protobuf message fields during RED
- These are implementation, not plumbing — they belong in GREEN

## GREEN Phase Artifacts

- Production code, SQL migration scripts, SQLite row structs, protobuf service/message definitions, CMakeLists.txt updates

## Coverage Tool

- gcov/lcov for GCC, llvm-cov for Clang
- Reports generated via `lcov --capture` or `llvm-cov export` (LCOV/JSON format)
- Run per-module: domain files checked against usecase coverage, adapter files checked against adapter coverage
- Scan touched files across `backend/*/src/` and `backend/adapters/*/src/`

## Test Filter Flag

- Google Test: `--gtest_filter="*ClassName*"` to run a single test class
- Example: `./build/backend/usecase/usecase_tests --gtest_filter="*TaskTest*"`
- Acceptance: poll output file for `FAILED\|PASSED` markers

## 3-Tier Test Architecture — C++ Specifics

### Test Class
- No `EXPECT_*`, no `ASSERT_*` — these belong in Statements
- No `for`, `while`, `if` — control flow belongs in Statements
- No private methods or nested types

### Scope
- Plain `struct` with default values and a `Builder` nested class
- Builder provides fluent `with_*()` methods and a `build()` method returning the scope
- Example: `auto scope = TaskScope::Builder().with_email("test@example.com").build()`

## Test Data & Isolation — C++ Specifics

- SQLite adapter tests: in-memory database (`:memory:`) with schema setup in `SetUp()` and teardown in `TearDown()`
- gRPC adapter tests: mock gRPC service or in-process server with GMock
- GMock: reset mocks before each test via `SetUp()` or fresh construction
- Fakes: plain C++ classes implementing port interfaces with in-memory `std::unordered_map` or `std::vector` storage

## Assertion Library (Google Test)

- Strict equality: `EXPECT_EQ(actual, expected)`
- Non-null (last resort): `EXPECT_NE(actual, nullptr)` or `EXPECT_TRUE(opt.has_value())`
- Timestamp bounds: `EXPECT_GE(timestamp, now - std::chrono::seconds(30))`
- Exception assertions: `EXPECT_THROW(expression, ValidationException)`
- Exception message: `EXPECT_THAT([]{ code; }, ThrowsMessage<ValidationException>(HasSubstr("msg")))`
- Structural comparison: implement `operator==` on structs, then `EXPECT_EQ(actual, expected)`
- List comparison: `EXPECT_THAT(actual_vec, ::testing::ElementsAre(a, b, c))` for ordered, `EXPECT_THAT(actual_vec, ::testing::UnorderedElementsAre(a, b, c))` for unordered
- Reserve per-field assertions only when custom matchers or field exclusions are needed

## Async Wait Pattern (polling loop)

- **Waiting for side-effect**: polling loop with `std::this_thread::sleep_for` and assertion check:
  ```cpp
  auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds(5);
  while (std::chrono::steady_clock::now() < deadline) {
      if (check_condition()) break;
      std::this_thread::sleep_for(std::chrono::milliseconds(100));
  }
  EXPECT_TRUE(check_condition());
  ```
- **Negative assertion ("nothing happened")**: poll for a duration, asserting the condition holds throughout:
  ```cpp
  auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds(2);
  while (std::chrono::steady_clock::now() < deadline) {
      EXPECT_FALSE(side_effect_occurred());
      std::this_thread::sleep_for(std::chrono::milliseconds(200));
  }
  ```
- Never use bare `std::this_thread::sleep_for` as a wait — always use polling with assertions

## Test Review Grep Patterns

Grep patterns for the test-review-agent checklist. Each entry maps to a checklist item number.

| # | Check | Grep pattern |
|---|-------|-------------|
| 2 | Loose string assertions | `find\|npos\|EXPECT_NE.*npos\|EXPECT_TRUE.*find` |
| 3 | Range/direction checks | `EXPECT_GT\|EXPECT_LT\|EXPECT_GE\|EXPECT_LE` |
| 4 | Loose mock matchers | `::testing::_\|An<\|A<` |
| 6 | Partial collection coverage | `\[0\]` |
| 12 | Assertions in test class | `EXPECT_\|ASSERT_` |
| 21 | Calculated expected values | `std::ceil\|std::floor\|% \|/ static_cast<double>` |
| 23 | Private methods or inner types in test class | `private:\|struct.*{` inside test fixture |
| 26 | HTTP client code in acceptance Statements | `curl_\|httplib::\|HttpClient\|fetch\(` |

## Test Clock

- Inject a `Clock` interface; use a `FakeClock` in tests with `advance(std::chrono::duration)` method
- Example: `fake_clock.advance(std::chrono::hours(24 * 31))` to expire a 30-day session
