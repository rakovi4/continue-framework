# C#/ASP.NET Core Coding Idioms

Tech binding for `coding-rules.md`. Shared section structure: `.claude/templates/coding/coding-sections.md`.

## Deployment

- In-memory state to avoid: `static` fields, `ConcurrentDictionary`, singleton caches in DI, `ThreadLocal<T>`.

## Clean Architecture

- `domain`: pure C# — no framework attributes, no NuGet packages (except code generation).
- `usecase`: ports are C# interfaces. Only `[Transactional]`/`IUnitOfWork`. DI wiring in `application` only.
- `adapters`: ASP.NET Core controllers, MassTransit/NServiceBus handlers, EF Core repositories, external API clients.

## Domain-Driven Design

- Validation: throws `ValidationException` (custom domain exception).
- Enum: C# `enum`. `ToLowerString()` extension for lowercase, `Parse(string)` static factory.
- Optional: `T?` with `#nullable enable`. Collections: `IReadOnlyList<T>`. Adapters convert `null`.
- Forbidden dispatch: `is`, `switch` on type patterns. Adapters dispatch from EF Core entities.
- Typed list: `IReadOnlyList<ArchivedTask>` not `IReadOnlyList<IBaseInterface>` + `is` checks.
- Parameter object: `record` or dedicated class.
- Immutable: C# `record`. Transitions via `with` expressions.

## Code Generation

- `record` for DTOs/VOs. `record struct` for small value types.
- Primary constructors (C# 12) or readonly fields. Builders: `with` expressions on records.

## Naming

- EF Core entities: `{Name}Entity`. Converters: `ToDto()` / `ToEntity()` / `ToDomain()`.
- Interfaces: `I` prefix. Files: `PascalCase`.

## Immutability

- `readonly` fields, `init`-only properties, `IReadOnlyList<T>`, `ImmutableArray<T>`.

## Optional/Nullable Handling

- `?.`, `??`, `switch` expressions with pattern matching — never `!= null` + direct access.

## Null Boundary

- Controllers: `?? default` or null-coalescing before building DTOs.
- Request records: `T?` properties default `null` for optional filters.

## Request DTO Conversions

- Examples: `string` date → `DateTimeOffset`, `string` → enum parse.
- Methods: `ToTimestamp()`, `ParsedActionType()`.

## Controllers

- `ToUsecaseRequest()` on request DTO.
- `Ok(body)` → 200, `Created(uri, body)` → 201, `NoContent()` → 204.
- Errors via `IExceptionFilter` or middleware.

## Storage Adapters

- EF Core entities ≠ domain. `static FromDomain(domain)` + `ToDomain()`. Never expose outside adapter.
- No manual `GroupBy()` LINQ-to-Objects, `Dictionary<K, List<V>>`, or row DTOs — use `.Include()`.
- Trivial: `return await context.Tasks.Select(e => e.ToDomain()).ToListAsync();`.
- Query objects: `class` with `protected` fields for `IQueryable<T>` filtering.

## Refactor Agent — C# Terms

| Generic term (in agent) | C# equivalent |
|--------------------------|---------------|
| Qualified enum references in logic | `using static` to import enum values |
| Type-checking/type dispatch in domain or usecase | `is`, `as`, `switch` on type patterns |
| Base-type list re-partitioned with type checks | `IReadOnlyList<IBase>` + `is`/`OfType<T>()` |
| Immutable data class | C# `record` |
| Collection pipeline terminal operation | `.ToList()` / `.ToArray()` / `.ToDictionary()` |
| Manual per-field assertion for immutable data types | Applies to records and value objects |

## Scan Checklist — EF Core Grep Patterns

| # | Grep pattern / indicator |
|---|--------------------------|
| A33 | `GroupBy(` LINQ-to-Objects, `Dictionary<.*List<`, Row/Projection DTOs |
| A34 | Count `DbSet`/`IRepository` fields per storage class |
| A42 | Static methods returning `IQueryable<T>` or building specs from filter |
| A43 | `SqlRaw`, `FromSqlRaw` with `object[]`, anonymous type projections |
| A44 | `IQueryable<T>` filter chains >5 lines inline |

## HTTP Clients

- Production: `HttpClient` via `IHttpClientFactory`. Tests: `Moq`/`NSubstitute` at adapter boundary.

## Error Handling

- Domain: `DomainException(Exception)`. Bubble to ASP.NET Core exception filter/middleware.
