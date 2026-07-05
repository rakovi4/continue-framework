# Mandatory Scan Checklist

**Run EVERY check on the target file. Show results. Fix violations before declaring clean.**

Skip checks marked with a file-type tag that doesn't match the target file.

The checklist is split **per cluster** — each detector loads only its own file,
nothing more:

- **`scan-mechanics.md`** — cluster M checks (structural mechanics).
- **`scan-design.md`** — cluster D checks (design + domain-judgment).
- **`scan-duplication.md`** — cluster T checks (duplication, tests, frontend).
- **`code-smells-routing-table.md`** — smell → fix → template map (serial fixer only).

## Detector clusters (parallel scan)

`/refactor` fans the scan out to **three read-only detector agents** that run in
parallel, then a **single serial fixer** applies fixes one refactoring at a time
(re-scanning cascades after each). Each detector runs ONLY the categories below.
Every check belongs to exactly one cluster — this table is the single source of
truth, so the per-row checks never drift out of sync with the split.

| Cluster | Detector agent | Loads | Section A categories | Section B |
|---------|---------------|-------|----------------------|-----------|
| **M — Mechanics** | `refactor-mechanics-agent` | `scan-mechanics.md` | Class size (A0); Complexity (A1, A2, A26); Optional (A5, A5b); Variables & lambdas (A8, A9, A58, A32, A25, A27, A28, A29, A30, A45); Indirection (A20, A21, A55); Imports (A10, A36); Dead code (A11, A11b) | — |
| **D — Design** | `refactor-design-agent` | `scan-design.md` | Data ownership (A3, A4); Repetition (A6, A7, A7b); Polymorphism (A46, A47, A48); Error handling (A57, A57b); Cohesion & parameter groups (A49, A50, A51); Type safety (A12, A13, A13b); Usecase design (A35, A56); Storage adapter design (A33, A34, A42, A43, A44) | Domain modeling (B1–B3); Behavior placement (B4–B9) |
| **T — Duplication & surface** | `refactor-duplication-agent` | `scan-duplication.md` | Sibling duplication (A14); Cross-class duplication (A22, A52, A54, A23, A24, A37, A41, A31, A38, A39, A40, A53); Frontend (A15, A15b, A16, A17, A18, A19, A46, A47, A57 — `.tsx` only) | Test-specific (B10, B11); Frontend (B12) |

The numbers **A46/A47/A57** are reused for backend (cluster **D**) and frontend
(cluster **T**) checks — the file-type tag disambiguates: cluster D runs them
only on domain/usecase source, cluster T only on `.tsx`. The serial fixer owns
the **Code Smells Routing Table** (`code-smells-routing-table.md`) and applies
templates; detectors only name the prescribed fix.

## Scan output format

**Print this filled checklist before starting refactoring.**

**Enumeration rule:** Every check that says "enumerate", "list", "count", or "for each" MUST show the enumerated data — even when clean. Write `→ clean` after the data shows no violation. Bare `[clean]` is only allowed for: (1) file-type skips (`[storage — skipped]`, `[frontend — skipped]`), (2) judgment checks (Section B) where the answer is "none found."

```
### A. Structural
A0.  Class size: 85 lines, 1 interface, 1 concern → clean
A1.  Method sizes: methodA=7, methodB=9 → clean
A2.  Nesting depth: methodA=0, methodB=1 → clean
A3.  Feature envy: methodA reads self only; methodB reads order.{amount, currency} → VIOLATION
A4.  Getter chains: methodB: order.getItems().get(0).getPrice() → VIOLATION
A5.  Optional handling: none → clean
A6.  Repeated construction: TaskRequest.builder() ×2 → VIOLATION
A7.  Repeated expressions: toDo.getTasks() ×2 (L47, L48) → VIOLATION
A7b. Near-duplicate blocks: stubSucceeded ≈ stubCanceled → VIOLATION
A8.  Locals: orderId (pass-through, 1 use) → inline; result (side-effect) → KEEP
A9.  Lambda→ref: L55 x -> new Foo(x) → VIOLATION
A10. Enum qualification: TaskStatus.DONE L30 → VIOLATION
A11–A14. Null args L18 → VIOLATION; sibling duplication → VIOLATION; rest: none found
A20. Thin wrappers: none → clean
A21. Single-value params: process(type) — all callers pass "EMAIL" → VIOLATION
A55. Derivable params: assertRoundTrip(actual, original, title, desc) — title=original.getTitle(), desc=original.getDescription() → VIOLATION
A25–A32. Inlined dep call L30 → VIOLATION; rest: none found
A33–A34. [storage — skipped]
A42–A44. [storage — skipped]
A45–A48. [polymorphism — skipped if not domain/usecase]
A49–A51. Bloated entity: 5 fields → clean; repeating params: none → clean; external rebuild: none → clean
A52–A53. [test-specific checks if applicable]
A15–A19. [frontend — skipped]

### B. Judgment
B1.  Primitive obsession: `String email` in RegisterRequest L12 → VIOLATION
B2–B4. [clean]
B5.  Caller checks+throws: task null check L25-28 → VIOLATION
B6–B9. [clean]
B10. Hardcoded helpers: givenUser() uses "test@example.com" L44 → VIOLATION
B11–B12. [clean]
```
**If any item has a violation, fix it BEFORE reporting "no issues."**
