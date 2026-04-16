# Usecase Test Template -- Universal

## 3-Tier Architecture

| Layer | Purpose |
|-------|---------|
| Test Class (thin DSL) | Disabled test, scenario in description |
| Statements (assertions) | Reusable setup and assertion methods |
| Scope (test data) | Builder pattern with default values |

## Test Class Rules

- NO infrastructure calls (fakes, storage, adapters) -- hide behind Statements methods. Test class reads like pure business DSL.

## Scope Boundary

Keep the full build green. When a domain entity constructor changes (e.g., adding `TaskStatus` to `Task`), fix ALL callers with defaults or zero-values -- including adapter code and tests.

**Do** (plumbing -- keeps build green):
- Pass default enum values in adapter/test constructors
- Pass the language's empty/absent value for optional fields, empty collections for lists

**Don't** (implementation -- belongs in GREEN/adapter phase):
- Add persistence annotations or new entity fields
- Create database migrations
- Wire new behavior end-to-end

## Stub Creation

When creating tests, also create minimal stubs for compilation:

- **Request DTO**: in the usecase feature directory
- **Response DTO**: in the usecase feature directory
- **Use-Case Class**: stub with the not-implemented marker
- **Domain entities/VOs**: only fields the test references. If the test asserts `Column.empty("To Do")`, Column needs `name` -- not a tasks collection. Don't create classes that no test references yet.

Story mapping: see `ProductSpecification/stories.md`
