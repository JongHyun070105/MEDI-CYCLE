import { Request, Response } from "express";
import { query } from "../database/db.js";
import { updateValidityForUser } from "../services/expiryUpdateService.js";

export const triggerUserValidityUpdate = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    if (!userId) return res.status(401).json({ error: "인증이 필요합니다" });
    await updateValidityForUser(userId);
    return res.json({ ok: true });
  } catch (error) {
    console.error("triggerUserValidityUpdate error:", error);
    return res.status(500).json({ error: "유효기간 업데이트 중 오류" });
  }
};

export const listExpiryStatus = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    if (!userId) return res.status(401).json({ error: "인증이 필요합니다" });
    const windowDays = Math.max(1, Math.min(90, Number(req.query.window) || 30));

    const result = await query(
      `SELECT id, drug_name, manufacturer, expiry_date, valid_term_text,
              (CASE WHEN expiry_date IS NULL THEN NULL ELSE (expiry_date - CURRENT_DATE) END) AS days_left
       FROM medications
       WHERE user_id = $1
         AND expiry_date IS NOT NULL
         AND (expiry_date <= CURRENT_DATE + ($2 || ' days')::interval)`,
      [userId, windowDays]
    );

    const today = new Date();
    const imminent: any[] = [];
    const expired: any[] = [];
    for (const row of result.rows) {
      const dleft = typeof row.days_left === 'number' ? row.days_left : parseInt(String(row.days_left));
      if (row.expiry_date && new Date(row.expiry_date) < today) expired.push(row);
      else imminent.push(row);
    }

    return res.json({ imminent, expired });
  } catch (error) {
    console.error("listExpiryStatus error:", error);
    return res.status(500).json({ error: "유효기간 조회 중 오류" });
  }
};


