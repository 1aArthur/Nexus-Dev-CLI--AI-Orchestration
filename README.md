# Nexus D2 — AI Orchestration

Nexus is an Android and iOS orchestration client built with Flutter/Dart, a bounded Rust native core, a Rust/Axum gateway, PostgreSQL, and an Elixir/OTP mission supervisor.

The default interface uses OLED black, bright white, and neutral grays. Provider credentials and signing material are never bundled in the mobile application.

## Workspace

- `apps/mobile`: shared Flutter application for Android and iOS.
- `crates/nexus_core`: memory-safe native primitives exposed through generated bindings.
- `crates/nexus_gateway`: public Axum API and WebSocket boundary.
- `services/orchestrator`: supervised mission and agent processes.
- `packages`: generated API and extension contracts.
- `infra`: migrations, workers, and development infrastructure.

## Development

Install the versions in `.tool-versions`, copy `.env.example` to a local untracked `.env`, then run:

```bash
make bootstrap
make format-check
make test
```

The complete approved design and implementation plan live under `docs/`.
