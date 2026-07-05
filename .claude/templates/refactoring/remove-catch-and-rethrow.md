# Remove Catch-and-Rethrow (and Catch-and-Swallow)

When to use: a try/catch block whose catch body does not change control flow in a meaningful way. Two forms of the same smell:

- **Catch-and-rethrow** — `try { ... } catch (X e) { <side-effect>; throw e; }`. The side effect can be anything — logging, metrics, tracing, audit, print, or nothing at all.
- **Catch-and-swallow on a broad type** — `try { ... } catch (RuntimeException e) { log.warn(...); /* continue */ }`. The body does not rethrow, but the catch is still non-transforming because it converts every exception (real bug, transient error, invariant violation) into a single warn line that downstream consumers ignore. Best-effort iteration (`for each item: try; catch broad; log; continue`) is the canonical example.

Both are forbidden in production code.

## Why it's wrong

A catch block exists to *change control flow*. If it doesn't, it is a wrapper around the throw that adds noise without adding meaning.

- **Wrong layer for the side effect.** Logging, metrics, tracing, and auditing are cross-cutting — they apply to every uncaught exception, not just the one at this site. The right place is the centralized exception handler (for exception-driven cross-cutting) or an interceptor/aspect (for orthogonal cross-cutting). Putting a `metrics.increment(...)` or a `tracer.tag(...)` next to a single throw means every other site that throws the same exception silently lacks that signal.
- **Redundant request context.** userId / request ID / trace ID belong in the logger's diagnostic context (MDC), populated once per request by the auth/request filter. Every log line in the request — including the centralized handler's — automatically inherits it. Passing them through the exception message is duplication.
- **Hides the happy path.** Wrapping a single call in try/catch indents the main logic and adds visual weight that suggests "this is the interesting branch" when the catch is doing nothing structural.

## Catalogue of offenders

All identical smell, all delete the try/catch:

```java
// log-rethrow
try { ... } catch (X e) { log.warn("...", e); throw e; }

// metric-rethrow
try { ... } catch (X e) { failureCounter.increment(); throw e; }

// trace-rethrow
try { ... } catch (X e) { span.tag("error", e.getMessage()); throw e; }

// audit-rethrow
try { ... } catch (X e) { auditLog.record(userId, "X_failed"); throw e; }

// print-rethrow
try { ... } catch (X e) { System.err.println(e); throw e; }

// no-op rethrow (pure noise)
try { ... } catch (X e) { throw e; }
```

## Rewrite

```java
// Before — catch only to log + rethrow
@Transactional
public LinkApiKeyResponse link(LinkApiKeyRequest request) {
    Token token = request.createToken();
    TokenValidationResult validationResult = tokenValidator.validateToken(request.getToken());

    try {
        validationResult.assess(clock.instant());
    } catch (TokenValidationException e) {
        log.warn("token validation failed userId={} errorMessage={}", request.getUserId(), e.getMessage());
        throw e;
    }

    apiKeyStorage.save(apiKey(request.getUserId(), token, validationResult));
    return LinkApiKeyResponse.createResponse(token, validationResult);
}

// After — let it propagate, no side effect, no indentation
@Transactional
public LinkApiKeyResponse link(LinkApiKeyRequest request) {
    Token token = request.createToken();
    TokenValidationResult validationResult = tokenValidator.validateToken(request.getToken());
    validationResult.assess(clock.instant());
    apiKeyStorage.save(apiKey(request.getUserId(), token, validationResult));
    return LinkApiKeyResponse.createResponse(token, validationResult);
}
```

`GlobalExceptionHandler` owns the `log.warn(...)` for `TokenValidationException` (and its subtypes). `userId` is in MDC from the auth filter, so the handler's log line carries it automatically.

## Variant: Catch-and-Swallow on Broad Type

A second form of the same smell: catching a broad exception type (`RuntimeException` / `Exception` / `Throwable`) inside an iteration to log a warn and continue. The catch "changes control flow" — the iteration moves on — but the change is superficial: the exception is silently dropped, real bugs surface as one warn line, and transient errors create log noise the entry-point layer already covers. Three rewrites depending on what the iteration actually needs:

### Rewrite 1: Propagate (preferred for idempotent batch operations)

```java
// Before — broad catch swallows every exception
public void execute() {
    List<Subscription> subscriptions = subscriptionStorage.findDueForRenewal(clock.instant());
    subscriptions.forEach(this::tryRenewSubscription);
    log.info("auto-renewal completed count={}", subscriptions.size());
}

private void tryRenewSubscription(Subscription subscription) {
    try {
        renewSubscription(subscription);
    } catch (RuntimeException e) {
        log.warn("auto-renewal failed subscriptionId={} errorMessage={}",
                subscription.getId(), e.getMessage());
    }
}

// After — let it propagate, no try/catch
public void execute() {
    List<Subscription> subscriptions = subscriptionStorage.findDueForRenewal(clock.instant());
    subscriptions.forEach(this::renewSubscription);
    log.info("auto-renewal completed count={}", subscriptions.size());
}
```

