import { Request, Response } from "express";
import PDFDocument from "pdfkit";
import { query } from "../database/db.js";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const GEMINI_API_KEY = process.env.GEMINI_API_KEY || "";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const generateReport = async (req: Request, res: Response) => {
  // 스트림 에러 플래그 및 doc 변수 (catch 블록에서 접근 가능하도록 함수 상단 선언)
  let streamError = false;
  let doc: InstanceType<typeof PDFDocument> | null = null;

  try {
    const userId = req.userId;
    if (!userId) return res.status(401).json({ error: "인증이 필요합니다" });

    // 기본 프로필
    const user = await query(
      `SELECT id, name, email, age, gender, address FROM users WHERE id = $1`,
      [userId]
    );
    const u = user.rows[0] || {};

    const generatedAt = new Date();
    const reportEndDate = generatedAt.toISOString().split("T")[0]; // 리포트 생성일

    // 복용 시작일부터 리포트 생성일까지의 복약 성실도 계산
    // 먼저 가장 이른 복용 시작일과 가장 늦은 복용 종료일(또는 리포트 생성일)을 찾음
    const dateRangeRes = await query(
      `SELECT 
         MIN(start_date)::date AS earliest_start,
         MAX(COALESCE(end_date, CURRENT_DATE))::date AS latest_end
       FROM medications 
       WHERE user_id = $1`,
      [userId]
    );

    const earliestStart = dateRangeRes.rows[0]?.earliest_start || reportEndDate;
    const reportStartDate = earliestStart;

    // 건강 인사이트 조회 (복용 시작일부터 리포트 생성일까지)
    const insightsRes = await query(
      `WITH days AS (
         SELECT dd::date AS d
         FROM generate_series($2::date, $3::date, interval '1 day') dd
       ),
       plans AS (
         SELECT dd::date AS d, COALESCE(array_length(m.dosage_times,1),0) AS planned
         FROM medications m
         JOIN LATERAL generate_series(
           GREATEST(m.start_date::date, $2::date),
           LEAST(COALESCE(m.end_date::date, $3::date), $3::date),
           interval '1 day'
         ) dd ON TRUE
         WHERE m.user_id = $1
           AND m.start_date::date <= $3::date
           AND COALESCE(m.end_date::date, $3::date) >= $2::date
       ),
       takes AS (
         SELECT date_trunc('day', mi.intake_time)::date AS d,
                COUNT(*) FILTER (WHERE mi.is_taken = TRUE) AS completed
         FROM medication_intakes mi
         JOIN medications m ON m.id = mi.medication_id AND m.user_id = $1
         WHERE mi.intake_time >= $2::date AND mi.intake_time <= $3::date
         GROUP BY 1
       )
       SELECT d.d,
              COALESCE((SELECT SUM(planned)::integer FROM plans p WHERE p.d = d.d),0)::integer AS planned,
              COALESCE((SELECT completed::integer FROM takes t WHERE t.d = d.d),0)::integer AS completed
       FROM days d
       ORDER BY d.d`,
      [userId, reportStartDate, reportEndDate]
    );
    const insightRows = insightsRes.rows;
    // 숫자로 명시적 변환하여 포맷팅 문제 방지
    const totalPlanned = insightRows.reduce((a, r: any) => {
      const planned = Number(r.planned) || 0;
      return a + (isFinite(planned) ? planned : 0);
    }, 0);
    const totalCompleted = insightRows.reduce((a, r: any) => {
      const completed = Number(r.completed) || 0;
      return a + (isFinite(completed) ? completed : 0);
    }, 0);
    const overallPct90 =
      totalPlanned > 0 ? Math.round((totalCompleted / totalPlanned) * 100) : 0;

    // 디버깅 로그
    console.log(`📄 리포트 인사이트 계산 (사용자 ${userId}):`);
    console.log(`   총 계획: ${totalPlanned}회`);
    console.log(`   총 완료: ${totalCompleted}회`);
    console.log(`   복용률: ${overallPct90}%`);

    // 숫자 포맷팅 함수 (천 단위 구분자)
    const formatNumber = (num: number): string => {
      return Number(num).toLocaleString("ko-KR");
    };

    // 월별 인사이트도 가져오기
    const monthlyRes = await query(
      `SELECT to_char(date_trunc('month', d), 'YYYY-MM') AS month,
              SUM(planned) AS planned,
              SUM(completed) AS completed,
              CASE WHEN SUM(planned) > 0 THEN ROUND((SUM(completed)::numeric / SUM(planned)) * 100,0)
                   ELSE 0 END AS pct
       FROM (
         SELECT dd::date AS d, COALESCE(array_length(m.dosage_times,1),0) AS planned, 0 AS completed
         FROM medications m
         JOIN LATERAL generate_series(date_trunc('month', CURRENT_DATE) - interval '2 month', CURRENT_DATE, interval '1 day') dd ON dd BETWEEN m.start_date AND COALESCE(m.end_date, CURRENT_DATE)
         WHERE m.user_id = $1
         UNION ALL
         SELECT date_trunc('day', mi.intake_time)::date AS d, 0 AS planned, COUNT(*) FILTER (WHERE mi.is_taken = TRUE) AS completed
         FROM medication_intakes mi
         JOIN medications m ON m.id = mi.medication_id AND m.user_id = $1
         WHERE mi.intake_time >= date_trunc('month', CURRENT_DATE) - interval '2 month'
         GROUP BY 1
       ) s
       GROUP BY 1
       ORDER BY 1`,
      [userId]
    );
    const months = monthlyRes.rows || [];

    // 현재 복용 중인 약 목록 (AI 인사이트 생성 전에 먼저 가져오기)
    const meds = await query(
      `SELECT id, drug_name, manufacturer, ingredient, frequency, dosage_times, start_date, end_date, is_indefinite
       FROM medications WHERE user_id = $1 ORDER BY created_at DESC LIMIT 50`,
      [userId]
    );

    // AI를 활용한 인사이트 생성
    let aiInsight = "";
    let tips: string[] = [];

    try {
      // 사용자 정보와 복약 데이터를 기반으로 AI 인사이트 생성
      const medicationNames = meds.rows.map((m: any) => m.drug_name).join(", ");
      const currentMedications = medicationNames || "없음";

      const prompt = `다음은 환자의 복약 리포트 데이터입니다. 의사 상담에 도움이 되는 전문적이고 구체적인 인사이트를 제공해주세요.

환자 정보:
- 이름: ${u.name || "정보 없음"}
- 나이: ${u.age || "정보 없음"}세
- 성별: ${u.gender || "정보 없음"}

현재 복용 중인 약물: ${currentMedications}

복약 성실도:
- 최근 90일 복약 성실도: ${overallPct90}%
- 계획 횟수: ${formatNumber(totalPlanned)}회
- 완료 횟수: ${formatNumber(totalCompleted)}회

월별 추세:
${months.map((m: any) => `- ${m.month}: ${m.pct || 0}%`).join("\n")}

위 데이터를 바탕으로 다음을 제공해주세요:
1. 환자의 복약 패턴에 대한 전문적인 분석 (2-3문장)
2. 개선이 필요한 부분이 있다면 구체적인 권장사항 (2-3개 항목)

중요: 마크다운, 별표, 번호 없이 순수 텍스트만 제공하세요. 형식은 "• "로 시작하는 문장으로 나열하세요.`;

      if (GEMINI_API_KEY) {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 15000);

        const response = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=${GEMINI_API_KEY}`,
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              contents: [
                {
                  role: "user",
                  parts: [{ text: prompt }],
                },
              ],
              generationConfig: {
                temperature: 0.7,
                topK: 40,
                topP: 0.95,
                maxOutputTokens: 512,
              },
            }),
            signal: controller.signal,
          } as any
        );

        clearTimeout(timeoutId);

        if (response.ok) {
          const result = (await response.json()) as any;
          if (result.candidates?.[0]?.content?.parts?.[0]?.text) {
            const fullResponse = result.candidates[0].content.parts[0].text;
            // 응답을 문장별로 분리
            const lines = fullResponse
              .split("\n")
              .filter((l: string) => l.trim());

            // 인사이트 메시지 추출 (첫 번째 문단 또는 "•"로 시작하는 첫 2-3개 문장)
            const insightLines = lines.filter(
              (l: string) =>
                l.trim().startsWith("•") ||
                (l.trim().length > 20 && !l.trim().match(/^[0-9]/))
            );

            if (insightLines.length > 0) {
              aiInsight = insightLines
                .slice(0, 2)
                .map((l: string) => l.replace(/^•\s*/, "").trim())
                .join(" ");
            } else if (lines.length > 0) {
              aiInsight = lines[0].trim();
            }

            // 팁 추출 (나머지 문장들 중에서)
            const tipLines = lines.filter(
              (l: string, idx: number) =>
                l.trim().length > 15 &&
                idx >= 2 && // 인사이트가 아닌 것들 (2번째 줄부터)
                (l.trim().startsWith("•") ||
                  l.trim().match(/^[0-9]/) ||
                  l.trim().includes("권장") ||
                  l.trim().includes("제안"))
            );

            if (tipLines.length > 0) {
              tips = tipLines
                .slice(0, 3)
                .map((t: string) => t.replace(/^[•\-0-9.]\s*/, "").trim());
            }
          }
        }
      }
    } catch (error) {
      console.error("AI 인사이트 생성 오류:", error);
    }

    // AI 인사이트가 없으면 기본 인사이트 사용
    let insightMessage = aiInsight || "최근 3개월 복용률 추세를 확인하세요.";
    if (!aiInsight && months.length >= 2) {
      const first: any = months[0];
      const last: any = months[months.length - 1];
      const diff = (last.pct || 0) - (first.pct || 0);
      if (diff > 0)
        insightMessage = `최근 3개월 약 복용률이 ${diff}% 올랐습니다.`;
      else if (diff < 0)
        insightMessage = `최근 3개월 약 복용률이 ${Math.abs(
          diff
        )}% 감소했습니다.`;
      else insightMessage = `최근 3개월 약 복용률에 변화가 없습니다.`;
    }

    // 기본 팁 추가 (AI 팁이 없을 경우)
    if (tips.length === 0) {
      if (overallPct90 < 60)
        tips.push("복용 알림 시간을 생활 패턴에 맞게 조정해 보세요.");
      if (months.some((m: any) => (m.pct || 0) < 50))
        tips.push("자주 놓치는 시간대를 집중 관리하세요.");
      tips.push("이상 반응이 있으면 즉시 복용을 중단하고 전문가와 상담하세요.");
    }

    // PDF 스트림 응답
    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", "inline; filename=yakdrugreport.pdf");

    // 한글 지원을 위한 폰트 설정
    doc = new PDFDocument({ size: "A4", margin: 50 });

    // doc이 생성되었는지 확인 (null이 아님을 보장)
    if (!doc) {
      throw new Error("PDF Document 생성 실패");
    }

    // doc이 null이 아님을 TypeScript에게 알림 (타입 단언)
    // 이후 코드에서 doc은 null이 아님을 보장
    const pdfDoc: InstanceType<typeof PDFDocument> = doc;

    // 스트림 에러 핸들러 추가
    pdfDoc.on("error", (err: Error) => {
      if (streamError) return; // 이미 에러 처리 중이면 무시
      streamError = true;
      console.error("PDF Document stream error:", err);

      // pipe 즉시 해제하여 추가 쓰기 방지
      try {
        pdfDoc.unpipe(res);
        pdfDoc.end();
      } catch (e) {
        // pipe 해제 실패 무시
      }

      // 응답 처리
      if (!res.headersSent) {
        try {
          res
            .status(500)
            .json({ error: "PDF 생성 중 스트림 오류가 발생했습니다" });
        } catch (e) {
          // 응답 전송 실패 무시
        }
      } else {
        // 응답이 이미 시작된 경우 안전하게 종료
        try {
          if (!res.writableEnded && !res.writableFinished) {
            res.end();
          }
        } catch (e) {
          // 이미 종료된 경우 무시
        }
      }
    });

    res.on("error", (err: Error) => {
      if (streamError) return; // 이미 에러 처리 중이면 무시
      streamError = true;
      console.error("Response stream error:", err);

      // pipe 즉시 해제 및 doc 종료
      try {
        pdfDoc.unpipe(res);
        pdfDoc.end();
      } catch (e) {
        // pipe 해제 실패 무시
      }
    });

    // 캐시 방지 헤더 설정
    res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    res.setHeader("Pragma", "no-cache");
    res.setHeader("Expires", "0");
    res.setHeader("Content-Type", "application/pdf");
    res.setHeader(
      "Content-Disposition",
      `attachment; filename="yakdrugreport_${Date.now()}.pdf"`
    );

    pdfDoc.pipe(res);

    // 한글 폰트 설정 시도 (시스템 폰트 경로 사용)
    // macOS/Linux: /System/Library/Fonts 또는 /usr/share/fonts
    // Windows: C:/Windows/Fonts
    // Docker 환경에서는 NotoSansKR 같은 폰트를 직접 추가해야 함

    let koreanFont: string | null = null;
    const fontPaths = [
      // 프로젝트 내 Jua 폰트 (우선순위 1 - TTF 파일)
      "/app/fonts/Jua-Regular.ttf",
      path.join(__dirname, "../../../fonts/Jua-Regular.ttf"),
      path.join(__dirname, "../../fonts/Jua-Regular.ttf"),
      // Docker/Alpine Linux - 나눔 폰트 (대체 폰트)
      "/usr/share/fonts/truetype/nanum/NanumGothic.ttf",
      "/app/fonts/NanumGothic.ttf",
      path.join(__dirname, "../../../fonts/NanumGothic.ttf"),
      path.join(__dirname, "../../fonts/NanumGothic.ttf"),
      // macOS
      "/System/Library/Fonts/Supplemental/AppleGothic.ttf",
      "/System/Library/Fonts/AppleGothic.ttf",
      // Windows (참고용, 서버에서는 일반적으로 사용 안 함)
      "C:/Windows/Fonts/malgun.ttf",
      // TTC 파일은 pdfkit에서 직접 지원하지 않으므로 제외
    ];

    for (const fontPath of fontPaths) {
      try {
        if (fs.existsSync(fontPath)) {
          koreanFont = fontPath;
          // TTC 파일은 pdfkit에서 직접 지원하지 않을 수 있으므로 try-catch로 처리
          try {
            pdfDoc.registerFont("Korean", fontPath);
            console.log(`✅ 한글 폰트 로드 성공: ${fontPath}`);
            break;
          } catch (fontError: any) {
            console.warn(`⚠️ 폰트 등록 실패 (${fontPath}):`, fontError.message);
            // TTC 파일이거나 지원하지 않는 형식인 경우 스킵하고 다음 폰트 시도
            if (
              fontPath.endsWith(".ttc") ||
              fontPath.endsWith(".otc") ||
              fontError.message.includes("createSubset")
            ) {
              continue;
            }
            throw fontError;
          }
        }
      } catch (e) {
        // 폰트 로드 실패 시 다음 경로 시도
        continue;
      }
    }

    // 한글 폰트가 없으면 기본 폰트 사용 (한글이 깨질 수 있음)
    const useKoreanFont = (text: string) => {
      if (koreanFont) {
        pdfDoc.font("Korean");
      } else {
        // 기본 폰트 사용 (한글은 깨질 수 있음)
        pdfDoc.font("Helvetica");
      }
      return text;
    };

    // 로컬 시간대로 포맷팅 (Asia/Seoul)
    const formatDate = (d: Date) => {
      const koreaTime = new Date(
        d.toLocaleString("en-US", { timeZone: "Asia/Seoul" })
      );
      return `${koreaTime.getFullYear()}.${String(
        koreaTime.getMonth() + 1
      ).padStart(2, "0")}.${String(koreaTime.getDate()).padStart(
        2,
        "0"
      )} ${String(koreaTime.getHours()).padStart(2, "0")}:${String(
        koreaTime.getMinutes()
      ).padStart(2, "0")}`;
    };

    // 헤더 함수 (섹션 제목 스타일 통일 - 왼쪽 정렬)
    const drawSectionTitle = (title: string) => {
      const titleX = 50; // 왼쪽에 딱 붙이기
      const titleY = pdfDoc.y;
      pdfDoc.fontSize(16);
      if (koreanFont) {
        pdfDoc.font("Korean");
      } else {
        pdfDoc.font("Helvetica-Bold");
      }
      pdfDoc.text(title, titleX, titleY);

      // 하단선 그리기 (제목 아래)
      const lineY = titleY + 20; // 제목 높이 고려
      pdfDoc
        .moveTo(50, lineY)
        .lineTo(pdfDoc.page.width - 50, lineY)
        .stroke("#333");

      // 다음 위치 설정
      pdfDoc.y = lineY + 8;
    };

    // Header
    pdfDoc.fontSize(22);
    if (koreanFont) {
      pdfDoc.font("Korean");
    } else {
      pdfDoc.font("Helvetica-Bold");
    }
    pdfDoc.text("약드셔유 - 의사 상담용 리포트", { align: "center" });
    pdfDoc.moveDown(0.4);
    pdfDoc.fontSize(10);
    if (koreanFont) {
      pdfDoc.font("Korean");
    } else {
      pdfDoc.font("Helvetica");
    }
    pdfDoc.text(`생성일시: ${formatDate(generatedAt)}`, { align: "center" });
    pdfDoc.moveDown(1.2);

    // Patient Info (박스 형태로 개선)
    drawSectionTitle("환자 정보");

    const infoBoxX = 50;
    const infoBoxY = pdfDoc.y;
    const infoBoxW = pdfDoc.page.width - 100;
    const infoBoxH = 70; // 환자 ID 제거로 높이 감소

    // 정보 박스 배경 먼저 그리기
    pdfDoc.rect(infoBoxX, infoBoxY, infoBoxW, infoBoxH).fill("#F9F9F9");
    pdfDoc.rect(infoBoxX, infoBoxY, infoBoxW, infoBoxH).stroke("#DDD");

    // 텍스트 색상 설정
    pdfDoc.fillColor("#000");
    pdfDoc.fontSize(11);
    if (koreanFont) {
      pdfDoc.font("Korean");
    } else {
      pdfDoc.font("Helvetica");
    }

    // 2열 레이아웃으로 정보 표시
    const infoLeftX = infoBoxX + 15;
    const infoRightX = infoBoxX + infoBoxW / 2 + 10;
    let infoCurrentY = infoBoxY + 15;

    pdfDoc.fillColor("#000");
    pdfDoc.text(`이름: ${u.name || "-"}`, infoLeftX, infoCurrentY);
    pdfDoc.text(`나이: ${u.age ?? "-"}세`, infoRightX, infoCurrentY);
    infoCurrentY += 18;

    pdfDoc.fillColor("#000");
    pdfDoc.text(`성별: ${u.gender || "-"}`, infoLeftX, infoCurrentY);
    pdfDoc.text(`주소: ${u.address || "-"}`, infoRightX, infoCurrentY, {
      width: infoBoxW / 2 - 20,
    });
    infoCurrentY += 18;

    pdfDoc.fillColor("#000");
    pdfDoc.text(`이메일: ${u.email || "-"}`, infoLeftX, infoCurrentY, {
      width: infoBoxW - 30,
    });

    pdfDoc.y = infoBoxY + infoBoxH + 15;

    // Adherence (박스 형태로 개선)
    drawSectionTitle("최근 90일 복약 성실도");

    const adherenceBoxX = 50;
    const adherenceBoxY = pdfDoc.y;
    const adherenceBoxW = pdfDoc.page.width - 100;
    const adherenceBoxH = 120; // 바 차트만 포함하여 높이 조정

    // 성실도 박스 배경
    pdfDoc
      .rect(adherenceBoxX, adherenceBoxY, adherenceBoxW, adherenceBoxH)
      .fill("#FAFAFA");
    pdfDoc
      .rect(adherenceBoxX, adherenceBoxY, adherenceBoxW, adherenceBoxH)
      .stroke("#DDD");

    // 통계 정보 (2열 레이아웃)
    pdfDoc.fontSize(11);
    if (koreanFont) {
      pdfDoc.font("Korean");
    } else {
      pdfDoc.font("Helvetica");
    }

    const statLeftX = adherenceBoxX + 20;
    const statRightX = adherenceBoxX + adherenceBoxW / 2 + 20;
    let statY = adherenceBoxY + 20;

    pdfDoc.text(
      `완료 횟수: ${formatNumber(totalCompleted)}회`,
      statLeftX,
      statY
    );
    pdfDoc.text(
      `계획 횟수: ${formatNumber(totalPlanned)}회`,
      statRightX,
      statY
    );
    statY += 20;

    pdfDoc.fontSize(12);
    if (koreanFont) {
      pdfDoc.font("Korean");
    } else {
      pdfDoc.font("Helvetica-Bold");
    }
    pdfDoc.text(`성실도: ${overallPct90}%`, statLeftX, statY);

    // 성실도 바 차트
    const barX = adherenceBoxX + 20;
    const barY = statY + 25;
    const barW = adherenceBoxW - 40;
    const barH = 25;
    const fillW = Math.max(
      0,
      Math.min(barW, Math.round((overallPct90 / 100) * barW))
    );

    // 배경 그리기
    pdfDoc.rect(barX, barY, barW, barH).fill("#E8F5E9");

    // 채우기
    if (fillW > 0) {
      pdfDoc.rect(barX, barY, fillW, barH).fill("#4CAF50");
    }

    // 외곽선 그리기
    pdfDoc.rect(barX, barY, barW, barH).stroke("#999");

    // 퍼센트 텍스트 (바 중앙에 표시)
    pdfDoc.fontSize(11);
    if (koreanFont) {
      pdfDoc.font("Korean");
    } else {
      pdfDoc.font("Helvetica-Bold");
    }
    const percentText = `${overallPct90}%`;
    const textWidth = pdfDoc.widthOfString(percentText);
    const textX = barX + (barW - textWidth) / 2;
    pdfDoc.fillColor("#000");
    pdfDoc.text(percentText, textX, barY + 7, {
      width: barW,
      align: "center",
    });
    pdfDoc.fillColor("#000"); // 기본 색상으로 복원

    // 박스 하단 위치 조정
    pdfDoc.y = barY + barH + 20;

    // AI 인사이트 (박스 형태로 개선)
    drawSectionTitle("AI 복약 인사이트");

    const insightBoxX = 50;
    const insightBoxY = pdfDoc.y;
    const insightBoxW = pdfDoc.page.width - 100;

    pdfDoc.fontSize(11);
    if (koreanFont) {
      pdfDoc.font("Korean");
    } else {
      pdfDoc.font("Helvetica");
    }

    // 텍스트 높이 계산을 위한 임시 위치
    let textY = insightBoxY + 15;
    let hasContent = false;

    // 인사이트 메시지
    if (insightMessage && insightMessage.trim()) {
      const messageLines = pdfDoc.heightOfString(insightMessage, {
        width: insightBoxW - 30,
      });
      textY += messageLines + 10;
      hasContent = true;
    }

    // 팁들
    if (tips.length > 0) {
      pdfDoc.fontSize(10);
      tips.forEach((tip) => {
        if (tip && tip.trim()) {
          const tipLines = pdfDoc.heightOfString(tip, {
            width: insightBoxW - 30,
          });
          textY += tipLines + 8;
          hasContent = true;
        }
      });
    }

    // 내용이 없으면 안내 메시지
    if (!hasContent) {
      textY += 20;
    }

    // 박스 높이 계산
    const insightBoxH = Math.max(textY - insightBoxY + 10, 40);

    // 박스 그리기
    pdfDoc
      .rect(insightBoxX, insightBoxY, insightBoxW, insightBoxH)
      .fill("#F0F7FF");
    pdfDoc
      .rect(insightBoxX, insightBoxY, insightBoxW, insightBoxH)
      .stroke("#BBDEFB");

    // 텍스트 그리기 (박스 위에)
    pdfDoc.fontSize(11);
    if (koreanFont) {
      pdfDoc.font("Korean");
    } else {
      pdfDoc.font("Helvetica");
    }

    let currentY = insightBoxY + 15;

    if (insightMessage && insightMessage.trim()) {
      pdfDoc.fillColor("#000");
      pdfDoc.text(insightMessage, insightBoxX + 15, currentY, {
        width: insightBoxW - 30,
        align: "left",
        lineGap: 3,
      });
      const messageHeight = pdfDoc.heightOfString(insightMessage, {
        width: insightBoxW - 30,
      });
      currentY += messageHeight + 10;
    }

    if (tips.length > 0) {
      pdfDoc.fontSize(10);
      tips.forEach((tip) => {
        if (tip && tip.trim()) {
          pdfDoc.fillColor("#000");
          pdfDoc.text("• " + tip, insightBoxX + 15, currentY, {
            width: insightBoxW - 30,
            align: "left",
            lineGap: 2,
          });
          const tipHeight = pdfDoc.heightOfString(tip, {
            width: insightBoxW - 30,
          });
          currentY += tipHeight + 8;
        }
      });
    }

    if (!hasContent) {
      pdfDoc.fontSize(11);
      pdfDoc.fillColor("#666");
      pdfDoc.text(
        "최근 복약 데이터가 부족하여 인사이트를 생성할 수 없습니다.",
        insightBoxX + 15,
        currentY,
        {
          width: insightBoxW - 30,
          align: "left",
        }
      );
    }

    pdfDoc.fillColor("#000"); // 기본 색상으로 복원
    pdfDoc.y = insightBoxY + insightBoxH + 15;

    // Medications (table) - 섹션 제목 개선
    drawSectionTitle("현재 복용 중인 약물");

    // 테이블 폭 조정 (페이지 폭에 맞게)
    const pageWidth = pdfDoc.page.width;
    const tableMargin = 50;
    const availableWidth = pageWidth - tableMargin * 2;
    const cellSpacing = 5; // 셀 간격
    const totalSpacing = cellSpacing * 3; // 4개 셀 사이 3개 간격
    const totalCellWidth = availableWidth - totalSpacing;

    const table = {
      x: tableMargin,
      y: pdfDoc.y,
      widths: [
        Math.floor(totalCellWidth * 0.32), // 약물명 32%
        Math.floor(totalCellWidth * 0.12), // 횟수 12%
        Math.floor(totalCellWidth * 0.28), // 복용 시간 28%
        Math.floor(totalCellWidth * 0.28), // 복용 기간 28%
      ],
      lineH: 30, // 행 높이 증가
      cellPadding: 10, // 패딩 증가
      spacing: cellSpacing,
    };

    const drawRow = (cells: string[], isHeader = false, rowIndex = -1) => {
      let x = table.x;
      const rowY = table.y;

      // 셀 내용에 따라 행 높이 계산 (더 정확하게)
      let maxLines = 1;
      cells.forEach((c, i) => {
        const w = table.widths[i] || 100;
        const maxWidth = w - table.cellPadding * 2;
        if (c) {
          // 줄바꿈 문자(\n) 개수 확인
          const lineBreaks = (c.match(/\n/g) || []).length;
          // 텍스트 줄 수 계산 (대략적으로 8px당 한 글자, 한글은 더 넓음)
          const estimatedCharsPerLine = Math.floor(maxWidth / 8);
          const estimatedLines = Math.max(
            lineBreaks + 1,
            Math.ceil(c.replace(/\n/g, "").length / estimatedCharsPerLine)
          );
          if (estimatedLines > maxLines) maxLines = estimatedLines;
        }
      });

      const cellHeight = Math.max(
        table.lineH,
        maxLines * 14 + table.cellPadding * 2
      );

      // 헤더 배경색
      if (isHeader) {
        const totalWidth =
          table.widths.reduce((a, b) => a + b, 0) +
          (table.widths.length - 1) * table.spacing;
        pdfDoc.rect(table.x, rowY, totalWidth, cellHeight).fill("#F5F5F5");
      } else if (rowIndex >= 0 && rowIndex % 2 === 0) {
        // 짝수 행 배경
        const totalWidth =
          table.widths.reduce((a, b) => a + b, 0) +
          (table.widths.length - 1) * table.spacing;
        pdfDoc.rect(table.x, rowY, totalWidth, cellHeight).fill("#FAFAFA");
      }

      cells.forEach((c, i) => {
        const w = table.widths[i] || 100;
        const cellX = x;
        const cellY = rowY;

        // 셀 경계선 그리기
        pdfDoc.rect(cellX, cellY, w, cellHeight).stroke("#CCC");

        // 텍스트 그리기
        pdfDoc.fontSize(isHeader ? 11 : 10);
        if (koreanFont) {
          pdfDoc.font("Korean");
        } else {
          pdfDoc.font(isHeader ? "Helvetica-Bold" : "Helvetica");
        }

        // 텍스트 위치 조정 (상단 정렬)
        const textY = cellY + table.cellPadding;
        pdfDoc.fillColor("#000");
        pdfDoc.text(c || "-", cellX + table.cellPadding, textY, {
          width: w - table.cellPadding * 2,
          align: "left",
          lineGap: 3,
        });

        x += w + table.spacing;
      });

      table.y += cellHeight;
    };

    // 테이블 헤더
    drawRow(["약물명", "횟수", "복용 시간", "복용 기간"], true);
    table.y += 2;

    const safeStr = (v: any) =>
      v === undefined || v === null ? "-" : String(v);

    const fmtDate = (dateStr: string | null | undefined): string => {
      if (!dateStr) return "-";
      try {
        const date = new Date(dateStr);
        if (isNaN(date.getTime())) return dateStr;
        return `${date.getFullYear()}.${String(date.getMonth() + 1).padStart(
          2,
          "0"
        )}.${String(date.getDate()).padStart(2, "0")}`;
      } catch {
        return dateStr;
      }
    };

    const fmtPeriod = (m: any) => {
      const start = fmtDate(m.start_date);
      const end = m.is_indefinite ? "무기한" : fmtDate(m.end_date);
      return `${start} ~ ${end}`;
    };

    // 약물 데이터가 있는지 확인
    if (meds.rows && meds.rows.length > 0) {
      for (let i = 0; i < meds.rows.length; i++) {
        const m: any = meds.rows[i];

        // 복용 시간 정렬 (시간 순서대로)
        let times = "-";
        if (Array.isArray(m.dosage_times) && m.dosage_times.length > 0) {
          const sortedTimes = m.dosage_times
            .map((t: string) => {
              const match = t.match(/(\d{1,2}):(\d{2})/);
              if (match) {
                const hours = parseInt(match[1], 10);
                const minutes = parseInt(match[2], 10);
                return { original: t, value: hours * 60 + minutes };
              }
              return { original: t, value: 0 };
            })
            .sort((a: any, b: any) => a.value - b.value)
            .map((item: any) => item.original);
          times = sortedTimes.join(", ");
        } else if (m.dosage_times) {
          times = safeStr(m.dosage_times);
        }

        const row = [
          `${safeStr(m.drug_name)}${
            m.manufacturer ? `\n(${m.manufacturer})` : ""
          }`,
          `${safeStr(m.frequency)}회/일`,
          times,
          fmtPeriod(m),
        ];
        // new page if near bottom
        if (table.y > pdfDoc.page.height - 100) {
          pdfDoc.addPage();
          table.y = 80;
          // 테이블 헤더 다시 그리기
          drawRow(["약물명", "횟수", "복용 시간", "복용 기간"], true);
          table.y += 2;
        }
        drawRow(row, false, i);
      }
    } else {
      // 약물 데이터가 없을 때
      pdfDoc.fontSize(11);
      if (koreanFont) {
        pdfDoc.font("Korean");
      } else {
        pdfDoc.font("Helvetica");
      }
      pdfDoc.text("현재 복용 중인 약물이 없습니다.", { align: "left" });
      pdfDoc.moveDown(0.5);
    }
    pdfDoc.moveDown(1);

    // Clinician notes section - 섹션 제목 개선
    drawSectionTitle("의사 메모");

    const notesTop = pdfDoc.y;
    const notesH = 100;
    const notesW = pdfDoc.page.width - 100;
    const notesX = 50;

    // 메모 박스 그리기
    pdfDoc.rect(notesX, notesTop, notesW, notesH).stroke("#CCC");

    // 메모 영역 내부 여백 (왼쪽 정렬)
    pdfDoc.fontSize(11);
    if (koreanFont) {
      pdfDoc.font("Korean");
    } else {
      pdfDoc.font("Helvetica");
    }
    pdfDoc.text("", notesX + 5, notesTop + 5, {
      width: notesW - 10,
      height: notesH - 10,
    });

    pdfDoc.y = notesTop + notesH + 10;

    // 하단 안내 문구
    pdfDoc.fontSize(9);
    if (koreanFont) {
      pdfDoc.font("Korean");
    } else {
      pdfDoc.font("Helvetica");
    }
    pdfDoc.text(
      "※ 본 리포트는 사용자 입력 데이터를 기반으로 생성되었습니다. 임상적 판단은 반드시 전문의와 상담하시기 바랍니다.",
      { align: "left", indent: 10 }
    );

    // 스트림이 완료될 때까지 대기하는 Promise를 먼저 설정
    const streamPromise = new Promise<void>((resolve, reject) => {
      let resolved = false;

      const resolveOnce = () => {
        if (!resolved && !streamError) {
          resolved = true;
          resolve();
        }
      };

      const rejectOnce = (err: Error) => {
        if (!resolved) {
          resolved = true;
          streamError = true;
          reject(err);
        }
      };

      pdfDoc.on("end", resolveOnce);
      pdfDoc.on("error", rejectOnce);
      res.on("finish", resolveOnce);
      res.on("error", rejectOnce);

      // 타임아웃 설정 (30초)
      setTimeout(() => {
        if (!resolved && !streamError) {
          if (!res.headersSent) {
            rejectOnce(new Error("PDF generation timeout"));
          } else {
            resolveOnce();
          }
        }
      }, 30000);
    });

    // PDF 생성 완료 (에러가 발생하지 않은 경우에만)
    if (!streamError && pdfDoc) {
      try {
        pdfDoc.end();
      } catch (err) {
        // pdfDoc.end() 실패 시 에러 처리
        streamError = true;
        try {
          if (pdfDoc) {
            pdfDoc.unpipe(res);
            pdfDoc.end();
          }
        } catch (e) {
          // 무시
        }
        throw err;
      }
    }

    // 스트림 완료 대기 (에러가 발생하지 않은 경우에만)
    if (!streamError && pdfDoc) {
      try {
        await streamPromise;
      } catch (err) {
        // streamPromise가 reject된 경우 이미 에러 핸들러에서 처리됨
        throw err;
      }
    }
  } catch (error) {
    console.error("Generate report error:", error);

    // 스트림 에러 플래그 설정
    streamError = true;

    // doc이 생성된 경우 pipe 해제 및 종료
    if (doc) {
      try {
        doc.unpipe(res);
        doc.end();
      } catch (e) {
        // 이미 종료된 경우 무시
      }
    }

    // 이미 응답이 시작되었을 수 있으므로 에러 처리
    if (!res.headersSent) {
      try {
        return res
          .status(500)
          .json({ error: "리포트 생성 중 오류가 발생했습니다" });
      } catch (e) {
        // 응답 전송 실패 무시
      }
    }

    // 응답이 이미 시작된 경우에는 에러를 무시하고 종료
    try {
      if (!res.writableEnded && !res.writableFinished) {
        res.end();
      }
    } catch (_) {
      // 이미 종료된 경우 무시
    }
  }
};
