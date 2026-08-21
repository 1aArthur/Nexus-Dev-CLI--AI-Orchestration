# Nexus Engine Abstraction Implementation Plan

> **For agentic workers:** Use the host's available task-by-task implementation workflow. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a production-safe, measurable browser-engine architecture to Nexus without renaming the product or bundling experimental runtimes in the default APK.

**Architecture:** Flutter remains the application UI. A small Dart engine contract selects exactly one installed engine per browsing context; Android System WebView is the first production adapter. Servo, Ultralight, and Lynx remain catalogued but unavailable until separate compatibility, licensing, size, security, and benchmark gates pass.

**Tech Stack:** Flutter/Dart 3.8+, Android System WebView, typed Platform Channels, Rust 1.89 for bounded native services, GitHub Actions, Flutter tests, WPT/benchmark harnesses for later experimental adapters.

## Global Constraints

- Preserve the existing Nexus name, AI orchestration features, OLED design system, and Android/iOS support.
- Ship one Web engine per browsing context; never render one page through multiple engines concurrently.
- Do not add Servo, Ultralight, Lynx, Stylo, or WebRender binaries to the default production package.
- Treat Stylo and WebRender as Servo/Mozilla implementation references, not standalone APK engines.
- Dart owns UI, state, navigation policy, and typed orchestration; it does not reimplement TLS, sandboxing, Same-Origin Policy, CORS, or renderer isolation.
- Every engine feature is capability-checked. Unsupported or uninstalled features fail closed with a visible reason.
- Experimental engines require an explicit build flavor and user opt-in after license, ABI, security, compatibility, memory, battery, and size gates pass.
- The basic application must operate when AI, backend, analytics, extensions, and every experimental engine are unavailable.
- Every optimization requires a recorded benchmark against a stable workload; no invented performance claims.

---

### Task 1: Add the dependency-free engine contract and Engine Lab

**Files:**
- Create: `apps/mobile/lib/features/browser/domain/engine_contract.dart`
- Create: `apps/mobile/lib/features/browser/application/engine_registry.dart`
- Create: `apps/mobile/lib/features/browser/presentation/engine_lab_screen.dart`
- Modify: `apps/mobile/lib/app/router.dart`
- Modify: `apps/mobile/lib/design/components/nexus_scaffold.dart`
- Test: `apps/mobile/test/features/browser/engine_registry_test.dart`
- Test: `apps/mobile/test/app/engine_lab_navigation_test.dart`

**Interfaces:**
- Consumes: existing `NexusDestination`, `GoRouter`, OLED design tokens.
- Produces: `EngineDescriptor`, `EngineCapability`, `EngineRole`, `EngineAvailability`, `EngineSelectionRequest`, `EngineSelectionDecision`, and `EngineRegistry.evaluate`.

- [ ] **Step 1: Add the focused failing test**

Assert that System WebView is the only production-Web candidate; Servo is experimental and disabled; Ultralight is specialized and uninstalled; Lynx is native UI and cannot own arbitrary-Web navigation. Assert an unknown engine, missing required capability, experimental selection without opt-in, and a second engine for the same active context are rejected with stable reason codes. Assert `/more/engine-lab` renders the real catalog rather than a placeholder.

- [ ] **Step 2: Verify the relevant failure**

Run: `cd apps/mobile && flutter test test/features/browser test/app/engine_lab_navigation_test.dart`
Expected: non-zero exit because the engine contract, registry, route, and screen do not exist.

- [ ] **Step 3: Implement the minimum behavior**

Create immutable descriptors and a registry that evaluates selections without loading native code. `EngineRegistry` owns active context-to-engine assignments; it permits only descriptors marked installed, arbitrary-Web-capable, capability-complete, and allowed by the experimental flag. A rejected request never changes an existing assignment. The catalog screen visibly separates Production, Experimental, Specialized, and Native UI roles and states that no alternative runtime is bundled.

- [ ] **Step 4: Verify the focused pass**

Run: `cd apps/mobile && flutter test test/features/browser test/app/engine_lab_navigation_test.dart`
Expected: all engine-policy and route tests pass.

- [ ] **Step 5: Run the affected integration check**

