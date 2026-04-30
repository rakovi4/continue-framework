# TDD & Testing Rules

## Red-Green-Refactor Cycle

Never write production code without a failing test first.

### RED Phase
- Create: test class, test methods, Statements/Scope helpers, minimal production stubs (using the not-implemented marker from the Conventions table in `technology.md`). **Never delegate to a working method** — delegating returns a valid result, which is partial implementation, not a stub.
- **Domain stubs: only what the test touches.** Domain entities and value objects created in RED must contain only the fields the current test actually references or asserts. Don't preemptively add fields, relationships, or entire classes from the ADR/design that future scenarios will need. Add fields when a test demands them, not before.
- Plumbing changes to existing code are OK if needed for compilation (adding a new port method signature, a new field to a request DTO, updating a fake to compile). The line is: **plumbing so the test compiles and fails ≠ implementing the feature**. If you find yourself writing business logic, conditional branches, or wiring behavior end-to-end — stop, that belongs in GREEN.
- **Keep the full build green during RED.** When a domain entity constructor changes, fix ALL callers across the project with defaults or zero-values to keep everything compiling. But **only patch callers** — never add persistence annotations, database migrations, or new storage-layer fields. That's implementation, not plumbing.
- **Never modify an existing port method signature in RED** — add a new overloaded method instead. Modifying an existing signature cascades compilation failures to all adapter implementors, forcing production code changes that belong in GREEN. Add the new overload and leave existing adapters untouched. Real adapters stub with the not-implemented marker; remove the old method in REFACTOR after the new one is fully wired.
- **Fakes are test infrastructure, not production code.** Make fakes functional in RED (map lookups, list returns, setup methods) — they exist to support the test, not to be implemented later. Reserve not-implemented markers for real adapter implementations only.
- **Statements are test infrastructure, not production code.** ALL Statements methods — `assert*`, `navigate*`, `click*`, `enter*` — must be FULLY FUNCTIONAL in RED. Write real locators, real wait conditions, real assertions. NEVER stub a Statements method with the not-implemented marker. That marker is reserved for real adapter implementations only.
- **Existence check before writing any red test.** Search for existing production code that already provides the capability under test (an API client in another feature, a port method from a prior scenario, a logic function, an adapter implementation). If the capability already exists, skip the red step (and its green counterpart) with `[S]` and document what provides it. Don't write tests for code that's already implemented and tested elsewhere.
- **Skip validation: zero production files modified.** A step may only be `[S]` if ZERO production files in that layer need modification. If any file in that layer needs even a 1-line change (adding a parameter, updating a method signature, changing a mapping), the full red/green cycle applies. "The pipeline already supports it" is not sufficient — check whether the adapter/controller/entity that connects to the pipeline also already handles the new parameter. Common trap: usecase supports a filter, but the REST controller doesn't pass it through yet — that requires `red-adapter rest` + `green-adapter rest`, not `[S]`.
- **Trivial-logic check (frontend).** Before writing a `red-frontend` logic test, ask: does this scenario require branching, computation, validation, or data transformation in `.logic.ts`? If the "implementation" would be a constant (`true`), an unconditional pass-through, or a value that never varies by input — there is no logic to test. Skip with `[S]` (and its green counterpart) and note that the behavior is purely presentational (handled in the component during `align-design`). **Identity/pass-through mappings are trivial.** If the function would just forward API response fields to the view model unchanged (same structure, same values, no renaming, no filtering, no defaults), that is not "data transformation" — it is a pass-through. The diagnostic: "If I removed the logic function and the component used the API response directly, would anything break?" If no → skip. Examples of skippable: "edit button is always visible" (`showEditButton: true`), "page title is a fixed string", "board columns mapped 1:1 from API response to view model". Examples of testable: "edit button hidden when task is locked", "warning text varies by API key status", "API returns status codes, view model needs human-readable labels".
- **Post-implementation trivial-test gate.** After writing a test stub (step 8 in red-agent), before running it: review every assertion. If every assertion compares an output field to the same input field that was passed in (output ≈ input), the test is trivial — it only proves the function returns what it received. **STOP.** Delete the test, mark `[S]`, and note that the test was trivial (identity mapping). This gate catches cases where the pre-implementation trivial-logic check misjudged.
- ALWAYS predict failure (type, message, reason) before running. Run to validate prediction, then add the test disable marker.
- **Prediction match = type + status + message.** After running the test, write a field-by-field comparison table (Type / Message / Status — each YES or NO). Count the NOs: zero NOs → add the test disable marker. Any NO → do NOT disable, do NOT argue "the red state is still valid." A NO means the predicted code path didn't execute — fix the setup, re-predict, re-run.
- **Predictions must be about feature behavior, not infrastructure.** "Backend not running → connection error" is never a valid prediction — it says nothing about the code under test. For acceptance tests, start the backend first, then predict the actual application-level failure (assertion error, HTTP status, missing endpoint). If the feature is already implemented and the test would pass, that is the prediction — handle it in green-acceptance.

