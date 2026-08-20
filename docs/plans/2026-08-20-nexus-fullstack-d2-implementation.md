# Nexus Full-Stack D2 Implementation Plan

> **For agentic workers:** Use the host's available task-by-task implementation workflow. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild Nexus as a production-oriented Flutter application for Android and iOS with a Rust native core and gateway, PostgreSQL persistence, Elixir/OTP many-agent orchestration, secure remote execution, multi-provider AI, Grok realtime voice, extensions, themes, pets, knowledge, and usage controls.

**Architecture:** Flutter owns cross-platform presentation and offline read models; a generated `flutter_rust_bridge` boundary exposes only bounded native primitives. Axum is the sole public backend and coordinates PostgreSQL, isolated terminal workers, AI adapters, GitHub, and xAI ephemeral sessions, while an Elixir/OTP service supervises durable mission DAGs and agents.

**Tech Stack:** Flutter/Dart, Riverpod, go_router, Drift/SQLite, Dio, WebSocket, flutter_secure_storage, media_kit, Rust, flutter_rust_bridge, Axum, Tokio, SQLx, PostgreSQL, pgvector, Wasmtime, Elixir/OTP, Phoenix PubSub, OpenAPI, Docker/Compose, GitHub Actions, CodeQL, Semgrep, Trivy, Gitleaks, CycloneDX.

## Global Constraints

- Android and iOS share one Flutter/Dart feature codebase; no Kotlin or Swift feature implementation is introduced.
- The default visual system uses OLED black, bright white, and neutral grays. Status never depends on color alone.
- Local device execution is a fixed allowlist of safe Rust functions; arbitrary shell runs only in isolated or explicitly authorized remote targets.
- Axum is the only public backend. Provider keys, refresh tokens, SSH credentials, signing material, and `XAI_API_KEY` never enter source control or mobile assets.
- xAI voice uses a server-issued short-lived client secret. Microphone audio and transcripts remain memory-only unless explicitly saved.
- All state-changing HTTP requests require idempotency keys; events have durable monotonically increasing mission sequences.
- Many-agent execution obeys dependency, concurrency, cost, time, provider, permission, and approval ceilings.
- Universal reasoning profiles resolve through a pinned exact-model capability record and never send unsupported parameters.
- Usage distinguishes estimates from provider-reported amounts and applies transactionally reserved hard budgets.
- Skills are declarative, Plugins execute only as bounded server-side Wasm, knowledge retrieval filters ACLs before ranking, and imported archives are treated as untrusted.
- Custom theme videos are muted, normalized MP4/H.264, at most 30 seconds, and fall back to a poster frame for reduced motion or battery saving.
- Proprietary OpenAI, Anthropic, or third-party pet artwork is not bundled without an explicit redistributable license.
- Production release workflows fail closed when signing credentials are absent; debug signing is never a release fallback.
- The existing target `LICENSE` remains Apache-2.0. The approved design is `docs/specs/2026-08-20-nexus-fullstack-d2-design.md`.

---

### Task 1: Bootstrap the reproducible monorepo

**Files:**
- Create: `melos.yaml`
- Create: `Makefile`
- Create: `.tool-versions`
- Create: `.env.example`
- Create: `.gitignore`
- Create: `docker-compose.yml`
- Create: `apps/mobile/pubspec.yaml`
- Create: `apps/mobile/analysis_options.yaml`
- Create: `apps/mobile/lib/main.dart`
- Create: `apps/mobile/lib/app/nexus_app.dart`
- Create: `apps/mobile/test/bootstrap_test.dart`
- Create: `Cargo.toml`
- Create: `Cargo.lock`
- Create: `crates/nexus_core/Cargo.toml`
- Create: `crates/nexus_core/src/lib.rs`
- Create: `crates/nexus_gateway/Cargo.toml`
- Create: `crates/nexus_gateway/src/main.rs`
- Create: `services/orchestrator/mix.exs`
- Create: `services/orchestrator/.formatter.exs`
- Create: `services/orchestrator/lib/nexus_orchestrator.ex`
- Create: `services/orchestrator/test/nexus_orchestrator_test.exs`
- Create: `.github/workflows/bootstrap.yml`
- Modify: `README.md`

**Interfaces:**
- Consumes: approved architecture and existing Apache-2.0 repository.
- Produces: `make bootstrap`, `make format-check`, `make test`, and workspace roots used by every later task.

- [ ] **Step 1: Add the focused failing test**

Create `bootstrap_test.dart` asserting `NexusApp` renders a `MaterialApp.router`, and add a shell check that required workspace manifests exist and no tracked file matches secret patterns.

- [ ] **Step 2: Verify the relevant failure**

Run: `cd apps/mobile && flutter test test/bootstrap_test.dart` locally, or the pinned `bootstrap.yml` GitHub Actions job when local Flutter is unavailable.
Expected: compilation fails because `NexusApp` and the application package do not exist.

- [ ] **Step 3: Implement the minimum behavior**

Generate Flutter Android/iOS runners under `apps/mobile`, declare pinned direct dependencies, create empty Rust and Elixir workspace members, add local PostgreSQL/pgvector and service definitions, and document one command per build stage. `.env.example` contains names and safe descriptions only.

- [ ] **Step 4: Verify the focused pass**

Run: `cd apps/mobile && flutter test test/bootstrap_test.dart`
Expected: one bootstrap widget test passes.

- [ ] **Step 5: Run the affected integration check**

