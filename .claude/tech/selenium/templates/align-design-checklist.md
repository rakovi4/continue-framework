# Align Design — Checklist & Patterns

## Design Token Extraction Checklist

Read the mockup HTML carefully. Extract EVERY CSS value:

### Page Layout
- [ ] Body/page background color
- [ ] Container max-width
- [ ] Centering method and padding

### Card/Container
- [ ] Background color
- [ ] Border (presence, color, width)
- [ ] Border radius
- [ ] Padding (all sides)
- [ ] Box shadow (exact value)

### Typography
- [ ] Logo: font-size, font-weight, letter-spacing, color, accent color
- [ ] Title: font-size, font-weight, color, margin-bottom
- [ ] Subtitle: font-size, color
- [ ] Labels: font-size, font-weight, color, margin-bottom
- [ ] Helper/muted text: font-size, color
- [ ] Optional markers: font-size, font-weight, color

### Form Inputs
- [ ] Padding (vertical and horizontal)
- [ ] Font size
- [ ] Border: color, width, radius
- [ ] Background color
- [ ] Placeholder color
- [ ] Focus state: border color, ring/shadow color and size

### Buttons
- [ ] Padding (vertical and horizontal)
- [ ] Font size, font weight
- [ ] Border radius
- [ ] Background color, hover color
- [ ] Text color
- [ ] Hover shadow
- [ ] Active state (transform)

### Spacing
- [ ] Gap between form groups (margin-bottom)
- [ ] Gap between label and input
- [ ] Spacing around dividers
- [ ] Section margins

### Special Elements
- [ ] Password toggle: position, colors, hover state
- [ ] Checkbox: size, accent color
- [ ] Divider: line color, text background, width calculation
- [ ] Links: color, hover decoration, font-weight
- [ ] Icons: size, color, stroke vs fill

### Element Inventory

Before checking styling, list EVERY element from the mockup:
- [ ] Interactive elements (buttons, links, toggles, inputs)
- [ ] Informational elements (hints, warnings, badges, status indicators, icons)
- [ ] Structural elements (sidebar, header, cards, sections)

Compare each against React component. Mark: MISSING / MISPLACED / MATCHED.
Fix any MISSING or MISPLACED elements before proceeding to styling.

### Icon Audit

- [ ] Every icon uses lucide-react import (no inline SVGs)
- [ ] Icon names match Lucide catalog (check lucide.dev/icons)
- [ ] Icon sizes match context: size={16} inline, size={20} nav, size={24} prominent

## Common Mismatches

| Issue | Mockup | Typical React/shadcn Default |
|-------|--------|------------------------------|
| Page bg | `#fafbfc` (light gray) | `#ffffff` (white) |
| Card | No border, large padding | Has border, small padding |
| Input bg | White `#ffffff` | Gray `#f3f3f5` (input-background) |
| Input height | `padding: 12px 16px` (tall) | `h-9` / 36px (short) |
| Button height | `padding: 14px 24px` (tall) | `h-9` / 36px (short) |
| Focus ring | Green glow `#d1fae5` | Default ring color |
| Border radius | `8px` / `12px` | `0.625rem` / `calc(var(--radius))` |
| Font sizes | Exact px values | Tailwind defaults |

## Styling Approach

- **Prefer native HTML elements** (`<input>`, `<button>`, `<label>`) with explicit Tailwind classes over shadcn components when shadcn defaults conflict with the mockup.
- **Keep shadcn components** only when their styling matches (e.g., `Checkbox` with Radix primitives).
- Use **exact hex colors** from mockup CSS variables, not Tailwind color names.
- Use **exact pixel/rem values** from mockup, not Tailwind approximations.
