# Documentation Conventions

## Knowledge Persistence: committed files, not personal memory

This project is developed across multiple local repo clones and by multiple developers. Durable project knowledge MUST live in version-controlled files so every clone and every teammate sees the same thing.

- **Do NOT use the assistant's personal/auto memory** (the per-user, per-machine memory store outside the repo). It is invisible to teammates and to other clones, is never code-reviewed, and silently drifts out of sync across the repos. Treat it as off — do not write to it, and do not rely on anything recalled from it without re-verifying against the repo. If a durable fact surfaces only in personal memory, relocate it into the appropriate committed file (below) and let the personal copy lapse.
- **Capture durable knowledge in committed files instead**, by kind:
  - Working principles, conventions, smells → `.claude/rules/` (this layer system) or `.claude/tech/{concern-value}/` for tech-specific idioms.
  - Architectural decisions, infra topology, external-system facts → `ProductSpecification/decisions/*.md` and the relevant `ProductSpecification/` docs (use `/doc`).
  - Cross-conversation "why" for in-flight work (predictions, surprises, quirks) → the story/task journey summaries and `carryover.md` (written only by `/handoff`; see `.claude/guidelines/workflow-detail.md` "Resuming Across Conversations").
- **The committed files are the single source of truth** a new session reads on resume — see the Layer Responsibilities table below for which file owns which kind of content. If something is worth remembering, it is worth committing.

## Layer Responsibilities

Each layer has one job. Never duplicate content across layers.

| Layer              | Job                    | Contains                                        |
|--------------------|-----------------------|-------------------------------------------------|
| **Rules**          | Principles/constraints | What/why — domain rules, coding standards (tech-agnostic) |
| **Tech bindings**  | Technology idioms      | Language/framework specifics: annotations, commands, code conventions |
| **Agents**         | Behavioral workflow    | How — phase mechanics, decision logic, smell→template routing |
| **Skills**         | Thin dispatcher        | Which agent + template + layer-specific context |
| **Templates (universal)** | Structural examples | Tech-agnostic patterns: documentation, refactoring, spec, workflow |
| **Templates (tech)**      | Code scaffolds    | Framework-specific: test classes, adapter stubs, config syntax |

## Two-Layer Split: Universal vs Tech-Specific

Rules, templates, and conventions split into two layers (see `.claude/guidelines/technology-loading.md` for full protocol):

| Content type | Universal location | Tech-specific location |
|--------------|--------------------|------------------------|
| Rules/principles | `.claude/rules/*.md` | `.claude/tech/{concern-value}/*.md` |
| Code templates | `.claude/templates/` | `.claude/tech/{concern-value}/templates/` |

**Boundary test:** if content mentions a specific language, framework, annotation, library, or CLI command — it belongs in the tech binding or tech template. Universal layers must be tech-agnostic.

## Product-Agnostic Prompt Library

The prompt library — every file under `.claude/` (rules, agents, skills, templates, tech bindings) — documents engineering patterns, not this product. It must be reusable as-is on a different product. **No prompt-library file may contain product-specific information:** product/company name, business-domain terms, external vendor or integration names, concrete domain entity names, or story/feature names and numbers. Tech bindings may name a framework; they still must not name the product.

**Boundary test:** if content names *this* product rather than the structural role it plays, replace it with the generic concept (`{Entity}`, `{Feature}`, "the external API", "the domain aggregate"). A rule welded to a product instance cannot be reused; the same rule stated structurally can. Product instances live only in `ProductSpecification/`, never in `.claude/`.

## Brevity: constrain artifacts, never reasoning

A length limit in a prompt must target a **produced artifact** — a file, a field, or a message shown to the user — never the model's own reasoning. Telling a model to "be brief," "be concise," or "don't overthink" *its analysis* degrades output quality on any non-trivial task; capping the size of a slug, an ADR, or a summary entry does not. The two read alike but do opposite things.

- **Allowed** (artifact / interaction constraints): "slug ≤ 5 words", "keep the ADR concise", "1-3 questions per round", a line cap on a generated file, "one sentence per summary field".
- **Forbidden** (reasoning constraints): "be brief" / "be concise" applied to the model's working, "don't overthink", "answer quickly", "skip the analysis", "minimal reasoning", any cap on thinking before the answer.

**Boundary test:** name the thing being limited. If it is an output the model writes to disk or shows the user, a length cap is fine. If it is *how much the model thinks or analyzes* before producing that output, drop the limit — let the model reason fully, then constrain only the final artifact.

## Deduplication Principles

- Rule applies to ALL layers → **rules** file; agents/skills reference it
- Rule is tech-specific (framework annotation, library API, build command) → **tech binding** (`.claude/tech/{concern-value}/`)
- Rule is phase-specific (red/green/refactor) → **agent**
- Rule is layer-specific (h2, rest, selenium) → **skill** or **template**
- Reference material (code examples, checklists, before/after patterns) → **template**; agents load on demand via file path. Agents keep only workflow + routing tables.
- Test execution commands → **test-runner.md** agent only; skills/agents use `Skill tool`
- Skill with unique workflow (not shared across skills) → keep workflow **inline in the skill**. Only extract to an agent when multiple skills share the same behavioral workflow (e.g., `red-agent` serves red-usecase, red-adapter, red-acceptance). A 1:1 agent-to-skill mapping is unnecessary indirection.

## When Editing Docs

Before adding content, check whether it already exists in a higher layer:
1. Check rules files (universal principles)
2. Check tech bindings (framework-specific idioms)
3. Check agents (workflow)
4. Check templates — universal first, then tech-specific
5. Only then add to the skill — and only layer-specific context

Automated tools:
- `/prompt-update` — classify new content and write it to the correct layer
- `/prompt-refactor` — scan a file for layer violations and structural drift, then fix
