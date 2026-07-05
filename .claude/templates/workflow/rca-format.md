# RCA Write-Up Format

Append an RCA section to the task `spec.md`. The reader must be able to tell evidence from inference without re-running the investigation — so separate what you **MEASURED** (observed directly) from what you **REASONED** (inferred from code plus rules) on every claim.

## Structure

### Symptom (authoritative source)

- **Observable:** the exact failing value or behavior, with units, and the assertion or log line that reports it. Confirm which value the assertion actually checks — it is often not the one a summary reports.
- **Source:** where it came from (CI test report job/URL, log path, test name) — quoted, not paraphrased.
- **Frequency:** for an intermittent failure, the real pass/fail count and the measured values on both sides of the boundary.

### Assumptions audit

Every claim a prior write-up, comment, or conversation treated as known is re-checked here. Reuse no conclusion not re-confirmed.

| Prior claim | Status | Evidence |
|-------------|--------|----------|
| (a claim previously treated as fact) | verified / refuted / unverified | (the data that settles it) |

### Hypotheses

At least two rows. A single-hypothesis table means the investigation stopped too early.

| # | Candidate cause | Evidence gathered | Label | Verdict |
|---|-----------------|-------------------|-------|---------|
| 1 | ... | (test run, log, query plan, code path, measurement) | MEASURED / REASONED | confirmed / refuted / unproven |

### Conclusion

- **Root cause:** the mechanism the evidence supports, traced end to end.
- **Measured:** facts observed directly.
- **Reasoned:** attributions inferred from code plus rules, with why no direct measurement was possible.
- **Residual unknowns:** what remains unmeasured, and the access or environment reason.
- **Fix lever:** the change the cause points to — designed in the next step, not implemented in the RCA.
