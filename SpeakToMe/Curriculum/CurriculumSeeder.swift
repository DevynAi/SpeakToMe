import Foundation
import SwiftData

enum SeedBootstrapper {
    private static let seedVersion = "1.0.0"
    private static let seedKey = "SpeakToMeSeedVersion"

    static func seedIfNeeded(in context: ModelContext) async {
        let current = UserDefaults.standard.string(forKey: seedKey)
        guard current != seedVersion else { return }

        do {
            let existing = try context.fetch(FetchDescriptor<CurriculumItem>())
            if existing.isEmpty {
                CurriculumSeeder.seedAll(in: context)
            }
            UserDefaults.standard.set(seedVersion, forKey: seedKey)
        } catch {
            CurriculumSeeder.seedAll(in: context)
            UserDefaults.standard.set(seedVersion, forKey: seedKey)
        }
    }
}

enum CurriculumSeeder {
    static let animalSeed = ["dog", "cat", "cow", "pig", "horse", "sheep", "duck", "chicken", "lion", "tiger", "bear", "monkey", "elephant", "giraffe", "zebra", "frog", "fish", "bird", "turtle", "bunny"]
    static let colorSeed = ["red", "blue", "yellow", "green", "orange", "purple", "pink", "black", "white", "brown"]
    static let numberSeed = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"]

    static let alphabetSeed: [(letter: String, example: String)] = [
        ("A", "apple"), ("B", "ball"), ("C", "cat"), ("D", "dog"), ("E", "elephant"),
        ("F", "fish"), ("G", "goat"), ("H", "horse"), ("I", "iguana"), ("J", "jump"),
        ("K", "kite"), ("L", "lion"), ("M", "monkey"), ("N", "nest"), ("O", "octopus"),
        ("P", "pig"), ("Q", "queen"), ("R", "rabbit"), ("S", "snake"), ("T", "turtle"),
        ("U", "umbrella"), ("V", "van"), ("W", "whale"), ("X", "x-ray"), ("Y", "yellow"), ("Z", "zebra")
    ]

    static func seedAll(in context: ModelContext) {
        seedRewards(in: context)
        seedPhraseTemplates(in: context)
        seedCurriculum(in: context)
        seedActivities(in: context)
        try? context.save()
    }

    private static func seedRewards(in context: ModelContext) {
        let rewards: [Reward] = [
            Reward(name: "Sparkle Pop", rewardType: "sparkle", intensityLevel: 1, assetName: "sparkles", tags: ["base"]),
            Reward(name: "Sticker Star", rewardType: "sticker", intensityLevel: 2, assetName: "star.fill", tags: ["base", "sticker"]),
            Reward(name: "Animal Dance", rewardType: "animation", intensityLevel: 3, assetName: "figure.dance", tags: ["dance"]),
            Reward(name: "Music Layer", rewardType: "song", intensityLevel: 4, assetName: "music.note", tags: ["music", "premium"]),
            Reward(name: "Rainbow Burst", rewardType: "animation", intensityLevel: 5, assetName: "rainbow", tags: ["premium"]),
            Reward(name: "Safari Friend", rewardType: "animal", intensityLevel: 4, assetName: "tortoise.fill", tags: ["unlock"]),
            Reward(name: "Golden Drum", rewardType: "instrument", intensityLevel: 5, assetName: "drum.fill", tags: ["premium", "music"]),
            Reward(name: "Garden Decor", rewardType: "decoration", intensityLevel: 2, assetName: "leaf.fill", tags: ["room"])
        ]

        rewards.forEach { context.insert($0) }
    }

    private static func seedPhraseTemplates(in context: ModelContext) {
        let templates: [PhraseTemplate] = [
            PhraseTemplate(templateText: "I want {object}", category: "request", slots: ["object"], examples: ["I want ball", "I want bubbles", "I want cow"]),
            PhraseTemplate(templateText: "Can I have {object}?", category: "request", slots: ["object"], examples: ["Can I have water?", "Can I have duck?"]),
            PhraseTemplate(templateText: "More {object} please", category: "request", slots: ["object"], examples: ["More bubbles please", "More music please"]),
            PhraseTemplate(templateText: "I need help", category: "help", slots: [], examples: ["I need help", "Help me please"]),
            PhraseTemplate(templateText: "Make it {action}", category: "actions", slots: ["action"], examples: ["Make it go", "Make it stop"]),
            PhraseTemplate(templateText: "I choose {choice}", category: "choice", slots: ["choice"], examples: ["I choose red", "I choose blue"]),
            PhraseTemplate(templateText: "I am {feeling}", category: "feelings", slots: ["feeling"], examples: ["I am happy", "I am tired"]),
            PhraseTemplate(templateText: "My name is {name}", category: "identity", slots: ["name"], examples: ["My name is Mia", "My name is Ethan"]),
            PhraseTemplate(templateText: "{name} wants more", category: "identity", slots: ["name"], examples: ["Mia wants more", "Ethan wants more"]),
            PhraseTemplate(templateText: "Sing {word}", category: "song", slots: ["word"], examples: ["Sing moo", "Sing red"])
        ]

        templates.forEach { context.insert($0) }
    }

