# Extract Tailwind @apply Class

**When to use:** A `className` string contains any Tailwind utility with an arbitrary value (`text-[#4b5563]`, `shadow-[...]`, `ring-[3px]`, `border-[#e5e7eb]`, `bg-[#f1f3f5]`) that obscures visual intent. Even a single `bg-[#hex]` qualifies — hex codes are opaque. Also applies to repeated utility combinations across 2+ components.

**Examples:**
- `shadow-[0_10px_15px_-3px_rgba(0,0,0,0.1),0_4px_6px_-2px_rgba(0,0,0,0.05)]` → `.auth-card`
- `border border-[#e5e7eb] bg-white px-4 py-3 text-[15px] text-[#111827] placeholder:text-[#9ca3af]` → `.input-field`
- `flex items-center justify-center rounded-full` → `.status-icon`

**NOT candidates** (already readable):
- `mb-5 text-center` — self-documenting, leave inline
- `flex gap-2` — simple layout, no arbitrary values
- `p-12` as a single override alongside a semantic class — fine inline

## Step 1: Identify the Pattern

Find `className` strings with any arbitrary-value utility (`[#hex]`, `[Npx]`, `[N.Nrem]`). Even one hex color is opaque — extract it. Ask: "Can a developer understand the visual intent without decoding these values?" If not, extract.

## Step 2: Choose a Semantic Name

The class name should describe the UI concept, not the styles:

```
BAD:  .green-button, .large-shadow-card, .gray-border-input
GOOD: .btn-primary, .auth-card, .input-field, .status-icon
```

## Step 3: Add to theme.css

Add the class inside the `@layer components` block in `frontend/src/styles/theme.css`:

```css
@layer components {
  /* existing classes ... */

  .input-field {
    @apply w-full rounded-lg border border-[#e5e7eb] bg-white px-4 py-3 text-[15px] text-[#111827] placeholder:text-[#9ca3af] transition-all focus:border-[#10b981] focus:outline-none focus:ring-[3px] focus:ring-[#d1fae5];
  }
}
```

Rules:
- One `@apply` per class — all utilities on one line
- Keep variant-specific overrides inline in components (e.g., `auth-card p-12` when default is `p-10`)
- Error variants get their own class (`.input-field-error`) rather than conditional overrides

## Step 4: Replace in Components

```tsx
// Before — opaque
<div className="rounded-xl bg-white p-10 shadow-[0_10px_15px_-3px_rgba(0,0,0,0.1),0_4px_6px_-2px_rgba(0,0,0,0.05)]">

// After — readable
<div className="auth-card">
```

When a component needs the base pattern plus extras, compose:

```tsx
// Base + override
<div className="auth-card p-12 text-center">

// Base + interactive states (not in the @apply)
<button className="btn-primary hover:shadow-md active:translate-y-px">
```

## Step 5: Clean Up Imports

If the extracted class replaces a TypeScript constant (e.g., `INPUT_DEFAULT` from `input-styles.ts`):
1. Remove the import from the component
2. After all components are migrated, delete the constants file
3. Remove the file from any shared UI index

## Step 6: Verify

1. `cd frontend && npx vitest run` — all tests pass
2. Visual check — styles render identically (CSS `@apply` produces the same output)

## Checklist

1. [ ] Opaque className identified (1+ arbitrary-value utilities)
2. [ ] Semantic class name chosen (describes UI concept)
3. [ ] Class added to `@layer components` in `theme.css`
4. [ ] All component usages replaced
5. [ ] Variant overrides composed inline where needed
6. [ ] Old imports/constants cleaned up
7. [ ] Tests pass
