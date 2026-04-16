# Test Coverage Commands — Node/TypeScript (vitest/c8)

Universal workflow, module mapping, report format, and remediation: see `.claude/templates/testing/coverage-commands.md`.

## Run tests with coverage

For `usecase` or `domain`:
```bash
cd backend && npx vitest run --coverage {module}/src
```

For adapter modules:
```bash
cd backend && npx vitest run --coverage adapters/{adapter}/src
```

## Report locations

- JSON: `backend/coverage/coverage-final.json`
- LCOV: `backend/coverage/lcov.info`
- HTML: `backend/coverage/index.html`

## Module summary

```bash
npx c8 report --reporter=text-summary
```

## List classes with gaps

```bash
npx c8 report --reporter=text | grep -v "100 |" | grep -v "^-" | grep -v "^File"
```

## Focus filter — touched files

```bash
git diff HEAD --name-only -- 'backend/*/src/' 'backend/adapters/*/src/' | grep -v '__tests__' | sed 's/.*\///' | sed 's/\.ts//'
```

## Multi-module grouping

```bash
git diff HEAD --name-only -- 'backend/*/src/' 'backend/adapters/*/src/' | grep -v '__tests__' | sed -n 's|backend/adapters/\([^/]*\)/.*|\1|p; s|backend/\([^/]*\)/src/.*|\1|p' | sort -u
```

## Extract uncovered lines

```bash
npx c8 report --reporter=text | grep -A2 "{class_filter}"
```
