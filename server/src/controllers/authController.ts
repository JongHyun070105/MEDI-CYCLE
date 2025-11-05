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
    const { email, name, age, address, gender, auto_login } = req.body;

    if (!userId) {
      return res.status(401).json({ error: "인증이 필요합니다" });
    }

    // 현재 사용자 정보 조회
    const currentUserResult = await query(
      "SELECT email FROM users WHERE id = $1",
      [userId]
    );

    if (currentUserResult.rows.length === 0) {
      return res.status(404).json({ error: "사용자를 찾을 수 없습니다" });
    }

    const currentEmail = currentUserResult.rows[0].email;

    // 이메일 변경 시 중복 체크 (자신의 이메일은 제외)
    if (email && email !== currentEmail) {
      // 이메일 형식 검증
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(email)) {
        return res.status(400).json({ error: "올바른 이메일 형식이 아닙니다" });
      }

      // 이메일 중복 확인
      const existingUser = await query(
        "SELECT id FROM users WHERE email = $1",
        [email]
      );

      if (existingUser.rows.length > 0) {
        return res.status(400).json({ error: "이미 사용 중인 이메일입니다" });
      }
    }

    // 프로필 업데이트
    const updateFields: string[] = [];
    const updateValues: any[] = [];
    let paramIndex = 1;

    if (email !== undefined) {
      updateFields.push(`email = $${paramIndex}`);
      updateValues.push(email);
      paramIndex++;
    }
    if (name !== undefined) {
      updateFields.push(`name = $${paramIndex}`);
      updateValues.push(name);
      paramIndex++;
    }
    if (age !== undefined) {
      updateFields.push(`age = $${paramIndex}`);
      updateValues.push(age);
      paramIndex++;
    }
    if (address !== undefined) {
      updateFields.push(`address = $${paramIndex}`);
      updateValues.push(address);
      paramIndex++;
    }
    if (gender !== undefined) {
      updateFields.push(`gender = $${paramIndex}`);
      updateValues.push(gender);
      paramIndex++;
    }
    if (auto_login !== undefined) {
      updateFields.push(`auto_login = $${paramIndex}`);
      updateValues.push(auto_login);
      paramIndex++;
    }

    if (updateFields.length === 0) {
      return res.status(400).json({ error: "변경할 정보가 없습니다" });
    }

    updateFields.push(`updated_at = CURRENT_TIMESTAMP`);
    updateValues.push(userId);

    const finalParamIndex = updateValues.length;

    const updateQuery = `
      UPDATE users 
      SET ${updateFields.join(', ')} 
      WHERE id = $${finalParamIndex} 
      RETURNING id, email, name, age, address, gender, auto_login
    `;

    const result = await query(updateQuery, updateValues);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "사용자를 찾을 수 없습니다" });
    }

    const user = result.rows[0];

    return res.json({
      message: "프로필이 업데이트되었습니다",
      user,
    });
  } catch (error: any) {
    console.error("Update profile error:", error);
    
    // 데이터베이스 제약 조건 위반 에러 처리
    if (error.code === '23505') { // unique_violation
      if (error.constraint && error.constraint.includes('email')) {
        return res.status(400).json({ error: "이미 사용 중인 이메일입니다" });
      }
    }

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
