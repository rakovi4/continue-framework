# Prompt Documentation Scan Checklist

**Run EVERY check on the target file. Show results. Fix violations before declaring clean.**

## Section A: Structural scan (enumerate)

Produce structural data. Violation is numeric/objective.

**File size:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A1 | File line count | Total lines | Agent > 100 lines, skill > 70 lines |

**Inline content:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A2 | Fenced code blocks (```) in agent or skill | Count and line ranges of each fenced block | Any fenced code block — should be in template |
| A3 | Tables with > 20 rows in agent | Row count per table | Any table exceeding 20 rows — exempt smell→template routing tables (each row carries a distinct fix hint) |

**Completeness:**

| # | Check | Enumerate | Violation |
|---|-------|-----------|-----------|
| A4 | Smell/routing table entries with `--` or missing template reference | Entries without a template path | Any entry lacking a concrete reference |
| A5 | Templates in directory vs listed in skill | Compare filesystem templates with skill's template list | Any mismatch (template exists but not listed, or listed but doesn't exist) |

## Section B: Layer placement (cite evidence)

Read the content. Answer the question. **Cite the line or section as evidence, or write "none found."**

| # | Question | Evidence required |
|---|----------|------------------|
| B1 | Does the file contain content that applies to ALL layers? (universal rule or principle) | Quote the content — belongs in `.claude/rules/` |
| B2 | Does the agent contain layer-specific context? (paths, config, or conventions for one specific adapter/layer) | Quote the content — belongs in skill or template |
| B3 | Does the skill contain workflow logic or decision trees? (if/then routing, multi-step algorithms) | Quote the content — belongs in agent |
| B4 | Is there duplicated content between this file and another layer? | Quote both locations |
| B5 | Are all templates referenced in routing/smell tables also listed in the skill's Available Templates? | List any missing references |
| B6 | Does a universal file (`.claude/rules/`, `.claude/templates/`) contain tech-specific content? (framework names, annotations, library APIs, CLI commands) | Quote the content — belongs in `.claude/tech/{concern-value}/` |

## Scan output format

**Print this filled checklist before starting fixes:**

```
## Prompt Scan: {filename}

### A. Structural
A1. File size: {N} lines → {clean | VIOLATION: exceeds {limit}}
A2. Fenced code blocks: {none | {count} blocks at L{start}-L{end}, ...} → {clean | VIOLATION}
A3. Large tables: {none | table "{name}" has {N} rows} → {clean | VIOLATION: > 20 rows}
A4. Missing template refs: {none | entry "{name}" has no ref} → {clean | VIOLATION}
A5. Template mismatch: {none | "{file}" not listed in skill} → {clean | VIOLATION}

### B. Layer Placement
B1. Universal rules: {none found | "{quoted content}" L{N} → VIOLATION: move to rules}
B2. Layer-specific in agent: {none found | "{quoted content}" L{N} → VIOLATION: move to skill}
B3. Workflow in skill: {none found | "{quoted content}" L{N} → VIOLATION: move to agent}
B4. Duplication: {none found | "{content}" in both {file1} and {file2} → VIOLATION}
B5. Template refs: {all listed | "{template}" missing from skill → VIOLATION}
B6. Tech leakage: {none found | "{quoted content}" L{N} → VIOLATION: move to tech binding}
```

**If any item has a violation, fix it BEFORE reporting "no issues."**
