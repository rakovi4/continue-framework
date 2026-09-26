# Extract Test Fixture or Assertion Helper

Apply to all test bindings: scenario bodies, callback tests, setup factories,
transport stubs, and observation helpers. Read the active test binding for syntax
and required narrative conventions, plus `restraint.md` for retained candidates.

1. Separate the scenario's meaningful inputs and expected outcomes from incidental
   setup, protocol details, and observation mechanics.
2. Extract multi-step setup by its scenario intent, keeping fixtures with their
   owning capability. Parameterize variation required by actual cases.
3. Give repeated contract assertions one focused helper with independent expected
   values. Preserve exact values, call counts/order, identity, and error details.
4. Keep the action under test visible. Never compute expected outcomes with the
   production implementation or reproduce its decision algorithm in a helper.
5. Remove redundant helper forwarding and unused fixtures. Avoid broad contexts
   that collect unrelated dependencies just to simplify a function signature.
6. Re-run affected tests and inspect the final scenario's abstraction level.

A language's native inline assertion syntax is compatible with these rules when
it remains readable at one abstraction level. It cannot waive shared checks for
length, mixed responsibilities, duplication, type safety, or independent oracles.
