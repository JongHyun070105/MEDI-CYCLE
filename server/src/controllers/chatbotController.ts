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

    // 응답 텍스트로 먼저 읽기
    const responseText = await response.text();

    // JSON 파싱 시도
    let data: any;
    try {
      data = JSON.parse(responseText);
    } catch (parseError) {
      console.error("❌ e약은요 API JSON 파싱 오류:", parseError);
      console.error(
        "❌ 응답 텍스트 (처음 200자):",
        responseText.substring(0, 200)
      );
      return "";
    }

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
    // 모든 오류는 무시하고 빈 문자열 반환
    return "";
  }
};

// 공통 시스템 프롬프트 생성: 약학 컨시어지(쉬운 설명, 상호작용/주의 포함, 마크다운 금지)
const buildSystemPrompt = (
  userInfo: any,
  drugInfo: string,
  currentMedications: string
) => {
  const serverTime = new Date().toISOString();
  return `역할: 당신은 ${
    userInfo?.name || "사용자"
  }님의 개인 약학 전문가입니다. 의학/약학 용어를 비전문가도 이해하기 쉽게 풀어서 설명합니다.

사용자 정보:
- 이름: ${userInfo?.name || "정보 없음"}
- 나이: ${userInfo?.age || "정보 없음"}세
- 성별: ${userInfo?.gender || "정보 없음"}
- 알레르기: ${userInfo?.allergies || "없음"}
- 복용 중인 약물: ${currentMedications || "없음"}
- 기존 질병: ${userInfo?.existing_diseases || "정보 없음"}

핵심 규칙:
1. 위 사용자 정보를 고려하여 개인화된 약학 정보 제공
2. 알레르기와 복용 중인 약물의 상호작용 주의
3. 나이와 성별에 따른 적절한 복용량 안내
4. 기존 질병과의 상호작용 고려
5. 응급상황 시 즉시 병원 방문 권유
6. 의심스러운 경우 의사 상담 권유

답변 원칙:
- 한국어로, 짧은 문장과 단락 사용. 과장/단정 금지.
- 마크다운 코드블록 별표 백틱 번호 라벨 없이 순수 텍스트만 사용. 굵게, 리스트 마커 금지
- 요청이 약물과 무관하면 1줄로 정중히 안내하고, 약물명/증상/복용 중 약을 물어 유도.
- 부작용을 설명할 때는 흔한 증상에서 주의해야 할 심각 증상 순서로 간단히.
- 상호작용은 대표적인 상충 약물/음식/알코올이 있으면 짧게 언급.
- 응급상황 징후가 의심되면 즉시 119/응급실 안내.
- 개인 맞춤: 사용자의 나이/성별/기저질환/복용약 정보가 부족하면 추가 질문을 제안.
- 날짜/시간은 추정하지 말고, 필요한 경우 다음 값을 사용: 서버시각 ${serverTime}
- 사용자가 복용 중인 약에 대해 물어볼 때, 사용자님께서 현재 복용 중이라고 알려주신 약은 바로 약명입니다. 형식으로 답변하세요. 복용 중인 약이 여러 개인 경우 모두 나열하세요. 약 목록이 비어있지 않으면 반드시 해당 약명을 명시적으로 언급하세요.
- 중요: 약 정보가 없거나 확인할 수 없는 약에 대해서는 부작용, 효능, 사용법 등을 지어내거나 추측하지 마세요. 약 정보가 없으면 "해당 약에 대한 정보를 찾을 수 없습니다. 정확한 약명을 확인하시거나 의사나 약사에게 문의하시기 바랍니다"라고만 답변하세요.
- 약 정보가 없는 경우 절대 할루시네이션(추측, 지어내기)하지 마세요. 없는 정보는 없다고 정직하게 말하세요.

약 정보 제공 시 필수 포함 사항:
- 약의 정보에 관한 질문에는 반드시 사용 기간(복용 기간, 치료 기간)을 포함하여 답변
- 예: "일반적으로 3-5일", "증상 완화 후 2일까지", "의사 처방에 따라 7-14일" 등
- 개인 상황에 맞는 구체적인 사용 기간 제시
- 약의 유통기한과 유효기간을 포함하여 답변
- 단, 약 정보가 없는 경우에는 위 정보를 추측하지 마세요.

컨텍스트(참고용):
- 약 정보(있으면 참고, 없으면 일반 가이드): ${drugInfo || "(없음)"}
- 약 정보가 "(없음)"이거나 빈 문자열인 경우, 해당 약에 대한 구체적인 정보(부작용, 효능, 사용법 등)를 제공하지 마세요.
`;
};

