import pool from "../src/database/db.js";

async function addExpiryTestData() {
  const client = await pool.connect();
  
  try {
    await client.query("BEGIN");
    
    const userId = 18;
    
    // 현재 날짜
    const now = new Date();
    
    // 1. 유통기한 30일 남은 약 (임박)
    const imminent30Days = new Date(now);
    imminent30Days.setDate(imminent30Days.getDate() + 30);
    
    await client.query(
      `INSERT INTO medications (
        user_id, drug_name, manufacturer, ingredient, 
        frequency, dosage_times, meal_relations, meal_offsets,
        start_date, end_date, is_indefinite,
        expiry_date, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, NOW())`,
      [
        userId,
        '타이레놀정 500mg',
        '한국존슨앤드존슨',
        '아세트아미노펜',
        2,
        ['09:00', '21:00'],
        ['식후', '식후'],
        [30, 30],
        now.toISOString().split('T')[0],
        null,
        true,
        imminent30Days.toISOString().split('T')[0]
      ]
    );
    
    // 2. 유통기한 15일 남은 약 (임박)
    const imminent15Days = new Date(now);
    imminent15Days.setDate(imminent15Days.getDate() + 15);
    
    await client.query(
      `INSERT INTO medications (
        user_id, drug_name, manufacturer, ingredient, 
        frequency, dosage_times, meal_relations, meal_offsets,
        start_date, end_date, is_indefinite,
        expiry_date, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, NOW())`,
      [
        userId,
        '판콜에이내복액',
        '동아제약',
        '아세트아미노펜 외',
        3,
        ['08:00', '14:00', '20:00'],
        ['식후', '식후', '식후'],
        [30, 30, 30],
        now.toISOString().split('T')[0],
        null,
        true,
        imminent15Days.toISOString().split('T')[0]
      ]
    );
    
    // 3. 유통기한 7일 남은 약 (임박)
    const imminent7Days = new Date(now);
    imminent7Days.setDate(imminent7Days.getDate() + 7);
    
    await client.query(
      `INSERT INTO medications (
        user_id, drug_name, manufacturer, ingredient, 
        frequency, dosage_times, meal_relations, meal_offsets,
        start_date, end_date, is_indefinite,
        expiry_date, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, NOW())`,
      [
        userId,
        '게보린정',
        '삼진제약',
        '아세트아미노펜 외',
        2,
        ['10:00', '22:00'],
        ['식후', '식후'],
        [0, 0],
        now.toISOString().split('T')[0],
        null,
        true,
        imminent7Days.toISOString().split('T')[0]
      ]
    );
    
    // 4. 유통기한 5일 지난 약 (만료)
    const expired5Days = new Date(now);
    expired5Days.setDate(expired5Days.getDate() - 5);
    
    await client.query(
      `INSERT INTO medications (
        user_id, drug_name, manufacturer, ingredient, 
        frequency, dosage_times, meal_relations, meal_offsets,
        start_date, end_date, is_indefinite,
        expiry_date, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, NOW())`,
      [
        userId,
        '어린이타이레놀현탁액',
        '한국존슨앤드존슨',
        '아세트아미노펜',
        2,
        ['09:00', '18:00'],
        ['식후', '식후'],
        [30, 30],
        expired5Days.toISOString().split('T')[0],
        expired5Days.toISOString().split('T')[0],
        false,
        expired5Days.toISOString().split('T')[0]
      ]
    );
    
    // 5. 유통기한 15일 지난 약 (만료)
    const expired15Days = new Date(now);
    expired15Days.setDate(expired15Days.getDate() - 15);
    
    await client.query(
      `INSERT INTO medications (
        user_id, drug_name, manufacturer, ingredient, 
        frequency, dosage_times, meal_relations, meal_offsets,
        start_date, end_date, is_indefinite,
        expiry_date, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, NOW())`,
      [
        userId,
        '후시딘연고',
        '동화약품',
        '푸시드산나트륨',
        1,
        ['21:00'],
        ['식후'],
        [0],
        expired15Days.toISOString().split('T')[0],
        expired15Days.toISOString().split('T')[0],
        false,
        expired15Days.toISOString().split('T')[0]
      ]
    );
    
    // 6. 유통기한 30일 지난 약 (만료)
    const expired30Days = new Date(now);
    expired30Days.setDate(expired30Days.getDate() - 30);
    
    await client.query(
      `INSERT INTO medications (
        user_id, drug_name, manufacturer, ingredient, 
        frequency, dosage_times, meal_relations, meal_offsets,
        start_date, end_date, is_indefinite,
        expiry_date, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, NOW())`,
      [
        userId,
        '베아제정',
        '한국암웨이',
        '판크레아틴',
        3,
        ['08:00', '13:00', '19:00'],
        ['식후', '식후', '식후'],
        [0, 0, 0],
        expired30Days.toISOString().split('T')[0],
        expired30Days.toISOString().split('T')[0],
        false,
        expired30Days.toISOString().split('T')[0]
      ]
    );
    
    await client.query("COMMIT");
    
    console.log("✅ 유통기한 테스트 데이터 추가 완료:");
    console.log(`   - 유통기한 임박 (30일): 1개`);
    console.log(`   - 유통기한 임박 (15일): 1개`);
    console.log(`   - 유통기한 임박 (7일): 1개`);
    console.log(`   - 유통기한 만료 (5일 전): 1개`);
    console.log(`   - 유통기한 만료 (15일 전): 1개`);
    console.log(`   - 유통기한 만료 (30일 전): 1개`);
    
  } catch (error) {
    await client.query("ROLLBACK");
    console.error("❌ 데이터 추가 실패:", error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

addExpiryTestData().catch(console.error);

