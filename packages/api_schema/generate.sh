#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repository_root"

schema_files=(
  packages/api_schema/openapi.yaml
  packages/api_schema/events.schema.json
  packages/api_schema/model-capabilities.schema.json
  packages/api_schema/execution-targets.schema.json
)
generated_files=(
  apps/mobile/lib/core/api/generated/contracts.dart
  crates/nexus_gateway/src/generated/mod.rs
)

for schema in "${schema_files[@]:1}"; do
  python3 -m json.tool "$schema" >/dev/null
done

python3 - <<'PY'
from pathlib import Path

document = Path("packages/api_schema/openapi.yaml").read_text(encoding="utf-8")
assert document.startswith("openapi: 3.1.0\n")
assert "jsonSchemaDialect: https://json-schema.org/draft/2020-12/schema" in document
PY

schema_digest="$({ sha256sum "${schema_files[@]}"; } | sha256sum | cut -d ' ' -f1)"
for generated in "${generated_files[@]}"; do
  grep -Fq "schema-digest: $schema_digest" "$generated"
done

echo "Schema contracts and generated projections match $schema_digest"