Run: `make format-check && make test`
Expected: all available empty-workspace format and test checks pass without credentials.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add .gitignore .env.example .tool-versions Makefile README.md Cargo.toml Cargo.lock docker-compose.yml melos.yaml apps/mobile crates/nexus_core crates/nexus_gateway services/orchestrator .github/workflows/bootstrap.yml
git commit -m "build: bootstrap nexus full-stack workspace"
```

### Task 2: Define shared API, event, and capability contracts

**Files:**
- Create: `packages/api_schema/openapi.yaml`
- Create: `packages/api_schema/events.schema.json`
- Create: `packages/api_schema/model-capabilities.schema.json`
- Create: `packages/api_schema/execution-targets.schema.json`
- Create: `packages/api_schema/generate.sh`
- Create: `apps/mobile/lib/core/api/generated/README.md`
- Create: `crates/nexus_gateway/tests/schema_contract.rs`
- Create: `apps/mobile/test/core/api/schema_contract_test.dart`

**Interfaces:**
- Consumes: REST and WebSocket resources in the approved specification.
- Produces: `MissionDto`, `MissionEventDto`, `ExecutionTargetDto`, `UsageRecordDto`, `ModelCapabilityDto`, `ApiErrorDto`, and generated Dart/Rust serializers.

- [ ] **Step 1: Add the focused failing test**

Assert schemas require UUID identifiers, opaque pagination cursors, `traceId`, idempotency on mutations, per-mission event sequence, execution capabilities, usage provenance, and exact-model reasoning mappings.

- [ ] **Step 2: Verify the relevant failure**

Run: `make schema-test`
Expected: schema validation fails because the contract files are absent.

- [ ] **Step 3: Implement the minimum behavior**

Define OpenAPI 3.1 resources and JSON Schema 2020-12 events with discriminated unions. Generate immutable Dart models and Rust types; reject unknown mutation fields while preserving provider-native metadata only inside explicit extension maps.

- [ ] **Step 4: Verify the focused pass**

Run: `make schema-test`
Expected: schemas validate and Dart/Rust fixtures deserialize to equivalent values.

- [ ] **Step 5: Run the affected integration check**

Run: `make schema-generate && git diff --exit-code packages/api_schema apps/mobile/lib/core/api/generated crates/nexus_gateway/src/generated`
Expected: generation is deterministic with no drift.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add packages/api_schema apps/mobile/lib/core/api apps/mobile/test/core/api crates/nexus_gateway
git commit -m "feat: define shared nexus contracts"
```

### Task 3: Port Kotlin domain models and offline read storage to Dart

**Files:**
- Create: `apps/mobile/lib/features/missions/domain/mission.dart`
- Create: `apps/mobile/lib/features/agents/domain/agent.dart`
- Create: `apps/mobile/lib/features/security/domain/security_finding.dart`
- Create: `apps/mobile/lib/features/execution/domain/execution_target.dart`
- Create: `apps/mobile/lib/features/usage/domain/usage.dart`
- Create: `apps/mobile/lib/core/storage/nexus_database.dart`
- Create: `apps/mobile/lib/core/storage/tables.dart`
- Create: `apps/mobile/test/features/domain/domain_models_test.dart`
- Create: `apps/mobile/test/core/storage/nexus_database_test.dart`

**Interfaces:**
- Consumes: generated DTOs from Task 2 and Kotlin concepts `AgentType`, `AgentState`, mission phases, security findings, SBOM, telemetry, terminal shells, tasks, workflows, audits, Skills, debates, and tools.
- Produces: immutable Dart domain records, DTO mappers, Drift tables, cached read repositories, and unsent-draft storage.

- [ ] **Step 1: Add the focused failing test**

Cover all enum values, terminal-state protection, DTO round trips, increasing event sequences, cache freshness, draft persistence, and preservation of both versions during offline conflicts.

- [ ] **Step 2: Verify the relevant failure**

Run: `cd apps/mobile && flutter test test/features/domain test/core/storage`
Expected: imports fail because the Dart domain and database files are absent.

- [ ] **Step 3: Implement the minimum behavior**

Port observable Kotlin data semantics without Android types. Store only read models and drafts locally; exclude provider credentials, raw microphone buffers, SSH credentials, signing material, and private audit payloads.

- [ ] **Step 4: Verify the focused pass**

Run: `cd apps/mobile && flutter test test/features/domain test/core/storage`
Expected: enum, mapping, lifecycle, and in-memory Drift tests pass.

- [ ] **Step 5: Run the affected integration check**

