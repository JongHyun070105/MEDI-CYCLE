import { Request, Response } from "express";
import { query } from "../database/db.js";

export const getHealthInsights = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    if (!userId) return res.status(401).json({ error: "인증이 필요합니다" });

    // 최근 90일 계획/완료 집계
    const result = await query(
      `WITH date_range AS (
         SELECT CURRENT_DATE - interval '90 day' AS start_date,
                CURRENT_DATE AS end_date
       ),
       days AS (
         SELECT dd::date AS d
         FROM generate_series(
           (SELECT start_date FROM date_range), 
           (SELECT end_date FROM date_range), 
           interval '1 day'
         ) dd
       ),
       plans AS (
         SELECT dd::date AS d, COALESCE(array_length(m.dosage_times,1),0) AS planned
         FROM medications m
         CROSS JOIN date_range dr
         JOIN LATERAL generate_series(
           GREATEST(m.start_date::date, dr.start_date::date),
           LEAST(COALESCE(m.end_date::date, dr.end_date::date), dr.end_date::date),
           interval '1 day'
         ) dd ON TRUE
         WHERE m.user_id = $1
           AND m.start_date::date <= dr.end_date::date
           AND COALESCE(m.end_date::date, dr.end_date::date) >= dr.start_date::date
       ),
       takes AS (
         SELECT date_trunc('day', mi.intake_time)::date AS d,
                COUNT(*) FILTER (WHERE mi.is_taken = TRUE) AS completed
         FROM medication_intakes mi
         JOIN medications m ON m.id = mi.medication_id AND m.user_id = $1
         WHERE mi.intake_time >= CURRENT_DATE - interval '90 day'
           AND mi.intake_time <= CURRENT_DATE
         GROUP BY 1
       )
       SELECT d.d,
              COALESCE((SELECT SUM(planned)::integer FROM plans p WHERE p.d = d.d),0)::integer AS planned,
              COALESCE((SELECT completed::integer FROM takes t WHERE t.d = d.d),0)::integer AS completed
       FROM days d
       ORDER BY d.d`,
      [userId]
    );

    const rows = result.rows as Array<{
      d: string;
      planned: number;
      completed: number;
    }>;
    
    // 안전한 숫자 변환 및 합산
    const totalPlanned = rows.reduce((a, r) => {
      const planned = Number(r.planned) || 0;
      return a + (isFinite(planned) ? planned : 0);
    }, 0);
    
    const totalCompleted = rows.reduce((a, r) => {
      const completed = Number(r.completed) || 0;
      return a + (isFinite(completed) ? completed : 0);
    }, 0);
    
    const overallPct =
      totalPlanned > 0 ? Math.round((totalCompleted / totalPlanned) * 100) : 0;
    
    // 디버깅 로그
    console.log(`📊 인사이트 계산 (사용자 ${userId}):`);
    console.log(`   총 계획: ${totalPlanned}회`);
    console.log(`   총 완료: ${totalCompleted}회`);
    console.log(`   복용률: ${overallPct}%`);

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

    // 상세한 AI 인사이트 생성
    let message = "";
    
    // 전체 성실도 평가
    if (overallPct >= 90) {
      message = `최근 90일 동안 약 복용 성실도가 ${overallPct}%로 매우 우수합니다. 꾸준한 복약 습관을 유지하고 계시네요. 이렇게 일관된 복약이 치료 효과를 높이는 데 중요한 역할을 합니다.`;
    } else if (overallPct >= 75) {
      message = `최근 90일 동안 약 복용 성실도가 ${overallPct}%로 양호한 편입니다. 대부분의 약을 규칙적으로 복용하고 계시지만, 놓치는 경우가 종종 있습니다. 복약 습관을 더욱 개선하면 치료 효과를 극대화할 수 있습니다.`;
    } else if (overallPct >= 60) {
      message = `최근 90일 동안 약 복용 성실도가 ${overallPct}%로 보통 수준입니다. 약을 자주 놓치지 않도록 주의가 필요합니다. 규칙적인 복약이 치료의 핵심이므로, 알림 설정이나 일정 관리 방법을 개선해 보시기 바랍니다.`;
    } else {
      message = `최근 90일 동안 약 복용 성실도가 ${overallPct}%로 개선이 필요합니다. 복약을 자주 놓치시는 것 같습니다. 약의 효과를 제대로 발휘하려면 처방대로 꾸준히 복용하는 것이 중요합니다. 아래 권장사항을 참고하여 복약 습관을 개선해 보시기 바랍니다.`;
    }
    
    // 월별 추세 분석 추가
    if (months.length >= 2) {
      const first = months[0]?.pct || 0;
      const last = months[months.length - 1]?.pct || 0;
      const diff = last - first;
      
      if (diff > 10) {
        message += ` 특히 최근 3개월 동안 복용률이 ${diff}% 증가하여 개선 추세를 보이고 있습니다. 이는 매우 긍정적인 신호입니다.`;
      } else if (diff > 0) {
        message += ` 최근 3개월 동안 복용률이 ${diff}% 소폭 증가하여 약간의 개선이 있었습니다.`;
      } else if (diff < -10) {
        message += ` 다만 최근 3개월 동안 복용률이 ${Math.abs(diff)}% 감소하여 주의가 필요합니다. 복약 습관 점검을 권장합니다.`;
      } else if (diff < 0) {
        message += ` 최근 3개월 동안 복용률이 ${Math.abs(diff)}% 소폭 감소했습니다. 일정한 복약 습관을 유지하도록 노력해 주세요.`;
      }
    }
    
    // 월별 데이터 분석
    const lowMonths = months.filter((m) => m.pct < 60);
    if (lowMonths.length > 0) {
      const monthNames = lowMonths.map((m) => {
        const parts = m.month.split("-");
        return `${parts[0]}년 ${parseInt(parts[1])}월`;
      }).join(", ");
      message += ` 특히 ${monthNames}에 복용률이 낮았던 것으로 나타났습니다.`;
    }

    const tips: string[] = [];
    
    // 성실도에 따른 맞춤 권장사항 (핵심만)
    if (overallPct < 60) {
      tips.push("📊 복용 패턴 분석: 어떤 시간대에 약을 자주 놓치는지 확인하고, 해당 시간에 알림을 설정하거나 약을 미리 준비해 두세요.");
      tips.push("💊 복약 시간 개선: 식사 시간이나 취침 전 등 매일 반복되는 일정과 복약 시간을 연결하면 잊지 않고 복용할 수 있습니다.");
    } else if (overallPct < 75) {
      tips.push("🔄 일관성 유지: 주말이나 외출 시에도 복약 시간을 지킬 수 있도록 휴대용 약통을 준비하세요.");
      tips.push("📦 약물 관리: 약을 눈에 잘 띄는 곳에 두어 깜빡하지 않도록 하세요.");
    } else if (overallPct >= 90) {
      tips.push("✅ 우수한 복약 습관: 현재의 우수한 복약 습관을 계속 유지하시기 바랍니다.");
    }
    
    // 복용을 많이 놓친 경우에만 경고
    if (totalPlanned > 0 && isFinite(totalPlanned) && isFinite(totalCompleted)) {
      const missedCount = Math.max(0, totalPlanned - totalCompleted);
      const missedPct = Math.round((missedCount / totalPlanned) * 100);
      
      if (isFinite(missedCount) && missedCount > 0 && missedCount < 10000 && missedPct > 30) {
        tips.push(`⚠️ 놓친 복용: 최근 ${missedCount}회를 놓치셨습니다. 복용을 놓쳤을 때는 다음 시간에 두 배로 드시지 말고 의사나 약사와 상담하세요.`);
      }
    }

    return res.json({ overallPct, months, message, tips });
  } catch (error) {
    console.error("Get health insights error:", error);
    return res
      .status(500)
      .json({ error: "건강 인사이트 조회 중 오류가 발생했습니다" });
  }
};
