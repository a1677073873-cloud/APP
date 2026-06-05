const { COACH_SYSTEM_PROMPT } = require("./coachPrompt");

const QIANWEN_API_URL =
  "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions";
const QIANWEN_MODEL = "qwen-turbo";

async function callQianwen(history) {
  const apiKey = process.env.QIANWEN_API_KEY;
  if (!apiKey) {
    throw new Error("未配置 QIANWEN_API_KEY 环境变量");
  }

  const messages = [
    { role: "system", content: COACH_SYSTEM_PROMPT },
    ...history,
  ];

  const response = await fetch(QIANWEN_API_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model: QIANWEN_MODEL,
      messages,
      temperature: 0.7,
      max_tokens: 600,
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error("Qianwen API error:", response.status, errorText);
    throw new Error("AI 服务暂时不可用，请稍后重试");
  }

  const data = await response.json();
  return (
    data.choices?.[0]?.message?.content || "抱歉，我暂时无法回复。请稍后再试。"
  );
}

module.exports = { callQianwen };
