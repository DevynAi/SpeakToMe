import Foundation

enum SafetyCopy {
    static let approvedEncouragement = [
        "Nice try!",
        "Let's try together.",
        "Watch my mouth.",
        "Your voice made magic.",
        "Let's sing it.",
        "Help me move it.",
        "You did it."
    ]

    static let forbidden = ["wrong", "failed", "bad", "try harder"]

    static func safe(_ text: String) -> String {
        let lowered = text.lowercased()
        if forbidden.contains(where: { lowered.contains($0) }) {
            return "Nice try! Let's do it together."
        }
        return text
    }
}
