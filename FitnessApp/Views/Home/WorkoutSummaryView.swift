import SwiftUI

struct WorkoutSummaryView: View {
    let record: WorkoutRecord
    var onDismiss: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 28) {
            Spacer().frame(height: 24)

            Text("训练完成")
                .font(.fitTitle1)
                .foregroundColor(.darkText)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(iconColor)

            VStack(spacing: 12) {
                summaryRow(icon: "figure.run", label: "运动类型", value: record.type.rawValue)
                Divider()
                summaryRow(icon: "clock", label: "训练时长", value: record.formattedDuration)
                Divider()
                summaryRow(icon: "flame", label: "估算消耗", value: "~\(record.caloriesEstimate) 千卡")
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.pureWhite))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.lightGray, lineWidth: 0.5))
            .padding(.horizontal, 40)

            Text("太棒了，继续保持！")
                .font(.fitCallout)
                .foregroundColor(.secondaryText)

            Spacer()

            FitButton(title: "完成", style: .primary) {
                if let onDismiss = onDismiss {
                    onDismiss()
                } else {
                    dismiss()
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(Color.lightGray.ignoresSafeArea())
    }

    private func summaryRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24)
            Text(label)
                .font(.fitBody)
                .foregroundColor(.secondaryText)
            Spacer()
            Text(value)
                .font(.fitHeadline)
                .foregroundColor(.darkText)
        }
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
