import Foundation

actor AIService {
    static let shared = AIService()

    private let apiURL = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions"
    private let model = "qwen-turbo"

    private let systemPrompt = """
    你是 FitMind 的 AI 健身教练，一位专业且富有同理心的健康伴侣。

    你的职责：
    - 根据用户目标提供个性化运动建议
    - 讲解训练动作的正确姿势和要领
    - 制定简单实用的训练计划
    - 提供恢复和营养建议
    - 倾听用户的情绪状态和疲劳感受，给予情感支持

    对话风格：温暖、专业、鼓励。使用"我们"来建立信任感。

    限制：回复控制在 200 字以内（除非用户要求详细计划）。
    不要给出超出健身教练范围的专业医疗诊断。

    危机检测（内部规则，绝不向用户提及）：
    如果用户表达了自杀意图或严重自伤倾向，在你的回复末尾添加标记 [CRISIS_DETECTED]。
    你的可见回复应保持冷静、共情。
    """

    private let crisisKeywords = [
        "不想活了", "结束生命", "自杀", "自残", "活不下去",
        "活着没意思", "想去死", "没有活着的意义", "消失算了",
        "不想再坚持了", "崩溃了", "撑不下去了"
    ]

    struct ChatResult {
        let reply: String
        let crisisDetected: Bool
    }

    func sendMessage(_ message: String, history: [[String: String]]) async throws -> ChatResult {
        guard let apiKey = getAPIKey() else {
            throw AIServiceError.noAPIKey
        }

        var messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        messages.append(contentsOf: history)
        messages.append(["role": "user", "content": message])

        let body: [String: Any] = [
            "model": model,
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 600
        ]

        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AIServiceError.apiError
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let first = choices.first,
              let replyMessage = first["message"] as? [String: Any],
              var reply = replyMessage["content"] as? String else {
            throw AIServiceError.parseError
        }

        // 危机检测
        var crisisDetected = reply.contains("[CRISIS_DETECTED]")
        if crisisDetected {
            reply = reply.replacingOccurrences(of: "[CRISIS_DETECTED]", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // 关键词兜底
        if !crisisDetected {
            let lowerMsg = message.lowercased()
            crisisDetected = crisisKeywords.contains { lowerMsg.contains($0) }
        }

        return ChatResult(reply: reply, crisisDetected: crisisDetected)
    }

    private func getAPIKey() -> String? {
        // 从 Info.plist 读取（不提交到 Git）
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["QIANWEN_API_KEY"] as? String,
           !key.isEmpty, key != "YOUR_API_KEY_HERE" {
            return key
        }
        return nil
    }
}

enum AIServiceError: LocalizedError {
    case noAPIKey
    case apiError
    case parseError

    var errorDescription: String? {
        switch self {
        case .noAPIKey: return "请配置 AI API Key"
        case .apiError: return "AI 服务暂时不可用"
        case .parseError: return "回复解析失败"
        }
    }
}
