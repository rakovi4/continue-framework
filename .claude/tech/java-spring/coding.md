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

## Scan Checklist — JPA Grep Patterns

| # | Grep pattern / indicator |
|---|--------------------------|
| A33 | `Collectors.groupingBy`, `Map.Entry`, `Map<..., List<...>>`, Row/Projection DTOs |
| A34 | Count `JpaRepository` / `EntityManager` fields per storage class |
| A42 | Static methods returning `Specification` or `CriteriaQuery` |
| A43 | `CriteriaQuery<Object[]>`, `multiselect(`, `result[0]`, `((Number) result[N])` |
| A44 | `Specification`/`PageRequest`/`CriteriaQuery` inline >5 lines |

## HTTP Clients

- Production: framework HTTP client. Tests: mock at adapter boundary, not transport.

## Error Handling

- Domain exceptions extend `RuntimeException`. Bubble to `GlobalExceptionHandler`.
