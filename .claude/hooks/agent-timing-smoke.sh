#!/usr/bin/env bash
# Smoke check for agent-timing.sh (Task 8, speed-up T1 — Step 1b).
# Pipes synthetic hook payloads through the real script into a temp dir
# and asserts each produces exactly one well-formed JSONL record with
# the expected field values. Exists because the hook registration wraps
# the script in `2>/dev/null || true` — in live use every failure is
# invisible, so this is the only place a regression fails loudly.
# Wired to the SessionStart hook in .claude/settings.json: silent on
# success, surfaces a systemMessage when any case fails.
#
# Usage: agent-timing-smoke.sh   (exit 0 = pass, non-zero = fail)
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
timing_script="$script_dir/agent-timing.sh"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

run_case() {
  local name="$1" event="$2" payload="$3" expect_filter="$4" session="${5:-smoke-session}"
  local log="$tmp_dir/infrastructure/timings/agent-timing-$session.jsonl"
  rm -f "$log"
  printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$tmp_dir" bash "$timing_script" "$event"
  [ -f "$log" ] && [ "$(wc -l <"$log")" -eq 1 ] \
    || { echo "FAIL $name: expected exactly 1 record in $log"; return 1; }
  jq -e "$expect_filter" "$log" >/dev/null \
    || { echo "FAIL $name: record failed assertion: $(cat "$log")"; return 1; }
  echo "PASS $name"
}

# return record: agent_id must be the DISPATCHED subagent's id from
# tool_response.agentId, not the caller's top-level agent_id
run_case "return-uses-dispatched-id" return \
  '{"session_id":"smoke-session","tool_use_id":"tu_1","agent_id":"caller-id",
    "tool_input":{"subagent_type":"premortem-agent","description":"d"},
    "tool_response":{"agentId":"dispatched-id"}}' \
  '.event=="return" and .agent_id=="dispatched-id" and .caller_id=="caller-id"
   and .agent_type=="premortem-agent" and .tool_use_id=="tu_1"
   and (.ts|test("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{3}Z$"))'

# dispatch record: no tool_response yet — agent_id must be an HONEST
# EMPTY, never the caller's id (which would join the wrong lifecycle)
run_case "dispatch-no-response" dispatch \
  '{"session_id":"smoke-session","tool_use_id":"tu_2","agent_id":"caller-id",
    "tool_input":{"subagent_type":"red-agent","description":"d"}}' \
  '.event=="dispatch" and .agent_id=="" and .caller_id=="caller-id"
   and .agent_type=="red-agent"'

# tool_response as ARRAY (content blocks) — .agentId? must not blow up,
# and must not fall back to the caller's id
run_case "return-array-response" return \
  '{"session_id":"smoke-session","tool_use_id":"tu_3","agent_id":"caller-id",
    "tool_input":{"subagent_type":"green-agent","description":"d"},
    "tool_response":[{"type":"text","text":"x"}]}' \
  '.event=="return" and .agent_id=="" and .caller_id=="caller-id"'

# return_failure: error-shaped (string) tool_response carries no
# agentId — agent_id empty, caller preserved in caller_id
run_case "return-failure-error-response" return_failure \
  '{"session_id":"smoke-session","tool_use_id":"tu_4","agent_id":"caller-id",
    "tool_input":{"subagent_type":"green-agent","description":"d"},
    "tool_response":"Error: agent terminated"}' \
  '.event=="return_failure" and .agent_id=="" and .caller_id=="caller-id"'

# subagent lifecycle record: top-level agent_id IS the subagent
run_case "subagent-stop" subagent_stop \
  '{"session_id":"smoke-session","agent_id":"sub-id","agent_type":"refactor-agent"}' \
  '.event=="subagent_stop" and .agent_id=="sub-id" and .caller_id==""
   and .agent_type=="refactor-agent"'

# empty stdin — must still land one record with defaults
run_case "empty-stdin" subagent_start "" \
  '.event=="subagent_start" and .session_id=="unknown" and .agent_id==""' \
  unknown

# jq-missing preflight: sandbox PATH has every tool the script needs
# EXCEPT jq → one systemMessage on stdout, marker created, no record
# written, exit 0; second run is silent
sandbox_bin="$tmp_dir/bin"
mkdir -p "$sandbox_bin"
for tool in bash date mkdir cat; do
  ln -s "$(command -v "$tool")" "$sandbox_bin/$tool"
done
jq_env="$tmp_dir/jq-missing-project"
run_missing() {
  printf '%s' "$1" | CLAUDE_PROJECT_DIR="$jq_env" PATH="$sandbox_bin" \
    bash "$timing_script" dispatch
}
out1="$(run_missing '{"session_id":"session-A"}')"
case "$out1" in *'"systemMessage"'*) ;; *)
  echo "FAIL jq-preflight: no systemMessage on first run"; exit 1;; esac
out2="$(run_missing '{"session_id":"session-A"}')"
[ -z "$out2" ] \
  || { echo "FAIL jq-preflight: second run same session not silent"; exit 1; }
# marker is per-session: a NEW session on the same jq-less machine must
# re-warn, not inherit an old session's silence
out3="$(run_missing '{"session_id":"session-B"}')"
case "$out3" in *'"systemMessage"'*) ;; *)
  echo "FAIL jq-preflight: fresh session did not re-warn"; exit 1;; esac
ls "$jq_env/infrastructure/timings"/*.jsonl >/dev/null 2>&1 \
  && { echo "FAIL jq-preflight: record written without jq"; exit 1; }
# jq back in PATH: a normal run must clear all warn markers so a later
# jq loss re-arms the warning instead of staying silent forever
printf '{"session_id":"session-A"}' | CLAUDE_PROJECT_DIR="$jq_env" \
  bash "$timing_script" dispatch
ls "$jq_env/infrastructure/timings"/.jq-missing-warned-* >/dev/null 2>&1 \
  && { echo "FAIL jq-preflight: markers not cleared once jq is back"; exit 1; }
echo "PASS jq-preflight (per-session warning, cleared when jq returns)"

echo "SMOKE OK"
