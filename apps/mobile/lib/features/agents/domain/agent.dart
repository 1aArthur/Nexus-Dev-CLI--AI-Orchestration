enum AgentType {
  planner,
  researcher,
  developer,
  reviewer,
  security,
  devops,
  orchestrator,
  custom,
}

enum AgentState {
  idle,
  queued,
  running,
  waiting,
  paused,
  completed,
  failed,
  cancelled,
}
