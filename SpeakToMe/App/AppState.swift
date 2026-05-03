import Foundation
import SwiftUI
import SwiftData

@Observable
final class AppState {
    var selectedProfile: ChildProfile?
    var activeSessionId: UUID?
    var showParentArea = false
    var highContrast = false
    var soundEnabled = true

    func beginSession(for child: ChildProfile) {
        selectedProfile = child
        activeSessionId = UUID()
    }

    func endSession() {
        activeSessionId = nil
    }
}

enum WorldArea: String, CaseIterable, Identifiable {
    case homeWorld = "Home World"
    case letterJungle = "Letter Jungle"
    case animalBand = "Animal Band"
    case colorRiver = "Color River"
    case numberTrain = "Number Train"
    case songTreehouse = "Song Treehouse"
    case nameCastle = "Name Castle"
    case phrasePlayground = "Phrase Playground"
    case rewardRoom = "Reward Room"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .homeWorld: return "map.fill"
        case .letterJungle: return "textformat.abc"
        case .animalBand: return "music.note.list"
        case .colorRiver: return "paintpalette.fill"
        case .numberTrain: return "tram.fill"
        case .songTreehouse: return "music.note"
        case .nameCastle: return "building.columns.fill"
        case .phrasePlayground: return "text.bubble.fill"
        case .rewardRoom: return "star.circle.fill"
        }
    }
}