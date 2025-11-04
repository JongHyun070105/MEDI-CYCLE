import { Request, Response } from "express";
import { query } from "../database/db.js";
import { authenticateToken } from "../middleware/auth.js";

// 라즈베리파이에서 상태 업데이트 (인증 없이, device_id만)
export const updatePillboxStatus = async (req: Request, res: Response) => {
  try {
    const { device_id, has_medication, log_message } = req.body;

    if (!device_id) {
      return res.status(400).json({ error: "device_id가 필요합니다" });
    }

    // device_id로 pillbox 찾기
    const pillboxResult = await query(
      "SELECT id, user_id FROM pillboxes WHERE device_id = $1",
      [device_id]
    );

    if (pillboxResult.rows.length === 0) {
      return res.status(404).json({ error: "등록된 약상자를 찾을 수 없습니다" });
    }

    const pillboxId = pillboxResult.rows[0].id;
    const userId = pillboxResult.rows[0].user_id;

    // pillbox 상태 업데이트
    await query(
      `UPDATE pillboxes 
       SET is_connected = true, 
           last_connected = CURRENT_TIMESTAMP,
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $1`,
      [pillboxId]
    );

    // 로그 저장 (로그 메시지가 있을 때만)
    if (log_message) {
      await query(
        `INSERT INTO pillbox_logs (pillbox_id, user_id, log_message, has_medication, created_at)
         VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)`,
        [pillboxId, userId, log_message, has_medication ?? false]
      );
    }

    // 최신 상태 업데이트 (약 유무는 별도로 저장)
    await query(
      `INSERT INTO pillbox_status (pillbox_id, has_medication, created_at)
       VALUES ($1, $2, CURRENT_TIMESTAMP)
       ON CONFLICT (pillbox_id) 
       DO UPDATE SET has_medication = $2, created_at = CURRENT_TIMESTAMP`,
      [pillboxId, has_medication ?? false]
    );

    console.log(`✅ 약상자 상태 업데이트: device_id=${device_id}, has_medication=${has_medication}`);

    res.json({
      success: true,
      message: "상태가 업데이트되었습니다",
    });
  } catch (error) {
    console.error("❌ 약상자 상태 업데이트 오류:", error);
    res.status(500).json({ error: "상태 업데이트 중 오류가 발생했습니다" });
  }
};

// 앱에서 약상자 상태 조회 (인증 필요)
export const getPillboxStatus = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).userId;

    // 사용자의 pillbox 찾기
    const pillboxResult = await query(
      "SELECT * FROM pillboxes WHERE user_id = $1 ORDER BY created_at DESC LIMIT 1",
      [userId]
    );

    if (pillboxResult.rows.length === 0) {
      return res.json({
        is_connected: false,
        has_medication: false,
        last_connected: null,
      });
    }

    const pillbox = pillboxResult.rows[0];
    const pillboxId = pillbox.id;

    // 최신 상태 조회
    const statusResult = await query(
      "SELECT has_medication FROM pillbox_status WHERE pillbox_id = $1",
      [pillboxId]
    );

    const hasMedication = statusResult.rows.length > 0 
      ? statusResult.rows[0].has_medication 
      : false;

    // 연결 상태 확인 (30초 이내에 업데이트가 있었으면 연결됨)
    const lastConnected = pillbox.last_connected;
    const now = new Date();
    const timeSinceLastUpdate = lastConnected 
      ? (now.getTime() - new Date(lastConnected).getTime()) / 1000 
      : Infinity;
    
    const isConnected = timeSinceLastUpdate < 60; // 60초 이내면 연결됨

    res.json({
      is_connected: isConnected,
      has_medication: hasMedication,
      last_connected: pillbox.last_connected,
      device_id: pillbox.device_id,
      device_name: pillbox.device_name,
    });
  } catch (error) {
    console.error("❌ 약상자 상태 조회 오류:", error);
    res.status(500).json({ error: "상태 조회 중 오류가 발생했습니다" });
  }
};

// 앱에서 약상자 로그 조회 (인증 필요)
export const getPillboxLogs = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).userId;
    const limit = parseInt(req.query.limit as string) || 20;

    // 사용자의 pillbox 찾기
    const pillboxResult = await query(
      "SELECT id FROM pillboxes WHERE user_id = $1 ORDER BY created_at DESC LIMIT 1",
      [userId]
    );

    if (pillboxResult.rows.length === 0) {
      return res.json([]);
    }

    const pillboxId = pillboxResult.rows[0].id;

    // 로그 조회
    const logsResult = await query(
      `SELECT id, log_message, has_medication, created_at
       FROM pillbox_logs
       WHERE pillbox_id = $1
       ORDER BY created_at DESC
       LIMIT $2`,
      [pillboxId, limit]
    );

    res.json(logsResult.rows);
  } catch (error) {
    console.error("❌ 약상자 로그 조회 오류:", error);
    res.status(500).json({ error: "로그 조회 중 오류가 발생했습니다" });
  }
};

// 약상자 등록 (처음 연결 시)
export const registerPillbox = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).userId;
    const { device_id, device_name } = req.body;

    if (!device_id) {
      return res.status(400).json({ error: "device_id가 필요합니다" });
    }

    // 이미 등록된 device_id인지 확인
    const existingResult = await query(
      "SELECT id, user_id FROM pillboxes WHERE device_id = $1",
      [device_id]
    );

    if (existingResult.rows.length > 0) {
      const existingPillbox = existingResult.rows[0];
      // 다른 사용자가 등록한 경우
      if (existingPillbox.user_id !== userId) {
        return res.status(403).json({ error: "이미 다른 사용자가 등록한 약상자입니다" });
      }
      // 같은 사용자가 다시 등록하는 경우 업데이트
      await query(
        `UPDATE pillboxes 
         SET device_name = $1, is_connected = true, last_connected = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
         WHERE id = $2`,
        [device_name || "스마트 약상자", existingPillbox.id]
      );
      return res.json({ success: true, message: "약상자가 업데이트되었습니다" });
    }

    // 새로 등록
    const result = await query(
      `INSERT INTO pillboxes (user_id, device_id, device_name, is_connected, last_connected)
       VALUES ($1, $2, $3, true, CURRENT_TIMESTAMP)
       RETURNING id`,
      [userId, device_id, device_name || "스마트 약상자"]
    );

    const pillboxId = result.rows[0].id;

    // 초기 상태 생성
    await query(
      `INSERT INTO pillbox_status (pillbox_id, has_medication)
       VALUES ($1, false)`,
      [pillboxId]
    );

    console.log(`✅ 약상자 등록: user_id=${userId}, device_id=${device_id}`);

    res.json({
      success: true,
      message: "약상자가 등록되었습니다",
      pillbox_id: pillboxId,
    });
  } catch (error) {
    console.error("❌ 약상자 등록 오류:", error);
    res.status(500).json({ error: "약상자 등록 중 오류가 발생했습니다" });
  }
};

