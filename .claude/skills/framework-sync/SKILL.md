---
name: framework-sync
description: Pull the latest upstream framework changes and merge them into the local prompt library without reverting local work. Use when the user wants to update the framework, pull upstream framework/prompt-library changes, or mentions /framework-sync.
---

# /framework-sync - Merge Upstream Framework Changes

The local `.claude/` tree is a vendored copy of an upstream framework template that both
sides keep editing. This skill pulls what upstream changed **since the last reconciled
revision** and merges it in — it never mirrors, never overwrites, never regresses local
work. Principles: "Upstream Framework Sync" in `.claude/guidelines/prompt-rules.md`.

## Usage
```
/framework-sync                 # fetch, merge, verify, commit
/framework-sync --dry-run       # report what would change; write nothing
/framework-sync <git-url>       # override the upstream repository
```

Default upstream: `https://github.com/rakovi4/continue-framework` (branch `main`).

## Workflow

1. **Preflight.** `git status --porcelain -- .claude CLAUDE.md` must be empty. If the
   sync surface has uncommitted edits, stop and report — the merge has to land as its own
   reviewable diff, and a three-way apply over dirty files is unresolvable afterwards.
   Uncommitted changes *outside* the sync surface are fine.
2. **Fetch upstream.** Add the remote once, then fetch it — never push to it:
   ```
   git remote get-url framework 2>/dev/null || git remote add framework <upstream-url>
   git fetch --no-tags framework main
   ```
   Read the upstream head: `git log -1 --format='%h %ci %s' framework/main`.
3. **Read the baseline** from `.claude/framework-baseline` (format in the merge template).
   Present → step 4. Absent → step 5.
4. **Incremental merge.** Compute the upstream change set:
   ```
   git diff <baseline>..framework/main -- .claude CLAUDE.md ':(exclude).claude/settings.json'
   ```
   Empty → report "prompt library already up to date at `<short-rev>`", then run the
   step 11 progress-layout audit before deciding there is nothing to commit. Otherwise
   apply it with `git apply --3way`, one file at a time so each result is inspectable.
   A file that fails to apply is not a failure of the sync — read both sides
   (`git show framework/main:<path>` vs the local file) and merge it by hand. Classify
   every file with the decision table in the merge template. Then go to step 6.
5. **Bootstrap** (no baseline). Do **not** apply a whole-tree diff as a patch — it cannot
   tell an upstream addition from a local deletion. Instead enumerate the differences:
   ```
   git diff --stat framework/main -- .claude CLAUDE.md
   ```
   Read direction matters: this diffs *from* upstream *to* the working tree, so `+` lines
   are local content and `-` lines are upstream content missing locally. Classify each
   file with the merge template's table, take only the rows it marks safe, and expect
   most files to be "keep local" when the local copy is ahead. Present the classification
   before writing anything.
6. **Key-merge the settings file** per the merge template. Upstream keys absent locally
   are *offered in the report*, applied only when every path and command they reference
   resolves in this checkout. No local key is ever rewritten or removed.
7. **Verify** — run the full post-merge checklist in the merge template (cross-references,
   routing tables, line limits, product-agnostic gate, layer placement). Fix what it
   catches before committing; a sync that lands a dangling reference is worse than none.
8. **Record the baseline.** Write the upstream head revision, today's date, and the
   upstream URL to `.claude/framework-baseline`. Only a sync that reached this step
   advances it — an aborted or rejected merge leaves the old value.
9. **Report** in the merge template's format: every file taken, merged, kept local, or
   skipped, named individually.
10. **Commit** the merge and the baseline together as `framework: sync from upstream
    <short-rev>`, with the report's substance in the body. Under `--dry-run`, stop after
    step 9 and write nothing.
11. **Migrate unstarted scenario plans.** After the sync commit (or immediately
    after an up-to-date result), run
    `.claude/templates/workflow/scenario-stage-migration.md` over every story
    `progress.md`. Inspect every `###` scenario block regardless of its enclosing `##`
    heading. Convert each wholly unstarted legacy backend-style or frontend scenario
    to its staged layout; preserve a scenario as a whole when any one of its steps
    started.
    Under `--dry-run`, report candidates without writing. Otherwise commit all migrated
    progress files separately as `framework: migrate unstarted scenario plans`.

## Constraints

- **Never merge upstream files outside the surface** defined in the merge template — product
  specification, product code, infrastructure, and repo-level docs stay untouched, whatever
  upstream carries in those paths. Step 11 is not an upstream-file sync: it is a
  deterministic, checkout-local plan migration governed by its own template and commit.
- **Never push to the upstream remote.** This skill is pull-only; local improvements go
  upstream by a separate, deliberate route.
- **A contradiction stops the merge.** When upstream and local state opposing rules for
  the same decision, ask the user with both versions shown verbatim — do not pick by
  recency, line count, or authorship.
- **Keep local when unsure.** Taking an upstream change is recoverable from git history;
  a lost local change leaves no trace in the resulting diff.
- **One prompt-sync commit.** The merge, settings decision, and baseline land together.
  The derived progress migration lands separately so prompt changes and product state can
  be reviewed or reverted independently.

## Templates

- `.claude/templates/documentation/framework-sync-merge.md` — sync surface, baseline
  format, per-file decision table, settings key-merge, verification checklist, report format.
- `.claude/templates/workflow/scenario-stage-migration.md` — idempotent migration of
  wholly unstarted legacy backend-style and frontend scenario blocks.

## Next Steps

1. Review the sync commit's diff — it is the only review surface for what upstream changed.
2. `/prompt-refactor {file}` — for any merged file whose layer placement the verification
   step flagged as questionable.
3. `/retier` — **once**, if this merge brought tiering in (`.claude/templates/spec/tier-ladder.md`
   arrived). The merged prompts read per-repo `Tier:` markers that no diff can carry, and
   nothing else writes them (`.claude/skills/retier/SKILL.md`). It commits per story, so it
   never rides the sync commit.
4. **The story-archive backfill** — **once**, if this merge brought the archive rule in
   (`.claude/rules/workflow.md`, "A repo adopting this rule backfills once") and `stories.md`
   has **Done** rows whose folders are still under `stories/`. Those folders predate the rule,
   no diff can move them, and this sync may not touch them — product specification is outside
   the sync surface. The sweep is in `.claude/templates/workflow/stories-md-format.md`,
   "Backfilling an adopting repo". It lands as its own commit, so it never rides the sync commit.
