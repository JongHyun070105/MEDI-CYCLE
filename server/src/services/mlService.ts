/**
 * Python ML 서버와 통신하는 서비스
 */

const ML_SERVER_URL = process.env.ML_SERVER_URL || "http://localhost:8000";

interface UserData {
  user_id: string;
  name: string;
  age: number;
  medications: string[];
  allergies: string[];
}

interface FeedbackData {
  taken: boolean;
  actual_time?: string; // HH:MM 형식
  meal_time?: number; // 분 단위
  medication_time?: number; // 분 단위
  feedback_score?: number;
  satisfaction?: number;
  time_accuracy?: number;
  timestamp?: string;
}

interface ScheduleRequest {
  medication_type: string;
}

interface PredictionResponse {
  status: string;
  user_id: string;
  medication_type: string;
  prediction: {
    predicted_times: Record<string, string>;
    confidence: number;
    method: string;
    learning_stage: number;
  };
}

/**
 * 사용자 등록
 */
export async function registerUser(userId: string, userData: UserData): Promise<any> {
  try {
    const response = await fetch(`${ML_SERVER_URL}/api/users/${userId}/register`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(userData),
    });

    if (!response.ok) {
      const errorData = await response.json() as { detail?: string };
      throw new Error(errorData.detail || "사용자 등록 실패");
    }

    return await response.json();
  } catch (error) {
    console.error("ML 서버 사용자 등록 오류:", error);
    if (error instanceof Error) {
      throw error;
    }
    throw new Error("사용자 등록 중 알 수 없는 오류가 발생했습니다");
  }
}

/**
 * 피드백 전송 및 모델 학습
 */
export async function sendFeedback(
  userId: string,
  feedback: FeedbackData
): Promise<any> {
  try {
    const response = await fetch(`${ML_SERVER_URL}/api/users/${userId}/feedback`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(feedback),
    });

    if (!response.ok) {
      const errorData = await response.json() as { detail?: string };
      throw new Error(errorData.detail || "피드백 전송 실패");
    }

    return await response.json();
  } catch (error) {
    console.error("ML 서버 피드백 전송 오류:", error);
    if (error instanceof Error) {
      throw error;
    }
    throw new Error("피드백 전송 중 알 수 없는 오류가 발생했습니다");
  }
}

/**
 * 개인화된 알림 스케줄 조회
 */
export async function getPersonalizedSchedule(
  userId: string,
  medicationType: string
): Promise<PredictionResponse> {
  try {
    const response = await fetch(`${ML_SERVER_URL}/api/users/${userId}/schedule`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ medication_type: medicationType }),
    });

    if (!response.ok) {
      const errorData = await response.json() as { detail?: string };
      throw new Error(errorData.detail || "스케줄 조회 실패");
    }

    const result = await response.json() as PredictionResponse;
    return result;
  } catch (error) {
    console.error("ML 서버 스케줄 조회 오류:", error);
    if (error instanceof Error) {
      throw error;
    }
    throw new Error("스케줄 조회 중 알 수 없는 오류가 발생했습니다");
  }
}

/**
 * 사용자 상태 조회
 */
export async function getUserStatus(userId: string): Promise<any> {
  try {
    const response = await fetch(`${ML_SERVER_URL}/api/users/${userId}/status`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    });

    if (!response.ok) {
      const errorData = await response.json() as { detail?: string };
      throw new Error(errorData.detail || "상태 조회 실패");
    }

    return await response.json();
  } catch (error) {
    console.error("ML 서버 상태 조회 오류:", error);
    if (error instanceof Error) {
      throw error;
    }
    throw new Error("상태 조회 중 알 수 없는 오류가 발생했습니다");
  }
}

/**
 * ML 서버 헬스 체크
 */
export async function checkMLServerHealth(): Promise<boolean> {
  try {
    const response = await fetch(`${ML_SERVER_URL}/health`, {
      method: "GET",
    });

    return response.ok;
  } catch (error) {
    console.error("ML 서버 헬스 체크 실패:", error);
    return false;
  }
}