Run: `cd apps/mobile && dart format --output=none --set-exit-if-changed lib test && flutter analyze && flutter test`
Expected: formatting unchanged, zero analyzer issues, and the full Flutter suite passes.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add -- apps/mobile/lib/features/browser apps/mobile/lib/app/router.dart apps/mobile/lib/design/components/nexus_scaffold.dart apps/mobile/test/features/browser apps/mobile/test/app/engine_lab_navigation_test.dart docs/plans/2026-08-21-nexus-engine-abstraction.md
git commit -m "feat: add nexus engine capability foundation"
```

### Task 2: Bind the production Android System WebView adapter

**Files:**
- Modify: `apps/mobile/pubspec.yaml`
- Create: `apps/mobile/lib/features/browser/data/system_webview_adapter.dart`
- Create: `apps/mobile/lib/features/browser/application/browser_controller.dart`
- Create: `apps/mobile/lib/features/browser/presentation/browser_screen.dart`
- Create: `apps/mobile/test/features/browser/system_webview_adapter_test.dart`
- Create: `apps/mobile/test/integration/browser_navigation_fake_test.dart`

**Interfaces:**
- Consumes: `EngineDescriptor`, `EngineSelectionDecision`, Android/iOS WebView plugin APIs pinned after a dedicated dependency review.
- Produces: `BrowserController.open`, `navigate`, `reload`, `goBack`, `goForward`, and `close`; production `SystemWebViewAdapter` capability probe.

- [ ] **Step 1: Add the focused failing test**

Use an adapter fake below the controller boundary. Assert HTTPS navigation succeeds, unsupported schemes are rejected before adapter invocation, back/forward state follows adapter events, a closed context rejects commands, and only System WebView reports `installed` in production builds.

- [ ] **Step 2: Verify the relevant failure**

Run: `cd apps/mobile && flutter test test/features/browser/system_webview_adapter_test.dart test/integration/browser_navigation_fake_test.dart`
Expected: non-zero exit because no production adapter/controller exists.

- [ ] **Step 3: Implement the minimum behavior**

Pin the current supported WebView plugin only after recording license, resolved version, transitive dependencies, Android/iOS minimums, and package-size delta. Bind navigation, lifecycle, progress, renderer failure, permission, popup, download, and console events without enabling arbitrary JavaScript bridges. Keep native sandbox, TLS, SOP, and CORS enforcement inside the platform engine.

- [ ] **Step 4: Verify the focused pass**

Run: the focused command from Step 2.
Expected: all controller and adapter contract tests pass.

- [ ] **Step 5: Run the affected integration check**

Run: `cd apps/mobile && flutter analyze && flutter test && flutter build apk --release && flutter build ios --release --no-codesign`
Expected: zero analyzer/test failures and both production-engine packages compile.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add -- apps/mobile/pubspec.yaml apps/mobile/pubspec.lock apps/mobile/lib/features/browser apps/mobile/test/features/browser apps/mobile/test/integration/browser_navigation_fake_test.dart
git commit -m "feat: bind system webview production adapter"
```

### Task 3: Add fail-closed navigation, permissions, popups, and downloads

**Files:**
- Create: `apps/mobile/lib/features/browser/security/navigation_policy.dart`
- Create: `apps/mobile/lib/features/browser/security/origin_permission_policy.dart`
- Create: `apps/mobile/lib/features/browser/security/download_policy.dart`
- Create: `apps/mobile/lib/features/browser/security/popup_policy.dart`
- Test: `apps/mobile/test/features/browser/browser_security_policy_test.dart`

**Interfaces:**
- Consumes: raw navigation URI, redirect chain, origin, requested permission, download metadata, popup gesture metadata.
- Produces: typed `allow`, `ask`, `warn`, or `block` decisions with stable reason codes and redacted audit metadata.

- [ ] **Step 1: Add the focused failing test**

Assert canonical HTTPS/HTTP handling; block `javascript:`, `intent:`, userinfo, malformed hosts, private/loopback destinations unless a separately configured private-network policy exists; distinguish `data:`, `blob:`, `about:`, and `file:` by trusted internal context; reject IDN mixed-script risk; default camera/microphone/location/clipboard/download/popup to `ask` or `block`; and require user gesture plus per-origin rate limits for new windows.

- [ ] **Step 2: Verify the relevant failure**

Run: `cd apps/mobile && flutter test test/features/browser/browser_security_policy_test.dart`
Expected: non-zero exit because the policy modules are absent.

- [ ] **Step 3: Implement the minimum behavior**

Normalize with `Uri`, preserve the original only in memory, redact sensitive URL components from logs, and return typed decisions. Do not claim local parsing replaces server reputation, DNS resolution, Safe Browsing/Web Risk, Android permission enforcement, or engine sandboxing. Downloads require HTTPS, explicit confirmation, size/MIME/extension consistency checks, quarantine metadata, and never auto-execute.

- [ ] **Step 4: Verify the focused pass**

Run: the focused command from Step 2.
Expected: every allow/warn/block case and audit-redaction assertion passes.

- [ ] **Step 5: Run the affected integration check**

