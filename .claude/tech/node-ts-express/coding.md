# Node/TypeScript/Express Coding Idioms

Tech binding for `coding-rules.md`. Shared section structure: `.claude/templates/coding/coding-sections.md`.

## Deployment

- In-memory state to avoid: module-level `Map`/`Set`, `global` variables, singleton caches in closures.

## Clean Architecture

- `domain`: pure TypeScript — no decorators, no framework imports.
- `usecase`: ports are TypeScript interfaces. No framework code except DI wiring.
- `adapters`: Express controllers, message handlers, Prisma/TypeORM/Knex repositories, external API clients.

## Domain-Driven Design

- Validation: throws `ValidationException` (custom domain exception).
- Enum: TypeScript `enum` or string union. `parse(value: string)` factory, `value()` accessor.
- Optional: `T | undefined` with strict null checks, or `Optional<T>` wrapper. Collections: `readonly` arrays. Adapters convert `null`/`undefined`.
- Forbidden dispatch: `instanceof`, discriminated union narrowing. Adapters dispatch from persistence entities.
- Typed list: `ReadonlyArray<ArchivedTask>` not `Array<BaseInterface>` + type guards.
- Parameter object: dedicated `interface` or `class`.
- Immutable: `readonly` properties, `Readonly<T>`. Classes own `toX()` transitions.

## Code Generation

- `readonly` for all class fields. Constructor injection via constructor parameters.
- DTOs: plain classes/interfaces with readonly fields. Builders: builder pattern or factory functions.

## Naming

- Persistence: `{Name}Entity`. Converters: `toDto()` / `toEntity()` / `toDomain()`.

## Immutability

- `readonly` fields, `Object.freeze()`, spread operator for defensive copies.

## Accessor Chains

- `get cValue(): string { return this.b.c.toString(); }` — callers use `a.cValue`.

## Optional/Nullable Handling

- `??`, `?.`, `map`/`flatMap` on Optional wrappers — never `!= null` + direct access.

## Null Boundary

- Controllers: undefined coalescing before building DTOs.
- Request DTOs: optional fields default `undefined` — never `null`.

## Request DTO Conversions

- Examples: `string` date → `Date`, `string` → enum parse.
- Methods: `toTimestamp()`, `parsedActionType()`.

## Branching

- `switch` over `if/return` chains for known constants.

## Controllers

- `toUsecaseRequest()` on request DTO.
- `res.status(200).json(body)` → 200, `status(201).json(body)` → 201, `status(204).send()` → 204.
- Errors via centralized error-handling middleware.

## Storage Adapters

- Entity: `static from(domain: T): Entity` + `toDomain(): T`. ORM relations for joins.
- Trivial: `const entities = await repo.findMany(); return entities.map(e => e.toDomain());`.
- Query objects: `class` with `protected` fields for query-builder logic.

## Refactor Agent — TypeScript Terms

| Generic term (in agent) | TypeScript equivalent |
|--------------------------|----------------------|
| Qualified enum references in logic | Direct import or barrel exports |
| Type-checking/type dispatch in domain or usecase | `instanceof`, type guards, discriminated union narrowing |
| Base-type list re-partitioned with type checks | `Array<BaseInterface>` + `instanceof`/type guards |
| Immutable data class | `readonly` class or `Readonly<T>` interface |
| Collection pipeline terminal operation | `.reduce()` / `.map()` / `.filter()` |
| Manual per-field assertion for immutable data types | Applies to readonly classes and value objects |

## Scan Checklist — Storage Grep Patterns

| # | Grep pattern / indicator |
|---|--------------------------|
| A33 | `reduce(`, `Map<`, `groupBy`, intermediate Row/Projection types |
| A34 | Count ORM repository/client fields per storage class |
| A42 | Static methods returning query builder fragments from filter |
| A43 | `any` return types from raw queries, `result[0]`, manual column extraction |
| A44 | Query builder chains >5 lines inline |

## HTTP Clients

- Production: native `fetch` (Node 18+) or `axios`. Tests: `vi.fn()`/`jest.fn()` at adapter boundary.

## Error Handling

- Domain: `class DomainException extends Error`. Express middleware maps subtypes to HTTP status.
