---
name: refactor
description: Refactor code using Martin Fowler's patterns. Improves readability, moves behavior closer to data, removes unnecessary abstractions.
---

# /refactor

Spawns `refactor-agent` for code improvements.

## Usage

```
/refactor                    # Analyze current code for smells
/refactor Email              # Create Email value object
/refactor UserService         # Refactor specific file
```

## Workflow

1. Load `.claude/agents/refactor-agent.md`
2. Agent reads target file + tests
3. **Run the scan checklist** defined in the agent — enumerate (Section A) + judge (Section B). Fix violations before declaring clean.
4. Identifies smell, loads template from `.claude/templates/refactoring/`
5. Applies ONE refactoring, runs tests
6. Repeats until clean

## Available Templates

### Backend (`.claude/templates/refactoring/`)

- `scan-checklist.md` - Mandatory structural + judgment scan checklist
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
- `extract-class.md` - Split large class by concern, extract superclass for shared infra
- `adapter-query.md` - Extract typed AdapterQuery for Specification/CriteriaQuery logic
- `subselect-read-model.md` - Consolidate multiple repositories into single query with ORM relationships

### Frontend (`.claude/templates/refactoring/`)

- `extract-component.md` - Extract JSX block into field/section component
- `extract-shared-ui.md` - Move reusable component to `app/components/ui/`
- `extract-test-fixture.md` - Extract MSW response fixtures, stub helpers, assertion helpers

## Constraints

- **Acceptance tests:** Selenium Statements should inject and delegate to backend Statements for shared setup (board setup, task creation) — never reimplement the same API calls.
- **Frontend extraction:** preserve CSS classes, Tailwind utilities, icon imports, element hierarchy, and ordering exactly. Rendered HTML must be structurally identical after extraction.
