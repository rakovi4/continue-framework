# PHP/Laravel Coding Idioms

Tech binding for `coding-rules.md`. Shared section structure: `.claude/templates/coding/coding-sections.md`.

## Deployment

- In-memory state to avoid: `static` properties, global variables, singleton caches in closures, mutable class-level arrays.

## Clean Architecture

- `domain`: pure PHP -- no Laravel imports, no Eloquent, no facades.
- `usecase`: ports are PHP `interface` classes. Only `DB::transaction()` allowed from Laravel.
- `adapters`: Laravel controllers, queue jobs, Eloquent repositories, external API clients.

## Domain-Driven Design

- Validation: throws `ValidationException` (custom domain exception).
- Enum: PHP 8.1 backed `enum`. `parse(string $value): self` static factory, `->value` for lowercase.
- Optional: `?T` only at adapter boundaries. Domain uses typed properties without null. Collections: `array` (docblock `@var T[]`). Adapters convert `null`.
- Forbidden dispatch: `instanceof`. Adapters dispatch from Eloquent models.
- Typed list: `/** @var ArchivedTask[] */` not `BaseInterface[]` + `instanceof`.
- Parameter object: `readonly class`.
- Immutable: `readonly class` (PHP 8.2). Transitions via named constructors.

## Code Generation

- `readonly class` for DTOs/VOs. Constructor promotion for all properties.
- DI: type-hinted constructor (Laravel auto-resolves). Builders: static factory methods.

## Naming

- Persistence: `{Name}Model`. Converters: `toDto()` / `toModel()` / `toDomain()`.
- Files: `PascalCase`, one class per file (PSR-4).

## Immutability

- `readonly` properties, `readonly class` for value types.

## Accessor Chains

- `$a->b->c->format()` -- add `$a->cValue()`.

## Optional/Null Handling

- `??` for defaults, `?->` for chaining, `match` for branching.
- Never `if ($x !== null) { return $x->value; }` -- use `$x?->value ?? $default`.

## Null Boundary

- Controllers: `$request->input('field')` returns `null` for missing. Convert to typed DTOs immediately.
- Request DTOs: optional fields default `null` typed as `?T`.

## Request DTO Conversions

- Examples: `string` date → `DateTimeImmutable`, `string` → enum parse.
- Methods: `toTimestamp()`, `parsedActionType()`.

## Branching

- `match` expression over `if/return` chains (PHP 8.0+).

## Controllers

- `toUsecaseRequest()` on request DTO.
- `response()->json($data, 200)` → 200, `status 201` → 201, `response()->noContent()` → 204.
- Errors via centralized `Handler.php`.

## Storage Adapters

- Eloquent models ≠ domain. `static fromDomain(DomainEntity $e): self` + `toDomain()`. Never expose models.
- No `collect()->groupBy()`, `array_map` with intermediates, or row DTOs -- use eager loading `with()`.
- Trivial: `return TaskModel::all()->map(fn($m) => $m->toDomain())->toArray();`.
- Query objects: `class` with `protected` properties for query scope building.

## Refactor Agent -- PHP Terms

| Generic term (in agent) | PHP equivalent |
|--------------------------|----------------|
| Qualified enum references in logic | `use` import for enum cases |
| Type-checking/type dispatch in domain or usecase | `instanceof`, `get_class()` |
| Base-type list re-partitioned with type checks | `BaseInterface[]` + `instanceof` |
| Immutable data class | `readonly class` (PHP 8.2) |
| Collection pipeline terminal operation | `->toArray()` / `->all()` on Collection |
| Manual per-field assertion for immutable data types | Applies to readonly classes and value objects |

## Scan Checklist -- Storage Grep Patterns

| # | Grep pattern / indicator |
|---|--------------------------|
| A33 | `collect()->groupBy`, `array_reduce`, `array_map` with intermediates, Row/Projection DTOs |
| A34 | Count Eloquent Model references per storage class |
| A42 | Static methods returning query builder scopes from filter |
| A43 | `DB::select(`, `DB::raw(`, `->selectRaw(`, `$row->` on stdClass |
| A44 | `->where()->where()->orderBy()` chains >5 lines inline |

## HTTP Clients

- Production: `Http` facade (wraps Guzzle). Tests: `Mockery` or `Http::fake()` at adapter boundary.

## Error Handling

- Domain: `DomainException(\RuntimeException)`. Bubble to centralized `Handler.php`.
