import Foundation

struct Exercise: Codable, Identifiable {
    let id: String
    let name: String
    let category: ExerciseCategory
    let description: String
    let difficulty: ExerciseDifficulty
    let targetMuscles: [String]
    let instructions: [String]
    let tips: [String]?
    let iconName: String
    let videoURL: String?

    init(id: String = UUID().uuidString,
         name: String,
         category: ExerciseCategory,
         description: String,
         difficulty: ExerciseDifficulty,
         targetMuscles: [String],
         instructions: [String],
         tips: [String]? = nil,
         iconName: String = "figure.strengthtraining.traditional",
         videoURL: String? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.difficulty = difficulty
        self.targetMuscles = targetMuscles
        self.instructions = instructions
        self.tips = tips
        self.iconName = iconName
        self.videoURL = videoURL
    }
}

enum ExerciseCategory: String, Codable, CaseIterable {
    case chest = "胸部"
    case back = "背部"
    case legs = "腿部"
    case shoulders = "肩部"
    case arms = "手臂"
    case core = "核心"
    case cardio = "有氧"
    case flexibility = "柔韧性"
    case rehabilitation = "康复"

    var iconName: String {
        switch self {
        case .chest: return "figure.strengthtraining.traditional"
        case .back: return "figure.rowing"
        case .legs: return "figure.cross.training"
        case .shoulders: return "figure.american.football"
        case .arms: return "figure.arms.open"
        case .core: return "figure.core.training"
        case .cardio: return "figure.run"
        case .flexibility: return "figure.yoga"
        case .rehabilitation: return "figure.mind.and.body"
        }
    }

    var colorName: String {
        switch self {
        case .chest: return "coral"
        case .back: return "oceanBlue"
        case .legs: return "mintGreen"
        case .shoulders: return "warmAmber"
        case .arms: return "lavender"
        case .core: return "coral"
        case .cardio: return "oceanBlue"
        case .flexibility: return "mintGreen"
        case .rehabilitation: return "stoneGray"
        }
    }
}

enum ExerciseDifficulty: String, Codable {
    case beginner = "初级"
    case intermediate = "中级"
    case advanced = "高级"
}
