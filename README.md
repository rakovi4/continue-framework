# /continue — TDD Framework for Claude Code

A prompt framework for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that enforces strict TDD, Clean Architecture, and DDD across the full stack. You type `/continue` and Claude executes the next atomic work unit — write a failing test, implement, refactor, commit — then stops.

Extracted from a production app built over 3.5 months (25K+ LOC, 1,500 tests, 4,000 commits). The rules and workflows accumulated organically; this repo is the tech-agnostic template.

## Why

LLMs write code that compiles but doesn't necessarily work, and without structure you re-explain the same constraints every conversation. This framework pins three things down:

- **Strict red-green-refactor.** Every line of production code is preceded by a failing test. The red phase predicts the exact error type and message, runs the test, and verifies the prediction field-by-field before accepting the red state.
- **Quality gates wired into the loop.** Each work unit runs `test-review` (26-item assertion audit), coverage analysis with gap classification, and `refactor` (55-item structural scan) before the commit. Not optional.
- **`progress.md` as persistent memory.** One checklist per story tracks exactly where work stopped. Context resets are safe — the file plus any ADRs in the story folder have everything needed to resume.

## How it feels

```
You: /continue 5
Claude: > Dispatching red-agent. Live progress: tail -f infrastructure/agent-progress.log
        [red-agent → test-review-agent → refactor-agent → commit]
        Step 14/47 done. Next: green-usecase.

You: /continue
Claude: [picks up where it left off]
```

`/continue` is the only command you type for day-to-day work. It reads `progress.md`, finds the next `[ ]` step, loads any relevant ADR, dispatches the right sub-agent (`red-agent`, `green-agent`, `refactor-agent`, `coverage-agent`, `test-review-agent`) in context isolation, runs the mandatory gates, commits, and stops. Sub-agents stream milestones to `infrastructure/agent-progress.log` — `tail -f` it in another terminal to watch RED → PREDICT → RUN → PASS unfold live.

Every feature follows the same pipeline:

```
interview → story → mockups → api-spec → test-spec
  → backend scenarios: red-acceptance → design → red-usecase → green-usecase
      → adapters-discovery → red-adapter(s) → green-adapter(s) → green-acceptance
  → frontend scenarios: red-selenium → red-frontend → green-frontend
      → red-frontend-api → green-frontend-api → align-design → green-selenium → demo
  → integration / security / load / infrastructure scenarios
```

`adapters-discovery` is a gate: after `green-usecase`, `/continue` reads the usecase constructor, maps each port to an adapter, and rewrites `progress.md` with the concrete adapter steps before proceeding. When `/design-preview` surfaces a non-obvious decision, it produces an ADR in `decisions/NNN-slug-decision.md` under the story folder; subsequent `/continue` runs load it automatically.

## Architecture

Clean Architecture, dependency flow strictly inward:

```
backend/domain  ←  backend/usecase  ←  backend/adapters/{rest,h2,email,...}  ←  backend/application
acceptance/     (black-box HTTP + browser tests, top-level)
frontend/       (feature-based, Humble Object pattern)
```

Rules prohibit importing from outer layers in inner layers. Domain has zero framework dependencies. Adapters implement ports defined in usecase.

## Tech profiles

The framework is tech-agnostic. Set four keys in `ProductSpecification/technology.md`:

| Concern | Available profiles |
|---------|-------------------|
| Backend | `java-spring` · `go-stdlib` · `node-ts-express` · `python-django` · `php-laravel` · `cpp-cmake` · `csharp-dotnet` |
| Frontend | `react-ts` · `vue-ts` · `angular-ts` |
| CSS | `tailwind` · `plain-css` |
| Browser testing | `selenium` · `playwright` · `cypress` |

Profiles are independent — any combination works. Each lives in `.claude/tech/{profile}/` with `coding.md`, `tdd.md`, `infrastructure.md`, and code templates. Adding a new profile means adding that directory; rules, agents, and skills resolve bindings dynamically.

## Quick start

```bash
# 1. Copy the framework into your project
cp -r continue-framework/.claude continue-framework/CLAUDE.md continue-framework/ProductSpecification your-project/
cd your-project

# 2. Pick your stack in ProductSpecification/technology.md
#    tech-profile:
#      backend: java-spring
#      frontend: react-ts
#      css: tailwind
#      browser-testing: selenium

# 3. Start working
claude
> /continue 1
```

First run triggers the spec phase (`/interview` → `/story` → `/mockups` → `/api-spec` → `/test-spec`), one skill at a time so you can review each. After the spec lands, every subsequent `/continue` executes one TDD work unit.

## What's inside

```
.claude/
├── rules/      8 files — universal principles (Clean Architecture, TDD, DDD, workflow)
├── agents/     8 files — red, green, refactor, coverage, test-review, test-runner, ...
├── skills/    28 slash commands — /continue, /refactor, /test-coverage, /design-preview, ...
├── templates/ 52 files — refactoring patterns, checklists, code scaffolds
└── tech/      15 directories — pluggable technology profiles
```

302 prompt files total. Every AI decision traces back to a specific rule, checklist item, or template. Start with `CLAUDE.md` and `.claude/rules/workflow.md` to understand the loop; `.claude/skills/continue/SKILL.md` is the dispatcher.

## Limitations

- **Claude Code only.** Relies on subagents, slash commands, hooks, and tool use. Won't work with other AI coding tools without adaptation.
- **Opinionated.** Clean Architecture + DDD + strict TDD. If your project doesn't follow this structure, the framework will fight you.
- **Learning curve.** 28 skills, 8 agents, 302 prompt files. It takes time to understand what's happening and why.
- **Context budget.** Rules load every conversation. On smaller context windows this leaves less room for code.

## Acknowledgments

Draws on [Extreme Programming](http://www.extremeprogramming.org/) (Beck), [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) (Martin), [DDD](https://www.domainlanguage.com/ddd/) (Evans), and [Refactoring](https://refactoring.com/) (Fowler).

MIT License.
