# Mandatory Scan Checklist

**Run EVERY check on the target file. Show results. Fix violations before declaring clean.**

## Applicability by responsibility

Read `coding-detail.md` for every scope and `frontend-rules.md` for frontend work.
Map targets to actual responsibilities; a file may have several roles. Technology
bindings supply syntax and representations, never a weaker engineering standard.

| Responsibility | Apply |
|----------------|-------|
| All source, tests, and helpers | Mechanics, ownership, duplication, cohesion, type safety, error handling where present, and file organization |
| Model and state | Invariants, valid states, derived values, owned transitions, and variant behavior; includes client state and test doubles |
| Orchestration | Named steps, narrow dependencies, computation/effect separation, and operation boundaries; includes callbacks and lifecycle hooks |
| Boundary | Typed decoding, mapping, error translation, and resource lifetime; includes transport and browser adapters |
| Persistence/query mechanism | Storage-specific checks where present; absence of persistence does not skip other design checks |
| Presentation | Rendering, component composition, and styles in addition to shared checks |
| Tests | Scenario abstraction, fixtures, assertion quality, independent oracles, and duplication regardless of test syntax |

For every row report findings, enumerated clean evidence, or NOT_APPLICABLE with
the absent responsibility/mechanism and inspected paths. A missing syntax match
is not evidence of absence: inspect its equivalent in the active language.
Never skip shared checks because a target lacks classes, a particular extension,
inheritance, or a named test-helper convention. Qualify reused IDs by cluster.
Frozen contracts and lane locks require coordinator ownership resolution; they
cannot turn a real violation into CLEAN.

The checklist is organized by cluster. A combined scope worker loads all three;
an explicitly selected cluster detector loads only its assigned file:

- **`scan-mechanics.md`** — cluster M checks (structural mechanics).
- **`scan-design.md`** — cluster D checks (design + domain-judgment).
- **`scan-duplication.md`** — cluster T checks (duplication, tests, frontend).
- **`code-smells-routing-table.md`** — smell → fix → template map (serial fixer only).

## Checklist clusters

Use `quality-execution.md` in the workflow templates for scope-based scheduling
and validated reuse. The default scope worker runs all clusters; the agents below
remain available for an explicitly selected concurrent cluster fan-out. Partitioned
scope inspectors also run all applicable clusters within their assigned scope.
Apply one refactoring at a time per writable scope, rescanning affected checks.
This table remains the authoritative check routing, regardless of dispatch mode.

| Cluster | Detector agent | Loads | Section A categories | Section B |
|---------|---------------|-------|----------------------|-----------|
| **M — Mechanics** | `refactor-mechanics-agent` | `scan-mechanics.md` | Formatting (A60); Class size (A0); Complexity (A1, A2, A26); Optional (A5, A5b); Variables, lambdas & comments (A8, A9, A58, A32, A25, A27, A28, A29, A59, A30, A45); Indirection (A20, A21, A55); Imports (A10, A36); Dead code (A11, A11b) | — |
| **D — Design** | `refactor-design-agent` | `scan-design.md` | Data ownership (A3, A4); Repetition (A6, A7, A7b); Polymorphism (A46, A47, A48); Error handling (A57, A57b); Cohesion & parameter groups (A49, A50, A51); Type safety (A12, A13, A13b); Usecase design (A35, A56); Storage adapter design (A33, A34, A42, A43, A44) | Domain modeling (B1–B3); Behavior placement (B4–B9); File organization (B13) |
| **T — Duplication & surface** | `refactor-duplication-agent` | `scan-duplication.md` | Sibling duplication (A14); Cross-module duplication and tests (A22, A52, A54, A23, A24, A37, A41, A31, A38, A39, A40, A53); Presentation (A15, A15b, A16, A17, A18, A19, A46, A47, A57) | Test-specific (B10, B11); Presentation (B12) |

The numbers **A46/A47/A57** are reused for design (cluster **D**) and presentation
(cluster **T**) checks. Qualify them by cluster, not runtime or extension.
Cluster D checks client and server models/orchestration and all error handlers;
cluster T adds presentation checks wherever rendering/styles exist. The fixer owns
the **Code Smells Routing Table** (`code-smells-routing-table.md`) and applies
templates; detectors only name the prescribed fix.

## Scan output format

**Record complete check results before applying refactoring.** Store enumerations
once and reference them from checks and later phases. Validated reuse identifies the
prior check, inputs, and result; it never substitutes a bare PASS for evidence.

**Enumeration rule:** Every check that says "enumerate", "list", "count", or "for each" MUST show the data, even when clean. Judgment checks cite inspected behavior or explain that none was found. NOT_APPLICABLE follows the role protocol above; bare language/file-type skips are invalid. B13 always requires grouping evidence. Preserve every candidate's FIX or evidenced KEEP disposition, including those declined by a detector.

Run A60 before treating A0/A1 counts as final. Read-only detectors report formatting
defects without rewriting files; the serial fixer formats and remeasures before
choosing extractions. Include formatting verification and B13 grouping evidence in
the scan result even when the candidate table is empty.

Example result entries (expand every check in its owning cluster):

| Check | Evidence | Disposition |
|-------|----------|-------------|
| A1 | Operation is 34 lines: eligibility, validation, pending transition, request, result publication | FIX: extract named model decisions and transitions; retain ordered orchestration |
| A8/A32 | Getter only returns owned state; request performs network I/O | Keep required snapshot; isolate request result; injection does not determine effects |
| D-A48 | Controller mixes a validation rule, transport call, and field updates | FIX: delegate validation and transition details to the model |
| A23 | Two assertion helpers duplicate the same contract checks | FIX: one assertion owner with independent expected values |
| A33 | Inspected client model and its consumers contain no persistence or row mapping | NOT_APPLICABLE: no storage mechanism; other design checks still ran |
| B13 | Per-file inventory and capability boundary verdicts attached | Every MOVE resolved or reported as blocked by ownership |

The final result must account for every applicable check; this example is not
permission to sample a subset.
**If any item has a violation, fix it BEFORE reporting "no issues."**
