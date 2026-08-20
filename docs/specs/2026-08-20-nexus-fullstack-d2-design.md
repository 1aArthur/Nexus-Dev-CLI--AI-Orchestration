# Nexus Full-Stack D2 Design

Date: 2026-08-20
Status: approved by Arthur on 2026-08-20
Target repository: `1aArthur/Nexus-Dev-CLI--AI-Orchestration`

## 1. Goal

Rebuild the Android-only Kotlin/Jetpack Compose Nexus application as a production-oriented Android and iOS platform. Flutter/Dart owns the mobile experience, Rust owns native performance-sensitive work and the public backend gateway, and Elixir/OTP owns resilient agent orchestration. The migration preserves the observable feature areas of the Kotlin application while replacing its cosmic color palette with an OLED black-and-white design and adding secure Grok realtime voice transcription.

## 2. Scope

The first complete release includes:

- Flutter applications for Android and iOS from one Dart codebase.
- A Rust native core embedded through `flutter_rust_bridge`.
- A Rust Axum gateway backed by PostgreSQL.
- An Elixir/OTP orchestration service with supervised mission and agent processes.
- Isolated Rust-managed terminal workers with Zsh, Fish, and NuShell images.
- Selectable execution targets for local safe tools, Nexus sandboxes, GitHub Actions, GitHub Codespaces, and explicitly configured remote SSH hosts.
- OIDC Authorization Code with PKCE.
- Grok realtime voice sessions authenticated by short-lived client secrets.
- OpenAI, Anthropic, OpenAI-compatible, Anthropic-compatible, xAI, Gemini, and Exa integrations behind server-side provider ports.
- Versioned Skills, permissioned WebAssembly plugins, layered model instructions, and hybrid-retrieval knowledge bases.
- An Open Design catalog connector pinned to the canonical `nexu-io/open-design` GitHub source and its Apache-2.0 licensed catalogs.
- A vendor-neutral Pet Pack system with built-in original pets and validated external pack import.
- User-created visual themes backed by a local image or muted video of at most 30 seconds.
- A complete, auditable usage and credits dashboard with budgets, alerts, exports, and versioned price catalogs.
- Bounded many-agent orchestration with configurable concurrency, cost, time, provider, and approval limits.
- A model-aware reasoning selector that translates universal user profiles into only the parameters each selected model supports.
- CI, security scanning, SBOM generation, reproducible build commands, and guarded signing workflows.
- Documentation for development, deployment, authentication, xAI configuration, and release signing.

## 3. Non-goals

- Executing arbitrary native shell commands directly on iOS or Android.
- Presenting GitHub Actions as an interactive terminal; Actions is a queued batch executor with logs and artifacts.
- Embedding permanent AI provider keys, signing material, or OIDC client secrets in the app.
- Persisting microphone audio or transcripts without an explicit user action.
- Reproducing the Kotlin implementation line by line when its behavior can be expressed more safely or portably.
- Shipping a signed store artifact without the repository owner supplying the private Android and Apple signing credentials through protected secrets.
- Redistributing proprietary OpenAI, Anthropic, or third-party mascot artwork without an explicit license that permits redistribution in the Nexus application.
- Treating instructions, Skills, plugin output, retrieved knowledge, or pet metadata as trusted merely because they came from an installed package.
- Claiming an estimated provider cost is an invoice, balance, or provider-reported charge.
- Displaying or attempting to reconstruct private chain-of-thought; only provider-supported summaries and operational metrics may be shown.

## 4. System architecture

### 4.1 Flutter/Dart client

Flutter owns UI, navigation, application state, offline reads, draft creation, microphone permission, audio capture, audio playback, networking, and local SQLite persistence. Features follow `data`, `domain`, and `presentation` boundaries. Dependencies flow toward domain interfaces.

The phone navigation destinations are Dashboard, Agents, Voice, Terminal, and More. Tablet and wider layouts use an adaptive navigation rail. The More area exposes Workflows, Research, Security, Tools, Skills, CI/CD, and Settings.

### 4.2 Embedded Rust core

The Rust library exposes typed APIs to Dart through generated `flutter_rust_bridge` bindings. Its bounded responsibilities are:

- PCM chunk validation and buffering.
- Audio waveform downsampling.
- SHA-256 hashing and deterministic artifact fingerprints.
- Local static-analysis primitives and safe parsing.
- Diff summarization primitives.
- Redaction helpers for logs and exported diagnostics.

The bridge never receives provider API keys, refresh tokens, Android signing keys, Apple certificates, or raw OIDC client secrets.

### 4.3 Axum gateway

Axum is the only public backend entry point. It provides:

