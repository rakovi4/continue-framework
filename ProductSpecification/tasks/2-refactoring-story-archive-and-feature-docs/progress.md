# Task 2: Archive done stories and add feature docs -- Progress

Type: refactoring

Throwaway task: delete this folder after completion (do not move to `tasks/done/`).

## Spec
- [x] spec

## Fix

### Step 1: Define the features/ layer
- [~] Write `.claude/templates/workflow/feature-doc-format.md` — the shape of `ProductSpecification/features/{feature-slug}.md`: Purpose, Current behavior (rules, supported inputs, limits), Endpoints, UI entry points, Constraints & non-goals, Delivered by (chronological story rows, one line per delta). State the invariant: the doc describes **today's state**, never history — history lives in the Delivered-by list and in the story folders. Document the layer in `CLAUDE.md` and in `.claude/rules/workflow.md` (stories are deltas; `features/` is the consolidated view), and point `.claude/skills/doc/SKILL.md` at it so research docs link instead of duplicating current-state prose

### Step 2: Wire the feature-doc work unit into the story plan
- [ ] Add `- [ ] feature-doc` as the final checkbox of a story's `progress.md`: emit it last in `.claude/templates/workflow/bootstrapping.md` (after the last tier's sections), document it in `.claude/templates/workflow/progress-format.md` as a non-scenario checkbox — no `### ` heading, counted in neither Tests nor % (same treatment as `harvest`) — and classify it in "Blocks and boundaries" as its own block, so its unit is a boundary. Add the `feature-doc` row to `/continue`'s Work Unit Dispatch table: run inline (no subagent), read the story spec + `tests/` + the existing `features/{slug}.md`, fold the delta into current state, append the Delivered-by row, commit. Stories specced before this change carry no such checkbox and close without a feature doc — no auto-append, no migration branch (see spec, "Backfill is a task, not a framework mechanism"). Note in `stories-md-format.md` that `feature-doc`, like `harvest`, can hold a full-by-count story open

### Step 3: Declare feature identity at spec time
- [ ] Add a `Feature: {slug}` declaration to the story spec header in `.claude/templates/spec/story-spec-generation.md`, and make `/interview` (`.claude/skills/interview/SKILL.md`, `.claude/templates/spec/interview-format.md`) ask which feature the story extends — offering existing `ProductSpecification/features/*.md` — and read that doc as input so a delta story starts from the current state rather than re-deriving it from sibling story folders. Let `/story` capture the feature when registering a backlog row. A story that names no existing feature creates a new one at its `feature-doc` step

### Step 4: Archive the story folder on completion
- [ ] Generalize `/continue` SKILL.md step 11 from "move the task folder" to the work item's folder — the trigger is the completion fact already recorded in `stories.md`: the behavior commit that moves the row to the **Done** table also moves `ProductSpecification/stories/NN-story-name/` → `ProductSpecification/stories/done/NN-story-name/`, under the same staged-`progress.md` gate (`git show :`/`git diff --cached`, zero `[ ]`/`[~]` remaining). Update Pre-Commit Checklist item 7 to cover both item types, extend the Triage reopen clause so a mid-cycle Tier 2 finding moves the folder back out of `done/` in the `review-fix:` commit, and update `.claude/rules/workflow.md` + `.claude/templates/workflow/stories-md-format.md` ("Story completion") to state the folder move alongside the row move

### Step 5: Resolve story folders in both locations
- [ ] Update every consumer that hardcodes `ProductSpecification/stories/NN-story-name/` to resolve `stories/` first, then `stories/done/`: `/continue` (Resolving the Argument), `/handoff`, `/screenshot`, `/api-spec`, `/interview` (its `stories/*/interview.md` sweep must see shipped stories), `/mockups`, `/align-design`, `/design-review`, `/test-spec`, `.claude/agents/red-agent.md`, `.claude/guidelines/workflow-detail.md`, and the templates (`ui/mockup-generation-rules.md`, `spec/adr-format.md`, `spec/interview-format.md`, `spec/test-spec-format.md`, `spec/story-spec-generation.md`). Exclude `stories/done/` explicitly in `/retier` — its "classify every folder under `ProductSpecification/stories/`" sweep must not descend into the archive or treat `done/` as a story folder

### Step 6: Verification sweep
- [ ] `grep -rn "ProductSpecification/stories/" .claude/ CLAUDE.md` and confirm every remaining hit either resolves both locations or documents why it is in-flight-only. Walk one full simulated story close on paper: last scenario `[x]` → `feature-doc` unit writes `features/{slug}.md` → behavior commit carries the folder move + Done-table row → triage predicate SKIPs (all paths under `ProductSpecification/`) → `/continue N` on the archived story still resolves it. Confirm `/story` number allocation still works (it reads `stories.md` tables, not folders) and that `.claude/templates/workflow/plan-integrity-check.md` accepts a plan whose final checkbox is `feature-doc`
