import SwiftUI
import SwiftData

struct ParentDashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChildProfile.createdAt) private var profiles: [ChildProfile]

    @StateObject private var vm = ParentDashboardViewModel()
    @State private var selectedProfileId: UUID?

    var selectedProfile: ChildProfile? {
        if let selectedProfileId {
            return profiles.first(where: { $0.id == selectedProfileId })
        }
        return appState.selectedProfile
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Parent Dashboard")
                    .font(.largeTitle.bold())

                profilePicker

                if let profile = selectedProfile {
                    settingsCard(profile: profile)
                    progressCard(profile: profile)
                    exportCard(profile: profile)
                    guidedAccessCard
                }
            }
            .padding(20)
        }
        .background(AppTheme.worldGradient.ignoresSafeArea())
        .navigationTitle("Parent Dashboard")
        .onAppear {
            if let child = selectedProfile {
                vm.refresh(child: child, in: modelContext)
            }
        }
        .onChange(of: selectedProfileId) { _, _ in
            if let child = selectedProfile {
                vm.refresh(child: child, in: modelContext)
            }
        }
    }

    private var profilePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Child Profile")
                .font(.headline)
            Picker("Child", selection: $selectedProfileId) {
                Text("Current Child").tag(UUID?.none)
                ForEach(profiles, id: \.id) { profile in
                    Text(profile.displayName).tag(UUID?.some(profile.id))
                }
            }
            .pickerStyle(.menu)
        }
        .worldCard()
    }

    private func settingsCard(profile: ChildProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.title3.bold())

            TextField("Name", text: Binding(
                get: { profile.name },
                set: {
                    profile.name = $0
                    profile.updatedAt = .now
                    try? modelContext.save()
                }
            ))
            .textFieldStyle(.roundedBorder)

            TextField("Nickname", text: Binding(
                get: { profile.nickname ?? "" },
                set: {
                    profile.nickname = $0.isEmpty ? nil : $0
                    profile.updatedAt = .now
                    try? modelContext.save()
                }
            ))
            .textFieldStyle(.roundedBorder)

            TextField("Favorite animals (comma separated)", text: Binding(
                get: { profile.favoriteAnimals.joined(separator: ", ") },
                set: {
                    profile.favoriteAnimals = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                    try? modelContext.save()
                }
            ))
            .textFieldStyle(.roundedBorder)

            TextField("Favorite colors (comma separated)", text: Binding(
                get: { profile.favoriteColors.joined(separator: ", ") },
                set: {
                    profile.favoriteColors = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                    try? modelContext.save()
                }
            ))
            .textFieldStyle(.roundedBorder)

            Stepper("Difficulty: \(profile.currentDifficultyLevel)", value: Binding(
                get: { profile.currentDifficultyLevel },
                set: {
                    profile.currentDifficultyLevel = max(1, min(5, $0))
                    profile.updatedAt = .now
                    try? modelContext.save()
                }
            ), in: 1...5)

            HStack {
                Text("Prompt delay")
                Slider(value: Binding(
                    get: { profile.promptDelaySeconds },
                    set: {
                        profile.promptDelaySeconds = $0
                        try? modelContext.save()
                    }
                ), in: 1...5)
            }

            HStack {
                Text("Voice sensitivity")
                Slider(value: Binding(
                    get: { profile.voiceSensitivity },
                    set: {
                        profile.voiceSensitivity = $0
                        try? modelContext.save()
                    }
                ), in: 0.05...0.4)
            }

            Stepper("Session length: \(profile.sessionLengthMinutes)m", value: Binding(
                get: { profile.sessionLengthMinutes },
                set: {
                    profile.sessionLengthMinutes = $0
                    try? modelContext.save()
                }
            ), in: 5...45)

            Stepper("Reward intensity: \(profile.rewardIntensity)", value: Binding(
                get: { profile.rewardIntensity },
                set: {
                    profile.rewardIntensity = $0
                    try? modelContext.save()
                }
            ), in: 1...5)

            Toggle("High Contrast", isOn: Binding(
                get: { appState.highContrast },
                set: { appState.highContrast = $0 }
            ))

            Toggle("Sound Enabled", isOn: Binding(
                get: { appState.soundEnabled },
                set: { appState.soundEnabled = $0 }
            ))
        }
        .worldCard()
    }

    private func progressCard(profile: ChildProfile) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Progress")
                .font(.title3.bold())

            if let summary = vm.summary {
                Text("Vocalizations: \(summary.vocalizationCount)")
                Text("Words attempted: \(summary.wordsAttempted)")
                Text("Phrase attempts: \(summary.phraseAttempts)")
                Text("Speaking attempts: \(summary.speakingAttempts)")
                Text("Singing attempts: \(summary.singingAttempts)")

                Text("Favorite games:")
                    .font(.headline)
                ForEach(summary.favoriteGames, id: \.self) { game in
                    Text("• \(game)")
                }

                Text("Most successful targets:")
                    .font(.headline)
                ForEach(summary.mostSuccessfulTargets, id: \.self) { target in
                    Text("• \(target)")
                }

                Text("Skipped targets:")
                    .font(.headline)
                ForEach(summary.skippedTargets, id: \.self) { target in
                    Text("• \(target)")
                }
            } else {
                Text("No progress yet.")
            }

            Button("Refresh Progress") {
                vm.refresh(child: profile, in: modelContext)
            }
            .buttonStyle(.bordered)
        }
        .worldCard()
    }

    private func exportCard(profile: ChildProfile) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Local Export")
                .font(.title3.bold())
            Text("Exports are saved locally on this iPad.")

            HStack {
                Button("Export JSON") {
                    vm.exportJSON(child: profile, in: modelContext)
                }
                .buttonStyle(.borderedProminent)

                Button("Export CSV") {
                    vm.exportCSV(child: profile, in: modelContext)
                }
                .buttonStyle(.bordered)
            }

            Button("Reset Progress") {
                vm.resetProgress(child: profile, in: modelContext)
            }
            .buttonStyle(.bordered)
            .tint(.red)

            Text(vm.exportStatus)
                .font(.caption)
                .foregroundStyle(AppTheme.indigo)
        }
        .worldCard()
    }

    private var guidedAccessCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Guided Access")
                .font(.title3.bold())
            Text("To keep your child inside Speak To Me, open iPad Settings > Accessibility > Guided Access, enable it, then triple-click the top button while the app is open.")
                .font(.subheadline)
        }
        .worldCard()
    }
}
