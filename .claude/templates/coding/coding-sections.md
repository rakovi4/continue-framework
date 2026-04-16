# Coding Sections (Universal)

Shared concepts and section structure for tech binding `coding.md` files.

Tech-specific language constructs are in `.claude/tech/{concern-value}/coding.md`.

## Backend Coding Sections

Every backend `coding.md` follows these sections. Each section provides ONLY the language-specific construct — the universal concept lives in `coding-rules.md`.

| Section | What the tech file provides |
|---------|----------------------------|
| Deployment | Language-specific in-memory state to avoid (specific types/keywords) |
| Clean Architecture | Framework annotations/imports allowed per layer, adapter technologies |
| Domain-Driven Design | Validation exception type, enum syntax, optional/null types, forbidden dispatch keywords, typed list syntax, parameter object type, immutable type |
| Code Generation | Framework code-gen annotations/decorators for DTOs, DI, builders, immutability |
| Naming | Persistence entity suffix, converter method names, file/package conventions |
| Immutability | Language-specific readonly/final/frozen keywords, defensive copy patterns |
| Accessor Chains | Language getter/property chain syntax and convenience method pattern |
| Optional/Nullable Handling | Language optional API (monadic operations, null-safe operators) |
| Null Boundary | Controller null-wrapping syntax, request DTO optional field defaults |
| Request DTO Conversions | Type conversion examples and method naming for the language |
| Branching | Language switch/match expression syntax |
| Controllers | Response builder syntax, HTTP status code API, error handler name |
| Storage Adapters | ORM entity mapping syntax, trivial method pattern, query object type |
| Refactor Agent Terms | Language-specific equivalents for generic refactor-agent smell terms |
| Scan Checklist Grep Patterns | ORM/framework-specific grep patterns for storage adapter checks |
| HTTP Clients | Production HTTP library, test mocking approach |
| Error Handling | Base exception class, centralized handler name |

## Refactor Agent — Generic Terms

The refactor agent uses these generic terms in the scan-checklist routing table. Each backend `coding.md` maps them to language-specific keywords.

| Generic term (in agent) | What to map |
|--------------------------|-------------|
| Qualified enum references in logic | Language import mechanism to avoid qualified enum access |
| Type-checking/type dispatch in domain or usecase | Language type-checking keywords forbidden in domain/usecase |
| Base-type list re-partitioned with type checks | Language base-type collection filtered with type-checking |
| Immutable data class | Language construct for immutable value types |
| Collection pipeline terminal operation | Language terminal operation for collection transformations |
| Manual per-field assertion for immutable data types | Which language types this applies to |

## Scan Checklist — Generic Storage Checks

The scan checklist (A33-A44) references "see tech binding" for ORM-specific patterns. Each backend `coding.md` provides grep patterns for these checks.

| # | Check | What to grep for |
|---|-------|------------------|
| A33 | Manual row grouping | ORM grouping utilities, intermediate row DTOs, manual collection assembly |
| A34 | Multi-repository injection | Count ORM repository/data-access fields per storage class |
| A42 | Static spec/query utility | Static methods returning framework query objects from filter objects |
| A43 | Untyped array query results | Raw/untyped query result access patterns |
| A44 | Inline query building | Framework query/filter/criteria chains >5 lines inline in storage methods |

## Browser Testing Sections

Shared rules for `selenium`, `cypress`, and `playwright` coding.md files. The universal rules live in `frontend-rules.md` (Selenium Tests section). Each tech file provides ONLY:

| Section | What the tech file provides |
|---------|----------------------------|
| DSL Architecture | Tool-specific class/module structure |
| Test Class Rules | Tool-specific base class/fixture, delegation API |
| Statements Rules | Tool-specific locator storage pattern, method naming |
| Element Locators | Tool-specific selector API (`By.cssSelector`, `cy.get`, `page.getByTestId`) |
| Component Attributes | Framework-specific `data-testid` example syntax |
| Prerequisites | Same across all (backend + frontend + unit tests passing) |

## Frontend Coding Sections

Shared structure for `react-ts`, `angular-ts`, and `vue-ts` coding.md files. The universal rules live in `frontend-rules.md`. Each tech file provides ONLY:

| Section | What the tech file provides |
|---------|----------------------------|
| File Extensions | Framework-specific component extension (`.tsx`, `.vue`, `.component.ts`) |
| Feature Structure | Framework-specific directory layout and file naming |
| Shared UI Components | Framework-specific shared component location |
| Icon Library | Framework-specific icon package and import/usage syntax |
| Conditional Class Syntax | Framework-specific class binding syntax |
