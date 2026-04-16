# Mandatory Scan Checklist

**Run EVERY check on the target file. Show results. Fix violations before declaring clean.**

Skip checks marked with a file-type tag that doesn't match the target file.

## Section A: Structural scan (enumerate)

Produce structural data. Violation is numeric/objective.

**Class size & responsibility:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A0 | Class size & concerns | Total source lines (excluding imports/package), implemented interfaces/ports, distinct method groups (methods that don't call each other and serve different concerns) | >200 lines OR 2+ unrelated interfaces |

**Complexity:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A1 | Method sizes | Every method with source line count (count from opening `{` line to closing `}` line inclusive — use the file's line numbers, e.g. L48–L71 = 23 lines) | > 10 lines |
| A2 | Nesting depth | Methods with control flow nesting (`if`, `for`, `while`, `try`, `switch`, lambda) | > 1 level |
| A26 | If/return vs switch | Methods with 3+ `if (x === 'constant') return` lines branching on the same variable | Any — replace with `switch` |

**Data ownership:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A3 | Feature envy | Per method: external objects with field accesses, grouped by object | 2+ accesses from same external object |
| A4 | Getter chains | Chained method calls through different objects | 3+ levels deep |

**Optional:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A5 | Optional handling | Every Optional variable with its handling pattern | Any `isPresent()`/`get()` pair |
| A5b | Nullable request fields | Fields in usecase request DTOs that are nullable instead of `Optional` with `@Builder.Default Optional.empty()` | Any nullable filter/parameter field in a request DTO (adapters wrap nulls at the boundary) |

**Repetition:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A6 | Repeated construction | `.builder()` or `new Type(...)` calls, grouped by type | Same type constructed 2+ times |
| A7 | Repeated expressions | Same sub-expression appearing in multiple places | 2+ occurrences |
| A7b | Near-duplicate blocks | Code blocks with identical structure but different literal values (same JSON template with different `status`/`amount`, same WireMock registration with different body). Group by structure, list the differing literals. | 2+ blocks sharing structure |

**Variables & lambdas:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A8 | Local variables | ALL local variables (single-use and multi-use). Classify each as *pass-through* (simple delegation used once: `var x = obj.field()`, `var x = privateMethod()`, `var x = staticMethod()` — the key is no injected dependency involved) or *computation* (conditional, ternary, multi-step expression, stream pipeline — any use count) or *side-effect isolation* (any call to an injected dependency — usecase, port, repository, API client — regardless of verb, whose result feeds a pure return/mapping). Only injected fields count as dependencies — private/static methods on the same class are NOT side-effecting. | Any local that is not side-effect isolation. Single-use pass-through → inline variable. Computation (any use count) → extract private method. **Side-effect isolation → KEEP** (never inline). |
| A9 | Lambda → method ref | Lambdas that delegate to a single constructor or method call | `x -> new Foo(x)`, `x -> bar(x)` |
| A32 | Inlined dependency calls | Calls to injected dependencies (usecase, port, repository, API client) nested inside expressions (return statements, method arguments, DTO factory calls) instead of isolated in their own local variable. Any call to an injected field is side-effecting regardless of verb — `getTasksByColumn()` hits the DB just like `save()` does. | Any dependency call nested inside another expression → extract to local variable |
| A25 | Replace Loop with Pipeline | For-loops over collections that can be replaced with stream pipelines (`forEach`, `map`, `filter`, `collect`, `reduce`, `anyMatch`, etc.). Includes loops that accumulate into a list, filter by condition, or transform elements. | Any for-loop replaceable by a collection pipeline |
| A27 | Inline multi-step pipeline | Stream/async pipelines (`IntStream.range().mapToObj().toArray()`, `.stream().map().filter().collect()`) written inline in a method that also does other work | Any inline pipeline with 2+ chained transformations in a method with other logic |
| A28 | Functional factory method | Methods returning `Runnable`, `Supplier`, `Callable`, or other functional interfaces where the body is a lambda wrapping imperative code | Any `return () -> { ... }` or `return () -> expr` |
| A29 | Commented sections | Comments followed by a code block followed by a blank line — each is a named concern that should be extracted | Any `// comment` + code block + blank line pattern |
| A30 | Blank line wrapped sections | Code blocks surrounded by blank lines without comments — each is an unnamed concern that should be extracted | Any blank line + code block + blank line pattern |
| A45 | Sequential independent blocks | Methods with 2+ sequential operations that don't share intermediate state and each handle a distinct concern (e.g., validate page, validate size, validate date range). Count independent blocks even without comments or blank lines separating them. | 2+ independent blocks in one method — extract each into a named method |

**Indirection:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A20 | Thin wrappers | Methods whose entire body is a single delegation to another method in the same class, passing only constants/hardcoded values. List each wrapper → target method + hardcoded args. | Any delegate-only method |
| A21 | Single-value parameters | Parameters that receive the same argument at every call site. For each method parameter, grep all callers. | Parameter always receives one value |
| A55 | Parameter derivable from sibling parameter | For each method with 2+ parameters of related types, check if any parameter's value is accessible from another parameter (e.g., `method(Task original, Title title)` where `title == original.getTitle()`). List the derivable parameter and the accessor path. | Any parameter obtainable from a sibling → remove it, use the accessor inside the method |

**Polymorphism & type dispatch:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A46 | `instanceof` in domain/usecase | Grep `instanceof` in domain and usecase source files. List each occurrence with file and line. | Any `instanceof` in domain or usecase → push behavior onto interface method, dispatch polymorphically |
| A47 | Re-partitioned base lists | `List<SealedBase>` or `List<InterfaceType>` that gets filtered/partitioned with `instanceof` downstream. List the field type and the instanceof filter location. | Any → replace with typed lists at creation time |
| A48 | Interleaved computation + side effects | Methods that alternate between computing results and calling external services (API, storage). List the interleaved calls. | Any → compute all results first, then try side effect, return original or error-mapped results |

**Cohesion & parameter groups:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A49 | Bloated entity / value object | Count fields. For each method, list which fields it accesses. Group fields by co-access patterns. | 10+ fields AND methods that use only a subset → extract cohesive value object for the field cluster |
| A50 | Repeating parameter group | Factory methods / constructors with 3+ parameters that appear together across 2+ call sites. List the repeated group. | Any → extract parameter object (record) and overload to accept it |
| A51 | External record rebuild | Code that constructs a new record/VO from an existing one, changing only 1-2 fields (copy all fields, override some). List the reconstruction site and the changed fields. | Any → add `toX()` transform method on the record itself |

**Usecase design** (skip if not a usecase class):

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A35 | Sequential storage port queries | Count injected storage/repository port fields. For each, check if data from one port feeds queries to another (N+1 pattern: fetch list → per item: fetch related data from another port). | 2+ storage ports queried sequentially — enrich aggregate, single port fetches everything upfront |

**Storage adapter design** (skip if not a storage adapter class):

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A33 | Manual row grouping | See tech binding for ORM-specific patterns (grouping utilities, intermediate DTOs) in storage methods | Any manual row assembly — delegate mapping to ORM with proper entity relationships |
| A34 | Multi-repository injection | Count repository/data-access fields injected into a single storage class (see tech binding for patterns) | >1 repository dependency — consolidate into single query |
| A42 | Static query utility | Static class with methods that take a query/filter object and return framework query objects (see tech binding for patterns) | Any static utility building queries from a query object → move to adapter query class extending the port query |
| A43 | Untyped array query results | Index-based access to untyped query results (see tech binding for patterns) | Any → extract typed projection class with `toDomain()` |
| A44 | Inline query building in storage | Storage methods that build query/filter/pagination objects inline (see tech binding for patterns). Count lines of query-building logic vs actual storage work. | >5 lines of query building → extract AdapterQuery class extending port query |

**Imports:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A10 | Enum qualification | Enum constants used with class prefix in logic (not import lines) | Any `EnumClass.VALUE` |
| A36 | Repeated FQN | Fully-qualified class names (`com.foo.Bar`) appearing 2+ times in logic (not import lines). When the short name collides with an inner class, rename the inner class and import the external one. | Any FQN used 2+ times |

**Dead code:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A11 | Unused code | Private methods/fields with no call site in the file | Any unreferenced private member |
| A11b | `// Unreachable` markers | Grep `// Unreachable` in the file. These are dead code branches flagged by the coverage agent. | Any match → remove the dead branch and simplify the surrounding condition |

**Type safety:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A12 | Raw map usage | `Map.of(`, `Map<String, Object>`, `Map<String, String>` in production code | Any map standing in for typed data |
| A13 | Null/default args | Constructor, `of()`, `from()` calls listing arguments | Any null/default argument |
| A13b | Nullable domain value object | Domain value object constructor that accepts null (e.g., `if (value != null` guard instead of rejecting null). Also: domain entity fields typed as a value object but allowed to be null at construction time. | Any null-accepting constructor or nullable VO field in domain — use empty string, Optional, or Null Object pattern per `coding-rules.md` "No nulls in domain" |

**Sibling duplication** (any class extending a base or implementing same interface):

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A14 | Sibling duplication | Fields and methods appearing in 2+ sibling classes — read ALL siblings | Same member in 2+ siblings |

**Cross-class duplication** (not siblings — structurally identical but unrelated classes):

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A22 | Structurally identical classes | For each Fake or port interface, grep for other classes with identical method signatures and field structures. Example: `FakeTaskCreatedNotificationSender` and `FakeTaskMovedNotificationSender` both have `List<String> sentEmails` + `void send(String)`. | 2+ classes with identical structure → extract base class |
| A52 | Manual per-field assertion | Methods with 2+ sequential `assertThat(obj.fieldX())` lines comparing two objects field-by-field, or `assertAllFields`-style helpers. List the method name and field count. Classify each field: exact-match, non-deterministic (isNotNull/isNotEmpty), null-check, or custom (timestamp truncation, range). | All fields exact-match → `usingRecursiveComparison().isEqualTo(expected)`. Mixed strategies (some non-deterministic/null/custom) → extract reusable assertion helpers as private methods (HTTP status, timestamp, error structure), keep field-specific assertions in the parent. See `recursive-comparison.md` for decision guide. |
| A54 | Test helper duplicates production method | For each private/package method in the test class, check if a production class used in the test has a method with identical logic (same stream/filter/find pattern, same computation). Compare the test helper's body against methods on the objects it operates on — including private methods that could be made public. | Any match → make the production method accessible (public or package-private), delete the test helper, call the production method instead |
| A23 | Cross-Statements assertion duplication | For each `assert*` method in the target Statements class, grep all other `*Statements.java` for methods asserting the same domain concept (same response fields, same status checks). Example: asserting `in_progress` status + `assignee` + `priority` when `GetTaskStatusStatements.assertInProgressTask()` already exists. | Same domain assertion logic in 2+ Statements → delegate to existing Statements |
| A24 | Assertions in test class | Grep `assertThat\|assertThatThrownBy` in test class (not Statements). Example: `assertThatThrownBy(...)` or `assertThat(response.field())` directly in a test method instead of `statements.assertX(response)`. | Any assertion in test class → move to Statements method |
| A37 | Control flow in test class | Grep `for \|for(\|while \|while(\|if \|if(` in test methods (not Statements, not base class helpers). Example: `for (int i = 0; i < 10; i++) { statements.assertField(i); }` directly in a test method. | Any loop or conditional in test class → extract to Statements method |
| A41 | Loops/conditionals computing expected values in tests | Grep `for \|for(\|if \|if(` combined with assertion or expected-value derivation in Statements. Loops for bulk data generation or collection assertions are fine. Example violation: `if (total > pageSize) { expected = total % pageSize; }` | Loops/conditionals that compute expected values or make branching assertions are production logic leaking into tests → replace with literal constants |
| A31 | Statements dependency count | Count `private final` fields in a Statements class — each is an injected dependency (usecases, other Statements, Fakes, Clock) | >8 dependencies → split Statements by concern |
| A38 | Middleman delegators between Statements | Methods in a Statements class whose entire body delegates to an injected Statements dependency (e.g., `void assertX() { otherStatements.assertX(); }`). List each wrapper → target Statements + method. | Any pass-through → remove method, have tests inject the target Statements directly |
| A39 | Implementation constants in test class | Grep for numeric literals (`\d+L`), `BigDecimal.valueOf`, `new .*Request`, technical constants (task IDs, column IDs, positions, offsets) passed as arguments to ANY Statements call (setup, action, or assertion) in test methods. Compare with the `@Description` — test code should match its Gherkin abstraction level. | Any implementation constants in test class → encapsulate inside the Statements method, return a record with values needed by subsequent calls. |
| A40 | Calculated expected values in tests | Grep `Math\.\|ceil\|floor` and arithmetic (`+`, `-`, `*`, `/`) used to compute expected assertion values from runtime data in Statements or test classes. Example: `int expectedSize = (int) (totalElements - (lastPageNum - 1) * pageSize)`. | Any formula computing an expected value → tests must be dumb. Fix setup to produce deterministic data, then assert with literal constants. |
| A53 | Null assertion on domain VO field | Grep `isNull()` in Statements/test. For each match, check if the asserted expression traverses a domain entity or value object (e.g., `task.getDescription().getValue()`). | Any `isNull()` on a domain VO field → domain is null-free; fix the VO to reject null (empty string / Optional / Null Object), update assertion to match |

**Frontend-specific** (skip if not `.tsx`):

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A15 | Component size | JSX return block line count | > 100 lines |
| A15b | Distinct visual blocks | Count top-level sibling JSX sections in return (e.g., header div, warning banner, stats grid, content card). Each block has its own data/props with no cross-block shared state. | 3+ separable blocks → extract each into its own component file, even if total lines < 100 |
| A16 | Return branches | `return` statements with JSX in component function | 2+ return blocks with JSX |
| A17 | Logic in component | Validation, computation, `fetch` calls inside `.tsx` | Any business logic or fetch |
| A18 | Render body locals | Computed local variables declared inside component before return | Any computed local |
| A19 | Repeated class strings | `className` values appearing 2+ times across JSX | Any repeated className string |
| A46 | Opaque Tailwind chains | **MUST grep first:** run `Grep pattern="\[#[0-9a-fA-F]" path="<target-file>" output_mode="content"` and paste ALL matching lines with line numbers. Then for each `className`, count utilities with arbitrary values (`[#hex]`, `[Npx]`, `[N.Nrem]`). Also read `frontend/src/styles/theme.css` `@layer components` to check which patterns already have semantic classes. | Any className with 1+ arbitrary-value utilities not already covered by a `theme.css` class → extract to `@apply` in `theme.css`. A single `bg-[#f1f3f5]` is already opaque — extract it. List each: line number, current chain, proposed class name. |
| A47 | Repeated conditional className | Same conditional className expression (ternary, logical AND, template literal with conditions) appearing in 2+ JSX elements, branching on the same variable to select classes. Example: `isActive ? 'bg-blue-500 text-white' : 'bg-gray-200'` repeated across elements. | 2+ occurrences → extract into a helper function (e.g., `getStatusClassName(status)`) above the component |

## Section B: Read-and-judge (cite evidence)

Read the code. Answer the question. **Cite the code snippet as evidence, or write "none found."** No bare "clean" allowed.

**Domain modeling:**

| # | Question | Evidence required |
|---|----------|------------------|
| B1 | Are there `String`/`int`/`long`/`UUID` parameters or fields that represent domain concepts (email, token, userId, amount)? | Quote the declaration |
| B2 | Are there String constants or parameters representing a fixed domain set (status, plan, type, period)? | Quote the usage |
| B3 | Are there persisted fields that could be computed from other fields in the same entity? | Quote the field + the fields it derives from |

**Behavior placement:**

| # | Question | Evidence required |
|---|----------|------------------|
| B4 | Is there validation logic in the wrong layer (usecase validating domain rules, controller with business logic)? | Quote the validation code |
| B5 | Does a caller check an object's fields then throw an exception? | Quote the `if` + `throw` block |
| B6 | Is there serialization, hashing, or formatting done outside the data object that owns the fields? | Quote the caller code |
| B7 | Are there consecutive find + validate sequences guarding the same concern? | Quote the guard block |
| B8 | Does a parent entity remove/add children in a collection directly instead of delegating to the child? | Quote the remove/add calls |
| B9 | Does a controller return a raw usecase/domain object without REST DTO wrapping? | Quote the return statement |

**Test-specific** (skip if not a test file):

| # | Question | Evidence required |
|---|----------|------------------|
| B10 | Do test helper methods use hardcoded values that should vary per test? | Quote the hardcoded value |
| B11 | Does the test create an object only to pass it to a single Statements method for assertion? | Quote the create + pass |

**Frontend-specific** (skip if not `.tsx`):

| # | Question | Evidence required |
|---|----------|------------------|
| B12 | Is this component generic enough to be reused across features? Should it live in `app/components/ui/`? | Quote the component's props and usage |

## Scan output format

**Print this filled checklist before starting refactoring.**

**Enumeration rule:** Every check that says "enumerate", "list", "count", or "for each" MUST show the enumerated data — even when clean. Write `→ clean` after the data shows no violation. Bare `[clean]` is only allowed for: (1) file-type skips (`[storage — skipped]`, `[frontend — skipped]`), (2) judgment checks (Section B) where the answer is "none found."

```
### A. Structural
A0.  Class size: 85 lines, 1 interface, 1 concern → clean
A1.  Method sizes: methodA=7, methodB=9 → clean
A2.  Nesting depth: methodA=0, methodB=1 → clean
A3.  Feature envy: methodA reads self only; methodB reads order.{amount, currency} → VIOLATION
A4.  Getter chains: methodB: order.getItems().get(0).getPrice() → VIOLATION
A5.  Optional handling: none → clean
A6.  Repeated construction: TaskRequest.builder() ×2 → VIOLATION
A7.  Repeated expressions: toDo.getTasks() ×2 (L47, L48) → VIOLATION
A7b. Near-duplicate blocks: stubSucceeded ≈ stubCanceled → VIOLATION
A8.  Locals: orderId (pass-through, 1 use) → inline; result (side-effect) → KEEP
A9.  Lambda→ref: L55 x -> new Foo(x) → VIOLATION
A10. Enum qualification: TaskStatus.DONE L30 → VIOLATION
A11–A14. Null args L18 → VIOLATION; sibling duplication → VIOLATION; rest: none found
A20. Thin wrappers: none → clean
A21. Single-value params: process(type) — all callers pass "EMAIL" → VIOLATION
A55. Derivable params: assertRoundTrip(actual, original, title, desc) — title=original.getTitle(), desc=original.getDescription() → VIOLATION
A25–A32. Inlined dep call L30 → VIOLATION; rest: none found
A33–A34. [storage — skipped]
A42–A44. [storage — skipped]
A45–A48. [polymorphism — skipped if not domain/usecase]
A49–A51. Bloated entity: 5 fields → clean; repeating params: none → clean; external rebuild: none → clean
A52–A53. [test-specific checks if applicable]
A15–A19. [frontend — skipped]

### B. Judgment
B1.  Primitive obsession: `String email` in RegisterRequest L12 → VIOLATION
B2–B4. [clean]
B5.  Caller checks+throws: task null check L25-28 → VIOLATION
B6–B9. [clean]
B10. Hardcoded helpers: givenUser() uses "test@example.com" L44 → VIOLATION
B11–B12. [clean]
```
**If any item has a violation, fix it BEFORE reporting "no issues."**

## Code Smells Routing Table

All templates live in `.claude/templates/refactoring/`.

### Backend Code Smells

| Smell | Fix | Template |
|-------|-----|----------|
| Primitive obsession (raw string for email, ID, etc.) | Replace Primitive with Value Object | `value-object.md` |
| Validation logic in usecase | Move to Value Object | `value-object.md` |
| Duplicate test setup (2+ sibling classes sharing a base) | Pull Up Field/Method to Base Class | `test-base-class.md` |
| Constructor with many null args | Extract Factory Method | `factory-method.md` |
| Caller checks fields then throws | Encapsulate Conditional | `encapsulate-conditional.md` |
| String literals for fixed set (status, plan, type) | Replace String with Enum | `replace-string-with-enum.md` |
| Persisted field derivable from other fields | Remove Field, Compute Instead | `computed-field.md` |
| Hardcoded values in test helpers | Parameterize Helper | `parameterize-helper.md` |
| Test passes data create->assert | Inline into Statement | `inline-test-params.md` |
| Untyped map/dict as API request body | Replace Map with Typed DTO | `replace-map-with-dto.md` |
| Controller returns raw usecase object | Wrap in REST DTO | `rest-response-dto.md` |
| Qualified enum references in logic | Import enum values to avoid qualified references (see tech binding) | `simplify-expressions.md` |
| Nested conditionals with early return | Flatten to if/return chain | `flatten-control-flow.md` |
| `if/return` chain branching on one variable against constants | Replace with `switch` | `flatten-control-flow.md` |
| Repeated expression representing a concept | Extract named computation method | `extract-method.md` |
| Lambda reducible to method/constructor reference | Simplify lambda to reference | `simplify-expressions.md` |
| Caller constructs DTO from source object fields | Add `from()` factory on DTO, use method ref | `move-to-data.md` |
| Usecase has private helpers converting request fields | Move conversion to request DTO (`fromInstant()`, `parsedActionType()`) | `move-to-data.md` |
| Nullable filter fields in request DTO | Replace with optional type + default empty value | `move-to-data.md` |
| Nullable domain value object (constructor accepts null, or entity field is nullable VO) | Reject null in constructor, use empty string / Optional / Null Object at domain boundary | `value-object.md` |
| Storage manually groups/assembles rows (grouping, intermediate DTOs) | Delegate mapping to ORM -- use proper entity relationships | `subselect-read-model.md` |
| Storage injects multiple repositories | Consolidate into single query | `subselect-read-model.md` |
| Usecase injects 2+ storage ports queried sequentially | Enrich aggregate, single storage port fetches everything upfront | `subselect-read-model.md` |
| Static utility class builds query criteria from query object | Move to adapter query class extending port query | `adapter-query.md` |
| Untyped array / tuple query results with index-based access | Extract typed projection class with `toDomain()` | `adapter-query.md` |
| Storage method has inline query building + criteria + result mapping | Extract AdapterQuery that owns `filters()`, `pageRequest()`, `summary()` | `adapter-query.md` |
| Type-checking/type dispatch in domain or usecase (see tech binding for keywords) | Push behavior onto interface method -- callers call polymorphically, adapters dispatch at boundary | `move-to-data.md` |
| Base-type list re-partitioned with type checks (see tech binding) | Replace with typed lists -- store what you know at creation time | `move-to-data.md` |
| Computation interleaved with side effects | Compute results upfront as immutable list, wrap side effect in try/catch, return original or error-mapped | `move-to-data.md` |
| Entity with 10+ fields, methods use only a subset | Extract cohesive value object for the field cluster | `move-to-data.md` |
| 3+ parameters repeated across multiple factory methods | Extract parameter object (immutable data class -- see tech binding), overload factories to accept it | `move-to-data.md` |
| External code rebuilds immutable data class changing 1-2 fields | Add `toX()` transform method on the class itself | `move-to-data.md` |
| Feature envy | Move method to data owner | `move-to-data.md` |
| Serialization/hashing outside DTO | Move `toJson()`, `computeSignature()` into DTO | `move-to-data.md` |
| Getter chain `a.getB().getC().toString()` | Extract convenience method on `a` | `move-to-data.md` |
| Caller builds raw data from object then passes both | Let object carry its own derived data | `move-to-data.md` |
| Repeated `Builder.builder()...build()` in caller | Extract factory method on data class | `move-to-data.md` |
| Sequential guards for one concern (find + validate) | Extract void guard method | `extract-method.md` |
| Test helper duplicates production method (same logic exists on the object under test) | Make production method public, delete test duplicate | (inline -- make accessible + delete) |
| Duplicate code | Extract Method | `extract-method.md` |
| Near-duplicate blocks (same structure, different literals) | Parameterize differences + Extract Method | `extract-method.md` |
| Thin wrapper (delegates to another method with only constants) | Inline Method -- push args to callers, delete wrapper | `simplify-expressions.md` |
| Single-value parameter (all callers pass same value) | Remove Parameter -- inline the constant | `simplify-expressions.md` |
| Parameter derivable from sibling parameter (value accessible via another param's accessor) | Remove redundant parameter, use accessor inside method | `simplify-expressions.md` |
| Unused code | Delete it | (inline -- just delete) |
| `// Unreachable` comment (left by coverage agent) | Remove the dead code branch and simplify the condition | (inline -- delete branch, simplify) |
| Long method (>10 lines) | Extract private methods per concern | `extract-method.md` |
| Commented block sections (`// comment` + code + blank) | Extract each block, use comment as method name | `extract-method.md` |
| Blank line wrapped sections (blank line + code + blank) | Extract each block, derive method name from purpose | `extract-method.md` |
| Sequential independent blocks (3+ small operations, no shared state, each a distinct concern) | Extract each block into named method -- parent becomes table of contents | `extract-method.md` |
| Single-use local: simple pass-through (accessor result used once, NOT a call to an injected dependency) | Inline variable | `simplify-expressions.md` |
| Inlined dependency call (usecase/port/repo call nested inside return or method arg) | Extract variable to isolate side effect | `simplify-expressions.md` |
| Local variable holding computation (any use count -- single or multi-use) | Extract private method | `extract-method.md` |
| Repeated fully-qualified names (2+ times in logic) | Import + rename colliding types | `simplify-expressions.md` |
| For-loop replaceable by collection pipeline | Replace Loop with Pipeline (see tech binding for terminal operations) | `simplify-expressions.md` |
| Inline multi-step pipeline in method with other logic | Extract pipeline to named method | `extract-method.md` |
| Method returns functional wrapper (callback, supplier) wrapping imperative body | Unwrap to direct method, caller wraps at call site | `simplify-expressions.md` |
| Optional check-then-unwrap pattern | Use monadic operations (map/flatMap/filter/orElse) | `flatten-control-flow.md` |
| Parent removes/adds child in collection | Delegate mutation to child entity | `flatten-control-flow.md` |
| Large class (>200 lines) or class with multiple concerns or 2+ unrelated interfaces | Split Class + Extract Superclass | `extract-class.md` |
| Manual per-field assertion — all fields exact-match (2+ sequential field assertions -- see tech binding) | Replace with recursive/structural comparison | `recursive-comparison.md` |
| Manual per-field assertion — mixed strategies (non-deterministic IDs, null checks, timestamp truncation) | Extract reusable assertion helpers as private methods; keep field-specific assertions in parent | `recursive-comparison.md` + `extract-method.md` |
| Sibling production classes sharing fields/methods | Extract Superclass | `extract-class.md` |
| Statements class with >8 injected dependencies | Split Statements by concern | `extract-class.md` |
| Statements method that only delegates to another injected Statements | Remove middleman -- tests inject target Statements directly via base class | `simplify-expressions.md` |
| `isNull()` assertion on domain VO field in test | Fix domain model — reject null in VO constructor (empty string / Optional / Null Object), update assertion | `value-object.md` |

### Frontend Code Smells

| Smell | Fix | Template |
|-------|-----|----------|
| Large page component (>100 lines JSX) | Extract Field/Section Component | `extract-component.md` |
| 3+ distinct visual blocks in JSX (even under 100 lines) | Extract each block into its own component -- page becomes thin orchestrator | `extract-component.md` |
| Two UI branches in one component (`if/return` + `return`) | Extract each branch as a View component | `extract-component.md` |
| Computed locals cluttering render body | Extract as private functions above component | `extract-component.md` |
| Component reused across features | Move to Shared UI | `extract-shared-ui.md` |
| Business logic in `.tsx` | Move to `.logic.ts` | (inline -- just move) |
| Inline fetch in `.tsx` | Move to `.api.ts` | (inline -- just move) |
| Duplicate JSX across fields | Extract parameterized component | `extract-component.md` |
| Inline styles/class strings repeated | Extract to constants file | (inline -- just extract) |
| Repeated conditional className (ternary/AND branching on same variable in 2+ elements) | Extract helper function above component | (inline -- just extract) |
| Opaque Tailwind chain (1+ utilities with arbitrary values like hex colors, pixel sizes, shadows) | Extract to semantic `@apply` class in `theme.css` | `extract-tailwind-class.md` |
| Long MSW API test (>10 lines) | Extract fixtures, stub helpers, assertion helpers | `extract-test-fixture.md` |
