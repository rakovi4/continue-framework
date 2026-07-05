# Task 1: Rename h2 adapter to storage -- Progress

Type: refactoring

Throwaway task: delete this folder after completion (do not move to `tasks/done/`).

## Spec
- [x] spec

## Fix

### Step 1: Rename the role in the generic layer
- [x] Replace `h2` with `storage` as the adapter role name in CLAUDE.md, README.md, `.claude/rules/`, `.claude/guidelines/`, `.claude/skills/`, `.claude/agents/`, `.claude/templates/` (module path `backend/adapters/storage`, progress labels `red-adapter storage`, skill args, layer lists, `test-review-{usecase|rest|storage|...}` resolution patterns; fix the `h2/db` hedge in coverage-commands.md)

### Step 2: Rename test-review files in all tech bindings
- [~] Rename `templates/testing/test-review-h2.md` to `test-review-storage.md` in all 7 backend bindings (java-spring, go-stdlib, csharp-dotnet, node-ts-express, php-laravel, python-django, cpp-cmake) and update their internal headings/cross-references from "H2 adapter" to "storage adapter"

### Step 3: Standardize storage template directories
- [ ] Rename `java-spring/templates/h2/` -> `templates/storage/`, `{go-stdlib,csharp-dotnet,node-ts-express,php-laravel,python-django}/templates/db/` -> `templates/storage/`, `cpp-cmake/templates/sqlite/` -> `templates/storage/`; update every reference to the old paths

### Step 4: Verification sweep
- [ ] Grep the whole repo for `h2`/`H2` case-insensitively and confirm every remaining hit refers to H2 the actual database (technology.md DB row, java-spring coding/tdd content) — not the adapter role

### Cleanup
- [ ] Delete `ProductSpecification/tasks/1-refactoring-rename-h2-to-storage/` (throwaway)
