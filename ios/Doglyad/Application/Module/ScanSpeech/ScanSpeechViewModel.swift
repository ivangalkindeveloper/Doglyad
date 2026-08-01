import Combine
import DoglyadNeuralModel
import DoglyadSpeech
import DoglyadUI
import SwiftUI

@MainActor
final class ScanSpeechViewModel: DViewModel {
    private let container: DependencyContainer
    private let messager: DMessager
    private let router: DRouter
    private let arguments: ScanSpeechBottomSheetArguments

    // The controller implementation is chosen by the factory based on system
    // support and locale, so it is held as an existential. `NestedObservableObject`
    // requires a concrete type, so changes are re-published manually through
    // `objectWillChange`.
    //
    // Picking the best implementation is asynchronous (locale support in
    // `SpeechTranscriber` is read via `await`), so we start with the synchronous
    // `SFSpeechRecognizer` and upgrade to `SpeechAnalyzer` if system and locale allow.
    private(set) var speechController: any DSpeechControllerProtocol
    private var speechCancellable: AnyCancellable?

    init(
        container: DependencyContainer,
        messager: DMessager,
        router: DRouter,
        arguments: ScanSpeechBottomSheetArguments
    ) {
        self.container = container
        self.messager = messager
        self.router = router
        self.arguments = arguments
        let contextualStrings = container.getContextualStrings(for: Locale.current)
        speechController = DSpeechFactory.makeDefault(
            locale: Locale.current,
            contextualStrings: contextualStrings
        )
        super.init()
        observeSpeechController()

        Task { [weak self] in
            let controller = await DSpeechFactory.make(
                locale: Locale.current,
                contextualStrings: contextualStrings
            )
            guard let self else { return }
            // Do not swap while recording, and only when the implementation actually
            // changed (otherwise the factory returned the same `SFSpeechRecognizer`).
            guard self.speechController.status == .stopped,
                  type(of: controller) != type(of: self.speechController) else { return }

            self.objectWillChange.send()
            self.speechController = controller
            self.observeSpeechController()
        }
    }

    private func observeSpeechController() {
        speechCancellable = speechController.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    @Published var isLoading = false
    let columns = [GridItem(.adaptive(minimum: 100))]

    func onTapBack() {
        router.dismissSheet()
    }

    var speechIcon: ImageResource {
        switch speechController.status {
        case .preparing,
             .recording:
            return .check
        case .stopped:
            return .play
        @unknown default:
            fatalError()
        }
    }

    /// Spinner on the button: both while the recognition session is starting up and
    /// while the dictation is being parsed — there is nothing to tap in either case.
    var isSpeechButtonLoading: Bool {
        guard !isLoading else { return true }

        switch speechController.status {
        case .preparing:
            return true
        case .recording,
             .stopped:
            return false
        @unknown default:
            fatalError()
        }
    }

    var isAudioMeterVisible: Bool {
        switch speechController.status {
        case .recording:
            return true
        case .preparing,
             .stopped:
            return false
        @unknown default:
            fatalError()
        }
    }

    /// While the session starts up (on the new speech stack a language model may
    /// still be downloading) the microphone is not recording yet — ask the physician
    /// to wait rather than dictate.
    var isPreparingDescriptionVisible: Bool {
        switch speechController.status {
        case .preparing:
            return true
        case .recording,
             .stopped:
            return false
        @unknown default:
            fatalError()
        }
    }

    var speechText: String? {
        isAudioMeterVisible ? speechController.text : nil
    }

    /// A separate flag for the transcript appearance animation. Binding the animation
    /// to the string itself is not an option: draft results arrive several times per
    /// second, and the whole sheet would replay the animation on every word.
    var isSpeechTextVisible: Bool {
        speechText != nil
    }

    var audioMeterLevel: Float {
        speechController.audioMeter
    }

    func onTapSpeech() {
        guard !isLoading else { return }

        switch speechController.status {
        case .preparing:
            // The session is still starting up — there is nothing to stop.
            return
        case .recording:
            onStopSpeech()
        case .stopped:
            speechController.start()
            // The parsing model weighs hundreds of megabytes and loads lazily. While the
            // physician dictates there is time to bring it up and warm it in the
            // background — otherwise they wait for the load after they finish speaking.
            container.examinationNeuralModelFactory?.prewarm()
        @unknown default:
            fatalError()
        }
    }

    private func onStopSpeech() {
        isLoading = true

        Task { [weak self] in
            guard let self else { return }
            // The tail of the dictation is recognized asynchronously after the microphone
            // stops, so the final text is taken from `stop()` rather than from `text`
            // right after it — otherwise the last phrase is lost.
            let speech = await self.speechController.stop()

            guard let speech, !speech.isEmpty,
                  self.container.examinationNeuralModelFactory != nil
            else {
                self.isLoading = false
                return
            }

            self.onParseSpeech(speech: speech)
        }
    }

    private func onParseSpeech(
        speech: String
    ) {
        guard let factory = container.examinationNeuralModelFactory else { return }

        handle {
            // The first parse additionally waits for the model to load — it is lazy.
            try await factory.model().parseSpeech(
                speech: speech
            )
        } onDefer: {
            self.isLoading = false
        } onMainSuccess: { response in
            self.arguments.onComplete?(response)
            self.router.dismissSheet()
        } onUnknownError: { _ in
            self.messager.showUnknownError()
        }
    }
}
