import Foundation
import SwiftData

@MainActor
final class SessionManager: ObservableObject {
    @Published var currentSession: SessionLog?

    private let sessionRepo: SessionRepository

    init(sessionRepo: SessionRepository = SwiftDataSessionRepository()) {
        self.sessionRepo = sessionRepo
    }

    func startSession(for child: ChildProfile, in context: ModelContext) {
        let session = SessionLog(childProfileId: child.id, startTime: .now)
        sessionRepo.createSession(session, in: context)
        currentSession = session
    }

    func recordPrompt(activityId: UUID) {
        guard let currentSession else { return }
        currentSession.totalPrompts += 1
        if !currentSession.activitiesPlayed.contains(activityId) {
            currentSession.activitiesPlayed.append(activityId)
        }
    }

    func recordAttempt(tier: ResponseTier, usedFallback: Bool) {
        guard let currentSession else { return }
        if tier.rawValue > 0 {
            currentSession.totalVocalAttempts += 1
        }
        if usedFallback {
            currentSession.totalFallbacks += 1
        }
        currentSession.bestResponseTier = max(currentSession.bestResponseTier, tier.rawValue)
    }

    func finishSession(in context: ModelContext) {
        guard let currentSession else { return }
        sessionRepo.updateSession(currentSession, in: context)
        self.currentSession = nil
    }
}
