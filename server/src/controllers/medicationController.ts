import { Request, Response } from "express";
import { query } from "../database/db.js";
import { Medication } from "../types/index.js";
import {
  registerUser as registerMLUser,
  getPersonalizedSchedule,
  getUserStatus,
} from "../services/mlService.js";
import {
  fetchDrugValidity,
  fetchDrugOverviewImage,
} from "../services/publicDataApiService.js";

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
      item_image_url,
    } = req.body;

    if (!userId) {
      return res.status(401).json({ error: "인증이 필요합니다" });
    }

    if (!drug_name || !start_date || !dosage_times) {
      return res.status(400).json({ error: "필수 정보가 누락되었습니다" });
    }

    // Validation: types and consistency
    const times: unknown[] = Array.isArray(dosage_times) ? dosage_times : [];
    const relations: unknown[] = Array.isArray(meal_relations)
      ? meal_relations
      : [];
    const offsets: unknown[] = Array.isArray(meal_offsets) ? meal_offsets : [];

    if (typeof frequency !== "number" || frequency <= 0) {
      return res
        .status(400)
        .json({ error: "frequency는 양의 정수여야 합니다" });
    }
    if (times.length !== frequency) {
      return res
        .status(400)
        .json({ error: "dosage_times의 길이가 frequency와 일치해야 합니다" });
    }
    if (relations.length && relations.length !== frequency) {
      return res
        .status(400)
        .json({ error: "meal_relations의 길이가 frequency와 일치해야 합니다" });
    }
    if (offsets.length && offsets.length !== frequency) {
      return res
        .status(400)
        .json({ error: "meal_offsets의 길이가 frequency와 일치해야 합니다" });
    }
    if (drug_name.length > 255) {
      return res
        .status(400)
        .json({ error: "drug_name이 너무 깁니다(최대 255자)" });
    }

    // Validate date format (ISO YYYY-MM-DD allowed)
    const startOk = /^\d{4}-\d{2}-\d{2}$/.test(start_date);
    const endOk = !end_date || /^\d{4}-\d{2}-\d{2}$/.test(end_date);
    if (!startOk || !endOk) {
      return res
        .status(400)
        .json({ error: "날짜 형식이 잘못되었습니다(YYYY-MM-DD)" });
    }

    // 이미지 URL이 없으면 자동으로 조회
    let finalImageUrl = item_image_url || null;
    if (!finalImageUrl) {
      try {
        const imageUrl = await fetchDrugOverviewImage(
          drug_name,
          manufacturer || undefined
        );
        if (imageUrl) {
          finalImageUrl = imageUrl;
          console.log(
            `✅ 약 등록 시 이미지 자동 조회 성공: "${drug_name}" → ${imageUrl.substring(
              0,
              80
            )}...`
          );
        } else {
          console.log(
            `ℹ️ 약 등록 시 이미지 조회 실패 (이미지 없음): "${drug_name}"`
          );
        }
      } catch (imageError) {
        console.error(
          `⚠️ 약 등록 시 이미지 조회 중 오류 (약은 등록됨):`,
          imageError
        );
        // 이미지 조회 실패는 치명적이지 않으므로 계속 진행
      }
    }

    const result = await query(
      `INSERT INTO medications 
       (user_id, drug_name, manufacturer, ingredient, frequency, dosage_times, meal_relations, meal_offsets, start_date, end_date, is_indefinite, item_image_url) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) 
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
        finalImageUrl,
      ]
    );

    const medication = result.rows[0];

    // 공공데이터 API로 유효기간 조회 및 저장 (비동기, 실패해도 계속 진행)
    try {
      const validity = await fetchDrugValidity(
        drug_name,
        manufacturer || undefined
      );
      if (validity) {
        const parseDate = (s?: string) => {
          if (!s) return null;
          const normalized = s.replace(/\./g, "-").replace(/\s/g, "");
          const m = normalized.match(/(\d{4})[-/](\d{2})[-/](\d{2})/);
          if (!m) return null;
          return `${m[1]}-${m[2]}-${m[3]}`;
        };

        const expiryDate = parseDate(validity.validTermText);
        const renewalDate = parseDate(validity.renewalDeadline);

        await query(
          `UPDATE medications
           SET expiry_date = COALESCE($2::date, expiry_date),
               valid_term_text = $3,
               renewal_deadline = COALESCE($4::date, renewal_deadline),
               api_item_seq = $5,
               api_item_no = $6,
               api_entp_name = $7,
               api_last_checked = NOW()
           WHERE id = $1`,
          [
            medication.id,
            expiryDate,
            validity.validTermText || null,
            renewalDate,
            validity.itemSeq || null,
            validity.itemNo || null,
            validity.entpName || null,
          ]
        );
      }
    } catch (_) {
      // ignore
    }

    // ML 서버에 사용자 업데이트 (비동기, 실패해도 계속 진행)
    // 약 등록 시마다 사용자 정보를 업데이트하되, 이미 등록된 사용자인지 확인
    try {
      // 사용자 정보 가져오기
      const userResult = await query(
        `SELECT id, name, age, gender FROM users WHERE id = $1`,
        [userId]
      );

      if (userResult.rows.length > 0) {
        const user = userResult.rows[0];

        // 사용자의 모든 약물 목록 가져오기
        const allMedicationsResult = await query(
          `SELECT drug_name FROM medications WHERE user_id = $1`,
          [userId]
        );
        const medications = allMedicationsResult.rows.map(
          (r: any) => r.drug_name
        );

        // ML 서버에 사용자 등록/업데이트
        // 먼저 사용자 상태 확인 (이미 등록되었는지 체크)
        let isRegistered = false;
        try {
          await getUserStatus(userId.toString());
          isRegistered = true;
        } catch (statusError) {
          // 사용자가 등록되지 않았거나 오류 발생
          isRegistered = false;
        }

        // 사용자가 등록되지 않았거나, 약물 목록이 변경된 경우에만 등록/업데이트
        if (!isRegistered || medications.length > 0) {
          try {
            await registerMLUser(userId.toString(), {
              user_id: userId.toString(),
              name: user.name,
              age: user.age || 30,
              medications: medications,
              allergies: [], // TODO: 알레르기 정보 추가
            });
            if (isRegistered) {
              console.log(
                `✅ ML 서버 사용자 정보 업데이트 완료: 사용자 ${userId}, 약물 ${drug_name}`
              );
            } else {
              console.log(
                `✅ ML 서버 사용자 등록 완료: 사용자 ${userId}, 약물 ${drug_name}`
              );
            }
          } catch (mlError: any) {
            console.error(
              "⚠️ ML 서버 사용자 등록/업데이트 실패 (약은 등록됨):",
              mlError
            );
          }
        } else {
          console.log(
            `ℹ️  ML 서버 사용자 이미 등록되어 있고 약물 목록이 동일함: 사용자 ${userId}`
          );
        }
      }
    } catch (mlError) {
      console.error("⚠️ ML 서버 사용자 등록 중 오류 (약은 등록됨):", mlError);
      // ML 서버 오류는 치명적이지 않으므로 계속 진행
    }

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
