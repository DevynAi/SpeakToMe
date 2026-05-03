import Foundation
import SwiftData

struct SwiftDataChildProfileRepository: ChildProfileRepository {
    func createProfile(_ profile: ChildProfile, in context: ModelContext) {
        context.insert(profile)
        try? context.save()
    }

    func fetchProfiles(in context: ModelContext) throws -> [ChildProfile] {
        try context.fetch(FetchDescriptor<ChildProfile>(sortBy: [SortDescriptor(\ChildProfile.createdAt)]))
    }
}

struct SwiftDataAttemptRepository: AttemptRepository {
    func logAttempt(_ attempt: AttemptLog, in context: ModelContext) {
        context.insert(attempt)
        try? context.save()
    }

    func fetchAttempts(childId: UUID, in context: ModelContext) throws -> [AttemptLog] {
        let descriptor = FetchDescriptor<AttemptLog>(predicate: #Predicate { $0.childProfileId == childId })
        return try context.fetch(descriptor)
    }
}

struct SwiftDataSessionRepository: SessionRepository {
    func createSession(_ session: SessionLog, in context: ModelContext) {
        context.insert(session)
        try? context.save()
    }

    func updateSession(_ session: SessionLog, in context: ModelContext) {
        session.endTime = .now
        session.durationSeconds = (session.endTime ?? .now).timeIntervalSince(session.startTime)
        try? context.save()
    }

    func fetchSessions(childId: UUID, in context: ModelContext) throws -> [SessionLog] {
        let descriptor = FetchDescriptor<SessionLog>(predicate: #Predicate { $0.childProfileId == childId })
        return try context.fetch(descriptor)
    }
}

// Compatibility seam for future Core Data adapter.
protocol DataStoreAdapter {
    var childProfileRepository: ChildProfileRepository { get }
    var attemptRepository: AttemptRepository { get }
    var sessionRepository: SessionRepository { get }
}

struct SwiftDataAdapter: DataStoreAdapter {
    let childProfileRepository: ChildProfileRepository = SwiftDataChildProfileRepository()
    let attemptRepository: AttemptRepository = SwiftDataAttemptRepository()
    let sessionRepository: SessionRepository = SwiftDataSessionRepository()
}

struct CoreDataAdapterPlaceholder: DataStoreAdapter {
    let childProfileRepository: ChildProfileRepository = SwiftDataChildProfileRepository()
    let attemptRepository: AttemptRepository = SwiftDataAttemptRepository()
    let sessionRepository: SessionRepository = SwiftDataSessionRepository()
}
