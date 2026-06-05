import Foundation
import SwiftUI
import Combine

@MainActor
class ActivityViewModel: ObservableObject {
    @Published var activities: [Activity] = []
    @Published var isLoading = false
    @Published var joinedActivityIDs: Set<String> = []

    init() {
        loadMockData()
    }

    // MARK: - Mock Data

    private func loadMockData() {
        let now = Date()
        let calendar = Calendar.current

        func date(daysFromNow: Int, hour: Int, minute: Int) -> Date {
            calendar.date(bySettingHour: hour, minute: minute, second: 0, of: calendar.date(byAdding: .day, value: daysFromNow, to: now)!)!
        }

        activities = [
            Activity(
                id: "act-1",
                title: "朝阳公园晨跑团",
                sportType: "有氧运动",
                coverImageURL: nil,
                coverImageData: nil,
                date: date(daysFromNow: 1, hour: 7, minute: 0),
                location: "朝阳公园南门",
                fee: 0,
                maxParticipants: 20,
                currentParticipants: 12,
                description: "每周三次的晨跑活动，沿朝阳公园环形跑道 5 公里。\n\n适合跑步爱好者，不限配速，重在坚持。跑前有 10 分钟热身拉伸，跑后互相交流跑步心得。\n\n注意事项：\n- 请穿着舒适运动鞋\n- 自带饮用水\n- 如遇恶劣天气会在群内通知取消",
                publisherName: "跑者小明",
                isPublished: true
            ),
            Activity(
                id: "act-2",
                title: "CrossFit 燃脂挑战",
                sportType: "HIIT",
                coverImageURL: nil,
                coverImageData: nil,
                date: date(daysFromNow: 2, hour: 18, minute: 30),
                location: "怪兽健身工作室（望京店）",
                fee: 49,
                maxParticipants: 10,
                currentParticipants: 5,
                description: "60 分钟高强度 CrossFit 团体课。\n\n课程内容：\n1. 动态热身 10min\n2. 力量技巧教学 15min\n3. WOD（每日训练）25min\n4. 拉伸放松 10min\n\n适合有一定运动基础的朋友，教练会根据个人能力调整强度。",
                publisherName: "Coach_Lee",
                isPublished: true
            ),
            Activity(
                id: "act-3",
                title: "周末瑜伽放松局",
                sportType: "柔韧性训练",
                coverImageURL: nil,
                coverImageData: nil,
                date: date(daysFromNow: 3, hour: 9, minute: 0),
                location: "三里屯 Lululemon 体验店 3F",
                fee: 0,
                maxParticipants: 15,
                currentParticipants: 15,
                description: "90 分钟哈他瑜伽，适合所有水平。\n\n由持证瑜伽导师带领，从呼吸法开始，逐步进入体式练习，最后以冥想放松结束。\n\n提供瑜伽垫，也可自带。",
                publisherName: "瑜伽导师 Amy",
                isPublished: true
            ),
            Activity(
                id: "act-4",
                title: "周末篮球对抗赛",
                sportType: "有氧运动",
                coverImageURL: nil,
                coverImageData: nil,
                date: date(daysFromNow: 4, hour: 15, minute: 0),
                location: "五棵松篮球公园 3 号场",
                fee: 20,
                maxParticipants: 12,
                currentParticipants: 7,
                description: "4v4 半场对抗，随机分组。\n\n娱乐为主，不看重胜负，目的是出出汗、交朋友。每局 11 分，打完一轮休息 5 分钟。\n\n费用用于场地租赁平摊。自带篮球，现场提供饮水。",
                publisherName: "篮球老张",
                isPublished: true
            ),
            Activity(
                id: "act-5",
                title: "奥森徒步交友",
                sportType: "有氧运动",
                coverImageURL: nil,
                coverImageData: nil,
                date: date(daysFromNow: 5, hour: 8, minute: 30),
                location: "奥林匹克森林公园南门",
                fee: 0,
                maxParticipants: 30,
                currentParticipants: 18,
                description: "沿奥森南园徒步 10 公里，预计 2.5 小时。\n\n途中设置 3 个休息点，每到一个休息点可以互相认识交流，是健身+社交的好机会。\n\n适合各年龄段，走路节奏不紧不慢，边走边聊。",
                publisherName: "户外达人小周",
                isPublished: true
            ),
            Activity(
                id: "act-6",
                title: "杠铃力量入门课",
                sportType: "力量训练",
                coverImageURL: nil,
                coverImageData: nil,
                date: date(daysFromNow: 1, hour: 19, minute: 0),
                location: "铁器时代健身房（中关村店）",
                fee: 79,
                maxParticipants: 6,
                currentParticipants: 3,
                description: "小班教学，针对三大项（深蹲、卧推、硬拉）的技术精讲。\n\n课程安排：\n1. 理论讲解 15min\n2. 空杆动作练习 20min\n3. 个性化负重指导 30min\n4. 辅助训练 15min\n\n适合想系统学习力量训练的新手，教练一对一纠正动作。",
                publisherName: "铁器时代官方",
                isPublished: true
            ),
            Activity(
                id: "act-7",
                title: "攀岩体验团",
                sportType: "力量训练",
                coverImageURL: nil,
                coverImageData: nil,
                date: date(daysFromNow: 2, hour: 14, minute: 0),
                location: "岩时攀岩馆（798 店）",
                fee: 128,
                maxParticipants: 8,
                currentParticipants: 2,
                description: "2 小时攀岩体验，含教练指导和安全带租赁。\n\n不限水平，新手会有 20 分钟入门教学，老手可以直接挑战高难度线路。攀岩后可在馆内咖啡区交流。\n\n费用包含：入场费 + 安全带 + 教练指导。攀岩鞋需额外租赁（¥15）或自带。",
                publisherName: "攀岩老手阿杰",
                isPublished: true
            ),
            Activity(
                id: "act-8",
                title: "夜跑长安街",
                sportType: "有氧运动",
                coverImageURL: nil,
                coverImageData: nil,
                date: date(daysFromNow: 0, hour: 20, minute: 30),
                location: "建国门地铁站 A 口集合",
                fee: 0,
                maxParticipants: 25,
                currentParticipants: 22,
                description: "沿长安街夜跑 8 公里，途经天安门、新华门。\n\n夜风拂面，在长安街的灯光下跑步是一种特别的体验。配速 6-7 分/公里，不快不慢，适合轻松夜跑。\n\n建议穿反光装备，注意交通安全。跑完可自行相约喝豆浆～",
                publisherName: "夜跑队长老王",
                isPublished: true
            )
        ]
    }

