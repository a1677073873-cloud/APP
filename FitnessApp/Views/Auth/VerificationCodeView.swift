import SwiftUI

struct VerificationCodeView: View {
    @Bindable var viewModel: AuthViewModel
    @State private var code = ""
    @State private var timeRemaining = AppConstants.smsResendCooldown
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 28) {
            Spacer().frame(height: 40)

            VStack(spacing: 12) {
                Image(systemName: "ellipsis.message.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.oceanBlue)

                Text("输入验证码")
                    .font(.fitTitle2)
                    .foregroundColor(.darkText)

                Text("验证码已发送至 \(viewModel.currentPhone)")
                    .font(.fitCallout)
                    .foregroundColor(.secondaryText)
            }

            // 6 位验证码输入
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    CodeDigitField(
                        digit: digit(at: index),
                        isActive: code.count == index
                    )
                }
            }
            .padding(.horizontal, 20)
            .overlay(
                TextField("", text: $code)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .opacity(0)
                    .onChange(of: code) { _, newValue in
                        if newValue.count > 6 {
                            code = String(newValue.prefix(6))
                        }
                        if newValue.count == 6 {
                            Task { await viewModel.verifyCode(code) }
                        }
                    }
            )

            // 重发按钮
            if timeRemaining > 0 {
                Text("\(timeRemaining)秒后可重发")
                    .font(.fitCaption)
                    .foregroundColor(.mediumGray)
            } else {
                Button("重新获取验证码") {
                    timeRemaining = AppConstants.smsResendCooldown
                    startTimer()
                    Task { await viewModel.sendVerificationCode(phone: viewModel.currentPhone) }
                }
                .font(.fitCallout)
                .foregroundColor(.oceanBlue)
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.fitCaption)
                    .foregroundColor(.dangerRed)
            }

            Spacer()
        }
        .background(Color.lightGray.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { startTimer() }
    }

    private func digit(at index: Int) -> String {
        let chars = Array(code)
        guard index < chars.count else { return "" }
        return String(chars[index])
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 { timeRemaining -= 1 }
            else { timer?.invalidate() }
        }
    }

    @FocusState private var isFocused: Bool
}

struct CodeDigitField: View {
    let digit: String
    var isActive: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.pureWhite)
                .frame(width: 44, height: 52)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isActive ? Color.oceanBlue : Color.mediumGray.opacity(0.4), lineWidth: isActive ? 2 : 0.5)
                )

            Text(digit)
                .font(.fitTitle2)
                .foregroundColor(.darkText)
        }
    }
}