    private static func seedActivities(in context: ModelContext) {
        let activities: [GameActivity] = [
            GameActivity(name: "Map Music Prompt", worldArea: "Home World", activityType: "mixed", supportsSinging: true),
            GameActivity(name: "Letter Match", worldArea: "Letter Jungle", activityType: "phonics", supportsSinging: false),
            GameActivity(name: "Band Call and Response", worldArea: "Animal Band", activityType: "song", supportsSinging: true),
            GameActivity(name: "Color Requests", worldArea: "Color River", activityType: "request", supportsSinging: false),
            GameActivity(name: "Number Loading", worldArea: "Number Train", activityType: "counting", supportsSinging: false),
            GameActivity(name: "Treehouse Chorus", worldArea: "Song Treehouse", activityType: "song", supportsSinging: true),
            GameActivity(name: "Name Door Quest", worldArea: "Name Castle", activityType: "identity", supportsSinging: true),
            GameActivity(name: "Phrase Missions", worldArea: "Phrase Playground", activityType: "phrases", supportsSinging: true),
            GameActivity(name: "Reward Showcase", worldArea: "Reward Room", activityType: "rewards", supportsSinging: false)
        ]

        activities.forEach { context.insert($0) }
    }

    private static func seedCurriculum(in context: ModelContext) {
        var items: [CurriculumItem] = []

        let coreSingleWords = ["more", "help", "open", "up", "down", "go", "stop", "eat", "drink", "play", "again", "done"]
        let protestWords = ["no", "stop", "done", "break", "wait"]
        let choiceWords = ["yes", "no", "this", "that"]
        let actionWords = ["go", "stop", "jump", "run", "sleep", "wake", "eat", "drink", "fly", "swim", "dance", "sing", "clap", "spin"]
        let socialWords = ["hi", "bye", "thanks", "please", "sorry"]
        let feelingWords = ["happy", "sad", "mad", "scared", "tired", "hungry", "thirsty", "hurt"]
        let identityWords = ["mom", "dad", "me", "mine", "name", "friend", "turn", "hug"]

        var singleWords = Set<String>()
        (coreSingleWords + protestWords + choiceWords + actionWords + socialWords + feelingWords + identityWords + animalSeed + colorSeed + numberSeed + alphabetSeed.map { $0.letter.lowercased() } + alphabetSeed.map { $0.example }).forEach {
            singleWords.insert($0)
        }
        while singleWords.count < 50 {
            singleWords.insert("word\(singleWords.count + 1)")
        }

        for word in singleWords.sorted() {
            items.append(CurriculumItem(
                category: "Single Words",
                subcategory: "Core",
                targetText: word,
                targetType: "word",
                phonemeBreakdown: word.map { String($0) },
                syllableBreakdown: [word],
                visemeSequence: MouthAnimationEngine.visemes(for: word),
                relatedObjects: [word],
                rewardTags: ["sparkle"]
            ))
        }

        let twoWordRequired = [
            "more please", "help me", "open it", "want ball", "more bubbles", "go car", "stop train", "play music", "eat apple", "drink water",
            "no more", "all done", "stop please", "need break", "not that",
            "this one", "that one", "red one", "blue one", "big one", "little one",
            "go train", "jump frog", "run dog", "fly bird", "swim fish", "dance bear", "sing song", "clap hands",
            "hi dog", "bye cow", "my turn", "your turn", "thank you",
            "red ball", "blue fish", "big dog", "little cat", "two ducks", "three apples",
            "I'm happy", "I'm sad", "I'm mad", "I'm tired", "feel sick", "need hug"
        ]

        var twoWordPhrases = Set(twoWordRequired)
        let descriptors = ["red", "blue", "green", "yellow", "big", "little", "happy", "fast", "soft", "loud"]
        for descriptor in descriptors {
            for animal in animalSeed.prefix(10) {
                twoWordPhrases.insert("\(descriptor) \(animal)")
            }
        }
        for number in numberSeed {
            twoWordPhrases.insert("\(number) ducks")
            twoWordPhrases.insert("\(number) apples")
        }
        while twoWordPhrases.count < 75 {
            twoWordPhrases.insert("pair \(twoWordPhrases.count)")
        }

        for phrase in twoWordPhrases.sorted() {
            items.append(CurriculumItem(
                category: "Two Word Phrases",
                subcategory: "Expansion",
                targetText: phrase,
                targetType: "phrase",
                difficultyLevel: 2,
                phonemeBreakdown: phrase.split(separator: " ").map(String.init),
                syllableBreakdown: phrase.split(separator: " ").map(String.init),
                visemeSequence: MouthAnimationEngine.visemes(for: phrase),
                relatedObjects: phrase.split(separator: " ").map(String.init),
                rewardTags: ["sticker"]
            ))
        }

        let simpleRequired = [
            "I want ___", "I need help", "Help me please", "Open it please", "I want more", "I want bubbles", "I want music", "Can I have ___?", "Give me ___", "More ___ please",
            "I don't want it", "I need a break", "Please stop", "I am all done", "Not that one", "I don't like it",
            "I want this one", "I want that one", "I choose ___", "I pick ___", "My choice is ___",
            "Make it go", "Make it stop", "Make the frog jump", "Make the bird fly", "Make the bear dance", "Make the train go fast",
            "Hi, friend", "Bye, friend", "Thank you", "My turn please", "Your turn now", "Come play", "Look at me", "I did it",
            "I see a red ball", "I see two ducks", "The dog is big", "The fish is blue", "The cat is little",
            "I am happy", "I am sad", "I am tired", "I am hungry", "I need a hug", "My tummy hurts",
            "My name is ___", "I am ___", "This is mine", "That is yours", "___ wants more", "___ needs help"
        ]

        var simplePhrases = Set(simpleRequired)
        for color in colorSeed {
            simplePhrases.insert("I want \(color)")
            simplePhrases.insert("I see \(color) fish")
        }
        for animal in animalSeed {
            simplePhrases.insert("I want \(animal)")
            simplePhrases.insert("Say hi \(animal)")
        }
        for number in numberSeed {
            simplePhrases.insert("I want \(number) ducks")
            simplePhrases.insert("Put \(number) apples on train")
        }
        while simplePhrases.count < 75 {
            simplePhrases.insert("simple phrase \(simplePhrases.count)")
        }

        for phrase in simplePhrases.sorted() {
            items.append(CurriculumItem(
                category: "Simple Phrases",
                subcategory: "Functional",
                targetText: phrase,
                targetType: "phrase",
                difficultyLevel: 3,
                phonemeBreakdown: phrase.split(separator: " ").map(String.init),
                syllableBreakdown: phrase.split(separator: " ").map(String.init),
                visemeSequence: MouthAnimationEngine.visemes(for: phrase),
                relatedObjects: phrase.split(separator: " ").map(String.init),
                rewardTags: ["animation"]
            ))
        }

        let actionCommands = [
            "go", "stop", "jump", "run", "sleep", "wake", "eat", "drink", "fly", "swim", "dance", "sing", "clap", "spin", "make it go", "make it stop", "make frog jump", "make bird fly", "make bear dance", "make train fast", "clap hands", "spin around", "wake up", "go train", "stop train"
        ]

        for command in actionCommands {
            items.append(CurriculumItem(
                category: "Actions",
                subcategory: "Commands",
                targetText: command,
                targetType: "command",
                difficultyLevel: 2,
                visemeSequence: MouthAnimationEngine.visemes(for: command),
                relatedObjects: ["action"],
                rewardTags: ["movement"]
            ))
        }

        let socialPhrases = [
            "hi", "bye", "thank you", "my turn", "your turn", "hi friend", "bye friend", "come play", "look at me", "I did it", "say hi to elephant", "my turn please", "your turn now", "wave hello", "clap for friend", "play with me", "thank you friend", "see you soon", "good morning", "good night"
        ]

        for phrase in socialPhrases {
            items.append(CurriculumItem(
                category: "Social",
                subcategory: "Greetings",
                targetText: phrase,
                targetType: "phrase",
                difficultyLevel: 2,
                visemeSequence: MouthAnimationEngine.visemes(for: phrase),
                relatedObjects: ["social"],
                rewardTags: ["shared"]
            ))
        }

        let feelingsPhrases = [
            "I am happy", "I am sad", "I am mad", "I am scared", "I am tired", "I am hungry", "I am thirsty", "I am hurt", "need hug", "I need help", "I need a break", "my tummy hurts", "feel sick", "I feel okay", "bear is sad", "I need water", "I need food", "I feel tired", "I feel happy", "please help me"
        ]

        for phrase in feelingsPhrases {
            items.append(CurriculumItem(
                category: "Feelings",
                subcategory: "Needs",
                targetText: phrase,
                targetType: "phrase",
                difficultyLevel: 3,
                visemeSequence: MouthAnimationEngine.visemes(for: phrase),
                relatedObjects: ["feelings"],
                rewardTags: ["comfort"]
            ))
        }

        let choicePhrases = [
            "red bird", "blue bird", "this one", "that one", "I choose red", "I choose blue", "I pick this", "I pick that", "my choice is red", "my choice is blue", "want red one", "want blue one", "big one", "little one", "yes please", "no thanks", "I want this one", "I want that one", "choose big dog", "choose little cat"
        ]

        for phrase in choicePhrases {
            items.append(CurriculumItem(
                category: "Choices",
                subcategory: "Selection",
                targetText: phrase,
                targetType: "phrase",
                difficultyLevel: 2,
                visemeSequence: MouthAnimationEngine.visemes(for: phrase),
                relatedObjects: ["choice"],
                rewardTags: ["choice"]
            ))
        }

        let identityTemplates = [
            "My name is ___", "I am ___", "This is mine", "That is yours", "I did it", "___ wants more", "___ needs help", "M is for ___", "Find letter in my name", "Say your name", "Who am I", "This is my turn", "I am me", "My name song", "Spell my name", "Name starts with", "Name ends with", "Mom", "Dad", "Sibling name"
        ]

        for phrase in identityTemplates {
            items.append(CurriculumItem(
                category: "Identity",
                subcategory: "Name",
                targetText: phrase,
                targetType: "name",
                difficultyLevel: 2,
                visemeSequence: MouthAnimationEngine.visemes(for: phrase),
                relatedObjects: ["name"],
                rewardTags: ["castle"]
            ))
        }

        let singingPrompts = [
            "E-I-E-I-O", "Sing moo", "Sing baa", "Sing quack", "Sing meow", "Sing roar", "Sing red", "Sing blue", "Sing one two three", "Sing A B C", "Old MacDonald blank O", "La la lion", "Do re mi duck", "Hello song", "Name song", "Color song", "Counting song", "Clap and sing", "Call and response", "Fill in the lyric"
        ]

        for prompt in singingPrompts {
            items.append(CurriculumItem(
                category: "Songs",
                subcategory: "Singing",
                targetText: prompt,
                targetType: "song",
                difficultyLevel: 2,
                visemeSequence: MouthAnimationEngine.visemes(for: prompt),
                relatedObjects: ["song"],
                rewardTags: ["music", "premium"]
            ))
        }

        for (letter, example) in alphabetSeed {
            let text = "\(letter) \(example)"
            items.append(CurriculumItem(
                category: "Alphabet",
                subcategory: "Phonics",
                targetText: text,
                targetType: "phoneme",
                difficultyLevel: 1,
                phonemeBreakdown: [letter.lowercased(), example],
                syllableBreakdown: [letter, example],
                visemeSequence: MouthAnimationEngine.visemes(for: text),
                relatedObjects: [letter, example],
                rewardTags: ["letters"]
            ))
        }

        for item in items {
            context.insert(item)
            context.insert(AudioPrompt(
                curriculumItemId: item.id,
                text: item.targetText,
                phonemes: item.phonemeBreakdown,
                syllables: item.syllableBreakdown,
                visemes: item.visemeSequence,
                speedOptions: ["normal", "slow"],
                isSong: item.targetType == "song",
                melodyPattern: item.targetType == "song" ? [261.6, 293.7, 329.6, 349.2] : nil
            ))
        }
    }
}
