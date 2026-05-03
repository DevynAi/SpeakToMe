import SwiftUI

struct HomeWorldView: View {
    @Environment(AppState.self) private var appState
    @State private var showParentGate = false
    @State private var gateUnlocked = false
    @State private var bubbleCount = 8
    @State private var instrumentOn = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    topBanner
                    playfulZone
                    worldGrid
                    parentAccess
                }
                .padding(20)
            }
            .background(AppTheme.worldGradient.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showParentGate) {
                ParentGateSheet(isUnlocked: $gateUnlocked)
                    .presentationDetents([.medium, .large])
            }
            .onChange(of: gateUnlocked) { _, newValue in
                if newValue {
                    appState.showParentArea = true
                }
            }
            .navigationDestination(isPresented: Binding(
                get: { appState.showParentArea },
                set: { appState.showParentArea = $0 }
            )) {
                ParentDashboardView()
            }
        }
    }

    private var playfulZone: some View {
        VStack(spacing: 10) {
            Text("Voice Garden Play")
                .font(.title3.bold())
            Text("Tap bubbles, move animals, and power music.")
                .font(.headline)

            HStack(spacing: 10) {
                ForEach(0..<min(bubbleCount, 8), id: \.self) { _ in
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 42, height: 42)
                        .overlay(Text("🫧"))
                        .onTapGesture {
                            if bubbleCount > 0 { bubbleCount -= 1 }
                        }
                }
            }

            HStack(spacing: 12) {
                Text("🦁")
                    .font(.system(size: 44))
                    .padding(8)
                    .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 14))
                Text("🐘")
                    .font(.system(size: 44))
                    .padding(8)
                    .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 14))
                Button(instrumentOn ? "Stop Drum" : "Play Drum") {
                    instrumentOn.toggle()
                }
                .buttonStyle(.borderedProminent)
            }

            HStack {
                Button("More Bubbles") { bubbleCount = 8 }
                    .buttonStyle(.bordered)
                if instrumentOn {
                    Text("🥁🎵")
                        .font(.title2)
                }
            }
        }
        .worldCard()
    }

    private var topBanner: some View {
        VStack(spacing: 6) {
            Text("🌈 Speak To Me")
                .font(.system(size: 48, weight: .black))
            Text("\(appState.selectedProfile?.displayName ?? "Friend"), your voice powers the world!")
                .font(.title2.bold())
                .foregroundStyle(AppTheme.indigo)
        }
        .worldCard()
    }

    private var worldGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            worldLink(title: "Letter Jungle", icon: "textformat.abc", destination: LetterJungleView())
            worldLink(title: "Animal Band", icon: "music.note.list", destination: AnimalBandView())
            worldLink(title: "Color River", icon: "paintpalette.fill", destination: ColorRiverView())
            worldLink(title: "Number Train", icon: "tram.fill", destination: NumberTrainView())
            worldLink(title: "Song Treehouse", icon: "music.note", destination: SongTreehouseView())
            worldLink(title: "Name Castle", icon: "building.columns.fill", destination: NameCastleView())
            worldLink(title: "Phrase Playground", icon: "text.bubble.fill", destination: PhrasePlaygroundView())
            worldLink(title: "Reward Room", icon: "star.circle.fill", destination: RewardRoomView())
        }
    }

    private var parentAccess: some View {
        VStack(spacing: 8) {
            Button("Parent Dashboard") {
                gateUnlocked = false
                showParentGate = true
            }
            .buttonStyle(.bordered)
            .tint(.gray)

            Button("Switch Child") {
                appState.selectedProfile = nil
                appState.endSession()
            }
            .buttonStyle(.bordered)
            .tint(.gray)
        }
        .worldCard()
    }

    private func worldLink<Destination: View>(title: String, icon: String, destination: Destination) -> some View {
        NavigationLink {
            destination
        } label: {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 38, weight: .heavy))
                    .foregroundStyle(AppTheme.coral)
                Text(title)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.highContrastText)
            }
            .frame(maxWidth: .infinity, minHeight: 135)
            .worldCard()
        }
        .buttonStyle(.plain)
    }
}

private struct ParentGateSheet: View {
    @Binding var isUnlocked: Bool

    var body: some View {
        ParentGateView(isUnlocked: $isUnlocked)
            .padding()
            .background(AppTheme.worldGradient.ignoresSafeArea())
    }
}
