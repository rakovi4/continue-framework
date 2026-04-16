# Selenium TDD Idioms

Tech binding for `tdd-rules.md`. Load alongside the universal rules.

## Test Disable Marker

- JUnit 5: `@Disabled` annotation on test methods/classes
- In RED: add `@Disabled` after validating prediction
- In GREEN: remove `@Disabled` (the only test modification allowed)

## Test Description

- Use `@Description("...")` on test classes to document the scenario
- `@Description` MUST include "UI Test Scenario N:" prefix referencing `02_UI_Tests.md`
- `@Description` MUST include full BDD gherkin from the test spec

## Statements Assertions (AssertJ)

- Real `waitUntil(visibilityOfElementLocated)` calls, real `assertThat(element.isDisplayed()).isTrue()` assertions
- Even when `waitUntil(visibilityOfElementLocated)` implies visibility, the explicit `assertThat` assertion must stay
- Use AssertJ with `.as()` for all assertions

## WireMock Stubs

- Backend Statements handle WireMock stub configuration — never in page Statements
- Tests call backend Statements directly for all setup

## Statements Dependencies

- `@Service` with `@RequiredArgsConstructor` — inject dependencies via constructor
- Reuse `AuthenticationStatements`: `login(loginRequest())` for API session; `LoginPageStatements.loginAsTestUser(appUrl)` for browser login flow

## Test Verification

```
Skill tool: skill="test-acceptance", args="frontend {TestClassName}"
```
