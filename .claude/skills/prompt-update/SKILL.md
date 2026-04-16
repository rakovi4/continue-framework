---
name: prompt-update
description: Classify new content (rule, pattern, workflow step) and write it to the correct documentation layer. Use when user wants to add prompt documentation or mentions /prompt-update command.
---

# /prompt-update - Classify & Place Documentation Content

Classify a piece of new content and write it to the correct file(s) in the project's documentation layers.

## Usage
```
/prompt-update "always use eq() not any() in Mockito"
/prompt-update "test-review should catch Fake storage assertions"
/prompt-update                          # Interactive — asks what to add
```

## Workflow

1. **Parse input.** If no content provided, ask the user what to add.
2. **Understand the content.** What does it mean? Is it a principle, a detection pattern, a code example, a workflow step?
3. **Classify targets** using `.claude/templates/documentation/prompt-update-classification.md`. Walk ALL 4 decision questions explicitly — principle, detection pattern, code example, layer-specific context. Show the classification before writing:
   ```
   1. Principle? → frontend-rules.md (new section)
   2. Detection? → refactor-agent.md (smell table) + scan-checklist.md (A-check)
   3. Template?  → new templates/refactoring/extract-tailwind-class.md
   4. Layer-specific? → n/a
   ```
   Most updates touch 2+ files. If only one target is identified, double-check — a rule without detection won't be enforced, a detection without a template won't guide the fix.
4. **Check for duplication** — grep key terms across `.claude/rules/`, `.claude/tech/`, `.claude/agents/`, `.claude/skills/`, `.claude/templates/`. If a duplicate exists, report it and ask: skip, merge, or replace?
5. **Write to all target files** in one pass. Match each file's existing style.
6. **Tech-agnostic gate** — for every write targeting a universal file (`.claude/rules/`, `.claude/templates/`), scan the content you just wrote for tech leaks. See "Tech-Agnostic Verification" in the classification template. If a leak is found, rephrase in universal terms first — only relocate to tech binding when the content is inherently tech-specific.
7. **Report** what was written and where (see Output format in classification template).
8. **Verify with `/skill-creator`** — see Impact Assessment in classification template.

## Constraints

- Never create new rules files — content fits existing files
- Never place fenced code blocks in agents or skills — extract to templates
- Never edit skill files directly — delegate to `/skill-creator`
- Always check for duplication before writing
- Preserve existing formatting and section structure of target files
- When the principle already exists in a higher layer, don't re-state it — add only the enforcement mechanism

## Templates

- `.claude/templates/documentation/prompt-update-classification.md` — classification guide, decision process, examples, impact assessment

## Next Steps

1. `/prompt-refactor {target-file}` — verify the file is still structurally clean.
2. `/skill-creator` — verify affected skills respect the new content (when Impact Assessment says to run it).
