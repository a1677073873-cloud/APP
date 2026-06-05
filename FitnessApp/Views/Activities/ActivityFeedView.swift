import SwiftUI

/// 运动活动列表页 — 卡片流
struct ActivityFeedView: View {
    @StateObject private var viewModel = ActivityViewModel()
    @State private var searchText = ""

    private var filteredActivities: [Activity] {
        guard !searchText.isEmpty else { return viewModel.activities }
        let q = searchText.lowercased()
        return viewModel.activities.filter {
            $0.title.lowercased().contains(q) ||
            $0.sportType.lowercased().contains(q) ||
            $0.location.lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                FitSearchBar(text: $searchText, placeholder: "搜索活动、运动类型、地点...")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                ScrollView {
                    LazyVStack(spacing: 16) {
                        if filteredActivities.isEmpty {
                            EmptyStateView(message: searchText.isEmpty ? "暂无活动\n快发布第一个活动吧" : "未找到匹配的活动")
                                .padding(.top, 80)
                        } else {
                            ForEach(filteredActivities) { activity in
                                NavigationLink(destination: ActivityDetailView(activity: activity, viewModel: viewModel)) {
                                    ActivityCard(activity: activity)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .background(Color.lightGray.ignoresSafeArea())
            .navigationTitle("发现活动")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: PublishActivityView(viewModel: viewModel)) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.coral)
                    }
                }
            }
        }
    }
}

// MARK: - Activity Card

struct ActivityCard: View {
    let activity: Activity

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 封面占位 — 横向通栏
            coverPlaceholder

            // 信息区
            VStack(alignment: .leading, spacing: 8) {
                // 标题 + 状态标签
                HStack(alignment: .center, spacing: 8) {
                    Text(activity.title)
                        .font(.fitHeadline)
                        .foregroundColor(.darkText)
                        .lineLimit(1)

                    Spacer()

                    if activity.isFull {
                        TagChip(label: "已满", color: .dangerRed)
                    } else if activity.remainingSpots <= 3 {
                        TagChip(label: "仅剩\(activity.remainingSpots)位", color: .warmAmber)
                    }
                }

                // 运动类型 Tag
                SportTag(label: activity.sportType, color: sportTagColor)

                // 时间 + 费用
                HStack(spacing: 16) {
                    LabelRow(icon: "calendar", text: activity.formattedDateTime)
                    LabelRow(icon: activity.isFree ? "ticket" : "dollarsign.circle", text: activity.formattedFee)
                }

                // 地点
                LabelRow(icon: "mappin.and.ellipse", text: activity.location)

                // 人数
                HStack(spacing: 0) {
                    LabelRow(icon: "person.2", text: "\(activity.participantsText) 已报名")
                    Spacer()
                    // 简易进度条
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.lightGray)
                                .frame(height: 4)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(progressColor)
                                .frame(width: geo.size.width * progressRatio, height: 4)
                        }
                    }
                    .frame(width: 60, height: 4)
                }
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.pureWhite)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.lightGray, lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    private var progressRatio: CGFloat {
        guard activity.maxParticipants > 0 else { return 0 }
        return CGFloat(activity.currentParticipants) / CGFloat(activity.maxParticipants)
    }

    private var progressColor: Color {
        if activity.isFull { return .dangerRed }
        if progressRatio > 0.7 { return .warmAmber }
        return .mintGreen
    }

    // MARK: Cover Placeholder

    private var coverPlaceholder: some View {
        Group {
            if let image = activity.coverImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 130)
                    .clipped()
            } else {
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [gradientStart, gradientEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    VStack(spacing: 6) {
                        Image(systemName: activity.sportIcon)
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.85))
                        Text(activity.sportType)
                            .font(.fitCaption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .frame(height: 130)
            }
        }
        .frame(height: 130)
        .overlay(alignment: .topTrailing) {
            if !activity.isFree {
                Text("¥\(String(format: "%.0f", activity.fee))")
                    .font(.fitCaption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.55))
                    )
                    .padding(10)
            }
        }
        .clipShape(
            UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 16)
        )
    }

    private var gradientStart: Color {
        switch activity.sportType {
        case "力量训练": return .coral
        case "有氧运动": return .oceanBlue
        case "柔韧性训练": return .mintGreen
        case "HIIT": return .warmAmber
        case "自定义": return .lavender
        default: return .stoneGray
        }
    }

    private var gradientEnd: Color {
        switch activity.sportType {
        case "力量训练": return .coral.opacity(0.5)
        case "有氧运动": return .oceanBlue.opacity(0.5)
        case "柔韧性训练": return .mintGreen.opacity(0.5)
        case "HIIT": return .warmAmber.opacity(0.5)
        case "自定义": return .lavender.opacity(0.5)
        default: return .stoneGray.opacity(0.5)
        }
    }

    private var sportTagColor: Color {
        switch activity.sportType {
        case "力量训练": return .coral
        case "有氧运动": return .oceanBlue
        case "柔韧性训练": return .mintGreen
        case "HIIT": return .warmAmber
        case "自定义": return .lavender
        default: return .stoneGray
        }
    }
}

// MARK: - Subviews

struct SportTag: View {
    let label: String
    let color: Color

    var body: some View {
        Text(label)
            .font(.fitCaption2)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.12))
            )
    }
}

struct TagChip: View {
    let label: String
    let color: Color

    var body: some View {
        Text(label)
            .font(.fitCaption2)
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.12))
            )
    }
}

struct LabelRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(.mediumGray)
                .frame(width: 14)
            Text(text)
                .font(.fitCaption2)
                .foregroundColor(.secondaryText)
                .lineLimit(1)
        }
    }
}

// MARK: - Preview

#Preview {
    ActivityFeedView()
}
