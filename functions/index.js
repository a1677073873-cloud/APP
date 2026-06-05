const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const { callQianwen } = require("./src/ai/qianwenClient");
const { COACH_SYSTEM_PROMPT } = require("./src/ai/coachPrompt");
const { detectCrisis } = require("./src/ai/crisisDetector");
const { sendSMS } = require("./src/sms/smsSender");

admin.initializeApp();
const db = admin.firestore();

// AI 对话函数
exports.aiChat = onCall(
  {
    maxInstances: 10,
    timeoutSeconds: 60,
    region: "asia-east1",
  },
  async (request) => {
    const { message, sessionId } = request.data;
    const userId = request.auth?.uid;

    if (!userId) {
      throw new HttpsError("unauthenticated", "请先登录");
    }
    if (!message || message.trim().length === 0) {
      throw new HttpsError("invalid-argument", "消息不能为空");
    }

    // 获取或创建会话
    const sessionRef = db.collection("chatSessions").doc(sessionId || "");
    let sessionDoc = sessionId ? await sessionRef.get() : null;

    if (!sessionDoc || !sessionDoc.exists) {
      const newSessionRef = await db.collection("chatSessions").add({
        userId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
        isActive: true,
      });
      request.data.sessionId = newSessionRef.id;
    }

    const finalSessionId = request.data.sessionId || sessionId;

    // 存储用户消息
    await db.collection("chatMessages").add({
      sessionId: finalSessionId,
      userId,
      role: "user",
      content: message,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 获取最近 20 条对话历史
    const historySnapshot = await db
      .collection("chatMessages")
      .where("sessionId", "==", finalSessionId)
      .orderBy("createdAt", "desc")
      .limit(20)
      .get();

    const history = [];
    historySnapshot.forEach((doc) => {
      history.unshift({
        role: doc.data().role === "assistant" ? "assistant" : "user",
        content: doc.data().content,
      });
    });

    // 调用通义千问
    const aiResponse = await callQianwen(history);

    // 危机检测
    const crisisResult = detectCrisis(message, aiResponse);

    // 存储 AI 回复
    await db.collection("chatMessages").add({
      sessionId: finalSessionId,
      userId,
      role: "assistant",
      content: aiResponse,
      crisisFlag: crisisResult.detected,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 更新会话时间
    await db
      .collection("chatSessions")
      .doc(finalSessionId)
      .update({
        lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    return {
      reply: aiResponse,
      sessionId: finalSessionId,
      crisisDetected: crisisResult.detected,
    };
  }
);

// 危机短信发送函数
exports.sendCrisisSMS = onCall(
  {
    maxInstances: 10,
    region: "asia-east1",
  },
  async (request) => {
    const userId = request.auth?.uid;

    if (!userId) {
      throw new HttpsError("unauthenticated", "请先登录");
    }

    // 获取用户紧急联系人
    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) {
      throw new HttpsError("not-found", "用户不存在");
    }

    const userData = userDoc.data();
    const contacts = userData.emergencyContacts || [];
    if (contacts.length === 0) {
      return { sent: false, reason: "未设置紧急联系人" };
    }

    const results = [];
    for (const contact of contacts) {
      try {
        await sendSMS(
          contact.phone,
          `【FitMind】紧急通知：您的联系人${userData.displayName || "用户"}可能正在经历情绪危机。建议尽快联系ta，给予关心和支持。此消息为自动发送，请勿回复。`
        );
        results.push({ phone: contact.phone, sent: true });
      } catch (err) {
        results.push({ phone: contact.phone, sent: false, error: err.message });
      }
    }

    // 记录告警
    await db.collection("emergencyAlerts").add({
      userId,
      contactsNotified: contacts.map((c) => c.phone),
      results,
      triggeredAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { sent: results.some((r) => r.sent), results };
  }
);
