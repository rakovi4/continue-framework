# Story Spec — Document Templates

## Main Story File: `NN_StoryName.md`

Brief, scannable, implementation-focused. **Target: ~50 lines max.**

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
[List of distinct screens/states needed for implementation]

## Core Requirements
[Critical implementation requirements - brief bullets, no fluff]
```

**Rules for main file:**
- No warnings, suggestions, or technical notes
- No "nice-to-haves" or future enhancements
- No verbose explanations - just facts
- Every line must be actionable for implementation

## Notes File: `NN_StoryName_Notes.md`

All supplementary information goes here:

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

### Load Considerations
[Performance concerns based on ExpectedLoad.txt:
- Single-user application
- No more than 100 tasks on the board at any time]

### Security Considerations
[Security considerations - OWASP top 10, etc.]

### Infrastructure Notes
[Infrastructure/deployment concerns]

### Integration Notes
[Integration and external API concerns:
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