Run: `cd apps/mobile && dart run build_runner build --delete-conflicting-outputs && git diff --exit-code lib/core/storage`
Expected: Drift generation is deterministic.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add apps/mobile/lib/features apps/mobile/lib/core/storage apps/mobile/test/features apps/mobile/test/core/storage
git commit -m "feat: port nexus domain and offline storage"
```

### Task 4: Build the OLED adaptive shell and navigation

**Files:**
- Create: `apps/mobile/lib/app/nexus_app.dart`
- Create: `apps/mobile/lib/app/router.dart`
- Create: `apps/mobile/lib/design/tokens.dart`
- Create: `apps/mobile/lib/design/nexus_theme.dart`
- Create: `apps/mobile/lib/design/components/nexus_scaffold.dart`
- Create: `apps/mobile/lib/design/components/status_badge.dart`
- Create: `apps/mobile/lib/features/dashboard/presentation/dashboard_screen.dart`
- Create: `apps/mobile/test/app/navigation_test.dart`
- Create: `apps/mobile/test/design/oled_accessibility_test.dart`

**Interfaces:**
- Consumes: domain records from Task 3.
- Produces: routes for Dashboard, Agents, Voice, Terminal, More, Workflows, Research, Security, Tools, Skills, CI/CD, Settings, Extensions, Knowledge, Instructions, Pets, Themes, and Credits.

- [ ] **Step 1: Add the focused failing test**

Assert phone bottom navigation, tablet rail navigation, route restoration, 48 logical-pixel targets, semantic labels, black/white/gray-only default tokens, non-color status semantics, and large-text layout.

- [ ] **Step 2: Verify the relevant failure**

Run: `cd apps/mobile && flutter test test/app/navigation_test.dart test/design/oled_accessibility_test.dart`
Expected: missing router, scaffold, and token imports.

- [ ] **Step 3: Implement the minimum behavior**

Use `go_router` with stateful branches and responsive breakpoints. Implement the Command Deck dashboard using real repository state interfaces and explicit loading, empty, stale, and error surfaces; do not port cosmic gradients, stars, or neon colors.

- [ ] **Step 4: Verify the focused pass**

Run: `cd apps/mobile && flutter test test/app/navigation_test.dart test/design/oled_accessibility_test.dart`
Expected: navigation and accessibility assertions pass at phone and tablet sizes.

- [ ] **Step 5: Run the affected integration check**

Run: `cd apps/mobile && flutter test --update-goldens test/goldens && flutter test test/goldens`
Expected: approved phone/tablet OLED goldens are stable.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add apps/mobile/lib/app apps/mobile/lib/design apps/mobile/lib/features/dashboard apps/mobile/test/app apps/mobile/test/design apps/mobile/test/goldens
git commit -m "feat: add adaptive oled application shell"
```

### Task 5: Implement mission composition, Agent Matrix, and feature-area screens

**Files:**
- Create: `apps/mobile/lib/features/missions/application/mission_controller.dart`
- Create: `apps/mobile/lib/features/missions/presentation/mission_composer_screen.dart`
- Create: `apps/mobile/lib/features/agents/presentation/agent_matrix_screen.dart`
- Create: `apps/mobile/lib/features/workflows/presentation/workflows_screen.dart`
- Create: `apps/mobile/lib/features/research/presentation/research_screen.dart`
- Create: `apps/mobile/lib/features/security/presentation/security_center_screen.dart`
- Create: `apps/mobile/lib/features/security/presentation/security_audit_screen.dart`
- Create: `apps/mobile/lib/features/cicd/presentation/cicd_center_screen.dart`
- Create: `apps/mobile/lib/features/tools/presentation/tools_screen.dart`
- Create: `apps/mobile/test/features/missions/mission_controller_test.dart`
- Create: `apps/mobile/test/features/agents/agent_matrix_test.dart`

**Interfaces:**
- Consumes: `MissionDto`, `MissionEventDto`, `ModelCapabilityDto`, `UsageRecordDto`, and authenticated API client.
- Produces: `MissionDraft`, `OrchestrationProfile`, `MissionController.submit/cancel/resume`, sequenced event reducer, and all mapped Kotlin feature destinations.

- [ ] **Step 1: Add the focused failing test**

Assert draft validation, reasoning availability after model changes, cost preview, idempotent submit, event-gap recovery, terminal-state protection, per-agent provenance, cancellation, and explicit approval gates.

- [ ] **Step 2: Verify the relevant failure**

Run: `cd apps/mobile && flutter test test/features/missions test/features/agents`
Expected: controller and Agent Matrix imports fail.

- [ ] **Step 3: Implement the minimum behavior**

Create Riverpod controllers and screen components. The composer exposes agent count, concurrency, budget, deadline, provider/model, reasoning profile, approval policy, and execution target. Agent Matrix renders the DAG, queue, locks, retries, usage, latency, grants, artifacts, citations, dissent, and cancel controls.

- [ ] **Step 4: Verify the focused pass**

Run: `cd apps/mobile && flutter test test/features/missions test/features/agents`
Expected: reducer, composer, and Agent Matrix tests pass with deterministic fakes.

- [ ] **Step 5: Run the affected integration check**

Run: `cd apps/mobile && flutter test test/features`
Expected: every mapped feature destination renders loading, empty, data, and error states.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add apps/mobile/lib/features apps/mobile/test/features
git commit -m "feat: add missions agents and feature centers"
```

### Task 6: Implement capability-aware terminal and GitHub execution targets

**Files:**
- Create: `apps/mobile/lib/features/execution/application/execution_controller.dart`
- Create: `apps/mobile/lib/features/execution/presentation/terminal_screen.dart`
- Create: `apps/mobile/lib/features/execution/presentation/execution_target_picker.dart`
- Create: `apps/mobile/lib/features/execution/data/execution_socket.dart`
- Create: `apps/mobile/test/features/execution/execution_capabilities_test.dart`
- Create: `apps/mobile/test/features/execution/execution_resume_test.dart`

**Interfaces:**
- Consumes: `ExecutionTargetDto.capabilities`, execution REST resources, and sequenced `/v1/ws/executions/{id}` frames.
- Produces: target selection and execution UI for `local_core`, `nexus_sandbox`, `github_actions`, `github_codespaces`, and `remote_ssh`.

- [ ] **Step 1: Add the focused failing test**

Assert local mode has no arbitrary input, GitHub Actions has no interactive prompt, Zsh/Fish/NuShell appear only for compatible targets, paid resources show cost/permission confirmation, SSH host-key changes block connection, and reconnect resumes from last acknowledged sequence.

- [ ] **Step 2: Verify the relevant failure**

Run: `cd apps/mobile && flutter test test/features/execution`
Expected: execution controller and terminal widgets are missing.

- [ ] **Step 3: Implement the minimum behavior**

Render controls solely from advertised capabilities. Use typed text/binary frames, bounded scrollback, secret redaction before diagnostic export, explicit target/actor/repository scope, and batch run logs/artifacts for Actions.

- [ ] **Step 4: Verify the focused pass**

Run: `cd apps/mobile && flutter test test/features/execution`
Expected: all target capability and resume tests pass.

- [ ] **Step 5: Run the affected integration check**

Run: `cd apps/mobile && flutter test test/integration/execution_fake_server_test.dart`
Expected: fake WebSocket disconnect, replay, completion, and cancellation flows pass.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add apps/mobile/lib/features/execution apps/mobile/test/features/execution apps/mobile/test/integration
git commit -m "feat: add capability aware execution console"
```

