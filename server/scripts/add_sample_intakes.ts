import { query } from "../src/database/db.js";

async function addSampleIntakes() {
  try {
    const userId = 13; // 박종현 사용자 ID

    // 사용자의 약물 조회
    const medications = await query(
      `SELECT id, drug_name, dosage_times, start_date, end_date, is_indefinite 
       FROM medications 
       WHERE user_id = $1 
       ORDER BY created_at DESC 
       LIMIT 5`,
      [userId]
    );

    if (medications.rows.length === 0) {
      console.log("❌ 사용자에게 등록된 약물이 없습니다.");
      return;
    }

    console.log(`✅ ${medications.rows.length}개의 약물을 찾았습니다.`);

    // 2025년 1월부터 현재까지의 복용 데이터 생성
    const now = new Date();
    const months = [];
    const startYear = 2025;
    const startMonth = 0; // 1월 (0-based)
    
    for (let year = startYear; year <= now.getFullYear(); year++) {
      const endMonth = year === now.getFullYear() ? now.getMonth() : 11;
      const startM = year === startYear ? startMonth : 0;
      
      for (let month = startM; month <= endMonth; month++) {
        months.push(new Date(year, month, 1));
      }
    }

    let totalInserted = 0;

    for (const med of medications.rows) {
      const medId = med.id;
      const dosageTimes = med.dosage_times || [];
      const startDate = new Date(med.start_date);
      const endDate = med.end_date ? new Date(med.end_date) : null;
      const isIndefinite = med.is_indefinite;

      console.log(`\n📦 약물: ${med.drug_name} (ID: ${medId})`);
      console.log(`   복용 횟수: ${dosageTimes.length}회/일`);

      for (const month of months) {
        const year = month.getFullYear();
        const monthNum = month.getMonth();

        // 해당 월의 일수
        const daysInMonth = new Date(year, monthNum + 1, 0).getDate();

        let monthInserted = 0;
        let monthPlanned = 0;

        for (let day = 1; day <= daysInMonth; day++) {
          const date = new Date(year, monthNum, day);

          // 약물 시작일 이후이고 종료일 이전(또는 무기한)인지 확인
          // 시작일이 미래이면 해당 월의 첫날부터 시작
          const effectiveStartDate = startDate > date ? new Date(year, monthNum, 1) : startDate;
          if (date < effectiveStartDate) continue;
          if (!isIndefinite && endDate && date > endDate) continue;

          // 각 복용 시간에 대해 데이터 생성 (70% 확률로 복용)
          for (const dosageTime of dosageTimes) {
            const [hours, minutes] = dosageTime.split(":").map(Number);
            const intakeTime = new Date(year, monthNum, day, hours, minutes);

            monthPlanned++;

            // 70% 확률로 복용, 주말에는 60% 확률로 복용
            const dayOfWeek = intakeTime.getDay();
            const isWeekend = dayOfWeek === 0 || dayOfWeek === 6;
            const takeProbability = isWeekend ? 0.6 : 0.7;

            if (Math.random() < takeProbability) {
              // 복용 기록 추가
              await query(
                `INSERT INTO medication_intakes 
                 (user_id, medication_id, intake_time, is_taken) 
                 VALUES ($1, $2, $3, $4)
                 ON CONFLICT DO NOTHING`,
                [userId, medId, intakeTime.toISOString(), true]
              );
              monthInserted++;
              totalInserted++;
            }
          }
        }

        const monthPct = monthPlanned > 0 
          ? Math.round((monthInserted / monthPlanned) * 100) 
          : 0;
        console.log(
          `   ${year}-${String(monthNum + 1).padStart(2, "0")}: ${monthInserted}/${monthPlanned} (${monthPct}%)`
        );
      }
    }

    console.log(`\n✅ 총 ${totalInserted}개의 복용 기록이 추가되었습니다.`);
  } catch (error) {
    console.error("❌ 오류 발생:", error);
    throw error;
  }
}

addSampleIntakes()
  .then(() => {
    console.log("\n✨ 완료!");
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ 스크립트 실행 실패:", error);
    process.exit(1);
  });

