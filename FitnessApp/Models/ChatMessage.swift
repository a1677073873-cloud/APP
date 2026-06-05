import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: String
    let role: MessageRole
    let content: String
    let timestamp: Date

    init(id: String = UUID().uuidString,
         role: MessageRole,
         content: String,
         timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }

    var historyDict: [String: String] {
        [role.apiKey: content]
    }
}

enum MessageRole: String, Codable {
    case user
    case assistant
    case system

    var apiKey: String {
        switch self {
        case .user: return "user"
        case .assistant: return "assistant"
        case .system: return "system"
        }
    }
}
