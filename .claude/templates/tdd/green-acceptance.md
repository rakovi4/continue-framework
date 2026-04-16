# Acceptance Test Implementation (Green Phase) -- Universal

## Workflow

1. Find disabled test, remove the test disable marker
2. Start backend: `Skill tool: skill="run-backend"`
3. Run ONLY the target test: `Skill tool: skill="test-acceptance", args="backend {TestName}"`
4. Check results:
   - ALL pass -- done
   - Target fails -- re-add disable marker, analyze what prerequisite is missing
   - Other tests fail -- re-add disable marker, investigate collateral failures
5. Stop backend: `Skill tool: skill="stop-backend"`

## Prerequisites

Before enabling acceptance test, ensure:
- Use-case implemented (`/green-usecase`)
- All required adapters implemented (`/green-adapter {adapter}` for each)
- All module tests pass

## Allowed Changes

Remove the disable marker from ONE test. **That is the ONLY change to ANY file.**

Do NOT write production code. Do NOT add error/exception handlers. Do NOT modify controllers, services, entities, or any other file. If the test needs production code that doesn't exist yet, a prerequisite step (red-adapter/green-adapter) was missed.

## Collateral Failures

If the target test passes but OTHER tests fail, this is NOT acceptable. Re-add the disable marker and investigate. Common causes:
- New domain logic (e.g., expiration checks) breaking tests with stale test data
- Missing error/exception handlers causing 500 instead of expected status codes
- Shared test state contamination
