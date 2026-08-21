use crate::CoreError;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SafeDocument {
    pub bytes: usize,
    pub lines: usize,
    pub max_depth: usize,
}

pub fn parse_safe_document(
    input: &[u8],
    max_bytes: usize,
    max_depth: usize,
) -> Result<SafeDocument, CoreError> {
    if max_bytes == 0 || max_depth == 0 || max_depth > 128 {
        return Err(CoreError::InvalidLimit);
    }
    if input.len() > max_bytes {
        return Err(CoreError::SizeLimitExceeded);
    }
    let text = std::str::from_utf8(input).map_err(|_| CoreError::InvalidUtf8)?;
    let mut depth = 0_usize;
    let mut observed = 0_usize;
    let mut quoted = false;
    let mut escaped = false;

    for character in text.chars() {
        if quoted {
            if escaped {
                escaped = false;
            } else if character == '\\' {
                escaped = true;
            } else if character == '"' {
                quoted = false;
            }
            continue;
        }
        match character {
            '"' => quoted = true,
            '{' | '[' => {
                depth += 1;
                observed = observed.max(depth);
                if depth > max_depth {
                    return Err(CoreError::DepthLimitExceeded);
                }
            }
            '}' | ']' => {
                depth = depth.checked_sub(1).ok_or(CoreError::MalformedDocument)?;
            }
            _ => {}
        }
    }
    if quoted || escaped || depth != 0 {
        return Err(CoreError::MalformedDocument);
    }
    Ok(SafeDocument {
        bytes: input.len(),
        lines: text.lines().count().max(1),
        max_depth: observed,
    })
}
