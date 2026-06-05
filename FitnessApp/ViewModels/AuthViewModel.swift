import SwiftUI
import FirebaseCore
import FirebaseAuth

@Observable
@MainActor
class AuthViewModel {
    var isAuthenticated = false
    var isLoading = false
    var errorMessage: String?
    var verificationID: String?
    var currentPhone: String = ""
    var currentUser: FirebaseAuth.User?

    private let authService = AuthService.shared

    init() {
        guard let app = FirebaseApp.app() else {
            errorMessage = "Firebase 未初始化，请重启应用"
            return
        }
        let auth = Auth.auth(app: app)
        isAuthenticated = auth.currentUser != nil
        currentUser = auth.currentUser
        auth.addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
            self?.currentUser = user
        }
    }

    // MARK: - 密码登录
    func signInWithPassword(phone: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await authService.signInWithPassword(phone: phone, password: password)
        } catch {
            handleError(error)
        }
        isLoading = false
    }

    // MARK: - 密码注册
    func signUpWithPassword(phone: String, password: String, name: String) async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await authService.signUpWithPassword(phone: phone, password: password, displayName: name)
        } catch {
            handleError(error)
        }
        isLoading = false
    }

    // MARK: - 发送验证码
    func sendVerificationCode(phone: String) async {
        isLoading = true
        errorMessage = nil
        currentPhone = phone
        do {
            verificationID = try await authService.verifyPhoneNumber(phone)
        } catch {
            handleError(error)
        }
        isLoading = false
    }

    // MARK: - 验证码登录
    func verifyCode(_ code: String) async {
        guard let verificationID = verificationID else {
            errorMessage = "请先获取验证码"
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            _ = try await authService.signInWithCode(verificationID: verificationID, code: code)
        } catch {
            handleError(error)
        }
        isLoading = false
    }

    // MARK: - 退出登录
    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = "退出失败"
        }
    }

    // MARK: - 错误处理
    private func handleError(_ error: Error) {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue:
            errorMessage = "密码错误"
        case AuthErrorCode.userNotFound.rawValue:
            errorMessage = "账号未注册"
        case AuthErrorCode.userDisabled.rawValue:
            errorMessage = "账号已被禁用"
        case AuthErrorCode.invalidEmail.rawValue:
            errorMessage = "手机号格式有误"
        case AuthErrorCode.invalidVerificationCode.rawValue:
            errorMessage = "验证码错误"
        case AuthErrorCode.sessionExpired.rawValue:
            errorMessage = "验证码已过期，请重新获取"
        case 17010:
            errorMessage = "验证码发送过于频繁，请稍后再试"
        default:
            errorMessage = error.localizedDescription
        }
    }
}
