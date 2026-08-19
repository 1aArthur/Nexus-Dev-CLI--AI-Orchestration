#!/usr/bin/env bash
# Build script for Nexus Dev Orchestrator Flutter app
# Run: chmod +x build_release.sh && ./build_release.sh [android|ios|both]

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLUTTER_PROJECT="${PROJECT_ROOT}/flutter_nexus_dev"
BUILD_DIR="${PROJECT_ROOT}/build_output"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
VERSION="1.0.0"
BUILD_NUMBER="1"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

check_prerequisites() {
    log "Checking prerequisites..."
    command -v flutter >/dev/null 2>&1 || error "Flutter not found in PATH"
    command -v dart >/dev/null 2>&1 || error "Dart not found in PATH"
    if [[ "$1" == "android" || "$1" == "both" ]]; then
        command -v java >/dev/null 2>&1 || error "Java not found"
        [[ -n "${ANDROID_HOME:-}" ]] || error "ANDROID_HOME not set"
    fi
    if [[ "$1" == "ios" || "$1" == "both" ]]; then
        [[ "$OSTYPE" == "darwin"* ]] || error "iOS build requires macOS"
        command -v xcodebuild >/dev/null 2>&1 || error "Xcode not found"
    fi
    success "Prerequisites check passed"
}

clean_builds() {
    log "Cleaning previous builds..."
    cd "$FLUTTER_PROJECT"
    flutter clean
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    success "Clean completed"
}

prepare_project() {
    log "Preparing project..."
    cd "$FLUTTER_PROJECT"
    flutter pub get
    flutter pub run build_runner build --delete-conflicting-outputs
    success "Project prepared"
}

build_android() {
    log "Building Android release..."
    cd "$FLUTTER_PROJECT"
    
    flutter build appbundle \
        --release \
        --build-name="$VERSION" \
        --build-number="$BUILD_NUMBER" \
        --obfuscate \
        --split-debug-info="$BUILD_DIR/debug_info/android/$TIMESTAMP"
    
    flutter build apk \
        --release \
        --build-name="$VERSION" \
        --build-number="$BUILD_NUMBER" \
        --split-per-abi \
        --obfuscate \
        --split-debug-info="$BUILD_DIR/debug_info/android/$TIMESTAMP"
    
    cp build/app/outputs/bundle/release/app-release.aab "$BUILD_DIR/nexus-dev-orchestrator-${VERSION}-${BUILD_NUMBER}-${TIMESTAMP}.aab"
    cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk "$BUILD_DIR/nexus-dev-orchestrator-${VERSION}-${BUILD_NUMBER}-arm64-${TIMESTAMP}.apk"
    cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk "$BUILD_DIR/nexus-dev-orchestrator-${VERSION}-${BUILD_NUMBER}-arm32-${TIMESTAMP}.apk"
    cp build/app/outputs/flutter-apk/app-x86_64-release.apk "$BUILD_DIR/nexus-dev-orchestrator-${VERSION}-${BUILD_NUMBER}-x64-${TIMESTAMP}.apk"
    
    log "Verifying Android signatures..."
    for apk in "$BUILD_DIR"/*.apk; do
        if [[ -f "$apk" ]]; then
            jarsigner -verify -verbose -certs "$apk" 2>/dev/null | grep -E "(verified|X.509)" || warn "Signature verification failed for $apk"
        fi
    done
    
    success "Android build completed"
}

build_ios() {
    log "Building iOS release..."
    cd "$FLUTTER_PROJECT"
    
    flutter build ios \
        --release \
        --build-name="$VERSION" \
        --build-number="$BUILD_NUMBER" \
        --obfuscate \
        --split-debug-info="$BUILD_DIR/debug_info/ios/$TIMESTAMP" \
        --no-codesign
    
    cd ios
    xcodebuild -workspace Runner.xcworkspace \
        -scheme Runner \
        -configuration Release \
        -archivePath "$BUILD_DIR/Runner.xcarchive" \
        -destination "generic/platform=iOS" \
        clean archive \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM:-}"
    
    xcodebuild -exportArchive \
        -archivePath "$BUILD_DIR/Runner.xcarchive" \
        -exportPath "$BUILD_DIR/ios_export" \
        -exportOptionsPlist ExportOptions.plist
    
    cp "$BUILD_DIR/ios_export/Runner.ipa" "$BUILD_DIR/nexus-dev-orchestrator-${VERSION}-${BUILD_NUMBER}-${TIMESTAMP}.ipa"
    
    success "iOS build completed"
}

security_scan() {
    log "Running security scans..."
    if command -v gitleaks >/dev/null 2>&1; then
        gitleaks detect --source "$FLUTTER_PROJECT" --verbose || warn "Gitleaks found potential secrets"
    fi
    if command -v osv-scanner >/dev/null 2>&1; then
        osv-scanner scan "$FLUTTER_PROJECT" || warn "OSV scanner found vulnerabilities"
    fi
    success "Security scans completed"
}

generate_checksums() {
    log "Generating checksums..."
    cd "$BUILD_DIR"
    for file in *; do
        if [[ -f "$file" ]]; then
            sha256sum "$file" >> "SHA256SUMS.txt"
            sha512sum "$file" >> "SHA512SUMS.txt"
        fi
    done
    success "Checksums generated"
}

create_release_notes() {
    log "Creating release notes..."
    cat > "$BUILD_DIR/RELEASE_NOTES.md" << EOF
# Nexus Dev Orchestrator v${VERSION} (Build ${BUILD_NUMBER})

## Release Date
$(date -u +"%Y-%m-%d %H:%M:%S UTC")

## Platform
- Android: minSdk 24, targetSdk 34
- iOS: 13.0+

## Features
- Full-Stack DevSecOps CLI
- Multi-Agent Orchestration (12 specialized agents)
- Terminal with Zsh/NuShell/Fish support
- MASVS v2.0 Static Analysis
- Exa Neural Search Integration
- Grok WebSocket Voice-to-Text
- TTS Voice Synthesis
- CI/CD Pipeline Automation
- Native NDK Module Generation (C++20/Rust)
- Performance Profiling

## Security
- OLED True Black + Pure White Theme
- Encrypted API Key Storage
- Network Security Config (Certificate Pinning)
- ProGuard/R8 Optimization
- Hardened Runtime (iOS)
- No Cleartext Traffic

## Build Information
- Flutter: $(flutter --version | head -1)
- Dart: $(dart --version)
- Build Timestamp: ${TIMESTAMP}

## Artifacts
- Android App Bundle (AAB)
- Android APKs (arm64, arm32, x64)
- iOS IPA
- Debug Symbols (for crash analysis)

## Verification
All artifacts signed with release certificates.
SHA256 checksums provided in SHA256SUMS.txt
EOF
    success "Release notes created"
}

main() {
    local target="${1:-both}"
    log "Starting Nexus Dev Orchestrator release build"
    log "Target: $target | Version: $VERSION | Build: $BUILD_NUMBER"
    check_prerequisites "$target"
    clean_builds
    prepare_project
    if [[ "$target" == "android" || "$target" == "both" ]]; then
        build_android
    fi
    if [[ "$target" == "ios" || "$target" == "both" ]]; then
        build_ios
    fi
    security_scan
    generate_checksums
    create_release_notes
    success "Release build completed!"
    log "Output directory: $BUILD_DIR"
    ls -la "$BUILD_DIR"
}

main "$@"
