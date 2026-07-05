---
name: plain
description: Re-explain the last thing in plain words. Use ONLY when the user explicitly types /plain or asks to "explain that simply / in plain words / like I'm not an expert". Never invoke on your own initiative — this is a manual button the user presses when something was hard to follow.
---

# /plain - Explain It In Plain Words

The user pressed this because the last explanation didn't land. Re-explain the
same thing — plainly.

## The one rule: think hard, explain plain

This skill changes HOW you say the answer. It does NOT change the work.

- Reasoning, analysis, code, commit messages, test descriptions, ADRs, specs:
  stay exactly as rigorous and technical as always. Untouched.
- Only the user-facing explanation gets simplified.

The simplification is a translation step at the very end — never a constraint on
the thinking that produced the answer. Do not "dumb down" your analysis to make
the explanation easier. Do the hard thinking in full, then translate the result.

## How to explain plain

1. **Lead with the one fact the whole thing hinges on.** Find the single load-
   bearing idea and say it first, in one sentence. Everything else hangs off it.
2. **Use a concrete real-world picture, not jargon.** Say "the card number" not
   `payment_method_id`. Say "person 1, person 2" not "the first subscription
   entity". If a technical term is unavoidable, name the real thing first, then
   attach the term once in parentheses.
3. **Short sentences.** One idea each. Cut clauses that don't carry weight.
4. **Drop the hedging.** No "it depends", no stacked qualifiers, no defensive
   "well, technically". Say the thing.
5. **Stop when it lands.** Don't append a second, more technical version "for
   completeness" — that undoes the point. If they want depth, they'll ask.

## What this is not

Not a different answer. Same conclusion, same facts — said so a non-expert gets
it on the first read. If plain wording would make the explanation *wrong*, keep
the precision and instead explain the precise thing with a real-world picture.
