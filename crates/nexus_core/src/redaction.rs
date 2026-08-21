const REDACTED: &str = "[REDACTED]";

#[must_use]
pub fn redact_diagnostics(input: &str) -> String {
    input
        .lines()
        .map(redact_line)
        .collect::<Vec<_>>()
        .join("\n")
}

fn redact_line(line: &str) -> String {
    let lowercase = line.to_ascii_lowercase();
    if lowercase.starts_with("authorization:") {
        return format!("Authorization: {REDACTED}");
    }
    if let Some((key, _)) = line.split_once('=') {
        let normalized = key.trim().to_ascii_uppercase();
        if ["_KEY", "_TOKEN", "_SECRET", "_PASSWORD"]
            .iter()
            .any(|suffix| normalized.ends_with(suffix))
        {
            return format!("{key}={REDACTED}");
        }
    }
    line.to_owned()
}
