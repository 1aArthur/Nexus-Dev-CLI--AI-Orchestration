const MAX_CHANGED_LINES: usize = 256;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct DiffSummary {
    pub additions: usize,
    pub deletions: usize,
    pub changed_lines: Vec<String>,
}

#[must_use]
pub fn summarize_diff(input: &str, max_chars_per_line: usize) -> DiffSummary {
    let width = max_chars_per_line.clamp(1, 4096);
    let mut additions = 0;
    let mut deletions = 0;
    let mut changed_lines = Vec::new();

    for line in input.lines() {
        let is_header = line.starts_with("+++") || line.starts_with("---");
        if !is_header && line.starts_with('+') {
            additions += 1;
        } else if !is_header && line.starts_with('-') {
            deletions += 1;
        } else {
            continue;
        }
        if changed_lines.len() < MAX_CHANGED_LINES {
            changed_lines.push(line.chars().take(width).collect());
        }
    }

    DiffSummary {
        additions,
        deletions,
        changed_lines,
    }
}
