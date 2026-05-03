import SwiftUI
import SwiftData

struct ChildProfileSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    let profiles: [ChildProfile]

    @State private var name = ""
    @State private var nickname = ""
    @State private var age = 4
    @State private var voiceSensitivity = 0.2
    @State private var promptDelay = 2.0
    @State private var sessionLength = 15
    @State private var rewardIntensity = 3
    @State private var emphasisMode: EmphasisMode = .mixed
    @State private var favoriteAnimals: Set<String> = ["dog"]
    @State private var favoriteColors: Set<String> = ["blue"]
    @State private var favoriteSongs: Set<String> = ["name song"]
    @State private var preferredRewards: Set<String> = ["sparkle", "sticker"]

    private let repo = SwiftDataChildProfileRepository()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Speak To Me")
                        .font(.system(size: 54, weight: .black))
                        .foregroundStyle(AppTheme.indigo)

                    Text("A colorful voice-powered safari for growing speech and singing.")
                        .font(.title3)
                        .multilineTextAlignment(.center)

                    existingProfiles

                    setupForm
                }
                .padding(20)
            }
            .background(AppTheme.worldGradient.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private var existingProfiles: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose Child")
                .font(.title2.bold())
            if profiles.isEmpty {
                Text("Create a child profile to begin.")
            } else {
                ForEach(profiles, id: \.id) { profile in
                    Button {
                        appState.beginSession(for: profile)
                    } label: {
                        HStack {
                            Text("🌟 \(profile.displayName), age \(profile.age)")
                                .font(.title3.bold())
                            Spacer()
                            Text("Play")
                                .font(.headline)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.indigo)
                    .controlSize(.large)
                }
            }
        }
        .worldCard()
    }

    private var setupForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Parent Setup")
                .font(.title2.bold())

            TextField("Child name", text: $name)
                .textFieldStyle(.roundedBorder)
            TextField("Nickname (optional)", text: $nickname)
                .textFieldStyle(.roundedBorder)

            HStack {
                Stepper("Age: \(age)", value: $age, in: 3...6)
                Stepper("Session: \(sessionLength)m", value: $sessionLength, in: 5...45)
            }

            Stepper("Reward intensity: \(rewardIntensity)", value: $rewardIntensity, in: 1...5)

            HStack {
                Text("Voice sensitivity")
                Slider(value: $voiceSensitivity, in: 0.05...0.4)
            }

            HStack {
                Text("Prompt delay")
                Slider(value: $promptDelay, in: 1...5)
            }

            Picker("Emphasis", selection: $emphasisMode) {
                ForEach(EmphasisMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue.capitalized).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            selectorRow(title: "Favorite animals", options: CurriculumSeeder.animalSeed, selected: $favoriteAnimals)
            selectorRow(title: "Favorite colors", options: CurriculumSeeder.colorSeed, selected: $favoriteColors)
            selectorRow(title: "Favorite songs", options: ["name song", "animal song", "color song", "counting song", "alphabet song"], selected: $favoriteSongs)
            selectorRow(title: "Preferred rewards", options: ["sparkle", "sticker", "song", "animation", "animal", "instrument", "decoration"], selected: $preferredRewards)

            Button("Create Child Profile") {
                createProfile()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .worldCard()
    }

    private func createProfile() {
        let profile = ChildProfile(
            name: name,
            nickname: nickname.isEmpty ? nil : nickname,
            age: age,
            favoriteAnimals: Array(favoriteAnimals),
            favoriteColors: Array(favoriteColors),
            favoriteSongs: Array(favoriteSongs),
            preferredRewards: Array(preferredRewards),
            voiceSensitivity: voiceSensitivity,
            promptDelaySeconds: promptDelay,
            currentDifficultyLevel: 1,
            sessionLengthMinutes: sessionLength,
            rewardIntensity: rewardIntensity,
            emphasisModeRaw: emphasisMode.rawValue
        )
        repo.createProfile(profile, in: modelContext)
        appState.beginSession(for: profile)
    }

    private func selectorRow(title: String, options: [String], selected: Binding<Set<String>>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(options, id: \.self) { option in
                        let isSelected = selected.wrappedValue.contains(option)
                        Button(option) {
                            if isSelected {
                                selected.wrappedValue.remove(option)
                            } else {
                                selected.wrappedValue.insert(option)
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(isSelected ? AppTheme.coral : AppTheme.indigo)
                    }
                }
            }
        }

    }
}
