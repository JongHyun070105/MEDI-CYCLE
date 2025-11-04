-- 약물 알림 피드백 테이블 (Federated Learning 모델 학습용)
CREATE TABLE IF NOT EXISTS medication_feedbacks (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    medication_id INT NOT NULL REFERENCES medications(id) ON DELETE CASCADE,
    notification_id INT, -- 알림 ID (optional)
    taken BOOLEAN NOT NULL, -- 복용 완료 여부
    actual_time TIME, -- 실제 복용 시간 (HH:MM 형식)
    meal_time INT, -- 식사 시간 (분 단위, 예: 450 = 7:30)
    medication_time INT, -- 약물 복용 시간 (분 단위, 예: 480 = 8:00)
    feedback_score INT, -- 피드백 점수 (1-5, optional)
    satisfaction INT, -- 만족도 (1-5, optional)
    time_accuracy INT, -- 시간 정확도 (1-5, optional)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_medication_feedbacks_user_id ON medication_feedbacks(user_id);
CREATE INDEX IF NOT EXISTS idx_medication_feedbacks_medication_id ON medication_feedbacks(medication_id);
CREATE INDEX IF NOT EXISTS idx_medication_feedbacks_created_at ON medication_feedbacks(created_at);

