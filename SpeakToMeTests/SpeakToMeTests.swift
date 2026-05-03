import XCTest
import SwiftData
@testable import SpeakToMe

final class SpeakToMeTests: XCTestCase {
    func testResponseTierClassifier() {
        let result = ResponseTierClassifier.classify(
            target: "I want apple",
            detectedText: "want apple",
            vocalizationDetected: true,
            vocalDuration: 1.1,
            singingDetected: false
        )

        XCTAssertGreaterThanOrEqual(result.tier.rawValue, ResponseTier.approximate.rawValue)
    }

    func testCurriculumSeedHasMinimumCounts() throws {
        let schema = Schema([
            ChildProfile.self,
            CurriculumItem.self,
            PhraseTemplate.self,
            GameActivity.self,
            Reward.self,
            AttemptLog.self,
            SessionLog.self,
            UnlockedReward.self,
            AudioPrompt.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        CurriculumSeeder.seedAll(in: context)

        let items = try context.fetch(FetchDescriptor<CurriculumItem>())
        XCTAssertGreaterThanOrEqual(items.filter { $0.targetType == "word" }.count, 50)
        XCTAssertGreaterThanOrEqual(items.filter { $0.category == "Two Word Phrases" }.count, 75)
        XCTAssertGreaterThanOrEqual(items.filter { $0.category == "Simple Phrases" }.count, 75)
        XCTAssertGreaterThanOrEqual(items.filter { $0.category == "Actions" }.count, 25)
        XCTAssertGreaterThanOrEqual(items.filter { $0.category == "Social" }.count, 20)
        XCTAssertGreaterThanOrEqual(items.filter { $0.category == "Feelings" }.count, 20)
        XCTAssertGreaterThanOrEqual(items.filter { $0.category == "Choices" }.count, 20)
        XCTAssertGreaterThanOrEqual(items.filter { $0.category == "Identity" }.count, 20)
        XCTAssertGreaterThanOrEqual(items.filter { $0.category == "Songs" }.count, 20)
        XCTAssertGreaterThanOrEqual(items.filter { $0.category == "Alphabet" }.count, 26)
    }
}
