# Test Review Patterns (Universal)

Reference material for the test-review agent: anti-patterns, assertion rules, and review output format.

Tech-specific code examples (BAD/GOOD with language syntax) are in `.claude/tech/{backend}/templates/testing/test-review-patterns.md`.

## Anti-Pattern Catalog

Each entry names a smell the reviewer must detect. Tech templates provide BAD/GOOD code examples for each.

1. **Infrastructure leaking into test class** -- test class calls mocks, clients, or adapters directly instead of hiding behind Statements DSL.
2. **Setup step visible in test DSL** -- test class exposes infrastructure setup as a separate step instead of merging into a compound given-phase method.
3. **Scope builder/factory in test class** -- test class constructs test data via Scope objects instead of hiding behind Statements.
4. **Private function or inner type in test class** -- test class has private helpers or inner types that belong in Statements.
5. **Direct usecase call in test class** -- test class calls usecase directly instead of through Statements.
6. **Loose string validation** -- asserts on raw strings for structured data instead of parsing then asserting fields.
7. **Multiple contains/toContain chains** -- validates substrings separately instead of parsing into typed fields.
8. **startsWith/prefix check without verifying content** -- checks prefix but not the actual data after it.
9. **Pattern match without verifying values** -- validates regex shape but not actual data.
10. **Existence-only check when value is known** -- uses defined/notNull/truthy check when the expected value is deterministic.
11. **Existence check for values capturable from setup** -- setup creates known data but assertion only checks existence, not exact match.
12. **Missing field assertions** -- response has N fields but only a subset are checked.
13. **Empty collections in expected values** -- asserts empty list when actual data should be present.
14. **Timestamp without time comparison** -- checks existence or ordering of timestamps without verifying the actual value.
15. **Relative comparison when exact value is deterministic** -- uses greater-than/less-than/range when the exact value is known from setup.
16. **Truthy/falsy instead of exact value** -- checks truthiness rather than the specific expected content.
17. **Range check when exact value is deterministic** -- validates a range but not the expected exact value.
18. **Contains on collection instead of exact match** -- checks one element exists without verifying the complete list.
19. **Asserting only first item in collection** -- verifies only index 0 when setup produces N items.
20. **Asserting only IDs without full object contents** -- checks identifier but not all fields of the domain object.
21. **Wildcard/any in mock when exact value is known** -- mock accepts any argument instead of matching the exact expected value.
22. **Any assertion in test class** -- even a single assertion call is non-DSL code in the test class; all assertions belong in Statements.
23. **Action + assertion combined in one Statements method** -- method calls usecase AND asserts, combining When + Then. Split into action (stores result) + assertion (verifies it).
24. **Storage port injected in Statements** -- Statements reads/writes storage directly instead of going through usecases. Only external-service Fakes are OK.
25. **Duplicating assertion logic from another Statements class** -- repeats assertions that already exist in another Statements instead of delegating.
26. **Cross-Statements data passing in test class** -- test builds/fetches data from one Statements and passes to another instead of using compound methods.
27. **Decomposed call when compound method exists** -- uses decomposed calls when an existing compound method already wraps them.
28. **In-app URL navigation in Selenium tests** -- uses direct URL navigation instead of clicking through UI. `driver.get()` only for app root and external entry points.
29. **Not-implemented marker in Statements method** -- Statements stubbed like production adapter. Statements are test infrastructure; write real implementation in RED.
30. **Selenium assertion shallower than spec** -- assertion checks parent count but not sub-elements that the spec requires.
31. **Unreferenced domain classes/fields from RED** -- domain stubs contain fields/classes not referenced by any test or Statements.
32. **Sequential per-field assertions replaceable by recursive comparison** -- 2+ consecutive `assertThat(obj.getX())` calls on the same object when a single recursive/structural comparison would be shorter and give better diffs.
33. **Null assertion on domain value object field** -- test asserts `isNull()` on a domain entity or value object field. Domain is null-free; the VO should use empty string, Optional, or Null Object. Fix the domain model and update the assertion.

## Assertion Rules

