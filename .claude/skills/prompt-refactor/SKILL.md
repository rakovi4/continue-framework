---
name: prompt-refactor
description: Scan a prompt file for layer violations and structural problems, then fix them. Use when user wants to clean up documentation files or mentions /prompt-refactor command.
---

# /prompt-refactor - Scan & Fix Documentation Files

Orchestrates prompt-refactor-agent to find and fix structural and layer placement issues in documentation files.

## Usage
```
/prompt-refactor refactor-agent.md              # Scan specific file
/prompt-refactor .claude/agents/red-agent.md    # Full path
/prompt-refactor                                # Scan all agents + skills
```

## Workflow

1. Parse user input (target file or "all")
2. Load agent instructions from `.claude/agents/prompt-refactor-agent.md`
3. Agent loads scan checklist from `.claude/templates/documentation/prompt-scan-checklist.md`
4. Execute scan → identify smells → fix one at a time
5. Return result: violations found, fixes applied, final state

## Layer-Specific

- Classification rules: `.claude/rules/prompt-rules.md`
- Two-layer structure: `.claude/rules/technology-loading.md`
- Scan checklist: `.claude/templates/documentation/prompt-scan-checklist.md`

## Next Step

After refactoring: review the diff to confirm fixes are clean.
