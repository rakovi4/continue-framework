---
name: refactor
description: Refactor code using Martin Fowler's patterns. Improves readability, moves behavior closer to data, removes unnecessary abstractions.
---

# /refactor

Dispatch one independent `refactor-agent` per coherent scope. The worker applies
all applicable refactoring checks; scope partitioning controls parallelism, not
checklist coverage. Load `.claude/templates/workflow/quality-execution.md` for
ownership, scheduling, evidence reuse, inspection modes, and result joining.

## Usage

- `/refactor` — analyze and refactor the current scope
- `/refactor {Target}` — analyze and refactor a named target

## Dispatch

1. Resolve the target, tests, helpers, and relevant collaborators. Load shared
   coding detail, frontend rules where relevant, and active technology bindings.
   Map responsibilities using `.claude/templates/refactoring/scan-checklist.md`.
2. Dispatch `refactor-agent` with the scope manifest, input revisions, applicable
   context, and execution mode. The worker must be independent of the primary
   implementation/test author and load every applicable M, D, and T check. It must
   not nest fan-outs.
   For large scopes, partition by cohesive capability, assign each partition all
   applicable clusters, and name an owner for cross-capability checks. Shared
   writes have one owner. Partitioned dispatches are read-only initially; gather
   every partition and cross-capability result before granting fixes.
3. Default unpartitioned standalone/task mode is **scan-and-fix**: scan the complete scope,
   resolve findings one refactoring at a time, verify, and return the completed
   result using `refactor-agent.md`. A small scope uses this same route.
4. Stage 2 may dispatch **inspect** on the stable joined candidate alongside
   coverage. It returns findings without edits; this is not a completed gate.
   After coverage-driven changes are verified and behavior is published, the
   coordinator explicitly dispatches **fix**, granting owned paths and passing
   current revisions and invalidations. Reuse the inspector when available;
   otherwise pass its evidence to a new independent worker. Revalidate affected
   checks, apply fixes, and await verification before completing the gate.
5. A worker retained from `/test-review` may run `/refactor` only after the
   coordinator publishes the reviewed tests and explicitly dispatches this skill.
   Keep the two named phases and results distinct; never auto-run the next phase.
   GREEN scope reuse follows `quality-execution.md`; every file and check remains
   accounted for, including cross-file effects.

Optional cluster fan-out is a coordinator choice only when scope size and
available capacity justify it without delaying ready independent scopes. Dispatch
`refactor-mechanics-agent`, `refactor-design-agent`, and
`refactor-duplication-agent` before awaiting any; gather every result, then grant
one owning `refactor-agent` the fixes. Workers never nest this fan-out.

## Available Templates

### Shared principles and responsibility-specific patterns (`.claude/templates/refactoring/`)

- `scan-checklist.md` - Scan hub: detector clusters + output format (links the three below)
- `scan-mechanics.md` - Cluster M checks (structural mechanics)
- `scan-design.md` - Cluster D checks (design + domain judgment)
- `scan-duplication.md` - Cluster T checks (duplication, tests, frontend)
- `code-smells-routing-table.md` - Smell → fix → template map (serial fixer)
- `value-object.md` - Replace primitive with value object
- `replace-string-with-enum.md` - Replace string constants with domain enum
- `computed-field.md` - Remove persisted field, replace with computed method
- `test-base-class.md` - Extract shared test setup
- `factory-method.md` - Replace constructor with factory
- `encapsulate-conditional.md` - Move conditionals to data class
- `parameterize-helper.md` - Add parameters to test helpers
- `inline-test-params.md` - Simplify test→statement data flow
- `replace-map-with-dto.md` - Replace Map.of() with typed DTO
- `rest-response-dto.md` - Wrap in REST DTO for snake_case conversion
- `move-to-data.md` - Move behavior, serialization, factories to data owner
- `simplify-expressions.md` - Static imports, method references, inline variables
- `flatten-control-flow.md` - Flatten conditionals, Optional patterns, child delegation
- `extract-method.md` - Named computations, guards, long method decomposition
- `replace-comment-with-code.md` - Preserve essential information elsewhere and delete every source comment
- `extract-class.md` - Split large class by concern, extract superclass for shared infra
- `adapter-query.md` - Extract typed AdapterQuery for Specification/CriteriaQuery logic
- `subselect-read-model.md` - Consolidate multiple repositories into single query with ORM relationships

### Additional presentation and fixture patterns (`.claude/templates/refactoring/`)

- `extract-component.md` - Extract JSX block into field/section component
- `extract-shared-ui.md` - Move reusable component to `app/components/ui/`
- `extract-test-fixture.md` - Extract MSW response fixtures, stub helpers, assertion helpers

## Constraints

- **Acceptance tests:** Selenium Statements should inject and delegate to backend Statements for shared setup (board setup, task creation) — never reimplement the same API calls.
- **Frontend extraction:** preserve CSS classes, Tailwind utilities, icon imports, element hierarchy, and ordering exactly. Rendered HTML must be structurally identical after extraction.
