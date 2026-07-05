# Mockup Generation Rules

## Output Location

```
ProductSpecification/stories/NN-story-name/mockups/
├── desktop/
│   ├── 01-screen-name.html
│   └── screenshots/
└── mobile/
    ├── 01-screen-name.html
    └── screenshots/
```

## Using Templates

Use templates from `ProductSpecification/ui/templates/` as structural starting points:

| Page type | Start from template |
|-----------|-------------------|
| Login, Register, Forgot Password | `auth-layout.html` |
| Dashboard pages with sidebar | `dashboard-layout.html` |
| Error status (expired link, etc.) | `error-page.html` |
| Success status (email sent, etc.) | `success-page.html` |
| Form-heavy pages | Copy form elements from `form-elements.html` |
| Pages with sidebar | Copy sidebar block from `sidebar.html` |

**Copy the template's layout and sidebar verbatim. Customize only the main content area.**

## Shared Web Components (REQUIRED)

Any UI element repeated across 2+ stories MUST use a shared web component from `ProductSpecification/ui/components/`. Never inline HTML that a component already provides — Shadow DOM guarantees consistency.

**Before writing any structural HTML, check `ui/components/` for an existing component.** If none exists and the element will appear in multiple stories, create one.

Component naming convention: use a single project-wide prefix (e.g., `<app-sidebar>`, `<app-header>`, `<app-dashboard-stats>`). Decide the prefix once for the project and apply it consistently to every shared component.

Typical components to extract (the exact set depends on the project):

| Element | Example component | Example attributes |
|---------|------------------|--------------------|
| Desktop sidebar | `<app-sidebar>` | `active` |
| Mobile header | `<app-header>` | `title` |
| Mobile bottom nav | `<app-bottom-nav>` | `active` |
| Stat cards | `<app-dashboard-stats>` | `layout`, plus one attribute per stat |
| Dashboard table | `<app-dashboard-table>` | `layout`, `title`, `count`, `link-text`, `rows` (JSON) |
| Page table (with actions) | `<app-page-table>` | `layout`, `actions`, `create-button`, `filter-tabs`, `active-tab`, `rows` |
| Empty state | `<app-empty-state>` | `icon`, `title`, `description`, `button-text`, `button-icon` |

**Script import path** (from `stories/NN/mockups/desktop/`):
```html
<script src="../../../../ui/components/app-dashboard-stats.js"></script>
```

**Rules:**
- Always show all 4 stat cards. Use `0` for unavailable values, descriptive sub-text for context.
- Read each component's doc comment (top of `.js` file) for the full attribute API.
- Never duplicate component CSS inline — it will drift.
- After generating mockups, if a new structural pattern appears in 2+ places, extract it into a new component and backport to existing stories.

## Format

- Standalone HTML with embedded CSS. External dependencies: Google Fonts (Inter), Lucide icons CDN.
- `lang="ru"`. Interface text in Russian.
- All design tokens, spacing, typography, and component styles MUST match `ui-conventions.md`.
- Icons: use Lucide CDN per `.claude/guidelines/frontend-rules.md`. Add `<script src="https://unpkg.com/lucide@latest"></script>` in `<head>` and `<script>lucide.createIcons();</script>` before `</body>`. Reference icons by name using `<i data-lucide="icon-name"></i>`.
- Unsplash URLs for product images.
- One file per screen state. Naming: `NN-descriptive-name.html`.
- Desktop and mobile are separate files, NOT responsive breakpoints.

**Icon Reference:** See `.claude/templates/ui/icon-reference.md` for the full icon table.

## Desktop (viewport 1400px)

- `<meta name="viewport" content="width=1400">`
- Sidebar navigation from `sidebar.html` template
- Multi-column layouts where appropriate

## Mobile (viewport 375px)

- `<meta name="viewport" content="width=375">`
- Bottom sticky navigation
- Single-column layouts
- Touch targets min 44x44px

## Story-specifics

- If `interview.md` exists, apply its design notes
- Extract UI-relevant details from `interview.md`: field names and data displayed, user flow steps that imply distinct screen states, business rules that affect UI
- Apply these to mockup content and field labels
- Add HTML comments referencing external docs if applicable

## Completion Check

After generating all files, verify against the Screen Plan table:
- Every row has both desktop AND mobile files created
- File count matches plan exactly
- No spec screen state was skipped

If any file is missing, create it before proceeding.

## Conventions Evolution

After generating all mockups, review what you built:

1. **Did you create any new UI patterns** not covered by `ui-conventions.md`? Examples: new component type (modal, dropdown, tab bar), new page layout, new interaction pattern.
2. **Did you create any new reusable structures** that future stories might need?

If yes to either:
- Update `ProductSpecification/ui/ui-conventions.md` with the new pattern rules
- Optionally create a new template in `ProductSpecification/ui/templates/` if the structure is reusable
