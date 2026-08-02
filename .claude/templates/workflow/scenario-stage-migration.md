# Scenario Stage Plan Migration

Deterministic checkout-local migration run by `/framework-sync`. It updates existing
story plans to the concurrent backend-style and frontend stages without reordering
scenarios or touching work that has begun.

## Scope

Enumerate every `progress.md` under the product specification tree with `find`; select
only files whose H1 identifies a story. Inspect scenario blocks under Backend,
Integration, Frontend, Security, Load, and Infrastructure sections, including
tier-prefixed versions. Never migrate task plans or non-scenario sections.

## Candidate Test

A scenario is a candidate only when every marker in one of these exact legacy
sequences is `[ ]`:

**Backend-style** — Backend, Integration, Security, Load, or Infrastructure only:

```markdown
- [ ] red-acceptance
- [ ] design
- [ ] red-usecase
- [ ] green-usecase
- [ ] adapters-discovery
- [ ] green-acceptance
```

**Frontend** — Frontend only:

```markdown
- [ ] red-selenium
- [ ] red-frontend
- [ ] green-frontend
- [ ] red-frontend-api
- [ ] green-frontend-api
- [ ] align-design
- [ ] green-selenium
- [ ] demo
```

No checkbox in the scenario may be `[x]`, `[~]`, or `[S]`. One such marker freezes the
entire scenario; never migrate only its unstarted suffix. A scenario that already
contains a `stage-*` checkbox or lane checkpoint is already staged, not a candidate.
An unfamiliar sequence is custom and must be preserved without inference.

## Rewrite

Replace only the matching checkbox lines. A backend-style candidate becomes:

```markdown
- [ ] stage-1 acceptance RED + contract design
- [ ] approve stage-1 contracts
- [ ] stage-2 implementation lanes
- [ ] stage-3 acceptance GREEN + review
```

A frontend candidate becomes:

```markdown
- [ ] stage-1 frontend acceptance RED + interface design
- [ ] stage-2 frontend implementation lanes
- [ ] stage-3 frontend acceptance GREEN + review
```

Keep headings, comments, blank lines, ordering, and every other block byte-for-byte.
Do not update `stories.md`: scenario totals and phase state are unchanged.

## Verification

After rewriting:

1. Re-scan every changed file and confirm no candidate legacy block remains.
2. Confirm every preserved started block is byte-identical to its pre-migration form.
3. Confirm each migrated block has exactly its staged checkboxes in the order above.
4. Run `.claude/templates/workflow/plan-integrity-check.md` against every changed plan.
5. Run the migration scan again and require zero candidates; this proves idempotence.

## Reporting and Commit

Report each file and scenario as `migrated`, `preserved — started`, `preserved — custom
shape`, or `already staged`. A dry run stops here. Otherwise commit all changed progress
files together as `framework: migrate unstarted scenario plans`, separately from the
prompt-sync commit. If no candidate exists, make no migration commit.