Run: `cd apps/mobile && flutter test test/features/browser test/integration/browser_navigation_fake_test.dart`
Expected: unsafe requests never reach the adapter fake; accepted navigation preserves the canonical URI.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add -- apps/mobile/lib/features/browser/security apps/mobile/test/features/browser
git commit -m "security: add browser navigation policy"
```

### Task 4: Add MV3/WebExtension package validation without executing extensions

**Files:**
- Create: `packages/extension_schema/manifest-v3.schema.json`
- Create: `apps/mobile/lib/features/extensions/domain/browser_extension.dart`
- Create: `apps/mobile/lib/features/extensions/application/extension_scanner.dart`
- Create: `apps/mobile/test/features/extensions/browser_extension_policy_test.dart`
- Create: `tests/contract/extension_schema_policy.sh`
- Modify: `Makefile`
- Modify: `.github/workflows/bootstrap.yml`

**Interfaces:**
- Consumes: unpacked local extension manifest, file inventory, content hashes, requested permissions, host patterns, service-worker declaration.
- Produces: deterministic scan findings and `allow|warn|block`; it does not execute extension code.

- [ ] **Step 1: Add the focused failing test**

Assert MV3 service workers are accepted only from package-local files; remote JavaScript/WASM, `eval`, missing hashes, wildcard hosts plus sensitive permissions, path traversal, native messaging, and unknown privileged APIs are blocked. Unsupported APIs remain explicitly unsupported instead of being simulated.

- [ ] **Step 2: Verify the relevant failure**

Run: `make extension-schema-test`
Expected: non-zero exit because the schema/scanner and Make target do not exist.

- [ ] **Step 3: Implement the minimum behavior**

Validate schemas and archive paths before scanning code references. Separate static-analysis findings from runtime guarantees. Keep the runtime disabled until a later engine-specific sandbox and permission broker passes its own tests.

- [ ] **Step 4: Verify the focused pass**

Run: `make extension-schema-test`
Expected: schema fixtures and Dart policy tests pass.

- [ ] **Step 5: Run the affected integration check**

Run: `make package-schema-test extension-schema-test task9-security-test`
Expected: all package, extension, and secret/security policies pass.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add -- packages/extension_schema apps/mobile/lib/features/extensions apps/mobile/test/features/extensions tests/contract/extension_schema_policy.sh Makefile .github/workflows/bootstrap.yml
git commit -m "feat: add mv3 extension validation"
```

### Task 5: Establish the Engine Benchmark Lab and optional-module admission gate

**Files:**
- Create: `benchmarks/engines/workloads.json`
- Create: `benchmarks/engines/README.md`
- Create: `tests/contract/engine_admission_policy.sh`
- Create: `docs/adr/engine-admission-template.md`
- Modify: `Makefile`
- Modify: `.github/workflows/bootstrap.yml`

**Interfaces:**
- Consumes: immutable engine/version/build identifiers and equivalent local workloads.
- Produces: signed benchmark metadata for startup, memory, CPU, frame timing, page compatibility, crashes, bridge latency, battery proxy, APK/AAB size, license, ABI, and security findings.

- [ ] **Step 1: Add the focused failing test**

Assert an engine admission record is rejected when any required metric, workload hash, license, ABI, source revision, security result, or package-size delta is absent; reject records that claim a winner without comparable workloads.

- [ ] **Step 2: Verify the relevant failure**

Run: `make engine-admission-test`
Expected: non-zero exit because no admission schema/policy exists.

- [ ] **Step 3: Implement the minimum behavior**

Define stable local workloads and evidence fields without synthetic benchmark numbers. Servo may enter only an experimental build flavor; Ultralight requires explicit license/platform approval; Lynx may enter only a specialized native-UI experiment. Stylo/WebRender never receive independent adapter entries.

- [ ] **Step 4: Verify the focused pass**

Run: `make engine-admission-test`
Expected: complete fixtures pass and missing/incomparable evidence fixtures fail.

- [ ] **Step 5: Run the affected integration check**

Run: `make workflow-policy-test engine-admission-test && git grep -nE 'servo|ultralight|lynx' -- apps/mobile/pubspec.yaml Cargo.toml`
Expected: policy tests pass and production manifests contain no experimental runtime dependency.

- [ ] **Step 6: Commit the passing deliverable**

```bash
git add -- benchmarks/engines tests/contract/engine_admission_policy.sh docs/adr/engine-admission-template.md Makefile .github/workflows/bootstrap.yml
git commit -m "test: add engine admission evidence gate"
```

## Unresolved externally observable decisions

- Whether browser navigation becomes a new primary bottom-navigation destination or remains under `More`; recommendation: keep it under `More` until Task 2 proves stable production navigation.
- Which reputation provider is used for phishing/malware checks and which privacy mode applies; no provider is selected by this plan.
- Whether production supports plain HTTP with a warning or blocks it globally; Task 3 keeps this as a policy input rather than hard-coding a product promise.
- Whether private-network browsing is supported; default remains blocked until an administrator-controlled network policy exists.
