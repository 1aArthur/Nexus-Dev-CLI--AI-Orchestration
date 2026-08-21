#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
import json
from pathlib import Path

schema_paths = {
    "theme": Path("packages/theme_pack_schema/theme-pack.schema.json"),
    "pet": Path("packages/pet_pack_schema/pet-pack.schema.json"),
    "skill": Path("packages/skill_schema/skill.schema.json"),
}

schemas = {
    name: json.loads(path.read_text(encoding="utf-8"))
    for name, path in schema_paths.items()
}

for name, schema in schemas.items():
    assert schema["$schema"] == "https://json-schema.org/draft/2020-12/schema", name
    assert schema["type"] == "object", name
    assert schema["additionalProperties"] is False, name
    required = set(schema["required"])
    assert {"schemaVersion", "id", "name", "version", "license", "signature"} <= required, name

theme = schemas["theme"]
video = theme["$defs"]["mediaAsset"]["oneOf"][1]["allOf"][1]
video_properties = video["properties"]
assert video_properties["mimeType"]["const"] == "video/mp4"
assert video_properties["durationSeconds"]["maximum"] == 30
assert video_properties["muted"]["const"] is True
assert "posterPath" in video["required"]
assert theme["properties"]["sync"]["properties"]["enabled"]["const"] is True

pet = schemas["pet"]
assert pet["properties"]["authorizedSource"]["const"] is True
assert pet["properties"]["spriteSheet"]["properties"]["frames"]["maximum"] == 2048
assert pet["properties"]["animations"]["items"]["properties"]["fps"]["maximum"] == 30

skill = schemas["skill"]
assert skill["properties"]["runtime"]["const"] == "declarative"
assert skill["properties"]["entryDocument"]["const"] == "SKILL.md"
assert "executable" not in json.dumps(skill).lower()
assert "permissions" in skill["required"]
assert "contentHashes" in skill["required"]

print("Theme, Pet Pack, and declarative Skill schema policies passed")
PY
