import { Request, Response } from "express";
import { query } from "../database/db.js";
import { Medication } from "../types/index.js";

export const registerMedication = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    const {
      drug_name,
      manufacturer,
      ingredient,
      frequency,
      dosage_times,
      meal_relations,
      meal_offsets,
      start_date,
      end_date,
      is_indefinite,
    } = req.body;

    if (!userId) {
      return res.status(401).json({ error: "인증이 필요합니다" });
    }

    if (!drug_name || !start_date || !dosage_times) {
      return res.status(400).json({ error: "필수 정보가 누락되었습니다" });
    }

    const result = await query(
      `INSERT INTO medications 
       (user_id, drug_name, manufacturer, ingredient, frequency, dosage_times, meal_relations, meal_offsets, start_date, end_date, is_indefinite) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) 
       RETURNING *`,
      [
        userId,
        drug_name,
        manufacturer || null,
        ingredient || null,
        frequency || 3,
        dosage_times,
        meal_relations,
        meal_offsets,
        start_date,
        is_indefinite ? null : end_date,
        is_indefinite || false,
      ]
    );

    const medication = result.rows[0];

    return res.status(201).json({
      message: "약이 등록되었습니다",
      medication,
    });
  } catch (error) {
    console.error("Register medication error:", error);
    return res.status(500).json({ error: "약 등록 중 오류가 발생했습니다" });
  }
};

export const getMedications = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;

    if (!userId) {
      return res.status(401).json({ error: "인증이 필요합니다" });
    }

    const result = await query(
      "SELECT * FROM medications WHERE user_id = $1 ORDER BY created_at DESC",
      [userId]
    );

    return res.json({
      medications: result.rows,
    });
  } catch (error) {
    console.error("Get medications error:", error);
    return res.status(500).json({ error: "약 조회 중 오류가 발생했습니다" });
  }
};

export const getMedicationById = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    const { id } = req.params;

    if (!userId) {
      return res.status(401).json({ error: "인증이 필요합니다" });
    }

    const result = await query(
      "SELECT * FROM medications WHERE id = $1 AND user_id = $2",
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "약을 찾을 수 없습니다" });
    }

    return res.json({
      medication: result.rows[0],
    });
  } catch (error) {
    console.error("Get medication error:", error);
    return res.status(500).json({ error: "약 조회 중 오류가 발생했습니다" });
  }
};

export const updateMedication = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    const { id } = req.params;
    const {
      drug_name,
      manufacturer,
      ingredient,
      frequency,
      dosage_times,
      meal_relations,
      meal_offsets,
      start_date,
      end_date,
      is_indefinite,
    } = req.body;

    if (!userId) {
      return res.status(401).json({ error: "인증이 필요합니다" });
    }

    const result = await query(
      `UPDATE medications 
       SET drug_name = COALESCE($1, drug_name), 
           manufacturer = COALESCE($2, manufacturer),
           ingredient = COALESCE($3, ingredient),
           frequency = COALESCE($4, frequency),
           dosage_times = COALESCE($5, dosage_times),
           meal_relations = COALESCE($6, meal_relations),
           meal_offsets = COALESCE($7, meal_offsets),
           start_date = COALESCE($8, start_date),
           end_date = COALESCE($9, end_date),
           is_indefinite = COALESCE($10, is_indefinite),
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $11 AND user_id = $12
       RETURNING *`,
      [
        drug_name,
        manufacturer,
        ingredient,
        frequency,
        dosage_times,
        meal_relations,
        meal_offsets,
        start_date,
        end_date,
        is_indefinite,
        id,
        userId,
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "약을 찾을 수 없습니다" });
    }

    return res.json({
      message: "약이 업데이트되었습니다",
      medication: result.rows[0],
    });
  } catch (error) {
    console.error("Update medication error:", error);
    return res
      .status(500)
      .json({ error: "약 업데이트 중 오류가 발생했습니다" });
  }
};

export const deleteMedication = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    const { id } = req.params;

    if (!userId) {
      return res.status(401).json({ error: "인증이 필요합니다" });
    }

    const result = await query(
      "DELETE FROM medications WHERE id = $1 AND user_id = $2 RETURNING id",
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "약을 찾을 수 없습니다" });
    }

    return res.json({
      message: "약이 삭제되었습니다",
    });
  } catch (error) {
    console.error("Delete medication error:", error);
    return res.status(500).json({ error: "약 삭제 중 오류가 발생했습니다" });
  }
};
