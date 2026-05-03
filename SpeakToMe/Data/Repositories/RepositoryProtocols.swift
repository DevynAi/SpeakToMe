import Foundation
import SwiftData

protocol ChildProfileRepository {
    func createProfile(_ profile: ChildProfile, in context: ModelContext)
    func fetchProfiles(in context: ModelContext) throws -> [ChildProfile]
}

protocol AttemptRepository {
    func logAttempt(_ attempt: AttemptLog, in context: ModelContext)
    func fetchAttempts(childId: UUID, in context: ModelContext) throws -> [AttemptLog]
}

protocol SessionRepository {
    func createSession(_ session: SessionLog, in context: ModelContext)
    func updateSession(_ session: SessionLog, in context: ModelContext)
    func fetchSessions(childId: UUID, in context: ModelContext) throws -> [SessionLog]
}
