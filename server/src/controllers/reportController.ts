import { Request, Response } from "express";
import PDFDocument from "pdfkit";
import { query } from "../database/db.js";

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

    // 현재 복용 중인 약 목록
    const meds = await query(
      `SELECT id, drug_name, manufacturer, ingredient, frequency, dosage_times, start_date, end_date, is_indefinite
       FROM medications WHERE user_id = $1 ORDER BY created_at DESC LIMIT 50`,
      [userId]
    );

    // 최근 90일 통계
    const stats = await query(
      `SELECT COUNT(*) FILTER (WHERE mi.is_taken = TRUE) AS completed,
              COUNT(*) AS total
       FROM medication_intakes mi
       JOIN medications m ON m.id = mi.medication_id AND m.user_id = $1
       WHERE mi.intake_time >= CURRENT_DATE - interval '90 day'`,
      [userId]
    );
    const s = stats.rows[0] || { completed: 0, total: 0 };
    const pct =
      s.total > 0
        ? Math.round((Number(s.completed) / Number(s.total)) * 100)
        : 0;

    // PDF 스트림 응답
    res.setHeader("Content-Type", "application/pdf");
    res.setHeader(
      "Content-Disposition",
      "inline; filename=medicycle_report.pdf"
    );

    const doc = new PDFDocument({ size: "A4", margin: 50 });
    doc.pipe(res);

    const generatedAt = new Date();
    const formatDate = (d: Date) =>
      `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(
        d.getDate()
      ).padStart(2, "0")} ${String(d.getHours()).padStart(2, "0")}:${String(
        d.getMinutes()
      ).padStart(2, "0")}`;

    // Header
    doc.fontSize(20).text("MediCycle - Doctor Report", { align: "center" });
    doc.moveDown(0.2);
    doc
      .fontSize(10)
      .fillColor("#666")
      .text(
        `Generated at: ${formatDate(generatedAt)}  |  User ID: ${u.id ?? "-"}`,
        { align: "center" }
      )
      .fillColor("#000");
    doc.moveDown();

    // Footer with page numbers (track manually; PDFPage has no 'number' prop)
    let currentPage = 1;
    const drawFooter = (pageNo: number) => {
      const text = `Page ${pageNo}`;
      doc
        .fontSize(9)
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
    doc.fontSize(14).text("Patient Information", { underline: true });
    doc.moveDown(0.5);
    doc.fontSize(11);
    doc.text(`Name: ${u.name || "-"}`);
    doc.text(`Email: ${u.email || "-"}`);
    doc.text(`Age: ${u.age ?? "-"}`);
    doc.text(`Gender: ${u.gender || "-"}`);
    doc.text(`Address: ${u.address || "-"}`);
    doc.moveDown();

    // Adherence
    doc.fontSize(14).text("Adherence (last 90 days)", { underline: true });
    doc.moveDown(0.5);
    doc.fontSize(11).text(`Completed: ${s.completed ?? 0}`);
    doc.text(`Total: ${s.total ?? 0}`);
    doc.text(`Adherence: ${pct}%`);

    // Simple bar visualization
    const barX = 50;
    const barY = doc.y + 10;
    const barW = 300;
    const barH = 12;
    doc.rect(barX, barY, barW, barH).stroke("#999");
    const fillW = Math.max(0, Math.min(barW, Math.round((pct / 100) * barW)));
    doc.rect(barX, barY, fillW, barH).fillAndStroke("#2E7D32", "#999");
    doc.fillColor("#000");
    doc.moveDown(2);

    // Medications (table)
    doc.fontSize(14).text("Current Medications", { underline: true });
    doc.moveDown(0.5);

    const table = {
      x: 50,
      y: doc.y,
      widths: [160, 60, 150, 140], // Name, Freq, Times, Period
      lineH: 16,
    };
    const drawRow = (cells: string[], isHeader = false) => {
      let x = table.x;
      cells.forEach((c, i) => {
        const w = table.widths[i] || 100;
        if (isHeader) {
          doc.fontSize(11).fillColor("#000").text(c, x, table.y, { width: w });
        } else {
          doc.fontSize(10).fillColor("#333").text(c, x, table.y, { width: w });
        }
        x += w + 8;
      });
      table.y += table.lineH;
      doc
        .moveTo(table.x, table.y - 2)
        .lineTo(x - 8, table.y - 2)
        .stroke("#EEE");
    };

    drawRow(["Name", "Freq", "Times", "Period"], true);
    table.y += 4;

    const safeStr = (v: any) =>
      v === undefined || v === null ? "-" : String(v);
    const fmtPeriod = (m: any) => {
      const start = safeStr(m.start_date);
      const end = m.is_indefinite ? "indefinite" : safeStr(m.end_date);
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
        safeStr(m.frequency),
        times,
        fmtPeriod(m),
      ];
      // new page if near bottom
      if (table.y > doc.page.height - 100) {
        doc.addPage();
        table.y = 80;
        drawRow(["Name", "Freq", "Times", "Period"], true);
        table.y += 4;
      }
      drawRow(row);
    }
    doc.moveDown(1);

    // Clinician notes section & footer note
    doc.fontSize(12).text("Clinician Notes", { underline: true });
    const notesTop = doc.y + 6;
    const notesH = 80;
    doc.rect(50, notesTop, doc.page.width - 100, notesH).stroke("#CCC");
    doc.moveDown(6);
    doc
      .fontSize(10)
      .fillColor("#666")
      .text(
        "This report is generated based on user logs. For clinical decisions, consult a qualified professional.",
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
