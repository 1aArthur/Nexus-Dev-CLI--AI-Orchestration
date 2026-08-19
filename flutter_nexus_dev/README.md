# Nexus Dev Orchestrator

**Full-Stack DevSecOps CLI with Multi-Agent Orchestration, Terminal, Security Auditing, and Voice Integration**

A production-ready Flutter application for Android and iOS that brings together:
- **12 Specialized AI Agents** for architecture, coding, security, performance, testing, and release
- **Multi-Shell Terminal** (Zsh, NuShell, Fish) with syntax highlighting
- **MASVS v2.0 Static Analysis** with auto-fix capabilities
- **Exa Neural Search** for deep technical intelligence
- **Grok WebSocket Voice-to-Text** + TTS synthesis
- **CI/CD Pipeline Automation** with native NDK module generation

---

## Architecture

```
lib/
├── core/
│   └── theme/              # OLED Black + Pure White theme
├── data/
│   ├── audio/              # TTS + Grok WebSocket voice
│   ├── local/              # Hive local storage
│   ├── repository/         # Data repositories
│   └── security/           # MASVS static analyzer
├── domain/
│   └── models/             # Freezed data models
└── ui/
    ├── components/         # Reusable UI components
    ├── screens/            # Feature screens
    └── viewmodels/         # Riverpod state management
```

---

## Theme

**OLED True Black (#000000) + Pure White (#FFFFFF) Only**

- No grays, no colors except minimal status indicators
- JetBrains Mono font throughout
- High contrast for developer ergonomics
- Battery-friendly on OLED displays

---

## Agents

| Agent | Role | Model |
|-------|------|-------|
| Planner | Task DAG decomposition | gemini-3.1-pro-preview |
| Architect | System design & ADRs | gemini-3.1-pro-preview |
| **Claude Code** | Senior code architect | gemini-3.1-pro-preview |
| **Codex** | Native/JNI/SIMD specialist | gemini-3.1-pro-preview |
| Exa Researcher | Deep web intelligence | gemini-3.5-flash |
| Debug Agent | Log parsing & root cause | gemini-3.1-pro-preview |
| DevSecOps Sentinel | SAST/DAST/MASVS | gemini-3.1-pro-preview |
| Performance Agent | Profiling & optimization | gemini-3.5-flash |
| Test Agent | Unit/Integration/E2E | gemini-3.5-flash |
| Reviewer Agent | Diff analysis & standards | gemini-3.1-pro-preview |
| Release Agent | Changelog & deployment | gemini-3.5-flash |
| Native NDK Engineer | C++20/Rust/JNI/CMake | gemini-3.5-flash |

---

## Screens

1. **Dashboard** - System status, metrics, real-time activity, resource gauges
2. **Agent Monitor** - Live agent status, thoughts, progress, autopilot
3. **Terminal** - Multi-shell CLI with nx commands, syntax highlighting
4. **Security Center** - MASVS scan results, code editor, vulnerability cards
5. **Exa Search** - Neural web search with scored results
6. **Workflows** - Orchestration history, quick actions
7. **CI/CD** - Pipeline stages, performance profile, native modules
8. **Settings** - API keys, voice config, terminal, appearance

---

## Security

- **Encrypted API Keys** via Flutter Secure Storage
- **Network Security Config** with certificate pinning
- **No Cleartext Traffic** (HTTPS only)
- **ProGuard/R8** optimization & obfuscation
- **Hardened Runtime** (iOS)
- **Biometric/Auth** for sensitive operations

---

## Getting Started

### Prerequisites

```bash
# Flutter 3.19+
flutter --version

# Android
ANDROID_HOME set, Java 11+

# iOS (macOS only)
Xcode 15+, CocoaPods
```

### Install

```bash
cd flutter_nexus_dev
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Run Debug

```bash
# Android
flutter run

# iOS
flutter run -d ios
```

---

## Release Build

### Android

```bash
# Using build script
./build_release.sh android

# Or manually
flutter build appbundle --release --obfuscate --split-debug-info=build/debug_info
flutter build apk --release --split-per-abi --obfuscate
```

**Outputs:**
- `build_output/nexus-dev-orchestrator-1.0.0-1-{timestamp}.aab` (Play Store)
- `build_output/nexus-dev-orchestrator-1.0.0-1-arm64-{timestamp}.apk`
- `build_output/nexus-dev-orchestrator-1.0.0-1-arm32-{timestamp}.apk`
- `build_output/nexus-dev-orchestrator-1.0.0-1-x64-{timestamp}.apk`

### iOS

```bash
# Using build script (macOS only)
./build_release.sh ios

# Or manually
flutter build ios --release --obfuscate --no-codesign
cd ios && xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release archive
```

**Output:**
- `build_output/nexus-dev-orchestrator-1.0.0-1-{timestamp}.ipa`

### Both Platforms

```bash
./build_release.sh both
```

---

## Signing Configuration

### Android

Set environment variables:

```bash
export KEYSTORE_PATH=/path/to/release.jks
export KEYSTORE_PASSWORD=your_keystore_password
export KEY_ALIAS=release
export KEY_PASSWORD=your_key_password
```

Generate keystore:
```bash
keytool -genkeypair \
    -alias release \
    -keyalg RSA \
    -keysize 4096 \
    -validity 10000 \
    -keystore release.jks
```

### iOS

1. Add Apple Developer Team in Xcode
2. Create App Store provisioning profile
3. Enable Automatic Signing for Release

---

## Voice Integration

### Grok WebSocket (Voice-to-Text)

```dart
final grok = ref.read(grokVoiceServiceProvider);
grok.setApiKey('your-xai-api-key');
await grok.connect();

// Stream transcript
grok.transcriptStream.listen((text) {
    print('Transcript: $text');
});

// Send audio
grok.sendAudioChunk(pcmData);
grok.commitAudio();
```

### TTS (Text-to-Speech)

```dart
final tts = ref.read(ttsServiceProvider);
await tts.initialize();
await tts.speak('Nexus Dev Orchestrator online');
await tts.stop();
```

---

## Terminal Commands

```
nx autopilot [goal]     - Full production pipeline
nx debate [topic]       - Agent debate
nx scan [target]        - Security scan
nx deploy [env]         - CI/CD deploy
nx search [query]       - Exa search
nx voice [text]         - Speak text
nx performance          - Refresh metrics
nx build                - Build project
nx test                 - Run tests
nx lint                 - Run linter
zsh|nushell|fish        - Switch shell
```

---

## Dependencies

| Package | Purpose |
|---------|---------|
| flutter_riverpod | State management |
| go_router | Navigation |
| dio | HTTP client |
| web_socket_channel | Grok WebSocket |
| hive/hive_flutter | Local database |
| flutter_tts | Text-to-speech |
| flutter_animate | Animations |
| freezed/json_serializable | Code generation |
| permission_handler | Mic/permissions |
| crypto | Hashing |
| uuid | Unique IDs |

---

## License

MIT License - See LICENSE file

---

## Links

- **Documentation**: https://nexus.dev/docs
- **API Reference**: https://nexus.dev/api
- **Issues**: https://github.com/nexus/dev-orchestrator/issues
- **Discord**: https://discord.gg/nexus-dev

---

**Built with love for DevSecOps Engineers**
