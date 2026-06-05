import SwiftUI

struct ExerciseLibraryView: View {
    @State private var searchText = ""
    @State private var selectedCategory: ExerciseCategory? = nil

    private let service = ExerciseDataService.shared

    private var filteredExercises: [Exercise] {
        var result = selectedCategory == nil
            ? service.allExercises()
            : service.exercises(for: selectedCategory!)

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.targetMuscles.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        return result
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                FitSearchBar(text: $searchText)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)

                CategoryFilterBar(selected: $selectedCategory)
                    .padding(.bottom, 8)

                if filteredExercises.isEmpty {
                    Spacer()
                    EmptyStateView(message: searchText.isEmpty ? "该分类暂无动作" : "未找到匹配的动作")
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(filteredExercises) { exercise in
                                NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                                    ExerciseCard(exercise: exercise)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                }
            }
            .background(Color.lightGray.ignoresSafeArea())
            .navigationTitle("动作库")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Category Filter Bar

struct CategoryFilterBar: View {
    @Binding var selected: ExerciseCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryPill(
                    label: "全部",
                    icon: "square.grid.2x2",
                    isSelected: selected == nil
                ) {
                    selected = nil
                }

                ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                    CategoryPill(
                        label: cat.rawValue,
                        icon: cat.iconName,
                        isSelected: selected == cat
                    ) {
                        selected = cat
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct CategoryPill: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.fitCaption)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.oceanBlue : Color.pureWhite)
            )
            .foregroundColor(isSelected ? .white : .secondaryText)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.mediumGray.opacity(0.3), lineWidth: 0.5)
            )
        }
    }
}

// MARK: - Exercise Card

struct ExerciseCard: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: exercise.category.iconName)
                    .font(.title2)
                    .foregroundColor(categoryColor)
                Spacer()
                DifficultyBadge(difficulty: exercise.difficulty)
            }

            Text(exercise.name)
                .font(.fitHeadline)
                .foregroundColor(.darkText)
                .lineLimit(1)

            Text(exercise.targetMuscles.prefix(2).joined(separator: "、"))
                .font(.fitCaption2)
                .foregroundColor(.secondaryText)
                .lineLimit(1)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.pureWhite))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.lightGray, lineWidth: 0.5))
        .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
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

struct DifficultyBadge: View {
    let difficulty: ExerciseDifficulty

    var body: some View {
        Text(difficulty.rawValue)
            .font(.fitCaption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(difficultyColor.opacity(0.15)))
            .foregroundColor(difficultyColor)
    }

    private var difficultyColor: Color {
        switch difficulty {
        case .beginner: return .mintGreen
        case .intermediate: return .warmAmber
        case .advanced: return .coral
        }
    }
}
