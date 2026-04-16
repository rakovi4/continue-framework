---
name: screenshot
description: Take screenshots of HTML mockups from any version. Use when user wants to capture mockups as PNG images, regenerate screenshots, or mentions /screenshot command.
---

# Screenshot HTML Mockups

Automate taking screenshots of HTML mockups using Puppeteer from a centralized runner location.

## Usage
```
/screenshot [folder/file]
```

## Mockups Location

Default location: `ProductSpecification/stories/*/mockups/`

## Workflow

### Phase 1: Determine Scope

Parse user input to determine target:

**Folder/file filtering:**
- `/screenshot` — All mockups in default location
- `/screenshot login.html` — Single file
- `/screenshot 01_auth` — Files matching pattern

### Phase 2: Ensure Puppeteer Environment

The centralized Puppeteer runner is in `.screenshots-temp/`:

1. Check if `.screenshots-temp/node_modules` exists:
   - If not: run `cd .screenshots-temp && npm install`
2. This only needs to happen once, not per-mockup-directory

### Phase 3: Run Screenshot Script

Execute from the centralized location:

```bash
cd .screenshots-temp && node take-screenshots.js [target]
```

**Examples:**
```bash
# All mockups in default directory
cd .screenshots-temp && node take-screenshots.js

# Specific file (relative to repo root)
cd .screenshots-temp && node take-screenshots.js ../ProductSpecification/stories/01-create-task/mockups/desktop/create-task.html

# Directory with HTML files
cd .screenshots-temp && node take-screenshots.js ../ProductSpecification/stories/01-create-task/mockups/desktop/

# Filter by filename pattern
cd .screenshots-temp && node take-screenshots.js ../ProductSpecification/stories/01-create-task/mockups/ mobile
```

### Phase 4: Output Summary

Report to user:
- Number of screenshots taken
- Output location (screenshots saved alongside HTML files or in `screenshots/` subfolder)
- Any failures encountered

## Example Invocations

```
/screenshot                           # All mockups
/screenshot login.html                # Specific file
/screenshot mobile                    # Files containing "mobile"
```

## Design Constraints

- **Mobile detection**: Files in a `mobile/` parent directory use mobile viewport (390x844)
- **Desktop viewport**: 1400x900
- **Element selector**: Crop to `.mockup-card` element when present
- **Fallback**: Full page screenshot if `.mockup-card` not found
- **Format**: PNG
- **Output**: `screenshots/` subfolder next to each HTML file (per-directory, not centralized)
- **Skip**: `node_modules/`, `screenshots/`, and `screenshots-live/` directories

## Notes

- Puppeteer is pre-installed in `.screenshots-temp/`
- No npm installation needed in mockup directories
- Screenshots are deterministic for visual regression testing
- Re-running overwrites existing screenshots
