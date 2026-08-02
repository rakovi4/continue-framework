# Platform Capability Conventions

Canonical skills describe required capabilities, not one assistant's tool names.
Every platform binding must preserve these semantics and fail explicitly when a
named capability cannot be resolved.

- **Named agent dispatch:** spawn the named agent with the supplied context.
  Await it unless the instruction explicitly says persistent or concurrent.
- **Concurrent fan-out:** start all named independent agents before awaiting any
  result, then gather every result before continuing. Concurrent does not mean
  detached or fire-and-forget.
- **Named skill execution:** load and execute the named canonical skill. A slash
  name in explanatory prose is not itself an execution request.
- **Persistent command:** start a pollable process, retain its session identifier,
  and report progress through bounded polls. Do not block the interaction while
  waiting for a long-lived process.
- **User decision:** use structured input when the platform provides it;
  otherwise ask directly. Pause until the user answers unless the instruction
  explicitly permits a default.
- **Repository operations:** use the shell for commands, `rg` for text and file
  search, `find` when a skill mandates filesystem discovery, and direct file
  reads for known paths.
- **Workflow script:** execute the exact repository script named by the skill,
  validate its arguments, and consume its returned plan or result completely.
