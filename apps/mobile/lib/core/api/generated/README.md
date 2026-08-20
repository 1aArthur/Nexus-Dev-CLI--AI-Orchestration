# Generated API contracts

`contracts.dart` is a dependency-free bootstrap projection of the schemas in `packages/api_schema`. It keeps wire names explicit, rejects unknown enum values, stores timestamps as UTC `DateTime`, and permits provider-native data only in the documented `extensions` and reasoning parameter maps.

Run `make schema-generate` after changing any source schema. CI rejects generated files whose embedded schema digest does not match the source contracts.
