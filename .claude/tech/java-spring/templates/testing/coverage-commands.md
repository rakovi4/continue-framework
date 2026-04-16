# Test Coverage Commands — Java/Spring (JaCoCo)

Universal workflow, module mapping, report format, and remediation: see `.claude/templates/testing/coverage-commands.md`.

## Run tests with coverage

For `usecase` or `domain`:
```bash
cd backend && ./gradlew.bat :{module}:test :{module}:jacocoTestReport --rerun-tasks
```

For adapter modules:
```bash
cd backend && ./gradlew.bat :adapters:{adapter}:test :adapters:{adapter}:jacocoTestReport --rerun-tasks
```

## Cross-module coverage (domain in usecase)

JaCoCo reports only the current module's classes by default. Domain classes exercised by usecase tests won't appear unless `build.gradle` includes them:

```groovy
// In backend/usecase/build.gradle
jacocoTestReport {
    additionalSourceDirs.from(project(':backend:domain').sourceSets.main.java.srcDirs)
    additionalClassDirs.from(project(':backend:domain').sourceSets.main.output.classesDirs)
}
```

Without this, domain branch coverage gaps (e.g., null-check ternaries in value objects) are invisible. The same pattern applies to any module testing classes from a dependency module.

## Report locations

- CSV: `backend/{module}/build/reports/jacoco/test/jacocoTestReport.csv`
- CSV (adapters): `backend/adapters/{adapter}/build/reports/jacoco/test/jacocoTestReport.csv`
- XML: same directory, `.xml` extension
- HTML: `backend/{module_path}/build/reports/jacoco/test/html/index.html`

## Module summary

```bash
 awk -F',' 'NR>1 { lm+=$9; lc+=$10; bm+=$7; bc+=$8 } END { printf "Lines: %d/%d (%.1f%%)\nBranches: %d/%d (%.1f%%)\n", lc, lm+lc, (lm+lc>0)?lc*100/(lm+lc):100, bc, bm+bc, (bm+bc>0)?bc*100/(bm+bc):100 }' {csv_path}
```

## List classes with gaps

```bash
awk -F',' 'NR>1 && ($7>0 || $9>0) { printf "%s — lines: %d/%d (%.0f%%), branches: %d/%d (%.0f%%)\n", $3, $10, $9+$10, $10*100/($9+$10), $8, $7+$8, ($7+$8>0)?$8*100/($7+$8):100 }' {csv_path} | sort -t'(' -k3 -n
```

## Focus filter — touched files

```bash
git diff HEAD --name-only -- 'backend/*/src/main/' 'backend/adapters/*/src/main/' | sed 's/.*\///' | sed 's/\.java//'
```

## Multi-module grouping

```bash
git diff HEAD --name-only -- 'backend/*/src/main/' 'backend/adapters/*/src/main/' | sed -n 's|backend/adapters/\([^/]*\)/.*|\1|p; s|backend/\([^/]*\)/src/main/.*|\1|p' | sort -u
```

## Extract uncovered lines from XML

```bash
CLASS_FILTER="{class_filter}"
awk -v filters="$CLASS_FILTER" '
BEGIN { RS="<"; FS="[\" ]"; n=split(filters,filt,",") }
/^sourcefile / { src=""; for(i=1;i<=NF;i++) if($i=="name=") { src=$(i+1); sub(/\.java$/,"",src) } }
/^line / && src {
    nr=0; mi=0; mb=0
    for(i=1;i<=NF;i++) {
        if($i=="nr=") nr=$(i+1)+0
        if($i=="mi=") mi=$(i+1)+0
        if($i=="mb=") mb=$(i+1)+0
    }
    if((mi>0 || mb>0)) {
        for(f=1;f<=n;f++) if(src==filt[f]) print "  L"nr": missed_instr="mi" missed_branch="mb
    }
}
' {xml_path}
```
