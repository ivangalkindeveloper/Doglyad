import Combine
import Foundation

/// A speech-to-text controller.
///
/// An observable object: the scanning screen subscribes to `status`, `text` and
/// `audioMeter` to reflect the progress of dictation. The concrete implementation is
/// chosen by ``DSpeechFactory`` based on system support and locale support.
///
/// Requiring `ObjectWillChangePublisher == ObservableObjectPublisher` lets a consumer
/// subscribe to `objectWillChange` through the `any DSpeechControllerProtocol`
/// existential without knowing the concrete type.
@MainActor
public protocol DSpeechControllerProtocol: ObservableObject
    where ObjectWillChangePublisher == ObservableObjectPublisher
{
    init(
        locale: Locale,
        contextualStrings: [String]
    )

    var status: DRecordingStatus { get }
    var text: String? { get }
    var audioMeter: Float { get }

    func start()

    /// Stops recording and waits for the final recognition result.
    ///
    /// Returns the final text: reading `text` right after the call is not enough —
    /// the tail of the dictation is recognized asynchronously after the microphone
    /// stops, and the last phrase of the examination would otherwise be lost.
    @discardableResult
    func stop() async -> String?
}
