import SwiftUI
import Observation

@MainActor
@Observable
class ChatViewModel {
    var messages: [ChatMessage] = []
    var inputText = ""
    var isLoading = false
    var showCrisisAlert = false
    var showEmergencyPrompt = false

    private let aiService = AIService.shared

    var historyForAPI: [[String: String]] {
        messages.suffix(20).map { $0.historyDict }
    }

    func checkFirstLaunch() {
        let hasLaunchedKey = "ai_coach_has_launched_v1"
        if !UserDefaults.standard.bool(forKey: hasLaunchedKey) {
            showEmergencyPrompt = true
            UserDefaults.standard.set(true, forKey: hasLaunchedKey)
        }
    }

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isLoading else { return }
        Haptics.light()

        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        inputText = ""
        isLoading = true

        Task {
            defer { isLoading = false }
            do {
                let apiHistory = Array(messages.prefix(while: { $0.id != userMessage.id }))
                    .map { $0.historyDict }
                let result = try await aiService.sendMessage(text, history: apiHistory)
                let reply = ChatMessage(role: .assistant, content: result.reply)
                messages.append(reply)

                if result.crisisDetected {
                    crisisMessage = result.reply
                    showCrisisAlert = true
                }
            } catch {
                let errorMsg = ChatMessage(
                    role: .assistant,
                    content: "抱歉，我暂时无法回复，请检查网络后重试。"
                )
                messages.append(errorMsg)
            }
        }
    }

    func sendSuggestedQuestion(_ question: String) {
        inputText = question
        sendMessage()
    }

    // MARK: - Crisis

    private(set) var crisisMessage = ""

    func confirmSendCrisisSMS() {
        showCrisisAlert = false
        // V1.0 仅做 UI 提示，不实际发送短信
    }

    func dismissCrisisAlert() {
        showCrisisAlert = false
    }
}
