# Red Phase -- TypeScript/Vitest Conventions

Universal formats and rules: `.claude/templates/workflow/red-phase-formats.md`

## .skip Syntax

```typescript
// TDD Red Phase - findByEmail returns undefined
describe.skip("Feature: Find user by email", () => {
```

Describe-level (adapter tests):

```typescript
// TDD Red Phase - DbTaskStorage.findByBoardId not implemented
describe.skip("DbTaskStorage findByBoardId", () => {
```
