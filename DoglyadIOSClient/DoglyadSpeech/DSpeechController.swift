import Foundation
import Combine
import Speech
import AVFoundation

@MainActor
public final class DSpeechController: ObservableObject {
    private let audioSession = AVAudioSession.sharedInstance()
    private let speechRecognizer: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    @Published public var isRecording = false
    @Published public var text: String? = nil
    @Published public var audioMeter: Float = 0.0
    
    public init(
        locale: Locale
    ) {
        self.speechRecognizer = SFSpeechRecognizer(locale: locale)
    }
    
    public func start() -> Void {
        guard !audioEngine.isRunning else { return }
        
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
            self.updateAudioMeter(buffer)
        }
        
        guard let recognizer = speechRecognizer, recognizer.isAvailable else { return }
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.text = result.bestTranscription.formattedString
                }
            }
            
            if error != nil || (result?.isFinal ?? false) {
                self.stop()
            }
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        isRecording = true
    }
    
    public func stop() -> Void {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        isRecording = false
    }
    
    
    private func updateAudioMeter(
        _ buffer: AVAudioPCMBuffer
    ) -> Void {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let channelDataArray = Array(UnsafeBufferPointer(
            start: channelData,
            count: Int(buffer.frameLength))
        )

        let rms = sqrt(channelDataArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let level = rms * 15

        DispatchQueue.main.async {
            self.audioMeter = min(max(level, 0), 1)
        }
    }
}
