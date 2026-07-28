#!/usr/bin/env bash
# Harness-side agent timing instrumentation (Task 8, speed-up T1).
# Registered in .claude/settings.json on the Agent tool (PreToolUse /
# PostToolUse / PostToolUseFailure) and on SubagentStart / SubagentStop.
# Appends one JSONL record per event to a per-session timing log.
# Timestamps are stamped HERE, by the harness at each event — never
# agent-self-reported (checklist 1.2a).
#
# Two event families, because the Agent tool dispatches in the background:
#   dispatch / return / return_failure — the Agent TOOL CALL. For a
#     background dispatch, return stamps the launch acknowledgment
#     (milliseconds after dispatch), NOT agent completion.
#   subagent_start / subagent_stop — the actual subagent lifecycle; the
#     stop-minus-start delta is the agent's real wall-clock duration.
#     COVERAGE ASYMMETRY: SubagentStop also fires for spawn paths that
#     never emit SubagentStart (observed live: typeless, dispatch-less
#     stops while the start hook was provably active). Consumers must
#     classify stop-without-start instead of assuming pairing symmetry
#     (Step 2 premortem Incident 1); busy-time totals under-count these
#     untracked spawns.
#
# Usage: agent-timing.sh <event-kind>   (hook JSON on stdin)
#
# Record fields:
#   ts           UTC, millisecond precision — stamped by this script
#   event        one of the five kinds above
#   session_id   groups records into the per-session log file
#   tool_use_id  pairs a return with its dispatch (concurrency-safe)
#   agent_id     the SUBAGENT's own id. On subagent_start/stop it is the
#                payload's top-level agent_id; on tool events it comes
#                ONLY from tool_response.agentId — NEVER from the
#                top-level agent_id, which on tool events is the CALLING
#                agent's id (premortem Incident A). Empty when the
#                payload has no dispatched id (dispatch, return_failure,
#                array-shaped responses): an honest empty joins nothing,
#                a silent caller-id fallback joins the WRONG lifecycle
#                records without tripping any orphan guard.
#   caller_id    tool events only: the dispatching agent's id
#   agent_type   subagent type of the dispatched agent
#   description  the agent's short label
set -euo pipefail

event="${1:?usage: agent-timing.sh <event-kind>}"
input="$(cat)"
[ -n "$input" ] || input='{}'
ts="$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)"

project_dir="${CLAUDE_PROJECT_DIR:-.}"
log_dir="$project_dir/infrastructure/timings"
mkdir -p "$log_dir"

# jq preflight: the hook registration wraps this script in
# `2>/dev/null || true`, so without this check a missing jq kills every
# event invisibly and the session silently produces no timing data
# (agent-review Finding 2). stdout is NOT suppressed by the wrapper, so
# a systemMessage on stdout surfaces in the UI. The marker is keyed by
# SESSION (crude bash-regex extraction — jq is exactly what is missing
# here) so every new session re-warns; a single per-project marker
# would warn once ever, then go silent forever (premortem Incident 1).
if ! command -v jq >/dev/null 2>&1; then
  sid="unknown"
  [[ "$input" =~ \"session_id\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]] \
    && sid="${BASH_REMATCH[1]}"
  marker="$log_dir/.jq-missing-warned-$sid"
  if [ ! -e "$marker" ]; then
    : > "$marker"
    printf '%s\n' '{"systemMessage":"agent-timing hook: jq not found in PATH — agent timing records are NOT being written this session (Task 8 / speed-up T1 instrumentation)"}'
  fi
  exit 0
fi
# jq is available — clear stale warn markers so a LATER loss of jq
# warns again instead of hitting a marker armed by a transient hiccup.
rm -f "$log_dir"/.jq-missing-warned-*

session="$(jq -r '.session_id // "unknown"' <<<"$input")"

jq -cn --arg ts "$ts" --arg event "$event" --arg session "$session" --argjson in "$input" '{
  ts: $ts,
  event: $event,
  session_id: $session,
  tool_use_id: ($in.tool_use_id // ""),
  agent_id: (if ($event | startswith("subagent_"))
             then ($in.agent_id // $in.agentId // "")
             else ($in.tool_response.agentId? // "") end),
  caller_id: (if ($event | startswith("subagent_")) then ""
              else ($in.agent_id // "") end),
  agent_type: ($in.tool_input.subagent_type // $in.agent_type
               // $in.subagent_type // "unknown"),
  description: ($in.tool_input.description // $in.description // "")
}' >> "$log_dir/agent-timing-$session.jsonl"
