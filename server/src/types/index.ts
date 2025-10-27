export interface User {
  id: number;
  email: string;
  password: string;
  name: string;
  age: number | null;
  address: string | null;
  gender: string | null;
  auto_login: boolean;
  created_at: string;
  updated_at: string;
}

export interface Medication {
  id: number;
  user_id: number;
  drug_name: string;
  manufacturer: string | null;
  ingredient: string | null;
  frequency: number;
  dosage_times: string[];
  meal_relations: string[];
  meal_offsets: number[];
  start_date: string;
  end_date: string | null;
  is_indefinite: boolean;
  created_at: string;
  updated_at: string;
}

export interface MedicationIntake {
  id: number;
  user_id: number;
  medication_id: number;
  intake_time: string;
  is_taken: boolean;
  created_at: string;
  updated_at: string;
}

export interface ChatMessage {
  id: number;
  user_id: number;
  role: string;
  content: string;
  created_at: string;
}

export interface Pillbox {
  id: number;
  user_id: number;
  device_id: string;
  device_name: string | null;
  is_connected: boolean;
  lock_status: string | null;
  battery_level: number | null;
  last_connected: string | null;
  created_at: string;
  updated_at: string;
}

export interface AuthPayload {
  email: string;
  password: string;
}

export interface RegisterPayload extends AuthPayload {
  name: string;
}

export interface JWTPayload {
  id: number;
  email: string;
}
