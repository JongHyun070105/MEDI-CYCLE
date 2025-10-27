import { Request, Response } from "express";
import { query } from "../database/db.js";

export const recordMedicationIntake = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    const { medication_id, intake_time, is_taken } = req.body;

    if (!userId) {
      return res.status(401).json({ error: "인증이 필요합니다" });
    }

    if (!medication_id || !intake_time) {
      return res.status(400).json({ error: "필수 정보가 누락되었습니다" });
    }

    // 사용자가 소유한 약인지 확인
    const medicationCheck = await query(
      "SELECT id FROM medications WHERE id = $1 AND user_id = $2",
      [medication_id, userId]
    );

    if (medicationCheck.rows.length === 0) {
      return res.status(404).json({ error: "약을 찾을 수 없습니다" });
    }

    // 동일 (user, medication, intake_time) 레코드가 있으면 업데이트, 없으면 생성
    const existing = await query(
      `SELECT id FROM medication_intakes 
       WHERE user_id = $1 AND medication_id = $2 AND intake_time = $3`,
      [userId, medication_id, intake_time]
    );

    if (existing.rows.length > 0) {
      const updated = await query(
        `UPDATE medication_intakes 
         SET is_taken = $1, updated_at = CURRENT_TIMESTAMP
         WHERE id = $2
         RETURNING *`,
        [is_taken ?? true, existing.rows[0].id]
      );
      return res.status(200).json({
        message: "복용 기록이 업데이트되었습니다",
        intake: updated.rows[0],
      });
    }

    const result = await query(
      `INSERT INTO medication_intakes 
       (user_id, medication_id, intake_time, is_taken) 
       VALUES ($1, $2, $3, $4) 
       RETURNING *`,
      [userId, medication_id, intake_time, is_taken || true]
    );

    return res.status(201).json({
      message: "복용 기록이 저장되었습니다",
      intake: result.rows[0],
    });
  } catch (error) {
    console.error("Record medication intake error:", error);
    return res
      .status(500)
      .json({ error: "복용 기록 저장 중 오류가 발생했습니다" });
  }
};

export const getMedicationIntakes = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    const { medication_id, startDate, endDate } = req.query;

    if (!userId) {
      return res.status(401).json({ error: "인증이 필요합니다" });
    }

    let queryStr = `SELECT mi.* FROM medication_intakes mi
       JOIN medications m ON mi.medication_id = m.id
       WHERE m.user_id = $1`;
    const params: unknown[] = [userId];

    if (medication_id) {
      queryStr += ` AND mi.medication_id = $${params.length + 1}`;
      params.push(medication_id);
    }

    if (startDate) {
      queryStr += ` AND mi.intake_time >= $${params.length + 1}`;
      params.push(startDate);
    }

    if (endDate) {
      queryStr += ` AND mi.intake_time <= $${params.length + 1}`;
      params.push(endDate);
    }

    queryStr += " ORDER BY mi.intake_time DESC";

    const result = await query(queryStr, params);

    return res.json({
      intakes: result.rows,
    });
  } catch (error) {
    console.error("Get medication intakes error:", error);
    return res
      .status(500)
      .json({ error: "복용 기록 조회 중 오류가 발생했습니다" });
  }
};

export const updateMedicationIntake = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    const { id } = req.params;
    const { is_taken } = req.body;

    if (!userId) {
      return res.status(401).json({ error: "인증이 필요합니다" });
    }

    const result = await query(
      `UPDATE medication_intakes 
       SET is_taken = $1, updated_at = CURRENT_TIMESTAMP
       WHERE id = $2 AND user_id = $3
       RETURNING *`,
      [is_taken, id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "복용 기록을 찾을 수 없습니다" });
    }

    return res.json({
      message: "복용 기록이 업데이트되었습니다",
      intake: result.rows[0],
    });
  } catch (error) {
    console.error("Update medication intake error:", error);
    return res
      .status(500)
      .json({ error: "복용 기록 업데이트 중 오류가 발생했습니다" });
  }
};

export const deleteMedicationIntake = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    const { id } = req.params;

    if (!userId) {
      return res.status(401).json({ error: "인증이 필요합니다" });
    }

    const result = await query(
      "DELETE FROM medication_intakes WHERE id = $1 AND user_id = $2 RETURNING id",
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "복용 기록을 찾을 수 없습니다" });
    }

    return res.json({
      message: "복용 기록이 삭제되었습니다",
    });
  } catch (error) {
    console.error("Delete medication intake error:", error);
    return res
      .status(500)
      .json({ error: "복용 기록 삭제 중 오류가 발생했습니다" });
  }
};
