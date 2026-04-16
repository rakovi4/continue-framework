# Prompt Update Classification Guide

## Layer Responsibilities

See `.claude/rules/prompt-rules.md` for the authoritative layer table.

Writing style by layer:
- **Rules**: Declarative — "Never X", "Prefer Y over Z", "Use A when B"
- **Agents**: Imperative checklists — grep patterns, decision tables, step sequences
- **Templates**: Fenced code blocks with BAD/GOOD labels, numbered rules, tables
- **Skills**: Only layer-specific context unique to one adapter/layer

## Decision Process

For each piece of content, ask:

1. **Is there a universal principle?** → Rules file. Pick the right one by topic (see topic table below).
2. **Is it technology-specific?** (mentions a framework, annotation, library, CLI command) → Tech binding (`.claude/tech/{concern-value}/{binding}.md`) or tech template (`.claude/tech/{concern-value}/templates/`). See `.claude/rules/technology-loading.md` for the binding-to-topic mapping.
3. **Is there a detection pattern (grep, checklist item)?** → Agent that runs the detection.
4. **Is there a code example, anti-pattern, or before/after?** → Template the agent references. Universal patterns → `.claude/templates/`, tech-specific patterns → `.claude/tech/{concern-value}/templates/`.
5. **Is there layer-specific context?** → Skill or template for that layer.

Often the answer is "yes to multiple" — that means multiple files get updated. A common split: universal principle → rules file, tech-specific example → tech binding or tech template.

## Rules File by Topic

Universal rules (`.claude/rules/`) — tech-agnostic principles only:

| Topic keywords | Target |
|---------------|--------|
| architecture, dependency, layer, import, domain, usecase, adapter | `coding-rules.md` |
| TDD, test, red, green, refactor, assertion, fake, Statements | `tdd-rules.md` |
| frontend, component, logic file, API client, Selenium, humble object | `frontend-rules.md` |
| documentation, prompt, agent, skill, template, layer placement | `prompt-rules.md` |
| workflow, story, interview, spec, progress, scenario | `workflow.md` |
| tech profile, tech binding, technology loading, conventions table | `technology-loading.md` |

Tech bindings (`.claude/tech/{concern-value}/`) — framework-specific idioms:

| Topic keywords | Target binding |
|---------------|----------------|
| language annotations, DI framework, ORM, exception classes | `coding.md` |
| test framework, assertion library, mock library, coverage tool, test disable marker | `tdd.md` |
| frontend framework, test runner, HTTP mock library, bundler | `frontend.md` |
| build tool commands, process management, config syntax | `infrastructure.md` |

## Agent Checklist Structure

Several agents have mandatory checklists with numbered items and grep patterns. When adding a detection check, match the existing format:

| Agent | Checklist location | Format |
|-------|-------------------|--------|
| `test-review-agent.md` | Mandatory Checklist table | `\| # \| Check \| Grep pattern \| Where \| Violation if found \|` |
| `prompt-refactor-agent.md` | Smell-to-Fix Table | `\| Smell \| Fix \|` |
| `refactor-agent.md` | Smell Detection table | `\| Smell \| Detection \| Template \|` |

## Template Sections

Templates often have multiple distinct sections that need coordinated updates:

| Template | Sections |
|----------|----------|
| `.claude/templates/testing/test-review-patterns.md` | Anti-Pattern Catalog (descriptions), Assertion Rules (numbered list), Assertion Improvements (concept-level table), Output Summary Format |
| `.claude/tech/{backend}/templates/testing/test-review-patterns.md` | Anti-Pattern Examples (BAD/GOOD code in language syntax), Correct Patterns (code), Assertion Improvements (syntax-specific table), Tech-Specific Rules |
| `documentation/prompt-scan-checklist.md` | Check items with IDs (A1-A5 structural, B1-B5 placement) |
| `refactoring/scan-checklist.md` | Smell detection patterns |

## Examples

### Single-target: new coding principle

**Input:** "Prefer switch over if/return chains when branching on a single variable"
**Classification:** Universal principle about code style → `coding-rules.md`
**Action:** Add to Code Style section.

### Tech-specific content

**Input:** "Always use `eq()` not `any()` in Mockito verify calls"
**Classification:** Technology-specific (Mockito is a library) → tech binding `.claude/tech/{concern-value}/tdd.md`
**Action:** Add to test framework idioms in the tech binding. NOT in universal `tdd-rules.md`.

### Multi-target: new test-review check

**Input:** "test-review should catch Statements that assert via Fake storage instead of through usecases"
**Classification:**
- Principle exists in `tdd-rules.md` ("NEVER inject storage adapters into Statements") — check if already there
- Detection pattern needed → `test-review-agent.md` checklist (new row)
- Anti-pattern description + assertion rule → `.claude/templates/testing/test-review-patterns.md` (universal)
- Anti-pattern code examples + syntax table row → `.claude/tech/{backend}/templates/testing/test-review-patterns.md` (per tech profile)

