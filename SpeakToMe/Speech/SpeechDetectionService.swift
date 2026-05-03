import Foundation
import AVFoundation
import Speech

@MainActor
final class SpeechDetectionService: ObservableObject {
    @Published var microphoneAuthorized = false
    @Published var speechAuthorized = false
    @Published var latestDetectedText: String?
    @Published var voiceEnergies: [Float] = []

    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
    private var startTime: Date?
    private(set) var vocalizationDetected = false

    func requestPermissions() async {
        let mic = await AVAudioApplication.requestRecordPermission()
        microphoneAuthorized = mic

        let speech = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
        speechAuthorized = speech
    }

    func startListening(sensitivity: Double) {
        guard microphoneAuthorized else { return }

        latestDetectedText = nil
        voiceEnergies.removeAll()
        vocalizationDetected = false
        startTime = Date()

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            guard let self else { return }
            let rms = self.calculateRMS(from: buffer)
            Task { @MainActor in
                self.voiceEnergies.append(rms)
                self.vocalizationDetected = self.vocalizationDetected || rms > Float(sensitivity)
                self.recognitionRequest?.append(buffer)
            }
        }

        prepareRecognitionIfPossible()

        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            _ = stopListening()
        }
    }

    func stopListening() -> (duration: Double, vocalDetected: Bool, detectedText: String?, singingDetected: Bool) {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil

        let duration = Date().timeIntervalSince(startTime ?? .now)
        let singing = PitchParticipationDetector.detectSinging(voiceEnergy: voiceEnergies)
        return (duration, vocalizationDetected, latestDetectedText, singing)
    }

    private func prepareRecognitionIfPossible() {
        guard speechAuthorized, let recognizer, recognizer.isAvailable else {
            recognitionTask?.cancel()
            recognitionTask = nil
            recognitionRequest = nil
            return
        }

        recognitionTask?.cancel()
        recognitionTask = nil

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, _ in
            guard let self else { return }
            Task { @MainActor in
                self.latestDetectedText = result?.bestTranscription.formattedString
            }
        }
    }

    private func calculateRMS(from buffer: AVAudioPCMBuffer) -> Float {
        guard let data = buffer.floatChannelData?[0] else { return 0 }
        let frameLength = Int(buffer.frameLength)
        var sum: Float = 0
        for i in 0..<frameLength {
            let value = data[i]
            sum += value * value
        }
        return sqrt(sum / Float(max(frameLength, 1)))
    }
}
