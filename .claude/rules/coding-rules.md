# Coding Rules

`## Deployment

- The backend runs as multiple instances. Never store application state in-memory (hash maps, static/global fields, local caches). Use the database for any state that must be consistent across instances.

## Clean Architecture

- `domain`: NO dependencies (only code generation library). No framework annotations.
- `usecase`: depends only on domain. No framework code except dependency injection and transaction management.
- `adapters`: implement interfaces defined in usecase. Framework-specific code lives here (HTTP controllers, message listeners/publishers, database repositories, external API clients).
- `application`: wires everything together.
- `acceptance`: top-level module. Black-box tests via HTTP and Selenium — no compile dependency on backend internals.
- FORBIDDEN: importing adapters from usecase/domain, importing usecase from domain, importing framework code from domain/usecase.
- Adapter interaction rules: first-layer adapters (controllers, listeners) must not call other first-layer adapters — they delegate to usecases. Third-layer adapters (repositories, clients) must not call other third-layer adapters or usecases — they are called by usecases only.

## Domain-Driven Design

- Domain must be rich: all domain-specific business rules belong in the domain layer, written in OOP style. Domain code must be free of code smells from Martin Fowler's Refactoring Book — especially domain, since it's the richest layer and the most susceptible to structural decay.
- Use value objects for domain concepts (Email, Token, UserId) — validate in constructor, throw domain validation exception.
- Use enums for fixed domain sets (TaskStatus, Priority, UserRole). Serialize to lowercase at adapter boundaries. Include a lowercase accessor and a parse-from-string factory. Add behavior methods when the enum carries domain logic (e.g., `isTerminal()`).
- Computed fields: if derivable from other fields, compute it — don't persist it.
- All domain validation in domain layer. Never validate domain rules in adapters or usecases.
- Entities: use factory methods (`create`, `of`, `from`), encapsulate state changes in methods.
- Aggregates: one root entity, external references by ID, transactions don't cross boundaries.
- No nulls in domain: domain entities and value objects MUST NOT have nullable fields. Use the language's optional type for truly optional associations, empty collections for absent lists, or Null Object / dedicated enum value for absent state. Adapters convert null/nil to optional at the boundary.
- Use polymorphism to eliminate type-based branching: when domain code uses type-checking or type-dispatch to pick behavior, push that behavior onto an interface method. Callers call the method — the type dispatches. No branching needed.
- No type-checking casts in domain/usecase: type-checking casts are forbidden in domain and usecase layers. Adapters dispatch at the boundary when building domain objects from persistence entities or external data. Domain uses polymorphic method calls instead.
- Typed lists over generic wrappers: when the concrete type is known at collection-creation time, use typed lists — don't erase the type into a base-interface list and re-partition with type checks later. Store what you know.
- Semantic naming for interface hierarchies: name the interface root after what ALL subtypes represent, not what only some represent. Example: `ListEntry` (any entry in any state) not `ActiveEntry` (because `ArchivedEntry` is not active).
- Extract cohesive value object from bloated entity: when an entity has 10+ fields and methods that only use a subset of them, extract a value object for the cohesive field group. The smell is intra-object: a cluster of fields always travel together and serve one concept (`TaskIdentity`, `TaskAssignment`, `TaskMetadata`).
- Repeating parameter group → parameter object: when 3+ parameters repeat across multiple factory methods or constructors, extract them into a dedicated class. Callers pass one object; factories overload to accept it.
- Instance transform on immutable data class: when external code rebuilds an immutable data class changing only 1-2 fields, add a `toX()` method on the class itself (e.g., `entry.toError(reason)`). The class owns its state transitions — callers don't need to know its fields.

## File Size

- **Hard limit: 200 lines per file.** After any creation or refactoring, verify with `wc -l`. If a file exceeds 200 lines, split it further. This applies to production code, test classes, Statements classes, and API clients. Third-party generated files (shadcn/ui) are exempt.

## Code Style

- Use code generation for boilerplate: DTOs get data accessors, builders for construction, constructor injection for DI, immutability markers for value types.
- Naming: value objects = simple noun, DTOs = `{Name}Dto`, requests = `{Action}Request`, responses = `{Action}Response`, fakes = `Fake{Interface}`, persistence entities = `{Name}Entity`. Variables: name by source when disambiguating same-typed values in one scope.
- Methods: usecases = verb+noun (`registerUser`), factory = `create`/`of`/`from`, converters = `toDto`/`toEntity`/`toDomain`.
- Prefer immutable objects, read-only fields, defensive copies of collections.
- Move behavior to data: serialization (`json()`), hashing (`computeSignature()`), formatting, builder construction, and derived values belong on the object that holds the fields. Callers should not extract fields to compute derived data externally. When callers repeat builder-then-build patterns, add a semantic factory method on the type.
- Eliminate accessor chains: if a caller traverses multiple levels of accessors (e.g., `a.b().c().format()`), add a convenience method on `a` (e.g., `a.cValue()`).
- Don't extract local variables for single-accessor calls — use `object.field()` directly. Extract a variable when it names a non-obvious computation, is reused across unrelated statements, or isolates a side-effecting call from a pure return mapping. Any call to an injected dependency (usecase, port, repository, API client) is side-effecting regardless of verb.
- Optional values: use monadic operations (map, flatMap, filter, orElse) — never check-then-unwrap. Let the optional type drive branching.
- Null boundary: adapters are the only layer that touches null. Controllers wrap nullable parameters with the optional type before building request DTOs. Usecase request DTOs use optional fields with empty defaults — never nullable types for optional filters/parameters. Domain and usecase code is null-free.
- Request DTOs own their conversions: if a usecase needs a derived value from request fields (e.g., date → timestamp, string → enum), put the conversion method on the request. The usecase calls request methods — it doesn't extract fields and convert them in private helpers.
- Avoid null as a signal between methods: never pass null to mean "no value" (e.g., `method(arg, null)` to skip optional behavior). Instead, extract shared logic into a private helper and keep overloads independent.
- Child entities own their mutations: parent delegates (`task.updateStatus(newStatus)`) instead of remove/add in the parent's collection.
- Avoid local variables: prefer extracting a private method over introducing a local. A method name documents intent better than a variable name, and keeps the calling method short.
- Prefer pattern matching / switch over if/return chains when branching on a single variable against known constant values (status codes, task priorities, column types).
- Extract sequential independent blocks: when a method is a flat sequence of 2+ independent operations (each small and cohesive, not sharing intermediate state), extract each into a named private method. The parent becomes a readable table of contents. The trigger is structural independence, not size — even a 10-line method with 4 independent 2-line blocks is a candidate.

## Usecases

- Usecases are orchestrators, not logic holders. All domain-specific business rules must be delegated to the domain layer. Usecases should be unaware of underlying technologies and integration protocols.
- Fetch everything upfront: a usecase should call one storage port that returns a rich aggregate containing all data needed for the operation. Never inject multiple storage ports to make sequential queries mid-execution (fetch board → per column: fetch tasks → per task: fetch subtasks). Instead, design the aggregate and the port so the storage layer delivers it in one shot.
- If a usecase has 2+ storage port dependencies queried in sequence, the aggregate is too thin — push the data assembly into the storage port and enrich the domain aggregate.
- Compute-then-side-effect: separate pure computation from side effects — compute all results upfront as an immutable list, then try the side effect (API call), return the original results or error-mapped results on failure. Don't interleave computation with side effects.

## Controllers

- Thin controllers only: accept request → convert DTO via conversion method → call usecase → return response via static factory.
- No business logic in controllers. Delegate immediately to usecases.
- HTTP status codes: 200 for success with body, 201 for resource creation, 204 for success without body. Errors via centralized exception handler.

## Storage Adapters

- Persistence entities are NOT domain entities. Separate classes with `from(domain)` and `toDomain()` mappers.
- Never expose persistence entities outside adapter. Storage implementations use framework repositories internally.
- One storage method = one logical query. Never inject multiple repositories into a single storage class to make separate queries.
- Delegate mapping to the ORM. Never use manual grouping, map entries, or intermediate row DTOs to reassemble query results — use proper entity relationships so the ORM handles aggregation.
- Storage `find*()` methods should be trivial: fetch all, map each to domain, collect. If the method body has helper methods, intermediate DTOs, or complex pipelines — the entity model is wrong.
- Query/filter parameter objects for storage ports belong in `backend/usecase/adapters/`, not `backend/domain/`. Use a mutable class with protected fields so adapters can extend it with framework-specific behavior (query specification building, criteria construction).

## Error Handling

- Domain exceptions extend the language's base unchecked exception, no framework dependencies. Let them bubble to the centralized exception handler.
- Mapping: ValidationException→400, UserNotFoundException→404, InvalidCredentialsException→401.
- Error response format: `{"error": "...", "message": "...", "timestamp": "..."}`.
