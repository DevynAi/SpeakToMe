import Foundation
import SwiftData

final class CurriculumEngine {
    func items(for child: ChildProfile, category: String?, in context: ModelContext) -> [CurriculumItem] {
        let childAge = child.age
        let descriptor = FetchDescriptor<CurriculumItem>(predicate: #Predicate {
            $0.isActive && $0.ageMin <= childAge && $0.ageMax >= childAge
        })

        guard let all = try? context.fetch(descriptor) else { return [] }
        let difficulty = max(1, min(5, child.currentDifficultyLevel))

        return all.filter {
            $0.difficultyLevel <= difficulty + 1 && (category == nil || $0.category.localizedCaseInsensitiveContains(category!))
        }
    }

    func adjustDifficulty(for child: ChildProfile, from tier: ResponseTier) {
        if tier.rawValue >= ResponseTier.word.rawValue {
            child.currentDifficultyLevel = min(child.currentDifficultyLevel + 1, 5)
        } else if tier == .none {
            child.currentDifficultyLevel = max(child.currentDifficultyLevel - 1, 1)
        }
        child.updatedAt = .now
    }
}
