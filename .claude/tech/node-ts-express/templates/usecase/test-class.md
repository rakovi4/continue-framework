# Usecase Test Template -- Node/TS/Express

> Universal rules: `.claude/templates/tdd/red-usecase.md`

## 3-Tier Locations

| Layer | Location |
|-------|----------|
| Test Class | `{feature}/{Feature}UseCase.test.ts` |
| Statements | `statements/{Feature}Statements.ts` |
| Scope | `scope/{Feature}RequestScope.ts` |

## Tech-Specific Rules

- `describe.skip("Feature: ...")` in RED
- Use nested `it("should ...")` blocks with Gherkin-style scenario text
- Not-implemented marker: `throw new Error("Not implemented")`
- Empty values: `undefined` for optional fields, `[]` for collections

## Reference (read before generating)

- Test class: `backend/usecase/src/__tests__/{feature}/{Feature}UseCase.test.ts`
- Statements: `backend/usecase/src/__tests__/statements/{Feature}Statements.ts`
- Scope: `backend/usecase/src/__tests__/scope/{Feature}RequestScope.ts`
- Base setup: `backend/usecase/src/__tests__/setup/ApplicationTest.ts`
- TestData: `backend/usecase/src/__tests__/scope/TestData.ts`
- Fake example: `backend/usecase/src/__tests__/fake/{feature}/Fake{Feature}Storage.ts`

## Update ApplicationTest

Add new use-case and statements to `ApplicationTest.ts` if needed (follow the existing setup sections).

## Key Paths

- Tests: `backend/usecase/src/__tests__/{feature}/`
- Production: `backend/usecase/src/{feature}/`
- Base setup: `backend/usecase/src/__tests__/setup/ApplicationTest.ts`
- Statements: `backend/usecase/src/__tests__/statements/`
- Scopes: `backend/usecase/src/__tests__/scope/`
- Fakes: `backend/usecase/src/__tests__/fake/`