- OIDC token validation and RBAC enforcement.
- REST resources for projects, missions, agents, workflows, scans, settings, and voice sessions.
- WebSocket streams for mission events, terminal sessions, logs, and telemetry.
- Idempotency enforcement for state-changing requests.
- PostgreSQL transactions, outbox records, and audit records.
- xAI client-secret creation with the permanent `XAI_API_KEY` held only in the server environment.
- Provider adapters for Gemini, Exa, and future AI providers.
- AI provider configuration, capability discovery, encrypted user credentials, connection tests, and adapters for OpenAI and Anthropic protocols.
- GitHub App and user-authorized integrations for workflow dispatch, run status, job logs, artifacts, and Codespaces lifecycle.
- Rate limiting, request size limits, timeouts, structured tracing, and graceful shutdown.

### 4.4 Elixir/OTP orchestrator

Elixir consumes durable pending mission records from PostgreSQL and uses database notifications only as wake-up hints. A `DynamicSupervisor` starts one mission process per accepted mission. Each mission starts supervised agent processes for planned tasks. Mission state transitions and agent events are persisted before being treated as externally visible.

The orchestrator uses bounded restart intensity, bounded retries with backoff, persisted cancellation, deterministic timeouts, checkpoints, and idempotent result writes. A process crash must not duplicate a completed side effect. Recovery reconstructs incomplete missions from PostgreSQL.

### 4.5 Terminal workers

Terminal sessions run outside the mobile device in ephemeral, unprivileged containers. Each session has a fixed TTL, CPU limit, memory limit, storage quota, read-only base filesystem, non-root user, no host mounts, no privileged mode, and network disabled by default. Policy grants are explicit and audited. Provider secrets are never injected automatically.

### 4.6 PostgreSQL

PostgreSQL is the source of truth for users, projects, missions, agent tasks, events, checkpoints, workflows, security findings, terminal sessions, audit logs, and outbox entries. Database notifications accelerate live updates but do not replace durable reads.

### 4.7 Execution targets

The terminal and workflow composer depend on an `ExecutionTarget` port. The target selector exposes only capabilities the selected target actually supports:

- `local_core`: runs a fixed catalog of safe Rust operations on the device. It does not expose an arbitrary shell and remains identical on Android and iOS.
- `nexus_sandbox`: provides an interactive TTY over WebSocket in an ephemeral isolated worker. It supports Zsh, Fish, and NuShell.
- `github_actions`: dispatches an allowlisted repository workflow, follows run and job state, downloads logs, and exposes produced artifacts. It is batch-only and has no interactive stdin.
- `github_codespaces`: creates or selects a user-owned Codespace through GitHub APIs and connects through a backend-controlled SSH bridge after explicit authorization. Availability depends on the user's GitHub plan and repository permissions.
- `remote_ssh`: connects to an explicitly configured host through the Axum backend. Host keys are pinned on first approved configuration and changes require re-approval.

Every execution request records target, repository or host scope, requested command or workflow, actor, policy decision, timestamps, exit status, and artifact references. The app displays cost and permission implications before starting metered GitHub or remote resources.

### 4.8 AI provider ports

Agent roles depend on a protocol-neutral `AiProvider` port rather than vendor SDK types. The shared request model covers system instructions, user and tool messages, streaming text, structured tool definitions, optional images, cancellation, token usage, and provider-native metadata kept in an extension map.

The initial adapters are:

- OpenAI Responses API.
- Anthropic Messages API.
- OpenAI-compatible endpoints with configurable HTTPS base URL, model identifier, and authentication header strategy.
- Anthropic-compatible endpoints with configurable HTTPS base URL, version header, model identifier, and authentication header strategy.
- Existing xAI, Gemini, and Exa adapters.

Capability discovery returns supported streaming, tools, vision, structured output, and realtime voice flags. A mission may select a default provider and override it per agent role. Unsupported capabilities fail during planning rather than halfway through execution.

### 4.9 Skills

A Skill is a declarative, versioned instruction package. Its source form is a directory containing `manifest.json`, one complete `SKILL.md`, and optional `references/`, `templates/`, and JSON Schemas. The manifest declares stable ID, semantic version, compatible engine range, entry document, required tools, required provider capabilities, requested permissions, content hashes, license, and publisher signature.

Skills never execute native code. The instruction compiler resolves selected Skills, detects duplicate IDs and incompatible versions, enforces permission grants, follows only declared references, and produces a deterministic instruction contribution with provenance. Project, organization, and user scopes may enable different Skill versions. Removing a Skill does not delete historical provenance from completed missions.

### 4.10 Plugins

A Plugin may add backend tools, provider adapters, importers, exporters, or declarative mobile UI contributions. The portable `.nplug` bundle contains `manifest.json`, JSON Schemas, optional assets, and a WebAssembly component. Executable plugin code runs only in a server-side Wasmtime sandbox with fuel, memory, time, filesystem, network, and host-function limits. Mobile clients render only schema-validated declarative contributions and never load plugin native code.

Every plugin declares permissions and outbound domains. Installation verifies archive limits, hashes, signature, engine compatibility, and license metadata. Unsigned developer plugins are allowed only in an explicit development mode and are visually marked. Updates are staged, revalidated, and can be rolled back to the previous content-addressed version.

