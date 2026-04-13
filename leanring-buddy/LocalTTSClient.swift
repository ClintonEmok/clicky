//
//  LocalTTSClient.swift
//  leanring-buddy
//
//  Uses macOS built-in AVSpeechSynthesizer for local text-to-speech.
//  Provides a drop-in replacement interface compatible with ElevenLabsTTSClient.
//

import AVFoundation
import Foundation

final class LocalTTSClient: NSObject {
    private let synthesizer = AVSpeechSynthesizer()
    private var completionHandler: (() -> Void)?

    override init() {
        super.init()
    }

    /// Speaks the given text using macOS built-in speech synthesis.
    /// Throws only on catastrophic setup failures (not on speech errors).
    func speakText(_ text: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let utterance = AVSpeechUtterance(string: text)
            // Use a default voice — could be made configurable later
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            utterance.pitchMultiplier = 1.0

            // Store completion handler for delegate callback
            completionHandler = {
                continuation.resume()
            }

            synthesizer.delegate = self
            synthesizer.speak(utterance)
        }
    }

    /// Whether speech synthesis is currently in progress.
    var isPlaying: Bool {
        synthesizer.isSpeaking
    }

    /// Stops any in-progress speech immediately.
    func stopPlayback() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}

extension LocalTTSClient: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        completionHandler?()
        completionHandler = nil
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        completionHandler?()
        completionHandler = nil
    }
}
