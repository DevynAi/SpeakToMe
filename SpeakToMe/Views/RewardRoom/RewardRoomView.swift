import SwiftUI
import SwiftData

struct RewardRoomView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @Query private var rewards: [Reward]
    @Query private var unlocked: [UnlockedReward]

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text("Reward Room")
                    .font(.largeTitle.bold())

                Text("Base rewards are always available. Voice and singing unlock premium variants faster.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .worldCard()

                ForEach(rewards, id: \.id) { reward in
                    let count = unlocked.filter { $0.rewardId == reward.id && $0.childProfileId == appState.selectedProfile?.id }.count
                    HStack {
                        Text(reward.assetName == "rainbow" ? "🌈" : "⭐️")
                            .font(.system(size: 42))
                        VStack(alignment: .leading) {
                            Text(reward.name).font(.title3.bold())
                            Text("Type: \(reward.rewardType.capitalized) • Level \(reward.intensityLevel)")
                                .font(.subheadline)
                            Text("Unlocked \(count)x")
                                .font(.caption)
                                .foregroundStyle(AppTheme.indigo)
                        }
                        Spacer()
                    }
                    .worldCard()
                }
            }
            .padding(20)
        }
        .background(AppTheme.worldGradient.ignoresSafeArea())
        .navigationTitle("Reward Room")
    }
}
