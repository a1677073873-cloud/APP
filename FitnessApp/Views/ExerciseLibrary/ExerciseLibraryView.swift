import SwiftUI

struct ExerciseLibraryView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    FitSearchBar(text: .constant("")).padding(.horizontal, 20)
                    EmptyStateView(message: "动作库即将上线\n敬请期待")
                }
                .padding(.vertical, 20)
            }
            .background(Color.lightGray.ignoresSafeArea())
            .navigationTitle("动作库")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
