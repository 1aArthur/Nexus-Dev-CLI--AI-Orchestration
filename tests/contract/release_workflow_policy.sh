#!/usr/bin/env bash
set -euo pipefail

require_text() {
  local expected=$1
  local file=$2
  grep -Fq "$expected" "$file" || {
    printf 'missing required release contract in %s: %s\n' "$file" "$expected" >&2
    return 1
  }
}

android=.github/workflows/release-android.yml
ios=.github/workflows/release-ios.yml
smoke=.github/workflows/mobile-build-smoke.yml

test -f "$android"
test -f "$ios"
test -f "$smoke"

for workflow in "$android" "$ios"; do
  grep -Fq "refs/tags/v" "$workflow"
  grep -Fq "environment:" "$workflow"
  grep -Fq "Validate signing inputs" "$workflow"
  grep -Fq "trap cleanup EXIT" "$workflow"
  if grep -Eq '^  pull_request:' "$workflow"; then
    echo "release workflows must never receive pull-request events" >&2
    exit 1
  fi
  if grep -Fq "signingConfig = signingConfigs.getByName(\"debug\")" "$workflow"; then
    echo "debug signing fallback is forbidden" >&2
    exit 1
  fi
done

grep -Fq "ANDROID_KEYSTORE_BASE64" "$android"
grep -Fq "jarsigner -verify" "$android"
grep -Fq "IOS_DISTRIBUTION_P12_BASE64" "$ios"
grep -Fq "codesign --verify" "$ios"

# Branch builds must expose immutable, checksum-protected packages without
# weakening the guarded production signing workflows.
require_text "flutter build appbundle --release" "$smoke"
require_text "flutter build apk --release" "$smoke"
require_text "SHA256SUMS-android.txt" "$smoke"
require_text "SHA256SUMS-ios.txt" "$smoke"
test "$(grep -Fc "actions/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a" "$smoke")" -eq 2
test "$(grep -Fc "if-no-files-found: error" "$smoke")" -eq 2
test "$(grep -Fc "retention-days: 30" "$smoke")" -eq 2
