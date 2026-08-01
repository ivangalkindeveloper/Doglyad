public enum DRecordingStatus {
    /// The session is starting up: the audio session is being configured and, on the
    /// new speech stack, the language model may still be downloading on first launch.
    /// The microphone is not recording yet, so the screen must ask the user to wait
    /// rather than show an active recording.
    case preparing
    case recording
    case stopped
}
