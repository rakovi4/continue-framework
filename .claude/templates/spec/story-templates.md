# Story Spec — Document Templates

## Main Story File: `NN_StoryName.md`

Brief, scannable, and written exclusively in domain language. **Target: ~50 lines max.**

```markdown
# [Story Title]

## Brief Description
[1-2 sentences max]

## Flow
[Numbered steps, max 10 steps]

## Acceptance Criteria
[Bullet points - what must work for story to be complete]

## Validation Rules
| Field | Rule |
|-------|------|
[Essential validations only - keep minimal]

## Screen States
[List distinct user-visible screens/states]

## Core Requirements
[Critical observable behavior and business constraints - brief bullets, no fluff]
```

**Rules for main file:**
- Use the vocabulary of users and the business domain
- Describe what happens, not how the system implements it
- Include observable behavior, business rules, validation, and user-facing constraints
- Exclude architecture, data/storage design, algorithms, technology, protocols,
  endpoint mechanics, deployment, and integration mechanics
- When a technical limitation affects behavior, state only its observable effect as a
  domain rule; put the technical cause in Notes
- No warnings, suggestions, rationale, or technical notes
- No "nice-to-haves" or future enhancements
- No verbose explanations - just facts
- Every requirement must be externally meaningful and testable

## Notes File: `NN_StoryName_Notes.md`

All implementation context and supplementary information goes here. Do not repeat a
domain requirement from the main spec; explain only the implementation constraint,
rationale, or consequence that a delivery team needs in order to realize it.

```markdown
# [Story Title] - Notes & Considerations

## Warnings

### Functional Warnings
[Things that could go wrong, edge cases]

### UI/UX Warnings
[UI/UX pitfalls to avoid]

### Technical Warnings
[Technical risks: security, performance, integration]

---

## Suggestions & Future Enhancements

### Functional Suggestions
[Enhancements, nice-to-haves]

### UI/UX Suggestions
[UI/UX improvements]

### Technical Suggestions
[Technical improvements and optimizations]

---

## Technical Notes

### Implementation Decisions
[Architecture, data/storage design, algorithms, technology, and protocol choices]

### Load Considerations
[Performance concerns based on ExpectedLoad.md:
- Single-user application
- No more than 100 tasks on the board at any time]

### Security Considerations
[Security considerations - OWASP top 10, etc.]

### Infrastructure Notes
[Infrastructure/deployment concerns]

### Integration Notes
[Integration mechanics and external API concerns:
- External API dependencies
- OAuth token lifecycle
- Rate limits and throttling
- If interview.md exists, reference external API documentation]

---

## Additional Context

[If interview.md exists, reference it here:
- See `interview.md` for external API documentation
- External systems integrated (e.g., third-party API)
- OAuth flows, token types, API versions]
```
