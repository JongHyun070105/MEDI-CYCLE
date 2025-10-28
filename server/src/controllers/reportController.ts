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

    // Header
    doc.fontSize(20).text("MediCycle - Doctor Report", { align: "center" });
    doc.moveDown();

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
    doc.moveDown();

    // Medications
    doc.fontSize(14).text("Current Medications", { underline: true });
    doc.moveDown(0.5);
    meds.rows.forEach((m: any, idx: number) => {
      doc.fontSize(11).text(`${idx + 1}. ${m.drug_name}`);
      if (m.manufacturer) doc.text(`   Manufacturer: ${m.manufacturer}`);
      if (m.ingredient) doc.text(`   Ingredient: ${m.ingredient}`);
      doc.text(`   Frequency(times/day): ${m.frequency}`);
      doc.text(`   Times: ${(m.dosage_times || []).join(", ")}`);
      doc.text(
        `   Period: ${m.start_date || "-"} ~ ${
          m.is_indefinite ? "indefinite" : m.end_date || "-"
        }`
      );
      doc.moveDown(0.5);
    });

    // Footer note
    doc.moveDown();
    doc
      .fontSize(10)
      .fillColor("#666")
      .text(
        "This report is generated based on user logs. For clinical decisions, consult a qualified professional.",
        { align: "left" }
      );

    doc.end();
  } catch (error) {
    console.error("Generate report error:", error);
    return res
      .status(500)
      .json({ error: "리포트 생성 중 오류가 발생했습니다" });
  }
};