### 4.11 Model instructions

Instructions are layered in this immutable precedence order: engine safety policy, organization policy, provider adapter requirements, agent role, enabled Skills, project instructions, mission instructions, and current user request. A lower layer cannot remove or rewrite a higher layer.

Source instructions use UTF-8 Markdown with YAML-free JSON metadata kept in separate manifests. The compiler normalizes line endings, assigns stable section IDs, hashes content, removes duplicate sections, calculates model-specific token cost, applies an explicit token budget, and renders a provider-specific request. Stable prefixes are cached where the provider supports prompt caching. Every mission stores the hashes and versions of the compiled instruction layers used to produce it.

### 4.12 Knowledge base

Knowledge source documents remain human-auditable UTF-8 Markdown, plain text, PDF-derived text, or structured JSON. Runtime retrieval never asks a model to scan one monolithic file.

The portable `.nkb` package contains `manifest.json`, content-addressed source files, and a Zstandard-compressed Apache Arrow IPC chunk table. Each chunk records stable ID, document ID, heading path, byte offsets, text, token counts by supported tokenizer, language, MIME type, ACL tags, timestamp, source hash, and optional embedding vector. The package is verified and extracted before runtime use; compressed archives are never memory-mapped directly.

Server ingestion stores chunks, metadata, ACLs, and embeddings in PostgreSQL. PostgreSQL full-text search supplies lexical ranking and `pgvector` HNSW `halfvec` indexes supply semantic ranking. Reciprocal Rank Fusion combines both result lists, followed by optional provider-independent reranking. Retrieval always filters tenant and project ACLs before ranking and returns citations with source hashes.

Arrow IPC is the optimized interchange and offline-read format because the Rust core can read typed columns without JSON parsing. PostgreSQL remains the online source of truth and query engine. Markdown remains the authoring format; it is not used as the production search index.

### 4.13 Open Design connector

The built-in Open Design catalog connector points only to the canonical `https://github.com/nexu-io/open-design` repository. It can inspect releases, licenses, content hashes, Skills, systems, templates, and compatible plugins. A sync operation imports selected compatible declarative packages into the Nexus registries after validation; it does not execute repository installation scripts or silently replace local versions.

The connector pins a release tag or commit SHA, records Apache-2.0 license metadata, and shows upstream provenance. Local Codex, Open Design Cloud, and secure BYOK execution remain separate user-selected modes when an installed Open Design runtime is available.

### 4.14 Pet Packs

Pets are optional presentation companions and have no authority to execute tools, change prompts, grant permissions, or read private mission content. The `.npet` bundle contains `manifest.json`, `animations.json`, PNG or WebP sprite sheets, accessibility labels, license metadata, content hashes, and an optional publisher signature. Animation clips are named rather than position-dependent, allowing external packs with different frame counts and directions.

The app ships only original, redistribution-safe built-in pets. External packs may be imported from a local file, an HTTPS URL, or a signed catalog. Imports validate decoded dimensions, frame counts, animation duration, decompressed size, MIME type, hashes, license fields, and schema compatibility before assets are rendered.

OpenAI ChatGPT Work Pets and Anthropic-branded mascots are not bundled unless the respective owner provides an official redistributable pack or API and license. The catalog may show a disabled provider entry explaining the missing authorized source, but it must not scrape, clone, or relabel proprietary artwork. A user-authorized future connector can map an official export into `.npet` without changing the runtime format.

### 4.15 Custom visual themes

The default remains the high-contrast OLED black-and-white theme. A user may create a `ThemePack` from one still image or one short video. Accepted source images are JPEG, PNG, or WebP. Accepted source video is MP4 with an H.264 video track, no required audio track, and a decoded duration of at most 30 seconds. Unsupported media is rejected with a precise reason rather than rendered through an unsafe or platform-specific fallback.

An imported theme is validated by MIME signature, extension agreement, byte size, decoded pixel count, frame dimensions, duration, frame rate, and codec. Audio tracks are removed during normalization. The app creates an encrypted-at-rest local normalized asset plus a poster frame and never uploads it unless the user explicitly enables theme synchronization. Imports use a temporary file and an atomic move so interrupted processing cannot replace the active theme.

The theme editor exposes crop, focal point, blur, dimming, contrast scrim, loop, and parallax controls. Foreground controls continue to use black, white, and neutral grays selected by measured contrast over the current frame. Reduced Motion always uses the poster frame. Battery Saver pauses animated themes; backgrounding the app pauses decoding; terminal, permission, and destructive-action surfaces may force a solid OLED background for legibility and safety. A failed theme can be disabled without deleting the original import.

### 4.16 Usage and credits ledger

Every AI or metered tool request writes an append-only `usage_record` after provider normalization. The record identifies tenant, project, mission, step, agent, provider, model, request, execution target, status, latency, currency, price-catalog version, and whether cost is `estimated` or `provider_reported`. Metrics include input, cached-input, output, reasoning, and total tokens when supplied; audio input/output units or seconds; image and video units; web/search/tool calls; container or terminal runtime; and provider-native usage metadata in a versioned extension object.

