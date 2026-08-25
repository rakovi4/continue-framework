---
name: story
description: Add a new story to the Backlog table in ProductSpecification/stories.md. Use when the user wants to add, register, or backlog a story, or mentions the /story command.
---

# Add Story to Backlog

Add a story row to the **Backlog** table in `ProductSpecification/stories.md`.
This skill does NOT generate a story specification — spec generation is
dispatched by `/continue` via `.claude/templates/spec/story-spec-generation.md`
when the story's spec phase starts (see `.claude/rules/workflow.md` Lifecycle).

## Usage

```
/story "Story name"         # Add named story to the Backlog
/story                      # Ask for the story name, then add
```

A bare-number argument is not a story name (the retired spec-generation
`/story` selected stories by number) — ask what the user meant instead of
adding a row named after the number.

## Workflow

### Phase 1: Read the story map

Read `ProductSpecification/stories.md` — all three tables (**In Progress**,
**Backlog**, **Done**).

### Phase 2: Duplicate check

If the requested name matches an existing row in any table (case-insensitive,
ignoring punctuation), report the existing row and its table instead of adding
a duplicate. Stop.

### Phase 3: Quality gate — pain or opportunity

A story is a **pain to be cured or an opportunity to be gained** for a user.
Before adding the row, test the requested story against both rejection
patterns below. Do not silently accept a story that fails one.

- **Tech story** — names a solution or technology instead of a user outcome
  (e.g., "add message-queue streaming", "migrate to a new cache"). Technology
  choices are implementation decisions made inside a story's scenarios, not
  stories. Ask what user pain or opportunity the technology serves, and
  propose the story reformulated around that value (e.g., "add message-queue
  streaming" → "a user sees updates without refreshing"). When the work has
  no user-facing outcome at all — a purely internal migration or clean-up —
  point at `/task` (a refactor task) as its home: the story lifecycle
  would run interview, mockups, and frontend phases over work with no user
  to interview and no screen to mock up.
- **Part-story** — a fragment of a user journey with no independent value: a
  step, precondition, or continuation of another behavior (e.g., "log in and
  download the file" + "remove the watermark from the downloaded file"
  instead of "remove the watermark"). Propose the single story that carries
  the whole user value — preconditions and steps belong to that story's flow,
  not to separate rows. When that whole-value story is already a row, the
  fragment belongs inside its scope: report that row and stop rather than
  appending a second, overlapping row.

When a pattern fires: state which one and why, propose the reformulated
user-value story, and add a row only for the story the user confirms — the
reformulation, or their original wording if they insist after hearing the
pushback.

Re-run the Phase 2 duplicate check against the confirmed name whenever it
differs from the requested one. Phase 2 only checked what the user asked
for; a reformulation rewrites tech or fragment phrasing into user-value
phrasing, which is exactly the phrasing existing rows already use — so the
reformulated name is *more* likely to collide than the original, not less.

### Phase 4: Size check — one story, not a program of work

A story is one user outcome: spec'd once, delivered once. Test the story as
Phase 3 left it — the reformulation the user confirmed, or the requested name
when no pattern fired. Phase 3's part-story remedy *merges* fragments into the
story that carries the whole user value, which is exactly the umbrella shape
this check tests. When that story would plausibly explode into tens of
scenarios, propose a split into independently valuable stories before adding
the row. Signals it is oversized:

- The name joins separate outcomes ("register and manage a subscription") —
  each half is worth shipping without the other.
- It is an umbrella verb over an entity ("manage {Entity}"), which unpacks into
  create, edit, delete, list, and search — five outcomes in one row.
- It spans several distinct journeys, user roles, or screens, each with its own
  flow.

Every lifecycle phase — interview, spec, mockups, and each scenario type — runs
over the whole row, so an oversized row holds all of them open at once and
delivers nothing until its last scenario is green. The same work split across
rows ships value as each row completes.

Each story in a proposed split must stand alone — one a user would notice if it
shipped by itself. Splitting by layer or phase (a "backend" story plus a
"frontend" story) is not a split: it produces fragments that fail the
part-story test in Phase 3.

When the size check fires: state which signal fired, propose the split as a
named list of stories, and add rows only for what the user confirms — the
split, or the single story if they insist after hearing the pushback.

Re-check every confirmed split name — whether it came from the proposed split
or from the user's counter-proposal. A split mints brand-new names that no
earlier phase has seen; passing the gate in the pre-split wording proves
nothing about the fragments it unpacks into.

- **Part-story test** (Phase 3) against each name. When one fails, the split
  *boundary* is wrong — not the split: propose a different boundary that gives
  each story independent value. Never merge the fragment back into the whole,
  which lands on this size check again and ping-pongs between the two phases.
- **Duplicate check** (Phase 2) against each name (same reason as Phase 3: a
  split renames). Phase 2's "Stop." is written for a single name and would
  discard a split the user just confirmed, so across a split it does not stop:
  add the non-colliding rows, and report each colliding name against the row it
  matched. A collision means that slice is already tracked — report it, never
  drop it silently.

### Phase 5: Add the Backlog rows

1. **Numbering.** The first story = highest `#` across all three tables + 1
   (zero-padded to two digits, matching the existing rows); when all three
   tables are empty, start at `01`. A confirmed split numbers its stories
   consecutively from there, in the order proposed.
2. **Append one row per confirmed story** to the **Backlog** table — one row for
   a single story, N rows for a confirmed N-way split. Row format: every phase
   column (`Spec` through `Infra`) is `·` (no story folder exists yet, per the
   lifecycle rules in `.claude/rules/workflow.md`), and `Tests` / `%` stay
   empty.
3. Create nothing else — no folder, no spec files. Those appear when
   `/continue N` promotes the story and runs its spec phase.

### Phase 6: Report

State the new row (number, name) — every row, when a split produced several —
and every confirmed name that was not added because it collided, naming the row
it matched. Then point at the next step: `/continue N` auto-promotes the story from
**Backlog** to **In Progress** and starts the spec phase (`interview` → story
spec → …).

## Constraints

- **stories.md is the only file this skill writes, and appending Backlog rows
  is the only edit it makes.** Never rename or rewrite an existing row: rows in
  **In Progress** and **Done** have a story folder whose slug was derived from
  the name, and renaming the row orphans the folder.
- Keep the row format identical to the existing Backlog rows — same columns,
  same `·` markers. Do not add a Total row.
- Story names may contain punctuation (e.g., "Login/Logout") — the folder slug
  is derived later, at promotion, by `/continue` (its File-lookup rule owns
  that derivation).