### Task 7: Implement secure Grok realtime voice

**Files:**
- Create: `apps/mobile/lib/features/voice/application/voice_controller.dart`
- Create: `apps/mobile/lib/features/voice/data/xai_realtime_socket.dart`
- Create: `apps/mobile/lib/features/voice/domain/voice_state.dart`
- Create: `apps/mobile/lib/features/voice/presentation/voice_screen.dart`
- Create: `apps/mobile/test/features/voice/transcript_reducer_test.dart`
- Create: `apps/mobile/test/features/voice/voice_privacy_test.dart`

**Interfaces:**
- Consumes: `POST /v1/realtime/client-secret`, ephemeral realtime URL/secret/expiry, microphone PCM stream, and xAI typed events.
- Produces: `VoiceController.start/pause/discard/save/createMissionDraft`, cumulative input transcript, incremental output transcript, waveform, and bounded reconnection.

- [ ] **Step 1: Add the focused failing test**

Assert cumulative input transcription replaces the partial text, output deltas append once by sequence, unknown events log type only, expired secrets trigger a new authenticated request, discard clears buffers, and no persistence occurs without save.

- [ ] **Step 2: Verify the relevant failure**

Run: `cd apps/mobile && flutter test test/features/voice`
Expected: voice state and controller imports fail.

- [ ] **Step 3: Implement the minimum behavior**

Dart owns permission, microphone, WebSocket lifecycle, playback, and UI. Send supported realtime session events only after the socket is authenticated with the ephemeral secret. Never accept or persist a permanent xAI key in mobile settings.

- [ ] **Step 4: Verify the focused pass**

Run: `cd apps/mobile && flutter test test/features/voice`
Expected: transcript, privacy, expiration, and reconnection tests pass.

- [ ] **Step 5: Run the affected integration check**

Run: `cd apps/mobile && flutter test test/integration/xai_realtime_fake_test.dart`
Expected: fake realtime input, transcript, audio, disconnect, resume, discard, and mission-draft flows pass.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add apps/mobile/lib/features/voice apps/mobile/test/features/voice apps/mobile/test/integration/xai_realtime_fake_test.dart
git commit -m "feat: add secure grok realtime voice"
```

### Task 8: Implement Themes, Pet Packs, Skills, Plugins, Knowledge, and Instructions UI

**Files:**
- Create: `apps/mobile/lib/features/themes/application/theme_controller.dart`
- Create: `apps/mobile/lib/features/themes/presentation/theme_editor_screen.dart`
- Create: `apps/mobile/lib/features/pets/presentation/pets_screen.dart`
- Create: `apps/mobile/lib/features/extensions/presentation/extensions_screen.dart`
- Create: `apps/mobile/lib/features/knowledge/presentation/knowledge_screen.dart`
- Create: `apps/mobile/lib/features/instructions/presentation/instructions_screen.dart`
- Create: `packages/theme_pack_schema/theme-pack.schema.json`
- Create: `packages/pet_pack_schema/pet-pack.schema.json`
- Create: `packages/skill_schema/skill.schema.json`
- Create: `apps/mobile/test/features/themes/theme_policy_test.dart`
- Create: `apps/mobile/test/features/extensions/package_ui_test.dart`

**Interfaces:**
- Consumes: validated server package metadata, local file picker results, device reduced-motion/battery state, and activation APIs.
- Produces: safe theme import/activation, declarative package inspection, explicit permissions, and disabled licensed-provider pet entries when no authorized source exists.

- [ ] **Step 1: Add the focused failing test**

Assert image and MP4 selection, 30-second rejection, reduced-motion poster fallback, app-background pause, contrast scrim, atomic rollback, package signature/license/permission presentation, and no executable mobile plugin path.

- [ ] **Step 2: Verify the relevant failure**

Run: `cd apps/mobile && flutter test test/features/themes test/features/extensions`
Expected: feature controllers, screens, and schemas are absent.

- [ ] **Step 3: Implement the minimum behavior**

Build editor controls for crop, focal point, blur, dimming, loop, and parallax. Keep theme assets local unless sync is explicitly enabled. Render Pet, Skill, Plugin, NKB, instruction, and Open Design provenance from schema-validated metadata only.

- [ ] **Step 4: Verify the focused pass**

Run: `cd apps/mobile && flutter test test/features/themes test/features/extensions`
Expected: theme policy and declarative extension UI tests pass.

- [ ] **Step 5: Run the affected integration check**

Run: `make package-schema-test && cd apps/mobile && flutter test test/integration/package_catalog_fake_test.dart`
Expected: invalid archives are rejected and prior active versions remain selected.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add apps/mobile/lib/features/themes apps/mobile/lib/features/pets apps/mobile/lib/features/extensions apps/mobile/lib/features/knowledge apps/mobile/lib/features/instructions apps/mobile/test/features packages/theme_pack_schema packages/pet_pack_schema packages/skill_schema
git commit -m "feat: add themes pets and extension surfaces"
```

