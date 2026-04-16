# Test Coverage Commands — Go (go test -cover)

Universal workflow, module mapping, report format, and remediation: see `.claude/templates/testing/coverage-commands.md`.

## Run tests with coverage

For `usecase` or `domain`:
```bash
cd backend && go test -coverprofile=coverage.out -covermode=atomic ./usecase/...
```

For adapter modules:
```bash
cd backend && go test -coverprofile=coverage.out -covermode=atomic ./adapters/{adapter}/...
```

## Report locations

- Text profile: `backend/coverage.out`
- HTML: `backend/coverage.html` (via `go tool cover -html=coverage.out -o coverage.html`)

## Module summary

```bash
go tool cover -func=coverage.out
```

## List classes with gaps

```bash
go tool cover -func=coverage.out | grep -v "100.0%"
```

## Focus filter — touched files

```bash
git diff HEAD --name-only -- 'backend/' | grep -v '_test.go' | sed 's/.*\///' | sed 's/\.go//'
```

## Multi-module grouping

```bash
git diff HEAD --name-only -- 'backend/' | grep -v '_test.go' | sed -n 's|backend/adapters/\([^/]*\)/.*|\1|p; s|backend/\([^/]*\)/.*|\1|p' | sort -u
```

## Extract uncovered lines

```bash
go tool cover -func=coverage.out | grep -A2 "{class_filter}"
```

For detailed line-level analysis:
```bash
go tool cover -html=coverage.out -o coverage.html
```
