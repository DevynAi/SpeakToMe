import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChildProfile.createdAt) private var profiles: [ChildProfile]

    var body: some View {
        Group {
            if profiles.isEmpty || appState.selectedProfile == nil {
                ChildProfileSetupView(profiles: profiles)
            } else {
                HomeWorldView()
            }
        }
        .background(AppTheme.worldGradient.ignoresSafeArea())
        .task {
            await SeedBootstrapper.seedIfNeeded(in: modelContext)
        }
    }
}
