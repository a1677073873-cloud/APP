import SwiftUI

struct AICoachView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        Image(systemName: "heart.text.clinic.fill")
                            .font(.system(size: 56))
                            .foregroundColor(.mintGreen)
                            .padding(.top, 40)
                        Text("你好，我是你的AI健身教练")
                            .font(.fitTitle2)
                            .foregroundColor(.darkText)
                        Text("你可以向我咨询训练计划、动作指导、营养建议，或者只是聊聊今天的感受。")
                            .font(.fitBody)
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        VStack(spacing: 10) {
                            ForEach(["今天适合练什么？", "如何缓解运动后的肌肉酸痛？", "帮我制定一个减脂计划"], id: \.self) { q in
                                Button {} label: {
                                    Text(q).font(.fitCallout).foregroundColor(.oceanBlue)
                                        .padding(.horizontal, 16).padding(.vertical, 10)
                                        .background(RoundedRectangle(cornerRadius: 20).stroke(Color.oceanBlue.opacity(0.3), lineWidth: 1))
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                HStack(spacing: 10) {
                    TextField("输入消息...", text: .constant(""))
                        .font(.fitBody).padding(12)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.lightGray))
                    Button {} label: {
                        Image(systemName: "arrow.up.circle.fill").font(.system(size: 32)).foregroundColor(.oceanBlue)
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(Color.pureWhite)
            }
            .background(Color.lightGray.ignoresSafeArea())
            .navigationTitle("AI教练")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
