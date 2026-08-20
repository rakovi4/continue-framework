#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"

printf '# Shared project instructions (loaded by SessionStart)\n\n'
printf 'The following files are authoritative project instructions. Follow them for this session.\n'

for rule_file in "$repo_root/CLAUDE.md" "$repo_root"/.claude/rules/*.md; do
  [ -f "$rule_file" ] || continue
  relative_path="${rule_file#"$repo_root"/}"
  printf '\n---\n\n## Source: `%s`\n\n' "$relative_path"
  sed -n '1,$p' "$rule_file"
done
