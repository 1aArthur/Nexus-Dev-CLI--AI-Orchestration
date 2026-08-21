.PHONY: bootstrap format format-check test flutter-test rust-test schema-test package-schema-test schema-generate workflow-policy-test clean

bootstrap:
	cd apps/mobile && flutter pub get
	cargo fetch --locked
	cd services/orchestrator && mix deps.get

format:
	cd apps/mobile && dart format lib test
	cargo fmt --all
	cd services/orchestrator && mix format

format-check:
	cd apps/mobile && dart format --output=none --set-exit-if-changed lib test
	cd apps/mobile && flutter analyze
	cargo fmt --all --check
	cd services/orchestrator && mix format --check-formatted

test: flutter-test rust-test
	cd services/orchestrator && mix test

flutter-test:
	cd apps/mobile && flutter test

rust-test:
	cargo test --workspace --locked

schema-test:
	cd apps/mobile && flutter test test/core/api
	cargo test -p nexus_gateway --test schema_contract --locked

package-schema-test:
	bash ./tests/contract/package_schema_policy.sh

schema-generate:
	./packages/api_schema/generate.sh

workflow-policy-test:
	./tests/contract/release_workflow_policy.sh

clean:
	cd apps/mobile && flutter clean
	cargo clean
	cd services/orchestrator && mix clean
