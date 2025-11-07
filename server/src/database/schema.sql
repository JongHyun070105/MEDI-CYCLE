-- 사용자 테이블
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    age INT,
    address VARCHAR(500),
    gender VARCHAR(50),
    auto_login BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 약 등록 테이블
CREATE TABLE IF NOT EXISTS medications (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    drug_name VARCHAR(255) NOT NULL,
    manufacturer VARCHAR(255),
    ingredient VARCHAR(500),
    frequency INT DEFAULT 3,
    dosage_times TEXT[] NOT NULL,
    meal_relations TEXT[] NOT NULL,
    meal_offsets INT[] NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    is_indefinite BOOLEAN DEFAULT FALSE,
    item_image_url TEXT,
    -- 유효기간 연동 필드 (공공데이터 API)
    expiry_date DATE,                               -- 실제 만료일 (파싱 가능 시)
    valid_term_text VARCHAR(100),                   -- 품목유효기간 원문(파싱 불가 시 보관)
    renewal_deadline DATE,                          -- 갱신신청기한
    api_item_seq VARCHAR(50),                       -- 품목기준코드
    api_item_no VARCHAR(50),                        -- 허가번호
    api_entp_name VARCHAR(255),                     -- 업체명(검증용)
    api_last_checked TIMESTAMP,                     -- API 마지막 조회 시각
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 복용 데이터 테이블
CREATE TABLE IF NOT EXISTS medication_intakes (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    medication_id INT NOT NULL REFERENCES medications(id) ON DELETE CASCADE,
    intake_time TIMESTAMP NOT NULL,
    is_taken BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 챗봇 대화 테이블
CREATE TABLE IF NOT EXISTS chat_messages (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 약상자 정보 테이블
CREATE TABLE IF NOT EXISTS pillboxes (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(255) UNIQUE NOT NULL,
    device_name VARCHAR(255),
    is_connected BOOLEAN DEFAULT FALSE,
    lock_status VARCHAR(50),
    battery_level INT,
    last_connected TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 약상자 상태 테이블 (최신 상태만 유지)
CREATE TABLE IF NOT EXISTS pillbox_status (
    pillbox_id INT PRIMARY KEY REFERENCES pillboxes(id) ON DELETE CASCADE,
    has_medication BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 약상자 로그 테이블 (활동 기록)
CREATE TABLE IF NOT EXISTS pillbox_logs (
    id SERIAL PRIMARY KEY,
    pillbox_id INT NOT NULL REFERENCES pillboxes(id) ON DELETE CASCADE,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    log_message TEXT NOT NULL,
    has_medication BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_medications_user_id ON medications(user_id);
CREATE INDEX IF NOT EXISTS idx_medication_intakes_user_id ON medication_intakes(user_id);
CREATE INDEX IF NOT EXISTS idx_medication_intakes_medication_id ON medication_intakes(medication_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_pillboxes_user_id ON pillboxes(user_id);
CREATE INDEX IF NOT EXISTS idx_pillbox_logs_pillbox_id ON pillbox_logs(pillbox_id);
CREATE INDEX IF NOT EXISTS idx_pillbox_logs_user_id ON pillbox_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_pillbox_logs_created_at ON pillbox_logs(created_at DESC);
