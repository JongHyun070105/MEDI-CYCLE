import { Request, Response } from "express";
import { query } from "../database/db.js";

export const getHealthInsights = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    if (!userId) return res.status(401).json({ error: "인증이 필요합니다" });

    // 최근 90일 계획/완료 집계
    const result = await query(
      `WITH days AS (
         SELECT dd::date AS d
         FROM generate_series(CURRENT_DATE - interval '90 day', CURRENT_DATE, interval '1 day') dd
       ),
       plans AS (
         SELECT dd::date AS d, COALESCE(array_length(m.dosage_times,1),0) AS planned
         FROM medications m
         JOIN LATERAL generate_series(m.start_date::date, COALESCE(m.end_date::date, CURRENT_DATE), interval '1 day') dd ON TRUE
         WHERE m.user_id = $1
       ),
       takes AS (
         SELECT date_trunc('day', mi.intake_time)::date AS d,
                COUNT(*) FILTER (WHERE mi.is_taken = TRUE) AS completed
         FROM medication_intakes mi
         JOIN medications m ON m.id = mi.medication_id AND m.user_id = $1
         GROUP BY 1
       )
       SELECT d.d,
              COALESCE((SELECT SUM(planned) FROM plans p WHERE p.d = d.d),0) AS planned,
              COALESCE((SELECT completed FROM takes t WHERE t.d = d.d),0) AS completed
       FROM days d
       ORDER BY d.d`,
      [userId]
    );

    const rows = result.rows as Array<{
      d: string;
      planned: number;
      completed: number;
    }>;
    const totalPlanned = rows.reduce((a, r) => a + (r.planned || 0), 0);
    const totalCompleted = rows.reduce((a, r) => a + (r.completed || 0), 0);
    const overallPct =
      totalPlanned > 0 ? Math.round((totalCompleted / totalPlanned) * 100) : 0;

    // 최근 3개월 월별 추세
    const monthly = await query(
      `SELECT to_char(date_trunc('month', d), 'YYYY-MM') AS month,
              SUM(planned) AS planned,
              SUM(completed) AS completed,
              CASE WHEN SUM(planned) > 0 THEN ROUND((SUM(completed)::numeric / SUM(planned)) * 100,0)
                   ELSE 0 END AS pct
       FROM (
         SELECT dd::date AS d, COALESCE(array_length(m.dosage_times,1),0) AS planned, 0 AS completed
         FROM medications m
         JOIN LATERAL generate_series(date_trunc('month', CURRENT_DATE) - interval '2 month', CURRENT_DATE, interval '1 day') dd ON dd BETWEEN m.start_date AND COALESCE(m.end_date, CURRENT_DATE)
         WHERE m.user_id = $1
         UNION ALL
         SELECT date_trunc('day', mi.intake_time)::date AS d, 0 AS planned, COUNT(*) FILTER (WHERE mi.is_taken = TRUE) AS completed
         FROM medication_intakes mi
         JOIN medications m ON m.id = mi.medication_id AND m.user_id = $1
         WHERE mi.intake_time >= date_trunc('month', CURRENT_DATE) - interval '2 month'
         GROUP BY 1
       ) s
       GROUP BY 1
       ORDER BY 1`,
      [userId]
    );

    const months = monthly.rows as Array<{
      month: string;
      planned: number;
      completed: number;
      pct: number;
    }>;

    // 간단한 인사이트 문구 생성
    let message = "최근 3개월 복용률 추세를 확인하세요.";
    if (months.length >= 2) {
      const first = months[0]?.pct || 0;
      const last = months[months.length - 1]?.pct || 0;
      const diff = last - first;
      if (diff > 0) message = `최근 3개월 약 복용률이 ${diff}% 올랐습니다.`;
      else if (diff < 0)
        message = `최근 3개월 약 복용률이 ${Math.abs(diff)}% 감소했습니다.`;
      else message = `최근 3개월 약 복용률에 변화가 없습니다.`;
    }

    const tips: string[] = [];
    if (overallPct < 60)
      tips.push("복용 알림 시간을 생활 패턴에 맞게 조정해 보세요.");
    if (months.some((m) => m.pct < 50))
      tips.push("자주 놓치는 시간대를 집중 관리하세요.");
    tips.push("이상 반응이 있으면 즉시 복용을 중단하고 전문가와 상담하세요.");

    return res.json({ overallPct, months, message, tips });
  } catch (error) {
    console.error("Get health insights error:", error);
    return res
      .status(500)
      .json({ error: "건강 인사이트 조회 중 오류가 발생했습니다" });
  }
};
