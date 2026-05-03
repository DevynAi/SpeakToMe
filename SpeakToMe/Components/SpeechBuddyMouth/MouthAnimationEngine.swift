import Foundation

enum MouthShape: String {
    case closedLips
    case openMouth
    case smileMouth
    case teethOnLip
    case tongueUp
    case tongueBetweenTeeth
    case teethClose
    case roundedLips
    case roundedTensed
    case backSound
}

enum MouthAnimationEngine {
    static func visemes(for text: String) -> [String] {
        let upper = text.uppercased()
        var sequence: [String] = []

        for char in upper {
            switch char {
            case "M", "B", "P": sequence.append("closedLips")
            case "A", "O": sequence.append("openMouth")
            case "E", "I", "Y": sequence.append("smileMouth")
            case "F", "V": sequence.append("teethOnLip")
            case "L", "N", "D", "T": sequence.append("tongueUp")
            case "S", "Z": sequence.append("teethClose")
            case "W", "U": sequence.append("roundedLips")
            case "R": sequence.append("roundedTensed")
            case "K", "G", "Q", "C": sequence.append("backSound")
            case "H": sequence.append("tongueBetweenTeeth")
            default: continue
            }
        }

        return sequence.isEmpty ? ["openMouth"] : sequence
    }

    static func shape(for viseme: String) -> MouthShape {
        MouthShape(rawValue: viseme) ?? .openMouth
    }
}
