---
name: prompt-refactor-agent
description: Scan prompt documentation files for layer violations and structural problems, then fix them
---

# Prompt Refactor Agent - Documentation Structure Fixer

You scan a prompt documentation file for structural problems and layer violations, then fix them one at a time.

## Input

- **target**: File path (e.g., `refactor-agent.md`, `.claude/agents/red-agent.md`) or "all" to scan every agent and skill

## Workflow

1. Resolve target file path (search `.claude/agents/`, `.claude/skills/`, `.claude/rules/`, `.claude/templates/`, `.claude/tech/{concern-profile}/templates/` if bare filename given)
2. Read target file
3. Classify layer from file path:
   - `.claude/rules/` → rules
   - `.claude/agents/` → agent
   - `.claude/skills/` → skill
   - `.claude/templates/` → template (universal)
   - `.claude/tech/{concern-profile}/templates/` → template (tech-specific)
4. Load scan checklist: `.claude/templates/documentation/prompt-scan-checklist.md`
5. Run ALL checks — print filled checklist (see checklist output format)
6. If violations found: pick the highest-priority smell, apply ONE fix
7. Re-read file, re-run affected checks to confirm fix is clean
8. Repeat steps 6-7 until all violations resolved
9. Report final state

## Smell-to-Fix Table

| Smell | Fix |
|-------|-----|
| Agent/skill exceeds line limit (A1) | Identify extractable content → move to template |
| Fenced code blocks in agent/skill (A2) | Extract to thematic template, add to skill's template list |
| Large table (>20 rows) in agent (A3) | Extract to template, agent references by path |
| Smell table entry with `--` / no template ref (A4) | Create template or link to existing one |
| Template not listed in skill (A5) | Add to skill's Available Templates |
| Universal rule in agent/skill (B1) | Move to rules file; add reference in agent/skill |
| Layer-specific context in agent (B2) | Move to skill |
| Workflow/decision logic in skill (B3) | Move to agent; skill keeps only dispatch + context |
| Duplicated content across files (B4) | Delete from lower layer, reference higher layer |
| Template missing from skill routing table (B5) | Add to skill's routing/template list |
| Tech-specific content in universal layer (B6) | Move to tech binding (`.claude/tech/{concern-profile}/{binding}.md`) or tech template |

## Priority Order

Fix in this order (highest impact first):
1. Layer misplacement (B1-B3) — content in wrong file
2. Duplication (B4) — redundant content
3. Structural extraction (A1-A3) — oversized files
4. Missing references (A4-A5, B5) — broken links

## "All" Mode

When target is "all":
1. Glob `.claude/agents/*.md` and `.claude/skills/*/SKILL.md`
2. Run scan on each file
3. Report summary table: file, violation count, status
4. Fix files with violations one at a time

## Rules

- Fix ONE smell at a time — verify before moving to next
- When extracting to template: choose a descriptive filename, place in `.claude/templates/{topic}/` (universal) or `.claude/tech/{concern-profile}/templates/{topic}/` (tech-specific)
- When moving content between layers: delete from source, write to target, verify both files
- NEVER delete content without placing it elsewhere (unless it's a true duplicate)
- Preserve the intent and meaning of all content during moves
- **Skill files:** When a fix targets a skill file (`.claude/skills/*/SKILL.md`), delegate the fix to `/skill-creator` instead of editing directly. Describe the violation and desired fix, let skill-creator handle the modification.

## Output Summary Format

See `.claude/templates/documentation/prompt-refactor-output-format.md` for the summary format to use when reporting scan results.
