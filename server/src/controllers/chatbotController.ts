import { Request, Response } from "express";
import { query } from "../database/db.js";

const CLOUDFLARE_WORKER_URL =
  process.env.CLOUDFLARE_WORKER_URL ||
  "https://take-your-medicine-api-proxy.how-about-this-api.workers.dev";
const EAPIYAK_SERVICE_KEY = process.env.EAPIYAK_SERVICE_KEY || "";
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || "";

// e약은요 API에서 약 정보 조회
const fetchDrugInfoFromEYakEunyo = async (
  drugName: string
): Promise<string> => {
  try {
    const encodedDrugName = encodeURIComponent(drugName);
    const url = `https://apis.data.go.kr/1471000/MdcinGrnIdntfcServiceV2/getMdcinGrnIdntfcList?ServiceKey=${EAPIYAK_SERVICE_KEY}&item_name=${encodedDrugName}&pageNo=1&numOfRows=1&type=json`;

    const response = await fetch(url);
    const data = (await response.json()) as any;

    if (data.body && data.body.items && data.body.items.length > 0) {
      const item = data.body.items[0];
      return `약명: ${item.ITEM_NAME || ""}
효능: ${item.ETC_OTC_NAME || ""}
성분: ${item.MAIN_INGR || ""}
용법: ${item.UD_STD_SPECFC_USES_MTHD || ""}`;
    }
    return `${drugName} 약에 대한 정보를 찾을 수 없습니다.`;
  } catch (error) {
    console.error("❌ e약은요 API 오류:", error);
    return "";
  }
};

// 공통 시스템 프롬프트 생성: 약학 컨시어지(쉬운 설명, 상호작용/주의 포함, 마크다운 금지)
const buildSystemPrompt = (userInfo: any, drugInfo: string) => {
  const serverTime = new Date().toISOString();
  return `역할: 당신은 친절한 "AI 약학 컨시어지"입니다. 의학/약학 용어를 비전문가도 이해하기 쉽게 풀어서 설명합니다.

답변 원칙:
- 한국어로, 짧은 문장과 단락 사용. 과장/단정 금지.
- 마크다운/코드블록/별표/백틱/번호 라벨 없이 순수 텍스트만 사용. (굵게, 리스트 마커(**, *, -, ``` 등) 금지)
- 요청이 약물과 무관하면 1줄로 정중히 안내하고, 약물명/증상/복용 중 약을 물어 유도.
- 부작용을 설명할 때는 흔한 증상 → 주의해야 할 심각 증상 순서로 간단히.
- 상호작용은 대표적인 상충 약물/음식/알코올이 있으면 짧게 언급.
- 응급상황 징후가 의심되면 즉시 119/응급실 안내.
- 개인 맞춤: 사용자의 나이/성별/기저질환/복용약 정보가 부족하면 추가 질문을 제안.
- 날짜/시간은 추정하지 말고, 필요한 경우 다음 값을 사용: 서버시각 ${serverTime}

