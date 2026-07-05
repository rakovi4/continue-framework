# Task 1: Rename h2 adapter to storage

Type: refactoring

Throwaway task: delete this folder after completion (do not move to `tasks/done/`).

## Problem

The framework's generic layer uses `h2` as the *role name* for the persistence
adapter, but H2 is a Java-specific in-memory database. The name leaks into every
non-Java tech binding: Go, PHP, Python, C++, Node, and C# bindings all ship a
`test-review-h2.md` whose content talks about an "H2 Adapter Layer" that will
never exist in those stacks. The generic docs hedge inconsistently
(`coverage-commands.md` says "h2/db"), and the storage template directory is
named differently in each binding (`h2`, `db`, `sqlite`), so generic agents
cannot resolve it mechanically.

`h2` appears in ~31 files outside the java-spring binding. No story or task
progress files exist yet, so there is nothing in flight to migrate — this is the
cheapest moment to rename.

## Solution

Use `storage` as the role name everywhere the generic layer addresses the
persistence adapter. It matches the port naming convention (`*Storage`
interfaces, e.g. `BoardStorage`), unlike `db`. Standardize the storage template
directory to `templates/storage/` in all tech bindings. Keep references to H2
*the database* (dev-database rows in `technology.md`, java-spring content about
the actual in-memory DB) — there "H2" names the technology, not the role.

Out of scope: renaming other tech-named template dirs (e.g. cpp-cmake's `grpc`
vs `rest`) — separate question, not part of this rename.

## Key Files

- `CLAUDE.md` — module table (`backend/adapters/h2`)
- `README.md` — architecture diagram
- `.claude/rules/*.md`, `.claude/guidelines/*.md` (workflow-detail, prompt-rules, technology-loading)
- `.claude/skills/` — test-adapter, test-coverage, test-review, task, continue
- `.claude/agents/` — coverage-agent, red-agent, test-review-*-agents (layer lists and `test-review-{...}` resolution patterns)
- `.claude/templates/` — workflow (progress-format, summary-format, adapter-discovery-checklist), task/creation-formats, refactoring (value-object, replace-string-with-enum, computed-field), testing/coverage-commands
- `.claude/tech/*/templates/testing/test-review-h2.md` — all 7 backend bindings
- `.claude/tech/java-spring/templates/h2/`, `.claude/tech/{go-stdlib,csharp-dotnet,node-ts-express,php-laravel,python-django}/templates/db/`, `.claude/tech/cpp-cmake/templates/sqlite/`
- `ProductSpecification/technology.md` — keep the "H2 (dev), PostgreSQL (prod)" database row as-is
