import SwiftUI

struct HealthProfileView: View {
    @State private var viewModel = HealthProfileViewModel()
    @State private var selectedShareCard: ShareCardType?
    @State private var renderedImage: UIImage?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    userHeader
                    statDashboard
                    shareCardsSection
                    trainingHistorySection
                }
                .padding(.bottom, 40)
            }
            .background(Color.lightGray.ignoresSafeArea())
            .navigationTitle("健康档案")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedShareCard) { cardType in
                ShareCardPreview(
                    cardType: cardType,
                    viewModel: viewModel,
                    renderedImage: $renderedImage
                )
            }
        }
    }

    // MARK: - User Header

    private var userHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.oceanBlue)
            Text("健身爱好者")
                .font(.fitTitle3)
                .foregroundColor(.darkText)

            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.fitCaption)
                    .foregroundColor(.coral)
                Text("已坚持训练 \(viewModel.consecutiveDays) 天")
                    .font(.fitCallout)
                    .foregroundColor(.secondaryText)
            }
        }
        .padding(.top, 20)
    }

    // MARK: - Stat Dashboard

    private var statDashboard: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "本周训练", value: "\(viewModel.thisWeekCount)次")
            StatCard(title: "总时长", value: viewModel.formattedTotalDuration)
            StatCard(title: "总消耗", value: "\(viewModel.totalCalories)千卡")
            StatCard(title: "总次数", value: "\(viewModel.totalWorkoutCount)次")
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Share Cards

    private var shareCardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分享卡片")
                .font(.fitHeadline)
                .foregroundColor(.darkText)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ShareCardType.allCases) { cardType in
                        Button {
                            selectedShareCard = cardType
                        } label: {
                            ShareCardThumbnail(type: cardType)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Training History

    private var trainingHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("训练历史")
                .font(.fitHeadline)
                .foregroundColor(.darkText)
                .padding(.horizontal, 20)

            if viewModel.allRecords.isEmpty {
                EmptyStateView(message: "暂无训练历史\n完成一次训练后这里会出现记录")
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.allRecords) { record in
                        TrainingHistoryRow(record: record)
                            .padding(.horizontal, 20)
                    }
                }
            }
        }
    }
}

// MARK: - Training History Row

struct TrainingHistoryRow: View {
    let record: WorkoutRecord

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: record.type.iconName)
                .font(.title3)
                .foregroundColor(colorForType(record.type))
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(colorForType(record.type).opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(record.exerciseName ?? record.type.rawValue)
                    .font(.fitCallout)
                    .foregroundColor(.darkText)
                Text(formattedDate(record.date))
                    .font(.fitCaption)
                    .foregroundColor(.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(record.formattedDuration)
                    .font(.fitCallout)
                    .foregroundColor(.darkText)
                Text("\(record.caloriesEstimate)千卡")
                    .font(.fitCaption)
                    .foregroundColor(.coral)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.pureWhite)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.lightGray, lineWidth: 0.5)
        )
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }

    private func colorForType(_ type: WorkoutType) -> Color {
        switch type {
        case .strength: return .coral
        case .cardio: return .oceanBlue
        case .flexibility: return .mintGreen
        case .hiit: return .warmAmber
        case .custom: return .lavender
        }
    }
}

// MARK: - Share Card Types

enum ShareCardType: String, Identifiable, CaseIterable {
    case today = "今日数据"
    case weekly = "本周概览"
    case summary = "训练总结"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .today: return "sun.max.fill"
        case .weekly: return "calendar.badge.clock"
        case .summary: return "chart.bar.fill"
        }
    }

    var color: Color {
        switch self {
        case .today: return .oceanBlue
        case .weekly: return .mintGreen
        case .summary: return .coral
        }
    }
}

// MARK: - Share Card Thumbnail

struct ShareCardThumbnail: View {
    let type: ShareCardType

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: type.icon)
                .font(.title)
                .foregroundColor(type.color)
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(type.color.opacity(0.1))
                )

            Text(type.rawValue)
                .font(.fitCaption)
                .foregroundColor(.darkText)

            Text("点击预览")
                .font(.fitCaption2)
                .foregroundColor(.mediumGray)
        }
        .frame(width: 100, height: 120)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.pureWhite)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.lightGray, lineWidth: 0.5)
        )
    }
}

// MARK: - Share Card Preview & Export

struct ShareCardPreview: View {
    let cardType: ShareCardType
    let viewModel: HealthProfileViewModel
    @Binding var renderedImage: UIImage?

    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                cardContent
                    .padding(20)

                VStack(spacing: 12) {
                    Button {
                        renderAndShare()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                            Text("导出分享")
                        }
                        .font(.fitHeadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(cardType.color)
                        )
                    }
                    .padding(.horizontal, 20)

                    Button("关闭") { dismiss() }
                        .font(.fitCallout)
                        .foregroundColor(.secondaryText)
                }

                Spacer()
            }
            .background(Color.lightGray.ignoresSafeArea())
            .navigationTitle(cardType.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showShareSheet) {
                if let image = renderedImage {
                    ShareSheet(items: [image])
                }
            }
        }
    }

    @ViewBuilder
    private var cardContent: some View {
        switch cardType {
        case .today:
            TodayDataCard(viewModel: viewModel)
        case .weekly:
            WeeklyOverviewCard(viewModel: viewModel)
        case .summary:
            SummaryCard(viewModel: viewModel)
        }
    }

    private func renderAndShare() {
        let renderer = ImageRenderer(content: cardContent.frame(width: 350))
        renderer.scale = UIScreen.main.scale
        if let image = renderer.uiImage {
            renderedImage = image
            showShareSheet = true
        }
    }
}

