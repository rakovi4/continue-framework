# Acceptance Test Template -- Universal

## 3-Tier DSL Architecture

| Tier | Purpose |
|------|---------|
| Test Class (DSL Layer) | Disabled test, scenario in description, extends base test setup |
| Statements Class (Service Layer) | Assertions, reuses other Statements |
| Adapter Layer (Client) | Raw HTTP operations, no assertions |

## Standard Directory Structure

Each tier lives in a standard location under the `acceptance/` module. Tech profiles provide the exact paths.

| Tier | Standard location |
|------|-------------------|
| Test Class | `tests/backend/{story}/` or `tests/frontend/{story}/` |
| Statements | `statements/` or `statements/{feature}/` |
| Client | `clients/application/` |
| DTOs | `clients/application/dto/{feature}/` |

## Test Types

Two test categories with separate base classes and tags:

| Type | Purpose |
|------|---------|
| Backend API | HTTP endpoint tests against the running backend |
| Frontend UI | Browser tests via Selenium/Playwright |

Each type has its own base class, tag/marker, and directory. Tech profiles specify the exact class names and tag syntax.

## Test Class Rules

- Multi-step test bodies with setup/action/assertion phases
- **Statements methods must be FULLY FUNCTIONAL in RED** -- real assertions, real setup. NEVER stub Statements with the not-implemented marker (that marker is for real adapter implementations only).
- Gherkin-style scenario in test description
- **NEVER call mocks, clients, or adapters directly** -- all infrastructure interactions must be hidden behind Statements. Test class reads like pure business DSL.

## Reference Files (read before generating)

Before writing a new acceptance test, read existing examples in the project:

1. **Test example** -- an existing test class to follow for structure and conventions
2. **Base class** -- the abstract base providing test infrastructure
3. **Statements example** -- an existing Statements class for DSL patterns
4. **Client** -- the application HTTP client for endpoint calls
5. **TestData** -- shared constants for test data

Tech profiles provide exact paths for each reference file.

Story mapping: see `ProductSpecification/stories.md`
