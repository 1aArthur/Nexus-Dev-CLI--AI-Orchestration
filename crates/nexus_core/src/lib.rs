#![doc = "Bounded native primitives for the Nexus mobile client."]

mod audio;
mod diff;
mod hash;
mod parsing;
mod redaction;

pub use audio::{downsample_waveform, validate_pcm_s16le};
pub use diff::{DiffSummary, summarize_diff};
pub use hash::sha256_hex;
pub use parsing::{SafeDocument, parse_safe_document};
pub use redaction::redact_diagnostics;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum CoreError {
    MalformedPcm,
    UnsupportedSampleRate,
    SizeLimitExceeded,
    InvalidUtf8,
    DepthLimitExceeded,
    MalformedDocument,
    InvalidLimit,
}

/// Confirms that the native workspace can be linked.
#[must_use]
pub const fn workspace_ready() -> bool {
    true
}

#[cfg(test)]
mod tests {
    #[test]
    fn workspace_is_ready() {
        assert!(super::workspace_ready());
    }
}
