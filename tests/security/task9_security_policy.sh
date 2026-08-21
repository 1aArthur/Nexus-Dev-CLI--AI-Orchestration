#!/usr/bin/env bash
set -euo pipefail

provider_root=apps/mobile/lib/features/providers
usage_root=apps/mobile/lib/features/usage
settings_root=apps/mobile/lib/features/settings
controller="$provider_root/application/provider_controller.dart"
workflow_root=.github/workflows

for path in "$provider_root" "$usage_root" "$settings_root" "$controller" "$workflow_root"; do
  test -e "$path"
done

fail_on_match() {
  local description=$1
  local pattern=$2
  shift 2
  if grep -ERn -- "$pattern" "$@"; then
    printf 'Task 9 security policy failed: %s\n' "$description" >&2
    exit 1
  fi
}

# Provider credentials cross one abstract write-only port. The mobile feature
# must not gain direct sockets, HTTP clients, process access, or local storage.
fail_on_match \
  'provider/settings code cannot perform direct network or persistence access' \
  "dart:io|package:http|shared_preferences|flutter_secure_storage|sqflite|drift" \
  "$provider_root" "$settings_root"

grep -Fq "endpoint.scheme != 'https'" "$controller"
grep -Fq 'Credentials in endpoint URLs are forbidden.' "$controller"
grep -Fq 'credential: [REDACTED]' "$controller"
grep -Fq 'ProviderCredentialWriter' "$controller"

# Keep signing material and recognizable live provider tokens out of product
# source, native services, package schemas, build templates, and workflows.
secret_roots=(apps/mobile/lib crates services packages tool .github)
fail_on_match \
  'private key material is forbidden in tracked product sources' \
  '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----' \
  "${secret_roots[@]}"
fail_on_match \
  'recognizable live provider tokens are forbidden in tracked product sources' \
  '(sk|xai)-[A-Za-z0-9_-]{20,}' \
  "${secret_roots[@]}"

# Every third-party workflow action is immutable so a mutable tag cannot alter
# release or security behavior after review.
while IFS= read -r use_line; do
  action_ref=${use_line##*@}
  if [[ ! "$action_ref" =~ ^[0-9a-f]{40}$ ]]; then
    printf 'Task 9 security policy failed: unpinned workflow action: %s\n' \
      "$use_line" >&2
    exit 1
  fi
done < <(grep -ERh '^[[:space:]]*uses:[[:space:]]*[^[:space:]]+@' "$workflow_root")

printf 'Task 9 security policy passed.\n'
