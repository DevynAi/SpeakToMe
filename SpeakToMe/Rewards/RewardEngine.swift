import Foundation
import SwiftData

struct RewardOutcome {
    let rewardName: String
    let message: String
    let intensity: Int
}

final class RewardEngine {
    func reward(for tier: ResponseTier, child: ChildProfile, context: ModelContext, curriculumItemId: UUID?) -> RewardOutcome {
        let rewardType: String
        let intensity: Int

        switch tier {
        case .none:
            rewardType = "sparkle"
            intensity = 1
        case .vocalization:
            rewardType = "sparkle"
            intensity = 1
        case .approximate:
            rewardType = "sticker"
            intensity = 2
        case .word:
            rewardType = "animation"
            intensity = 3
        case .phrase:
            rewardType = "song"
            intensity = 4
        case .sung:
            rewardType = "instrument"
            intensity = 5
        }

        let descriptor = FetchDescriptor<Reward>(predicate: #Predicate {
            $0.rewardType == rewardType
        })

        let selectedReward = (try? context.fetch(descriptor))?.first
            ?? Reward(name: "Magic Sparkle", rewardType: rewardType, intensityLevel: intensity, assetName: "sparkles")

        let unlock = UnlockedReward(
            childProfileId: child.id,
            rewardId: selectedReward.id,
            unlockedByCurriculumItemId: curriculumItemId
        )
        context.insert(unlock)
        try? context.save()

        let adjustedIntensity = max(1, min(5, intensity + (child.rewardIntensity - 3)))

        return RewardOutcome(
            rewardName: selectedReward.name,
            message: tier.encouragement,
            intensity: adjustedIntensity
        )
    }
}
