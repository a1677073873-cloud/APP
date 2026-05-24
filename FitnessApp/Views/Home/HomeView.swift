import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("下午好")
                            .font(.fitTitle2)
                            .foregroundColor(.secondaryText)
                        Text("开始今天的训练吧")
                            .font(.fitLargeTitle)
                            .foregroundColor(.darkText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                    VStack(spacing: 20) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 48))
                            .foregroundColor(.coral)
                        Text("选择运动类型，一键开始记录")
                            .font(.fitBody)
                            .foregroundColor(.secondaryText)
                        FitButton(title: "开始训练", style: .primary, icon: "play.fill") {}
                    }
                    .frame(maxWidth: .infinity)
                    .glassEffect()
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("最近记录").font(.fitHeadline).padding(.horizontal, 20)
                        EmptyStateView(message: "还没有训练记录\n开始你的第一次训练吧")
                    }
                }
                .padding(.vertical, 20)
            }
            .background(Color.lightGray.ignoresSafeArea())
            .navigationTitle("训练台")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
