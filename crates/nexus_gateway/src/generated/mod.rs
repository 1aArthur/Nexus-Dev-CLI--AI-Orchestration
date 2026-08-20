// Generated from packages/api_schema.
// schema-digest: 7b8d22ddd8c3d1e81cd42252c70c9e9472bf2d7ee290c548cbeba89fcd296a61
// Do not add business logic to this file.

use std::collections::BTreeMap;

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum MissionStatus {
    Draft,
    Queued,
    Running,
    AwaitingApproval,
    Succeeded,
    Failed,
    Cancelled,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum ExecutionTargetKind {
    Device,
    GithubActions,
    Codespaces,
    SshWorker,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum ExecutionTargetStatus {
    Available,
    Unavailable,
    RequiresAuth,
    Disabled,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum ApprovalMode {
    AlwaysAsk,
    Policy,
    NeverForSafeNative,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum UsageProvenance {
    ProviderReported,
    Estimated,
    Adjusted,
}

#[derive(Clone, Debug, Eq, PartialEq, Ord, PartialOrd)]
pub enum UniversalReasoningLevel {
    Fast,
    Balanced,
    Deep,
    Max,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum UnsupportedReasoningPolicy {
    Reject,
    Clamp,
    Omit,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum ProviderKind {
    OpenAi,
    Anthropic,
    Xai,
    OpenAiCompatible,
    AnthropicCompatible,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum ProviderParameterValue {
    String(String),
    Integer(i64),
    Number(String),
    Boolean(bool),
    Null,
}

pub type Extensions = BTreeMap<String, ProviderParameterValue>;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct MissionDto {
    pub id: String,
    pub owner_id: String,
    pub title: String,
    pub status: MissionStatus,
    pub created_at: String,
    pub updated_at: String,
    pub last_event_sequence: u64,
    pub budget_limit_micros: Option<u64>,
    pub concurrency_limit: Option<u16>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct MissionEventDto {
    pub event_id: String,
    pub mission_id: String,
    pub sequence: u64,
    pub trace_id: String,
    pub event_type: String,
    pub occurred_at: String,
    pub payload: Extensions,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ExecutionTargetDto {
    pub id: String,
    pub display_name: String,
    pub kind: ExecutionTargetKind,
    pub status: ExecutionTargetStatus,
    pub capabilities: Vec<String>,
    pub approval_mode: ApprovalMode,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct UsageRecordDto {
    pub id: String,
    pub mission_id: String,
    pub provider: String,
    pub exact_model_id: String,
    pub input_tokens: u64,
    pub output_tokens: u64,
    pub cached_input_tokens: Option<u64>,
    pub cost_micros: u64,
    pub currency: String,
    pub provenance: UsageProvenance,
    pub recorded_at: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ReasoningCapabilityDto {
    pub supported_universal_levels: Vec<UniversalReasoningLevel>,
    pub provider_parameters: BTreeMap<UniversalReasoningLevel, Extensions>,
    pub unsupported_policy: UnsupportedReasoningPolicy,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ModelCapabilityDto {
    pub exact_model_id: String,
    pub provider: ProviderKind,
    pub supports_streaming: bool,
    pub context_window_tokens: Option<u64>,
    pub reasoning: ReasoningCapabilityDto,
    pub extensions: Extensions,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ApiErrorDto {
    pub code: String,
    pub message: String,
    pub trace_id: String,
    pub retryable: bool,
    pub details: Extensions,
}
