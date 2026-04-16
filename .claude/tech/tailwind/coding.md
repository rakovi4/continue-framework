# Tailwind CSS Conventions

Tech binding for `frontend-rules.md` CSS concerns. Shared section structure: `.claude/templates/coding/coding-sections.md`.

## Utility Framework

- CSS utility framework: Tailwind CSS.
- Extract inline Tailwind utilities to semantic `@apply` classes in `theme.css` when repeated or opaque.
- Opaque examples: `text-[#4b5563]`, `shadow-[...]`, `ring-[3px]`.
- Simple self-documenting utilities stay inline: `mb-5`, `text-center`, `flex gap-2`.

## Icons

- Icon library: `lucide-react` (v0.487.0, already in `package.json`).
- Import syntax: `import { HelpCircle } from 'lucide-react'`.
- NEVER write inline SVG `<path d="...">` or `<svg>` elements.
- Standard sizes: `size={16}` inline text, `size={20}` nav items, `size={24}` prominent.
