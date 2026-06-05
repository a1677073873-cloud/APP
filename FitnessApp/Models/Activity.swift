import Foundation
import UIKit

/// 运动活动模型
struct Activity: Identifiable, Codable {
    let id: String
    let title: String
    let sportType: String          // WorkoutType 的 rawValue
    let coverImageURL: String?     // 远程封面图 URL
    let coverImageData: Data?      // 本地封面图数据
    let startDate: Date
    let endDate: Date
    let location: String
    let fee: Double                // 0 = 免费
    let maxParticipants: Int
    var currentParticipants: Int
    let description: String
    let publisherName: String
    let isPublished: Bool

    var coverImage: UIImage? {
        guard let data = coverImageData else { return nil }
        return UIImage(data: data)
    }

    // MARK: Computed

    var isFree: Bool { fee == 0 }
    var isFull: Bool { currentParticipants >= maxParticipants }
    var remainingSpots: Int { max(0, maxParticipants - currentParticipants) }
    var formattedFee: String { isFree ? "免费" : "¥\(String(format: "%.0f", fee))" }

    var formattedDate: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "MM月dd日"
        return f.string(from: startDate)
    }

    var formattedTimeRange: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "HH:mm"
        return "\(f.string(from: startDate)) - \(f.string(from: endDate))"
    }

    var formattedDateTime: String {
        "\(formattedDate) \(formattedTimeRange)"
    }

    var participantsText: String { "\(currentParticipants)/\(maxParticipants)人" }

    /// 判断是否与另一个活动时间重叠
    func overlaps(with other: Activity) -> Bool {
        startDate < other.endDate && endDate > other.startDate
    }
}

// MARK: - 运动类型颜色映射

extension Activity {
    var sportColor: String {
        switch sportType {
        case "力量训练": return "coral"
        case "有氧运动": return "oceanBlue"
        case "柔韧性训练": return "mintGreen"
        case "HIIT": return "warmAmber"
        case "自定义": return "lavender"
        default: return "stoneGray"
        }
    }

    var sportIcon: String {
        switch sportType {
        case "力量训练": return "dumbbell.fill"
        case "有氧运动": return "heart.circle.fill"
        case "柔韧性训练": return "figure.mind.and.body"
        case "HIIT": return "flame.fill"
        case "自定义": return "star.fill"
        default: return "figure.run"
        }
    }
}
