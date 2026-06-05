import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Image(systemName: "house.fill"); Text("训练台") }
                .tag(0)
            ExerciseLibraryView()
                .tabItem { Image(systemName: "book.pages.fill"); Text("动作库") }
                .tag(1)
            ActivityFeedView()
                .tabItem { Image(systemName: "flame.fill"); Text("发现") }
                .tag(2)
            HealthProfileView()
                .tabItem { Image(systemName: "chart.bar.doc.horizontal.fill"); Text("健康档案") }
                .tag(3)
        }
        .tint(.oceanBlue)
        .onChange(of: selectedTab) { _, _ in
            Haptics.light()
        }
    }
}
