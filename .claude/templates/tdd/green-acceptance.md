# Acceptance Test Implementation (Green Phase) -- Universal

## Workflow

1. Find the scenario's disabled test target and remove its shared marker or every equivalent case marker as one atomic change
2. Start backend: `Skill tool: skill="run-backend"`
3. Run ONLY the target scenario group: `Skill tool: skill="test-acceptance", args="backend {TestName}"`
4. Check results:
   - ALL pass -- done
   - Any target case fails -- re-add the group marker or markers, analyze what prerequisite is missing
   - Other tests fail -- re-add every removed marker, investigate collateral failures
5. Stop backend: `Skill tool: skill="stop-backend"`

## Prerequisites

Before enabling acceptance test, ensure:
- Use-case implemented (`/green-usecase`)
- All required adapters implemented (`/green-adapter {adapter}` for each)
- All module tests pass

## Allowed Changes

Remove the disable marker or markers from ONE scenario target. A multi-case target is enabled together. **That is the ONLY change to ANY file.**

Do NOT write production code. Do NOT add error/exception handlers. Do NOT modify controllers, services, entities, or any other file. If the test needs production code that doesn't exist yet, a prerequisite step (red-adapter/green-adapter) was missed.

## Collateral Failures

If the target test passes but OTHER tests fail, this is NOT acceptable. Re-add the disable marker and investigate. Common causes:
- New domain logic (e.g., expiration checks) breaking tests with stale test data
- Missing error/exception handlers causing 500 instead of expected status codes
- Shared test state contamination
