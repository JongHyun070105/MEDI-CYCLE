import pool from "../src/database/db.js";

async function deleteExpiryTestData() {
  const client = await pool.connect();
  
  try {
    await client.query("BEGIN");
    
    const userId = 18;
    
    // 유통기한 테스트 약들 삭제
    const result = await client.query(
      `DELETE FROM medications 
       WHERE user_id = $1 
       AND (
         drug_name LIKE '%유통기한%'
         OR drug_name IN (
           '타이레놀정 500mg',
           '판콜에이내복액',
           '게보린정',
           '어린이타이레놀현탁액',
           '후시딘연고',
           '베아제정'
         )
       )
       RETURNING id, drug_name`,
      [userId]
    );
    
    await client.query("COMMIT");
    
    console.log(`✅ 유통기한 테스트 데이터 삭제 완료: ${result.rows.length}개`);
    result.rows.forEach((row) => {
      console.log(`   - ${row.drug_name} (ID: ${row.id})`);
    });
    
  } catch (error) {
    await client.query("ROLLBACK");
    console.error("❌ 데이터 삭제 실패:", error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

deleteExpiryTestData().catch(console.error);

