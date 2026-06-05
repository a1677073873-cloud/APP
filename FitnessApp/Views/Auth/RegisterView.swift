import SwiftUI

struct RegisterView: View {
    @Bindable var viewModel: AuthViewModel
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 40)

                VStack(spacing: 12) {
                    Image(systemName: "person.badge.plus.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.mintGreen)

                    Text("创建账号")
                        .font(.fitTitle2)
                        .foregroundColor(.darkText)
                }

                FitTextField(placeholder: "昵称", text: $name)
                    .padding(.horizontal, 20)

                FitTextField(placeholder: "手机号", text: $phone, keyboardType: .phonePad)
                    .padding(.horizontal, 20)

                FitTextField(placeholder: "设置密码（至少6位）", text: $password, isSecure: true)
                    .padding(.horizontal, 20)

                FitTextField(placeholder: "确认密码", text: $confirmPassword, isSecure: true)
                    .padding(.horizontal, 20)

                FitButton(
                    title: "注册",
                    isDisabled: phone.isEmpty || password.isEmpty || confirmPassword.isEmpty || name.isEmpty || viewModel.isLoading
                ) {
                    guard password == confirmPassword else {
                        viewModel.errorMessage = "两次密码不一致"
                        return
                    }
                    guard password.count >= 6 else {
                        viewModel.errorMessage = "密码至少6位"
                        return
                    }
                    Task { await viewModel.signUpWithPassword(phone: phone, password: password, name: name) }
                }
                .padding(.horizontal, 20)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.fitCaption)
                        .foregroundColor(.dangerRed)
                }

                Spacer()
            }
        }
        .background(Color.lightGray.ignoresSafeArea())
        .navigationTitle("注册")
        .navigationBarTitleDisplayMode(.inline)
    }
}
