# QA prod-copy Browser Harness (watched, headed)

Manual-QA execution harness for driving an external environment (prod-copy) one
action at a time in a browser the tester watches. Used by `/qa-run`. Connect to an
already-running **headed** browser over the DevTools protocol (CDP) — never spawn a
headless one — so every step is visible to the tester.

## Principles

- **Connect, don't spawn.** Launch one headed Chromium with a remote-debug port at
  the start of the session; each step is a tiny script that *connects* over CDP, does
  ONE action, screenshots, and exits. The browser stays open between steps so the
  tester sees continuity.
- **One action, one screenshot.** Never script a whole case end-to-end.
- **UI-only navigation.** Click buttons/links; do **not** `goto()` an in-app URL (see
  `/qa-run` Core Constraints and frontend-rules "FORBIDDEN in-app navigation via
  URL"). `goto()` is allowed only for the app-root entry and genuine external-arrival
  links (an emailed verify/reset link).
- **No hardcoded port or URL.** Pick a free debug port and read the environment base
  URL from the task config; never bake either into the script (see
  `.claude/rules/infrastructure.md`).

## Launch the watched browser (once per session)

```bash
# DEBUG_PORT: a free port you pick (do NOT hardcode a fixed number)
# BROWSER:    a headed Chromium/Chrome binary
# PROFILE_DIR: an isolated, throwaway profile dir under the scratchpad
"$BROWSER" --remote-debugging-port="$DEBUG_PORT" --user-data-dir="$PROFILE_DIR" &
```

## Per-action step (one script per action, written to the scratchpad)

```js
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.connectOverCDP(`http://localhost:${process.env.DEBUG_PORT}`);
  const page = browser.contexts()[0].pages()[0];        // attach to the already-open tab

  // EXACTLY ONE action — click a visible control; never goto() an in-app path:
  await page.getByRole('link', { name: 'Settings' }).click();

  await page.screenshot({ path: `${process.env.SHOT_DIR}/step-NN.png` });
  // Do NOT call browser.close() — on a CDP connection it would terminate the watched
  // Chrome. Just let the process exit; the connection drops, the browser stays open.
})();
```

## Slow waits (scheduler tick, email delivery)

Never block >30s (CLAUDE.md Interaction Rules). Run the wait in the background and
poll with short, separate checks (each call <30s):

```bash
# bounded poll of an inbox / a status — short check, capped attempts
for i in $(seq 1 20); do <short-check> && break; sleep 5; done
```

## Credentials

External-integration credentials come from `infrastructure/creds.txt` (gitignored —
**NEVER commit**) and from the tester per case. Never echo a secret into a committed
file or into a screenshot filename.