// MARK: - Today Data Card

struct TodayDataCard: View {
    let viewModel: HealthProfileViewModel

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedTodayDate())
                        .font(.fitCaption)
                        .foregroundColor(.secondaryText)
                    Text("今日训练数据")
                        .font(.fitTitle2)
                        .foregroundColor(.darkText)
                }
                Spacer()
                Image(systemName: "sun.max.fill")
                    .font(.title)
                    .foregroundColor(.warmAmber)
            }

            HStack(spacing: 0) {
                cardStatItem(value: viewModel.todayRecords.count, unit: "次", label: "训练次数")
                Divider().frame(height: 40)
                cardStatItem(value: Int(viewModel.todayTotalDuration / 60), unit: "分钟", label: "训练时长")
                Divider().frame(height: 40)
                cardStatItem(value: viewModel.todayTotalCalories, unit: "千卡", label: "消耗热量")
            }

            if let last = viewModel.todayRecords.first {
                HStack {
                    Image(systemName: last.type.iconName)
                        .foregroundColor(.oceanBlue)
                    Text(last.type.rawValue)
                        .font(.fitCaption)
                        .foregroundColor(.secondaryText)
                    Spacer()
                    Text("FitMind")
                        .font(.fitCaption)
                        .foregroundColor(.mediumGray)
                }
            }
        }
        .padding(24)
        .background(Color.pureWhite)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.lightGray, lineWidth: 0.5)
        )
    }

    private func cardStatItem(value: Int, unit: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(value)")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.darkText)
                Text(unit)
                    .font(.fitCaption)
                    .foregroundColor(.secondaryText)
            }
            Text(label)
                .font(.fitCaption2)
                .foregroundColor(.mediumGray)
        }
        .frame(maxWidth: .infinity)
    }

    private func formattedTodayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: Date())
    }
}

// MARK: - Weekly Overview Card

struct WeeklyOverviewCard: View {
    let viewModel: HealthProfileViewModel

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("最近7天")
                        .font(.fitCaption)
                        .foregroundColor(.secondaryText)
                    Text("本周训练概览")
                        .font(.fitTitle2)
                        .foregroundColor(.darkText)
                }
                Spacer()
                Image(systemName: "calendar.badge.clock")
                    .font(.title)
                    .foregroundColor(.mintGreen)
            }

            HStack(spacing: 0) {
                cardStatItem(value: viewModel.thisWeekCount, unit: "次", label: "训练次数")
                Divider().frame(height: 40)
                cardStatItem(value: Int(viewModel.thisWeekTotalDuration / 60), unit: "分钟", label: "训练时长")
                Divider().frame(height: 40)
                cardStatItem(value: viewModel.consecutiveDays, unit: "天", label: "连续坚持")
            }

            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.coral)
                Text("保持节奏，你做得很好")
                    .font(.fitCaption)
                    .foregroundColor(.secondaryText)
                Spacer()
                Text("FitMind")
                    .font(.fitCaption)
                    .foregroundColor(.mediumGray)
            }
        }
        .padding(24)
        .background(Color.pureWhite)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.lightGray, lineWidth: 0.5)
        )
    }

    private func cardStatItem(value: Int, unit: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(value)")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.darkText)
                Text(unit)
                    .font(.fitCaption)
                    .foregroundColor(.secondaryText)
            }
            Text(label)
                .font(.fitCaption2)
                .foregroundColor(.mediumGray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Summary Card

struct SummaryCard: View {
    let viewModel: HealthProfileViewModel

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("累计数据")
                        .font(.fitCaption)
                        .foregroundColor(.secondaryText)
                    Text("训练总结")
                        .font(.fitTitle2)
                        .foregroundColor(.darkText)
                }
                Spacer()
                Image(systemName: "chart.bar.fill")
                    .font(.title)
                    .foregroundColor(.coral)
            }

            HStack(spacing: 0) {
                cardStatItem(value: viewModel.totalWorkoutCount, unit: "次", label: "总训练次数")
                Divider().frame(height: 40)
                cardStatItem(value: Int(viewModel.totalDuration / 60), unit: "分钟", label: "总时长")
                Divider().frame(height: 40)
                cardStatItem(value: viewModel.totalCalories, unit: "千卡", label: "总消耗")
            }

            HStack(spacing: 0) {
                cardStatItem(value: viewModel.consecutiveDays, unit: "天", label: "连续坚持")
                Divider().frame(height: 40)
                cardStatItem(value: viewModel.averageCaloriesPerSession, unit: "千卡", label: "平均消耗")
                Divider().frame(height: 40)
                cardStatItem(value: 0, unit: "项", label: "掌握动作")
            }

            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.warmAmber)
                Text("每一滴汗水都算数")
                    .font(.fitCaption)
                    .foregroundColor(.secondaryText)
                Spacer()
                Text("FitMind")
                    .font(.fitCaption)
                    .foregroundColor(.mediumGray)
            }
        }
        .padding(24)
        .background(Color.pureWhite)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.lightGray, lineWidth: 0.5)
        )
    }

    private func cardStatItem(value: Int, unit: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(value)")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.darkText)
                Text(unit)
                    .font(.fitCaption)
                    .foregroundColor(.secondaryText)
            }
            Text(label)
                .font(.fitCaption2)
                .foregroundColor(.mediumGray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Share Sheet (UIKit bridge)

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