### Task 9: Implement provider settings, reasoning selection, and Credits center

**Files:**
- Create: `apps/mobile/lib/features/providers/application/provider_controller.dart`
- Create: `apps/mobile/lib/features/providers/domain/reasoning_profile.dart`
- Create: `apps/mobile/lib/features/providers/presentation/providers_screen.dart`
- Create: `apps/mobile/lib/features/usage/application/usage_controller.dart`
- Create: `apps/mobile/lib/features/usage/presentation/credits_screen.dart`
- Create: `apps/mobile/lib/features/settings/presentation/settings_screen.dart`
- Create: `apps/mobile/test/features/providers/reasoning_resolution_test.dart`
- Create: `apps/mobile/test/features/usage/credits_screen_test.dart`

**Interfaces:**
- Consumes: provider/model discovery, `ModelCapabilityDto`, usage summaries, price catalogs, budgets, and exports.
- Produces: OpenAI/Anthropic/native/compatible provider configuration; `Auto|Fast|Balanced|Deep|Maximum`; and credits filters by provider, model, project, mission, agent, and target.

- [ ] **Step 1: Add the focused failing test**

Assert unsupported reasoning levels are disabled, the exact native mapping is previewed, expensive modes warn, estimates and reported charges have distinct labels, historical catalog versions remain stable, hard budget remaining is visible, and CSV/JSON exports preserve provenance.

- [ ] **Step 2: Verify the relevant failure**

Run: `cd apps/mobile && flutter test test/features/providers test/features/usage`
Expected: controllers and screens are missing.

- [ ] **Step 3: Implement the minimum behavior**

Credentials are sent once over authenticated TLS and never returned. Compatible endpoints require HTTPS and explain SSRF policy. Credits show tokens, cache, reasoning, audio/media/tool units, latency, failure, currency, source, effective date, estimate/report status, budgets, and alerts.

- [ ] **Step 4: Verify the focused pass**

Run: `cd apps/mobile && flutter test test/features/providers test/features/usage`
Expected: mapping, labeling, filtering, budget, and export tests pass.

- [ ] **Step 5: Run the affected integration check**

Run: `cd apps/mobile && flutter test test/integration/provider_settings_fake_test.dart test/integration/usage_fake_test.dart`
Expected: credential write-only behavior and paginated usage reconciliation render correctly.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add apps/mobile/lib/features/providers apps/mobile/lib/features/usage apps/mobile/lib/features/settings apps/mobile/test/features apps/mobile/test/integration
git commit -m "feat: add model controls and credits center"
```

### Task 10: Build and bind the embedded Rust core

**Files:**
- Create: `crates/nexus_core/Cargo.toml`
- Create: `crates/nexus_core/src/lib.rs`
- Create: `crates/nexus_core/src/audio.rs`
- Create: `crates/nexus_core/src/hash.rs`
- Create: `crates/nexus_core/src/redaction.rs`
- Create: `crates/nexus_core/src/parsing.rs`
- Create: `crates/nexus_core/src/diff.rs`
- Create: `crates/nexus_core/tests/core_properties.rs`
- Create: `crates/nexus_core/fuzz/fuzz_targets/parsers.rs`
- Create: `apps/mobile/lib/core/native/nexus_core.dart`
- Create: `flutter_rust_bridge.yaml`

**Interfaces:**
- Consumes: PCM bytes, log text, artifact bytes, safe parser input, and diff text.
- Produces: `validatePcm`, `downsampleWaveform`, `sha256`, `redactDiagnostics`, `parseSafeDocument`, and `summarizeDiff` generated Dart calls with typed errors.

- [ ] **Step 1: Add the focused failing test**

Property tests cover malformed PCM, bounded waveform output, SHA-256 vectors, common authorization/secret redaction, parser size/depth ceilings, invalid UTF-8, and deterministic diff summaries.

- [ ] **Step 2: Verify the relevant failure**

Run: `cargo test -p nexus_core`
Expected: package or functions are missing.

- [ ] **Step 3: Implement the minimum behavior**

Use memory-safe Rust and explicit maximums. Expose only the six bounded functions through `flutter_rust_bridge`; do not expose process spawning, filesystem traversal, sockets, credentials, or provider APIs.

- [ ] **Step 4: Verify the focused pass**

Run: `cargo test -p nexus_core`
Expected: unit and property tests pass.

- [ ] **Step 5: Run the affected integration check**

Run: `make bridge-generate && cd apps/mobile && flutter test test/core/native`
Expected: bindings show no drift and Dart-to-Rust fixtures pass on supported host platforms.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add Cargo.toml crates/nexus_core apps/mobile/lib/core/native apps/mobile/test/core/native flutter_rust_bridge.yaml
git commit -m "feat: add bounded rust native core"
```

### Task 11: Implement Axum foundation, PostgreSQL schema, OIDC, and audit

