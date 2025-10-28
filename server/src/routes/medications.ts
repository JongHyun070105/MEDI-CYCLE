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
import { authenticateToken } from "../middleware/auth.js";
import { getMonthlyAdherence } from "../controllers/statsController.js";
import { getHealthInsights } from "../controllers/insightsController.js";
import { generateReport } from "../controllers/reportController.js";

const router = express.Router();

// All routes require authentication
router.use(authenticateToken);

router.post("/", registerMedication);
router.get("/", getMedications);
router.get("/:id", getMedicationById);
router.put("/:id", updateMedication);
router.delete("/:id", deleteMedication);

// Medication intake routes
router.post("/intake/record", recordMedicationIntake);
router.get("/intake/list", getMedicationIntakes);
router.put("/intake/:id", updateMedicationIntake);
router.delete("/intake/:id", deleteMedicationIntake);

// Chatbot routes
router.post("/chat/send", sendChatMessage);
router.get("/chat/history", getChatHistory);
router.delete("/chat/history", deleteChatHistory);

// Stats routes
router.get("/stats/adherence/monthly", getMonthlyAdherence);
router.get("/stats/insights", getHealthInsights);
router.get("/report/pdf", generateReport);

export default router;
