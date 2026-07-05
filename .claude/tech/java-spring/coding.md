# Java/Spring Coding Idioms

Tech binding for `coding-rules.md`. Shared section structure: `.claude/templates/coding/coding-sections.md`.

## Deployment

- In-memory state to avoid: `ConcurrentHashMap`, `static` fields, local caches.

## Clean Architecture

- `domain`: only Lombok. No Spring annotations.
- `usecase`: only `@Service` and `@Transactional`.
- `adapters`: REST controllers, Kafka listeners/publishers, JPA repositories, external API clients.

## Domain-Driven Design

- Validation: throws `ValidationException`.
- Enum: `value()` for lowercase, `from(String)` for parsing.
- Optional: `Optional<T>`, collections: `List<T>`, boundary: `null` ↔ `Optional`.
- Forbidden dispatch: `instanceof`, `if/instanceof`. Adapters dispatch from JPA entities.
- Typed list: `List<ArchivedTask>` not `List<BaseInterface>` + `instanceof`.
- Parameter object: `record`.
- Immutable: Java `record`, owns `toX()` transitions.

## Code Generation

- `@Data` for DTOs, `@Builder` for construction, `@RequiredArgsConstructor` for DI, `@Value` for immutable.

## Naming

- JPA entities: `{Name}Entity`. Converters: `toDto()` / `toEntity()` / `toDomain()`.

## Immutability

- `final` fields, defensive copies. Repeated `X.builder()...build()` → factory method on X.

## Accessor Chains

- `a.getB().getC().toString()` → convenience method `a.cValue()`.

## Optional API

- `ifPresentOrElse` / `map` / `filter` — never `isPresent()` + `get()`.

## Null Boundary

- Controllers: `Optional.ofNullable()` for `@RequestParam`.
- Request DTOs: `Optional` with `@Builder.Default Optional.empty()`.

## Request DTO Conversions

- Examples: `LocalDate` → `Instant`, `String` → enum.
- Methods: `fromInstant(Clock)`, `parsedActionType()`.

## Branching

- `switch` expressions (arrow `->`) for enums/sealed types. Pattern matching for sealed subtypes.

## Local Variables

- Never `var`. Declare the explicit type on every local (`Board board = ...`, not `var board = ...`). An inferred type forces the reviewer to reconstruct it from the right-hand side; an explicit type makes the declaration self-documenting in diffs and review.

## Controllers

- `toUsecaseRequest()` on request DTO.
- `ResponseEntity`: `ok()` → 200, `status(CREATED).body()` → 201, `noContent().build()` → 204.
- Errors via `GlobalExceptionHandler`.

## Storage Adapters

- JPA entities ≠ domain. `from(domain)` + `toDomain()`. Never expose outside adapter.
- No `Collectors.groupingBy()`, `Map.Entry`, or Row DTOs — use JPA relationships.
- Trivial: `repository.findAll().stream().map(Entity::toDomain).toList()`.
- Query objects: `class` with `protected` fields for `Specification`/`CriteriaQuery`.

## Refactor Agent — Java Terms

| Generic term (in agent) | Java equivalent |
|--------------------------|-----------------|
| Qualified enum references in logic | `static import` enum values |
| Type-checking/type dispatch in domain or usecase | `instanceof` and `if/instanceof` patterns |
| Base-type list re-partitioned with type checks | `List<BaseInterface>` + `instanceof` |
| Immutable data class | Java `record` |
| Collection pipeline terminal operation | `.collect(toList())` / `.toList()` |
| Manual per-field assertion for immutable data types | Applies to records and value objects |

## Scan Checklist — Java Grep Patterns

| # | Grep pattern / indicator |
|---|--------------------------|
| A58 | `\bvar\b` — type-inference local declaration. Java forbids `var`; every match is a violation (replace with the explicit type). |
| A33 | `Collectors.groupingBy`, `Map.Entry`, `Map<..., List<...>>`, Row/Projection DTOs |
| A34 | Count `JpaRepository` / `EntityManager` fields per storage class |
| A42 | Static methods returning `Specification` or `CriteriaQuery` |
| A43 | `CriteriaQuery<Object[]>`, `multiselect(`, `result[0]`, `((Number) result[N])` |
| A44 | `Specification`/`PageRequest`/`CriteriaQuery` inline >5 lines |

## HTTP Clients

- Production: framework HTTP client. Tests: mock at adapter boundary, not transport.

## Error Handling

- Domain exceptions extend `RuntimeException`. Bubble to `GlobalExceptionHandler`.

## Logging

- Use SLF4J parametrized messages — `log.info("did X for user={} chrt={}", userId, chrtId)` — one line per call site. Interpolated values land in the final message string, which is what you grep in prod.
- FORBIDDEN: the SLF4J 2.x fluent KV API (`log.atInfo().setMessage(...).addKeyValue(...).log()`), `Markers`, per-one-shot-value `MDC.put(...)`, and `StructuredArguments.kv(...)`. They add ~5 lines of ceremony per call for per-field JSON keys that aren't wanted. Request-scoped context (userId, request/trace ID) goes in MDC once via the auth/request filter — not per call site.
