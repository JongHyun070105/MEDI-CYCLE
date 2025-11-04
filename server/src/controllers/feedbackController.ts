import { Request, Response } from "express";
import { query } from "../database/db.js";
import { sendFeedback, getPersonalizedSchedule } from "../services/mlService.js";

/**
 * 약물 알림 피드백 수신
 * POST /api/medications/:id/feedback
 */
export const submitFeedback = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    const medicationId = parseInt(req.params.id);
    const {
      taken,
      actual_time,
      meal_time,
      medication_time,
      feedback_score,
      satisfaction,
      time_accuracy,
      notification_id,
    } = req.body;

    if (!userId) {
      return res.status(401).json({ error: "인증이 필요합니다" });
    }

    if (medicationId <= 0 || isNaN(medicationId)) {
      return res.status(400).json({ error: "유효하지 않은 약물 ID입니다" });
    }

    if (typeof taken !== "boolean") {
      return res.status(400).json({ error: "taken은 boolean이어야 합니다" });
    }

    // 데이터베이스에 피드백 저장
    const result = await query(
      `INSERT INTO medication_feedbacks 
       (user_id, medication_id, notification_id, taken, actual_time, meal_time, medication_time, feedback_score, satisfaction, time_accuracy)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING *`,
      [
        userId,
        medicationId,
        notification_id || null,
        taken,
        actual_time || null,
        meal_time || null,
        medication_time || null,
        feedback_score || null,
        satisfaction || null,
        time_accuracy || null,
      ]
    );

    const feedback = result.rows[0];

    // 약물 정보 가져오기
    const medicationResult = await query(
      `SELECT drug_name FROM medications WHERE id = $1 AND user_id = $2`,
      [medicationId, userId]
    );

    if (medicationResult.rows.length === 0) {
      return res.status(404).json({ error: "약물을 찾을 수 없습니다" });
    }

    const medicationName = medicationResult.rows[0].drug_name;

    // ML 서버에 피드백 전송
    try {
      await sendFeedback(userId.toString(), {
        taken,
        actual_time,
        meal_time,
        medication_time,
        feedback_score,
        satisfaction,
        time_accuracy,
        timestamp: new Date().toISOString(),
      });

      console.log(`✅ ML 서버 피드백 전송 완료: 사용자 ${userId}, 약물 ${medicationName}`);
    } catch (mlError) {
      console.error("⚠️ ML 서버 피드백 전송 실패 (데이터베이스에는 저장됨):", mlError);
      // ML 서버 오류는 치명적이지 않으므로 계속 진행
    }

    return res.status(201).json({
      message: "피드백이 저장되었습니다",
      feedback,
    });
  } catch (error) {
    console.error("Submit feedback error:", error);
    return res.status(500).json({ error: "피드백 저장 중 오류가 발생했습니다" });
  }
};

/**
 * 개인화된 알림 스케줄 조회
 * GET /api/users/:id/personalized-schedule?medication_type=...
 */
export const getPersonalizedMedicationSchedule = async (
  req: Request,
  res: Response
) => {
  try {
    const userId = req.userId;
    const { medication_type } = req.query;

    if (!userId) {
      return res.status(401).json({ error: "인증이 필요합니다" });
    }

    if (!medication_type || typeof medication_type !== "string") {
      return res.status(400).json({ error: "medication_type이 필요합니다" });
    }

    // ML 서버에서 개인화된 스케줄 조회
    try {
      const prediction = await getPersonalizedSchedule(
        userId.toString(),
        medication_type
      );

      return res.status(200).json({
        message: "개인화된 스케줄 조회 완료",
        schedule: prediction.prediction,
      });
    } catch (mlError) {
      console.error("ML 서버 스케줄 조회 실패:", mlError);
      
      // ML 서버 오류 시 기본 스케줄 반환
      return res.status(200).json({
        message: "기본 스케줄 조회 (ML 서버 오류)",
        schedule: {
          predicted_times: {
            breakfast: "07:30",
            lunch: "12:00",
            dinner: "18:30",
          },
          confidence: 0.6,
          method: "base_pattern",
          learning_stage: 1,
        },
      });
    }
  } catch (error) {
    console.error("Get personalized schedule error:", error);
    return res.status(500).json({ error: "스케줄 조회 중 오류가 발생했습니다" });
  }
};

