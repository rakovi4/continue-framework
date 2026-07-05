# Scan — Cluster M: Mechanics (structural)

Part of the refactor scan, run by `refactor-mechanics-agent`. Hub + cluster
routing + output format: `scan-checklist.md`. Fix templates: `code-smells-routing-table.md`.

Produce structural data. Violation is numeric/objective.
Skip checks marked with a file-type tag that doesn't match the target file.

**Class size & responsibility:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A0 | File / class size & concerns | Total source lines (excluding imports/package), implemented interfaces/ports, distinct method groups (methods that don't call each other and serve different concerns). **Applies to every file type — for files with no classes (stylesheets, config, plain modules) count all lines.** | >200 lines OR 2+ unrelated interfaces |

**Complexity:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A1 | Method sizes | Every method with source line count (count from opening `{` line to closing `}` line inclusive — use the file's line numbers, e.g. L48–L71 = 23 lines) | > 10 lines |
| A2 | Nesting depth | Methods with control flow nesting (`if`, `for`, `while`, `try`, `switch`, lambda) | > 1 level |
| A26 | If/return vs switch | Methods with 3+ `if (x === 'constant') return` lines branching on the same variable | Any — replace with `switch` |

**Optional:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A5 | Optional handling | Every Optional variable with its handling pattern | Any `isPresent()`/`get()` pair |
| A5b | Nullable request fields | Fields in usecase request DTOs that are nullable instead of `Optional` with `@Builder.Default Optional.empty()` | Any nullable filter/parameter field in a request DTO (adapters wrap nulls at the boundary) |

**Variables & lambdas:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A8 | Local variables | ALL local variables (single-use and multi-use). Classify each as *pass-through* (simple delegation used once: `Foo x = obj.field()`, `Foo x = privateMethod()`, `Foo x = staticMethod()` — the key is no injected dependency involved) or *computation* (conditional, ternary, multi-step expression, stream pipeline — any use count) or *side-effect isolation* (any call to an injected dependency — usecase, port, repository, API client — regardless of verb, whose result feeds a pure return/mapping). Only injected fields count as dependencies — private/static methods on the same class are NOT side-effecting. | Any local that is not side-effect isolation. Single-use pass-through → inline variable. Computation (any use count) → extract private method. **Side-effect isolation → KEEP** (never inline). |
| A9 | Lambda → method ref | Lambdas that delegate to a single constructor or method call | `x -> new Foo(x)`, `x -> bar(x)` |
| A58 | Type-inference local declarations | Local variables declared with the language's type-inference shorthand instead of an explicit type (see tech binding for the keyword and policy). | Per tech binding — any occurrence where the binding forbids type inference. An inferred type forces the reviewer to derive it from the right-hand side; an explicit type is self-documenting in diffs. |
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
