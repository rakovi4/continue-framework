# Frontend Implementation Template

Load shared `coding-detail.md`, `frontend-rules.md`, and the React/TypeScript
coding and test bindings before implementing. Their responsibility map applies
to the entire capability, including functions, hooks, clients, and test helpers.

## Pure model (.logic.ts)

Own validation, derived values, and named transitions in pure model functions.
Use typed outcomes so callers do not repeat the rule or inspect unrelated fields.

```typescript
type InputDecision =
  { kind: "invalid"; message: string } | { kind: "valid"; value: string };

export function validateInput(value: string): InputDecision {
  if (!value.trim()) {
    return { kind: "invalid", message: "A value is required" };
  }
  return { kind: "valid", value };
}
```

Keep capability state and its transitions with this owner. A transition returns
new state; observable publication belongs to the controller/store boundary.
Represent mutually exclusive states with discriminated unions where appropriate.

## Orchestration (.controller.ts)

Own operation sequencing and lifecycle here. Inject narrow API, navigation,
clock, and state-publication ports as needed. Delegate validation and transitions
to the model; never place external effects in a pure logic file.

Use `.claude/tech/react-ts/templates/refactoring.md` for decomposition of an
asynchronous operation. Preserve cancellation and freshness checks at each await
boundary. Handle expected errors through the owning error policy; never add an
empty catch or silently ignore an unexpected failure.

## API client (.api.ts)

The adapter owns transport, typed decoding, and protocol error translation.
Models and components do not know response status codes or external SDK details.
Use the backend URL configuration from the active binding. Validate unknown
external data at the boundary; a type assertion is not decoding.

## Component (.tsx)

Render view state and bind events to controller operations. The controller owns
submission, validation, and failure handling. Keep capability paths local.

```tsx
type InputViewProps = {
  value: string;
  error: string | null;
  busy: boolean;
  onChange(value: string): void;
  onSubmit(): void;
};

export function InputView(props: InputViewProps) {
  return (
    <form
      onSubmit={(event) => {
        event.preventDefault();
        props.onSubmit();
      }}
    >
      <label htmlFor="input-value">Value</label>
      <input
        id="input-value"
        data-testid="input-value"
        value={props.value}
        onChange={(event) => props.onChange(event.target.value)}
      />
      {props.error && <p role="alert">{props.error}</p>}
      <button disabled={props.busy} type="submit">
        Submit
      </button>
    </form>
  );
}
```

The markup is one form responsibility. Its event callback only adapts the browser
event. Adding a multi-step workflow requires a controller operation; adding an
independent visual responsibility requires component extraction. A render block's
length never exempts its executable callbacks from the common checks.

## Verification

Use the frontend test skill for the owning capability. Check pure models,
orchestration with controlled effects, and transport at their respective seams.
Check component binding and rendered behavior where required. All production and
test paths receive shared refactor checks plus applicable presentation checks.
