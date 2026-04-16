# Test Coverage Commands — PHP/Laravel (Clover)

Universal workflow, module mapping, report format, and remediation: see `.claude/templates/testing/coverage-commands.md`.

## Run tests with coverage

For `usecase` or `domain`:
```bash
cd backend && ./vendor/bin/phpunit --coverage-clover build/reports/coverage/clover.xml --coverage-html build/reports/coverage/html {module}/tests/
```

For adapter modules:
```bash
cd backend && ./vendor/bin/phpunit --coverage-clover build/reports/coverage/clover.xml --coverage-html build/reports/coverage/html adapters/{adapter}/tests/
```

## Report locations

- Clover XML: `backend/build/reports/coverage/clover.xml`
- HTML: `backend/build/reports/coverage/html/index.html`

## Module summary

```bash
php -r "
\$xml = simplexml_load_file('backend/build/reports/coverage/clover.xml');
\$metrics = \$xml->project->metrics;
\$statements = (int)\$metrics['statements'];
\$covered = (int)\$metrics['coveredstatements'];
\$conditionals = (int)\$metrics['conditionals'];
\$coveredCond = (int)\$metrics['coveredconditionals'];
echo 'Lines: ' . \$covered . '/' . \$statements . ' (' . round(\$covered*100/\$statements, 1) . '%)' . PHP_EOL;
if (\$conditionals > 0) {
    echo 'Branches: ' . \$coveredCond . '/' . \$conditionals . ' (' . round(\$coveredCond*100/\$conditionals, 1) . '%)' . PHP_EOL;
}
"
```

## List classes with gaps

```bash
php -r "
\$xml = simplexml_load_file('backend/build/reports/coverage/clover.xml');
foreach (\$xml->project->package as \$pkg) {
    foreach (\$pkg->file as \$file) {
        \$m = \$file->class->metrics ?? \$file->metrics;
        \$stmts = (int)\$m['statements'];
        \$covered = (int)\$m['coveredstatements'];
        if (\$stmts > 0 && \$covered < \$stmts) {
            \$pct = round(\$covered*100/\$stmts, 1);
            echo basename((string)\$file['name']) . ' -- ' . \$covered . '/' . \$stmts . ' (' . \$pct . '%)' . PHP_EOL;
        }
    }
}
"
```

## Focus filter — touched files

```bash
git diff HEAD --name-only -- 'backend/*/src/' 'backend/adapters/*/src/' | grep -v 'tests/' | sed 's/.*\///' | sed 's/\.php//'
```

## Multi-module grouping

```bash
git diff HEAD --name-only -- 'backend/*/src/' 'backend/adapters/*/src/' | grep -v 'tests/' | sed -n 's|backend/adapters/\([^/]*\)/.*|\1|p; s|backend/\([^/]*\)/src/.*|\1|p' | sort -u
```

## Extract uncovered lines from Clover XML

```bash
CLASS_FILTER="{class_filter}"
php -r "
\$filters = explode(',', '$CLASS_FILTER');
\$xml = simplexml_load_file('backend/build/reports/coverage/clover.xml');
foreach (\$xml->project->package as \$pkg) {
    foreach (\$pkg->file as \$file) {
        \$name = pathinfo((string)\$file['name'], PATHINFO_FILENAME);
        if (!in_array(\$name, \$filters)) continue;
        foreach (\$file->line as \$line) {
            \$type = (string)\$line['type'];
            \$num = (string)\$line['num'];
            \$count = (int)\$line['count'];
            if (\$type === 'stmt' && \$count === 0) {
                echo '  L' . \$num . ': missed' . PHP_EOL;
            }
            if (\$type === 'cond' && \$count === 0) {
                echo '  L' . \$num . ': missed_branch' . PHP_EOL;
            }
        }
    }
}
"
```
