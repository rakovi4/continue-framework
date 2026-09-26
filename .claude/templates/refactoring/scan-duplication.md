# Scan — Cluster T: Duplication & surface (structural + judgment)

Part of the refactor scan, run by `refactor-duplication-agent`. Hub + cluster
routing + output format: `scan-checklist.md`. Fix templates: `code-smells-routing-table.md`.

Two modes below. **Section A (structural):** produce numeric/objective data.
**Section B (judgment):** read the code, answer the question, and **cite the
snippet as evidence** or write "none found" — no bare "clean."
Use the role applicability protocol in `scan-checklist.md`. Inspect functions,
modules, closures, and classes; lack of inheritance or a named test-helper class
is not a skip reason. Qualify presentation IDs T-A46, T-A47, and T-A57 to
distinguish the design checks with the same numbers.

## Section A — Structural

**Sibling duplication** (collaborators serving related contracts):

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A14 | Sibling duplication | Related implementations, functions, hooks, and factories; compare state and behavior across all siblings | Repeated responsibility with the same reason to change requires a shared owner; choose composition or inheritance using the active binding |

**Cross-module duplication and tests:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A22 | Structural duplication | Similar implementations and test doubles across modules, including closure/object factories | Shared behavior duplicated across unrelated owners; extract a focused collaborator rather than forcing a common superclass |
| A52 | Repeated field assertions | Runs of assertions over the same object: exact, absent, nondeterministic, identity, or custom; identify a natural independently expected sibling | Use structural comparison for exact state, including round-trip siblings, with justified exclusions only. Keep independent behavioral/identity checks. Deliberate subsets without an expected sibling may stay explicit; extract repeated mixed assertion logic |
| A54 | Test helper mirrors production | Compare test computations with production transformations; distinguish setup from expected-value derivation | Replace duplicated expected-value algorithms with independent literal oracles, never calls to the implementation under test. Reuse public setup behavior only when it cannot compute or weaken the expected result |
| A23 | Assertion duplication | Repeated checks of the same contract across test helpers, modules, or scenario bodies | Give repeated assertion logic one focused owner while preserving independent expected values and diagnostic detail |
| A24 | Mixed assertion abstraction | Scenario bodies combining named actions with low-level multi-step observations | Extract named assertion helpers. Bindings may allow direct assertions, but cannot exempt mixed abstraction levels; preserve the binding's stricter narrative form where required |
| A37 | Scenario control flow | Loops and conditionals in scenario bodies, excluding test registration | Move setup/observation mechanics into focused helpers or explicit parameterized cases; do not hide scenario selection or weaken outcomes |
| A41 | Conditional or computed oracle | Branches and loops deriving expected outcomes from actual behavior | Use independent expected cases; collection assertions and bulk setup may iterate without reproducing production decisions |
| A31 | Test helper dependencies | All collaborators captured or injected into a test helper, fixture factory, or class | More than eight requires splitting by responsibility; smaller helpers still fail if they mix unrelated concerns |
| A38 | Test middlemen | Helpers that merely forward to another helper; identify semantic contribution | Remove redundant forwarding and call the owning helper directly; retain a wrapper only for a distinct contract or meaningful scenario vocabulary |
| A39 | Scenario abstraction | Technical setup literals and protocol details mixed into semantic scenario steps | Encapsulate incidental mechanics in fixtures; retain literal inputs and expected values that define the behavior being tested |
| A40 | Calculated expected values | Arithmetic, filtering, mapping, or parsing used to reproduce the tested result | Use independent expected values; never derive an oracle by reusing the production algorithm |
| A53 | Assertions legitimizing invalid model state | Absence/default assertions on model invariants versus intentionally optional boundary data | Do not normalize an invalid model state as expected behavior; preserve explicit optional states and follow TDD for any required behavior change |

**Presentation-specific** (where markup, rendering, or styles are present):

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A15 | Component size | Formatted component and render-body sizes; distinct responsibilities | Over 100 render lines requires component decomposition; A0/A1/A45 also apply to executable functions inside components |
| A15b | Distinct visual blocks | Separable visual sections, their inputs, and local state | Three or more independent blocks require named components following capability ownership; keep single-view helpers local unless shared |
| A16 | Mixed rendering branches | Render branches, their responsibilities, repeated markup, and nesting | Extract distinct views when branches mix concerns. Multiple guard returns are valid; replacing them with nested conditionals or a mutable render accumulator does not resolve the smell |
| A17 | Behavior in presentation | Validation, domain computations, transport, and multi-step event workflows | Move behavior to its model, controller, or adapter owner under `frontend-rules.md`; moving everything to one generic logic file does not establish separation |
| A18 | Render computations | Locals and inline expressions: snapshots, aliases, simple display values, or domain computations | Apply A8 and ownership rules. Extract distinct/repeated computations; retain meaningful local names and framework state bindings |
| A19 | Repeated style recipes | Repeated declarations or utility combinations and their owning design concept | Extract a semantic style owner for duplicated recipes; reuse of an existing semantic class is expected, not duplication |
| A46 | Opaque utility values | Arbitrary-value styling in markup and existing semantic styles, using active CSS binding syntax | Give opaque visual recipes a semantic style owner; list each location and intended class |
| A47 | Repeated conditional styles | Repeated branching over the same state to choose styles | Extract the shared style decision under its capability; preserve states and element structure |
| A57 | Utility chains | Standalone utility counts and overrides after semantic classes, using the active CSS binding | Two or more standalone utilities, any opaque utility, or two or more overrides after a semantic class require a named style recipe. A semantic base allows at most one small override; a separate layout/sizing concern still requires its own name |

## Section B — Read-and-judge (cite evidence)

**Test-specific** (tests, fixtures, and assertion helpers):

| # | Question | Evidence required |
|---|----------|------------------|
| B10 | Do fixed values in helpers hide variation required by existing scenarios? | Quote values and callers; retain complete short setup recipes only under `restraint.md` |
| B11 | Is construction used solely to feed one assertion helper adding unnecessary indirection? | Quote construction and use; preserve independent, readable expected values |

**Presentation-specific** (where markup, rendering, or styles are present):

| # | Question | Evidence required |
|---|----------|------------------|
| B12 | Is a presentation component truly shared across capabilities, or coupled to a broad controller/state contract? | Quote props and consumers; keep capability-specific views local and narrow their inputs, move genuinely shared UI to its shared owner |
