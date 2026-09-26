# Scan — Cluster M: Mechanics (structural)

Part of the refactor scan, run by `refactor-mechanics-agent`. Hub + cluster
routing + output format: `scan-checklist.md`. Fix templates: `code-smells-routing-table.md`.

Produce structural data for all executable forms, including functions, callbacks,
closures, and methods. Use the role applicability protocol in `scan-checklist.md`;
translate syntax through the active binding instead of skipping a principle.

**Formatting:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A60 | Packed statements and missing spacing | Cite lines containing multiple statements, collapsed block bodies, multiple stylesheet declarations, or missing separation between methods. Check the remaining Source Formatting rules; record formatter verification or manual inspection. | Put statements and declarations on separate lines, expand blocks, and restore readable spacing; then remeasure A0/A1 |

**Class size & responsibility:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A0 | File / class size & concerns | Every physical line after Source Formatting in the coding rules, including blank lines and imports; implemented interfaces/ports and distinct responsibility groups. Applies to every file type. If A60 fails, report current counts as provisional and require remeasurement after formatting. | >200 formatted lines OR 2+ unrelated interfaces; compressed source cannot pass by its raw count |

**Complexity:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A1 | Function sizes | Every function, method, callback, and effect body: formatted physical lines, responsibilities, abstraction levels, and possible extraction boundaries | Over 10 lines requires decomposition or the per-function KEEP evidence in `restraint.md`; shared state, asynchronous ordering, or a lifecycle name alone cannot justify KEEP |
| A2 | Nesting depth | Control-flow depth in every executable body, including callbacks | More than one level requires flattening or named extraction; preserve required error/lifetime boundaries and justify retained nesting under `restraint.md` |
| A26 | Repeated variant branching | Three or more branches comparing the same value against constants | Use exhaustive dispatch at the owning responsibility; preserve clear guard returns and do not manufacture an accumulator merely to force one return |

**Optional:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A5 | Optional handling | Every representation of absence and its access/unwrap pattern | Replace redundant check-then-unwrap with the active binding's safe optional handling; preserve required narrowing and legitimate guards |
| A5b | Optional request fields | Optional fields in internal operation requests and their boundary conversions | Ambiguous missing/default values or unchecked absence reaching model logic; normalize at the boundary using explicit optional states |

**Variables & lambdas:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A8 | Local variables | All locals: classify aliases, named computations, stable snapshots/identities, and effect results; inspect the called behavior | Inline disposable aliases; extract distinct or repeated computations; keep meaningful names, required snapshots, and effect isolation. Injection alone does not establish an effect |
| A9 | Forwarding callbacks | Callbacks that only forward arguments to another operation | Use a direct reference when binding, argument shape, and lifetime remain identical; otherwise retain the adapter with evidence |
| A58 | Type-inference local declarations | Local variables declared with the language's type-inference shorthand instead of an explicit type (see tech binding for the keyword and policy). | Per tech binding — any occurrence where the binding forbids type inference. An inferred type forces the reviewer to derive it from the right-hand side; an explicit type is self-documenting in diffs. |
| A32 | Effects hidden in expressions | Nested network, persistence, scheduling, mutation, clock, or other time-dependent calls; identify actual behavior and evaluation order | Isolate effects before pure mapping. Do not expand pure accessor calls merely because the object was injected; preserve snapshot timing and short-circuit behavior where observable |
| A25 | Collection transformations | Loops implementing mapping, filtering, aggregation, or search | Use the active binding's collection operations when they clarify the transformation without changing ordering, short-circuiting, or effects |
| A27 | Inline multi-step pipeline | Two or more transformations embedded in a function that also owns another concern | Extract the transformation into a named operation; preserve evaluation and asynchronous order |
| A28 | Functional wrappers | Returned callbacks and factories wrapping imperative work; list captured values and lifetime | Remove redundant indirection; retain callbacks that own meaningful identity, subscription cleanup, or lifetime, with that responsibility stated |
| A29 | Comment-labeled responsibilities | For each section comment, inspect whether its block has a distinct responsibility; cite the behavior and shared state. Route comment removal through A59. | Extract only a distinct responsibility when restraint permits; a comment or whitespace alone does not justify extraction |
| A59 | Source comments | Count comment-only lines and enumerate every contiguous source comment block (`start–end`, line count). Identify what information or directive must be preserved elsewhere before removal. | Any source comment. Preserve essential information through names, types, tests, executable configuration, or owning documentation, then delete the comment. No `KEEP` classification exists. |
| A30 | Blank line wrapped sections | List blocks separated by blank lines inside methods; describe each block’s purpose and shared state. Exclude spacing between declarations, methods, and imports. | Extract each block into a method named for its purpose, subject to extraction restraint; never delete the blank lines as the fix |
| A45 | Mixed sequential responsibilities | Consecutive validation, state transitions, transport, mapping, or assertions; enumerate purposes and values exchanged | Extract distinct responsibilities even when they share intermediate state; pass values or use the owning model. Shared data is not evidence of a single concern |

**Indirection:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A20 | Thin wrappers | Methods whose entire body is a single delegation to another method in the same class, passing only constants/hardcoded values. List each wrapper → target method + hardcoded args. | Any delegate-only method |
| A21 | Single-value parameters | Parameters that receive the same argument at every call site. For each method parameter, grep all callers. | Parameter always receives one value |
| A55 | Derivable parameters | Parameters whose values can be obtained from another parameter; list all callers | Remove redundant parameters unless they intentionally capture a different snapshot or independently expected test value |

**Imports:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A10 | Qualified fixed values | Repeated qualifications in expressions; inspect binding conventions and naming collisions | Apply the active binding's import conventions while keeping ownership unambiguous |
| A36 | Repeated fully qualified names | Repeated module/type qualification in executable expressions | Use imports or meaningful aliases under the active binding; resolve name collisions explicitly |

**Dead code:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A11 | Unused code | Unreferenced functions, members, exports, fixtures, and styles; inspect consumers, discovery, and dynamic registrations | Remove code with no consumer after verifying framework discovery and external contracts |
| A11b | Unreachable branches | Coverage findings and source markers that claim unreachability; verify each path against contracts | Delete proven unreachable code; lack of coverage alone is not proof. Remove source comments through A59 |
