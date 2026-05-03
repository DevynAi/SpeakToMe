import SwiftUI

struct LetterJungleView: View {
    var body: some View {
        ActivityGameView(
            worldTitle: "Letter Jungle",
            categoryHint: "Alphabet",
            mascot: "🦜",
            draggableEmoji: "🔤"
        )
    }
}
