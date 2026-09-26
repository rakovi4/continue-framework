# Scan — Cluster D: Design (structural + judgment)

Part of the refactor scan, run by `refactor-design-agent`. Hub + cluster
routing + output format: `scan-checklist.md`. Fix templates: `code-smells-routing-table.md`.

Two modes below. **Section A (structural):** produce numeric/objective data.
**Section B (judgment):** read the code, answer the question, and **cite the
snippet as evidence** or write "none found" — no bare "clean."
Use the role applicability protocol in `scan-checklist.md` for every target.
Models and orchestration exist on client and server. Error handling applies
wherever errors are handled, including tests. Qualify reused IDs as D-A46,
D-A47, and D-A57; the presentation checks with those numbers belong to T.

## Section A — Structural

**Data ownership:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A3 | Feature envy | Per operation: external fields read, computations performed, and actual data owner | Repeated field reads used to implement another owner's rule or transition; move behavior to that owner. Boundary mapping must have an explicit owner |
| A4 | Getter chains | Chained method calls through different objects | 3+ levels deep |

**Repetition:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A6 | Repeated construction | Object, record, and state construction grouped by type and purpose | Repeated construction policy belongs in a named factory or transition; do not merge intentionally independent identities |
| A7 | Repeated expressions | Same sub-expression appearing in multiple places | 2+ occurrences |
| A7b | Near-duplicate blocks | Structurally similar blocks and their differing values, across functions and classes | Repeated behavior with the same reason to change; parameterize the variation under `restraint.md` |

**Polymorphism & type dispatch:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A46 | Scattered variant dispatch | Runtime type tests, casts, or repeated tag/status branches in models and orchestration | Centralize variant behavior in its model with polymorphism or exhaustive typed dispatch. Safe narrowing and boundary decoding are not themselves smells |
| A47 | Erased collection types | Collections that discard known variant types and require later filtering or casts to recover them | Preserve known types at construction; use explicit variant handling when mixed data is intentional |
| A48 | Computation mixed with effects | Validation, decisions, transitions, and effect calls within each operation; record response dependencies | Extract pure decisions and transitions from effect orchestration. Preserve response-before-decision, freshness, and error ordering; asynchronous execution does not exempt mixed concerns |

**Error handling:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A57 | Catch-and-rethrow | Every error handler: caught category, body, rethrow, translation, fallback, state transition, or cleanup | Remove handlers that merely log or rethrow unchanged. Keep meaningful recovery/translation/cleanup at its boundary; do not duplicate error policy across operations |
| A57b | Catch-and-swallow | Broad or untyped handlers, rejected asynchronous operations, empty handlers, and ignored errors; trace what the caller or user observes | Silent loss or log-and-continue without an explicit recovery contract is a violation. Narrow expected failures; surface unexpected ones. Stale-result suppression requires a demonstrated lifetime contract, not a blanket catch exemption |

**Cohesion & parameter groups:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A49 | Bloated model or state | Fields and per-operation access groups in objects, records, stores, and closures | Ten or more fields with distinct co-access groups require splitting by capability; smaller models with unrelated responsibilities still fail cohesion |
| A50 | Repeating parameter group | Three or more parameters traveling together across constructors, factories, functions, or callbacks | Give a cohesive group a named type; do not hide unrelated dependencies in a broad context object |
| A51 | External state reconstruction | Callers copying another owner's fields and changing a subset; list transition rules and duplicate updates | Move the transition into the state owner, through a model method or cohesive pure function. Typed transport mapping stays at the boundary |

**Type safety:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A12 | Untyped structured data | Maps, dictionaries, generic objects, dynamic field access, and unchecked conversions replacing known shapes | Use typed boundary records and validated decoding; genuine key/value collections remain collections |
| A13 | Placeholder arguments | Construction and operation calls with missing/default values used as mode flags; inspect their contracts | Replace ambiguous placeholders with explicit operations or typed alternatives; legitimate optional boundary data follows A13b |
| A13b | Invalid or ambiguous model states | Model construction, optional fields, unchecked casts, and flag combinations | Make invalid states unrepresentable or reject them; represent legitimate absence explicitly. Boundary nullability is not permission for unchecked model state |

