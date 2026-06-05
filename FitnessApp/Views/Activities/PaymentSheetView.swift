import SwiftUI

/// 模拟支付页面
struct PaymentSheetView: View {
    let activityTitle: String
    let amount: Double
    @Binding var selectedMethod: PaymentMethod

    @State private var isPaying = false
    @State private var paySuccess = false
    @State private var payProgress: CGFloat = 0
    @State private var timer: Timer?

    var onDismiss: ((_ success: Bool) -> Void)?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            if isPaying {
                payingView
            } else if paySuccess {
                successView
            } else {
                paymentForm
            }
        }
    }

    // MARK: - Payment Form

    private var paymentForm: some View {
        VStack(spacing: 24) {
            // 顶部关闭按钮
            HStack {
                Button("取消") {
                    dismiss()
                }
                .foregroundColor(.secondaryText)
                Spacer()
                Text("收银台")
                    .font(.fitHeadline)
                    .foregroundColor(.darkText)
                Spacer()
                Color.clear.frame(width: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // 订单信息
            VStack(spacing: 8) {
                Text(activityTitle)
                    .font(.fitCallout)
                    .foregroundColor(.secondaryText)
                    .lineLimit(1)
                    .padding(.horizontal, 40)

                Text("¥\(String(format: "%.0f", amount))")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.darkText)
            }

            // 账单卡片
            VStack(spacing: 0) {
                HStack {
                    Text("商家")
                        .foregroundColor(.secondaryText)
                    Spacer()
                    Text("FitMind 健身平台")
                        .foregroundColor(.darkText)
                }
                .padding(.vertical, 8)
                Divider()
                HStack {
                    Text("商品")
                        .foregroundColor(.secondaryText)
                    Spacer()
                    Text(activityTitle)
                        .foregroundColor(.darkText)
                        .lineLimit(1)
                }
                .padding(.vertical, 8)
                Divider()
                HStack {
                    Text("金额")
                        .foregroundColor(.secondaryText)
                    Spacer()
                    Text("¥\(String(format: "%.0f", amount))")
                        .foregroundColor(.darkText)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 8)
            }
            .font(.fitCallout)
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.pureWhite))
            .padding(.horizontal, 20)

            // 支付方式选择
            VStack(alignment: .leading, spacing: 12) {
                Text("选择支付方式")
                    .font(.fitHeadline)
                    .foregroundColor(.darkText)

                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    PaymentMethodRow(
                        method: method,
                        isSelected: selectedMethod == method,
                        action: { selectedMethod = method }
                    )
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            // 确认支付按钮
            FitButton(
                title: "确认支付 ¥\(String(format: "%.0f", amount))",
                style: .primary,
                icon: "creditcard.fill"
            ) {
                startPayment()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.lightGray.ignoresSafeArea())
    }

    // MARK: - Paying Animation

    private var payingView: some View {
        VStack(spacing: 0) {
            // 顶部
            Text("收银台")
                .font(.fitHeadline)
                .foregroundColor(.darkText)
                .padding(.top, 20)

            Spacer()

            // 支付动画
            VStack(spacing: 28) {
                // 图标动画
                ZStack {
                    Circle()
                        .stroke(Color.lightGray, lineWidth: 6)
                        .frame(width: 100, height: 100)

                    Circle()
                        .trim(from: 0, to: payProgress)
                        .stroke(Color.oceanBlue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.5), value: payProgress)

                    Image(systemName: selectedMethod == .wechat ? "message.fill" : "a.square.fill")
                        .font(.title)
                        .foregroundColor(selectedMethod == .wechat ? .mintGreen : .oceanBlue)
                }

                VStack(spacing: 10) {
                    Text("正在支付 ¥\(String(format: "%.0f", amount))")
                        .font(.fitTitle3)
                        .foregroundColor(.darkText)

                    Text("\(selectedMethod.rawValue)安全支付处理中...")
                        .font(.fitCallout)
                        .foregroundColor(.secondaryText)
                }

                // 支付步骤
                VStack(alignment: .leading, spacing: 10) {
                    PayStepRow(icon: "lock.shield.fill", text: "支付环境安全加密", done: payProgress > 0.3)
                    PayStepRow(icon: "creditcard.fill", text: "正在验证支付信息", done: payProgress > 0.6)
                    PayStepRow(icon: "checkmark.shield.fill", text: "等待银行确认...", done: payProgress > 0.9)
                }
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.pureWhite))
                .padding(.horizontal, 20)
            }

            Spacer()
        }
        .background(Color.lightGray.ignoresSafeArea())
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
                if payProgress < 0.95 {
                    withAnimation {
                        payProgress += 0.08
                    }
                } else {
                    timer?.invalidate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            isPaying = false
                            paySuccess = true
                        }
                    }
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    // MARK: - Success

    private var successView: some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(.mintGreen)

            VStack(spacing: 8) {
                Text("支付成功")
                    .font(.fitTitle1)
                    .foregroundColor(.darkText)
                Text("¥\(String(format: "%.0f", amount))")
                    .font(.fitTitle3)
                    .foregroundColor(.secondaryText)
            }

            Text("你已成功报名「\(activityTitle)」")
                .font(.fitCallout)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            FitButton(title: "完成", style: .primary) {
                dismiss()
                onDismiss?(true)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(Color.lightGray.ignoresSafeArea())
    }

    // MARK: - Actions

    private func startPayment() {
        withAnimation {
            isPaying = true
        }
    }
}

// MARK: - Pay Step Row

private struct PayStepRow: View {
    let icon: String
    let text: String
    let done: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: done ? "checkmark.circle.fill" : icon)
                .font(.system(size: 16))
                .foregroundColor(done ? .mintGreen : .mediumGray)
                .frame(width: 22)

            Text(text)
                .font(.fitCallout)
                .foregroundColor(done ? .darkText : .secondaryText)

            Spacer()
        }
    }
}

// MARK: - Payment Method Row

struct PaymentMethodRow: View {
    let method: PaymentMethod
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .mintGreen : .mediumGray)

                VStack(alignment: .leading, spacing: 2) {
                    Text(method.rawValue)
                        .font(.fitCallout)
                        .foregroundColor(.darkText)
                    Text(method == .wechat ? "微信安全支付" : "支付宝安全支付")
                        .font(.fitCaption2)
                        .foregroundColor(.secondaryText)
                }

                Spacer()

                Image(systemName: method == .wechat ? "message.fill" : "a.square.fill")
                    .font(.title2)
                    .foregroundColor(method == .wechat ? .mintGreen : .oceanBlue)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.pureWhite : Color.pureWhite.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.mintGreen.opacity(0.5) : Color.lightGray, lineWidth: 1)
            )
        }
    }
}

#Preview {
    PaymentSheetView(
        activityTitle: "CrossFit 燃脂挑战",
        amount: 49,
        selectedMethod: .constant(.wechat)
    )
}
