# Documentation Conventions

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

Rules, templates, and conventions split into two layers (see `.claude/rules/technology-loading.md` for full protocol):

| Content type | Universal location | Tech-specific location |
|--------------|--------------------|------------------------|
| Rules/principles | `.claude/rules/*.md` | `.claude/tech/{concern-value}/*.md` |
| Code templates | `.claude/templates/` | `.claude/tech/{concern-value}/templates/` |

**Boundary test:** if content mentions a specific language, framework, annotation, library, or CLI command — it belongs in the tech binding or tech template. Universal layers must be tech-agnostic.

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
