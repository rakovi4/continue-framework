---
name: api-spec
description: Generate OpenAPI specifications for story endpoints. Use when user wants to create API specs for a story or mentions /api-spec command.
---

# Generate API Specification

Generate OpenAPI 3.0.3 specifications for frontend endpoints in a story.

## Usage
```
/api-spec "Story name"
/api-spec 5                    # By MVP story number
/api-spec                      # Interactive selection
```

## MVP Mindset

**Generate the MINIMUM viable API, not the complete API.**

- Prefer fewer endpoints - consolidate where possible
- No health/status endpoints (infrastructure, not features)
- No separate replace endpoints (use PUT on same resource)
- No separate "get current state" if POST response returns it
- When in doubt, leave it out

## Workflow

### Phase 1: Context & Story Selection

1. Read context files:
   - `ProductSpecification/BriefProductDescription.md`
   - `ProductSpecification/stories.md`

2. Parse user input to find target story (by name, number, or interactive)

3. Read the **target** story's folder — `stories/NN-story-name/` first, then `stories/done/NN-story-name/` (`.claude/rules/workflow.md`, "Resolving a story folder"), since an unresolved archived folder reads exactly like a story with no interview: `NN_StoryName.md` (specification), `mockups/` (UI mockups — the fields each screen needs), `interview.md` if it exists (authoritative source for API details)

4. Read what the areas this story touches already expose — the **acceptance tests of those areas**, for their request/response shapes, status codes and Statements. Never sweep `stories/*/mockups/` or `stories/*/interview.md` to reconstruct it (`.claude/rules/workflow.md`, "Where the Current State Lives"). Only **enabled** tests count as shipped — one still carrying its disable/skip marker is a pending increment, not a live endpoint. Where the suite is silent about an area, read that area's controllers and say what you found — silence is not evidence that no endpoint exists. In a repo with no acceptance suite yet, say so explicitly and fall back to the story folders. Open an earlier story's `interview.md` or `decisions/*-decision.md` only for a **named** precedent — the rule behind an existing response shape — resolving it under `stories/` or `stories/done/`, since the story that set the shape has usually closed (`.claude/rules/workflow.md`, "Resolving a story folder")

### Phase 2: Generate Specifications

Load `.claude/templates/spec/api-spec-template.md` for document formats.

Based on story and mockups, identify the **minimum** endpoints needed.

- Create `endpoints.md` in story folder
- Create OpenAPI YAML in `ProductSpecification/api-specs/[resource]_[action].yaml`

### Phase 3: Summary

Report: created files, endpoints generated, design decisions.

## Design Constraints

- **OpenAPI version**: 3.0.3 (YAML format)
- **API versioning**: `/api/v1/` prefix
- **Naming**: snake_case files, kebab-case URLs
- **RESTful**: Follow REST conventions
- **Minimal responses**: Only essential fields
- Check if spec already exists before creating
