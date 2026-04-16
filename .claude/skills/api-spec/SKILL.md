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
   - `ProductSpecification/BriefProductDescription.txt`
   - `ProductSpecification/stories.md`
   - `ProductSpecification/stories/*/mockups/` (UI mockups)
   - `ProductSpecification/stories/*/interview.md` (if exists — authoritative source for API details)

2. Parse user input to find target story (by name, number, or interactive)

3. Read story specification: `ProductSpecification/stories/NN-story-name/NN_StoryName.md`

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
