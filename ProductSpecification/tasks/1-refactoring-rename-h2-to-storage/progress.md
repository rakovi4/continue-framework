# Task 1: Rename h2 adapter to storage -- Progress

Type: refactoring

Throwaway task: delete this folder after completion (do not move to `tasks/done/`).

## Spec
- [x] spec

## Fix

### Step 1: Rename the role in the generic layer
- [x] Replace `h2` with `storage` as the adapter role name in CLAUDE.md, README.md, `.claude/rules/`, `.claude/guidelines/`, `.claude/skills/`, `.claude/agents/`, `.claude/templates/` (module path `backend/adapters/storage`, progress labels `red-adapter storage`, skill args, layer lists, `test-review-{usecase|rest|storage|...}` resolution patterns; fix the `h2/db` hedge in coverage-commands.md)

### Step 2: Rename test-review files in all tech bindings
- [x] Rename `templates/testing/test-review-h2.md` to `test-review-storage.md` in all 7 backend bindings (java-spring, go-stdlib, csharp-dotnet, node-ts-express, php-laravel, python-django, cpp-cmake) and update their internal headings/cross-references from "H2 adapter" to "storage adapter"

### Step 3: Standardize storage template directories
- [~] Rename `java-spring/templates/h2/` -> `templates/storage/`, `{go-stdlib,csharp-dotnet,node-ts-express,php-laravel,python-django}/templates/db/` -> `templates/storage/`, `cpp-cmake/templates/sqlite/` -> `templates/storage/`; update every reference to the old paths
- [ ] Rename module-path/coordinate references INSIDE binding content too (per review-pass findings on Step 1): `backend/adapters/{h2|db|sqlite}` dirs, `Adapters/Db`, build coordinates like `:adapters:h2`, and module-derived package/namespace paths -> the `storage` module. Explicitly includes files outside the renamed dirs: `java-spring/templates/scheduling/test-class.md` (`:adapters:h2`, liquibase path) and `java-spring/tdd.md` ("H2 adapter tests" row). Keep class-name prefixes that name the DB tech (`H2TaskStorage`, `sqlite_task_storage`)

### Step 4: Verification sweep
- [ ] Grep the whole repo for `h2`/`H2` case-insensitively and confirm every remaining hit refers to H2 the actual database (technology.md DB row, java-spring content about the in-memory DB itself) — not the adapter role. Module paths are role references, never keeps: `grep -rniE 'adapters[/:](h2|db|sqlite)|Adapters[/:]Db|H2 adapter' .claude/tech` must return zero role hits

### Cleanup
- [ ] Delete `ProductSpecification/tasks/1-refactoring-rename-h2-to-storage/` (throwaway)
