#!/usr/bin/env bash
set -euo pipefail

android=.github/workflows/release-android.yml
ios=.github/workflows/release-ios.yml

test -f "$android"
test -f "$ios"

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