컨텍스트(참고용):
- 사용자: ${JSON.stringify(userInfo)}
- 약 정보(있으면 참고, 없으면 일반 가이드): ${drugInfo || "(없음)"}
`;
};

// Gemini API 직접 호출
const generateMedicalAdviceDirectly = async (
  userQuestion: string,
  userInfo: any,
  drugInfo: string
): Promise<string> => {
  try {
    const systemPrompt = buildSystemPrompt(userInfo, drugInfo);

    console.log("🤖 Calling Gemini API directly...");

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 30000);

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          contents: [
            {
              role: "user",
              parts: [
                { text: systemPrompt },
                { text: `사용자 질문: ${userQuestion}` },
              ],
            },
          ],
          generationConfig: {
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 1024,
          },
        }),
        signal: controller.signal,
      } as any
    );

    clearTimeout(timeoutId);

    console.log("✅ Response received:", response.status);
    console.log("📋 Response headers:", response.headers);

    if (!response.ok) {
      const errorData = await response.text();
      console.error("❌ Gemini API Error:", response.status, errorData);
      return "AI 응답을 생성할 수 없습니다. 나중에 다시 시도해주세요.";
    }

    const result = (await response.json()) as any;
    console.log("📦 Gemini response body:", JSON.stringify(result, null, 2));

    if (
      result.candidates &&
      result.candidates[0] &&
      result.candidates[0].content &&
      result.candidates[0].content.parts &&
      result.candidates[0].content.parts[0]
    ) {
      const content = result.candidates[0].content.parts[0].text;
      console.log("✅ Gemini API Success");
      return content;
    }

    console.error("⚠️  Unexpected response structure:", result);
    return "응답을 생성할 수 없습니다.";
  } catch (error) {
    if (error instanceof Error && error.name === "AbortError") {
      console.error("❌ Gemini API Timeout: Request took more than 30 seconds");
      return "AI 응답 생성 중 시간 초과가 발생했습니다. 나중에 다시 시도해주세요.";
    }
    console.error("❌ Gemini API 오류:", error);
    return "AI 응답 생성 중 오류가 발생했습니다.";
  }
};

// Cloudflare Workers를 통해 Gemini API 호출 (Fallback)
const generateMedicalAdvice = async (
  userQuestion: string,
  userInfo: any,
  drugInfo: string
): Promise<string> => {
  try {
    const systemPrompt = buildSystemPrompt(userInfo, drugInfo);

    console.log("🤖 Calling Gemini API via Cloudflare Workers...");
    console.log("📍 Cloudflare Worker URL:", CLOUDFLARE_WORKER_URL);

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 30000);

    const response = await fetch(`${CLOUDFLARE_WORKER_URL}/gemini`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        systemPrompt,
        userQuestion,
      }),
      signal: controller.signal,
    });

    clearTimeout(timeoutId);

    console.log("✅ Response received:", response.status);

    if (!response.ok) {
      const errorData = await response.text();
      console.error("❌ Cloudflare API Error:", response.status, errorData);
      return "AI 응답을 생성할 수 없습니다. 나중에 다시 시도해주세요.";
    }

    const result = (await response.json()) as any;

    if (result.success && result.content) {
      console.log("✅ Gemini API Success via Cloudflare");
      return result.content;
    }

    console.error("⚠️  Unexpected response:", result);
    return "응답을 생성할 수 없습니다.";
  } catch (error) {
    if (error instanceof Error && error.name === "AbortError") {
      console.error("❌ Gemini API Timeout: Request took more than 30 seconds");
      return "AI 응답 생성 중 시간 초과가 발생했습니다. 나중에 다시 시도해주세요.";
    }
    console.error("❌ Gemini API 오류:", error);
    return "AI 응답 생성 중 오류가 발생했습니다.";
  }
};

// 사용자 질문 저장 및 응답
export const sendChatMessage = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    const { content, medication_id } = req.body;

    console.log("💬 Chat request received");
    console.log("   User ID:", userId);
    console.log("   Content:", content);
    console.log("   Medication ID:", medication_id);

    if (!userId) {
      return res.status(401).json({ error: "인증이 필요합니다" });
    }

    if (!content) {
      return res.status(400).json({ error: "메시지 내용이 필요합니다" });
    }

    // 사용자 정보 조회
    console.log("🔍 Fetching user info...");
    const userResult = await query(
      "SELECT id, name, age, gender FROM users WHERE id = $1",
      [userId]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: "사용자를 찾을 수 없습니다" });
    }

    const userInfo = userResult.rows[0];
    console.log("✅ User found:", userInfo.name);

    // 약 정보 조회 (선택사항)
    let drugInfo = "";
    if (medication_id) {
      const medResult = await query(
        "SELECT drug_name, ingredient FROM medications WHERE id = $1 AND user_id = $2",
        [medication_id, userId]
      );

      if (medResult.rows.length > 0) {
        drugInfo = await fetchDrugInfoFromEYakEunyo(
          medResult.rows[0].drug_name
        );
      }
    }

    // 직전 대화 히스토리(최근 5개) 추출
    const history = await query(
      `SELECT role, content FROM chat_messages WHERE user_id = $1 ORDER BY created_at DESC LIMIT 5`,
      [userId]
    );
    const historyText = history.rows
      .reverse()
      .map((r: any) => `${r.role === "user" ? "사용자" : "AI"}: ${r.content}`)
      .join("\n");

    const enrichedDrugInfo = historyText
      ? `${drugInfo}\n\n이전 대화:\n${historyText}`
      : drugInfo;

    // Gemini API로 응답 생성 (간단한 재시도 2회)
    console.log("🤖 Generating AI response...");
    let aiResponse = "";
    const attempts = GEMINI_API_KEY ? [1, 2] : [1, 2];
    for (const _ of attempts) {
      aiResponse = GEMINI_API_KEY
        ? await generateMedicalAdviceDirectly(
            content,
            userInfo,
            enrichedDrugInfo
          )
        : await generateMedicalAdvice(content, userInfo, enrichedDrugInfo);
      if (
        aiResponse &&
        aiResponse.trim().length > 0 &&
        !aiResponse.startsWith("AI 응답을 생성할 수 없습니다")
      ) {
        break;
      }
      console.warn("⚠️  AI 응답 재시도");
    }
    console.log(
      "✅ AI response generated:",
      aiResponse.substring(0, 50) + "..."
    );

    // 사용자 메시지 저장
    const userMessageResult = await query(
      `INSERT INTO chat_messages (user_id, role, content) 
       VALUES ($1, 'user', $2) 
       RETURNING id, created_at`,
      [userId, content]
    );

    // AI 응답 메시지 저장
    const aiMessageResult = await query(
      `INSERT INTO chat_messages (user_id, role, content) 
       VALUES ($1, 'assistant', $2) 
       RETURNING id, created_at`,
      [userId, aiResponse]
    );

    console.log("✅ Chat messages saved to database");

    return res.status(201).json({
      message: "채팅 메시지가 저장되었습니다",
      userMessage: {
        id: userMessageResult.rows[0].id,
        role: "user",
        content: content,
        createdAt: userMessageResult.rows[0].created_at,
      },
      aiMessage: {
        id: aiMessageResult.rows[0].id,
        role: "assistant",
        content: aiResponse,
        createdAt: aiMessageResult.rows[0].created_at,
      },
    });
  } catch (error) {
    console.error("❌ Send chat message error:", error);
    return res
      .status(500)
      .json({ error: "메시지 전송 중 오류가 발생했습니다" });
  }
};

// 채팅 이력 조회
export const getChatHistory = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;

    if (!userId) {
      return res.status(401).json({ error: "인증이 필요합니다" });
    }

    const result = await query(
      "SELECT * FROM chat_messages WHERE user_id = $1 ORDER BY created_at ASC",
      [userId]
    );

    return res.json({
      messages: result.rows,
    });
  } catch (error) {
    console.error("Get chat history error:", error);
    return res
      .status(500)
      .json({ error: "채팅 이력 조회 중 오류가 발생했습니다" });
  }
};

// 채팅 이력 삭제
export const deleteChatHistory = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;

    if (!userId) {
      return res.status(401).json({ error: "인증이 필요합니다" });
    }

    await query("DELETE FROM chat_messages WHERE user_id = $1", [userId]);

    return res.json({
      message: "채팅 이력이 삭제되었습니다",
    });
  } catch (error) {
    console.error("Delete chat history error:", error);
    return res
      .status(500)
      .json({ error: "채팅 이력 삭제 중 오류가 발생했습니다" });
  }
};
