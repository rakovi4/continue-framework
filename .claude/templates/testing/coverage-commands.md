# Test Coverage Commands — Universal

Tech-specific commands (run, parse, extract) are in `.claude/tech/{backend}/templates/testing/coverage-commands.md`. This file defines the universal workflow and report structure.

## Focus Mode (--focus)

When `--focus` is specified, restrict coverage analysis to files changed since the last commit:

1. Get ALL production files touched since last commit — regardless of module (use the tech-specific git diff command)
2. This catches domain classes exercised by usecase tests, adapter classes pulled in transitively, etc.
3. Filter the coverage output to only those class/file names
4. If the focus filter returns no classes but the green phase wrote new code with branches, the filter is wrong — investigate

## Multi-Module Coverage

Group touched files by owning module to determine which coverage reports to run.

### Module-to-test mapping

| Touched file module | Run coverage for | Reason |
|---------------------|-----------------|--------|
| `domain` | `usecase` | Domain has no own tests; usecase tests exercise domain |
| `usecase` | `usecase` | Direct |
| `{adapter}` (rest, h2/db, email, etc.) | `{adapter}` | Direct |

For each module with touched files, run its mapped test suite's coverage (if not already run as the primary module). Check each touched file against the coverage of its mapped module.

## Uncovered Line Analysis

After extracting uncovered lines (using the tech-specific extraction command):

**Read each uncovered line from the source file** using the Read tool. Show the line number and actual code so the gap is immediately understandable.

## Report Format

```
Tests: {pass_count} passed, {fail_count} failed
Lines: X/Y (Z%)  |  Branches: A/B (C%)

Classes with gaps (sorted by coverage, lowest first):
  ClassName — lines: X/Y (Z%), branches: A/B (C%)

Uncovered lines in ClassName:
  L42:  <language-specific throw/raise/return error>
  L97:  <conditional check>          // false branch
  L98:  <fetch from storage>
  L99:  <iterate and process>

HTML report: <tech-specific path>
```

If all classes have 100% line and branch coverage, say so — no need to list them.

## Gap-to-Scenario Mapping and Remediation

See `.claude/templates/workflow/coverage-formats.md` for the universal gap-to-scenario mapping, reachability check, remediation workflow, and output format.
