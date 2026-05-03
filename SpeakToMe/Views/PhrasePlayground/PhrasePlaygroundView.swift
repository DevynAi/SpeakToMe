import SwiftUI

struct PhrasePlaygroundView: View {
    var body: some View {
        ActivityGameView(
            worldTitle: "Phrase Playground",
            categoryHint: "Simple Phrases",
            mascot: "🛝",
            draggableEmoji: "🧩"
        )
    }
}
