use std::{fs, path::PathBuf};

fn contract(name: &str) -> String {
    let root = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .and_then(|path| path.parent())
        .expect("gateway crate must live below the workspace root")
        .to_path_buf();
    let path = root.join("packages/api_schema").join(name);
    fs::read_to_string(&path)
        .unwrap_or_else(|error| panic!("missing schema contract {}: {error}", path.display()))
}

#[test]
fn openapi_contract_contains_shared_security_invariants() {
    let source = contract("openapi.yaml");
    for token in [
        "openapi: 3.1.0",
        "Idempotency-Key",
        "format: uuid",
        "traceId",
        "MissionDto",
        "MissionEventDto",
        "ExecutionTargetDto",
        "UsageRecordDto",
        "ModelCapabilityDto",
        "ApiErrorDto",
    ] {
        assert!(
            source.contains(token),
            "OpenAPI contract is missing {token}"
        );
    }
}

#[test]
fn websocket_and_capability_contracts_are_explicit() {
    let events = contract("events.schema.json");
    for token in [
        "2020-12",
        "eventId",
        "missionId",
        "sequence",
        "traceId",
        "oneOf",
    ] {
        assert!(events.contains(token), "event contract is missing {token}");
    }

    let models = contract("model-capabilities.schema.json");
    for token in ["exactModelId", "providerParameters", "unsupportedPolicy"] {
        assert!(models.contains(token), "model contract is missing {token}");
    }

    let targets = contract("execution-targets.schema.json");
    for token in [
        "device",
        "github_actions",
        "codespaces",
        "ssh_worker",
        "capabilities",
        "approvalMode",
    ] {
        assert!(
            targets.contains(token),
            "target contract is missing {token}"
        );
    }
}
