# C++/CMake Coding Idioms

Tech binding for `coding-rules.md`. Shared section structure: `.claude/templates/coding/coding-sections.md`.

## Deployment

- In-memory state to avoid: `static` mutable variables, global singletons, `thread_local` caches.

## Clean Architecture

- `domain`: pure C++ standard library only. No framework headers, no third-party libraries.
- `usecase`: ports are pure abstract classes. Manual constructor injection — no service locators.
- `adapters`: gRPC implementations, SQLite repositories, libcurl/cpp-httplib HTTP clients, email senders.

## Domain-Driven Design

- Validation: throws `ValidationException` (inherits `DomainException`).
- Enum: `enum class`. `to_string()` free function for lowercase, `parse_{enum}(std::string_view)` factory. Behavior as free functions in same header.
- Optional: `std::optional<T>`, collections: `std::vector<T>`. Adapters convert null/empty.
- Forbidden dispatch: `dynamic_cast`, `typeid`. Adapters dispatch from persistence rows.
- Typed list: `std::vector<ArchivedTask>` not `std::vector<std::unique_ptr<IBaseInterface>>` + `dynamic_cast`.
- Parameter object: `struct`.
- Immutable: `struct` with `const` fields + constructor init. `with_*()` for field changes.

## Code Generation

- No code generation library. Constructor initialization lists.
- DTOs: plain `struct` with public fields. `operator==` via `= default` (C++20).
- Builder: nested `Builder` class with fluent setters + `build()`.

## Naming

- Files: `snake_case.h`/`.cpp`. Classes: `PascalCase`. Members: `snake_case_` (trailing underscore).
- Free functions/methods: `snake_case`. Persistence: `{Name}Row`. Converters: `to_dto()`/`to_row()`/`to_domain()`.
- Interfaces: `I` prefix. Namespaces: `domain::`, `usecase::`, `adapters::grpc::`, `adapters::sqlite::`.

## Immutability

- `const` members, `const` references. Pass by `const&`, return by value. `std::unique_ptr` for polymorphic.

## Accessor Chains

- `a.B().C().String()` → convenience method. Go convention: no `Get` prefix.

## Optional API

- `std::optional`: `value_or()`, `has_value()`, `transform()` (C++23), `and_then()` — never unchecked `*opt`.
- C++17: `if (auto val = opt)` pattern.

## Null Boundary

- Adapters convert raw pointers → `std::optional` at boundary.
- Request structs: `std::optional<T>` with `std::nullopt` default.

## Request DTO Conversions

- Examples: `std::string` date → `std::chrono::system_clock::time_point`, `std::string` → enum parse.
- Methods: `to_timestamp()`, `parsed_action_type()`.

## Branching

- `switch` over `if/return` for `enum class`. `[[nodiscard]]` on status-returning functions.

## Controllers (gRPC Services)

- Thin: deserialize protobuf → usecase request → call usecase → serialize response.
- `grpc::Status::OK` for success. Errors via centralized interceptor or base service.

## Storage Adapters

- SQLite rows ≠ domain. `from_domain(const Domain&)` + `to_domain()`. Never expose rows.
- Delegate joins to SQL — no `std::unordered_map<K, std::vector<V>>` grouping.
- Trivial: query → iterate rows → `to_domain()` → `std::vector`.
- Query objects: `struct` with `protected` fields for SQL WHERE building.

## Refactor Agent — C++ Terms

| Generic term (in agent) | C++ equivalent |
|--------------------------|----------------|
| Qualified enum references in logic | `using enum` (C++20) |
| Type-checking/type dispatch in domain or usecase | `dynamic_cast`, `typeid`, `if (auto* p = dynamic_cast<T*>(x))` |
| Base-type list re-partitioned with type checks | `std::vector<std::unique_ptr<IBase>>` + `dynamic_cast` |
| Immutable data class | `struct` with `const` fields or all-`const` getters |
| Collection pipeline terminal operation | Range-based for loop collecting into `std::vector` |
| Manual per-field assertion for immutable data types | Applies to structs and value objects |

## Scan Checklist — SQLite Grep Patterns

| # | Grep pattern / indicator |
|---|--------------------------|
| A33 | `std::unordered_map`, `std::map<.*std::vector`, intermediate Row/Projection structs |
| A34 | Count `sqlite3_stmt*` or repository pointers per storage class |
| A42 | Static functions building SQL WHERE from filter object |
| A43 | `sqlite3_column_int` without type-safe wrapper, raw `void*` results |
| A44 | SQL string concatenation >5 lines inline |

## HTTP Clients

- Production: `libcurl` or `cpp-httplib`. Tests: GMock at adapter boundary.

## Error Handling

- Domain: `DomainException(std::runtime_error)`. Bubble to gRPC interceptor/service base.
