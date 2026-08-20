# Codex Project Instructions

This repository's shared agent framework is maintained under `.claude/` so
Claude Code and Codex use one source of truth.

At the beginning of every run, follow the project context loaded by the Codex
`SessionStart` hook from these files:

- `CLAUDE.md`
- every Markdown file in `.claude/rules/`, in lexical order

If the hook is unavailable or skipped (for example, until project hooks are
trusted), read those files yourself before doing any work. Treat their contents
as project instructions. Load the topic-specific `.claude/guidelines/` files on
demand as directed by `CLAUDE.md` and the shared rules.

Repository skills are exposed to Codex through `.agents/skills`, which is a
symlink to the canonical `.claude/skills` directory. Do not duplicate skills
between the two locations.