    // MARK: - Actions

    func joinActivity(_ activity: Activity) {
        guard let index = activities.firstIndex(where: { $0.id == activity.id }) else { return }
        guard !activities[index].isFull else { return }
        guard !joinedActivityIDs.contains(activity.id) else { return }
        activities[index].currentParticipants += 1
        joinedActivityIDs.insert(activity.id)
        Haptics.success()
    }

    func cancelJoin(_ activity: Activity) {
        guard let index = activities.firstIndex(where: { $0.id == activity.id }) else { return }
        guard joinedActivityIDs.contains(activity.id) else { return }
        activities[index].currentParticipants = max(0, activities[index].currentParticipants - 1)
        joinedActivityIDs.remove(activity.id)
        Haptics.light()
    }

    func isJoined(_ activity: Activity) -> Bool {
        joinedActivityIDs.contains(activity.id)
    }

    func publishActivity(_ draft: ActivityDraft) {
        let newActivity = Activity(
            id: "act-\(UUID().uuidString.prefix(8))",
            title: draft.title,
            sportType: draft.sportType,
            coverImageURL: nil,
            coverImageData: draft.coverImageData,
            date: draft.date,
            location: draft.location,
            fee: draft.isFree ? 0 : draft.fee,
            maxParticipants: draft.maxParticipants,
            currentParticipants: 1,
            description: draft.description,
            publisherName: "我",
            isPublished: true
        )
        activities.insert(newActivity, at: 0)
        Haptics.success()
    }
}

// MARK: - Activity Draft (发布表单数据)

struct ActivityDraft {
    var title = ""
    var sportType = "有氧运动"
    var date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    var location = ""
    var isFree = true
    var fee: Double = 0
    var maxParticipants = 10
    var description = ""
    var coverImageData: Data?
    var paymentMethod: PaymentMethod = .wechat

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

enum PaymentMethod: String, CaseIterable {
    case wechat = "微信支付"
    case alipay = "支付宝"
}
