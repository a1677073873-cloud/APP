import SwiftUI

struct OnboardingView: View {
    @AppStorage("has_completed_onboarding_v1") private var hasCompletedOnboarding = false
    @State private var currentPage = 0

    private let pages = OnboardingPage.allPages

    var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()
                Button("跳过") {
                    completeOnboarding()
                }
                .font(.fitCallout)
                .foregroundColor(.secondaryText)
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }

            // Pages
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentPage)

            // Indicators + button
            VStack(spacing: 24) {
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? Color.oceanBlue : Color.mediumGray.opacity(0.3))
                            .frame(width: i == currentPage ? 24 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }

                FitButton(
                    title: currentPage == pages.count - 1 ? "开始" : "下一步",
                    style: .primary
                ) {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 40)
        }
        .background(Color.lightGray.ignoresSafeArea())
    }

    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.3)) {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Page Model

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color

    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            icon: "heart.circle.fill",
            title: "欢迎来到 FitMind",
            subtitle: "你的 AI 健身伴侣\n用科学和共情，陪伴每一次训练",
            accentColor: .mintGreen
        ),
        OnboardingPage(
            icon: "bubble.left.and.bubble.right.fill",
            title: "AI 对话教练",
            subtitle: "不只是训练计划\n聊聊你的疲劳、心情和目标\n我会认真倾听",
            accentColor: .oceanBlue
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "开始你的旅程",
            subtitle: "极简记录，一键开始\n让每一次汗水都看得见",
            accentColor: .coral
        )
    ]
}

// MARK: - Page View

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: page.icon)
                .font(.system(size: 72))
                .foregroundColor(page.accentColor)
                .padding(40)
                .background(
                    Circle()
                        .fill(page.accentColor.opacity(0.1))
                )

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.fitTitle1)
                    .foregroundColor(.darkText)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.fitBody)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
    }
}
