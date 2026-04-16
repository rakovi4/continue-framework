# Technology Loading

## Profile Resolution

The active technology profile is declared in `ProductSpecification/technology.md` via the `tech-profile:` block. The profile is **composite** — four independent concern keys, each pointing to a separate tech profile directory.

```yaml
tech-profile:
  backend: {backend-profile}
  frontend: {frontend-profile}
  css: {css-profile}
  browser-testing: {browser-testing-profile}
```

Each concern resolves independently to `.claude/tech/{concern-value}/`.

## Concern-to-Layer Mapping

Agents and skills resolve the correct concern based on the layer they operate on:

| Layer / Skill context | Concern key |
|-----------------------|-------------|
| Domain, usecase, application, REST adapter, DB adapter, email adapter, scheduling | `backend` |
| Frontend logic, API clients, feature structure | `frontend` |
| Component styling, CSS extraction, icons | `css` |
| Selenium/browser tests, align-design, design-review | `browser-testing` |
| Acceptance tests (backend API) | `backend` |
| Acceptance tests (frontend UI) | `browser-testing` |

When a skill needs bindings from multiple concerns (e.g., a browser test skill needs both `browser-testing` for test patterns and `backend` for mock server stubs), it loads both profiles.

## Directory Structure

```
ProductSpecification/technology.md          # Declares composite tech-profile
.claude/tech/
  {concern-value}/                          # One directory per concern
    coding.md                               # Language/framework coding conventions
    tdd.md                                  # Tech-specific TDD patterns (optional)
    infrastructure.md                       # Build/run/deploy config (optional)
    templates/                              # Tech-specific code scaffolds
      {layer}/                              # One subdirectory per adapter/layer
```

Each concern directory contains the bindings relevant to that technology. The exact files and template subdirectories vary per profile — inspect `.claude/tech/{concern-value}/` to see what a profile provides.

## How Agents and Skills Load Tech Bindings

1. **Read profile**: Read `ProductSpecification/technology.md`, extract all four concern keys from the `tech-profile:` block
2. **Identify concern**: Determine which concern applies to the current layer/skill (see mapping table above)
3. **Load tech rules**: Read `.claude/tech/{concern-value}/{binding}.md` for the relevant binding (coding, tdd, infrastructure)
4. **Resolve templates**: Template paths are `.claude/tech/{concern-value}/templates/{template-dir}/`
5. **Multi-concern skills**: When a skill spans concerns, load bindings from each relevant profile

## Conventions Table

`ProductSpecification/technology.md` includes a **Conventions** table with key operational values (test disable marker, not-implemented marker, run/test commands, coverage report path). Conventions are organized by concern — each concern's conventions are grouped together. Skills that dispatch commands or check markers should read from this table rather than hardcoding values.

## Adding a New Tech Profile

To support a new technology combination:
1. Create `.claude/tech/{profile-name}/` for each concern with the relevant bindings (`coding.md`, `tdd.md`, `infrastructure.md`, `templates/`)
2. Update `ProductSpecification/technology.md` to set the four concern keys
3. No changes needed to universal rules, agents, or skills -- they resolve via concern mapping
