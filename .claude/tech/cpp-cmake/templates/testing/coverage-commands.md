# Test Coverage Commands — C++/CMake (lcov/llvm-cov)

Universal workflow, module mapping, report format, and remediation: see `.claude/templates/testing/coverage-commands.md`.

## Run tests with coverage

Build with coverage flags enabled, then run tests:

For `usecase` or `domain`:
```bash
cmake --build build --target {module}_tests && ./build/backend/{module}/{module}_tests
```

For adapter modules:
```bash
cmake --build build --target {adapter}_tests && ./build/backend/adapters/{adapter}/{adapter}_tests
```

Generate coverage report:
```bash
# Using lcov (GCC/gcov)
lcov --capture --directory build/backend/{module} --output-file build/coverage/{module}.info --rc lcov_branch_coverage=1
lcov --remove build/coverage/{module}.info '*/tests/*' '*/third_party/*' '/usr/*' --output-file build/coverage/{module}_filtered.info --rc lcov_branch_coverage=1
genhtml build/coverage/{module}_filtered.info --output-directory build/coverage/{module}_html --branch-coverage

# Using llvm-cov (Clang)
llvm-profdata merge -sparse build/coverage/{module}.profraw -o build/coverage/{module}.profdata
llvm-cov export ./build/backend/{module}/{module}_tests -instr-profile=build/coverage/{module}.profdata -format=lcov > build/coverage/{module}.info
```

## Report locations

- lcov info: `build/coverage/{module}_filtered.info`
- HTML: `build/coverage/{module}_html/index.html`

## Module summary

```bash
lcov --summary build/coverage/{module}_filtered.info --rc lcov_branch_coverage=1 2>&1 | grep -E 'lines|branches'
```

## List classes with gaps

```bash
lcov --list build/coverage/{module}_filtered.info --rc lcov_branch_coverage=1 2>&1 | grep -v '100.0%' | grep -v '^$' | grep -v 'Total'
```

## Focus filter — touched files

```bash
git diff HEAD --name-only -- 'backend/*/src/' 'backend/*/include/' 'backend/adapters/*/src/' 'backend/adapters/*/include/' | sed 's/.*\///' | sed 's/\.\(cpp\|h\)//'
```

## Multi-module grouping

```bash
git diff HEAD --name-only -- 'backend/*/src/' 'backend/*/include/' 'backend/adapters/*/src/' 'backend/adapters/*/include/' | sed -n 's|backend/adapters/\([^/]*\)/.*|\1|p; s|backend/\([^/]*\)/\(src\|include\)/.*|\1|p' | sort -u
```

## Extract uncovered lines from lcov

```bash
CLASS_FILTER="{class_filter}"
awk -v filters="$CLASS_FILTER" '
BEGIN { n=split(filters,filt,","); recording=0 }
/^SF:/ {
    src=$0; sub(/^SF:/,"",src); sub(/.*\//,"",src); sub(/\.(cpp|h)$/,"",src)
    recording=0
    for(f=1;f<=n;f++) if(src==filt[f]) { recording=1; print "\n" src ":" }
}
recording && /^DA:/ {
    sub(/^DA:/,"",$0); split($0,a,",")
    if(a[2]+0==0) print "  L" a[1] ": not covered"
}
recording && /^BRDA:/ {
    sub(/^BRDA:/,"",$0); split($0,a,",")
    if(a[4]=="-" || a[4]+0==0) print "  L" a[1] ": branch not taken (block=" a[2] " branch=" a[3] ")"
}
' build/coverage/{module}_filtered.info
```
