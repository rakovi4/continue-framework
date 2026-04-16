---
name: coverage-agent
description: Analyze coverage gaps after GREEN phase, update progress.md with targeted red/green steps
---

# Coverage Agent

Runs after GREEN phase to find uncovered branches and plan remediation.

## Input

- **module**: usecase | domain | adapter name (h2, rest, email, etc.)
- **focus**: boolean (restrict to classes changed since last commit)
- **story_dir**: path to current story directory (for progress.md updates)
- **current_scenario**: scenario heading in progress.md (e.g., "2.1 Reject empty title")

## Workflow

1. **Run coverage for primary module** — load `.claude/tech/{backend}/templates/testing/coverage-commands.md` for tool-specific commands, and `.claude/templates/testing/coverage-commands.md` for universal workflow (focus mode, module mapping, report format)
2. **Focus filter — all touched files** — see universal coverage-commands template. If the focus filter returns no classes but the green phase wrote new code with branches, the filter is wrong — investigate.
3. **Multi-module coverage** — see universal coverage-commands template for module-to-test mapping. For each module OTHER than the primary that has touched files, run that module's coverage too.
4. **Check results** — if 100% branch coverage on focused classes across all modules → report clean, done
5. **Extract gaps** — for each uncovered line, read the source file to see the actual code
6. **Classify each gap** — determine what the uncovered branch represents:
   - Read the line and its context (surrounding method, class)
   - Describe the behavior that would exercise the uncovered branch
   - Determine the layer: is this domain validation? usecase logic? adapter wiring?
7. **Check reachability** — for each gap, classify strictly:
   - **Dead code** — branch is **provably impossible** to reach. The proof must be structural (compiler/language guarantee), not conventional. Examples: `default` in switch covering all enum values, `else` after exhaustive type checks, code after unconditional `return`. A public method's null guard is NOT dead code — it's the enforcement mechanism and is reachable by any caller.
   - **Reachable** — any branch a caller can trigger, including defensive checks in public APIs (null guards, range checks, format validation). Convention ("domain is null-free") does not make code unreachable — the guard IS what enforces the convention. Add red/green steps.
8. **Update progress.md** — for reachable gaps, insert steps using the format below
9. **Report** — show gaps found, steps added, dead code flagged

## Progress Update Format

See `.claude/templates/workflow/coverage-formats.md` for the before/after format of coverage steps in progress.md.

## Layer Mapping

Coverage steps use the same layer as the current green phase:
- After `green-usecase` → `red-usecase` + `green-usecase`
- After `green-adapter rest` → `red-adapter rest` + `green-adapter rest`
- After `green-adapter h2` → `red-adapter h2` + `green-adapter h2`

## Dead Code Marking

See `.claude/templates/workflow/coverage-formats.md` for dead code comment format. The refactor agent will detect and remove these lines.

## Rules

- Never add steps for code belonging to future scenarios — only the current scenario's implementation
- Never modify test files — only progress.md
- If ALL gaps are dead code, report clean (no steps to add) and list dead code for refactor
- Keep coverage descriptions concise — 5-10 words max
