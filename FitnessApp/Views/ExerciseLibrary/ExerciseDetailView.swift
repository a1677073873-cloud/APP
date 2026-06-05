import SwiftUI
import AVKit

struct ExerciseDetailView: View {
    let exercise: Exercise

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                if let videoURL = exercise.videoURL, let url = URL(string: videoURL) {
                    videoSection(url)
                }
                descriptionSection
                targetMusclesSection
                instructionsSection
                if let tips = exercise.tips, !tips.isEmpty {
                    tipsSection(tips)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .background(Color.lightGray.ignoresSafeArea())
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: exercise.category.iconName)
                .font(.system(size: 44))
                .foregroundColor(categoryColor)

            HStack(spacing: 10) {
                Text(exercise.category.rawValue)
                    .font(.fitCaption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(categoryColor.opacity(0.15)))
                    .foregroundColor(categoryColor)

                DifficultyBadge(difficulty: exercise.difficulty)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.pureWhite))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.lightGray, lineWidth: 0.5))
    }

    // MARK: - Video

    private func videoSection(_ url: URL) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("教学视频", systemImage: "play.rectangle")
                .font(.fitHeadline)
                .foregroundColor(.darkText)

            VideoPlayer(player: AVPlayer(url: url))
                .frame(height: 220)
                .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.pureWhite))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.lightGray, lineWidth: 0.5))
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("动作介绍", systemImage: "text.alignleft")
                .font(.fitHeadline)
                .foregroundColor(.darkText)
            Text(exercise.description)
                .font(.fitBody)
                .foregroundColor(.secondaryText)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.pureWhite))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.lightGray, lineWidth: 0.5))
    }

    // MARK: - Target Muscles

    private var targetMusclesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("目标肌群", systemImage: "figure.strengthtraining.traditional")
                .font(.fitHeadline)
                .foregroundColor(.darkText)

            WrapLayout(spacing: 8) {
                ForEach(exercise.targetMuscles, id: \.self) { muscle in
                    Text(muscle)
                        .font(.fitCaption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 8).fill(categoryColor.opacity(0.12)))
                        .foregroundColor(categoryColor)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.pureWhite))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.lightGray, lineWidth: 0.5))
    }

    // MARK: - Instructions

    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("动作步骤", systemImage: "list.number")
                .font(.fitHeadline)
                .foregroundColor(.darkText)

            VStack(spacing: 0) {
                ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(categoryColor)
                                .frame(width: 22, height: 22)
                            Text("\(index + 1)")
                                .font(.fitCaption2)
                                .foregroundColor(.white)
                        }

                        Text(step)
                            .font(.fitBody)
                            .foregroundColor(.darkText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 10)

                    if index < exercise.instructions.count - 1 {
                        Divider().padding(.leading, 34)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.pureWhite))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.lightGray, lineWidth: 0.5))
    }

    // MARK: - Tips

    private func tipsSection(_ tips: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("小贴士", systemImage: "lightbulb")
                .font(.fitHeadline)
                .foregroundColor(.darkText)

            VStack(spacing: 8) {
                ForEach(tips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "sparkle")
                            .font(.caption)
                            .foregroundColor(.warmAmber)
                            .padding(.top, 2)

                        Text(tip)
                            .font(.fitBody)
                            .foregroundColor(.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.pureWhite))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.lightGray, lineWidth: 0.5))
    }

    private var categoryColor: Color {
        switch exercise.category {
        case .chest: return .coral
        case .back: return .oceanBlue
        case .legs: return .mintGreen
        case .shoulders: return .warmAmber
        case .arms: return .lavender
        case .core: return .coral
        case .cardio: return .oceanBlue
        case .flexibility: return .mintGreen
        case .rehabilitation: return .stoneGray
        }
    }
}

// MARK: - Wrap Layout (for muscle tags)

struct WrapLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(proposal.width ?? 0, subviews: subviews)
        let height = rows.last?.maxY ?? 0
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrange(bounds.width, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            if let frame = rows.first(where: { $0.index == index }) {
                subview.place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: .unspecified)
            }
        }
    }

    struct Frame { let index: Int; let minX: CGFloat; let minY: CGFloat; let maxY: CGFloat }

    private func arrange(_ width: CGFloat, subviews: Subviews) -> [Frame] {
        var frames: [Frame] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(Frame(index: index, minX: x, minY: y, maxY: y + size.height))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return frames
    }
}
