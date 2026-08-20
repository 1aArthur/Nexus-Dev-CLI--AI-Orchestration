#![doc = "Bounded native primitives for the Nexus mobile client."]

/// Confirms that the native workspace can be linked before feature APIs land.
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
