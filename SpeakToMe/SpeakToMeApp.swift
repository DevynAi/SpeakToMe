import SwiftUI
import SwiftData

@main
struct SpeakToMeApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
        }
        .modelContainer(for: [
            ChildProfile.self,
            CurriculumItem.self,
            PhraseTemplate.self,
            GameActivity.self,
            Reward.self,
            AttemptLog.self,
            SessionLog.self,
            UnlockedReward.self,
            AudioPrompt.self
        ])
    }
}
