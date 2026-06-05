// 危机关键词（中文）
const CRISIS_KEYWORDS = [
  "不想活了",
  "结束生命",
  "自杀",
  "自残",
  "活不下去",
  "活着没意思",
  "想去死",
  "没有活着的意义",
  "消失算了",
  "不想再坚持了",
  "崩溃了",
  "撑不下去了",
];

function detectCrisis(userMessage, aiResponse) {
  // 方案 1：AI 模型在回复中标记了 CRISIS_DETECTED
  if (aiResponse && aiResponse.includes("[CRISIS_DETECTED]")) {
    // 清理标记后的文本
    const cleanedReply = aiResponse.replace("[CRISIS_DETECTED]", "").trim();
    return { detected: true, cleanedReply };
  }

  // 方案 2：关键词兜底检测（用户原始消息）
  const lowerMessage = (userMessage || "").toLowerCase();
  const keywordMatch = CRISIS_KEYWORDS.some((keyword) =>
    lowerMessage.includes(keyword)
  );

  if (keywordMatch) {
    return { detected: true, cleanedReply: aiResponse };
  }

  return { detected: false, cleanedReply: aiResponse };
}

module.exports = { detectCrisis, CRISIS_KEYWORDS };
