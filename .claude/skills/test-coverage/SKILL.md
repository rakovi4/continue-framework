---
name: test-coverage
description: Run tests with coverage and report uncovered lines/branches per class. Use when user wants to check test coverage, find untested code, identify coverage gaps, or mentions /test-coverage command. Also use after green phases to verify new code is well-covered.
---

# /test-coverage - Run Tests with Coverage Report

## Usage
```
/test-coverage usecase
/test-coverage h2
/test-coverage rest RegisterUserController
/test-coverage usecase --focus    # only classes touched in recent git diff
```

## Arguments

First word is the module:
- `usecase` → `:usecase`
- `h2`, `rest`, `email`, `scheduling`, `security` → `:adapters:{name}`
- `domain` → `:domain`

Optional second word filters the report to classes matching that name.

Optional `--focus` flag restricts the report to classes changed since the last commit (useful after a green phase to check only new code).

## Action

Delegate to `.claude/agents/coverage-agent.md` which loads `.claude/tech/{backend}/templates/testing/coverage-commands.md` for commands, report format, gap mapping, and remediation.

Steps:
1. Run tests with coverage (stop if tests fail)
2. Compute module summary from CSV
3. List classes with gaps (apply filter/focus if specified)
4. Extract uncovered lines from XML, read source to show actual code
5. Report results
6. In `--focus` mode: map gaps to scenarios, classify reachability, update progress.md with red/green steps for reachable gaps, flag dead code for refactor

## Agent

- `.claude/agents/coverage-agent.md` — workflow for gap analysis, reachability classification, progress.md updates

## Templates

- `.claude/templates/testing/coverage-commands.md` — universal workflow: focus mode, module mapping, report format
- `.claude/tech/{backend}/templates/testing/coverage-commands.md` — tool-specific commands: run, parse, extract