`price_catalogs` contain effective date ranges, currencies, model aliases, context tiers, cache and batch discounts, tool prices, and audio/image/video units. Catalog entries are versioned and never retroactively mutate historical estimates. A reconciliation job may replace an estimate with a linked provider-reported charge while preserving both records and the reason for any difference. The UI never converts an API estimate into a claimed provider account balance when the provider does not expose a billing API.

The Credits center shows current-period total, remaining user-defined budget, estimated versus provider-reported amounts, token and unit breakdowns, latency, failures, and filters by date, provider, model, project, mission, agent, and execution target. It supports daily and monthly budgets, warning and hard-stop thresholds, per-mission preflight estimates, live accumulation, CSV/JSON export, and a visible timestamp and source for every price. Budget enforcement is atomic with mission scheduling so parallel agents cannot overspend a shared hard limit through races.

### 4.17 Many-agent orchestration

An `OrchestrationProfile` controls planning mode, maximum agents, maximum concurrent agents, task timeout, mission deadline, retry policy, provider quotas, token and currency budgets, tool permissions, and approval gates. Organization and project policy define hard ceilings; users may select any smaller value. The planner converts the mission into a dependency DAG and assigns typed roles only after capability, cost, data-residency, and permission checks pass.

Elixir/OTP uses a partitioned registry, queue, `DynamicSupervisor` trees, backpressure, and fair scheduling across missions. Agents run concurrently only when their DAG dependencies and shared-resource locks permit it. Provider adapters expose concurrency and rate-limit feedback; the scheduler applies token-bucket limits, bounded exponential backoff, circuit breakers, and provider-aware queueing. Cancellation, budget exhaustion, deadline expiry, revoked credentials, and permission denial stop new scheduling and propagate to running children.

The default collaboration mode uses one planner, independent specialists for parallel-ready tasks, one synthesizer, and a verifier only when the mission risk profile requires it. Debate, voting, or duplicate execution must be explicitly selected or triggered by a verification policy because they multiply cost. Outputs carry provenance, confidence, artifacts, citations, and dissent; the synthesizer cannot erase failed checks. The Agent Matrix screen shows the DAG, queues, live concurrency, per-agent model and reasoning profile, cost, latency, tool grants, retries, and cancellation controls.

### 4.18 Model-aware reasoning profiles

The user-facing selector is `Auto`, `Fast`, `Balanced`, `Deep`, or `Maximum`. It is not sent directly to a provider. A versioned `ModelCapability` registry translates it for the exact model ID and API version, records the effective parameter in the request audit, and disables unsupported choices in the UI. `Auto` preserves the model's documented default or adaptive behavior. No adapter silently substitutes a more expensive level; downgrades require an explicit recorded fallback policy.

Initial native mappings follow official model documentation and remain data-driven:

| Provider family | Native control | Nexus translation rule |
|---|---|---|
| OpenAI GPT-5.6 | `reasoning.effort`: `none`, `low`, `medium`, `high`, `xhigh`, `max`; optional `reasoning.mode: pro` | `Fast=low`, `Balanced=medium`, `Deep=high`, `Maximum=max`; Pro is a separate quality-first toggle with cost and latency warning. |
| Other OpenAI reasoning models | model-specific subset of `reasoning.effort` | Map to the nearest supported level without exceeding the user's selected level; unsupported distinctions are disabled. |
| Anthropic adaptive-thinking models | `thinking.type=adaptive` plus `output_config.effort` | Use adaptive thinking and map profiles only to effort values advertised for the exact model. Preserve signed thinking blocks unchanged across tool turns. |
| Anthropic legacy/manual-thinking models | `thinking.type=enabled` plus `budget_tokens` | Use policy-bounded, model-specific token budgets; never send adaptive-only fields. |
| Gemini 3.x | `thinkingLevel` with a model-specific subset of `minimal`, `low`, `medium`, `high` | `Fast=minimal` when supported, otherwise `low`; `Balanced=medium`; `Deep/Maximum=high`. Never combine it with `thinkingBudget`. |
| Gemini 2.5 | `thinkingBudget` | Translate profiles to tested model-specific budgets, with `Auto=-1` only where documented. |
| xAI Grok | model-specific `reasoning_effort`, commonly `none`, `low`, `medium`, `high` | `Fast=low`, `Balanced=medium`, `Deep/Maximum=high`; `none` is offered only on models that document it. |
| Compatible or non-reasoning model | discovered schema or no control | Use a tested custom mapping; otherwise show `Not supported` and omit all reasoning fields. |

Optimization profiles also define prompt-cache keys, stable instruction prefixes, context compaction, reasoning-context preservation, maximum output, tool-call limits, supported sampling fields, timeout class, and retry semantics per model. The registry is updated through signed server data, pinned per mission, and protected by contract tests against provider fakes. The UI may show a provider-returned reasoning summary, but never hidden reasoning tokens or reconstructed chain-of-thought.