### GREEN Phase
- Implement ONLY minimal code to pass the test. No extra features, no "while I'm here" improvements.
- Tests are READ-ONLY (only remove the test disable marker). Statements setup methods may be updated when GREEN adds domain fields/ports that the setup now needs to wire through.
- **NEVER change assertion expected values in Statements.** Expected values (strings, numbers, prices, reason texts) were defined in RED and verified by prediction. If the running system returns different values than the Statements assert, the test is doing its job — the production code is wrong, not the test. Fix the production code to produce the expected values, or STOP and report the mismatch. Never "correct" assertions to match actual behavior — that defeats the purpose of TDD.
- **NEVER delete assertions from Statements methods.** Not to meet file size limits, not to "simplify", not for any reason. If a file exceeds 200 lines, extract a new Statements class by concern — never trim assertions. Even when a wait-for-visibility call implies visibility, the explicit assertion is the documented test assertion and must stay.
- Create: production code, database migrations, persistence entities, repositories as needed.
- **green-acceptance and green-selenium are remove-marker-only phases.** The ONLY allowed change is removing the test disable/skip marker. No production code changes (backend or frontend), no Statements changes, no new files. If the test does not pass after removing the marker, STOP and report — the missing implementation belongs in an earlier phase (green-usecase, green-adapter, align-design) that was incomplete or skipped. Never "fix" backend code in a green-acceptance/green-selenium step.

### REFACTOR Phase
- Improve structure (extract, rename, move, deduplicate). DO NOT change behavior or add features.
- **Stay in your layer.** After green-usecase, refactor only domain + usecase files. After green-adapter, refactor only that adapter. Never cascade into other layers — if a usecase method rename would require controller changes, keep the old public method and defer adapter updates.

