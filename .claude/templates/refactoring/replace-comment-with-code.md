# Replace Comment with Code

Use this refactoring for every source comment. No comment category may remain.

## Preserve the Information Elsewhere

| Comment content | Replacement |
|-----------------|-------------|
| Restatement of an operation | Rename the operation or delete redundant prose |
| Name for a block of operations | Extract a cohesive method named for the intent |
| Rationale or external constraint | Move it to the owning documentation and make the constraint executable where possible |
| Public contract | Express it through types, tests, or the language's executable contract mechanism |
| Tooling directive | Replace it with tool configuration or ordinary code |
| Safety hazard | Encode the guard in validation, types, tests, or owning operational documentation |
| TODO or disabled code | Implement it within scope or delete it; use tracked work for deferred behavior |

## Refactoring Sequence

1. Identify the information or behavior the comment carries.
2. Rename symbols, extract a cohesive method, or simplify control flow until the
   code expresses its operational intent.
3. Preserve contracts and constraints in types, tests, executable configuration,
   or the owning documentation.
4. Replace comment-based tool directives with configuration or ordinary code.
5. Delete the comment.
6. Re-read and test the result without relying on the deleted prose.

The refactoring is incomplete while any source comment remains in the edited
file.
