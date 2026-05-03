import SwiftUI

struct AnimalBandView: View {
    var body: some View {
        ActivityGameView(
            worldTitle: "Animal Band",
            categoryHint: "Songs",
            mascot: "🐘",
            draggableEmoji: "🥁"
        )
    }
}