**Orchestration design** (client and server operations):

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A35 | Sequential storage port queries | Count injected storage/repository port fields. For each, check if data from one port feeds queries to another (N+1 pattern: fetch list → per item: fetch related data from another port). | 2+ storage ports queried sequentially — enrich aggregate, single port fetches everything upfront |
| A56 | Operation-to-operation dependency | Each orchestration dependency: model, effect port, internal helper, or another top-level user operation; classify by behavior | Top-level operations must not call one another to share logic; extract a focused model operation or helper. Names and file locations alone cannot classify a collaborator |

**Storage adapter design** (only where persistence/query mechanisms exist):

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
| B1 | Do primitive parameters or fields carry validation, units, identity, or other domain meaning without an owner? | Quote declarations and rules; use the active binding's validated value representation |
| B2 | Are fixed states represented by unrestricted strings, duplicated predicates, or inconsistent branches? | Quote definitions and consumers; require a closed type and owned behavior |
| B3 | Is stored or observable state derivable from other owned state? | Quote the fields and derivation; justify any independently observable snapshot |

**Behavior placement:**

| # | Question | Evidence required |
|---|----------|------------------|
| B4 | Are validation, policy, or state transitions in presentation, transport, or orchestration instead of the model? | Quote behavior and identify its proper owner on either client or server |
| B5 | Does a caller inspect another owner's fields to reject an operation or construct an error? | Quote guards and failure mapping; separate model validation from boundary presentation |
| B6 | Are serialization, normalization, formatting, or derived computations scattered outside their owning model or boundary? | Quote callers and the intended owner; keep framework/transport concerns at boundaries |
| B7 | Do consecutive eligibility/validation guards implement one unnamed decision? | Quote guards, inputs, and outcome; extract a named decision without changing failure behavior |
| B8 | Does external code mutate another model's children or fields instead of requesting a transition? | Quote mutation and state owner |
| B9 | Does a boundary leak domain or transport structures into consumers with different contracts? | Quote exposed type and consumers; introduce a boundary projection only where the contract differs |

**File organization:**

| # | Question | Evidence required |
|---|----------|------------------|
| B13 | Do directories expose cohesive capabilities inside each broad feature, following File Organization in `.claude/rules/coding-rules.md`? | Produce the directory inventory and boundary verdict below, including tests/helpers. A clean verdict requires the inventory; a shared feature name or small file count is insufficient. |

### B13 — Directory boundary check

Run once per affected capability area, including when the target is one small
file. Read sibling files and their consumers; names alone do not establish roles.
Record one row per file: current path, responsibility, collaborators/consumers
(with source references), and owning capability/destination. Include related tests
and helpers; files outside the edit scope remain read-only context.

Identify entry operations, then group their dedicated collaborators with them.
A worker plus its provider port, validator, and failure type forms an independently
cohesive subgroup when those collaborators serve that worker. Other operations
sharing its entity or storage port do not erase that boundary. Check the same
relationship for interface components, state logic, clients, tests, and helpers.

For each subgroup, report MOVE or KEEP with its member paths and reason to change.
MOVE when a dedicated group is mixed with other responsibilities or scattered
across technical buckets. KEEP requires showing that the current directory already
contains that group or that no separate subgroup exists. Put genuinely shared
collaborators in a directory named for their responsibility; trace their consumers
before calling them shared. Do not duplicate shared ports or introduce wrappers
to make the directory tree symmetrical. One cohesive group may remain flat.

For example, eight files serving one operation can be cohesive; fewer files mixing
an operation and its dedicated collaborators with unrelated operations require a
split. A common entity, journey, or persistence dependency is not a KEEP reason.
