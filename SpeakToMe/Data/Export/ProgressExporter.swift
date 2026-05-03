import Foundation
import SwiftData

struct ProgressExporter {
    static func exportJSON(child: ChildProfile, attempts: [AttemptLog], sessions: [SessionLog]) throws -> URL {
        let payload = ExportPayload(child: child, attempts: attempts, sessions: sessions)
        let data = try JSONEncoder.pretty.encode(payload)
        return try write(data: data, fileName: "SpeakToMe_\(child.name)_progress.json")
    }

    static func exportCSV(child: ChildProfile, attempts: [AttemptLog], sessions: [SessionLog]) throws -> URL {
        var rows = ["type,id,timestamp,prompt,tier,fallback,reward,duration"]
        for attempt in attempts {
            rows.append("attempt,\(attempt.id.uuidString),\(attempt.timestamp.iso8601),\(attempt.promptText.csvEscaped),\(attempt.responseTier),\(attempt.usedFallback),\(attempt.rewardGiven.csvEscaped),\(attempt.vocalizationDuration)")
        }
        for session in sessions {
            rows.append("session,\(session.id.uuidString),\(session.startTime.iso8601),session,\(session.bestResponseTier),\(session.totalFallbacks),session_summary,\(session.durationSeconds)")
        }
        let csvData = rows.joined(separator: "\n").data(using: .utf8) ?? Data()
        return try write(data: csvData, fileName: "SpeakToMe_\(child.name)_progress.csv")
    }

    private static func write(data: Data, fileName: String) throws -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = documents.appendingPathComponent(fileName)
        try data.write(to: url, options: .atomic)
        return url
    }
}

private struct ExportPayload: Codable {
    let child: ChildSnapshot
    let attempts: [AttemptSnapshot]
    let sessions: [SessionSnapshot]

    init(child: ChildProfile, attempts: [AttemptLog], sessions: [SessionLog]) {
        self.child = ChildSnapshot(from: child)
        self.attempts = attempts.map(AttemptSnapshot.init)
        self.sessions = sessions.map(SessionSnapshot.init)
    }
}

private struct ChildSnapshot: Codable {
    let id: UUID
    let name: String
    let nickname: String?
    let age: Int

    init(from child: ChildProfile) {
        self.id = child.id
        self.name = child.name
        self.nickname = child.nickname
        self.age = child.age
    }
}

private struct AttemptSnapshot: Codable {
    let id: UUID
    let timestamp: Date
    let promptText: String
    let responseTier: Int
    let usedFallback: Bool
    let rewardGiven: String

    init(_ log: AttemptLog) {
        id = log.id
        timestamp = log.timestamp
        promptText = log.promptText
        responseTier = log.responseTier
        usedFallback = log.usedFallback
        rewardGiven = log.rewardGiven
    }
}

private struct SessionSnapshot: Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date?
    let durationSeconds: Double
    let totalPrompts: Int
    let totalVocalAttempts: Int
    let totalFallbacks: Int

    init(_ session: SessionLog) {
        id = session.id
        startTime = session.startTime
        endTime = session.endTime
        durationSeconds = session.durationSeconds
        totalPrompts = session.totalPrompts
        totalVocalAttempts = session.totalVocalAttempts
        totalFallbacks = session.totalFallbacks
    }
}

private extension JSONEncoder {
    static var pretty: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

private extension String {
    var csvEscaped: String {
        let escaped = replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
}

private extension Date {
    var iso8601: String {
        ISO8601DateFormatter().string(from: self)
    }
}
