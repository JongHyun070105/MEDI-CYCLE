import { query } from "../src/database/db.js";

async function resetAndAddData() {
  try {
    const userId = 17; // 주시우 사용자 ID

    console.log("🗑️  기존 약 데이터 삭제 중...");
    
    // 복용 데이터 먼저 삭제 (외래키 제약 때문에)
    await query(`DELETE FROM medication_intakes WHERE user_id = $1`, [userId]);
    console.log("   ✅ 복용 데이터 삭제 완료");
    
    // 약 데이터 삭제
    await query(`DELETE FROM medications WHERE user_id = $1`, [userId]);
    console.log("   ✅ 약 데이터 삭제 완료");

    console.log("\n📦 새로운 약 등록 중...");

    // 약 5-6개 등록 (2025년 1월 1일부터 2025년 12월 31일까지)
    const startDate = "2025-01-01";
    const endDate = "2025-12-31";

    const medications = [
      {
        drug_name: "타이레놀정500밀리그람",
        manufacturer: "한국얀센",
        ingredient: "아세트아미노펜",
        frequency: 3,
        dosage_times: ["08:00", "13:00", "19:00"],
        meal_relations: ["아침", "점심", "저녁"],
        meal_offsets: [0, 0, 0],
      },
      {
        drug_name: "다이톱현탁액",
        manufacturer: "유한양행",
        ingredient: "디옥타헤드랄스멕타이트",
        frequency: 3,
        dosage_times: ["08:30", "13:30", "19:30"],
        meal_relations: ["아침", "점심", "저녁"],
        meal_offsets: [30, 30, 30],
      },
      {
        drug_name: "슈멕톤현탁액",
        manufacturer: "한화",
        ingredient: "디옥타헤드랄스멕타이트",
        frequency: 3,
        dosage_times: ["09:00", "14:00", "20:00"],
        meal_relations: ["아침", "점심", "저녁"],
        meal_offsets: [60, 60, 60],
      },
      {
        drug_name: "바이탈씨에프정",
        manufacturer: "알파",
        ingredient: "아스코르빈산",
        frequency: 2,
        dosage_times: ["09:00", "21:00"],
        meal_relations: ["아침", "저녁"],
        meal_offsets: [0, 0],
      },
      {
        drug_name: "스카이정",
        manufacturer: "대웅",
        ingredient: "레보세티리진",
        frequency: 1,
        dosage_times: ["20:00"],
        meal_relations: ["저녁"],
        meal_offsets: [0],
      },
      {
        drug_name: "게보린정",
        manufacturer: "삼진제약",
        ingredient: "아세트아미노펜, 카페인",
        frequency: 2,
        dosage_times: ["09:00", "21:00"],
        meal_relations: ["아침", "저녁"],
        meal_offsets: [0, 0],
      },
    ];

    const insertedMedIds: number[] = [];

    for (const med of medications) {
      const result = await query(
        `INSERT INTO medications 
         (user_id, drug_name, manufacturer, ingredient, frequency, dosage_times, meal_relations, meal_offsets, start_date, end_date, is_indefinite)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
         RETURNING id`,
        [
          userId,
          med.drug_name,
          med.manufacturer,
          med.ingredient,
          med.frequency,
          med.dosage_times,
          med.meal_relations,
          med.meal_offsets,
          startDate,
          endDate,
          false,
        ]
      );

      insertedMedIds.push(result.rows[0].id);
      console.log(`   ✅ ${med.drug_name} 등록 완료 (ID: ${result.rows[0].id})`);
    }

    console.log("\n📊 복용 데이터 생성 중...");

    // 2025년 1월 1일부터 11월 4일까지의 복용 데이터 생성
    const start = new Date(2025, 0, 1); // 2025-01-01
    const end = new Date(2025, 10, 4); // 2025-11-04

    let totalInserted = 0;

    for (let i = 0; i < insertedMedIds.length; i++) {
      const medId = insertedMedIds[i];
      const med = medications[i];
      const dosageTimes = med.dosage_times;

      console.log(`\n📦 약물: ${med.drug_name} (ID: ${medId})`);
      console.log(`   복용 횟수: ${dosageTimes.length}회/일`);

      const currentDate = new Date(start);
      let monthCount = 0;
      let monthInserted = 0;
      let monthPlanned = 0;
      let currentMonth = -1;

      while (currentDate <= end) {
        const year = currentDate.getFullYear();
        const month = currentDate.getMonth();
        const day = currentDate.getDate();

        // 월이 바뀌면 이전 월 통계 출력
        if (currentMonth !== -1 && currentMonth !== month) {
          const monthPct = monthPlanned > 0 
            ? Math.round((monthInserted / monthPlanned) * 100) 
            : 0;
          console.log(
            `   ${year}-${String(currentMonth + 1).padStart(2, "0")}: ${monthInserted}/${monthPlanned} (${monthPct}%)`
          );
          monthInserted = 0;
          monthPlanned = 0;
        }

        currentMonth = month;

        // 각 복용 시간에 대해 데이터 생성
        for (const dosageTime of dosageTimes) {
          const [hours, minutes] = dosageTime.split(":").map(Number);
          const intakeTime = new Date(year, month, day, hours, minutes);

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

        // 다음 날로 이동
        currentDate.setDate(currentDate.getDate() + 1);
      }

      // 마지막 월 통계 출력
      if (monthPlanned > 0) {
        const year = currentDate.getFullYear();
        const monthPct = Math.round((monthInserted / monthPlanned) * 100);
        console.log(
          `   ${year}-${String(currentMonth + 1).padStart(2, "0")}: ${monthInserted}/${monthPlanned} (${monthPct}%)`
        );
      }
    }

    console.log(`\n✅ 총 ${totalInserted}개의 복용 기록이 추가되었습니다.`);
    console.log("\n✨ 완료!");
  } catch (error) {
    console.error("❌ 오류 발생:", error);
    throw error;
  }
}

resetAndAddData()
  .then(() => {
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ 스크립트 실행 실패:", error);
    process.exit(1);
  });

