import { Request, Response } from "express";
import bcryptjs from "bcryptjs";
import { query } from "../database/db.js";
import { generateToken } from "../middleware/auth.js";
import { User } from "../types/index.js";

export const register = async (req: Request, res: Response) => {
  try {
    const { email, password, name } = req.body;

    // 입력값 검증
    if (!email || !password || !name) {
      return res
        .status(400)
        .json({ error: "이메일, 비밀번호, 이름은 필수입니다" });
    }

    // 이메일 중복 확인
    const existingUser = await query("SELECT id FROM users WHERE email = $1", [
      email,
    ]);
    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: "이미 등록된 이메일입니다" });
    }

    // 비밀번호 해싱
    const hashedPassword = await bcryptjs.hash(password, 10);

    // 사용자 생성
    const result = await query(
      "INSERT INTO users (email, password, name) VALUES ($1, $2, $3) RETURNING id, email, name, created_at",
      [email, hashedPassword, name]
    );

    const user = result.rows[0];
    const token = generateToken(user.id, user.email);

    return res.status(201).json({
      message: "회원가입이 완료되었습니다",
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
      },
      token,
    });
  } catch (error) {
    console.error("Register error:", error);
    return res.status(500).json({ error: "회원가입 중 오류가 발생했습니다" });
  }
};

export const login = async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;
    console.log("   🔐 Login attempt for:", email);

    // 입력값 검증
    if (!email || !password) {
      console.log("   ❌ Missing email or password");
      return res.status(400).json({ error: "이메일과 비밀번호는 필수입니다" });
    }

    // 사용자 조회
    console.log("   🔍 Searching for user...");
    const result = await query(
      "SELECT id, email, password, name FROM users WHERE email = $1",
      [email]
    );
    const user = result.rows[0] as User | undefined;

    if (!user) {
      console.log("   ❌ User not found");
      return res
        .status(401)
        .json({ error: "이메일 또는 비밀번호가 잘못되었습니다" });
    }

    console.log("   ✅ User found, checking password...");
    // 비밀번호 확인
    const isPasswordValid = await bcryptjs.compare(password, user.password);
    if (!isPasswordValid) {
      console.log("   ❌ Invalid password");
      return res
        .status(401)
        .json({ error: "이메일 또는 비밀번호가 잘못되었습니다" });
    }

    console.log("   ✅ Password valid, generating token...");
    // 토큰 생성
    const token = generateToken(user.id, user.email);

    console.log("   ✅ Login successful");
    return res.json({
      message: "로그인 성공",
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
      },
      token,
    });
  } catch (error) {
    console.error("   ⚠️  Login error:", error);
    return res.status(500).json({ error: "로그인 중 오류가 발생했습니다" });
  }
};

export const updateProfile = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    const { name, age, address, gender, auto_login } = req.body;

    if (!userId) {
      return res.status(401).json({ error: "인증이 필요합니다" });
    }

    // 프로필 업데이트
    const result = await query(
      "UPDATE users SET name = COALESCE($1, name), age = COALESCE($2, age), address = COALESCE($3, address), gender = COALESCE($4, gender), auto_login = COALESCE($5, auto_login), updated_at = CURRENT_TIMESTAMP WHERE id = $6 RETURNING id, email, name, age, address, gender, auto_login",
      [name, age, address, gender, auto_login, userId]
    );

    const user = result.rows[0];

    return res.json({
      message: "프로필이 업데이트되었습니다",
      user,
    });
  } catch (error) {
    console.error("Update profile error:", error);
    return res
      .status(500)
      .json({ error: "프로필 업데이트 중 오류가 발생했습니다" });
  }
};

export const getProfile = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;

    if (!userId) {
      return res.status(401).json({ error: "인증이 필요합니다" });
    }

    const result = await query(
      "SELECT id, email, name, age, address, gender, auto_login FROM users WHERE id = $1",
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "사용자를 찾을 수 없습니다" });
    }

    return res.json({
      user: result.rows[0],
    });
  } catch (error) {
    console.error("Get profile error:", error);
    return res
      .status(500)
      .json({ error: "프로필 조회 중 오류가 발생했습니다" });
  }
};
