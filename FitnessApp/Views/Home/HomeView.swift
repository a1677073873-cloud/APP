import SwiftUI

struct HomeView: View {
    @State private var viewModel = WorkoutViewModel()
    @State private var showTimer = false
    @State private var showAICoach = false

    private let store = WorkoutStore.shared

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "早上好"
        case 12..<14: return "中午好"
        case 14..<18: return "下午好"
        default: return "晚上好"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    greetingHeader
                    workoutTypeSelector
                    startButton
                    recentRecordsSection
                }
                .padding(.vertical, 20)
            }
            .background(Color.lightGray.ignoresSafeArea())
            .navigationTitle("训练台")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showTimer) {
                WorkoutTimerView(viewModel: viewModel)
            }
            .overlay(alignment: .bottomTrailing) {
                AICoachFloatingBall(showAICoach: $showAICoach)
            }
            .fullScreenCover(isPresented: $showAICoach) {
                AICoachView(dismissAction: { showAICoach = false })
            }
        }
    }

    // MARK: - Greeting

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.fitTitle2)
                .foregroundColor(.secondaryText)
            Text("开始今天的训练吧")
                .font(.fitLargeTitle)
                .foregroundColor(.darkText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    // MARK: - Type Selector

    private var workoutTypeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择运动类型")
                .font(.fitHeadline)
                .foregroundColor(.darkText)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(WorkoutType.allCases, id: \.self) { type in
                        WorkoutTypeCard(
                            type: type,
                            isSelected: viewModel.selectedType == type
                        ) {
                            Haptics.light()
                            viewModel.selectedType = type
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Start Button

    private var startButton: some View {
        FitButton(
            title: viewModel.selectedType == nil ? "选择运动类型开始" : "开始\(viewModel.selectedType!.rawValue)",
            style: .primary,
            icon: "play.fill",
            isDisabled: viewModel.selectedType == nil
        ) {
            if let type = viewModel.selectedType {
                Haptics.medium()
                viewModel.startWorkout(type: type)
                showTimer = true
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Recent Records

    private var recentRecordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近记录")
                .font(.fitHeadline)
                .foregroundColor(.darkText)
                .padding(.horizontal, 20)

            let records = store.recentRecords()
            if records.isEmpty {
                EmptyStateView(message: "还没有训练记录\n开始你的第一次训练吧")
                    .padding(.horizontal, 20)
            } else {
                VStack(spacing: 10) {
                    ForEach(records) { record in
                        RecentRecordRow(record: record)
                            .padding(.horizontal, 20)
                    }
                }
            }
        }
    }
}

// MARK: - Workout Type Card

struct WorkoutTypeCard: View {
    let type: WorkoutType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.iconName)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : iconColor)

                Text(type.rawValue)
                    .font(.fitCaption)
                    .foregroundColor(isSelected ? .white : .darkText)
            }
            .frame(width: 78, height: 78)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? iconColor : Color.pureWhite)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : Color.lightGray, lineWidth: 1)
            )
            .shadow(color: isSelected ? iconColor.opacity(0.3) : Color.black.opacity(0.04), radius: 6, y: 2)
        }
    }

    private var iconColor: Color {
        switch type {
        case .strength: return .coral
        case .cardio: return .oceanBlue
        case .flexibility: return .mintGreen
        case .hiit: return .warmAmber
        case .custom: return .lavender
        }
    }
}

// MARK: - Recent Record Row

struct RecentRecordRow: View {
    let record: WorkoutRecord

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: record.type.iconName)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(RoundedRectangle(cornerRadius: 10).fill(iconColor.opacity(0.12)))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.exerciseName ?? record.type.rawValue)
                    .font(.fitCallout)
                    .foregroundColor(.darkText)
                Text(record.date.formatted(date: .numeric, time: .shortened))
                    .font(.fitCaption2)
                    .foregroundColor(.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(record.formattedDuration)
                    .font(.fitCaption)
                    .foregroundColor(.darkText)
                Text("~\(record.caloriesEstimate)千卡")
                    .font(.fitCaption2)
                    .foregroundColor(.secondaryText)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.pureWhite))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.lightGray, lineWidth: 0.5))
    }

    private var iconColor: Color {
        switch record.type {
        case .strength: return .coral
        case .cardio: return .oceanBlue
        case .flexibility: return .mintGreen
        case .hiit: return .warmAmber
        case .custom: return .lavender
        }
    }
}
