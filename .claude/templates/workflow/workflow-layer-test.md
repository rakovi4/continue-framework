# Layer `workflow` — Test Template

For `red-workflow` / `green-workflow` steps. The work item defines the workflow
engine's language, project root, and test command. Read its specification and test-stack
documents before writing either tests or production code.

## Architecture

Mirror the application's inward dependency direction:

```
application → adapters → usecase → domain
```

- **Domain** owns workflow state and value objects without filesystem, shell, Git, or
  agent-runtime dependencies.
- **Usecase** owns orchestration and declares typed ports for every external effect.
- **Adapters** implement one port each for the real runtime.
- **Application** wires the usecase to real adapters.
- Usecases never import adapters or call other usecases.
- The workflow engine may use normal filesystem, shell, and Git adapters. It is not a
  sandbox and does not generate a second orchestration program.

## Test architecture

Tests mirror the backend test style:

- A shared application-test fixture wires the usecase to recording fakes.
- Each external-effect port has a recording fake beside the fixture.
- Statements own setup, execution, and assertions.
- Test files contain scenario names and calls to Statements only.
- Assert observable port calls, ordering, arguments, returned state, and failures; do
  not inspect private implementation details.
- Extend the fixture vertically as each scenario introduces another port.

The work item's test-stack document is authoritative for the current scenario's ports,
pipeline, and expected calls.

## Red phase

1. Create only the minimum project and shared test infrastructure needed by the first
   scenario.
2. Write the scenario test through the shared fixture and Statements DSL.
3. Predict the failure using the red-phase output format.
4. Run the focused test without a disable marker and prove it fails for the missing
   behavior.
5. Add the project's test disable marker and re-run the collected suite to prove the
   committed tree stays green.
6. Production workflow behavior is forbidden in red.

## Green phase

1. Remove only the current scenario's disable marker.
2. Implement the minimum domain, usecase, ports, adapters, or wiring needed by that
   scenario.
3. Run the focused test with a no-skips/no-disabled check appropriate to the configured
   test runner.
4. Run the collected workflow suite.
5. If another scenario remains disabled, leave it untouched.

## Assertion boundaries

- Test files contain no direct assertions and no raw IO.
- Statements contain every assertion.
- Fakes record inputs and calls; they do not reproduce orchestration decisions.
- Clients or adapters own filesystem, process, Git, and agent-runtime IO.
- Expected values that define the behavior stay visible in the scenario call; bulky
  fixtures belong in Statements.
- One test block describes one behavior.

## File size

The 200-line hard limit applies to every production and test file. Split by behavior or
port before crossing it; never shave assertions or explanatory guards to buy lines.
