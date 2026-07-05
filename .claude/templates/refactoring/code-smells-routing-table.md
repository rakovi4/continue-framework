# Code Smells Routing Table

The **serial fixer** (`refactor-agent`) owns this table. Detectors only name the
prescribed fix; the fixer maps each candidate smell to its template and applies
it. Checklist: `scan-checklist.md` (hub) + the per-cluster files `scan-mechanics.md`,
`scan-design.md`, `scan-duplication.md`.

All templates live in `.claude/templates/refactoring/`.

## Backend Code Smells

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
| Untyped JSON-tree navigation when parsing a payload (`getNode("field").asText()`, `path(...)` chains) | Replace JsonNode traversal with Typed DTO + typed deserialization | `replace-jsonnode-with-dto.md` |
| Manual text re-parsing of a structured body (splitting on `:`, regex over emitted format, line-by-line key extraction) | Replace JsonNode traversal with Typed DTO + typed deserialization | `replace-jsonnode-with-dto.md` |
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
| Usecase injects or calls another usecase | Extract shared logic into the domain (entity method, value-object behavior, stateless domain service) or a non-usecase helper at the usecase layer; delete the usecase dependency | `move-to-data.md` |
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
| Catch block whose body re-raises the same exception without transformation, fallback, or cleanup — regardless of the side effect (log, metric increment, span tag, audit write, print, no-op) | Delete try/catch, let exception propagate to centralized handler. Move cross-cutting side effects to handler/interceptor/aspect; request context lives in logger diagnostic context (MDC). | `remove-catch-and-rethrow.md` |
| Catch block on broad exception type (`RuntimeException` / `Exception` / `Throwable`) without rethrow — body logs + continues in iteration, or silently swallows without a meaningful fallback consumed downstream (best-effort iteration pattern) | Delete try/catch and let exception propagate to centralized handler / scheduled-job wrapper / message listener; OR catch a specific expected exception type with a real fallback; OR return Optional/Result from the source domain method so iteration drops failed items without try/catch | `remove-catch-and-rethrow.md` |
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
| Manual per-field assertion — subset of state fields read off an object that has a natural sibling expected in scope (just-saved entity), even with behavioral predicates interleaved | Collapse state-field assertions to `usingRecursiveComparison().ignoringFields(...).isEqualTo(sibling)`; keep behavioral-predicate assertions separate | `recursive-comparison.md` |
| Manual per-field assertion — mixed strategies (non-deterministic IDs, null checks, timestamp truncation) | Extract reusable assertion helpers as private methods; keep field-specific assertions in parent | `recursive-comparison.md` + `extract-method.md` |
| Sibling production classes sharing fields/methods | Extract Superclass | `extract-class.md` |
| Statements class with >8 injected dependencies | Split Statements by concern | `extract-class.md` |
| Statements method that only delegates to another injected Statements | Remove middleman -- tests inject target Statements directly via base class | `simplify-expressions.md` |
| `isNull()` assertion on domain VO field in test | Fix domain model — reject null in VO constructor (empty string / Optional / Null Object), update assertion | `value-object.md` |

## Frontend Code Smells

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
| Multi-utility chain (standalone className with 2+ utilities, variants included) | Extract to semantic `@apply` class in `theme.css` — readability and breakpoints don't exempt it; only a single utility or a semantic-class-plus-overrides stays inline | `extract-tailwind-class.md` |
| Long MSW API test (>10 lines) | Extract fixtures, stub helpers, assertion helpers | `extract-test-fixture.md` |
