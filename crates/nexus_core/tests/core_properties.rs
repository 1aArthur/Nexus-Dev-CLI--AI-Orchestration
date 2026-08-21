use nexus_core::{
    CoreError, downsample_waveform, parse_safe_document, redact_diagnostics, sha256_hex,
    summarize_diff, validate_pcm_s16le,
};

#[test]
fn validates_bounded_pcm_and_waveform() {
    let pcm = [0_u8, 0, 255, 127, 0, 128, 0, 0];
    assert!(validate_pcm_s16le(&pcm, 24_000).is_ok());
    assert_eq!(downsample_waveform(&pcm, 2).unwrap().len(), 2);
    assert_eq!(
        validate_pcm_s16le(&[0], 24_000),
        Err(CoreError::MalformedPcm)
    );
    assert_eq!(
        validate_pcm_s16le(&pcm, 1),
        Err(CoreError::UnsupportedSampleRate)
    );
}

#[test]
fn hashes_known_sha256_vector() {
    assert_eq!(
        sha256_hex(b"abc"),
        "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
    );
}

#[test]
fn redacts_authorization_and_secret_assignments() {
    let input = "Authorization: Bearer abc.def\nXAI_API_KEY=secret-value\nstatus=ready";
    let redacted = redact_diagnostics(input);
    assert!(!redacted.contains("abc.def"));
    assert!(!redacted.contains("secret-value"));
    assert!(redacted.contains("status=ready"));
}

#[test]
fn parser_enforces_utf8_size_and_depth_limits() {
    assert!(parse_safe_document(br#"{"ok":[1,2]}"#, 128, 4).is_ok());
    assert_eq!(
        parse_safe_document(&[0xff], 128, 4),
        Err(CoreError::InvalidUtf8),
    );
    assert_eq!(
        parse_safe_document(b"12345", 4, 4),
        Err(CoreError::SizeLimitExceeded),
    );
    assert_eq!(
        parse_safe_document(b"[[[]]]", 128, 2),
        Err(CoreError::DepthLimitExceeded),
    );
}

#[test]
fn diff_summary_is_deterministic_and_ignores_headers() {
    let diff = "--- a/file\n+++ b/file\n line\n-old\n+new\n+second\n";
    let summary = summarize_diff(diff, 64);
    assert_eq!(summary.additions, 2);
    assert_eq!(summary.deletions, 1);
    assert_eq!(summary.changed_lines, vec!["-old", "+new", "+second"]);
}
