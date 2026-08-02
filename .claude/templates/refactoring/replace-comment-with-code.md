# Replace Comment with Code

Use this refactoring when a comment narrates an operation or labels a section
that the code itself can name.

## Classify Before Removing

| Comment preserves | Action |
|-------------------|--------|
| A restatement of the next operation | Improve the operation's name or remove the comment |
| A name for a block of operations | Extract a cohesive method named for the intent |
| Rationale or an external constraint | Keep only the irreducible fact, at most two source lines |
| A public contract | Keep it in the language's contract mechanism |
| A tooling directive | Keep it while the tool requires it |
| A safety hazard | Keep it when deletion would hide risk from maintainers |

Never delete a comment before preserving information that only prose can carry.

## Comment-Bloat Gate

Before retaining a rationale, answer both questions:

1. What present maintainer decision would change if this comment disappeared?
2. Why can names, types, tests, version control, or the owning documentation not
   preserve the information?

If either answer is missing, delete the comment. Implementation history,
migration stories, test anecdotes, and explanations of how the current code came
to exist belong in version control or durable documentation, not production
source. Multi-paragraph comments are always bloated. Compress an irreducible
current rationale to at most two source lines; tooling directives and safety
warnings may exceed that cap only when shortening them would break the tool or
hide the hazard.

## Refactoring Sequence

1. Read the code without the comment and state the missing intent.
2. Prefer renaming an existing symbol when one name can reveal that intent.
3. Extract a cohesive method when the comment labels multiple operations.
4. Simplify control flow when the comment compensates for tangled structure.
5. Apply the comment-bloat gate to any rationale that remains.
6. Delete or compress the comment.
7. Re-read the result without relying on surrounding context. The code should
   still explain what happens; retained comments should explain only why.

## Example

Before:

```text
comment: Resume from the first unfinished stage
stage = stages.find(notFinished)
```

After:

```text
stage = firstUnfinishedStage()
```

The new name carries the operational intent. If an external rule determines
why the first unfinished stage is required, preserve that rule as a rationale
comment beside the named operation.
