---
name: cleanup-chrome
description: Kill orphaned chromedriver and headless Chrome processes left over from failed Selenium test runs. Use when Selenium tests mass-fail with Connection reset or TimeoutException, when the system feels sluggish during test runs, or when the user mentions /cleanup-chrome. Also use proactively before running frontend acceptance tests if previous runs were interrupted or stopped.
---

# Clean Up Orphaned Chrome Processes

Failed or interrupted Selenium test runs leave behind chromedriver and headless Chrome processes. These accumulate and exhaust system resources, causing new Selenium tests to fail with `Connection reset` / `TimeoutException` on the Chrome DevTools WebSocket.

## Action

1. **Count** orphaned processes to assess the situation:
   ```bash
   echo "chromedriver: $(tasklist //FI "IMAGENAME eq chromedriver.exe" 2>/dev/null | grep -c chromedriver)" && echo "chrome: $(tasklist //FI "IMAGENAME eq chrome.exe" 2>/dev/null | grep -c chrome)"
   ```

2. **Kill all** chromedriver processes (these are always test-spawned):
   ```bash
   taskkill //IM chromedriver.exe //F 2>&1 | tail -1
   ```

3. **Kill all** headless Chrome processes:
   ```bash
   taskkill //IM chrome.exe //F 2>&1 | tail -1
   ```

4. **Repeat** kill commands until counts reach 0 — processes can respawn briefly as child processes exit. Usually 2-3 rounds suffice.

5. **Clean locked test output** if it exists:
   ```bash
   rm -rf acceptance/build/test-results/frontendTest/binary 2>/dev/null
   ```

## Output

Report how many processes were killed and confirm cleanup is complete.

## Note

This kills ALL Chrome and chromedriver processes, including the user's own browser. Warn the user before proceeding if they might have a Chrome browser open with unsaved work.
