import Foundation
import SwiftData

@MainActor
final class ActivityLoopViewModel: ObservableObject {
    enum PromptPhase: String {
        case prompt = "Prompt"
        case wait = "Wait"
        case model = "Model"
        case mouth = "Mouth"
        case attempt = "Child Attempt"
        case reward = "Reward"
    }

    @Published var currentPrompt: PromptSelection?
    @Published var latestTier: ResponseTier = .none
    @Published var rewardText = ""
    @Published var showingReward = false
    @Published var showingFallback = false
    @Published var helperText = "Let's try together."
    @Published var phase: PromptPhase = .prompt

    private let promptEngine = PromptEngine()
    private let rewardEngine = RewardEngine()
    private let tracker = ProgressTracker()
    private let curriculumEngine = CurriculumEngine()

    func loadPrompt(for child: ChildProfile, category: String, context: ModelContext, recentTargets: [String]) {
        let promptContext = PromptContext(child: child, categoryHint: category, recentTargets: recentTargets)
        currentPrompt = promptEngine.nextPrompt(context: promptContext, in: context)
        phase = .prompt
        helperText = "Watch my mouth."
    }

    func beginGuidedFlow(waitSeconds: Double) {
        phase = .prompt
        helperText = "Watch my mouth."

        Task {
            phase = .wait
            try? await Task.sleep(for: .seconds(max(1, waitSeconds)))
            phase = .model
            helperText = "Let's do it together."
            try? await Task.sleep(for: .seconds(1.2))
            phase = .mouth
            try? await Task.sleep(for: .seconds(1.0))
            phase = .attempt
            helperText = "Nice try!"
        }
    }

    func completeAttempt(
        child: ChildProfile,
        activityId: UUID,
        sessionId: UUID,
        result: DetectionResult,
        usedFallback: Bool,
        context: ModelContext
    ) {
        guard let prompt = currentPrompt else { return }
        latestTier = result.tier
        let outcome = rewardEngine.reward(for: result.tier, child: child, context: context, curriculumItemId: prompt.item.id)
        rewardText = "\(outcome.rewardName) unlocked"
        showingReward = true
        showingFallback = usedFallback
        phase = .reward

        let log = AttemptLog(
            childProfileId: child.id,
            curriculumItemId: prompt.item.id,
            activityId: activityId,
            promptText: prompt.promptText,
            responseDetected: result.tier != .none,
            responseTier: result.tier.rawValue,
            detectedText: result.detectedText,
            vocalizationDuration: result.vocalizationDuration,
            usedFallback: usedFallback,
            rewardGiven: outcome.rewardName,
            sessionId: sessionId
        )
        tracker.log(attempt: log, in: context)
        curriculumEngine.adjustDifficulty(for: child, from: result.tier)

        helperText = SafetyCopy.safe(outcome.message)
    }
}
