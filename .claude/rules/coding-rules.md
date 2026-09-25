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

## File Organization

- Within each architectural layer or adapter module, group code by cohesive domain capability in named subdirectories. Inspect boundaries inside each broad feature: a feature or product folder alone does not establish cohesion. Separate groups with distinct responsibilities, collaborators, and reasons to change, even when they serve the same user journey.
- Keep collaborators local to their owning capability; put genuinely shared code in a narrowly named responsibility directory within its owning layer. Preserve inward dependencies when organizing files.
- Keep each capability's production code, tests, and helpers together within the technology's source/test layout. Technical subdirectories may organize a capability internally; feature-wide buckets for components, hooks, logic, or clients must not scatter collaborators from several capabilities.
- Let directories reflect real boundaries: a small area may stay flat when its files serve one responsibility and no independently cohesive subgroup exists. Neither file count nor a shared feature name proves cohesion. Avoid empty scaffolding and one directory per class.

## Source Formatting

- Keep hand-written production code, tests, styles, markup, and configuration readable: one statement per line, expanded block bodies, consistent indentation, and blank lines between methods and logical sections. Put stylesheet declarations on separate lines; wrap long expressions and markup using the project's formatting conventions.
- Run the configured formatter on touched files. If none exists, apply the language's conventional multiline formatting manually. Generated output is not a model for hand-written source.
- Blank lines aid readability and can reveal blocks within a method that deserve a named extraction. Extract those blocks by purpose; retain normal spacing between declarations, methods, and logical sections. Never remove spacing, join statements, or collapse blocks to satisfy a file or method size limit. Format first; split oversized files by cohesive responsibility afterward.

## File Size

- **Hard limit: 200 lines per file after readable formatting.** Count every physical line, including blank lines, imports, and declarations. After any creation or refactoring, verify with `wc -l`. If a file exceeds 200 lines, split it further. This applies to **every source file regardless of type** — production code, test classes, Statements classes, API clients, stylesheets, and config files. Third-party generated files (shadcn/ui) are exempt.

## Source Comments

- **NEVER WRITE COMMENTS.** Source files must express intent through names,
  types, structure, tests, and executable configuration instead of comments.
  This includes comments in production code, tests, stylesheets, markup, and
  configuration, including documentation comments, TODOs, commented-out code,
  rationale, section labels, and comment-based tool directives.
- **DELETE COMMENTS WHEN YOU ENCOUNTER THEM.** Every source comment in a file
  within the current task's edit scope is mandatory cleanup. Preserve essential
  information in clearer code, tests, or the owning documentation, replace
  comment-based directives with configuration or code, then delete the comment.
