---
name: rca
description: Evidence-based root cause analysis for a defect — re-verify every prior assumption, test competing hypotheses, and confirm the cause with real data (logs, test runs, measurements) before any fix. Use for the bug-task `root cause analysis` step, or whenever a cause is claimed but not yet proven.
---

# /rca - Root Cause Analysis

Find the real cause of a defect from evidence, not speculation. The deliverable is a cause you have **confirmed against real data** — logs, test runs, query plans, measurements you actually pulled — recorded in the task `spec.md`. Producing a plausible-sounding story is the failure mode this skill exists to prevent: a narrative that was never checked against data is a guess, even when it reads like a conclusion.

## Input

- **target** (optional): bug task number/slug, or a free-text symptom. If absent, infer from the current task or conversation.
- **evidence sources** (optional): credentials or paths for authoritative data (CI API, log locations, a reproducible environment). When provided, use them — do not substitute a guess for data you could fetch.

## Core Principle

Every prior claim is a hypothesis until you re-verify it here — including claims already written in `spec.md`, an earlier RCA attempt, a code comment, or this conversation. Carrying a prior hypothesis forward as established fact is the exact failure this skill exists to prevent. Re-derive each claim from primary evidence, or mark it unverified. Distinguish **MEASURED** (you observed it directly) from **REASONED** (you inferred it from code plus rules) on every statement, and never present REASONED as MEASURED.

## Workflow

1. **State the symptom precisely.** Pull the exact observable from its authoritative source — the test report, the log line, the failing assertion message — with exact values, units, and frequency, not a paraphrase. For an intermittent failure, get the real pass/fail count and the measured values on both sides of the boundary. Quote the source. Confirm which value the assertion actually checks (it is often not the one a summary reports).

2. **Audit prior assumptions.** List every claim the existing write-up, prior RCA, comments, or conversation treats as known. For each, record a status — verified (with evidence), refuted (with evidence), or unverified — and reuse no prior conclusion you have not personally re-confirmed.

3. **Enumerate competing hypotheses.** Write at least two or three distinct candidate causes, not one favored story. A single hypothesis is a red flag: if you can only think of one, you have not researched enough.

4. **Gather real evidence per hypothesis.** For each, name the concrete data that would confirm or refute it, then go get it — run the failing test, pull the logs, read the code path end to end, inspect the query plan / config / index / schema, measure. Label every fact MEASURED or REASONED.

5. **Verify or refute each hypothesis.** Converge on the cause the evidence supports and explicitly knock out the ones it contradicts. State plainly what you could NOT measure and why (no access, environment unavailable) — an honest gap beats fabricated certainty.

6. **Trace the full path.** Confirm you hold the whole mechanism, not a fragment: re-read the actual code path for the failing operation and check for steps a prior write-up omitted (an extra call, a second query, a retry, a hidden count). A scope correction to an earlier RCA is itself a finding.

7. **Record the RCA.** Write findings into the task `spec.md` using `.claude/templates/workflow/rca-format.md` — symptom, assumptions audit, hypotheses with verdicts, and a conclusion that separates MEASURED facts from REASONED attribution and lists residual unknowns. Update `progress.md`: mark `root cause analysis` `[x]` with a one-line pointer to the spec section.

8. **Commit** progress-only (`task:` prefix for tasks).

## Constraints

- Runs **inline** (no subagent) — the evidence-gathering must be visible to the user as it happens, not collapsed into an opaque summary.
- **No production or test code changes.** RCA only investigates and documents; the fix is designed in the following `design` step and implemented in later TDD steps.
- Do not mark `root cause analysis` `[x]` until at least one hypothesis is confirmed by real data, OR you have documented exactly why the cause cannot be measured and what the best-supported attribution is.
- If a credential or environment is read-only or unavailable, say so and record the limit — never paper over a missing measurement with a plausible inference dressed up as fact.

## Templates

- `.claude/templates/workflow/rca-format.md` — RCA write-up structure (symptom, assumptions audit, hypotheses table, conclusion).

## Next Steps

- `design` (`/design-preview`) — design the fix against the confirmed cause.
