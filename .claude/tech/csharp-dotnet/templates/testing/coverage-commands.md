# Test Coverage Commands — C#/.NET (Cobertura)

Universal workflow, module mapping, report format, and remediation: see `.claude/templates/testing/coverage-commands.md`.

## Run tests with coverage

For `usecase` or `domain`:
```bash
dotnet test backend/Usecase.Tests --collect:"XPlat Code Coverage" --results-directory TestResults/
```

For adapter modules:
```bash
dotnet test backend/Adapters/{Adapter}.Tests --collect:"XPlat Code Coverage" --results-directory TestResults/
```

## Report locations

- Cobertura XML: `TestResults/{guid}/coverage.cobertura.xml`
- HTML: `TestResults/CoverageReport/index.html` (via `reportgenerator`)

## Module summary

```bash
dotnet tool run reportgenerator -reports:TestResults/*/coverage.cobertura.xml -targetdir:TestResults/CoverageReport -reporttypes:TextSummary
cat TestResults/CoverageReport/Summary.txt
```

## List classes with gaps

```bash
dotnet tool run reportgenerator -reports:TestResults/*/coverage.cobertura.xml -targetdir:TestResults/CoverageReport -reporttypes:TextSummary
```

## Focus filter — touched files

```bash
git diff HEAD --name-only -- 'backend/*/.' 'backend/Adapters/*/.' | grep -v 'Tests/' | sed 's/.*\///' | sed 's/\.cs//'
```

## Multi-module grouping

```bash
git diff HEAD --name-only -- 'backend/*/.' 'backend/Adapters/*/.' | grep -v 'Tests/' | sed -n 's|backend/Adapters/\([^/]*\)/.*|\1|p; s|backend/\([^/]*\)/.*|\1|p' | sort -u
```

## Extract uncovered lines from Cobertura XML

```bash
CLASS_FILTER="{class_filter}"
python -c "
import xml.etree.ElementTree as ET
filters = '$CLASS_FILTER'.split(',')
tree = ET.parse('TestResults/coverage.cobertura.xml')
for pkg in tree.getroot().findall('.//package'):
    for cls in pkg.findall('.//class'):
        name = cls.get('filename', '').rsplit('/', 1)[-1].replace('.cs', '')
        if name not in filters:
            continue
        for line in cls.findall('.//line'):
            hits = int(line.get('hits', 0))
            nr = line.get('number')
            branch = line.get('branch') == 'true'
            cond = line.get('condition-coverage', '')
            missed_branch = 0
            if branch and cond:
                parts = cond.split('(')[1].rstrip(')').split('/')
                missed_branch = int(parts[1]) - int(parts[0])
            if hits == 0 or missed_branch > 0:
                print(f'  L{nr}: missed_hits={1 if hits==0 else 0} missed_branch={missed_branch}')
"
```
