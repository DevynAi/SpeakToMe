import Foundation
import SwiftData

@MainActor
final class ParentDashboardViewModel: ObservableObject {
    @Published var summary: ProgressSummary?
    @Published var exportStatus = ""

    private let tracker = ProgressTracker()
    private let sessionRepo = SwiftDataSessionRepository()

    func refresh(child: ChildProfile, in context: ModelContext) {
        summary = tracker.summary(for: child, in: context)
    }

    func exportJSON(child: ChildProfile, in context: ModelContext) {
        do {
            let attempts = try SwiftDataAttemptRepository().fetchAttempts(childId: child.id, in: context)
            let sessions = try sessionRepo.fetchSessions(childId: child.id, in: context)
            let url = try ProgressExporter.exportJSON(child: child, attempts: attempts, sessions: sessions)
            exportStatus = "JSON saved: \(url.lastPathComponent)"
        } catch {
            exportStatus = "Could not export JSON."
        }
    }

    func exportCSV(child: ChildProfile, in context: ModelContext) {
        do {
            let attempts = try SwiftDataAttemptRepository().fetchAttempts(childId: child.id, in: context)
            let sessions = try sessionRepo.fetchSessions(childId: child.id, in: context)
            let url = try ProgressExporter.exportCSV(child: child, attempts: attempts, sessions: sessions)
            exportStatus = "CSV saved: \(url.lastPathComponent)"
        } catch {
            exportStatus = "Could not export CSV."
        }
    }

    func resetProgress(child: ChildProfile, in context: ModelContext) {
        let childId = child.id
        let attemptDescriptor = FetchDescriptor<AttemptLog>(predicate: #Predicate { $0.childProfileId == childId })
        let sessionDescriptor = FetchDescriptor<SessionLog>(predicate: #Predicate { $0.childProfileId == childId })
        let rewardDescriptor = FetchDescriptor<UnlockedReward>(predicate: #Predicate { $0.childProfileId == childId })

        if let attempts = try? context.fetch(attemptDescriptor) {
            attempts.forEach(context.delete)
        }
        if let sessions = try? context.fetch(sessionDescriptor) {
            sessions.forEach(context.delete)
        }
        if let unlocked = try? context.fetch(rewardDescriptor) {
            unlocked.forEach(context.delete)
        }

        try? context.save()
        refresh(child: child, in: context)
    }
}