**Files:**
- Create: `crates/nexus_gateway/Cargo.toml`
- Create: `crates/nexus_gateway/src/main.rs`
- Create: `crates/nexus_gateway/src/config.rs`
- Create: `crates/nexus_gateway/src/auth.rs`
- Create: `crates/nexus_gateway/src/http.rs`
- Create: `crates/nexus_gateway/src/ws.rs`
- Create: `crates/nexus_gateway/src/idempotency.rs`
- Create: `crates/nexus_gateway/src/audit.rs`
- Create: `infra/migrations/0001_core.sql`
- Create: `infra/migrations/0002_usage_and_capabilities.sql`
- Create: `crates/nexus_gateway/tests/auth_and_idempotency.rs`
- Create: `crates/nexus_gateway/tests/ws_resume.rs`

**Interfaces:**
- Consumes: OIDC discovery/JWKS, PostgreSQL, HTTP/WebSocket requests, and shared schemas.
- Produces: liveness/readiness, authenticated RBAC context, idempotent mutations, durable outbox/events, audit records, opaque pagination, trace IDs, and resumable event streams.

- [ ] **Step 1: Add the focused failing test**

Test issuer/audience/signature/expiry/algorithm rejection, viewer/operator/admin policy, duplicate idempotency keys, concurrent identical writes, event replay, request/frame limits, redaction, and graceful shutdown.

- [ ] **Step 2: Verify the relevant failure**

Run: `cargo test -p nexus_gateway --test auth_and_idempotency --test ws_resume`
Expected: gateway routes and migrations are absent.

- [ ] **Step 3: Implement the minimum behavior**

Create typed configuration validated at startup, least-privilege SQLx queries, transactionally paired state/outbox/audit writes, bounded middleware, standard error envelopes, and WebSocket resume from the last acknowledged sequence.

- [ ] **Step 4: Verify the focused pass**

Run: `cargo test -p nexus_gateway --test auth_and_idempotency --test ws_resume`
Expected: all auth, idempotency, persistence, and resume cases pass against ephemeral PostgreSQL.

- [ ] **Step 5: Run the affected integration check**

Run: `make migration-test && cargo test -p nexus_gateway`
Expected: migrations apply/revert in test order and the gateway suite passes.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add crates/nexus_gateway infra/migrations
git commit -m "feat: add secure axum gateway foundation"
```

### Task 12: Implement AI adapters, xAI ephemeral sessions, usage, and budgets

**Files:**
- Create: `crates/nexus_gateway/src/providers/mod.rs`
- Create: `crates/nexus_gateway/src/providers/openai.rs`
- Create: `crates/nexus_gateway/src/providers/anthropic.rs`
- Create: `crates/nexus_gateway/src/providers/gemini.rs`
- Create: `crates/nexus_gateway/src/providers/xai.rs`
- Create: `crates/nexus_gateway/src/providers/compatible.rs`
- Create: `crates/nexus_gateway/src/providers/exa.rs`
- Create: `crates/nexus_gateway/src/usage.rs`
- Create: `crates/nexus_gateway/src/budgets.rs`
- Create: `crates/nexus_gateway/src/realtime.rs`
- Create: `packages/model_capabilities/catalog.json`
- Create: `crates/nexus_gateway/tests/provider_contract.rs`
- Create: `crates/nexus_gateway/tests/usage_budget.rs`

**Interfaces:**
- Consumes: protocol-neutral `AiRequest`, exact `ModelCapability`, encrypted provider credential, provider response usage, and authenticated xAI session request.
- Produces: streaming `AiEvent`, structured tool calls, `ResolvedReasoning`, append-only usage records, transactional budget reservations, reconciliation, and short-lived xAI client-secret responses.

- [ ] **Step 1: Add the focused failing test**

Run one shared adapter contract against deterministic OpenAI, Anthropic, Gemini, xAI, Exa, and compatible fakes. Cover mapping subsets, unsupported fields, cache keys, Anthropic thinking-block preservation, Gemini mutual exclusion, xAI effort subsets, timeout/cancel, SSRF denial, usage units, price effective dates, and parallel budget races.

- [ ] **Step 2: Verify the relevant failure**

Run: `cargo test -p nexus_gateway --test provider_contract --test usage_budget`
Expected: provider ports, mappings, usage, and reservation functions are absent.

- [ ] **Step 3: Implement the minimum behavior**

Resolve capabilities before network calls, omit unsupported fields, use allowlisted provider redirect behavior, encrypt credentials with envelope keys, reserve estimated cost before scheduling, reconcile after final usage, and request xAI ephemeral credentials using only the server-held permanent key.

- [ ] **Step 4: Verify the focused pass**

Run: `cargo test -p nexus_gateway --test provider_contract --test usage_budget`
Expected: all adapter, ephemeral-secret, usage, and concurrency invariants pass.

- [ ] **Step 5: Run the affected integration check**

Run: `cargo test -p nexus_gateway && make capability-catalog-verify`
Expected: signed catalog verification and full gateway tests pass.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add crates/nexus_gateway/src/providers crates/nexus_gateway/src/usage.rs crates/nexus_gateway/src/budgets.rs crates/nexus_gateway/src/realtime.rs crates/nexus_gateway/tests packages/model_capabilities
git commit -m "feat: add ai adapters voice credentials and usage controls"
```

### Task 13: Implement isolated execution and GitHub integrations

