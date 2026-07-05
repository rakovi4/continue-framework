# Tailwind CSS Conventions

Tech binding for `frontend-rules.md` CSS concerns. Shared section structure: `.claude/templates/coding/coding-sections.md`.

## Utility Framework

- CSS utility framework: Tailwind CSS.
- Extract inline Tailwind utilities to semantic `@apply` classes in `theme.css` when a standalone `className` has 2+ utilities, when a single utility is opaque (arbitrary value), or when the combination repeats across 2+ components.
- Multi-utility chain (extract): any standalone `className` with 2+ utilities -- the count is the whole test, regardless of readability or breakpoints. `flex gap-2` -> `.button-row`, `mb-5 text-center` -> `.section-heading`, `min-w-0 flex-1` -> `.grow-cell`, `flex flex-col gap-4 lg:flex-row lg:items-start lg:gap-6` -> `.detail-header-row`, `grid grid-cols-1 gap-6 lg:grid-cols-2` -> `.detail-grid-2`. Variants count as utilities, so `hidden lg:inline` (2 utilities) extracts. Name by the element's role.
- Opaque single utility (extract): one arbitrary-value utility is enough -- `text-[#4b5563]`, `shadow-[...]`, `ring-[3px]`, `bg-[#f1f3f5]`.
- Stay inline only: a single standalone utility (`p-12`, `text-center`, `hidden`), or a semantic base class plus at most one small override/variant utility (`auth-card p-12`, `btn-primary hover:shadow-md`).
- Bounded exemption: a semantic base buys exactly one free override, not an unlimited trailing chain. 2+ trailing utilities, or a trailing set that introduces a new concern (layout cluster `flex items-center gap-2`, full sizing `w-full min-w-0 lg:w-[150px]`), is itself a chain -- extract a second semantic class for the trailing set and compose both class names in the markup (`filter-input date-picker-trigger`). Composing two class names is not a chain.
- Tailwind v4 `@apply` caveat: `@apply` works reliably only with real utility classes. Do NOT `@apply` a custom component/semantic class inside another (`@apply filter-input;` inside `.date-picker-trigger` is unreliable in v4). To reuse a semantic base, put only real utilities in the new class and compose both class names in the markup -- never nest semantic classes via `@apply`.

## Icons

- Icon library: `lucide-react` (v0.487.0, already in `package.json`).
- Import syntax: `import { HelpCircle } from 'lucide-react'`.
- NEVER write inline SVG `<path d="...">` or `<svg>` elements.
- Standard sizes: `size={16}` inline text, `size={20}` nav items, `size={24}` prominent.
