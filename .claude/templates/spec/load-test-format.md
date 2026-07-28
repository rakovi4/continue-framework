# 03_Load_Tests.md — Format (1-3 tests)

The `03_Load_Tests.md` section of [`test-spec-format.md`](test-spec-format.md),
held here because it is profile-driven and self-contained. Tier assignment for
these scenarios follows the ladder in [`tier-ladder.md`](tier-ladder.md) like any
other category — a load scenario is not automatically a lower tier.

**Profile-driven, not one-size-fits-all.** Read the project's load reference document first — for this codebase that is `ProductSpecification/ExpectedLoad.md`. The reference declares a **Load Challenge Profile** naming the dominant production risk; pick the matching assertion class from the catalog below. Never invent a profile that the project doc has not declared.

## Load Challenge Profile catalog

| Profile | When it fits the project | What scenarios assert | What's out of scope for this profile |
|---|---|---|---|
| **Volume** | Data set grows large (millions of rows); few users, lots of data per user; risk is queries dying as the table grows | Correctness at full data scale, external-call batching/grouping behavior, wall-clock hang-guard ceiling (~5x a healthy indexed query) | Latency percentiles, sustained-throughput rates, concurrent-request scenarios, dual-volume linear-scaling tests |
| **Throughput** | High request rate; capacity per second is the constraint; many concurrent users | Sustained request rate over a window, queue depth bounds, downstream rate-limit compliance, error-rate ceiling under load | Full-table-volume seeding, single-request latency assertions |
| **Latency** | User-facing operations with strict response-time SLOs (interactive trading, real-time UX) | p95/p99 latency at expected concurrency, tail-latency guards, GC-pause / GC-allocation budget | Hang-guard-only ceilings (too loose for a latency SLO), volume seeding without realistic concurrency |
| **Big-data processing** | Batch jobs over TB-scale corpora, ETL, analytics pipelines | End-to-end job duration, peak memory ceiling, stream-vs-collect correctness, checkpoint/restart correctness, partition-skew handling | Per-request percentiles, small-batch ceilings |

A project may declare more than one profile when independent subsystems carry distinct risks. Most projects pick one.

## Relevance filter — skip the file entirely (set `Load = n/a` in `stories.md`) when:

- The story is a one-shot per-user action whose lifetime volume is bounded by user count (e.g., Login/Logout, Registration, Password Reset, Link API Key, Subscription Management).
- The story has no operation that exercises the project's declared profile (no scaling DB query for Volume; no high-rate endpoint for Throughput; no SLO-bound interaction for Latency; no batch job for Big-data).

If neither condition holds, generate the file.

## Scenario authoring rules (apply to any profile)

- **Title describes behavior, not numbers.** Use "Task list page 1 returns the user's first 20 tasks" — NOT "Task list page 1 returns 20 entries when user owns 2,000 tasks". The numeric setup is implicit in the project baseline.
- **One assertion class per scenario.** Pick the class that matches the project's profile. Document the threshold with a one-line annotation under the gherkin block (e.g., `Ceiling: paged list — 500ms. Catches {regression}.` for Volume; `Threshold: 200 req/s sustained over 60s.` for Throughput).
- **External-call assertions go through existing Fakes.** Never introduce new test infrastructure for load specs.
- **Section grouping.** Group scenarios by concern (paging / aggregation / scheduler tick / bulk write for Volume; endpoint group for Throughput; user flow for Latency; job stage for Big-data). One concern per `##` section.
- **1-3 scenarios per story typical.** Add a scenario only when it catches a distinct regression. Two scenarios exercising different code paths make sense; two near-duplicates do not.

## File layout

````
# {Story} — Load Tests

{One-line intro: name the profile this story's load tests target and reference the project's load doc.}

---

## 1. {Concern at the relevant scale or rate}

### 1.1 {Scenario title — behavior, not numbers}

Tier: ?

```gherkin
Given {the project baseline DSL — e.g., "the standard load baseline" for Volume, "the configured throughput baseline" for Throughput}
And {scenario-specific data on top}
When {the action under test}
Then {correctness assertion}
And {external-system assertion, if applicable}
And {the profile-appropriate threshold DSL — e.g., "the response completes within the {bucket} ceiling" for Volume, "the endpoint sustains {N} req/s over {window}" for Throughput}
```

{Threshold annotation: profile-specific value and the regression this scenario detects.}

---

## DSL Technical Reference

| DSL Statement | Technical Implementation |
|---------------|-------------------------|
| `{the baseline DSL}` | {Pointer to the project's baseline setup in its load doc} |
| ... | ... |
| `{the threshold DSL}` | {How the threshold is measured — wall-clock duration, throughput counter, p99 timer, batch duration, etc.} |
````
