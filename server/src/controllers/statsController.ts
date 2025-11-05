import { Request, Response } from "express";
import { query } from "../database/db.js";

// 월별 복용률 집계: 해당 연도의 모든 월, 각 월별 (완료 복용 수 / 계획 복용 수)
export const getMonthlyAdherence = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    if (!userId) return res.status(401).json({ error: "인증이 필요합니다" });

    // 현재 연도의 모든 월 (1월~12월) 생성
    const currentYear = new Date().getFullYear();
    const yearStart = `${currentYear}-01-01`;
    const yearEnd = `${currentYear + 1}-01-01`;
    
    const result = await query(
      `WITH months AS (
         SELECT date_trunc('month', ($2::date + (interval '1 month' * gs))) AS month_start
         FROM generate_series(0, 11) AS gs
       ),
       plans AS (
         SELECT 
           date_trunc('month', dd)::date AS month_start,
           SUM( array_length(m.dosage_times, 1) ) AS planned
         FROM medications m
         JOIN LATERAL generate_series(m.start_date::date, COALESCE(m.end_date::date, $3::date - interval '1 day'), interval '1 day') dd ON TRUE
         WHERE m.user_id = $1
           AND date_trunc('month', dd)::date >= $2::date
           AND date_trunc('month', dd)::date < $3::date
         GROUP BY 1
       ),
       takes AS (
         SELECT date_trunc('month', mi.intake_time)::date AS month_start,
                COUNT(*) FILTER (WHERE mi.is_taken = TRUE) AS completed
         FROM medication_intakes mi
         JOIN medications m ON mi.medication_id = m.id AND m.user_id = $1
         WHERE date_trunc('month', mi.intake_time)::date >= $2::date
           AND date_trunc('month', mi.intake_time)::date < $3::date
         GROUP BY 1
       )
       SELECT to_char(months.month_start, 'YYYY-MM') AS month,
              COALESCE(plans.planned, 0) AS planned,
              COALESCE(takes.completed, 0) AS completed,
              CASE WHEN COALESCE(plans.planned,0) > 0 
                   THEN ROUND( (COALESCE(takes.completed,0)::numeric / plans.planned) * 100, 0)
                   ELSE 0 END AS adherence_pct
       FROM months
       LEFT JOIN plans ON plans.month_start = months.month_start
       LEFT JOIN takes ON takes.month_start = months.month_start
       ORDER BY months.month_start`,
      [userId, yearStart, yearEnd]
    );

    // 디버깅: 응답 데이터 확인
    console.log(`📊 월별 복용률 조회 결과 (사용자 ${userId}):`);
    console.log(`   총 ${result.rows.length}개월 데이터`);
    result.rows.forEach((row, index) => {
      console.log(`   ${index + 1}. ${row.month}: 계획 ${row.planned}회, 완료 ${row.completed}회, 복용률 ${row.adherence_pct}%`);
    });
    
    return res.json({ months: result.rows });
  } catch (error) {
    console.error("Get monthly adherence error:", error);
    return res
      .status(500)
      .json({ error: "월별 복용률 조회 중 오류가 발생했습니다" });
  }
};
