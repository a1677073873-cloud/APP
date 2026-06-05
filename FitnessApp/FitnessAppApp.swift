import SwiftUI
import FirebaseCore

@main
struct FitnessAppApp: App {
    @AppStorage("has_completed_onboarding_v1") private var hasCompletedOnboarding = false
//    @State private var authViewModel: AuthViewModel

    init() {
        FirebaseApp.configure()
//        _authViewModel = State(initialValue: AuthViewModel())
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if !hasCompletedOnboarding {
                    OnboardingView()
                        .transition(.opacity.combined(with: .scale(scale: 1.02)))
                }
                // 登录暂时关闭，直接进入主页
//                else if !authViewModel.isAuthenticated {
//                    LoginView(viewModel: authViewModel)
//                        .transition(.opacity)
//                }
                else {
                    MainTabView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: hasCompletedOnboarding)
//            .animation(.easeInOut(duration: 0.4), value: authViewModel.isAuthenticated)
        }
    }
}
