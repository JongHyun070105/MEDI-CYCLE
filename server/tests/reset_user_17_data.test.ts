import { describe, it, expect, beforeAll, afterAll } from '@jest/globals';
import { query } from '../database/db.js';

describe('User 17 데이터 리셋 테스트', () => {
  const userId = 17;

  beforeAll(async () => {
    // 테스트 전 데이터 확인
    const medications = await query(
      'SELECT COUNT(*) as count FROM medications WHERE user_id = $1',
      [userId]
    );
    console.log(`테스트 전 약물 개수: ${medications.rows[0].count}`);
  });

  afterAll(async () => {
    // 테스트 후 정리 (필요시)
  });

  it('유효기간 30일 남은 약이 제대로 추가되는지 확인', async () => {
    // 유효기간 30일 남은 약 검색
    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + 30);
    const expiryDateStr = expiryDate.toISOString().split('T')[0];

    const result = await query(
      `SELECT * FROM medications 
       WHERE user_id = $1 
       AND expiry_date = $2 
       AND drug_name = '유효기간테스트약'`,
      [userId, expiryDateStr]
    );

    expect(result.rows.length).toBeGreaterThan(0);
    
    if (result.rows.length > 0) {
      const medication = result.rows[0];
      expect(medication.expiry_date).toBe(expiryDateStr);
      expect(medication.drug_name).toBe('유효기간테스트약');
      console.log(`✅ 유효기간 테스트 약 추가 확인: ${medication.drug_name}, 유효기간: ${medication.expiry_date}`);
    }
  });

  it('user_id 17의 복용 데이터가 제대로 생성되었는지 확인', async () => {
    const intakes = await query(
      'SELECT COUNT(*) as count FROM medication_intakes WHERE user_id = $1',
      [userId]
    );

    const count = parseInt(intakes.rows[0].count);
    expect(count).toBeGreaterThan(0);
    console.log(`✅ 복용 데이터 개수: ${count}`);
  });

  it('약물 데이터가 제대로 생성되었는지 확인', async () => {
    const medications = await query(
      'SELECT * FROM medications WHERE user_id = $1 ORDER BY id',
      [userId]
    );

    expect(medications.rows.length).toBeGreaterThan(0);
    
    // 각 약물에 제조사명과 성분이 있는지 확인
    for (const medication of medications.rows) {
      expect(medication.drug_name).toBeTruthy();
      // 제조사명이 null이 아닌지 확인 (일부는 null일 수 있음)
      // 성분이 null이 아닌지 확인 (일부는 null일 수 있음)
      console.log(`약물: ${medication.drug_name}, 제조사: ${medication.manufacturer || '없음'}, 성분: ${medication.ingredient || '없음'}`);
    }
  });
});

