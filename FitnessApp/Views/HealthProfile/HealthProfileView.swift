import SwiftUI

struct HealthProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 64)).foregroundColor(.mediumGray)
                        Text("健身爱好者").font(.fitTitle3).foregroundColor(.darkText)
                        Text("已坚持训练 0 天").font(.fitCallout).foregroundColor(.secondaryText)
                    }
                    .padding(.top, 20)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(title: "本周训练", value: "0次")
                        StatCard(title: "总时长", value: "0分钟")
                        StatCard(title: "平均疲劳", value: "--")
                        StatCard(title: "消耗卡路里", value: "0千卡")
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("训练历史").font(.fitHeadline).padding(.horizontal, 20)
                        EmptyStateView(message: "暂无训练历史")
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color.lightGray.ignoresSafeArea())
            .navigationTitle("健康档案")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
