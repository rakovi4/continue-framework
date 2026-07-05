# Test Spec — Category Formats & Ordering

## 01_API_Tests.md (8-12 tests)

Tests are ordered for **sequential TDD implementation** — each section builds on the previous one. You can implement group N without needing group N+1.

Start every generated file with this header:
```markdown
> **Implementation Order**: Tests are numbered for sequential TDD implementation.
> Start with [story-specific progression summary].
```

**Ordering principles (apply in this priority):**
1. **Prerequisite guards first** — generate guard scenarios for every prerequisite listed in the story spec. See Prerequisite Guard Checklist below. Do NOT include generic auth (401 for unauthenticated) tests — those are tested globally by the security filter, not per-story.
2. **Read operations before writes** — GET before POST/PUT/DELETE. Less infrastructure needed. **Exception:** if a GET scenario's Given clause requires a write operation (e.g., "Given a task exists"), move that scenario after the write scenarios that create the precondition. A scenario must never depend on capabilities not yet implemented at its position in the TDD sequence.
3. **Validation before happy path** — within a write group, reject bad input first (needs only validation), then test success (needs full pipeline).
4. **Simple states before complex states** — default/initial state before edge cases (e.g., empty board before board with tasks).
5. **Verification/confirmation flows last** — depend on prior operations succeeding (e.g., email verification after registration, webhook after checkout).

**Structure:** Use `## N. Section Title` for groups, `### N.M Scenario Title` for individual tests. Separate sections with `---`.

**Typical section progression** (adapt to story — skip irrelevant sections, add story-specific ones):
```
## 1. Security Foundation
## 2. Read Current State (GET)
## 3. Create/Submit (POST) — Validation
## 4. Create/Submit (POST) — Happy Path
## 5. Verification/Confirmation/Callback
## 6. Additional Operations (PUT/DELETE)
```

Reference: `ProductSpecification/stories/01-create-task/tests/01_API_Tests.md`

### Prerequisite Guard Checklist

Stories declare prerequisites (e.g., "board must exist", "column must exist"). Each prerequisite MUST produce guard scenarios in BOTH `01_API_Tests.md` and `02_UI_Tests.md`.

**How to extract prerequisites:** Read the story's Prerequisites section and Validation Rules table. Each entry that gates the feature is a prerequisite.

| Prerequisite | API test scenarios | UI test scenarios |
|-------------|-------------------|-------------------|
| Board exists | Task created on non-existent board → 404 | Error message with "create board" CTA + navigation to boards |
| Column exists | Task created in non-existent column → 404 | Error message with "add column" CTA + navigation to board settings |
| Task ownership | Task not owned by user → 404 | (no UI test — user only sees own tasks) |
| CSRF token | Request without CSRF token → 403 | (handled by browser, no UI test needed) |

**Rules:**
- Generate one API scenario per prerequisite per endpoint (e.g., if story has PATCH and GET, test each)
- Generate UI blocker scenarios in a `## 0. Prerequisite Guards` section — display + navigation per blocker
- Cross-reference existing stories for established blocker patterns (e.g., Story 5 `02_UI_Tests.md` section 0)
- If a prerequisite has two states (unlinked vs expired), generate separate scenarios for each

### Side-Effect & Idempotency Guard Checklist

For every operation that **moves money, calls an external system, or mutates persisted state** AND can be re-run (scheduled job, webhook delivery, user-initiated retry), generate re-run-safety scenarios in BOTH directions. A re-run-safe operation produces the side effect at most once regardless of how many times it is triggered.

**How to extract operations:** Read the story spec and `interview.md` for any payment, external API call, email send, or batch state change. Each is a guard target. If unsure whether an operation is re-runnable, assume it is.

| Direction | What to assert | Example scenario |
|-----------|---------------|------------------|
| Inbound (duplicate event) | A duplicate trigger produces the same result with no duplicate side effect | Same webhook delivered twice → charged/recorded once |
| Outbound (re-attempt after partial failure) | A re-run after a crash or partial-batch failure does not repeat an already-completed side effect | Batch renews A, fails on B; next run must NOT re-charge A |

