# Task Creation Formats

## Usage Examples

```
/task bug "Modal scroll broken"
/task refactoring "TaskBoard aggregate"
/task                                        # Interactive
```

## spec.md Format

```markdown
# Task {N}: {Title}

Type: {bug|refactoring}

## Problem

{description}

## Solution

{description}

## Key Files

- {file paths}

## Reproduction  <- bug only

{steps}
```

## progress.md Formats

### Bug (backend)

```markdown
# Task {N}: {Title} -- Progress

Type: bug

## Spec
- [x] spec

## Backend

### Fix: {bug description}
- [ ] red-acceptance
- [ ] red-usecase
- [ ] green-usecase
- [ ] adapters-discovery
- [ ] green-acceptance
```

### Bug (frontend)

```markdown
# Task {N}: {Title} -- Progress

Type: bug

## Spec
- [x] spec

## Frontend

### Fix: {bug description}
- [ ] red-selenium
- [ ] red-frontend
- [ ] green-frontend
- [ ] red-frontend-api
- [ ] green-frontend-api
- [ ] align-design
- [ ] green-selenium
- [ ] demo
```

### Refactoring

```markdown
# Task {N}: {Title} -- Progress

Type: refactoring

## Spec
- [x] spec

## Fix

### Step 1: {description}
- [ ] red-adapter h2
- [ ] green-adapter h2

### Step 2: {description}
- [ ] refactor usecase
- [ ] refactor (cleanup)
- [ ] green-acceptance
```
