# Database Storage Test Template

## Test Class Rules

- Use test database with transaction rollback or truncation cleanup
- Inject the storage class under test
- Use `describe("Feature: ...")` with Gherkin-style description
- Clean up test data in `beforeEach` / `afterEach` hooks

## DB-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| `return undefined;` | `Expected value to be defined` or `Expected value to equal...` |
| `return [];` | `Expected array not to be empty` or `Expected array to equal...` |

## Reference (read before generating)

- Test example: `backend/adapters/db/src/__tests__/access/{feature}/{Feature}Storage.test.ts`
- Test setup: `backend/adapters/db/src/__tests__/setup/DbTest.ts`
- Storage example: `backend/adapters/db/src/access/{feature}/{Feature}Storage.ts`
- Entity example: `backend/adapters/db/src/entity/{feature}/{Feature}Entity.ts`

## Naming Convention

- Test file: `{Entity}Storage{Method}.test.ts`
- Test case: `it("should {expected behavior}")`

## Key Paths

- Tests: `backend/adapters/db/src/__tests__/access/`
- Production: `backend/adapters/db/src/access/`
- Entities: `backend/adapters/db/src/entity/`
- ORM config: `backend/adapters/db/src/config/`
