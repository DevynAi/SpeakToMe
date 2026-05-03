import SwiftUI

struct RewardAnimationView: View {
    let tier: ResponseTier
    let rewardText: String

    @State private var animate = false

    var body: some View {
        VStack(spacing: 12) {
            Text(symbol)
                .font(.system(size: 80))
                .scaleEffect(animate ? 1.15 : 0.85)
                .rotationEffect(.degrees(animate ? 6 : -6))
                .animation(.easeInOut(duration: 0.6).repeatCount(4, autoreverses: true), value: animate)

            Text(rewardText)
                .font(.title3.bold())
                .foregroundStyle(AppTheme.indigo)

            Text(SafetyCopy.safe(tier.encouragement))
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.94))
        )
        .task {
            animate = true
        }
    }

    private var symbol: String {
        switch tier {
        case .none: return "✨"
        case .vocalization: return "🌟"
        case .approximate: return "🎉"
        case .word: return "🦁"
        case .phrase: return "🏆"
        case .sung: return "🎵"
        }
    }
}