## 5. User experience and visual system

The visual system uses `#000000` for the base background and `#FFFFFF` for primary foreground and actions. Neutral grays may communicate hierarchy, disabled state, dividers, and secondary text. Gradients, neon colors, galaxy imagery, and color-only status meanings are excluded.

Severity and state combine text, icons, shape, and pattern. Touch targets are at least 48 logical pixels. All actions have semantic labels, dynamic type remains usable, motion respects reduced-motion settings, and screen-reader order follows visual order.

The central Voice action replaces the original cosmic orb. It exposes connection state, microphone state, waveform, cumulative transcript, assistant transcript, playback state, discard, save, and send-as-mission actions.

The More area adds Extensions, Knowledge, Instructions, Pets, Themes, and Credits. The companion can be disabled globally, per project, or during focused terminal and voice sessions. Pet motion obeys reduced-motion settings and never obscures terminal input, permissions, errors, or primary actions.

The mission composer exposes Agent Count, Maximum Concurrency, Budget, Deadline, Approval Policy, and Reasoning Profile. Changing model or provider immediately recomputes available reasoning choices and a cost/latency preview. The Agent Matrix and Credits center remain read-only offline and clearly display the freshness of cached usage.

## 6. Feature mapping from Kotlin

| Kotlin feature | New feature |
|---|---|
| DashboardScreen | Command Deck dashboard |
| AgentMonitorScreen | Agent monitor and timeline |
| OrchestratorScreen | Mission composer and DAG orchestration |
| TerminalScreen / TerminalEmulator | Capability-aware multi-target execution console |
| WorkflowsScreen | Workflow and pipeline center |
| ExaSearchScreen | Research workspace |
| SecurityCenterScreen | Security overview |
| SecurityAuditScreen | MASVS and DevSecOps audit |
| CicdNativeScreen | CI/CD and artifact center |
| ToolsHubScreen | Tool catalog and permissions |
| SkillsSettingsScreen | Agent profiles and skills |
| SettingsScreen | Application and backend settings |
| CosmicAutopilotSheet | Mission quick actions |
| AudioNarrationManager | Voice Core playback and transcript controls |

Kotlin `AgentType`, `AgentState`, mission phases, security findings, SBOM components, terminal shell types, telemetry, and pipeline stages become generated shared API schemas plus Dart domain models.

## 7. Public interfaces

### 7.1 REST

- `GET /v1/health/live` and `GET /v1/health/ready`
- `GET /v1/me`
- `GET|POST /v1/projects`
- `GET|POST /v1/projects/{projectId}/missions`
- `GET|POST /v1/missions/{missionId}/actions`
- `GET /v1/missions/{missionId}`
- `GET /v1/missions/{missionId}/events`
- `POST /v1/realtime/client-secret`
- `POST /v1/terminal/sessions`
- `DELETE /v1/terminal/sessions/{sessionId}`
- `GET /v1/execution-targets`
- `POST /v1/executions`
- `POST /v1/executions/{executionId}/actions`
- `GET /v1/executions/{executionId}/logs`
- `GET|POST /v1/providers`
- `POST /v1/providers/{providerId}/test`
- `GET /v1/providers/{providerId}/models`
- `GET /v1/github/repositories/{repositoryId}/workflows`
- `POST /v1/github/repositories/{repositoryId}/workflows/{workflowId}/dispatches`
- `GET|POST /v1/github/codespaces`
- `GET|POST /v1/skills`
- `POST /v1/skills/{skillId}/versions/{version}/enable`
- `GET|POST /v1/plugins`
- `POST /v1/plugins/{pluginId}/versions/{version}/enable`
- `GET|POST /v1/instruction-sets`
- `POST /v1/instructions/compile`
- `GET|POST /v1/knowledge-bases`
- `POST /v1/knowledge-bases/{knowledgeBaseId}/imports`
- `POST /v1/knowledge-bases/{knowledgeBaseId}/search`
- `POST /v1/catalogs/open-design/sync`
- `GET|POST /v1/pet-packs`
- `POST /v1/pet-packs/{petPackId}/activate`
- `GET|POST /v1/theme-packs`
- `POST /v1/theme-packs/{themePackId}/activate`
- `DELETE /v1/theme-packs/{themePackId}`
- `GET /v1/usage`
- `GET /v1/usage/summary`
- `GET /v1/usage/export`
- `GET|POST /v1/budgets`
- `GET /v1/price-catalogs/current`
- `GET /v1/model-capabilities`
- `POST /v1/model-capabilities/resolve`
- `GET|POST /v1/orchestration-profiles`
- `POST /v1/security/scans`
- `GET /v1/security/scans/{scanId}`
- `GET /v1/workflows` and `POST /v1/workflows/{workflowId}/runs`

