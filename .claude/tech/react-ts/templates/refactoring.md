# TypeScript Refactoring Examples

Use the shared `extract-method.md`, `restraint.md`, and role applicability rules.
These examples supply syntax, not frontend exemptions.

## Decompose asynchronous orchestration

An operation mixing eligibility, validation, field updates, transport, and result
interpretation has multiple responsibilities even when every phase uses the same
state. The pure model owns the submission decision and named transitions; the
controller coordinates effects and publishes their results.

Illustrative methods inside a capability controller:

```typescript
async submit(): Promise<void> {
  const decision = this.model.submission(this.state.getSnapshot());
  if (decision.kind !== "ready") {
    this.publishDecision(decision);
    return;
  }
  await this.send(decision.request, this.requests.begin());
}

private async send(request: Request, current: () => boolean): Promise<void> {
  this.publishPending();
  try {
    const result = await this.api.submit(request);
    this.publishResultIfCurrent(result, current);
  } catch (error) {
    this.handleFailure(error, current);
  }
}

private handleFailure(error: unknown, current: () => boolean): void {
  if (!current()) {
    return;
  }
  if (!isExpectedFailure(error)) {
    throw error;
  }
  this.publishFailure(error);
}
```

The model decision distinguishes invalid input from an operation that is currently
unavailable; `publishDecision` preserves their different outcomes. The publication
methods apply named model transitions through the observable state port. Result
publication and failure handling each recheck freshness before changing state or navigating.
The adapter's typed failure predicate distinguishes recoverable failures from
unexpected errors, which propagate to the owning error boundary.
Do not hoist that check before the request. Each helper must implement its named
responsibility; do not add another forwarding layer around the same behavior.

## Preserve simple state reads

```typescript
const snapshot = state.getSnapshot();
if (!state.active() || !snapshot.profile) {
  return;
}
const decision = validateInput(snapshot.input);
```

Use this shape only when the getter is a pure snapshot read and the captured state
is valid for that synchronous decision. Injection alone does not justify extra
aliases or repeated reads. Re-read state after an await when current state matters.

## Preserve straightforward rendering

```tsx
function ResultView({ state }: { state: ViewState }) {
  if (state.kind === "loading") {
    return <ProgressView />;
  }
  if (state.kind === "failed") {
    return <FailureView message={state.message} />;
  }
  return <ContentView content={state.content} />;
}
```

Each branch delegates to a named view. Multiple returns are not a violation;
mixed view responsibilities and excessive nesting are. Types and collaborators
come from the owning capability; exhaustive handling belongs with its closed state.

## Test helpers and independent oracles

A callback test is subject to the same checks as a test method. Keep meaningful
inputs, the action, and expected outcomes visible. Extract repeated mock setup,
transport stubs, and multi-step observations into capability-local helpers.
Expected results must not call a production reducer or validation function to
calculate their own oracle. Direct structural assertions remain valid when they
express the complete intended outcome without mixing abstraction levels.