The first failure aborts the batch — and that's correct, because the scheduled-job wrapper (Spring's `TaskScheduler`, Quartz, equivalent) ERROR-logs the uncaught exception with stack trace. Next cycle picks up the unprocessed items. The trade-off: one bad item kills the rest of *this* cycle. Accept that trade-off when (a) the job is idempotent and (b) the operation is fast-failing for transient errors (not the slow-90%-failures-still-block-the-tenth case).

### Rewrite 2: Catch a specific expected exception

```java
// Before — broad catch can't distinguish "expected absence" from "bug"
private Optional<UserGoods> tryFetchGoods(UUID userId) {
    try {
        return Optional.of(goodsClient.fetch(userId));
    } catch (RuntimeException e) {
        log.warn("fetch failed userId={} errorMessage={}", userId, e.getMessage());
        return Optional.empty();
    }
}

// After — catch only the specific expected case
private Optional<UserGoods> tryFetchGoods(UUID userId) {
    try {
        return Optional.of(goodsClient.fetch(userId));
    } catch (GoodsNotPublishedException e) {
        return Optional.empty();
    }
}
```

`GoodsNotPublishedException` is an expected outcome — "this user has no published goods yet." `Optional.empty()` is a meaningful fallback that downstream `flatMap(Optional::stream)` actually uses. Any other exception (network failure, API rate limit, NPE) propagates and reaches the entry-point handler.

### Rewrite 3: Make the source non-throwing

```java
// Before — domain method throws on expected absence
public Subscription renew(Instant now) {
    if (paymentMethod.isExpired(now)) {
        throw new PaymentMethodExpiredException();
    }
    // ...
}

// caller catches it
try {
    subscription.renew(now);
} catch (PaymentMethodExpiredException e) {
    log.warn("expired card subscriptionId={}", subscription.getId());
}

// After — domain returns a result type
public RenewalResult renew(Instant now) {
    if (paymentMethod.isExpired(now)) {
        return RenewalResult.skipped(SkipReason.PAYMENT_EXPIRED);
    }
    // ...
    return RenewalResult.renewed(...);
}

// caller branches on the result, no try/catch
RenewalResult result = subscription.renew(now);
if (result.isSkipped()) {
    // optionally aggregate or log at the end of the batch
}
```

Result type / `Optional` / Null Object pushes the "expected failure" branch into the type system. The caller iterates without try/catch, the domain remains expressive, the warn log moves to wherever the aggregate cares about skipped counts.

### Picking between the three

| Situation | Use |
|-----------|-----|
| Idempotent job, transient errors retry next cycle | **Propagate** (1) |
| Expected business outcome (not-found, already-processed) with a real downstream branch | **Specific catch with meaningful fallback** (2) |
| The "failure" is an expected branch in domain logic, not an exception at all | **Non-throwing source** (3) |

If you cannot place the catch in one of these three, the try/catch should not exist.

## When to keep the catch

Only when the catch *changes control flow*:

| Reason | Example |
|--------|---------|
| Translate to a different exception type | `catch (HttpClientErrorException e) { throw new ApiRateLimitException(); }` |
| Recover with a fallback value | `catch (NotFoundException e) { return Optional.empty(); }` |
| Side-effecting cleanup or compensating action | `catch (PaymentException e) { reservation.release(); throw e; }` |
| Add genuinely new context the handler cannot derive | A retry counter computed at the call site, a correlation token unique to this attempt |

The last case is rare. Before claiming it, check whether MDC (populated by a filter or interceptor) can supply the context, or whether the centralized handler can derive it — if yes, prefer those layers.

## Where each side effect actually belongs

| Side effect at the catch site | Correct home |
|-------------------------------|--------------|
| `log.warn/error(...)` of the exception | Centralized exception handler (`GlobalExceptionHandler`) |
| `userId`, `requestId`, `traceId` in the log line | Logger diagnostic context (MDC), populated once per request by the auth/request filter |
| `metrics.increment("failures")` | Metrics interceptor / aspect filtering on exception type |
| `span.tag("error", ...)`, `span.recordException(...)` | Tracing instrumentation (Spring Cloud Sleuth, OpenTelemetry interceptor, or the centralized handler) |
| `auditLog.record(...)` | Audit aspect filtering on exception type, or the centralized handler |
| `System.out/err.println(...)` | Never — replace with the logger, then move to the handler |

## Steps

1. Locate the catch block.
2. Classify the body: is it a transformation (different exception thrown, fallback returned, cleanup performed) or a non-transforming side effect (log / metric / trace / audit / print / nothing)?
3. If non-transforming: identify the correct home for the side effect (centralized handler, interceptor, aspect, MDC) from the table above.
4. Verify the correct home is already wired (or will be wired in the same change). If not, wire it first — otherwise the signal is lost.
5. Delete the try/catch, leaving the inner statement at the original indentation level.
6. Run tests for the module.
