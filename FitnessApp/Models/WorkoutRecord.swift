import Foundation

struct WorkoutRecord: Codable, Identifiable {
    let id: String
    let date: Date
    let type: WorkoutType
    let duration: TimeInterval
    let exerciseName: String?
    let caloriesEstimate: Int

    init(id: String = UUID().uuidString,
         date: Date = Date(),
         type: WorkoutType,
         duration: TimeInterval,
         exerciseName: String? = nil,
         caloriesEstimate: Int = 0) {
        self.id = id
        self.date = date
        self.type = type
        self.duration = duration
        self.exerciseName = exerciseName
        self.caloriesEstimate = caloriesEstimate
    }

    var formattedDuration: String {
        let mins = Int(duration) / 60
        let secs = Int(duration) % 60
        return String(format: "%d分%02d秒", mins, secs)
    }
}

enum WorkoutType: String, Codable, CaseIterable {
    case strength = "力量训练"
    case cardio = "有氧运动"
    case flexibility = "柔韧训练"
    case hiit = "高强度间歇"
    case custom = "自定义"

    var iconName: String {
        switch self {
        case .strength: return "dumbbell.fill"
        case .cardio: return "figure.run"
        case .flexibility: return "figure.yoga"
        case .hiit: return "flame.fill"
        case .custom: return "star.fill"
        }
    }

    var colorName: String {
        switch self {
        case .strength: return "coral"
        case .cardio: return "oceanBlue"
        case .flexibility: return "mintGreen"
        case .hiit: return "warmAmber"
        case .custom: return "lavender"
        }
    }
}
