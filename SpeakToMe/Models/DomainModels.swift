import Foundation
import SwiftData

@Model
final class ChildProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var nickname: String?
    var age: Int
    var favoriteAnimals: [String]
    var favoriteColors: [String]
    var favoriteSongs: [String]
    var preferredRewards: [String]
    var voiceSensitivity: Double
    var promptDelaySeconds: Double
    var currentDifficultyLevel: Int
    var sessionLengthMinutes: Int
    var rewardIntensity: Int
    var emphasisModeRaw: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        nickname: String? = nil,
        age: Int,
        favoriteAnimals: [String] = [],
        favoriteColors: [String] = [],
        favoriteSongs: [String] = [],
        preferredRewards: [String] = ["sparkle"],
        voiceSensitivity: Double = 0.2,
        promptDelaySeconds: Double = 2.0,
        currentDifficultyLevel: Int = 1,
        sessionLengthMinutes: Int = 15,
        rewardIntensity: Int = 3,
        emphasisModeRaw: String = EmphasisMode.mixed.rawValue,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.nickname = nickname
        self.age = age
        self.favoriteAnimals = favoriteAnimals
        self.favoriteColors = favoriteColors
        self.favoriteSongs = favoriteSongs
        self.preferredRewards = preferredRewards
        self.voiceSensitivity = voiceSensitivity
        self.promptDelaySeconds = promptDelaySeconds
        self.currentDifficultyLevel = currentDifficultyLevel
        self.sessionLengthMinutes = sessionLengthMinutes
        self.rewardIntensity = rewardIntensity
        self.emphasisModeRaw = emphasisModeRaw
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var emphasisMode: EmphasisMode {
        get { EmphasisMode(rawValue: emphasisModeRaw) ?? .mixed }
        set { emphasisModeRaw = newValue.rawValue }
    }

    var displayName: String {
        nickname?.isEmpty == false ? nickname! : name
    }
}

@Model
final class CurriculumItem {
    @Attribute(.unique) var id: UUID
    var category: String
    var subcategory: String
    var targetText: String
    var targetType: String
    var ageMin: Int
    var ageMax: Int
    var difficultyLevel: Int
    var phonemeBreakdown: [String]
    var syllableBreakdown: [String]
    var visemeSequence: [String]
    var relatedObjects: [String]
    var rewardTags: [String]
    var isActive: Bool

    init(
        id: UUID = UUID(),
        category: String,
        subcategory: String,
        targetText: String,
        targetType: String,
        ageMin: Int = 3,
        ageMax: Int = 6,
        difficultyLevel: Int = 1,
        phonemeBreakdown: [String] = [],
        syllableBreakdown: [String] = [],
        visemeSequence: [String] = [],
        relatedObjects: [String] = [],
        rewardTags: [String] = [],
        isActive: Bool = true
    ) {
        self.id = id
        self.category = category
        self.subcategory = subcategory
        self.targetText = targetText
        self.targetType = targetType
        self.ageMin = ageMin
        self.ageMax = ageMax
        self.difficultyLevel = difficultyLevel
        self.phonemeBreakdown = phonemeBreakdown
        self.syllableBreakdown = syllableBreakdown
        self.visemeSequence = visemeSequence
        self.relatedObjects = relatedObjects
        self.rewardTags = rewardTags
        self.isActive = isActive
    }
}

@Model
final class PhraseTemplate {
    @Attribute(.unique) var id: UUID
    var templateText: String
    var category: String
    var slots: [String]
    var examples: [String]

    init(
        id: UUID = UUID(),
        templateText: String,
        category: String,
        slots: [String],
        examples: [String]
    ) {
        self.id = id
        self.templateText = templateText
        self.category = category
        self.slots = slots
        self.examples = examples
    }
}

@Model
final class GameActivity {
    @Attribute(.unique) var id: UUID
    var name: String
    var worldArea: String
    var activityType: String
    var targetCurriculumIds: [UUID]
    var rewardProfileId: UUID?
    var minDifficulty: Int
    var maxDifficulty: Int
    var supportsFallback: Bool
    var supportsSinging: Bool
    var supportsDragging: Bool

    init(
        id: UUID = UUID(),
        name: String,
        worldArea: String,
        activityType: String,
        targetCurriculumIds: [UUID] = [],
        rewardProfileId: UUID? = nil,
        minDifficulty: Int = 1,
        maxDifficulty: Int = 5,
        supportsFallback: Bool = true,
        supportsSinging: Bool = false,
        supportsDragging: Bool = true
    ) {
        self.id = id
        self.name = name
        self.worldArea = worldArea
        self.activityType = activityType
        self.targetCurriculumIds = targetCurriculumIds
        self.rewardProfileId = rewardProfileId
        self.minDifficulty = minDifficulty
        self.maxDifficulty = maxDifficulty
        self.supportsFallback = supportsFallback
        self.supportsSinging = supportsSinging
        self.supportsDragging = supportsDragging
    }
}

@Model
final class Reward {
    @Attribute(.unique) var id: UUID
    var name: String
    var rewardType: String
    var intensityLevel: Int
    var assetName: String
    var unlockCondition: String?
    var tags: [String]

