# Task 2: Archive done stories; the acceptance suite is the current state -- Progress

Type: refactoring

Throwaway task: delete this folder after completion (do not move to `tasks/done/`).

## Spec
- [x] spec

## Fix

### Step 1: State where the current state lives
- [~] Add a short section to `.claude/rules/workflow.md`: the **acceptance suite is the current-state documentation** of what the product does (grouped by functionality, `@Description`-annotated, black-box, self-correcting — an outdated behavior makes the build red, not a document stale), while a **story folder is a delta plus its rationale** (spec, interview, `decisions/*-decision.md`, `tests/tier3/`). Name the three things the suite cannot hold — deliberate non-goals, rationale, Tier 3 — and where each already lives. Record the **rejected alternative** in the same section, one sentence with its reason: a consolidated `ProductSpecification/features/{slug}.md` layer written by a `feature-doc` work unit at story close was considered and dropped, because prose duplicating executable behavior is an unchecked second surface that drifts. Add the pointer from `CLAUDE.md`

### Step 2: Point the four sweeps at the suite
- [ ] Rewrite the current-state reads so they stop scanning every story folder: `.claude/skills/interview/SKILL.md:28` (ALL `stories/*/interview.md`), `.claude/templates/spec/story-spec-generation.md:24` (all `stories/*/NN_StoryName.md`), `.claude/skills/api-spec/SKILL.md:34,35` (all `stories/*/mockups/` + all `stories/*/interview.md`), `.claude/skills/test-spec/SKILL.md:24` (story folders). Each reads the **acceptance tests of the area it is about to touch** for what exists today — test class names, `@Description` scenarios, Statements — and reaches into a story folder only for a *named* precedent (a decision record, the interview behind a specific rule), never as a sweep. Keep the fallback explicit for a repo with no suite yet: say so in the instruction rather than silently degrading

### Step 3: Archive the story folder on completion
- [ ] Generalize `/continue` SKILL.md step 11 from "move the task folder" to the work item's folder — the trigger is the completion fact already recorded in `stories.md`: the behavior commit that moves the row to the **Done** table also moves `ProductSpecification/stories/NN-story-name/` → `ProductSpecification/stories/done/NN-story-name/`, under the same staged-`progress.md` gate (`git diff --cached` on `progress.md`, zero `[ ]`/`[~]` remaining). Update Pre-Commit Checklist item 7 to cover both item types, extend the Triage reopen clause so a mid-cycle Tier 2 finding moves the folder back out of `done/` in the `review-fix:` commit, and state the folder move alongside the row move in `.claude/rules/workflow.md` and `.claude/templates/workflow/stories-md-format.md` ("Story completion")

### Step 4: Resolve story folders in both locations
- [ ] Rule: resolve `stories/` first, then `stories/done/`. Apply to every reader that resolves one story — `/continue` (Resolving the Argument), `.claude/guidelines/workflow-detail.md:89`, `.claude/agents/red-agent.md:18,97` (the reopen path sends it after an archived story's spec), `/handoff` (summaries + carryover), `/mockups`, `/align-design`, `/design-review`, `/screenshot` (default `stories/*/mockups/`), and the write-path templates (`spec/interview-format.md`, `spec/adr-format.md`, `spec/story-spec-generation.md`, `spec/test-spec-format.md`, `ui/mockup-generation-rules.md`) so none of them asserts a story always lives under `stories/`. **Rationale must survive the move**: decision-record and interview lookups explicitly span `stories/**` including `done/`. One exclusion — `/retier`'s "classify **every** folder under `ProductSpecification/stories/`" must not descend into the archive or treat `done/` as a story folder

### Step 5: Verification sweep
- [ ] `grep -rn "stories/" .claude/ CLAUDE.md` (excluding `.claude/tech/`) and confirm every remaining hit is one of: resolves both locations, is a pure write path for the active story, is an in-text example, or is `/retier`'s deliberate exclusion. Walk one story close on paper: last checkbox `[x]` → behavior commit carries the Done-table row **and** the folder move → triage SKIPs (all paths under `ProductSpecification/`) → `/continue N` on the archived story still resolves it → a Tier 2 review finding reopens it back out of `done/`. Confirm `/story` number allocation is unaffected (it reads the `stories.md` tables, not folders), and that no sweep rewritten in Step 2 still enumerates story folders to answer "what exists today"