### Coverage Check (after REFACTOR)
- After green-usecase or green-adapter, run `/test-coverage {module} --focus` **after** `/refactor`, not before. Refactoring can introduce new branches (null normalization, ternary extraction, guard clauses) that coverage must verify.
- The coverage check uses `coverage-agent.md` to analyze gaps, classify reachability, and update progress.md automatically.
- **Reachable gaps** → agent inserts `red-{layer} (coverage: ...)` + `green-{layer} (coverage: ...)` steps into progress.md immediately after the current green step.
- **Dead code gaps** (provably unreachable: exhaustive enum switch default, code after unconditional return) → agent flags for removal in the refactor phase. No new test steps added. Null guards in public methods are NOT dead code — they're reachable and need tests.
- Coverage steps target only branches/lines within the current scenario's code, not code belonging to future scenarios.
- **Focus filter must cover all touched files.** When running `--focus`, scan ALL production files changed since the last commit across the entire backend, not just the tested module. Usecase tests exercise domain classes; a new domain value object with validation branches must appear in the focus filter — otherwise its uncovered branches are silently ignored.
- **Multi-module coverage.** Group touched files by owning module. Run the coverage tool for each module that has touched files — not just the primary module. Domain files → check against usecase coverage (domain is tested through usecase tests). Adapter files → check against that adapter's coverage. This ensures every touched file is verified by the test suite that exercises it.
- Skip the coverage check for green-acceptance and green-selenium (black-box tests don't produce meaningful per-class coverage).

### Phase Transitions
- RED → GREEN: only after test fails as predicted.
- GREEN → REFACTOR: only after test passes.
- REFACTOR → RED: only after all tests still pass.

### Zero Tolerance for Test Failures
- When running tests, ALL failures must be investigated and resolved — not just the target test.
- **There is no such thing as a "pre-existing" failure.** Never dismiss a failure as pre-existing, known, or unrelated. If a test fails, it is YOUR problem right now. Either fix the root cause or create a task to fix it — but never report "all tests passed" when the build is red.
- A build marked FAILED means tests failed. Qualifying it with "but all actual tests passed" or "unrelated OOM" is dismissal — the suite is red and must be fixed before proceeding.
- If collateral tests fail after a green phase, the new production code likely broke them. Investigate before proceeding.
- Report ALL test results (pass count AND failure count) in every summary.

### Test Execution Efficiency
- **Run the narrowest scope possible.** When investigating a failure, use the test filter flag to run only the failing test class — never rerun the entire suite just to see one test's output.
- **Never re-run tests to get failure details you already have.** The output file from a completed run contains full stack traces. Use the `Read` tool on the output file — don't re-run the suite or even individual tests just to see the error. Only re-run a test when you've changed code and need to verify the fix.
- **Escalate scope only when needed:** single test → test class → module → full suite. Start narrow, widen only if the failure depends on test ordering or shared state.
- **Stop on first failure — then investigate immediately.** When running acceptance suites, launch with `run_in_background: true` and poll the output file for failure/success markers. When the first failure appears: (1) stop the running test suite (`TaskStop`), (2) read the stack trace from the output file, (3) investigate the root cause. Do NOT continue reading more failures, do NOT call `TaskOutput` to wait for completion, do NOT collect a summary of all failures. The first failure is the only one that matters — fix it before re-running. Waiting wastes minutes while the answer is already in front of you.
- **Show progress while tests run.** Never block silently waiting for test completion. A single Bash call with a polling loop does NOT show progress — output only appears when the command finishes. Instead, make **separate short Bash calls** to check the output file, so each call's output is displayed to the user immediately. The user must always have visibility into what is happening — silent waits erode trust.

## Commit Discipline

**Each TDD phase = separate commit. NEVER combine red and green in one commit.**
- RED → commit the failing test (with the test disable marker)
- GREEN → commit the implementation
- REFACTOR → commit the refactoring
- When asked to commit, only commit work from the current phase. If both red and green completed without committing, inform the user and ask how to proceed (separate commits recommended).

## Testing Patterns

### 3-Tier Architecture (Usecase Tests)
1. **Test Class**: pure DSL — only Statements calls. No assertion library calls, no data preparation, no usecase calls, no infrastructure, no control flow (`for`, `while`, `if`), no private methods, no inner types. Loops, conditionals, and shared setup logic belong in Statements methods — the test class should read as a flat sequence of named steps. **No implementation constants in any Statements call** — numeric IDs (task, column, board), positions, and other technical parameters belong inside Statements methods, not passed from the test class. This applies to setup (`given*`), action (`get*`, `execute*`), and assertion (`assert*`) calls equally. The test class should match the abstraction level of its test description. If the Given says "tasks in To Do and In Progress", the code should be `statements.givenTasksInTwoColumns()` — not `createTask(login, 10001L, 11001L, "TODO", ...)`. Return a structured type with the values the test needs for subsequent Statements calls.
2. **Statements**: reusable setup and assertion methods
3. **Scope**: builder pattern with default values

### Naming
- Test classes: `{Feature}Test`, methods: `should_{expected_behavior}`
- Statements: `{Feature}Statements`, Scope: `{Feature}Scope`
- **Test description = spec text.** Every test method's display annotation must contain the test case text from the spec (the Gherkin scenario). The method name is a short identifier; the display annotation is the readable spec. Example: method `should_return_board_with_three_empty_columns`, display annotation text = "Get empty board" (matching the spec's scenario title) and the scenario text.

### Acceptance Test Client Layer
- **Separate HTTP client from Statements.** Acceptance tests use a 3-tier architecture: Test Class → Statements → Application Client. The Application Client (`{Feature}Client`) encapsulates all HTTP calls (request building, response parsing, base URL resolution). Statements orchestrate setup/assertions using the client — they never make HTTP calls directly.
- Client classes own: base URL resolution, request construction, HTTP execution, response extraction.
- Statements classes own: test setup sequences, assertion logic, DSL methods for test readability.
- FORBIDDEN in Statements: HTTP library imports (see tech binding for specific libraries), URL construction, request/response handling.

