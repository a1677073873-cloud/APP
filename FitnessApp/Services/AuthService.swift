import Foundation
import FirebaseAuth

@MainActor
class AuthService {
    static let shared = AuthService()

    var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }

    var isLoggedIn: Bool {
        currentUser != nil
    }

    // MARK: - 手机号 + 密码登录

    func signInWithPassword(phone: String, password: String) async throws -> FirebaseAuth.User {
        guard !phone.isEmpty, !password.isEmpty else {
            throw AuthServiceError.invalidInput
        }
        let email = phoneToEmail(phone)
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user
    }

    // MARK: - 手机号 + 密码注册

    func signUpWithPassword(phone: String, password: String, displayName: String) async throws -> FirebaseAuth.User {
        guard !phone.isEmpty, !password.isEmpty else {
            throw AuthServiceError.invalidInput
        }
        let email = phoneToEmail(phone)
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()
        return result.user
    }

    // MARK: - 手机号 + 验证码登录

    func verifyPhoneNumber(_ phone: String) async throws -> String {
        try await PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil)
    }

    func signInWithCode(verificationID: String, code: String) async throws -> FirebaseAuth.User {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )
        let result = try await Auth.auth().signIn(with: credential)
        return result.user
    }

    // MARK: - Apple 登录

    func signInWithApple(idToken: String, nonce: String) async throws -> FirebaseAuth.User {
        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: nil
        )
        let result = try await Auth.auth().signIn(with: credential)
        return result.user
    }

    // MARK: - 退出登录

    func signOut() throws {
        try Auth.auth().signOut()
    }

    // MARK: - 辅助

    private func phoneToEmail(_ phone: String) -> String {
        let cleaned = phone.replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
        return "\(cleaned)@fitmind.app"
    }
}

enum AuthServiceError: LocalizedError {
    case invalidInput
    case notConfigured

    var errorDescription: String? {
        switch self {
        case .invalidInput: return "请输入手机号和密码"
        case .notConfigured: return "登录服务未配置"
        }
    }
}