State-changing calls require an `Idempotency-Key`. Responses expose a request `traceId`. Pagination uses opaque cursors.

### 7.2 WebSocket

- `/v1/ws/missions/{missionId}` streams sequenced mission and agent events.
- `/v1/ws/terminal/{sessionId}` streams typed terminal input and output frames.
- `/v1/ws/executions/{executionId}` streams target-neutral state, log, and artifact events. Interactive input frames are accepted only when the advertised target capability includes `interactiveInput`.

Clients resume from the last acknowledged sequence. Missed events are read from the durable event endpoint before live streaming resumes.

### 7.3 Error envelope

Public failures use a stable machine code, localized-safe message, retryable flag, and trace identifier. Validation failures include field paths without echoing sensitive input.

```json
{
  "code": "MISSION_STEP_TIMEOUT",
  "message": "A etapa excedeu o tempo permitido.",
  "retryable": true,
  "traceId": "01J..."
}
```

## 8. Core data model

Principal records are `users`, `projects`, `missions`, `mission_steps`, `agent_tasks`, `mission_events`, `mission_checkpoints`, `orchestration_profiles`, `workflows`, `workflow_runs`, `execution_targets`, `executions`, `execution_events`, `ai_providers`, `provider_credentials`, `model_capabilities`, `skills`, `skill_versions`, `plugins`, `plugin_versions`, `instruction_sets`, `knowledge_bases`, `knowledge_documents`, `knowledge_chunks`, `pet_packs`, `pet_pack_versions`, `theme_packs`, `usage_records`, `usage_reconciliations`, `budgets`, `budget_reservations`, `price_catalogs`, `price_catalog_entries`, `security_scans`, `security_findings`, `terminal_sessions`, `audit_events`, and `outbox_events`.

Every user-owned record carries a stable UUID and owner or project relationship. Mission events carry an increasing per-mission sequence. External provider identifiers are stored separately from internal identifiers. Audit events are append-only at the application layer.

## 9. Mission behavior

The mission lifecycle is Draft, Queued, Planning, Running, Waiting, Verifying, Completed, Failed, or Canceled. A user-confirmed draft becomes queued exactly once. Waiting represents an explicit dependency or approval boundary. Verification may schedule bounded corrective work. A completed, failed, or canceled mission is terminal.

Cancellation is persisted before signals are sent to running processes. Late results from canceled or superseded attempts are recorded for diagnosis but cannot change the terminal mission state.

## 10. Voice behavior

The mobile app requests a short-lived session from Axum. Axum authenticates the user, applies rate limits, requests an ephemeral xAI client secret with its server-held API key, and returns the permitted realtime URL, expiration, and non-secret session configuration. The app authenticates its WebSocket with the ephemeral secret.

The Rust core validates PCM framing and prepares waveform samples. Dart owns microphone lifecycle and UI state. Cumulative `conversation.item.input_audio_transcription.updated` events replace the current partial input transcript. Incremental output transcript events append in sequence. Unknown events are ignored and logged by type without logging payloads. The user may discard, explicitly save, or convert the transcript into a mission draft.

Audio and transcript content remain memory-only unless the user saves them. Disconnects use bounded reconnect with session resumption when supported. Expired secrets are replaced through a newly authenticated Axum request.

## 11. Authentication and authorization

The mobile app uses system-browser OIDC Authorization Code with PKCE. The backend validates issuer, audience, signature, expiry, and allowed algorithms against configured provider metadata and JWKS. Production rejects wildcard redirect URIs and plain HTTP redirects.

Roles are `viewer`, `operator`, and `admin`. Viewers read project state. Operators create and control missions and terminal sessions within granted projects. Admins manage policies, providers, and membership. Every privileged decision is enforced server-side and recorded in the audit log.

Access tokens are short-lived. Refresh tokens rotate and are stored through platform Keychain or Keystore facilities. Logout removes local tokens and revokes the refresh session when the provider supports revocation.

GitHub authorization uses a GitHub App or OIDC-linked user authorization with minimum repository permissions. Personal access tokens are not stored in the mobile app. Provider API keys entered through an authenticated settings flow are sent once over TLS, encrypted with a per-record data key, and stored server-side using envelope encryption. The key-encryption key comes from the deployment secret store. Stored provider credentials are never returned to the client after creation.

## 12. Offline and synchronization

Flutter stores read models and unsent drafts in local SQLite. Cached screens state their freshness. Drafts may be edited offline. Executions, terminal commands, policy changes, and security fixes require a successful server acknowledgment and never present optimistic completion.

Reconnect first refreshes authoritative resources, then replays unsent drafts with their original idempotency keys. Conflicts preserve both the server version and local draft for explicit resolution.

## 13. Security controls

