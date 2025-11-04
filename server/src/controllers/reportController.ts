import { Request, Response } from "express";
import PDFDocument from "pdfkit";
import { query } from "../database/db.js";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const generateReport = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    if (!userId) return res.status(401).json({ error: "인증이 필요합니다" });

    // 기본 프로필
    const user = await query(
      `SELECT id, name, email, age, gender, address FROM users WHERE id = $1`,
      [userId]
    );
    const u = user.rows[0] || {};

    // 건강 인사이트도 함께 조회
    const insightsRes = await query(
      `WITH days AS (
         SELECT dd::date AS d
         FROM generate_series(CURRENT_DATE - interval '90 day', CURRENT_DATE, interval '1 day') dd
       ),
       plans AS (
         SELECT dd::date AS d, COALESCE(array_length(m.dosage_times,1),0) AS planned
         FROM medications m
         JOIN LATERAL generate_series(m.start_date::date, COALESCE(m.end_date::date, CURRENT_DATE), interval '1 day') dd ON TRUE
         WHERE m.user_id = $1
       ),
       takes AS (
         SELECT date_trunc('day', mi.intake_time)::date AS d,
                COUNT(*) FILTER (WHERE mi.is_taken = TRUE) AS completed
         FROM medication_intakes mi
         JOIN medications m ON m.id = mi.medication_id AND m.user_id = $1
         GROUP BY 1
       )
       SELECT d.d,
              COALESCE((SELECT SUM(planned) FROM plans p WHERE p.d = d.d),0) AS planned,
              COALESCE((SELECT completed FROM takes t WHERE t.d = d.d),0) AS completed
       FROM days d
       ORDER BY d.d`,
      [userId]
    );
    const insightRows = insightsRes.rows;
    const totalPlanned = insightRows.reduce(
      (a, r: any) => a + (r.planned || 0),
      0
    );
    const totalCompleted = insightRows.reduce(
      (a, r: any) => a + (r.completed || 0),
      0
    );
    const overallPct90 =
      totalPlanned > 0 ? Math.round((totalCompleted / totalPlanned) * 100) : 0;

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
    let insightMessage = "최근 3개월 복용률 추세를 확인하세요.";
    if (months.length >= 2) {
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
    const tips: string[] = [];
    if (overallPct90 < 60)
      tips.push("복용 알림 시간을 생활 패턴에 맞게 조정해 보세요.");
    if (months.some((m: any) => (m.pct || 0) < 50))
      tips.push("자주 놓치는 시간대를 집중 관리하세요.");
    tips.push("이상 반응이 있으면 즉시 복용을 중단하고 전문가와 상담하세요.");

    // 현재 복용 중인 약 목록
    const meds = await query(
      `SELECT id, drug_name, manufacturer, ingredient, frequency, dosage_times, start_date, end_date, is_indefinite
       FROM medications WHERE user_id = $1 ORDER BY created_at DESC LIMIT 50`,
      [userId]
    );

    // PDF 스트림 응답
    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", "inline; filename=yakdrugreport.pdf");

    // 한글 지원을 위한 폰트 설정
    const doc = new PDFDocument({ size: "A4", margin: 50 });
    doc.pipe(res);

    // 한글 폰트 설정 시도 (시스템 폰트 경로 사용)
    // macOS/Linux: /System/Library/Fonts 또는 /usr/share/fonts
    // Windows: C:/Windows/Fonts
    // Docker 환경에서는 NotoSansKR 같은 폰트를 직접 추가해야 함
    
    let koreanFont: string | null = null;
    const fontPaths = [
      // macOS
      "/System/Library/Fonts/Supplemental/AppleGothic.ttf",
      "/System/Library/Fonts/AppleGothic.ttf",
      // Linux (일반적인 한글 폰트 경로)
      "/usr/share/fonts/truetype/nanum/NanumGothic.ttf",
      "/usr/share/fonts/truetype/noto/NotoSansCJK-Regular.ttc",
      // Windows (참고용, 서버에서는 일반적으로 사용 안 함)
      "C:/Windows/Fonts/malgun.ttf",
      "C:/Windows/Fonts/gulim.ttc",
    ];
    
    for (const fontPath of fontPaths) {
      try {
        if (fs.existsSync(fontPath)) {
          koreanFont = fontPath;
          doc.registerFont("Korean", fontPath);
          break;
        }
      } catch (e) {
        // 폰트 로드 실패 시 다음 경로 시도
        continue;
      }
    }
    
    // 한글 폰트가 없으면 기본 폰트 사용 (한글이 깨질 수 있음)
    const useKoreanFont = (text: string) => {
      if (koreanFont) {
        doc.font("Korean");
      } else {
        // 기본 폰트 사용 (한글은 깨질 수 있음)
        doc.font("Helvetica");
      }
      return text;
    };

    const generatedAt = new Date();
    const formatDate = (d: Date) =>
      `${d.getFullYear()}년 ${d.getMonth() + 1}월 ${d.getDate()}일 ${String(
        d.getHours()
      ).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}`;

    // Header
    doc
      .fontSize(24);
    if (koreanFont) {
      doc.font("Korean");
    } else {
      doc.font("Helvetica-Bold");
    }
    doc.text("약드셔유 - 의사 상담용 리포트", { align: "center" });
    doc.moveDown(0.2);
    doc.fontSize(10);
    if (koreanFont) {
      doc.font("Korean");
    } else {
      doc.font("Helvetica");
    }
    doc
      .fillColor("#666")
      .text(
        `생성일시: ${formatDate(generatedAt)}  |  환자 ID: ${u.id ?? "-"}`,
        { align: "center" }
      )
      .fillColor("#000");
    doc.moveDown();

    // Footer with page numbers
    let currentPage = 1;
    const drawFooter = (pageNo: number) => {
      const text = `페이지 ${pageNo}`;
      doc.fontSize(9);
      if (koreanFont) {
        doc.font("Korean");
      } else {
        doc.font("Helvetica");
      }
      doc
        .fillColor("#666")
        .text(text, 50, doc.page.height - 40, {
          width: doc.page.width - 100,
          align: "right",
        })
        .fillColor("#000");
    };
    drawFooter(currentPage);
    doc.on("pageAdded", () => {
      currentPage += 1;
      drawFooter(currentPage);
    });

    // Patient Info
    doc.fontSize(16);
    if (koreanFont) {
      doc.font("Korean");
    } else {
      doc.font("Helvetica-Bold");
    }
    doc.text("환자 정보", { underline: true });
    doc.moveDown(0.5);
    doc.fontSize(12);
    if (koreanFont) {
      doc.font("Korean");
    } else {
      doc.font("Helvetica");
    }
    doc.text(`이름: ${u.name || "-"}`);
    doc.text(`이메일: ${u.email || "-"}`);
    doc.text(`나이: ${u.age ?? "-"}`);
    doc.text(`성별: ${u.gender || "-"}`);
    doc.text(`주소: ${u.address || "-"}`);
    doc.moveDown();

    // Adherence
    doc.fontSize(16);
    if (koreanFont) {
      doc.font("Korean");
    } else {
      doc.font("Helvetica-Bold");
    }
    doc.text("최근 90일 복약 성실도", { underline: true });
    doc.moveDown(0.5);
    doc.fontSize(12);
    if (koreanFont) {
      doc.font("Korean");
    } else {
      doc.font("Helvetica");
    }
    doc.text(`완료 횟수: ${totalCompleted ?? 0}회`);
    doc.text(`계획 횟수: ${totalPlanned ?? 0}회`);
    doc.text(`성실도: ${overallPct90}%`);

    // Simple bar visualization
    const barX = 50;
    const barY = doc.y + 10;
    const barW = 300;
    const barH = 15;
    doc.rect(barX, barY, barW, barH).stroke("#999");
    const fillW = Math.max(
      0,
      Math.min(barW, Math.round((overallPct90 / 100) * barW))
    );
    doc.rect(barX, barY, fillW, barH).fillAndStroke("#2E7D32", "#999");
    doc.fillColor("#000");
    doc.moveDown(2);

    // AI 피드백 섹션
    doc.fontSize(16);
    if (koreanFont) {
      doc.font("Korean");
    } else {
      doc.font("Helvetica-Bold");
    }
    doc.text("AI 복약 인사이트", { underline: true });
    doc.moveDown(0.5);
    doc.fontSize(12);
    if (koreanFont) {
      doc.font("Korean");
    } else {
      doc.font("Helvetica");
    }
    if (insightMessage) {
      doc.text("• " + insightMessage);
    }
    if (tips.length > 0) {
      doc.moveDown(0.3);
      doc.fontSize(11).fillColor("#444");
      tips.forEach((tip) => {
        doc.text("  - " + tip, { indent: 10 });
      });
      doc.fillColor("#000");
    }
    doc.moveDown();

    // Medications (table)
    doc.fontSize(16);
    if (koreanFont) {
      doc.font("Korean");
    } else {
      doc.font("Helvetica-Bold");
    }
    doc.text("현재 복용 중인 약물", { underline: true });
    doc.moveDown(0.5);

    const table = {
      x: 50,
      y: doc.y,
      widths: [180, 60, 150, 120], // Name, Freq, Times, Period
      lineH: 18,
    };
    const drawRow = (cells: string[], isHeader = false) => {
      let x = table.x;
      cells.forEach((c, i) => {
        const w = table.widths[i] || 100;
        if (isHeader) {
          doc.fontSize(11);
          if (koreanFont) {
            doc.font("Korean");
          } else {
            doc.font("Helvetica-Bold");
          }
          doc.fillColor("#000").text(c, x, table.y, { width: w });
        } else {
          doc.fontSize(10);
          if (koreanFont) {
            doc.font("Korean");
          } else {
            doc.font("Helvetica");
          }
          doc.fillColor("#333").text(c, x, table.y, { width: w });
        }
        x += w + 8;
      });
      table.y += table.lineH;
      doc
        .moveTo(table.x, table.y - 2)
        .lineTo(x - 8, table.y - 2)
        .stroke("#EEE");
    };

    drawRow(["약물명", "횟수", "시간", "기간"], true);
    table.y += 4;

    const safeStr = (v: any) =>
      v === undefined || v === null ? "-" : String(v);
    const fmtPeriod = (m: any) => {
      const start = safeStr(m.start_date);
      const end = m.is_indefinite ? "무기한" : safeStr(m.end_date);
      return `${start} ~ ${end}`;
    };

    for (let i = 0; i < meds.rows.length; i++) {
      const m: any = meds.rows[i];
      const times = Array.isArray(m.dosage_times)
        ? m.dosage_times.join(", ")
        : safeStr(m.dosage_times);
      const row = [
        `${safeStr(m.drug_name)}${
          m.manufacturer ? `\n(${m.manufacturer})` : ""
        }`,
        `${safeStr(m.frequency)}회/일`,
        times,
        fmtPeriod(m),
      ];
      // new page if near bottom
      if (table.y > doc.page.height - 100) {
        doc.addPage();
        table.y = 80;
        drawRow(["약물명", "횟수", "시간", "기간"], true);
        table.y += 4;
      }
      drawRow(row);
    }
    doc.moveDown(1);

    // Clinician notes section & footer note
    doc.fontSize(16);
    if (koreanFont) {
      doc.font("Korean");
    } else {
      doc.font("Helvetica-Bold");
    }
    doc.text("의사 메모", { underline: true });
    const notesTop = doc.y + 6;
    const notesH = 100;
    doc.rect(50, notesTop, doc.page.width - 100, notesH).stroke("#CCC");
    doc.moveDown(8);
    doc.fontSize(10);
    if (koreanFont) {
      doc.font("Korean");
    } else {
      doc.font("Helvetica");
    }
    doc
      .fillColor("#666")
      .text(
        "본 리포트는 사용자 입력 데이터를 기반으로 생성되었습니다. 임상적 판단은 반드시 전문의와 상담하시기 바랍니다.",
        { align: "left" }
      )
      .fillColor("#000");

    doc.end();
  } catch (error) {
    console.error("Generate report error:", error);
    return res
      .status(500)
      .json({ error: "리포트 생성 중 오류가 발생했습니다" });
  }
};
