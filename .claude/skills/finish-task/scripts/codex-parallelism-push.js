const intervalMs = 300_000;

for (;;) {
  notify(
    "[FINISH_TASK_PARALLELISM_CHECK] Reassess the task dependency graph, live agents, newly frozen surfaces, available capacity, and whether a newly unblocked disjoint lane would reduce elapsed time."
  );
  yield_control();
  await new Promise((resolve) => setTimeout(resolve, intervalMs));
}
