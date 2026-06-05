import Foundation

struct FitUser: Codable, Identifiable {
    var id: String
    var displayName: String
    var phoneNumber: String
    var email: String?
    var authProvider: AuthProvider
    var onboardingCompleted: Bool
    var emergencyContacts: [EmergencyContact]
    var createdAt: Date

    init(
        id: String,
        displayName: String = "",
        phoneNumber: String = "",
        email: String? = nil,
        authProvider: AuthProvider = .phone,
        onboardingCompleted: Bool = false,
        emergencyContacts: [EmergencyContact] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.displayName = displayName
        self.phoneNumber = phoneNumber
        self.email = email
        self.authProvider = authProvider
        self.onboardingCompleted = onboardingCompleted
        self.emergencyContacts = emergencyContacts
        self.createdAt = createdAt
    }
}

enum AuthProvider: String, Codable {
    case phone
    case apple
    case wechat
}

struct EmergencyContact: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var phone: String
    var relationship: String
}
