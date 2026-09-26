# Extract Method or Function

Apply to methods, functions, callbacks, event handlers, lifecycle effects, and
test helpers on both client and server. Read `restraint.md` before extraction;
its evidence requirements apply to every candidate, including long methods.

## Identify responsibilities

1. Enumerate each block's purpose, inputs, output, effects, and failure behavior.
2. Identify changes in abstraction level: model validation, transition details,
   boundary calls, response mapping, presentation decisions, and assertions.
3. Give each distinct responsibility a named owner. Shared values become explicit
   parameters or owned model state; they do not prevent extraction.
4. Prefer moving behavior to its existing owner over adding a generic utility.

## Preserve behavior

- Preserve guard precedence, short-circuiting, call order, and error translation.
- Keep freshness checks at their asynchronous boundaries. Never hoist a snapshot
  or validity decision across a response when it must be re-evaluated afterward.
- Preserve captured identity, callback binding, subscriptions, and cleanup.
- A guard that returns from a helper does not return from its caller. Return an
  explicit decision or use the existing failure contract; do not silently turn
  rejection into continued execution.
- Keep test expectations independent of production computations. Extract setup
  and observation by intent without changing assertion strength or scenario order.

## Common extractions

| Mixed behavior | Extracted owner |
|----------------|-----------------|
| Eligibility and input validation inside an operation | Named model decision with an explicit result |
| Repeated field updates for a lifecycle phase | Named state transition in the capability model |
| Request construction inside rendering or orchestration | Typed request mapping at its owning model/boundary |
| Response validation and state publication inside a transport sequence | Named response decision/transition; orchestration retains effect order |
| Repeated calculations or multi-step transformations | A named computation next to the data it interprets |
| Multi-step setup or repeated contract assertions | Focused fixture or assertion helper using independent expected values |

An operation should read as a sequence of named responsibilities. Do not make a
forwarding helper for every statement; each extraction must name meaningful
behavior. Do not replace early returns with nested branches merely to reduce
return counts or compress formatting to reduce line counts.

## Verification

Run affected checks after each extraction. Remeasure formatted sizes and revisit
nesting, locals, duplication, parameter groups, and ownership. Retained candidates
need current source ranges and the concrete alternatives rejected under
`restraint.md`; a lifecycle label alone cannot establish a clean result.

## Binding examples

- Java: `.claude/tech/java-spring/templates/refactoring/extract-method.md`
- TypeScript: `.claude/tech/react-ts/templates/refactoring.md`

Use only the active binding's examples; other bindings apply the same principles
through their native representations.
