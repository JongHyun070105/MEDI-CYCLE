import express from "express";
import {
  updatePillboxStatus,
  getPillboxStatus,
  getPillboxLogs,
  registerPillbox,
} from "../controllers/pillboxController.js";
import { authenticateToken } from "../middleware/auth.js";

const router = express.Router();

// 라즈베리파이에서 상태 업데이트 (인증 없음)
router.post("/status/update", updatePillboxStatus);

// 앱에서 약상자 상태 조회 (인증 필요)
router.get("/status", authenticateToken, getPillboxStatus);

// 앱에서 약상자 로그 조회 (인증 필요)
router.get("/logs", authenticateToken, getPillboxLogs);

// 약상자 등록 (인증 필요)
router.post("/register", authenticateToken, registerPillbox);

export default router;