**Rules:**
- Both directions are mandatory for any money-moving operation — covering one (e.g. inbound webhooks) does NOT cover the other (e.g. outbound re-charge on retry). This is the exact gap that ships double-charge bugs.
- Place these in `01_API_Tests.md` (and `06_Integration_Tests.md` when an external system is involved), not in `extended/` — re-run safety for a side effect is critical-path, never nice-to-have.

## 02_UI_Tests.md (5-8 tests)

Same TDD-sequential ordering philosophy. Start with what needs the least code, build up.

Start every generated file with the same `> **Implementation Order**` header.

**Ordering principles:**
0. **Prerequisite guards first** — blocker pages for missing board, missing column. See Prerequisite Guard Checklist above.
1. **Page display first** — render, layout, fields visible. Just needs the component, no logic.
2. **Basic interaction before submission** — focus, toggles, input. Needs handlers, no API.
3. **Form submission with loading state** — submit button, spinner. First test triggering API.
4. **Client-side validation display** — inline errors on blur. Needs validation logic wired.
5. **Server response handling** — success/error messages. Needs API integration.
6. **Navigation and post-action flows** — redirects, links to related pages.

**Navigation coverage rule:** Every link, back-link, and navigation button that appears in a display scenario must have a corresponding scenario that **clicks it and verifies the destination**. Visibility-only assertions ("link is visible") are insufficient — users need confidence the link actually works. Group these click-and-navigate scenarios in the Navigation section. Examples:
- "back to login" link visible → separate scenario: click it → verify URL is `/login`
- "Go to dashboard" button visible → separate scenario: click it → verify dashboard page loads
- Step indicator / breadcrumb clickable → separate scenario: click step → verify navigation and state
These navigation scenarios are pure frontend (no API calls), so their TDD cycle skips `red-frontend-api` / `green-frontend-api` steps.

**Typical section progression:**
```
## 0. Prerequisite Guards (if story has prerequisites)
## 1. Page Display
## 2. User Interaction
## 3. Form Submission
## 4. Validation Feedback
## 5. Server Response Display
## 6. Navigation
```

## 03_Load_Tests.md (1-3 tests)

**Profile-driven, not one-size-fits-all.** Read the project's load reference document first — for this codebase that is `ProductSpecification/ExpectedLoad.md`. The reference declares a **Load Challenge Profile** naming the dominant production risk; pick the matching assertion class from the catalog below. Never invent a profile that the project doc has not declared.

### Load Challenge Profile catalog

| Profile | When it fits the project | What scenarios assert | What's out of scope for this profile |
|---|---|---|---|
| **Volume** | Data set grows large (millions of rows); few users, lots of data per user; risk is queries dying as the table grows | Correctness at full data scale, external-call batching/grouping behavior, wall-clock hang-guard ceiling (~5x a healthy indexed query) | Latency percentiles, sustained-throughput rates, concurrent-request scenarios, dual-volume linear-scaling tests |
| **Throughput** | High request rate; capacity per second is the constraint; many concurrent users | Sustained request rate over a window, queue depth bounds, downstream rate-limit compliance, error-rate ceiling under load | Full-table-volume seeding, single-request latency assertions |
| **Latency** | User-facing operations with strict response-time SLOs (interactive trading, real-time UX) | p95/p99 latency at expected concurrency, tail-latency guards, GC-pause / GC-allocation budget | Hang-guard-only ceilings (too loose for a latency SLO), volume seeding without realistic concurrency |
| **Big-data processing** | Batch jobs over TB-scale corpora, ETL, analytics pipelines | End-to-end job duration, peak memory ceiling, stream-vs-collect correctness, checkpoint/restart correctness, partition-skew handling | Per-request percentiles, small-batch ceilings |

A project may declare more than one profile when independent subsystems carry distinct risks. Most projects pick one.

### Relevance filter — skip the file entirely (set `Load = n/a` in `stories.md`) when:

