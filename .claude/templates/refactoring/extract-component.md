# Extract Component

**When to use:** A component file exceeds ~70–100 lines, or has a large JSX block (form field, section, card, banner) that can be isolated with clear props.

**Examples:**
- Form fields: EmailField, PasswordField, TermsCheckbox
- Sections: StatusBanner, SectionHeader, TaskCard, EmptyPlaceholder
- Views: ListView, DetailView (when a page has multiple UI branches)

## Step 1: Identify the Block

Find a self-contained JSX block in the page component:
- Form fields: `<div className="mb-6">` wrapping label + input + error
- Sections/cards: a visual section with its own `data-testid` or clear boundary
- UI branches: two completely different renders behind an `if` — extract each as a View component

## Step 2: Define Props Interface

Extract the minimal data the block needs from its parent:

```tsx
interface EmailFieldProps {
  value: string
  error?: string
  onChange: (value: string) => void
  onBlur: () => void
}
```

Rules:
- Pass primitive values, not the whole form state
- Callbacks take simple args (`string`, `boolean`), not events
- Keep the interface small — only what the block actually uses

## Step 3: Create Component File

Location: `frontend/src/features/{feature}/components/{ComponentName}.tsx`

```tsx
import { FieldError } from '@/app/components/ui/field-error'
import { INPUT_DEFAULT, INPUT_ERROR } from '@/app/components/ui/input-styles'

export function EmailField({ value, error, onChange, onBlur }: EmailFieldProps) {
  return (
    <div className="mb-6">
      <label htmlFor="email" className="...">Email</label>
      <input
        data-testid="email-input"
        value={value}
        onChange={e => onChange(e.target.value)}
        onBlur={onBlur}
        className={error ? INPUT_ERROR : INPUT_DEFAULT}
      />
      {error && <FieldError testId="email-error" message={error} />}
    </div>
  )
}
```

## Step 4: Replace in Page

```tsx
// Before: 15 lines of JSX
<div className="mb-6">
  <label>...</label>
  <input ... />
  {error && <FieldError ... />}
</div>

// After: 1 component call
<EmailField
  value={form.email}
  error={emailError}
  onChange={v => updateField('email', v)}
  onBlur={() => setEmailError(validateEmail(form.email).error)}
/>
```

## Step 5: Verify

1. `cd frontend && npx vitest run` — all tests pass
2. `data-testid` attributes preserved — Selenium tests unaffected

## Step 6: Extract Computed Values as Private Functions

When the parent component has local variables that compute derived data for child components,
extract them as private functions above the component. This eliminates local variables and
makes the render body a pure composition of named calls.

```tsx
// Before — cluttered locals in render body
export function BoardView({ columns, selectedColumnId }: Props) {
  const activeColumn = columns.find(c => c.type === 'active')
  const archiveColumn = columns.find(c => c.type === 'archive')
  const selectedColumn = columns.find(c => c.id === selectedColumnId)
  const taskCount = selectedColumn ? selectedColumn.tasks.length : 0
  const archivedCount = archiveColumn ? archiveColumn.tasks.length : 0
  return (<div>...</div>)
}

// After — private functions, render body reads like a sentence
function taskCount(columns: Column[], columnId: string) {
  return columns.find(c => c.id === columnId)?.tasks.length ?? 0
}
function selectedColumn(columns: Column[], selectedColumnId: string) {
  return columns.find(c => c.id === selectedColumnId)
}
function archivedBadge(columns: Column[]) {
  const archive = columns.find(c => c.type === 'archive')
  return archive ? `${archive.tasks.length} archived` : null
}

export function BoardView({ columns, selectedColumnId, onColumnSelect }: Props) {
  return (
    <div>
      <SectionHeader badge={archivedBadge(columns)} onSelect={onColumnSelect} />
      <TaskList column={selectedColumn(columns, selectedColumnId)} count={taskCount(columns, selectedColumnId)} />
    </div>
  )
}
```

## Checklist

1. [ ] JSX block identified
2. [ ] Props interface defined (minimal, primitive values)
3. [ ] Component created in `components/`
4. [ ] `data-testid` attributes preserved
5. [ ] Page component updated to use new component
6. [ ] Computed values extracted as private functions (no local variables in render)
7. [ ] Old imports cleaned up from page
8. [ ] Tests pass
