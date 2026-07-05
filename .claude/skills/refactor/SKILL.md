---
name: refactor
description: Refactor code using Martin Fowler's patterns. Improves readability, moves behavior closer to data, removes unnecessary abstractions.
---

# /refactor

Scatter–gather: **three parallel read-only detectors** scan for smells, then a
**single serial fixer** applies refactorings one at a time. Detectors never edit
— only the fixer writes, and it re-scans cascades after each change, so the
"one refactoring at a time" invariant is preserved.

## Usage

```
/refactor                    # Analyze current code for smells
/refactor Email              # Create Email value object
/refactor UserService         # Refactor specific file
```

## Workflow

1. **Identify the target** file (and its tests / siblings). This determines which
   file-type checks apply (backend vs `.tsx`).
2. **Dispatch the detectors in parallel** (single message, multiple agent calls).
   Each runs only its cluster of `.claude/templates/refactoring/scan-checklist.md`
   and returns a candidate table:
   - `refactor-mechanics-agent` — cluster M (size, complexity, variables, dead code)
   - `refactor-design-agent` — cluster D (domain modeling, behavior placement, type safety)
   - `refactor-duplication-agent` — cluster T (sibling/cross-class duplication, tests, frontend)
3. **Gather + fix:** hand all candidate tables to `.claude/agents/refactor-agent.md`
   (the serial fixer). It merges, dedups, orders highest-impact-first, applies
   ONE refactoring at a time (loading the template from the Code Smells Routing
   Table), runs tests, and re-scans cascades inline — repeating until clean.

### Small-file shortcut

If the target is small with few methods/concerns, skip the fan-out and run a
single `refactor-agent` pass over the whole checklist — the detector
orchestration + merge overhead can exceed the single-agent cost on tiny files.

## Available Templates

### Backend (`.claude/templates/refactoring/`)

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
