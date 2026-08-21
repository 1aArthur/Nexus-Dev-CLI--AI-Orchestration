use crate::CoreError;

const MAX_PCM_BYTES: usize = 2 * 1024 * 1024;
const MAX_WAVEFORM_POINTS: usize = 4096;

pub fn validate_pcm_s16le(bytes: &[u8], sample_rate_hz: u32) -> Result<(), CoreError> {
    if !(8_000..=48_000).contains(&sample_rate_hz) {
        return Err(CoreError::UnsupportedSampleRate);
    }
    if bytes.is_empty() || bytes.len() % 2 != 0 {
        return Err(CoreError::MalformedPcm);
    }
    if bytes.len() > MAX_PCM_BYTES {
        return Err(CoreError::SizeLimitExceeded);
    }
    Ok(())
}

pub fn downsample_waveform(bytes: &[u8], points: usize) -> Result<Vec<f32>, CoreError> {
    if points == 0 || points > MAX_WAVEFORM_POINTS {
        return Err(CoreError::InvalidLimit);
    }
    if bytes.is_empty() || bytes.len() % 2 != 0 {
        return Err(CoreError::MalformedPcm);
    }
    if bytes.len() > MAX_PCM_BYTES {
        return Err(CoreError::SizeLimitExceeded);
    }

    let samples = bytes
        .chunks_exact(2)
        .map(|pair| i16::from_le_bytes([pair[0], pair[1]]))
        .collect::<Vec<_>>();
    let output_len = points.min(samples.len());
    let chunk_size = samples.len().div_ceil(output_len);
    let mut waveform = Vec::with_capacity(output_len);
    for chunk in samples.chunks(chunk_size).take(output_len) {
        let peak = chunk
            .iter()
            .map(|sample| i32::from(*sample).unsigned_abs())
            .max()
            .unwrap_or(0);
        waveform.push(peak as f32 / 32_768.0);
    }
    Ok(waveform)
}
