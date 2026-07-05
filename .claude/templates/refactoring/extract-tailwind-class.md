# Extract Tailwind @apply Class

**When to use:** A standalone `className` string contains 2+ Tailwind utilities. The count is the whole test — readability of each token and whether it restructures across breakpoints are NOT exemptions, and variants (`lg:`, `hover:`) count as utilities. Also applies to a single utility with an arbitrary value (`text-[#4b5563]`, `shadow-[...]`, `ring-[3px]`, `bg-[#f1f3f5]`) — even one hex code is opaque — and to any combination repeated across 2+ components. A chain of self-documenting tokens is still a chain the reader must parse and re-assemble into one intent; give the intent a name.

**Examples:**
- `shadow-[0_10px_15px_-3px_rgba(0,0,0,0.1),0_4px_6px_-2px_rgba(0,0,0,0.05)]` → `.auth-card`
- `border border-[#e5e7eb] bg-white px-4 py-3 text-[15px] text-[#111827] placeholder:text-[#9ca3af]` → `.input-field`
- `flex items-center justify-center rounded-full` → `.status-icon`
- `flex gap-2` → `.button-row` (2-utility chain)
- `mb-5 text-center` → `.section-heading` (2-utility chain)
- `min-w-0 flex-1` → `.grow-cell` (2-utility chain)
- `hidden lg:inline` → `.nav-label-desktop` (variants count — 2-utility chain)
- `flex flex-col gap-4 lg:flex-row lg:items-start lg:gap-6` → `.detail-header-row`
- `mb-6 grid grid-cols-1 gap-6 lg:grid-cols-2` → `.detail-grid-2`

**NOT candidates** (stay inline):
- A single standalone utility — `p-12`, `text-center`, `hidden` — one token, nothing to name
- A semantic base class plus override/variant utilities — `auth-card p-12`, `btn-primary hover:shadow-md active:translate-y-px` — the semantic class is already extracted; the remaining overrides are composition, not a chain

## Step 1: Identify the Pattern

Find `className` strings that are either (a) a single arbitrary-value utility (`[#hex]`, `[Npx]`, `[N.Nrem]`) — even one hex color is opaque, or (b) a standalone chain of 2+ utilities (count every space-separated token, variants included; skip tokens that are an already-extracted semantic class). The only stay-inline cases are a single standalone utility and a semantic base class plus override/variant utilities.

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

1. [ ] Extractable className identified (2+ standalone utilities, or 1+ arbitrary-value utility)
2. [ ] Semantic class name chosen (describes UI concept)
3. [ ] Class added to `@layer components` in `theme.css`
4. [ ] All component usages replaced
5. [ ] Variant overrides composed inline where needed
6. [ ] Old imports/constants cleaned up
7. [ ] Tests pass
