# Plain CSS Conventions

Tech binding for `frontend-rules.md` CSS concerns. Shared section structure: `.claude/templates/coding/coding-sections.md`.

## Styling Approach

- CSS approach: semantic class names in external stylesheets. No utility-first framework.
- Define styles in component-scoped or feature-scoped `.css` files. Import stylesheets where the framework supports it, or use a single `theme.css` for shared styles.
- Use CSS custom properties (`--color-primary`, `--spacing-md`) for theming and design tokens. Define them on `:root` in the theme stylesheet.
- Naming: BEM-lite convention — `.block__element--modifier` for complex components, simple `.semantic-name` for standalone elements. Avoid deep nesting beyond 3 levels.

## Class Extraction

- Extraction triggers: see `frontend-rules.md` CSS Utility Extraction section.
- Extract to a named CSS class in the component stylesheet or `theme.css`. No `@apply` or utility framework syntax.
- Name classes by visual intent: `.card-header` not `.flex-row-between-padding-4`.
- One-off styles stay in the component stylesheet. Promote to `theme.css` only when shared across components.
- Avoid inline `style` attributes except for truly dynamic values (computed positions, percentages from data).

## Responsive Patterns

- Use CSS media queries for responsive breakpoints. Define breakpoint values as custom properties or comments at the top of the theme stylesheet.
- Mobile-first: base styles for small screens, `@media (min-width: ...)` for larger screens.
- Use `clamp()`, `min()`, `max()` for fluid typography and spacing where appropriate.

## Theming

- All colors, font sizes, spacing values, border radii, and shadows as CSS custom properties.
- Dark mode: override custom properties inside `@media (prefers-color-scheme: dark)` or a `.dark` class on the root element.
- Never hardcode color hex values in component stylesheets — reference custom properties.

## Icons

- Icon library: determined by the frontend framework profile (e.g., `lucide-react` for React, framework-appropriate alternative for Angular/Vue).
- Inline SVG prohibition and usage principles: see `frontend-rules.md` Icons section.
- Standard sizes for plain CSS: `width: 16px; height: 16px` inline text, `20px` nav items, `24px` prominent display.
