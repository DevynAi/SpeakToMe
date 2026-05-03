import Foundation

struct DetectionResult {
    let tier: ResponseTier
    let detectedText: String?
    let vocalizationDuration: Double
}

enum ResponseTierClassifier {
    static func classify(
        target: String,
        detectedText: String?,
        vocalizationDetected: Bool,
        vocalDuration: Double,
        singingDetected: Bool
    ) -> DetectionResult {
        guard vocalizationDetected else {
            return DetectionResult(tier: .none, detectedText: detectedText, vocalizationDuration: vocalDuration)
        }

        if singingDetected {
            return DetectionResult(tier: .sung, detectedText: detectedText, vocalizationDuration: vocalDuration)
        }

        guard let text = detectedText?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            return DetectionResult(tier: .vocalization, detectedText: nil, vocalizationDuration: vocalDuration)
        }

        let targetText = target.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if text == targetText {
            if targetText.split(separator: " ").count >= 3 {
                return DetectionResult(tier: .phrase, detectedText: text, vocalizationDuration: vocalDuration)
            }
            return DetectionResult(tier: .word, detectedText: text, vocalizationDuration: vocalDuration)
        }

        if targetText.contains(text) || text.contains(targetText) {
            return DetectionResult(tier: .approximate, detectedText: text, vocalizationDuration: vocalDuration)
        }

        let targetTokens = Set(targetText.split(separator: " "))
        let textTokens = Set(text.split(separator: " "))
        if !targetTokens.intersection(textTokens).isEmpty {
            return DetectionResult(tier: .approximate, detectedText: text, vocalizationDuration: vocalDuration)
        }

        return DetectionResult(tier: .vocalization, detectedText: text, vocalizationDuration: vocalDuration)
    }
}