- TLS is mandatory in production for HTTP and WebSocket traffic.
- Secrets come from deployment secret stores and are never committed.
- Request bodies, uploads, decompressed data, and WebSocket frames have explicit limits.
- SQL uses parameterized queries and least-privilege database roles.
- Terminal workers are isolated and disposable.
- Provider responses are untrusted input and cannot directly grant tools or permissions.
- GitHub workflows callable from the app are allowlisted by immutable workflow path and repository scope; arbitrary workflow YAML cannot be injected through dispatch inputs.
- Remote SSH host keys are verified, credentials remain server-side, and the mobile app receives only connection state and terminal frames.
- Custom compatible-provider URLs require HTTPS in production and pass SSRF checks against loopback, link-local, private, and metadata-service destinations unless an administrator explicitly configures a private network policy.
- Skill, Plugin, Knowledge, Open Design, and Pet packages pass archive traversal, decompression-bomb, schema, hash, signature, license, and size validation before installation.
- WebAssembly plugins receive deny-by-default capabilities, cannot access host process memory, and cannot invoke terminal or provider tools without a granted host capability.
- Retrieved knowledge and imported instructions are delimited as untrusted context; prompt-injection text cannot grant tools, change higher-priority instructions, or bypass ACL filters.
- Pet assets are decoded with pixel and frame ceilings and are isolated from instruction and tool registries.
- Theme media is decoded in a resource-bounded worker, normalized to an allowlisted format, stripped of audio and metadata, and never interpreted as executable content.
- Usage hard limits reserve estimated cost transactionally before parallel work begins and reconcile reservations after provider usage arrives.
- Model capability records are signed, versioned, and validated; incompatible reasoning parameters fail before a provider request is sent.
- Logs redact authorization headers, cookies, tokens, provider keys, transcripts, and command secrets.
- Dependency locks are committed and scanned.
- Release artifacts include checksums, CycloneDX SBOM, and build provenance.
- Backups and restore procedures cover PostgreSQL but exclude transient audio buffers.

## 14. Testing strategy

### Dart

Unit tests cover domain reducers, transcript accumulation, reconnect policy, authorization presentation, and offline merge behavior. Widget tests cover navigation, OLED contrast semantics, loading, empty, error, and permission states. Golden tests cover phone and tablet layouts. Integration tests run against deterministic mock services.

Execution-target tests verify capability-driven controls: local safe tools never expose shell input, GitHub Actions never exposes an interactive prompt, and interactive targets reject input until a session is ready.

### Rust native core

Unit and property-based tests cover PCM validation, waveform reduction, hashing, redaction, parsing, and diff summaries. Fuzz targets cover binary and text parsers. Bridge integration tests verify generated Dart/Rust calls and error mapping.

### Axum

Tests cover OIDC validation, RBAC, idempotency, PostgreSQL transactions, outbox writes, client-secret issuance, rate limits, request limits, WebSocket resume, and structured errors. xAI, Gemini, Exa, and OIDC providers are represented by deterministic local fakes.

Provider contract suites run against OpenAI, Anthropic, and compatible-protocol fakes. GitHub integration tests cover workflow dispatch, delayed run discovery, job logs, artifacts, permission denial, rate limiting, Codespaces lifecycle, and revoked authorization.

Skill tests cover precedence, reference resolution, token budgets, duplicate IDs, version conflicts, and deterministic compilation. Plugin tests cover Wasm limits, denied host capabilities, signature failure, staged update, and rollback. Knowledge tests measure lexical, semantic, and hybrid retrieval recall while verifying ACL filtering and citations. Pet tests cover malformed manifests, oversized decoded images, missing animation clips, reduced motion, external imports, and activation rollback.

Theme tests cover forged MIME types, corrupt media, oversized decoded frames, videos over 30 seconds, unsupported codecs, metadata and audio removal, atomic activation, reduced motion, app backgrounding, and contrast enforcement. Usage tests cover cached/reasoning/audio/tool units, price changes across effective dates, reconciliation, rounding, exports, concurrent budget reservations, and estimate-versus-reported labeling. Model-capability tests verify every universal profile against supported native fields and reject incompatible combinations such as Gemini `thinkingLevel` plus `thinkingBudget`.

### Elixir/OTP

ExUnit tests cover mission state transitions, dynamic supervision, agent crashes, restart intensity, retries, timeouts, cancellation, recovery from checkpoints, duplicate event delivery, and terminal-state protection.

Scheduler property tests cover DAG dependency safety, bounded concurrency, fairness, rate-limit backpressure, provider circuit breakers, cancellation propagation, and the invariant that committed usage plus outstanding reservations never exceeds a hard budget.

### System

Contract tests validate OpenAPI schemas and WebSocket event schemas. End-to-end tests cover login, project creation, mission execution, live updates, cancellation, security scan, terminal creation, and voice transcription with a fake realtime server.

## 15. CI/CD and release

Pull requests run formatting, static analysis, tests, bridge code-generation drift checks, SAST, dependency audits, secret scanning, container scanning, database migration tests, and unsigned build verification. Untrusted pull requests never receive signing or deployment secrets.

