import { query } from "../src/database/db.js";

async function addIntakesForUser18() {
  try {
    const userId = 18;

    console.log(`\n🔍 사용자 ID ${userId}의 약물 정보 조회 중...\n`);

    // 사용자의 약물 조회
    const medications = await query(
      `SELECT id, drug_name, dosage_times, start_date, end_date, is_indefinite, frequency
       FROM medications 
       WHERE user_id = $1 
       ORDER BY created_at DESC`,
      [userId]
    );

    if (medications.rows.length === 0) {
      console.log("❌ 사용자에게 등록된 약물이 없습니다.");
      return;
    }

    console.log(`✅ ${medications.rows.length}개의 약물을 찾았습니다.\n`);

    // 각 약물 정보 출력
    for (const med of medications.rows) {
      console.log(`📦 약물: ${med.drug_name} (ID: ${med.id})`);
      console.log(`   시작일: ${med.start_date}`);
      console.log(`   종료일: ${med.end_date || (med.is_indefinite ? '무기한' : '없음')}`);
      console.log(`   복용 횟수: ${med.frequency || med.dosage_times?.length || 0}회/일`);
      console.log(`   복용 시간: ${(med.dosage_times || []).join(', ')}`);
      console.log('');
    }

    // 각 약물의 시작일부터 종료일까지 1년치 복용 데이터 생성
    const today = new Date();
    today.setHours(23, 59, 59, 999); // 오늘 마지막 시간

    console.log(`\n📅 복용 데이터 생성 시작 (각 약물의 시작일 ~ 종료일 기준)\n`);

    let totalInserted = 0;
    let totalPlanned = 0;

    for (const med of medications.rows) {
      const medId = med.id;
      const dosageTimes = med.dosage_times || [];
      const medStartDate = new Date(med.start_date);
      const medEndDate = med.end_date ? new Date(med.end_date) : null;
      const isIndefinite = med.is_indefinite;

      console.log(`\n📦 약물: ${med.drug_name} (ID: ${medId})`);

      if (dosageTimes.length === 0) {
        console.log(`   ⚠️  복용 시간이 없어서 건너뜁니다.`);
        continue;
      }

      // 실제 복용 시작일 (약물 시작일)
      const effectiveStartDate = new Date(medStartDate);
      effectiveStartDate.setHours(0, 0, 0, 0);
      
      // 실제 복용 종료일
      let effectiveEndDate: Date;
      if (isIndefinite) {
        // 무기한인 경우: 시작일부터 1년 후 또는 오늘 중 더 이른 날
        const oneYearLater = new Date(effectiveStartDate);
        oneYearLater.setFullYear(oneYearLater.getFullYear() + 1);
        oneYearLater.setHours(23, 59, 59, 999);
        effectiveEndDate = oneYearLater < today ? oneYearLater : today;
      } else if (medEndDate) {
        // 종료일이 있는 경우: 종료일 또는 오늘 중 더 이른 날
        const endDate = new Date(medEndDate);
        endDate.setHours(23, 59, 59, 999);
        effectiveEndDate = endDate < today ? endDate : today;
      } else {
        // 종료일이 없는 경우: 오늘까지
        effectiveEndDate = new Date(today);
      }

      if (effectiveStartDate > effectiveEndDate) {
        console.log(`   ⚠️  복용 기간이 없어서 건너뜁니다. (시작일: ${medStartDate.toISOString().split('T')[0]}, 종료일: ${medEndDate?.toISOString().split('T')[0] || '없음'})`);
        continue;
      }

      const daysDiff = Math.ceil((effectiveEndDate.getTime() - effectiveStartDate.getTime()) / (1000 * 60 * 60 * 24));
      console.log(`   복용 기간: ${effectiveStartDate.toISOString().split('T')[0]} ~ ${effectiveEndDate.toISOString().split('T')[0]} (${daysDiff}일)`);

      let medInserted = 0;
      let medPlanned = 0;

      // 날짜별로 반복
      const currentDate = new Date(effectiveStartDate);
      while (currentDate <= effectiveEndDate) {
        const year = currentDate.getFullYear();
        const month = currentDate.getMonth();
        const day = currentDate.getDate();

        // 각 복용 시간에 대해 데이터 생성
        for (const dosageTime of dosageTimes) {
          const [hours, minutes] = dosageTime.split(":").map(Number);
          const intakeTime = new Date(year, month, day, hours, minutes);

          // 복용 종료일 이후의 복용 시간은 건너뜀
          if (intakeTime > effectiveEndDate) {
            continue;
          }

          medPlanned++;
          totalPlanned++;

          // 70% 확률로 복용, 주말에는 60% 확률로 복용
          const dayOfWeek = intakeTime.getDay();
          const isWeekend = dayOfWeek === 0 || dayOfWeek === 6;
          const takeProbability = isWeekend ? 0.6 : 0.7;

          if (Math.random() < takeProbability) {
            // 기존 복용 기록 확인
            const existing = await query(
              `SELECT id FROM medication_intakes 
               WHERE user_id = $1 AND medication_id = $2 AND intake_time = $3`,
              [userId, medId, intakeTime.toISOString()]
            );

            if (existing.rows.length === 0) {
              // 복용 기록 추가
              await query(
                `INSERT INTO medication_intakes 
                 (user_id, medication_id, intake_time, is_taken) 
                 VALUES ($1, $2, $3, $4)`,
                [userId, medId, intakeTime.toISOString(), true]
              );
              medInserted++;
              totalInserted++;
            } else {
              // 기존 기록 업데이트
              await query(
                `UPDATE medication_intakes 
                 SET is_taken = $1, updated_at = CURRENT_TIMESTAMP
                 WHERE id = $2`,
                [true, existing.rows[0].id]
              );
              medInserted++;
              totalInserted++;
            }
          }
        }

        // 다음 날로 이동
        currentDate.setDate(currentDate.getDate() + 1);
      }

      const medPct = medPlanned > 0 
        ? Math.round((medInserted / medPlanned) * 100) 
        : 0;
      console.log(`   ✅ ${medInserted}/${medPlanned} (${medPct}%) 복용 기록 생성`);
    }

    const totalPct = totalPlanned > 0 
      ? Math.round((totalInserted / totalPlanned) * 100) 
      : 0;
    console.log(`\n✅ 총 ${totalInserted}/${totalPlanned} (${totalPct}%)개의 복용 기록이 추가되었습니다.`);
  } catch (error) {
    console.error("❌ 오류 발생:", error);
    throw error;
  }
}

addIntakesForUser18()
  .then(() => {
    console.log("\n✨ 완료!");
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ 스크립트 실행 실패:", error);
    process.exit(1);
  });

