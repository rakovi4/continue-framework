# Test Review Mandatory Checklist

Run EVERY check below on the test class file. Paste results. Fix violations before reporting.

The **Cl** (cluster) column routes each check to the detector agent that owns it.
Each detector runs ONLY its cluster's rows — the table stays the single source of
truth, so check definitions never drift across agents:

| Cl | Detector agent | Theme |
|----|----------------|-------|
| A  | `test-review-assertions-agent` | Assertion strictness (loose→strict, field coverage, determinism) |
| P  | `test-review-placement-agent`  | Placement / DSL separation (test class vs Statements) |
| S  | `test-review-statements-agent` | Statements internal quality |
| Se | `test-review-selenium-agent`   | Selenium / spec-depth (dispatched only for selenium/frontend tests) |

| #  | Cl | Check | Grep pattern | Where | Violation if found |
|----|----|-------|-------------|-------|--------------------|
| 1  | P  | Infrastructure in test class | `stub\|Mock\|Fake\|Client\|wiremock\|ApiMock` | test class only (not Statements) | Move call to Statements |
| 2  | A  | Loose string assertions | see tech binding for patterns | Statements + Fake `verify*`/`assert*` methods | Replace with strict equality |
| 3  | A  | Range/direction checks | see tech binding for patterns | Statements + Fake `verify*`/`assert*` methods | Replace with strict equality if value is deterministic |
| 4  | A  | Loose mock matchers | see tech binding for patterns | test class + Statements | Replace with exact matchers |
| 5  | A  | Missing field assertions | (read response DTO, count fields vs assertion count) | Statements + Fake `verify*`/`assert*` methods | Add missing field assertions |
| 6  | A  | Partial collection coverage | see tech binding for patterns | Statements + Fake `verify*`/`assert*` methods | If collection has N items from stubs, assert ALL N items -- not just the first |
| 7  | A  | Shallow object assertions | (read asserted object's DTO, check if all fields are verified) | Statements + Fake `verify*`/`assert*` methods | Assert full contents (all fields), not just IDs |
| 8  | P  | Setup leak in test DSL | `\.setup\|\.prepare\|\.configure\|\.init` | test class only | Merge into compound given-phase method in Statements |
| 9  | P  | Scope in test class | `Scope` | test class only (not Statements) | Move scope construction/factory into Statements |
| 10 | P  | Direct usecase calls | (read test body: any call not through `*Statements`) | test class only | Wrap in Statements method |
| 11 | S  | Cross-Statements assertion duplication | For each `assert*` method: grep all Statements files for methods asserting the same domain concept | all Statements in module | Delegate to existing Statements instead of duplicating |
| 12 | P  | Assertions in test class | see tech binding for assertion library patterns | test class only | Move ALL assertion code to Statements -- test class must contain zero assertions |
| 13 | P  | Cross-Statements data passing | (read test body: any line calling `statementsA.method(statementsB.method())`) | test class only | Extract compound method on owning Statements |
| 14 | P  | Decomposed compound calls | (read test body: any multi-step call where a single compound Statements method exists) | test class only | Use existing compound method (grep Statements for combined equivalents) |
| 15 | S  | Action + assertion in one Statements method | (read each `assert*` method in Statements: does it call a usecase/API AND assert the result in the same method?) | Statements only | Split into action method (captures result/exception) + assertion method (verifies it) |
| 16 | P  | Storage port injected in Statements | `Storage\|Repository` (in constructor/fields) | Statements only | Storage ports must NEVER be injected into Statements -- not for assertions, not for setup. Setup must go through usecases. Only external-service Fakes (FakeEmailClient) are OK. NO EXCEPTIONS for read-only ports, count-only ports, aggregation ports, or ports without a write usecase -- if the implementation reads from the database, it is a storage port. Do not reclassify as "analogous to external-service Fake." |
| 17 | Se | Selenium assert method shallower than spec | (read spec's DSL Technical Reference, compare with Statements assert body) | Selenium Statements only | When spec says "cards with title, status, assignee, and priority", the assert method must verify each sub-element inside each card -- not just count cards. Cross-check every `assert*` method against the spec's DSL table to find missing sub-element assertions. |
| 18 | Se | In-app URL navigation in Selenium | `navigateTo(appUrl +\|\.get(appUrl +\|driver\.get.*"/` | test class + Statements | Replace with UI click navigation (e.g., `page.navigateToCreateItem(appUrl)` clicks a button). `driver.get()`/`navigateTo()` is only allowed for app root (`appUrl`) and external entry points (deep links, shared links). |
| 19 | S  | Not-implemented marker in Statements | not-implemented marker (see Conventions in `technology.md`) | Statements only | Statements are test infrastructure -- ALL methods must be fully functional (real locators, waits, assertions). The not-implemented marker is only for real adapter implementations. Replace with the actual implementation. |
| 20 | P  | Middleman delegators between Statements | (read each method in Statements: does it only forward to an injected Statements field?) | Statements only | Remove the wrapper method. Tests inject the target Statements directly (via test base class or dependency injection). |
| 21 | A  | Calculated expected values | see tech binding for patterns; also any arithmetic (`+`, `-`, `*`, `/`) deriving an expected assertion value from runtime data | Statements + test class | Tests must be dumb -- assert predefined constants. Fix setup to produce deterministic data, then use literals in assertions. |
| 22 | A  | Loops/conditionals computing expected values | `for \|for(\|while \|while(\|if \|if(` combined with assertion logic or expected-value derivation | Statements only | Loops for bulk data generation or collection assertions are fine. Loops/conditionals that compute expected values or make branching assertions are production logic leaking into tests -- replace with literal constants. |
| 23 | P  | Private methods or inner types in test class | see tech binding for patterns | test class only (not Statements) | Move to Statements: private helper methods become Statements methods, inner records/types become Statements return types. Test class must have zero private members. |
| 24 | S  | Unreferenced domain classes/fields from RED | (read each domain class created/modified in RED; for each field, grep test class + Statements for usage) | domain classes created in RED | Domain class or field not referenced by any test or Statements code -- remove the field (and the class if no fields remain). The ADR shows the target; RED creates only the current test's slice. |
| 25 | Se | Missing test description annotation | (read each test method: check for display annotation containing spec text) | test class only | Every test method must have a display annotation with the scenario title from the spec. Method name is a short identifier; the annotation carries the readable spec text. |
| 26 | S  | HTTP client code in acceptance Statements | see tech binding for patterns | Statements only (acceptance module) | Statements must not contain HTTP calls. Extract a `{Feature}Client` class that owns HTTP execution, URL resolution, request building, and response extraction. Statements delegates to the client. |
| 27 | A  | Sequential per-field assertions replaceable by recursive comparison | (count consecutive `assertThat(x.getY())` calls on the same object — 2+ is a violation) | Statements + Fake `verify*`/`assert*` methods | Replace 2+ sequential per-field assertions on the same object with recursive/structural comparison. Build an expected object and compare in one call. |
| 28 | A  | Null assertions on domain value object fields | `isNull()` on a domain entity or value object field (e.g., `task.getDescription().getValue()).isNull()`) | Statements + test class + Fake `verify*`/`assert*` methods | Domain is null-free (`.claude/guidelines/coding-detail.md`). If the test asserts null on a VO field, the domain model is wrong — the VO should use empty string, Optional, or Null Object. Fix the domain model and update the assertion to match. |
