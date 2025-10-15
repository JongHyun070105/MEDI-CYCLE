-- Database
CREATE DATABASE IF NOT EXISTS medicycle CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE medicycle;

-- Users
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(100) NULL,
  age INT NULL,
  address VARCHAR(255) NULL,
  gender VARCHAR(20) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_users_email (email)
) ENGINE=InnoDB;

-- Medications
CREATE TABLE IF NOT EXISTS medications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  daily_count INT NOT NULL,

  time1 TIME NULL,
  time1_meal VARCHAR(10) NULL,
  time1_offset_min INT NULL,
  time2 TIME NULL,
  time2_meal VARCHAR(10) NULL,
  time2_offset_min INT NULL,
  time3 TIME NULL,
  time3_meal VARCHAR(10) NULL,
  time3_offset_min INT NULL,
  time4 TIME NULL,
  time4_meal VARCHAR(10) NULL,
  time4_offset_min INT NULL,
  time5 TIME NULL,
  time5_meal VARCHAR(10) NULL,
  time5_offset_min INT NULL,
  time6 TIME NULL,
  time6_meal VARCHAR(10) NULL,
  time6_offset_min INT NULL,

  start_date DATE NOT NULL,
  end_date DATE NULL,
  is_indefinite BOOLEAN NOT NULL DEFAULT FALSE,
  notes TEXT NULL,

  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  INDEX idx_med_user (user_id),
  CONSTRAINT fk_med_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Pillbox Status
CREATE TABLE IF NOT EXISTS pillbox_status (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  detected BOOLEAN NOT NULL DEFAULT FALSE,
  battery_percent INT NULL,
  is_locked BOOLEAN NOT NULL DEFAULT FALSE,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_pill_user (user_id),
  CONSTRAINT fk_pill_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- AI Feedback Logs (선택 저장)
CREATE TABLE IF NOT EXISTS ai_feedbacks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  kind ENUM('chat','feedback') NOT NULL,
  request_text TEXT NOT NULL,
  response_text LONGTEXT NULL,
  source ENUM('mfds','gemini','mixed') NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_ai_user (user_id),
  CONSTRAINT fk_ai_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;
