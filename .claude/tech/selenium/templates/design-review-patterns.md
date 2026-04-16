# Design Review — Anti-Patterns & Output Format

## Anti-Patterns (BAD → GOOD)

### Email from mockup
```tsx
// BAD: hardcoded from mockup
<p className="text-sm text-gray-500">user@example.com</p>

// GOOD: from auth context
<p className="text-sm text-gray-500">{user.email}</p>
```

### Date from mockup
```tsx
// BAD: hardcoded from mockup
<span>Due: January 15, 2026</span>

// GOOD: from API response
<span>Due: {formatDate(task.dueDate)}</span>
```

### Status from mockup
```tsx
// BAD: hardcoded from mockup
<p className="text-xl font-bold">In Progress</p>

// GOOD: from API / data
<p className="text-xl font-bold">{task.status}</p>
```

### Count from mockup
```tsx
// BAD: hardcoded from mockup
<span className="badge">3 tasks</span>

// GOOD: from data
<span className="badge">{tasks.length} {tasks.length === 1 ? 'task' : 'tasks'}</span>
```

## Output Format

```
## Design Review: {ComponentName}

**Files reviewed:**
- `path/to/Component.tsx`
- `path/to/SubComponent.tsx` (if any)

**Mockup reference:**
- `path/to/mockup.html`

### Flagged Literals

| Line | Literal | Category | Verdict | Reason |
|------|---------|----------|---------|--------|
| 42 | `user@example.com` | Email | FAIL | User-specific, must come from auth context |
| 58 | `January 15, 2026` | Date | FAIL | Time-specific, must come from API |
| 71 | `Войти` | Button text | OK | Same for all users |

### Verdict: FAIL (2 violations)

**Required fixes:**
1. Line 42: Replace hardcoded email with `{user.email}` from auth context
2. Line 58: Replace hardcoded date with formatted API field
```

If no violations:
```
### Verdict: PASS

No mockup placeholder data detected. All dynamic values use props, context, or API responses.
```
