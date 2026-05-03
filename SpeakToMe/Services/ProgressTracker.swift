import Foundation
import SwiftData

struct ProgressSummary {
    let vocalizationCount: Int
    let wordsAttempted: Int
    let phraseAttempts: Int
    let mostSuccessfulTargets: [String]
    let skippedTargets: [String]
    let singingAttempts: Int
    let speakingAttempts: Int
    let favoriteGames: [String]
}

final class ProgressTracker {
    private let attemptRepo: AttemptRepository
    private let sessionRepo: SessionRepository

    init(
        attemptRepo: AttemptRepository = SwiftDataAttemptRepository(),
        sessionRepo: SessionRepository = SwiftDataSessionRepository()
    ) {
        self.attemptRepo = attemptRepo
        self.sessionRepo = sessionRepo
    }

    func log(attempt: AttemptLog, in context: ModelContext) {
        attemptRepo.logAttempt(attempt, in: context)
    }

    func summary(for child: ChildProfile, in context: ModelContext) -> ProgressSummary {
        let attempts = (try? attemptRepo.fetchAttempts(childId: child.id, in: context)) ?? []
        let vocalizations = attempts.filter { $0.responseTier > 0 }.count
        let wordsAttempted = attempts.filter { $0.promptText.split(separator: " ").count <= 2 }.count
        let phraseAttempts = attempts.filter { $0.promptText.split(separator: " ").count >= 3 }.count
        let singing = attempts.filter { $0.responseTier == ResponseTier.sung.rawValue }.count
        let speaking = attempts.filter { (ResponseTier.word.rawValue...ResponseTier.phrase.rawValue).contains($0.responseTier) }.count

        let sessions = (try? sessionRepo.fetchSessions(childId: child.id, in: context)) ?? []
        let activityMap = Dictionary(uniqueKeysWithValues: ((try? context.fetch(FetchDescriptor<GameActivity>())) ?? []).map { ($0.id, $0.name) })
        let gameCounts = Dictionary(grouping: sessions.flatMap(\.activitiesPlayed), by: { $0 }).mapValues(\.count)
        let favoriteGames = gameCounts
            .sorted { $0.value > $1.value }
            .prefix(3)
            .compactMap { activityMap[$0.key] }

        let grouped = Dictionary(grouping: attempts, by: { $0.promptText })
        let successful = grouped
            .mapValues { $0.max(by: { $0.responseTier < $1.responseTier })?.responseTier ?? 0 }
            .sorted { $0.value > $1.value }

        let successfulTargets = successful.prefix(5).map { $0.key }
        let skippedTargets = grouped
            .filter { $0.value.allSatisfy { $0.responseTier == 0 } }
            .map(\.key)
            .prefix(5)

        return ProgressSummary(
            vocalizationCount: vocalizations,
            wordsAttempted: wordsAttempted,
            phraseAttempts: phraseAttempts,
            mostSuccessfulTargets: successfulTargets,
            skippedTargets: Array(skippedTargets),
            singingAttempts: singing,
            speakingAttempts: speaking,
            favoriteGames: favoriteGames
        )
    }
}