// Gemini API 직접 호출
const generateMedicalAdviceDirectly = async (
  userQuestion: string,
  userInfo: any,
  drugInfo: string,
  currentMedications: string,
  historyMessages: any[] = []
): Promise<string> => {
  try {
    const systemPrompt = buildSystemPrompt(
      userInfo,
      drugInfo,
      currentMedications
    );

    console.log("🤖 Calling Gemini API directly...");

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 30000);

    // 이전 대화 히스토리와 현재 질문을 contents 배열에 구성
    // Gemini API는 system instruction을 첫 메시지에 포함하고, 이후 대화는 user/model 역할로 진행
    const contents = [];

    // 첫 메시지: systemPrompt + 첫 질문 (히스토리가 없을 때) 또는 systemPrompt만 (히스토리가 있을 때)
    if (historyMessages.length === 0) {
      // 첫 대화: systemPrompt와 질문을 함께 포함
      contents.push({
        role: "user",
        parts: [{ text: `${systemPrompt}\n\n사용자 질문: ${userQuestion}` }],
      });
    } else {
      // 이전 대화가 있으면 systemPrompt를 첫 메시지로, 히스토리와 현재 질문을 이후에 추가
      contents.push({
        role: "user",
        parts: [{ text: systemPrompt }],
      });
      // 히스토리 추가 (user와 model이 번갈아 나타나야 함)
      contents.push(...historyMessages);
      // 현재 질문 추가
      contents.push({
        role: "user",
        parts: [{ text: userQuestion }],
      });
    }

    // 디버그: 최종 contents 배열 로그 출력
    console.log(
      `📦 Gemini API contents 배열 구성: ${contents.length}개 메시지`
    );
    console.log(
      `📦 첫 번째 메시지: ${
        contents[0].role
      } - ${contents[0].parts[0].text.substring(0, 100)}...`
    );
    if (contents.length > 1) {
      console.log(
        `📦 마지막 메시지: ${contents[contents.length - 1].role} - ${contents[
          contents.length - 1
        ].parts[0].text.substring(0, 100)}...`
      );
    }

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          contents: contents,
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
  drugInfo: string,
  currentMedications: string,
  historyMessages: any[] = []
): Promise<string> => {
  try {
    const systemPrompt = buildSystemPrompt(
      userInfo,
      drugInfo,
      currentMedications
    );

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
        historyMessages,
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

    // 사용자의 현재 복용 중인 약 목록 조회 (현재 날짜 기준 활성화된 약만)
    console.log("🔍 Fetching current medications...");
    const today = new Date();
    const todayStr = today.toISOString().split("T")[0]; // YYYY-MM-DD 형식

    const medicationsResult = await query(
      `SELECT drug_name FROM medications 
       WHERE user_id = $1 
       AND start_date <= $2 
       AND (is_indefinite = true OR end_date IS NULL OR end_date >= $2)
       ORDER BY created_at DESC`,
      [userId, todayStr]
    );

    let currentMedications = "";
    if (medicationsResult.rows.length > 0) {
      const medicationNames = medicationsResult.rows.map(
        (row: any) => row.drug_name
      );
      currentMedications = medicationNames.join(", ");
      console.log("✅ Current medications found:", currentMedications);
    } else {
      console.log("ℹ️  No active medications found");
    }

    // 약 정보 조회 (선택사항)
    // medication_id가 있으면 해당 약의 정보를 조회하고, 없으면 사용자 질문에서 약 이름을 추출하여 조회
    let drugInfo = "";
    let drugName = "";

    if (medication_id) {
      const medResult = await query(
        "SELECT drug_name, ingredient FROM medications WHERE id = $1 AND user_id = $2",
        [medication_id, userId]
      );

      if (medResult.rows.length > 0) {
        drugName = medResult.rows[0].drug_name;
      }
    } else {
      // medication_id가 없으면 사용자 질문에서 약 이름 추출 시도
      // 간단한 패턴 매칭: "약명" 또는 "약명에 대해" 같은 형태
      const match = content.match(
        /([\w가-힣()]+(?:정|캡슐|액|산|분말|주사|연고|크림|패치|스프레이)?)/
      );
      if (match && match[1]) {
        drugName = match[1];
      }
    }

    if (drugName) {
      console.log(`🔍 약 정보 조회: ${drugName}`);
      drugInfo = await fetchDrugInfoFromEYakEunyo(drugName);
      if (drugInfo) {
        console.log(`✅ 약 정보 조회 성공: ${drugName.substring(0, 50)}...`);
      } else {
        console.log(`⚠️ 약 정보를 찾을 수 없음: ${drugName}`);
      }
    }

    // 직전 대화 히스토리(최근 5쌍 = 10개 메시지) 추출
    // 현재 질문은 아직 저장되지 않았으므로 포함되지 않음
    const history = await query(
      `SELECT role, content FROM chat_messages WHERE user_id = $1 ORDER BY created_at DESC LIMIT 10`,
      [userId]
    );

    // 역순으로 정렬하여 시간순으로 만들기 (오래된 것이 앞에, 최신이 뒤에)
    // user와 model이 번갈아 나타나야 하므로 순서 유지
    const historyMessages = history.rows.reverse().map((r: any) => ({
      role: r.role === "user" ? "user" : "model",
      parts: [{ text: r.content }],
    }));

    // 디버그: 히스토리 로그 출력
    console.log(`📝 대화 히스토리: ${historyMessages.length}개 메시지`);
    if (historyMessages.length > 0) {
      historyMessages.forEach((msg, idx) => {
        console.log(
          `📝 히스토리[${idx}]: ${msg.role} - ${msg.parts[0].text.substring(
            0,
            50
          )}...`
        );
      });
    }

    const enrichedDrugInfo = drugInfo;

    // Gemini API로 응답 생성 (간단한 재시도 2회)
    console.log("🤖 Generating AI response...");
    let aiResponse = "";
    const attempts = GEMINI_API_KEY ? [1, 2] : [1, 2];
    for (const _ of attempts) {
      aiResponse = GEMINI_API_KEY
        ? await generateMedicalAdviceDirectly(
            content,
            userInfo,
            enrichedDrugInfo,
            currentMedications,
            historyMessages
          )
        : await generateMedicalAdvice(
            content,
            userInfo,
            enrichedDrugInfo,
            currentMedications,
            historyMessages
          );
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
