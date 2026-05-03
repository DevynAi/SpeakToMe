import Foundation

enum PitchParticipationDetector {
    static func detectSinging(voiceEnergy: [Float], minimumFrames: Int = 20) -> Bool {
        guard voiceEnergy.count >= minimumFrames else { return false }
        let activeFrames = voiceEnergy.filter { $0 > 0.02 }
        guard activeFrames.count > minimumFrames / 2 else { return false }

        // Simple rhythm continuity heuristic for V1.
        let variance = activeFrames.reduce(0, +) / Float(activeFrames.count)
        return variance > 0.03
    }
}