**Action:** Write to all three locations.

### Multi-target: new refactoring pattern

**Input:** "Extract opaque Tailwind utility chains into semantic @apply classes"
**Classification:**
- Principle about when to extract → `frontend-rules.md` (new section)
- Detection pattern for scan → `refactoring/scan-checklist.md` (new A-check in Frontend section)
- Smell → fix mapping → `refactor-agent.md` (new row in Frontend smell table)
- Step-by-step how-to with code examples → new `templates/refactoring/extract-tailwind-class.md`

**Action:** Write to all four locations. Agent smell table references the new template.

### Layer-specific: new adapter convention

**Input:** "H2 adapter tests should use FixtureCleanerExtension"
**Classification:** Layer-specific to h2 adapter → `templates/h2/test-class.md`
**Action:** Add to the h2 test template, not to universal rules.

## Tech-Agnostic Verification

Before finalizing any write to a universal file (`.claude/rules/`, `.claude/templates/`), scan the content for tech leaks. Universal content must pass the boundary test from `prompt-rules.md`: if it mentions a specific language, framework, annotation, library, or CLI command, it belongs in the tech binding or tech template — not the universal layer.

**Scan for these indicators:**

| Indicator | Examples | Fix |
|-----------|----------|-----|
| Language-specific syntax | `throw new UnsupportedOperationException()`, `@Disabled`, `def`, `func` | Replace with generic term: "not-implemented marker", "test disable marker" |
| Framework annotations/decorators | `@RestController`, `@ResponseStatus`, `@pytest.mark`, `#[derive]` | Describe the concept: "endpoint method", "HTTP status annotation" |
| Library names | Mockito, JUnit, pytest, Express, Spring | Use generic: "mock library", "test framework", "web framework" |
| Concrete types from a language | `void`, `CompletableFuture<T>`, `Promise<Response>` | Describe behavior: "returns no body", "returns asynchronous result" |
| Build/CLI commands | `mvn test`, `npm run`, `cargo build` | Reference "the build tool" or "see Conventions table in technology.md" |
| Code snippets in a specific language | Java method signatures, Python function defs | Use pseudocode or prose description; put real code in tech templates |

**If a leak is found:** Default to rephrasing in universal terms — replace the tech-specific word with the concept it represents (see Fix column above). Most leaks are just word choice; the idea itself is universal. Only relocate to `.claude/tech/{concern-value}/` when the content is inherently tech-specific and cannot be expressed generically (a code example, a framework idiom, a library-specific API pattern).

## Impact Assessment

After writing, determine whether the update changes **expected behavior** of any skill.

### Mapping updated files to affected agents and skills

| Updated file pattern | Affected agents / skills |
|---------------------|--------------------------|
| `rules/coding-rules.md`, `agents/refactor-agent.md`, `templates/refactoring/*` | `refactor-agent` |
| `rules/tdd-rules.md`, `agents/test-review-agent.md`, `templates/testing/*` | `test-review-agent` |
| `rules/tdd-rules.md`, `agents/red-agent.md`, `tech/{concern-value}/templates/*` | `red-agent` |
| `rules/tdd-rules.md` | `/test-acceptance`, `/design-preview` |
| `agents/green-agent.md`, `tech/{concern-value}/templates/*` | `green-agent` |
| `rules/frontend-rules.md`, `tech/{concern-value}/templates/frontend/*` | `red-agent`, `green-agent` (frontend layers), `/mockups` |
| `rules/workflow.md`, `rules/technology-loading.md` | `/continue`, `/task` |
| `templates/spec/*` | `/interview`, `/story`, `/api-spec`, `/test-spec`, `/design-preview`, `/architecture` |
| `templates/ui/*` | `/mockups` |
| `templates/task/*` | `/task` |
| `templates/workflow/*` | `/continue` |
| `tech/{browser-testing}/templates/align-design-*` | `/align-design` |
| `tech/{browser-testing}/templates/design-review-*` | `design-review-agent` |
| `technology.md`, `infrastructure/.env` | `/demo`, `/test-acceptance`, `/align-design` |
| `tech/{concern-value}/coding.md`, `tech/{concern-value}/tdd.md`, etc. | All agents that load tech bindings |

### When to run `/skill-creator`

**Run it** when the update changes what a skill should **do differently** — a new smell to detect, a new pattern to follow, a new constraint to respect.

**Skip it** when the update is organizational (moving content between layers), fixes a typo, improves wording without changing meaning, or adds documentation that no skill directly acts on.

Propose a concrete test prompt that exercises the specific behavior the update should change.