    init(
        id: UUID = UUID(),
        name: String,
        rewardType: String,
        intensityLevel: Int,
        assetName: String,
        unlockCondition: String? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.rewardType = rewardType
        self.intensityLevel = intensityLevel
        self.assetName = assetName
        self.unlockCondition = unlockCondition
        self.tags = tags
    }
}

@Model
final class AttemptLog {
    @Attribute(.unique) var id: UUID
    var childProfileId: UUID
    var curriculumItemId: UUID
    var activityId: UUID
    var timestamp: Date
    var promptText: String
    var responseDetected: Bool
    var responseTier: Int
    var detectedText: String?
    var vocalizationDuration: Double
    var usedFallback: Bool
    var rewardGiven: String
    var sessionId: UUID

    init(
        id: UUID = UUID(),
        childProfileId: UUID,
        curriculumItemId: UUID,
        activityId: UUID,
        timestamp: Date = .now,
        promptText: String,
        responseDetected: Bool,
        responseTier: Int,
        detectedText: String? = nil,
        vocalizationDuration: Double = 0,
        usedFallback: Bool,
        rewardGiven: String,
        sessionId: UUID
    ) {
        self.id = id
        self.childProfileId = childProfileId
        self.curriculumItemId = curriculumItemId
        self.activityId = activityId
        self.timestamp = timestamp
        self.promptText = promptText
        self.responseDetected = responseDetected
        self.responseTier = responseTier
        self.detectedText = detectedText
        self.vocalizationDuration = vocalizationDuration
        self.usedFallback = usedFallback
        self.rewardGiven = rewardGiven
        self.sessionId = sessionId
    }
}

@Model
final class SessionLog {
    @Attribute(.unique) var id: UUID
    var childProfileId: UUID
    var startTime: Date
    var endTime: Date?
    var durationSeconds: Double
    var activitiesPlayed: [UUID]
    var totalPrompts: Int
    var totalVocalAttempts: Int
    var totalFallbacks: Int
    var bestResponseTier: Int
    var notes: String?

    init(
        id: UUID = UUID(),
        childProfileId: UUID,
        startTime: Date = .now,
        endTime: Date? = nil,
        durationSeconds: Double = 0,
        activitiesPlayed: [UUID] = [],
        totalPrompts: Int = 0,
        totalVocalAttempts: Int = 0,
        totalFallbacks: Int = 0,
        bestResponseTier: Int = 0,
        notes: String? = nil
    ) {
        self.id = id
        self.childProfileId = childProfileId
        self.startTime = startTime
        self.endTime = endTime
        self.durationSeconds = durationSeconds
        self.activitiesPlayed = activitiesPlayed
        self.totalPrompts = totalPrompts
        self.totalVocalAttempts = totalVocalAttempts
        self.totalFallbacks = totalFallbacks
        self.bestResponseTier = bestResponseTier
        self.notes = notes
    }
}

@Model
final class UnlockedReward {
    @Attribute(.unique) var id: UUID
    var childProfileId: UUID
    var rewardId: UUID
    var unlockedAt: Date
    var unlockedByCurriculumItemId: UUID?

    init(
        id: UUID = UUID(),
        childProfileId: UUID,
        rewardId: UUID,
        unlockedAt: Date = .now,
        unlockedByCurriculumItemId: UUID? = nil
    ) {
        self.id = id
        self.childProfileId = childProfileId
        self.rewardId = rewardId
        self.unlockedAt = unlockedAt
        self.unlockedByCurriculumItemId = unlockedByCurriculumItemId
    }
}

@Model
final class AudioPrompt {
    @Attribute(.unique) var id: UUID
    var curriculumItemId: UUID
    var text: String
    var phonemes: [String]
    var syllables: [String]
    var visemes: [String]
    var speedOptions: [String]
    var isSong: Bool
    var melodyPattern: [Double]?

    init(
        id: UUID = UUID(),
        curriculumItemId: UUID,
        text: String,
        phonemes: [String] = [],
        syllables: [String] = [],
        visemes: [String] = [],
        speedOptions: [String] = ["normal", "slow"],
        isSong: Bool = false,
        melodyPattern: [Double]? = nil
    ) {
        self.id = id
        self.curriculumItemId = curriculumItemId
        self.text = text
        self.phonemes = phonemes
        self.syllables = syllables
        self.visemes = visemes
        self.speedOptions = speedOptions
        self.isSong = isSong
        self.melodyPattern = melodyPattern
    }
}

enum EmphasisMode: String, CaseIterable, Codable {
    case singing
    case words
    case phrases
    case mixed
}

enum ResponseTier: Int, CaseIterable {
    case none = 0
    case vocalization = 1
    case approximate = 2
    case word = 3
    case phrase = 4
    case sung = 5

    var encouragement: String {
        switch self {
        case .none: return "Nice try. Let's do it together."
        case .vocalization: return "Your voice made magic!"
        case .approximate: return "Nice try! Keep going!"
        case .word: return "Great talking!"
        case .phrase: return "Amazing phrase! You did it!"
        case .sung: return "Let's sing it! Musical magic!"
        }
    }
}
