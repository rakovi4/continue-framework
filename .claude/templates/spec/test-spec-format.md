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

## 03_Load_Tests.md (3-5 tests)
1. Single request response time (<200ms)
2. Concurrent requests (50 users, <500ms)
3. Queue/batch processing performance
4. Volume tests — large data sets (e.g., board with 1000 tasks, task with max-length fields, bulk operations). Verify the system handles high data volumes without timeout or memory issues.

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
