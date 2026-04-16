# Python/Django Coding Idioms

Tech binding for `coding-rules.md`. Shared section structure: `.claude/templates/coding/coding-sections.md`.

## Deployment

- In-memory state to avoid: module-level `dict`/`set`, mutable default arguments, singleton caches in closures, class-level mutable attributes.

## Clean Architecture

- `domain`: pure Python — no Django imports, no framework decorators.
- `usecase`: ports are `Protocol` classes. Only `@transaction.atomic` allowed from Django.
- `adapters`: Django views/viewsets, Celery tasks, Django ORM repositories, external API clients.

## Domain-Driven Design

- Validation: throws `ValidationException` (custom domain exception).
- Enum: `enum.Enum` or `StrEnum`. `parse(value: str)` classmethod, `.value` for lowercase.
- Optional: `Optional[T]` / `T | None`. Collections: `tuple`/`frozenset` (immutable), `list` (mutable). Adapters convert `None`.
- Forbidden dispatch: `isinstance`. Adapters dispatch from Django models.
- Typed list: `list[ArchivedTask]` not `list[BaseProtocol]` + `isinstance`.
- Parameter object: `dataclass` or `NamedTuple`.
- Immutable: `@dataclass(frozen=True)`. Transitions via `dataclasses.replace()`.

## Code Generation

- `@dataclass` for DTOs/VOs. `@dataclass(frozen=True)` for immutable.
- DI: manual `__init__` wiring. Builders: class methods (`create`, `of`, `from_`).

## Naming

- Persistence: `{Name}Model`. Converters: `to_dto()` / `to_model()` / `to_domain()`.
- Modules: `snake_case`.

## Immutability

- `frozen=True` dataclasses, `tuple` over `list`, `frozenset` for sets.

## Accessor Chains

- `a.b.c.format()` → convenience property `a.c_value`.

## Optional/None Handling

- `match/case` or ternary — never `if x is not None: return x.value`.
- `or` for defaults, conditional expressions for mapping.

## Null Boundary

- Views: `or None` / explicit checks before building DTOs.
- Request dataclasses: `field(default=None)` typed as `Optional[T]`.

## Request DTO Conversions

- Examples: `str` date → `datetime`, `str` → enum parse.
- Methods: `to_timestamp()`, `parsed_action_type()`.

## Branching

- `match/case` over `if/return` chains (Python 3.10+).

## Controllers

- `to_usecase_request()` on request DTO.
- `JsonResponse(data, status=200)` → 200, `status=201` → 201, `HttpResponse(status=204)` → 204.
- Errors via centralized exception handler middleware.

## Storage Adapters

- Django models ≠ domain. `@classmethod from_domain(cls, domain)` + `to_domain()`. Never expose models.
- No `itertools.groupby()`, `defaultdict` grouping, or row dicts — use `select_related`/`prefetch_related`.
- Trivial: `return [model.to_domain() for model in MyModel.objects.all()]`.
- Query objects: `dataclass` with fields for `Q` object building.

## Refactor Agent — Python Terms

| Generic term (in agent) | Python equivalent |
|--------------------------|-------------------|
| Qualified enum references in logic | `from module import EnumValue` |
| Type-checking/type dispatch in domain or usecase | `isinstance`, `type()` checks |
| Base-type list re-partitioned with type checks | `list[BaseProtocol]` + `isinstance` |
| Immutable data class | `@dataclass(frozen=True)` |
| Collection pipeline terminal operation | `list()` / comprehension terminal |
| Manual per-field assertion for immutable data types | Applies to frozen dataclasses and value objects |

## Scan Checklist — Storage Grep Patterns

| # | Grep pattern / indicator |
|---|--------------------------|
| A33 | `itertools.groupby`, `defaultdict(list)`, `dict[..., list[...]]`, Row/Projection classes |
| A34 | Count Django Model/Manager references per storage class |
| A42 | Static/class methods returning `Q` objects or building querysets from filter |
| A43 | `.values_list()` without `named=True`, `.extra()`, `raw()` with manual column extraction |
| A44 | `Q()` chains or queryset filter chains >5 lines inline |

## HTTP Clients

- Production: `requests` (sync), `httpx` (async). Tests: `unittest.mock` at adapter boundary.

## Error Handling

- Domain: `DomainException(Exception)`. Bubble to centralized Django middleware.
