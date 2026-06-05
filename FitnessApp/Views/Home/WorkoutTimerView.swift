import SwiftUI

struct WorkoutTimerView: View {
    @Bindable var viewModel: WorkoutViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var showStopConfirmation = false
    @State private var completedRecord: WorkoutRecord?
    @State private var showSummary = false

    var body: some View {
        ZStack {
            backgroundLayer

            if showSummary, let record = completedRecord {
                WorkoutSummaryView(record: record) {
                    dismiss()
                }
            } else {
                VStack(spacing: 36) {
                    headerBar
                    Spacer()
                    timerCircle
                    Spacer()
                    controlButtons
                    calorieInfo
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
        }
        .confirmationDialog("结束训练？", isPresented: $showStopConfirmation, titleVisibility: .visible) {
            Button("结束训练", role: .destructive) {
                let record = viewModel.stopWorkout()
                completedRecord = record
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSummary = true
                }
            }
            Button("继续训练", role: .cancel) {}
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        iconColor
            .opacity(0.08)
            .ignoresSafeArea()
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Button {
                if viewModel.elapsedSeconds == 0 {
                    viewModel.reset()
                    dismiss()
                } else {
                    showStopConfirmation = true
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.mediumGray)
            }

            Spacer()

            VStack(spacing: 2) {
                Image(systemName: viewModel.selectedType?.iconName ?? "figure.run")
                    .font(.title3)
                    .foregroundColor(iconColor)
                Text(viewModel.selectedType?.rawValue ?? "训练中")
                    .font(.fitHeadline)
                    .foregroundColor(.darkText)
            }

            Spacer()

            Color.clear.frame(width: 30, height: 30)
        }
    }

    // MARK: - Timer Circle

    private var timerCircle: some View {
        ZStack {
            Circle()
                .stroke(iconColor.opacity(0.12), lineWidth: 8)
                .frame(width: 240, height: 240)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(iconColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)

            VStack(spacing: 8) {
                Text(viewModel.formattedTime)
                    .font(.system(size: 52, weight: .light, design: .monospaced))
                    .foregroundColor(.darkText)

                if viewModel.isPaused {
                    Text("已暂停")
                        .font(.fitCallout)
                        .foregroundColor(.warmAmber)
                } else if viewModel.elapsedSeconds > 0 {
                    Text("训练中")
                        .font(.fitCallout)
                        .foregroundColor(iconColor)
                }
            }
        }
    }

    // MARK: - Controls

    private var controlButtons: some View {
        HStack(spacing: 32) {
            Button {
                showStopConfirmation = true
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                    Text("结束")
                        .font(.fitCaption)
                }
                .frame(width: 72, height: 72)
                .background(Circle().fill(Color.pureWhite))
                .foregroundColor(.dangerRed)
                .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
            }
            .disabled(viewModel.elapsedSeconds == 0)

            Button {
                viewModel.togglePause()
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                        .font(.title)
                    Text(viewModel.isPaused ? "继续" : "暂停")
                        .font(.fitCaption)
                }
                .frame(width: 88, height: 88)
                .background(Circle().fill(iconColor))
                .foregroundColor(.white)
                .shadow(color: iconColor.opacity(0.4), radius: 8, y: 4)
            }
        }
    }

    // MARK: - Calorie Info

    private var calorieInfo: some View {
        HStack(spacing: 24) {
            statItem(value: "\(viewModel.estimatedCalories)", label: "估算千卡")
            statItem(value: String(format: "%.1f", viewModel.caloriesPerMinute), label: "千卡/分钟")
        }
        .padding(.bottom, 20)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.fitTitle3)
                .foregroundColor(.darkText)
            Text(label)
                .font(.fitCaption2)
                .foregroundColor(.secondaryText)
        }
    }

    // MARK: - Helpers

    private var progress: CGFloat {
        let total: Double = 3600
        return min(CGFloat(viewModel.elapsedSeconds) / CGFloat(total), 1.0)
    }

    private var iconColor: Color {
        switch viewModel.selectedType {
        case .strength: return .coral
        case .cardio: return .oceanBlue
        case .flexibility: return .mintGreen
        case .hiit: return .warmAmber
        case .custom: return .lavender
        case .none: return .oceanBlue
        }
    }
}
