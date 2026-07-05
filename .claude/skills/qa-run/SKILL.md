---
name: qa-run
description: Execute a QA task's manual checklist against an external environment (prod-copy) by driving a watched, headed browser one action at a time. Use when running a smoke/regression checklist against prod-copy, validating the critical path against real integrations, or when the user mentions /qa-run. Navigation is UI-only — reach every page by clicking, never by typing a direct in-app URL.
---

# /qa-run - Run a Manual QA Checklist Against prod-copy

Drive the cases of a QA task (created by `/task qa`) against the live external
environment, one case at a time, in a headed browser the tester watches. Each
case either **passes** (tick the box) or **fails** (leave `[ ]`, file a bug).

Executing the checklist also **validates the checklist itself** (the test model):
a case you cannot verify through the UI, or whose intent is ambiguous, is a defect
in the test model — fixed in the task `spec.md` — which is distinct from a product
defect, which becomes a `/task bug`.

## Input

- **target** (optional): QA task number/slug. If absent, infer the in-progress QA
  task from the task progress files / recent git log.

## Core Constraints

- **UI-only navigation.** Reach every page by clicking visible buttons, links, and
  menu items — never type, paste, or script a direct in-app URL. The only allowed
  direct-URL uses are the two carved out in `.claude/guidelines/frontend-rules.md`
  ("FORBIDDEN in-app navigation via URL"): the app root as the session entry point,
  and genuine external-arrival links a real user would click (an emailed
  verification or password-reset link). A manual tester must prove the same
  navigation paths a real user walks — the same constraint the Selenium rule applies
  to automated tests.
- **One action per step, watched.** Connect to a headed browser the tester can see;
  perform a single action, then screenshot, then say what to look for. Never batch a
  whole case into one scripted run — the point is for the tester to watch each step.
- **Real integrations, real creds.** External-integration credentials (external-API
  sandbox key, payment-gateway sandbox shop, mail inbox) come from
  `infrastructure/creds.txt` (gitignored — **NEVER commit**) and from the tester as
  each case needs them. Never echo a secret into a committed file or a screenshot name.
- **Never block >30s** (CLAUDE.md Interaction Rules). Long waits (a scheduler tick,
  email delivery) run in the background with short, separate polls (≤30s each).
- **Read-only on infrastructure.** prod-copy is a real environment — diagnose freely,
  change nothing (see `.claude/rules/infrastructure.md`). Read ports and base URLs
  from config; never hardcode them.

## Workflow

1. Read the QA task `spec.md` (case intent) and `progress.md` (which cases remain
   `[ ]`). Identify the next unchecked case.
2. Resolve the environment base URL and the harness debug port from the task config —
   do not hardcode either.
3. Start or attach to the watched harness (see Templates) — connect to an already-open
   headed browser; never spawn a hidden/headless one.
4. Establish the case's starting context the UI-only way: if it needs a state reached
   in a prior case (e.g. logged in), navigate there by clicking, or start from the app
   root and click through.
5. Drive the case one action at a time, screenshotting after each, until its intent is
   satisfied or contradicted.
6. **Record the verdict:**
   - **Pass** → tick the case `[x]` in `progress.md`.
   - **Product defect** → leave `[ ]`, file `/task bug` (prod-copy variant — it was
     reproduced there). Never mark a failed case `[x]`.
   - **Test-model defect** (unverifiable through the UI / case ambiguous) → leave `[ ]`,
     fix the case wording in `spec.md`, and report. This is the "validate the test
     model" outcome, not a product bug.
7. Repeat for the next case, or stop when the tester ends the session.
8. Commit ticked cases with the `task:` prefix (multiple cases may share one commit —
   a smoke session is not work-unit-atomic the way a TDD cycle is).

## Rules

- A failed case never becomes `[x]` — `[x]` means verified, `[ ]` means not-yet-verified
  or under investigation (see QA Task Sequence in `.claude/guidelines/workflow-detail.md`).
- Never commit `infrastructure/creds.txt` or any secret.
- Don't auto-advance past a failing case without the tester's acknowledgement.

## Templates

- `.claude/tech/playwright/templates/qa-prod-copy-harness.md` — watched headed-browser
  harness: connect-over-debug-protocol, one-action-per-step, per-action screenshot,
  background polling for slow waits.