1. **Parse before assert** -- never assert on raw strings for structured data
2. **One field per assertion** -- easier to debug failures
3. **Assert ALL fields** -- every response field must be validated
4. **Verify actual content** -- never use pattern/prefix matching when exact values are known
5. **No existence-only checks** -- replace with exact equality when expected value is deterministic
6. **No empty collections** -- if a field should have values, assert the actual expected values
7. **Exact collection match** -- use exact list equality, not element containment
8. **Timestamp precision** -- truncate to minutes for now-based comparisons
9. **Define expected constants** -- create named constants for all expected values
10. **Use exact mock matching** -- verify with exact argument matching, not wildcards
11. **No infrastructure in test classes** -- test classes must NEVER call mocks, clients, or adapters directly
12. **No assertions in test class** -- ALL assertion calls must live in Statements methods
13. **No calculations in expected values** -- tests must be dumb, assert predefined constants
14. **Minimize loops and conditionals in Statements** -- acceptable for bulk data, unacceptable for computing expected values
15. **No storage ports in Statements** -- use usecases to verify state, not storage queries
16. **Separate action from assertion** -- a Statements method must not call usecase AND assert in the same body
17. **No setup steps in test DSL** -- merge setup into compound given-phase method
18. **No cross-Statements data passing** -- extract compound methods instead
19. **Use existing compound methods** -- search before writing decomposed calls
20. **No in-app URL navigation in Selenium** -- `driver.get()` only for app root and external entry points
21. **No not-implemented markers in Statements** -- Statements are test infrastructure, write real implementations in RED
22. **Selenium assertions must match spec depth** -- verify sub-elements, not just parent count
23. **No middleman delegators between Statements** -- test injects focused Statements directly
24. **No private members in test class** -- zero private functions, interfaces, or inner types
25. **No unreferenced domain classes/fields from RED** -- every class/field must be referenced by test or Statements
26. **Assert ALL items in a collection** -- if setup produces N items, assert every item
27. **Assert full object contents, not just IDs** -- verify all fields of domain objects
28. **Prefer recursive comparison over sequential per-field assertions** -- when 2+ consecutive assertions target fields of the same object, replace with a single recursive/structural comparison call
29. **No null assertions on domain VO fields** -- domain is null-free; `isNull()` on a VO field means the domain model is wrong, not the test

## Assertion Improvements (Concept Level)

| Before (Loose) | After (Strict) |
|----------------|----------------|
| String containment on JSON | Parse, assert field equality |
| Regex match on body | Parse, assert exact token/value |
| String containment on response | Parse, assert field by ID |
| Prefix check on header | Parse auth type, assert equality |
| Prefix check on masked value | Assert full masked string with expected suffix |
| Existence/defined check | Assert exact expected value |
| Truthiness/non-blank check | Assert exact expected message |
| Greater-than/range check | Assert exact value (if deterministic) |
| Collection containment | Assert exact expected list |
| Empty collection | Assert actual expected collection |
| Timestamp existence check | Truncate to minutes, assert equality |
| Relative timestamp comparison | Compute exact period and assert |
| Partial field check (3 of 6) | Check ALL fields of the response |
| Wildcard/any in mock setup | Exact argument matching |
| Infrastructure call in test class | Hide behind Statements DSL method |
| Assert only first collection item | Assert every item: index 0 through N-1 |
| Assert only ID of domain object | Assert all fields: ID, title, status, assignee, etc. |
| Scope/builder in test class | Hide behind Statements method |
| Direct usecase call in test class | Wrap in Statements method |
| Any assertion in test class | Move to Statements assert method |
| Cross-Statements data passing | Extract compound on owning Statements |
| Decomposed call when compound exists | Use existing compound |
| Selenium: assertion checks only count | Find sub-elements and assert each |
| Selenium: direct URL navigation | Navigate via UI click |
| Not-implemented marker in Statements | Write real implementation with locators, waits, assertions |
| Action + assertion in one method | Split: action method (stores result) + assertion method |
| Storage port in Statements | Replace with usecase query |
| Middleman Statements delegation | Test injects Statements directly |
| Private function/type in test class | Move to Statements |
| Domain class/field not referenced by test | Remove -- RED creates only current test's slice |
| 2+ sequential per-field assertions on same object | Build expected object, use recursive/structural comparison |
| `isNull()` on domain VO field | Fix domain model (reject null, use Optional/empty), update assertion to match |

## Output Summary Format

```
## Test Review Summary

**Files reviewed:**
- `path/to/TestFile`

**Issues found:**
1. Line N: `<loose assertion>` - description
2. ...

**Changes made:**
1. Description of fix
2. ...

**Test result:** All tests still pass

**Before:**
```
<loose code>
```

**After:**
```
<strict code>
```
```
