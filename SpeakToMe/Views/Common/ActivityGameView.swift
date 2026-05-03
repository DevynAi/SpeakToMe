import SwiftUI
import SwiftData

struct ActivityGameView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    let worldTitle: String
    let categoryHint: String
    let mascot: String
    let draggableEmoji: String

    @StateObject private var viewModel = ActivityLoopViewModel()
    @StateObject private var speechService = SpeechDetectionService()
    @StateObject private var sessionManager = SessionManager()

    @State private var recentTargets: [String] = []
    @State private var activityId = UUID()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header

                if let prompt = viewModel.currentPrompt {
                    Text("Flow: \(viewModel.phase.rawValue)")
                        .font(.headline)
                        .foregroundStyle(AppTheme.indigo)
                        .worldCard()

                    PromptCard(
                        mascot: mascot,
                        prompt: prompt.promptText,
                        helper: viewModel.helperText
                    )

                    SpeechBuddyMouthView(
                        targetText: prompt.item.targetText,
                        phonemes: prompt.item.phonemeBreakdown,
                        syllables: prompt.item.syllableBreakdown,
                        visemes: prompt.item.visemeSequence
                    )

                    controls

                    if viewModel.showingFallback {
                        DraggableItemView(title: prompt.item.targetText, emoji: draggableEmoji) {
                            viewModel.showingFallback = false
                            viewModel.helperText = "You did it."
                            nextPrompt()
                        }
                    }

                    if viewModel.showingReward {
                        RewardAnimationView(tier: viewModel.latestTier, rewardText: viewModel.rewardText)
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle(worldTitle)
        .background(AppTheme.worldGradient.ignoresSafeArea())
        .task {
            guard let child = appState.selectedProfile else { return }
            await speechService.requestPermissions()
            sessionManager.startSession(for: child, in: modelContext)
            activityId = UUID()
            nextPrompt()
        }
        .onDisappear {
            sessionManager.finishSession(in: modelContext)
        }
    }

    private var header: some View {
        HStack {
            Text(worldTitle)
                .font(.largeTitle.bold())
                .foregroundStyle(AppTheme.indigo)
            Spacer()
            Text("\(mascot)")
                .font(.system(size: 52))
        }
        .worldCard()
    }

    private var controls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button("Prompt -> Wait -> Model") {
                    guard let child = appState.selectedProfile else { return }
                    viewModel.beginGuidedFlow(waitSeconds: child.promptDelaySeconds)
                }
                .buttonStyle(.bordered)

                Button("Start Listening") {
                    guard let child = appState.selectedProfile else { return }
                    viewModel.showingReward = false
                    viewModel.showingFallback = false
                    speechService.startListening(sensitivity: child.voiceSensitivity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button("Finish Attempt") {
                    finishAttempt()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }

            Button("Use Helper Fallback") {
                viewModel.showingFallback = true
                viewModel.showingReward = false
                viewModel.helperText = "That's okay. Help me move it."
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button("Next Prompt") {
                nextPrompt()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .worldCard()
    }

    private func finishAttempt() {
        guard
            let child = appState.selectedProfile,
            let sessionId = sessionManager.currentSession?.id,
            let prompt = viewModel.currentPrompt
        else {
            return
        }

        let data = speechService.stopListening()
        let result = ResponseTierClassifier.classify(
            target: prompt.item.targetText,
            detectedText: data.detectedText,
            vocalizationDetected: data.vocalDetected,
            vocalDuration: data.duration,
            singingDetected: data.singingDetected
        )

        let usedFallback = result.tier == .none
        viewModel.completeAttempt(
            child: child,
            activityId: activityId,
            sessionId: sessionId,
            result: result,
            usedFallback: usedFallback,
            context: modelContext
        )

        sessionManager.recordAttempt(tier: result.tier, usedFallback: usedFallback)
        recentTargets.append(prompt.item.targetText)
    }

    private func nextPrompt() {
        guard let child = appState.selectedProfile else { return }
        viewModel.showingReward = false
        viewModel.loadPrompt(for: child, category: categoryHint, context: modelContext, recentTargets: recentTargets)
        sessionManager.recordPrompt(activityId: activityId)
    }
}
