# ADR 0001: Mobile SQLite without generated persistence code

## Status

Accepted on 2026-08-20.

## Decision

The mobile read-model cache uses `sqlite3` directly behind `NexusDatabase`. Domain code remains independent of SQLite, and callers can open either an in-memory database for tests or a file path supplied by the platform composition root.

## Rationale

The selected Drift 2.34 toolchain requires an additional generator lifecycle while Nexus already generates API contracts. Direct SQLite keeps the offline boundary small, deterministic, portable to Android/iOS, and testable without weakening the rule that credentials, signing material, raw microphone buffers, and private audit payloads never enter the mobile database.

## Consequences

Schema migrations must be explicit SQL and covered by integration tests. Reactive UI streams will be implemented in repositories above this boundary instead of relying on generated table APIs.