**Files:**
- Create: `crates/nexus_gateway/src/execution/mod.rs`
- Create: `crates/nexus_gateway/src/execution/policy.rs`
- Create: `crates/nexus_gateway/src/execution/github_actions.rs`
- Create: `crates/nexus_gateway/src/execution/codespaces.rs`
- Create: `crates/nexus_gateway/src/execution/ssh.rs`
- Create: `crates/nexus_gateway/src/execution/sandbox.rs`
- Create: `infra/containers/worker/Dockerfile`
- Create: `infra/containers/worker/entrypoint.sh`
- Create: `crates/nexus_gateway/tests/execution_contract.rs`
- Create: `crates/nexus_gateway/tests/github_fake.rs`

**Interfaces:**
- Consumes: authorized `ExecutionRequest`, target capability/policy, GitHub App or user grant, pinned SSH host key, and sandbox manager.
- Produces: isolated Zsh/Fish/NuShell sessions, GitHub workflow dispatch/log/artifacts, Codespaces lifecycle, SSH bridge, sequenced execution events, and audit trails.

- [ ] **Step 1: Add the focused failing test**

Cover non-root/readonly/no-host-mount worker policy, CPU/memory/storage/TTL limits, network denied by default, no secret auto-injection, workflow path allowlist, delayed run discovery, revoked GitHub grant, rate limit, host-key change, resume, cancel, and cleanup.

- [ ] **Step 2: Verify the relevant failure**

Run: `cargo test -p nexus_gateway --test execution_contract --test github_fake`
Expected: execution adapters and worker image are missing.

- [ ] **Step 3: Implement the minimum behavior**

Model each target as a capability adapter. Keep Actions batch-only. Require explicit authorization and cost preview for Codespaces/remote resources. Create sandbox sessions with fixed quotas and deny-by-default network policy.

- [ ] **Step 4: Verify the focused pass**

Run: `cargo test -p nexus_gateway --test execution_contract --test github_fake`
Expected: target contract and fake GitHub tests pass.

- [ ] **Step 5: Run the affected integration check**

Run: `make worker-security-test && make execution-integration-test`
Expected: container policy inspection, terminal lifecycle, replay, and cleanup pass.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add crates/nexus_gateway/src/execution crates/nexus_gateway/tests infra/containers/worker
git commit -m "feat: add isolated and github execution targets"
```

### Task 14: Implement durable Elixir/OTP many-agent orchestration

**Files:**
- Create: `services/orchestrator/lib/nexus_orchestrator/application.ex`
- Create: `services/orchestrator/lib/nexus_orchestrator/mission_supervisor.ex`
- Create: `services/orchestrator/lib/nexus_orchestrator/mission.ex`
- Create: `services/orchestrator/lib/nexus_orchestrator/agent.ex`
- Create: `services/orchestrator/lib/nexus_orchestrator/scheduler.ex`
- Create: `services/orchestrator/lib/nexus_orchestrator/provider_limiter.ex`
- Create: `services/orchestrator/lib/nexus_orchestrator/store.ex`
- Create: `services/orchestrator/test/mission_recovery_test.exs`
- Create: `services/orchestrator/test/scheduler_properties_test.exs`

**Interfaces:**
- Consumes: durable queued missions, DAG steps, `OrchestrationProfile`, budget reservation API, permission decisions, and provider rate-limit feedback.
- Produces: persisted Planning/Running/Waiting/Verifying/terminal transitions, supervised agents, fair bounded scheduling, checkpoints, cancellation propagation, and idempotent results.

- [ ] **Step 1: Add the focused failing test**

Property and integration tests assert DAG dependency safety, concurrency ceilings, fairness, shared-resource locks, provider token buckets, backpressure, bounded retries, circuit breaking, deadline/budget cancellation, crash recovery, duplicate event tolerance, and no terminal-state reversal.

- [ ] **Step 2: Verify the relevant failure**

Run: `cd services/orchestrator && mix test`
Expected: application and supervision modules are missing.

- [ ] **Step 3: Implement the minimum behavior**

Use a partitioned Registry, queue, DynamicSupervisor trees, one process per mission and supervised agent child. PostgreSQL is authoritative; notifications only wake schedulers. Persist state before publishing it and use idempotency keys for every external side effect.

- [ ] **Step 4: Verify the focused pass**

Run: `cd services/orchestrator && mix test`
Expected: lifecycle, property, crash, fairness, and budget tests pass.

- [ ] **Step 5: Run the affected integration check**

Run: `make orchestrator-chaos-test`
Expected: killing agents and the orchestrator during active fake missions recovers without duplicate completed side effects.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add services/orchestrator
git commit -m "feat: add durable otp agent orchestration"
```

### Task 15: Implement Skills, Wasm Plugins, NKB retrieval, Open Design, Pets, and theme normalization backend

**Files:**
- Create: `crates/nexus_gateway/src/extensions/skills.rs`
- Create: `crates/nexus_gateway/src/extensions/plugins.rs`
- Create: `crates/nexus_gateway/src/extensions/knowledge.rs`
- Create: `crates/nexus_gateway/src/extensions/open_design.rs`
- Create: `crates/nexus_gateway/src/extensions/pets.rs`
- Create: `crates/nexus_gateway/src/extensions/themes.rs`
- Create: `packages/knowledge_schema/nkb.schema.json`
- Create: `packages/plugin_sdk/wit/nexus-plugin.wit`
- Create: `infra/migrations/0003_knowledge_extensions.sql`
- Create: `crates/nexus_gateway/tests/extensions_security.rs`
- Create: `crates/nexus_gateway/tests/hybrid_retrieval.rs`

