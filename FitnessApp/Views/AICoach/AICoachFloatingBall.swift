import SwiftUI

/// 可拖拽的 AI 教练悬浮球
struct AICoachFloatingBall: View {
    @Binding var showAICoach: Bool

    // 拖拽状态
    @State private var position: CGPoint = .zero
    @GestureState private var dragOffset: CGSize = .zero

    // 呼吸动效
    @State private var breathing = false

    private let ballSize: CGFloat = 56
    private let padding: CGFloat = 16

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let safeTop = geometry.safeAreaInsets.top
            let safeBottom = geometry.safeAreaInsets.bottom

            // 默认右下角位置
            let defaultX = screenWidth - ballSize - padding
            let defaultY = screenHeight - ballSize - padding - safeBottom - 80

            let posX = position == .zero ? defaultX : position.x
            let posY = position == .zero ? defaultY : position.y

            ZStack {
                // 外层光晕
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.mintGreen.opacity(0.3), .mintGreen.opacity(0)],
                            center: .center,
                            startRadius: ballSize / 2,
                            endRadius: ballSize
                        )
                    )
                    .frame(width: ballSize + 20, height: ballSize + 20)
                    .scaleEffect(breathing ? 1.15 : 1.0)
                    .opacity(breathing ? 0.6 : 0.3)

                // 主体圆球
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.mintGreen, Color(red: 130/255, green: 190/255, blue: 170/255)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: ballSize, height: ballSize)
                    .shadow(color: .mintGreen.opacity(0.4), radius: 12, y: 4)

                // AI 图标
                Image(systemName: "sparkles")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
            .position(x: posX + ballSize / 2 + dragOffset.width,
                      y: posY + ballSize / 2 + dragOffset.height)
            .onTapGesture {
                Haptics.light()
                showAICoach = true
            }
            .gesture(
                DragGesture(minimumDistance: 8)
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        // 计算新位置
                        var newX = posX + value.translation.width
                        var newY = posY + value.translation.height

                        // Y 轴边界约束
                        let minY = safeTop + padding
                        let maxY = screenHeight - ballSize - padding - safeBottom
                        newY = max(minY, min(maxY, newY))

                        // X 轴吸附：贴左或贴右
                        let midX = screenWidth / 2
                        newX = newX < midX ? padding : screenWidth - ballSize - padding

                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            position = CGPoint(x: newX, y: newY)
                        }
                    }
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    breathing = true
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.lightGray.ignoresSafeArea()
        AICoachFloatingBall(showAICoach: .constant(false))
    }
}
