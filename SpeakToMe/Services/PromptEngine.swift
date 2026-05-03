import Foundation
import SwiftData

struct PromptContext {
    let child: ChildProfile
    let categoryHint: String
    let recentTargets: [String]
}

struct PromptSelection {
    let item: CurriculumItem
    let promptText: String
    let promptLevel: Int
}

final class PromptEngine {
    func nextPrompt(context: PromptContext, in modelContext: ModelContext) -> PromptSelection? {
        let childAge = context.child.age
        let descriptor = FetchDescriptor<CurriculumItem>(predicate: #Predicate {
            $0.isActive && $0.ageMin <= childAge && $0.ageMax >= childAge
        })

        guard let items = try? modelContext.fetch(descriptor), !items.isEmpty else { return nil }

        let filtered = items.filter {
            context.categoryHint.isEmpty || $0.category.localizedCaseInsensitiveContains(context.categoryHint)
        }

        let candidates = (filtered.isEmpty ? items : filtered).filter {
            !context.recentTargets.suffix(4).contains($0.targetText)
        }

        guard let item = (candidates.isEmpty ? filtered.first : candidates.randomElement()) else { return nil }

        let level = choosePromptLevel(for: context.child)
        let text = buildPrompt(level: level, childName: context.child.displayName, target: item.targetText)
        return PromptSelection(item: item, promptText: text, promptLevel: level)
    }

    func expandedTarget(after tier: ResponseTier, currentText: String) -> String {
        if tier.rawValue >= ResponseTier.word.rawValue {
            if !currentText.lowercased().contains("i want") {
                return "I want \(currentText)"
            }
            if currentText.split(separator: " ").count < 4 {
                return "\(currentText) please"
            }
        }

        if tier == .none || tier == .vocalization {
            let tokens = currentText.split(separator: " ")
            if let first = tokens.first {
                return String(first)
            }
        }

        return currentText
    }

    private func choosePromptLevel(for child: ChildProfile) -> Int {
        let level = max(1, min(4, child.currentDifficultyLevel))
        return level
    }

    private func buildPrompt(level: Int, childName: String, target: String) -> String {
        switch level {
        case 1: return "\(childName), can you say \(target)?"
        case 2: return "\(childName), say \(target.prefix(1).lowercased())..."
        case 3: return "\(childName), watch my mouth for \(target)."
        default: return "\(childName), what do you want to say?"
        }
    }
}
