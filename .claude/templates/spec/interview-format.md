# Interview Format & Rounds

## Interview Rounds

Conduct the interview in **rounds**. Each round asks 1-3 focused questions using `AskUserQuestion`. Adapt questions based on previous answers and story context.

**Present context you found** before asking questions — show what you already know so the user can correct or confirm rather than repeat themselves.

### Round 1: Scope & Boundaries

Summarize what you understand about the story from context gathering, then ask:

1. **Scope**: "What test cases / scenarios does this story cover? What is explicitly OUT of scope?"
2. **Dependencies**: "Which other stories does this one depend on or affect?"

### Round 2: External Integrations

Based on the story's nature, ask about relevant integrations:

3. **External APIs**: "Does this story integrate with external APIs? If yes, provide documentation links and key endpoints."
4. **External services**: "Any payment providers, email services, scraping tools, or other external systems involved?"

Skip this round entirely for stories with no external integrations (e.g., pure UI stories).

### Round 3: Architectural Decisions

Ask about key design choices the user has already made or wants to make:

5. **Key decisions**: "What architectural or design decisions have you already made for this story? (e.g., data model choices, algorithm approach, scheduling strategy)"
6. **Business rules**: "What are the business rules and constraints? (limits, validation rules, error handling strategy, edge cases)"

### Round 4: Size & Complexity

Based on what's already implemented vs. what's needed:

7. **Already built**: Present what you found in the codebase and ask: "Is this accurate? Anything else already implemented that I missed?"
8. **Known gaps**: Present the gaps you identified and ask: "Any additional gaps or things you know will be needed?"

### Round 5: Special Considerations (Conditional)

Only ask if relevant based on the story:

9. **Legal/compliance**: For payment, data, or user-facing stories — "Any legal or compliance requirements?"
10. **Testing considerations**: For stories with complex integrations — "Any special testing considerations? (test modes, mock services, test data)"
11. **Performance**: For stories with scheduling, bulk operations, or high load — "Any performance constraints or rate limit concerns?"

### Adaptive Questions

After each round, if the user's answers reveal topics not covered by the standard rounds, ask follow-up questions. For example:
- If user mentions a specific API → ask about authentication, rate limits, error handling
- If user mentions scheduling → ask about interval, concurrency, failure recovery
- If user mentions size/variant handling → ask about edge cases, UI treatment

## Output Format

**Format rules:**
- Use `##` headers for major sections
- Use `###` for subsections
- Include external links as numbered lists (same style as existing interview.md files)
- Keep the conversational, handwritten tone — this is NOT a formal spec
- Use `DECISION:` prefix for architectural decisions
- Use `ACTION:` prefix for things that need to happen
- Mark items as `ALREADY IMPLEMENTED` or `NOT YET IMPLEMENTED` clearly
- Mark out-of-scope items clearly with explanation

**Section order** (include only sections with content):
1. Scope
2. External API/Service Documentation (links)
3. API Endpoints Used (with implementation status)
4. Token/Auth Requirements (if applicable)
5. Key Architectural Decisions
6. Business Rules & Constraints
7. Already Implemented (REUSE)
8. NOT Yet Implemented (Gaps)
9. Cross-Story Dependencies
10. Legal/Compliance (if applicable)
11. Testing Considerations (if applicable)
12. Performance/Rate Limits (if applicable)

**Save to:** `ProductSpecification/stories/NN-story-name/interview.md`

Create the story directory if it doesn't exist.