Protected version tags run Android APK/AAB and iOS archive/IPA jobs. Android signing uses a protected upload keystore. iOS signing uses an Apple distribution certificate, provisioning profile, and macOS runner. A missing credential fails the release; debug signing is not a fallback. Signed artifacts, checksums, SBOM, provenance, and changelog are published only after all gates pass.

## 16. Repository layout

```text
apps/
  mobile/                 Flutter/Dart application
crates/
  nexus_core/             Embedded Rust library
  nexus_gateway/          Axum API and WebSocket gateway
services/
  orchestrator/           Elixir/OTP application
infra/
  containers/             Development worker images
  migrations/             PostgreSQL migrations
packages/
  api_schema/             OpenAPI and event schemas
  skill_schema/           Skill manifests and instruction contracts
  plugin_sdk/             Wasm component interfaces and host schemas
  knowledge_schema/       NKB manifests and Arrow table schema
  pet_pack_schema/        NPET manifests and animation schema
  theme_pack_schema/      Theme manifests and validated media rules
  model_capabilities/     Versioned provider/model reasoning mappings
docs/
  architecture/
  operations/
  security/
  specs/
.github/workflows/
```

## 17. Delivery sequence

1. Establish the monorepo, shared schemas, quality gates, and local development environment.
2. Port domain models and create the OLED adaptive Flutter shell.
3. Implement feature screens with deterministic repositories and tests.
4. Integrate the embedded Rust core and validate Android/iOS bridge builds.
5. Implement Axum, PostgreSQL migrations, OIDC validation, and WebSocket contracts.
6. Implement Elixir/OTP mission supervision and persisted recovery.
7. Implement xAI ephemeral sessions and Voice Core.
8. Implement isolated terminal workers, provider adapters, security scanning, and CI/CD views.
9. Implement GitHub Actions, Codespaces, execution-target selection, and external OpenAI/Anthropic-compatible provider settings.
10. Implement Skills, instruction compilation, Wasm Plugins, NKB hybrid retrieval, and the pinned Open Design catalog connector.
11. Implement original built-in Pet Packs, external NPET validation, accessibility, and optional licensed-provider connectors.
12. Implement custom Theme Packs, safe media normalization, poster fallback, contrast adaptation, and battery/reduced-motion behavior.
13. Implement usage and credits ledger, price catalogs, reconciliation, budgets, alerts, and exports.
14. Implement bounded many-agent profiles, fair scheduling, transactional budget reservations, and the model-capability reasoning registry.
15. Run full contract, integration, security, and release verification.
16. Produce signed store artifacts only when protected owner credentials are available.

## 18. Acceptance criteria

- Android and iOS share the Flutter feature code and expose all mapped Kotlin feature areas.
- The UI uses only OLED black, bright white, and neutral grayscale hierarchy.
- Rust bridge calls are typed, tested, and contain no secrets.
- Axum is the only public service and enforces OIDC, RBAC, limits, and idempotency.
- Elixir supervision recovers a crashed agent without duplicating completed side effects.
- Mission and terminal WebSockets recover missed events by sequence.
- Grok realtime voice uses ephemeral credentials and never embeds `XAI_API_KEY`.
- Audio and transcripts are not persisted by default.
- Arbitrary shell execution occurs only on remote isolated or explicitly authorized targets and is bounded and audited; local mode exposes safe Rust tools only.
- Users can select an execution target and the UI exposes only that target's declared capabilities.
- GitHub Actions jobs can be dispatched, monitored, and inspected without being misrepresented as interactive terminals.
- Authorized Codespaces and remote SSH sessions can provide interactive execution without exposing their credentials to the mobile app.
- OpenAI, Anthropic, and compatible external providers pass one shared contract suite and keep credentials encrypted on the backend.
- Skills compile deterministically with explicit precedence, provenance, token budgets, and permission checks.
- Executable Plugins run only in bounded server-side WebAssembly sandboxes with deny-by-default host capabilities.
- Knowledge uses Markdown authoring, Arrow IPC interchange, and ACL-filtered PostgreSQL full-text plus pgvector HNSW hybrid retrieval.
- Open Design imports are pinned to verified canonical GitHub sources and never run arbitrary installer scripts.
- Original and external Pet Packs use one validated format; proprietary provider pets are included only with a redistributable official source and license.
- Users can activate a validated image theme or muted video theme of at most 30 seconds; reduced-motion and battery policies fall back to its poster frame.
- Credits displays preserve token, media, tool, latency, provider, model, mission, agent, catalog, and estimate/report provenance and enforce concurrent hard budgets without overspend races.
- Many-agent missions execute only DAG-ready work within configured concurrency, provider, cost, time, permission, and approval ceilings and recover without duplicate side effects.
- Reasoning profiles resolve to a pinned, audited model capability; unsupported parameters are omitted or rejected before the provider call, never guessed.
- Static analysis, tests, dependency audits, secret scanning, and build verification pass.
- Release workflows never substitute debug signing for missing production credentials.
