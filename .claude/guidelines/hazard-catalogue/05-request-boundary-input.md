# Request boundary & input

> Apply with `_index.md`. Each entry: **Trigger** / **Mitigation** / **Forced guard**.

## Authorization & IDOR

- **Trigger.** An endpoint or operation takes a resource identifier (`.../{id}`) or
  acts on data owned by a principal.
- **Mitigation.** Authorize the *specific resource* against the caller, not just that
  the caller is authenticated; ownership is checked at the operation, never inferred
  from a valid token. Don't disclose existence: a forbidden resource and a missing one
  return the same response.
- **Forced guard.** Principal A requests principal B's resource by id and is denied,
  for every by-id and owner-scoped operation — not only the one the story mentioned.
  The "not found" response is identical (status + body) to the "exists but forbidden"
  response, and auth failures don't distinguish unknown-principal from wrong-credential.

## Mass assignment & over-binding

- **Trigger.** A write endpoint deserializes a request body straight into an entity,
  persistence model, or a DTO carrying more fields than the operation should expose —
  especially when one type is reused for read and write, or for create and update.
- **Mitigation.** Bind only an explicit allow-list of writable fields into a
  purpose-built request DTO; never bind a request onto an entity. Server-owned fields
  (id, owner, role, status, balance, createdAt) are set by the server after binding,
  never read from the body.
- **Forced guard.** Send a body containing a privileged or server-owned field the
  contract doesn't list (`"role":"admin"`, `"ownerId":<other>`, `"balance":999`) and
  assert the persisted result is unchanged for that field — one test per server-owned
  field on each write endpoint, not just the documented ones.

## Absent vs null vs default

- **Trigger.** A request field is optional and behaviour must differ between "key
  omitted", "key sent as null", and "empty / zero value" — most acute on PATCH /
  partial-update, where unspecified fields must survive.
- **Mitigation.** Model absent vs present-null as distinct in-memory states (presence
  flag / tri-state), decided on purpose, not collapsed by the deserializer's
  default-on-missing. On partial update, load the stored record and apply only supplied
  fields — "not supplied" means "keep existing", never "overwrite with default".
- **Forced guard.** Three tests for a tri-state field: omit (assert unchanged /
  default), null (assert cleared), value (assert set) — omit-vs-null is the canonical
  miss. A PATCH that sets two fields then updates one asserts the *other* retains its
  prior value, not its default.

## Output-context encoding & injection

- **Trigger.** A value from input, an external system, or storage is echoed into a
  context that interprets some bytes as structure — HTML, a SQL/NoSQL query, a shell
  command, a log line, a CSV cell (leading `=`/`+`/`-`/`@`), an HTTP header, or a URL.
  A sort/filter parameter mapped to a column/operator name is the same hazard.
- **Mitigation.** Encode/escape at the moment of output, for the specific sink, never
  once at input; prefer structural separation that makes injection impossible —
  parameterized queries, auto-escaping templates, argument arrays not shell strings,
  structured logging treating the value as a field. Sort/filter params resolve through
  a server-side allow-list of columns, never raw client strings.
- **Forced guard.** Per sink, feed a value containing that sink's metacharacters
  (`<script>`, `' OR 1=1`, `=cmd`, a `\r\n`-forged header / log line) and assert the
  emitted artifact is neutralized/escaped — not merely that the happy-path value
  renders. A sort/filter value outside the allow-list is rejected, not interpolated.

## Default-branch & fail-open

- **Trigger.** Code dispatches on an enum / type / role / feature-flag, or a guard
  computes allow/deny, and one input can be unknown, missing, null, errored, or
  timed-out — a new enum value, an unmapped role, a flag whose config is absent, an
  auth/quota check whose backing store is unreachable.
- **Mitigation.** Make exhaustiveness enforced (a compile-time check, or a test that
  goes red on an unhandled value); forbid a catch-all default that silently absorbs the
  unknown. Decide explicitly which direction "can't tell" resolves and make the safe
  direction the default — security / spend / destructive decisions fail closed (deny /
  skip); availability-only decisions may fail open, but the choice is stated, not
  whatever the catch block yields.
- **Forced guard.** Feed an unknown/unmapped discriminant (new enum, unknown role,
  flag-lookup failure) and assert the safe outcome (deny / reject / explicit error),
  not the permissive fallthrough. Drive a guard's input into the error/timeout state
  and assert the intended safe decision ("auth dependency times out → denied").
