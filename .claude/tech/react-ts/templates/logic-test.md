# Frontend Model and Controller Test Template

Apply shared test-quality and refactor checks to every callback and helper.
Resolve paths inside the owning capability under the agreed responsibility map.

## Model tests

Pure model tests live beside their `.logic.ts` owner. Expected values are literal
and independent of the model implementation.

```typescript
import { describe, expect, it } from "vitest";
import { validateInput } from "./input.logic";

describe("input validation", () => {
  it("accepts a nonblank value unchanged", () => {
    expect(validateInput("example")).toEqual({
      kind: "valid",
      value: "example",
    });
  });

  it("rejects an empty value", () => {
    expect(validateInput("")).toEqual({
      kind: "invalid",
      message: "A value is required",
    });
  });
});
```

Use the exact reviewed behavior and error text for the actual capability. Direct
assertions here express one complete outcome; multi-step setup and observations
still require named helpers under the common checks.

## Controller tests

Effectful orchestration belongs in `.controller.ts`, with matching controller
tests in the same capability. Use real model decisions and transitions with
controlled effect ports, timers, and deferred promises. Assert observable state
and calls, including freshness, errors, and disposal where the scenario needs them.
Do not move effects into `.logic.ts` merely to fit the frontend-logic lane name;
that lane owns both model and orchestration work with separate responsibilities.

## RED stub and failure

Create only the importable signature from the approved contract. Its body throws
the configured not-implemented error until GREEN. An import/type error is not the
behavioral RED prediction. Preserve reviewed assertions during implementation.

After verifying the raw failure, encode the actual reason in the disabled case:

```typescript
it.skip("TDD Red: validator not implemented — rejects an empty value", () => {
  expect(validateInput("")).toEqual({
    kind: "invalid",
    message: "A value is required",
  });
});
```

Run the frontend test skill for the explicit model/controller paths. Use the
capability filter when both roles change so neither suite is silently omitted.
