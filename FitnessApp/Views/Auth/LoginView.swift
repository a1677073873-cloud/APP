import SwiftUI

struct LoginView: View {
    var viewModel: AuthViewModel
    @State private var phone = ""
    @State private var password = ""
    @State private var showVerification = false
    @State private var showRegister = false
    @State private var loginMode: LoginMode = .password

    enum LoginMode: CaseIterable {
        case password, smsCode
        var title: String {
            switch self {
            case .password: return "密码登录"
            case .smsCode: return "验证码登录"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 40)

                    // Logo 区域
                    VStack(spacing: 12) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.mintGreen)

                        Text(AppConstants.appName)
                            .font(.fitLargeTitle)
                            .foregroundColor(.darkText)

                        Text("你的AI健身伴侣")
                            .font(.fitCallout)
                            .foregroundColor(.secondaryText)
                    }

                    // 登录方式切换
                    Picker("模式", selection: $loginMode) {
                        ForEach(LoginMode.allCases, id: \.self) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)

                    // 手机号输入
                    FitTextField(placeholder: "请输入手机号", text: $phone, keyboardType: .phonePad)
                        .padding(.horizontal, 20)

                    // 密码或验证码区域
                    if loginMode == .password {
                        FitTextField(placeholder: "请输入密码", text: $password, isSecure: true)
                            .padding(.horizontal, 20)

                        FitButton(title: "登录", isDisabled: phone.isEmpty || password.isEmpty || viewModel.isLoading) {
                            Task { await viewModel.signInWithPassword(phone: phone, password: password) }
                        }
                        .padding(.horizontal, 20)

                        Button {
                            showRegister = true
                        } label: {
                            Text("还没有账号？立即注册")
                                .font(.fitCallout)
                                .foregroundColor(.oceanBlue)
                        }
                    } else {
                        FitButton(title: "获取验证码", isDisabled: phone.isEmpty || viewModel.isLoading) {
                            Task {
                                await viewModel.sendVerificationCode(phone: phone)
                                if viewModel.errorMessage == nil { showVerification = true }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Apple 登录
                    HStack(spacing: 12) {
                        Rectangle().frame(height: 0.5).foregroundColor(.mediumGray)
                        Text("其他方式").font(.fitCaption).foregroundColor(.mediumGray)
                        Rectangle().frame(height: 0.5).foregroundColor(.mediumGray)
                    }
                    .padding(.horizontal, 40)

                    FitButton(title: "使用 Apple 登录", style: .secondary, icon: "apple.logo") {
                        // TODO: 实现 Apple Sign In
                    }
                    .padding(.horizontal, 20)

                    // 错误提示
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.fitCaption)
                            .foregroundColor(.dangerRed)
                            .padding(.horizontal, 20)
                    }

                    Spacer()
                }
            }
            .background(Color.lightGray.ignoresSafeArea())
            .navigationDestination(isPresented: $showVerification) {
                VerificationCodeView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView(viewModel: viewModel)
            }
        }
    }
}
