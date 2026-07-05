# Coding Rules

Always-on architectural core. The DDD smell catalogue, code-style catalogue, and
per-layer rules (usecases, controllers, storage adapters, error handling) live in
`.claude/guidelines/coding-detail.md` — read it before writing or refactoring code
in any backend layer.

## Deployment

- The backend runs as multiple instances. Never store application state in-memory (hash maps, static/global fields, local caches). Use the database for any state that must be consistent across instances.

## Clean Architecture

- `domain`: NO dependencies (only code generation library). No framework annotations.
- `usecase`: depends only on domain. No framework code except dependency injection and transaction management.
- `adapters`: implement interfaces defined in usecase. Framework-specific code lives here (HTTP controllers, message listeners/publishers, database repositories, external API clients).
- `application`: wires everything together.
- `acceptance`: top-level module. Black-box tests via HTTP and Selenium — no compile dependency on backend internals.
- Dependency flow is strictly inward. FORBIDDEN: importing adapters from usecase/domain, importing usecase from domain, importing framework code from domain/usecase, **injecting or calling one usecase from another usecase**.
- Adapter interaction rules: first-layer adapters (controllers, listeners) must not call other first-layer adapters — they delegate to usecases. Third-layer adapters (repositories, clients) must not call other third-layer adapters or usecases — they are called by usecases only.
- Usecase interaction rule: usecases must not call other usecases. Each usecase is a top-level entry point that orchestrates one user-visible operation; usecases do not compose. If two usecases share logic, extract it into the domain layer (a domain method, value-object behavior, or a stateless domain service) or into a shared helper that is itself not a usecase. Chaining usecases hides the call graph from the controller layer, leaks transactional/authorization boundaries across operations, and entangles top-level scenarios that should evolve independently.

## File Size

- **Hard limit: 200 lines per file.** After any creation or refactoring, verify with `wc -l`. If a file exceeds 200 lines, split it further. This applies to **every source file regardless of type** — production code, test classes, Statements classes, API clients, stylesheets, and config files. The limit is not class-specific: a file with no classes (a stylesheet, a config file) is still capped at 200 lines. Third-party generated files (shadcn/ui) are exempt.
