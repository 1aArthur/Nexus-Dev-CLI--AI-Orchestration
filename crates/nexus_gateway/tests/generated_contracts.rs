use std::collections::BTreeMap;

use nexus_gateway::generated::{
    ModelCapabilityDto, ProviderKind, ProviderParameterValue, ReasoningCapabilityDto,
    UniversalReasoningLevel, UnsupportedReasoningPolicy,
};

#[test]
fn exact_model_mapping_preserves_typed_provider_parameters() {
    let low = BTreeMap::from([(
        String::from("effort"),
        ProviderParameterValue::String(String::from("low")),
    )]);
    let capability = ModelCapabilityDto {
        exact_model_id: String::from("provider/model-version"),
        provider: ProviderKind::OpenAiCompatible,
        supports_streaming: true,
        context_window_tokens: Some(128_000),
        reasoning: ReasoningCapabilityDto {
            supported_universal_levels: vec![UniversalReasoningLevel::Fast],
            provider_parameters: BTreeMap::from([(UniversalReasoningLevel::Fast, low)]),
            unsupported_policy: UnsupportedReasoningPolicy::Reject,
        },
        extensions: BTreeMap::new(),
    };

    assert_eq!(capability.exact_model_id, "provider/model-version");
    assert_eq!(capability.reasoning.provider_parameters.len(), 1);
}