- The story is a one-shot per-user action whose lifetime volume is bounded by user count (e.g., Login/Logout, Registration, Password Reset, Link API Key, Subscription Management).
- The story has no operation that exercises the project's declared profile (no scaling DB query for Volume; no high-rate endpoint for Throughput; no SLO-bound interaction for Latency; no batch job for Big-data).

If neither condition holds, generate the file.

### Scenario authoring rules (apply to any profile)

- **Title describes behavior, not numbers.** Use "Task list page 1 returns the user's first 20 tasks" — NOT "Task list page 1 returns 20 entries when user owns 2,000 tasks". The numeric setup is implicit in the project baseline.
- **One assertion class per scenario.** Pick the class that matches the project's profile. Document the threshold with a one-line annotation under the gherkin block (e.g., `Ceiling: paged list — 500ms. Catches {regression}.` for Volume; `Threshold: 200 req/s sustained over 60s.` for Throughput).
- **External-call assertions go through existing Fakes.** Never introduce new test infrastructure for load specs.
- **Section grouping.** Group scenarios by concern (paging / aggregation / scheduler tick / bulk write for Volume; endpoint group for Throughput; user flow for Latency; job stage for Big-data). One concern per `##` section.
- **1-3 scenarios per story typical.** Add a scenario only when it catches a distinct regression. Two scenarios exercising different code paths make sense; two near-duplicates do not.

### File layout

```
# {Story} — Load Tests

{One-line intro: name the profile this story's load tests target and reference the project's load doc.}

---

## 1. {Concern at the relevant scale or rate}

### 1.1 {Scenario title — behavior, not numbers}

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
```


## 04_Infrastructure_Tests.md (2-3 tests)
1. Database connection failure handling
2. Database recovery after failure
3. External service unavailable handling

## 05_Security_Tests.md (6-10 tests)

Generate **only scenarios relevant to the story's actual attack surface**. Do not include generic OWASP items that don't apply.

**Relevance filtering — skip if:**
- Technology not in stack (NoSQL injection when using JPA, LDAP when no LDAP, XXE when JSON-only)
- Attack has no surface (SSRF when endpoint doesn't fetch external resources, session fixation with JWT cookies)
- Concern is cross-cutting and tested globally (generic 401 for unauthenticated, security headers, CORS, HTTPS — these belong in a global security hardening task, not per-story)
- Timing attacks on non-sensitive operations (registration validation timing)

**Stack-aware checklist — include when relevant to the story:**

| Category | When to include | Example |
|----------|----------------|---------|
| SQL injection | Story has user input that reaches DB queries | Registration, search, filters |
| XSS | Story stores/displays user-provided text | Company name, product names |
| CSRF | Story has state-changing POST/PUT/DELETE with cookie auth | Login, registration, task creation |
| Mass assignment | Story accepts JSON body mapped to DTO | Registration (role), task creation |
| Input length limits | Story has text fields with size constraints | Email, password, URLs |
| Rate limiting | Story has abuse-prone endpoint | Login (brute force), registration (bots) |
| Password hashing | Story handles password storage | Registration, password change |
| IDOR | Story has resource endpoints with IDs | GET/PUT/DELETE /tasks/{id}, /boards/{id} |
| JWT security | Story issues or validates JWT tokens | Login (algorithm confusion, expiration, revocation) |
| Input validation | Story accepts user text input | Task title, description |

**Merge related scenarios**: combine SQL injection across fields into one scenario, combine input length limits into one scenario. Aim for 6-10 focused tests, not 50 generic ones.

## 06_Integration_Tests.md (3-4 tests)
1. External API success flow
2. External API error handling
3. External API timeout handling
4. Token refresh flow

## BDD Format Rules

1. Use Gherkin syntax with domain-specific language (DSL)
2. No technical details in scenario steps
3. Fold repeating sequences into reusable statements
4. End each file with DSL Technical Reference table:

```markdown
## DSL Technical Reference

| DSL Statement | Technical Implementation |
|---------------|-------------------------|
| `an authenticated user` | Valid JWT in Authorization header |
| `the user submits registration` | POST /api/auth/register |
```