**Interfaces:**
- Consumes: `.nplug`, `.nkb`, `.npet`, ThemePack media, Skill directories, instruction layers, and pinned canonical Open Design release/SHA.
- Produces: deterministic instruction compilation, Wasmtime-hosted bounded tools, ACL-filtered FTS+pgvector HNSW+RRF retrieval with citations, package registries, validated theme media/posters, and rollback.

- [ ] **Step 1: Add the focused failing test**

Cover traversal, decompression bombs, hash/signature/license/engine mismatch, duplicate Skill IDs, precedence, reference boundaries, token budgets, prompt injection isolation, Wasm fuel/memory/time/network denial, ACL-before-ranking, citations, malformed pets, forged media MIME, oversized decoded frames, videos over 30 seconds, metadata/audio removal, and activation rollback.

- [ ] **Step 2: Verify the relevant failure**

Run: `cargo test -p nexus_gateway --test extensions_security --test hybrid_retrieval`
Expected: extension services, schemas, WIT, and migration are missing.

- [ ] **Step 3: Implement the minimum behavior**

Use content-addressed extraction and atomic activation. Compile instructions in immutable precedence. Run plugin components in Wasmtime with deny-by-default capabilities. Filter tenant/project ACLs before lexical/semantic ranking. Pin Open Design to `nexu-io/open-design` release or SHA and never execute installer scripts. Normalize themes in a bounded worker and strip audio/metadata.

- [ ] **Step 4: Verify the focused pass**

Run: `cargo test -p nexus_gateway --test extensions_security --test hybrid_retrieval`
Expected: security, determinism, retrieval, media, and rollback tests pass.

- [ ] **Step 5: Run the affected integration check**

Run: `make extension-integration-test`
Expected: valid sample packages install, query, activate, update, and roll back; malicious fixtures fail without changing active state.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add crates/nexus_gateway/src/extensions crates/nexus_gateway/tests packages/knowledge_schema packages/plugin_sdk infra/migrations/0003_knowledge_extensions.sql
git commit -m "feat: add secure extensions knowledge and themes"
```

### Task 16: Add end-to-end tests, security pipeline, and guarded signed releases

**Files:**
- Create: `tests/e2e/mobile_backend_test.dart`
- Create: `tests/contract/openapi_test.sh`
- Create: `tests/security/secret_fixture_allowlist.txt`
- Create: `.github/workflows/ci.yml`
- Create: `.github/workflows/security.yml`
- Create: `.github/workflows/release-android.yml`
- Create: `.github/workflows/release-ios.yml`
- Create: `.github/dependabot.yml`
- Create: `docs/operations/development.md`
- Create: `docs/operations/deployment.md`
- Create: `docs/operations/signing.md`
- Create: `docs/security/threat-model.md`
- Create: `docs/security/provider-data-flow.md`
- Modify: `README.md`

**Interfaces:**
- Consumes: complete mobile/backend/orchestrator system, protected GitHub environments, Android upload keystore secrets, Apple distribution certificate/profile secrets, and version tags.
- Produces: verified unsigned PR builds; signed APK/AAB and archive/IPA only from protected tags; checksums, CycloneDX SBOM, provenance, changelog, and documented operating procedures.

- [ ] **Step 1: Add the focused failing test**

Create end-to-end scenarios for login, project, mission, live agent events, cancellation, security scan, terminal target selection, voice fake, theme activation, provider mapping, budget hard-stop, usage export, extension import, and offline draft reconciliation. Add workflow policy tests proving fork PRs receive no secrets and release jobs fail when signing inputs are absent.

- [ ] **Step 2: Verify the relevant failure**

Run: `make e2e-test && make workflow-policy-test`
Expected: end-to-end harness and workflows are missing.

- [ ] **Step 3: Implement the minimum behavior**

Build CI stages for formatting, analyzer/lints, unit/integration/contract tests, bridge drift, SAST, SCA, secret scan, container/IaC scan, migration tests, unsigned Android/iOS build checks, SBOM, and provenance. Gate signing behind protected version tags and environments; never store signing files in artifacts longer than the job.

- [ ] **Step 4: Verify the focused pass**

Run: `make e2e-test && make workflow-policy-test`
Expected: all system and workflow policy scenarios pass with fake providers.

- [ ] **Step 5: Run the affected integration check**

Run: `make verify-release`
Expected: static analysis, tests, audits, secret scan, unsigned Android build, SBOM, checksums, and provenance pass; iOS archive runs on a macOS CI runner; signed jobs stop with a clear missing-secret error outside protected release environments.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add .github tests docs/operations docs/security README.md
git commit -m "ci: add secure verification and signed release gates"
```

## Final verification

- [ ] Run `make clean verify` in a clean Linux CI environment and retain test, audit, SBOM, checksum, and provenance artifacts.
- [ ] Run `flutter build appbundle --release` with protected Android signing inputs and verify the AAB certificate fingerprint.
- [ ] Run `flutter build ipa --release --export-options-plist=ios/ExportOptions.plist` on a protected macOS runner and verify archive signing and entitlements.
- [ ] Confirm no permanent provider key, access token, refresh token, SSH private key, keystore, certificate, provisioning profile, transcript, or raw microphone buffer exists in the repository or release assets.
- [ ] Compare every acceptance criterion in `docs/specs/2026-08-20-nexus-fullstack-d2-design.md` with passing test or artifact evidence before publishing a release.
