# Scan — Cluster D: Design (structural + judgment)

Part of the refactor scan, run by `refactor-design-agent`. Hub + cluster
routing + output format: `scan-checklist.md`. Fix templates: `code-smells-routing-table.md`.

Two modes below. **Section A (structural):** produce numeric/objective data.
**Section B (judgment):** read the code, answer the question, and **cite the
snippet as evidence** or write "none found" — no bare "clean."
Skip checks marked with a file-type tag that doesn't match the target file.
The A46/A47/A57 here are the **backend** rows (domain/usecase source only) — the
frontend rows of the same numbers belong to cluster T.

## Section A — Structural

**Data ownership:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A3 | Feature envy | Per method: external objects with field accesses, grouped by object | 2+ accesses from same external object |
| A4 | Getter chains | Chained method calls through different objects | 3+ levels deep |

**Repetition:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A6 | Repeated construction | `.builder()` or `new Type(...)` calls, grouped by type | Same type constructed 2+ times |
| A7 | Repeated expressions | Same sub-expression appearing in multiple places | 2+ occurrences |
| A7b | Near-duplicate blocks | Code blocks with identical structure but different literal values (same JSON template with different `status`/`amount`, same WireMock registration with different body). Group by structure, list the differing literals. | 2+ blocks sharing structure |

**Polymorphism & type dispatch:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A46 | `instanceof` in domain/usecase | Grep `instanceof` in domain and usecase source files. List each occurrence with file and line. | Any `instanceof` in domain or usecase → push behavior onto interface method, dispatch polymorphically |
| A47 | Re-partitioned base lists | `List<SealedBase>` or `List<InterfaceType>` that gets filtered/partitioned with `instanceof` downstream. List the field type and the instanceof filter location. | Any → replace with typed lists at creation time |
| A48 | Interleaved computation + side effects | Methods that alternate between computing results and calling external services (API, storage). List the interleaved calls. | Any → compute all results first, then try side effect, return original or error-mapped results |

**Error handling:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A57 | Catch-and-rethrow | Grep `catch (` in the file. For each catch block list: (a) the exception type caught, (b) the body in line-numbered form, (c) whether the body re-raises the same exception (or wraps its message unchanged), (d) the side effect(s) in the body — classify as: log statement, metric/counter increment, span/trace annotation, audit write, print/stderr, no-op (empty), or transformation. A catch is "transforming" only when it does at least one of: throws a different exception type, returns a fallback value, performs cleanup/compensating action (resource close, transaction rollback). | Any catch whose body re-raises the same exception without transformation, fallback, or cleanup — regardless of the side effect (log, metric, trace, audit, print, none) → delete the try/catch. Cross-cutting concerns belong elsewhere: exception logging in the centralized exception handler, metrics/tracing in an interceptor or aspect, request context (userId, request ID) in the logger's diagnostic context (MDC). |
| A57b | Catch-and-swallow on broad type | Grep `catch (RuntimeException\|catch (Exception\|catch (Throwable` in the file. For each match list: (a) the broad exception type caught, (b) the body in line-numbered form, (c) whether the body rethrows (if yes, A57 covers it). For non-rethrowing bodies, classify the outcome as **silent drop** (no return value, `continue` in iteration, `return` from void, returns `Optional.empty()` that downstream just skips) vs **meaningful fallback** (returns a sentinel/default value that a caller branches on, returns a domain Null Object that downstream uses normally). A log statement does NOT count as making the drop meaningful. | Any broad catch without rethrow and without a meaningful fallback (silent drop, log-and-continue, best-effort iteration) → delete the try/catch and let the exception propagate to the centralized handler / scheduled-job wrapper / message listener (which already ERROR-logs uncaught exceptions); OR catch a SPECIFIC expected exception type with a real fallback consumed downstream; OR make the call non-throwing at the source (return Optional/Result from the domain method). |

**Cohesion & parameter groups:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A49 | Bloated entity / value object | Count fields. For each method, list which fields it accesses. Group fields by co-access patterns. | 10+ fields AND methods that use only a subset → extract cohesive value object for the field cluster |
| A50 | Repeating parameter group | Factory methods / constructors with 3+ parameters that appear together across 2+ call sites. List the repeated group. | Any → extract parameter object (record) and overload to accept it |
| A51 | External record rebuild | Code that constructs a new record/VO from an existing one, changing only 1-2 fields (copy all fields, override some). List the reconstruction site and the changed fields. | Any → add `toX()` transform method on the record itself |

**Type safety:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A12 | Raw map usage | `Map.of(`, `Map<String, Object>`, `Map<String, String>` in production code | Any map standing in for typed data |
| A13 | Null/default args | Constructor, `of()`, `from()` calls listing arguments | Any null/default argument |
| A13b | Nullable domain value object | Domain value object constructor that accepts null (e.g., `if (value != null` guard instead of rejecting null). Also: domain entity fields typed as a value object but allowed to be null at construction time. | Any null-accepting constructor or nullable VO field in domain — use empty string, Optional, or Null Object pattern per `.claude/guidelines/coding-detail.md` "No nulls in domain" |

**Usecase design** (skip if not a usecase class):

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A35 | Sequential storage port queries | Count injected storage/repository port fields. For each, check if data from one port feeds queries to another (N+1 pattern: fetch list → per item: fetch related data from another port). | 2+ storage ports queried sequentially — enrich aggregate, single port fetches everything upfront |
| A56 | Usecase-to-usecase dependency | List every injected field on the usecase. For each, classify its type: domain type, port interface, request DTO, clock/time source, other usecase. A type is "other usecase" if it lives under the usecase layer directory, is a concrete implementation (not a port interface), and itself orchestrates a user-visible operation. | Any other-usecase dependency → extract shared logic into the domain (entity method, value-object behavior, stateless domain service) or a non-usecase helper at the usecase layer; delete the usecase dependency |

**Storage adapter design** (skip if not a storage adapter class):

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A33 | Manual row grouping | See tech binding for ORM-specific patterns (grouping utilities, intermediate DTOs) in storage methods | Any manual row assembly — delegate mapping to ORM with proper entity relationships |
| A34 | Multi-repository injection | Count repository/data-access fields injected into a single storage class (see tech binding for patterns) | >1 repository dependency — consolidate into single query |
| A42 | Static query utility | Static class with methods that take a query/filter object and return framework query objects (see tech binding for patterns) | Any static utility building queries from a query object → move to adapter query class extending the port query |
| A43 | Untyped array query results | Index-based access to untyped query results (see tech binding for patterns) | Any → extract typed projection class with `toDomain()` |
| A44 | Inline query building in storage | Storage methods that build query/filter/pagination objects inline (see tech binding for patterns). Count lines of query-building logic vs actual storage work. | >5 lines of query building → extract AdapterQuery class extending port query |

## Section B — Read-and-judge (cite evidence)

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