### Test Data & Isolation
- Usecase tests: Fake implementations (no DB, no HTTP). Use TestData for shared constants.
- Persistence adapter tests: use the persistence test annotation with fixture cleanup.
- Web adapter tests: use the web test annotation with a mock HTTP client.
- Acceptance tests: full app, black box via HTTP API only. Never access DB directly.
- Each test independent: no shared mutable state, reset mocks/fakes before each test.

### Statements Dependency Limit
- A Statements class with more than 8 injected dependencies is a sign it needs splitting. Extract a focused Statements class per concern (e.g., `TaskStatements` + `BoardStatements` instead of one monolith).

### No Middleman Delegators Between Statements
- **NEVER create a Statements method that only forwards to another Statements class.** If `FormStatements` injects `FieldStatements` and creates `assertFieldVisible()` that just calls `fieldStatements.assertFieldVisible()`, that's a middleman. Instead, have the test (or test base class) inject `FieldStatements` directly and call it without the indirection. Each Statements class owns its own concern — tests compose by injecting multiple focused Statements, not by chaining through a parent.

### Assertion Rules
**NEVER inject storage adapters into Statements classes.** Statements depend only on usecases, other Statements, and Fake adapters for setup only (e.g., `FakeEmailClient.setValidSender()`). Use usecases to verify state, not storage queries.

**Default to strict assertions.** Treat every value as deterministic until proven otherwise. Error messages, reason strings, and status codes are defined by us — assert exact equality. IDs returned from setup (taskId, userId) must be captured and asserted with exact equality. Timestamps must be tightly bounded (within 30 seconds of test execution), never just a non-null check. Only auto-generated primary keys with no retrieval API may use non-null assertions.

**No calculations in test expected values.** Tests must be dumb — assert predefined constants, never compute expected values with formulas. If a Statements method uses arithmetic or derives the expected value from runtime data, the test is mirroring production logic and testing nothing. Fix the setup to produce a known, deterministic count, then assert with literals. When non-deterministic data makes literal assertions impossible, redesign the setup (control timing, reduce variables) — don't make the test "smart" to compensate.

**Never loosen assertions to work around non-deterministic data.** Replacing an exact-match assertion with a range assertion is not a fix — it hides bugs by accepting any value in range. If a background process (scheduler, async job) creates unpredictable entries, the fix is to stop the background process during the test, control the setup so counts are deterministic, or wait for a stable state before asserting. The assertion itself must stay strict.

**Prefer recursive/structural comparison over manual per-field assertions.** For immutable data objects, use the test framework's recursive comparison to get pinpoint field-by-field diffs in one line — no need for shared assertion utility classes with many per-field assertions. Reserve per-field assertions only when you need custom comparators or field exclusions.

**Prefer whole-response comparison over per-field extraction in HTTP endpoint tests.** When testing an HTTP endpoint's response, compare the entire serialized response against an expected example rather than extracting and asserting individual fields. Inline the expected response for small results; extract to a fixture file when it exceeds ~50 lines or is reused.
**No test helpers that duplicate production methods.** When a test helper reimplements logic that already exists as a method on a production object (even a private one), the fix is to make the production method accessible and delete the test copy. Duplication between test helpers and production code is still duplication — the refactoring scan must catch it.

**Minimize loops and conditionals in Statements.** Cycles and conditionals make tests "smart" — they belong in production code, not test code. Acceptable when iterating over large test data (generating bulk entries, asserting all N items in a collection) or in highly reused setup helpers. Unacceptable when a loop or conditional computes expected values or makes branching assertions — that's production logic leaking into tests.

### No Sleep-Based Waits in Tests
**Avoid sleep calls in Statements.** They waste CI time and produce flaky tests. Two alternatives by intent:
- **Negative assertion ("nothing happened")**: First check whether the positive assertion later in the test already proves the point — if the action only happens after condition X, and the test asserts that, the absence check is redundant. If truly needed, use a polling-based wait that asserts a condition holds for a duration.
- **Waiting for async side-effect**: Use a polling-based wait with a timeout and assertion (the standard async wait pattern).

### Time-Dependent Behavior
**NEVER mutate storage data to simulate time passing.** Use a test clock and advance it instead. For example, to expire a session: create it normally (30-day expiry), then advance the clock past expiry. Directly overwriting entities with past timestamps couples tests to internal storage structure and misrepresents how the system actually works.
