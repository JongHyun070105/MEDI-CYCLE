import express from "express";
import {
  registerMedication,
  getMedications,
  getMedicationById,
  updateMedication,
  deleteMedication,
} from "../controllers/medicationController.js";
import {
  recordMedicationIntake,
  getMedicationIntakes,
  updateMedicationIntake,
  deleteMedicationIntake,
} from "../controllers/medicationIntakeController.js";
import {
  sendChatMessage,
  getChatHistory,
  deleteChatHistory,
} from "../controllers/chatbotController.js";
import {
  submitFeedback,
  getPersonalizedMedicationSchedule,
} from "../controllers/feedbackController.js";
import { authenticateToken } from "../middleware/auth.js";
import { getMonthlyAdherence } from "../controllers/statsController.js";
import { getHealthInsights } from "../controllers/insightsController.js";
import { generateReport } from "../controllers/reportController.js";
import { listExpiryStatus, triggerUserValidityUpdate } from "../controllers/expiryController.js";
import { updateMissingMedicationImages } from "../services/expiryUpdateService.js";

const router = express.Router();

// All routes require authentication
router.use(authenticateToken);

router.post("/", registerMedication);
router.get("/", getMedications);

// 특정 라우트들을 :id 라우트보다 먼저 정의
router.get("/personalized-schedule", getPersonalizedMedicationSchedule);
router.post("/intake/record", recordMedicationIntake);
router.get("/intake/list", getMedicationIntakes);
router.post("/chat/send", sendChatMessage);
router.get("/chat/history", getChatHistory);
router.delete("/chat/history", deleteChatHistory);
router.get("/stats/adherence/monthly", getMonthlyAdherence);
router.get("/stats/insights", getHealthInsights);
router.get("/report/pdf", generateReport);
router.get("/expiry/list", listExpiryStatus);
router.post("/expiry/check", triggerUserValidityUpdate);
router.post("/images/check", async (_req, res) => {
  try {
    await updateMissingMedicationImages();
    res.json({ message: "이미지 보정 완료" });
  } catch (e) {
    res.status(500).json({ error: "이미지 보정 중 오류" });
  }
});

// :id 라우트는 마지막에 정의
router.get("/:id", getMedicationById);
router.put("/:id", updateMedication);
router.delete("/:id", deleteMedication);
router.put("/intake/:id", updateMedicationIntake);
router.delete("/intake/:id", deleteMedicationIntake);
router.post("/:id/feedback", submitFeedback);

export default router;
