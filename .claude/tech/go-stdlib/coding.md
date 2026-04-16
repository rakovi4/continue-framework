# Go/stdlib Coding Idioms

Tech binding for `coding-rules.md`. Shared section structure: `.claude/templates/coding/coding-sections.md`.

## Deployment

- In-memory state to avoid: package-level `var` maps/slices, `sync.Map`, global singletons, in-process caches.

## Clean Architecture

- `domain`: pure Go — no third-party packages.
- `usecase`: ports are Go interfaces. Only standard library + domain.
- `adapters`: chi HTTP handlers, pgx/sqlc repositories, external API clients.

## Domain-Driven Design

- Validation: `NewEmail(raw string) (Email, error)` — sentinel errors, not panic.
- Enum: typed `string`/`int` constants with `iota`. `String()` for serialization, `Parse{Type}(s string)` factory.
- Optional: `*T` for optional, `[]T` (nil-safe) for collections. Adapters convert `sql.Null*`/`*T`.
- Forbidden dispatch: type switches, type assertions. Adapters dispatch from persistence rows.
- Typed list: `[]ArchivedTask` not `[]Entry` + type assertions.
- Parameter object: dedicated `struct`.
- Immutable: unexported fields + exported getters. Factory `New*()`. Structs own `To*()` transitions.

## Code Generation

- DTOs: plain structs with exported fields and JSON tags.
- Constructors: `New{Type}(...)`. Functional options `With{Field}(v T) Option` for 5+ optional fields.

## Naming

- Persistence: `{Name}Row` or `{Name}Entity`. Converters: `ToDTO()` / `ToRow()` / `ToDomain()`.
- Interfaces: single-method → `TaskSaver`; multi-method → `{Noun}Port`/`{Noun}Storage`.
- Packages: short, lowercase, single-word.

## Immutability

- Unexported fields + exported getters. Return slices by value (copy).

## Accessor Chains

- `a.B().C().String()` → `func (a A) CValue() string`. No `Get` prefix.

## Optional/Pointer Handling

- `*T`: early-return nil checks. Lookup: comma-ok `val, ok := m[key]`.
- `(T, error)`: always check `err` first. Chain via helpers, not nested nil checks.

## Error Handling Style

- Always check returned errors. Never `_` to discard (except deferred Close).
- `errors.Is()`/`errors.As()` — never compare error strings.
- Wrap: `fmt.Errorf("fetching task %d: %w", id, err)`.
- Domain: sentinel `var` errors or typed structs implementing `error`. No panic.

## Null Boundary

- Adapters convert `sql.NullString` → `string`/`*string` at boundary.
- Request structs: zero values (empty string, zero int) or `*T` pointer fields with `nil` = "not provided".

## Request DTO Conversions

- Examples: `string` → `time.Time`, `string` → enum parse.
- Methods: `ParsedDeadline() time.Time`, `ParsedActionType() ActionType`.

## Branching

- `switch` — no fall-through by default. `fallthrough` only when intentional.

## Controllers (HTTP Handlers)

- Handler struct with injected usecases. `toUsecaseRequest()` on request struct.
- `w.WriteHeader(http.StatusOK)` + `json.NewEncoder(w).Encode(body)` → 200. `StatusCreated` → 201. `StatusNoContent` → 204.
- `chi.URLParam(r, "id")`, `r.URL.Query().Get("filter")`.

## Storage Adapters

- Persistence ≠ domain. `FromDomain(d) Row` + `(r Row) ToDomain() Domain`. Never expose rows.
- Scan logic in entity's `Scan()`/`FromRow()`, not scattered in storage methods.
- Trivial: `rows := query.FindAll(ctx); return mapSlice(rows, Row.ToDomain)`.
- Query objects: struct with exported fields for SQL WHERE translation.

## Refactor Agent — Go Terms

| Generic term (in agent) | Go equivalent |
|--------------------------|---------------|
| Qualified enum references in logic | `pkg.StatusActive` — use dot import or alias in tests |
| Type-checking/type dispatch in domain or usecase | Type switches (`switch v := x.(type)`), type assertions |
| Base-type list re-partitioned with type checks | `[]Interface` filtered with type assertions |
| Immutable data class | Struct with unexported fields + exported getters |
| Collection pipeline terminal operation | `for` loop with append, or `lo.Map`/`lo.Filter` |
| Manual per-field assertion for immutable data types | Applies to structs with unexported fields |

## Scan Checklist — Storage Grep Patterns

| # | Grep pattern / indicator |
|---|--------------------------|
| A33 | `map\[.*\]\[\]`, manual grouping loops, intermediate row structs |
| A34 | Count `*sql.DB`/`*pgx.Pool`/query interfaces per storage struct |
| A42 | Package-level functions building SQL fragments from filter object |
| A43 | `interface{}` return types from raw queries, `rows.Scan(&result)` with `interface{}` |
| A44 | String concatenation SQL (`"SELECT " + ...`) >5 lines inline |

## HTTP Clients

- Production: `net/http`. Tests: interface fakes at adapter boundary.

## Error Handling

- Domain: sentinel `var` errors or typed structs (`error` interface). No framework deps.
- Bubble to centralized HTTP error-handling middleware.
