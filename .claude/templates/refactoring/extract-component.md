# Extract Component

Apply shared cohesion, ownership, size, and abstraction rules to presentation.
Use this pattern for a view mixing independently meaningful visual sections or
responsibilities, not merely because it has multiple return statements.

## Procedure

1. Identify the visual responsibility, inputs, events, and state owner. Move
   domain decisions to the model and asynchronous workflows to the controller.
2. Give the view only the values and operations it needs. Do not pass an entire
   page state or broad controller to a leaf for convenience.
3. Keep helpers used only by one view local according to the frontend rules;
   place shared components with their actual capability or shared UI owner.
4. Preserve rendered structure, ordering, styles, accessibility, test locators,
   framework identity, and event semantics. Update consumers and imports.
5. Retain simple local names and clear guard returns. Extract distinct or repeated
   computations by responsibility; do not introduce nested conditionals or mutable
   render accumulators merely to satisfy a return-count preference.
6. Run affected component and behavior checks, plus design verification where
   required. Remeasure and re-scan complexity, ownership, duplication, and props.

## Completion

Record the responsibility extracted and final ownership. A component remains
subject to all shared refactor checks; visual equivalence alone does not establish
code quality. Apply `restraint.md` evidence to any retained candidate.

For concrete syntax, use the active frontend binding's implementation template.
