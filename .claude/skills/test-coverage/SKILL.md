---
name: test-coverage
description: Run tests with coverage and report uncovered lines/branches per class. Use when user wants to check test coverage, find untested code, identify coverage gaps, or mentions /test-coverage command. Also use after green phases to verify new code is well-covered.
---

# /test-coverage - Run Tests with Coverage Report

## Usage
```
/test-coverage usecase
/test-coverage storage
/test-coverage rest RegisterUserController
/test-coverage usecase --focus    # only classes touched in recent git diff
```

## Arguments

First word is the module:
- `usecase` → `:usecase`
- `storage`, `rest`, `email`, `scheduling`, `security` → `:adapters:{name}`
- `domain` → measured through the suites exercising domain code
- `frontend` → frontend coverage tooling from the active technology profile

Optional second word filters the report to classes matching that name.

Optional `--focus` restricts the report to changed production files. In staged
lanes, pass the recorded baseline and explicit owned paths, including already
committed changes; use last-commit focus only when no explicit scope was supplied.
Pass report-only mode for every staged lane so the coordinator owns tracking.

## Action

Delegate to `.claude/agents/coverage-agent.md` with module, focus paths/baseline,
and report-only mode. It resolves backend or frontend tooling from the active
technology profile and uses `.claude/templates/testing/coverage-commands.md` for
scope, report format, gap mapping, and remediation.

Steps:
1. Run tests with coverage (stop if tests fail)
2. Compute each touched module summary from its coverage report
3. List classes with gaps (apply filter/focus if specified)
4. Extract uncovered lines/branches, read source to show actual code
5. Report results
6. In `--focus` mode: map gaps to scenarios and classify reachability; return staged-lane findings to the coordinator, otherwise update progress.md for reachable gaps. Flag dead code for refactor.

## Agent

- `.claude/agents/coverage-agent.md` — workflow for gap analysis, reachability classification, progress.md updates

## Templates

- `.claude/templates/testing/coverage-commands.md` — universal workflow: focus mode, module mapping, report format
- `.claude/tech/{backend}/templates/testing/coverage-commands.md` — tool-specific commands: run, parse, extract
