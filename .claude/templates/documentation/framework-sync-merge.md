# Framework Sync Merge Guide

Reference for `/framework-sync`. The governing principles are in the "Upstream
Framework Sync" section of `.claude/guidelines/prompt-rules.md` — this file is the
mechanics: what is in scope, how each differing file is classified, and how conflicts
are resolved.

## Sync Surface

| Path | Treatment |
|------|-----------|
| `.claude/` (rules, guidelines, agents, skills, templates, tech bindings, hooks) | **Synced** — merged file by file |
| Always-on project instruction file at repo root | **Synced** — merged |
| `.claude/` settings file | **Key-merge only** — see below |
| Product specification tree | **Never** — upstream's copy is an empty template |
| Product code (backend, frontend, acceptance) and build files | **Never** — upstream has none, or has scaffolding |
| `infrastructure/` | **Never** — checkout-local ports, scripts, compose files |
| Repo-level docs (`README`, `LICENSE`, ignore file) | **Never** — describe this product, not the framework |

Anything outside the synced rows is not read, not diffed, and not reported.

After this upstream merge, `/framework-sync` may run an explicitly routed,
deterministic checkout-local migration. Such a migration reads product state but never
takes product files from upstream, and lands in a separate commit. The scenario stage
plan migration is defined in `../workflow/scenario-stage-migration.md`.

## Baseline File

`.claude/framework-baseline` — one line, created by the first successful sync:

```
<upstream-revision>  <iso-date>  <upstream-url>
```

It records the upstream revision the library was last reconciled against, **not** the
newest upstream revision seen. Only a sync that actually finished — merged, verified,
committed — advances it. An aborted or user-rejected sync leaves it untouched, so the
next run reconsiders the same upstream range.

## Two Entry Paths

**Incremental** (baseline present) — diff `baseline..upstream-head` restricted to the
sync surface. That diff *is* the set of upstream changes; everything not in it is local
territory and is left alone. Empty diff → report "already up to date" and stop without
touching a file.

**Bootstrap** (no baseline) — a whole-tree comparison cannot tell an upstream addition
from a local deletion, so it must not be applied as a patch. Classify every differing
file with the table below, present the classification, and take only what the table
marks as safe. Then record the baseline so later runs use the incremental path.

## Per-File Classification

| Situation | Action |
|-----------|--------|
| File exists upstream only, and nothing local references its absence | **Take** — new upstream capability |
| File exists locally only | **Keep** — local addition, upstream simply lacks it |
| Both changed, disjoint regions | **Merge** — apply the upstream hunks, keep the local ones |
| Both changed, same region, compatible intent | **Merge semantically** — express both intents in one passage; never pick a side by line count or recency |
| Both changed, same region, opposing rules | **STOP** — ask the user, showing both versions verbatim |
| Upstream change is a rename/restructure already done locally under a different name | **Skip as already-applied** — match on content, not path; report it |
| Upstream deletes a file the local library still references | **Keep the file**, report the upstream removal — a live cross-reference outranks an upstream delete |
| Upstream reverts something local added deliberately | **Keep local**, report — upstream lagging is not an instruction to regress |

The load-bearing asymmetry: *taking* an upstream change is reversible from history,
*losing* a local change is not visible in the resulting diff at all. When a case does
not fit a row cleanly, keep local and report it.

## Settings Key-Merge

The settings file is checkout-local: it wires hooks to scripts, selects plugins, and
points at paths that exist only here. It is never replaced wholesale.

- A top-level key present upstream and absent locally → offer it in the report; add it
  only if every path and command it references resolves in this checkout.
- A key present in both → keep the local value, always. Report the difference.
- A key present locally and absent upstream → keep silently; local hooks are expected.
- Never remove a local hook, plugin entry, or path.

## Post-Merge Verification

Run all of these before committing — a sync that lands a broken cross-reference is
worse than no sync:

1. **Cross-references resolve** — every file path named in a merged file exists.
2. **Routing tables are complete** — a skill, agent, or guideline newly referenced by a
   merged routing table actually arrived; one newly removed is not still routed to.
3. **File-size limit** — merged files respect the hard per-file line cap.
4. **Product-agnostic gate** — merged content names no product, company, domain entity,
   vendor, or story; upstream is generic, but a semantic merge can pull local product
   nouns into a shared passage.
5. **Layer placement** — content that arrived in the wrong layer gets relocated per
   `.claude/guidelines/prompt-rules.md`, not left where the patch put it.

## Report Format

```
Framework sync — upstream <short-rev> (<date>)
Baseline: <short-rev or "none — bootstrap">

Taken      (N)  path — one-line summary of the upstream change
Merged     (N)  path — what upstream added / what local kept
Kept local (N)  path — why upstream's version was not taken
Skipped    (N)  path — already applied / out of scope
Settings   (N)  key — offered, not applied

Asked user (N)  path — the contradiction, and the resolution chosen
Verification: cross-refs OK | routing OK | line limits OK | product-agnostic OK

Progress migration: <N migrated> | <N preserved — started> | <N already staged>
```

Every row names a file. A sync that reports only a count is unreviewable.
