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
    
    // 성실도에 따른 맞춤 권장사항
    if (overallPct < 60) {
      tips.push("📊 복용 패턴 분석: 현재 복용률이 낮은 상태입니다. 어떤 시간대나 요일에 가장 많이 놓치는지 확인하고, 해당 시간대에 약을 미리 준비해 두거나 복용 여부를 체크하는 습관을 만들어 보세요.");
      tips.push("💊 복약 시간 최적화: 식사와 연계하여 복용하거나 특정 일정(예: 아침 식사 후, 저녁 취침 전)과 결합하면 복약을 놓치는 빈도를 줄일 수 있습니다. 일주일 동안 가장 성공적인 복용 시간대를 찾아 고정해 보세요.");
      tips.push("📈 목표 설정: 일주일 단위로 복용 목표를 설정하고, 달성 시 작은 보상을 주는 방식으로 동기부여를 높여보세요. 예를 들어 주 5회 이상 달성 시 자신에게 작은 선물을 주는 것도 효과적입니다.");
    } else if (overallPct < 75) {
      tips.push("🔄 일관성 유지: 현재 복용률을 유지하면서도 놓치는 경우를 줄이기 위해 복약 시간을 생활 패턴과 더욱 밀접하게 연계시켜 보세요. 특히 주말이나 특별한 일정이 있을 때도 복용 시간을 유지하는 것이 중요합니다.");
      tips.push("📦 약물 관리: 약을 잘 보이는 곳에 두거나, 휴대용 약통을 활용하여 외출 시에도 약을 놓치지 않도록 준비하세요. 특히 아침에 외출하는 경우 전날 밤에 약통을 준비해 두는 습관을 권장합니다.");
    } else {
      tips.push("✅ 우수한 복약 습관: 현재 우수한 복약 습관을 계속 유지하시기 바랍니다. 복용 기록을 꾸준히 남기시면 건강 상태 추이를 더 정확히 파악할 수 있으며, 의료진과의 상담 시에도 유용한 자료가 됩니다.");
    }
    
    // 월별 패턴 분석 기반 권장사항
    if (months.some((m) => m.pct < 50)) {
      const lowMonths = months.filter((m) => m.pct < 50);
      const monthNames = lowMonths.map((m) => {
        const parts = m.month.split("-");
        return `${parseInt(parts[1])}월`;
      }).join(", ");
      tips.push(`📅 월별 패턴 분석: ${monthNames}에 복용률이 낮았던 것으로 나타났습니다. 해당 기간의 생활 패턴이나 특별한 일정을 확인하고, 다음번에는 미리 대비하는 방법을 고려해 보세요.`);
    }
    
    // 복용률 기반 구체적 권장사항
    if (totalPlanned > 0) {
      const missedCount = totalPlanned - totalCompleted;
      const missedPct = Math.round((missedCount / totalPlanned) * 100);
      if (missedPct > 20) {
        tips.push(`⚠️ 놓친 복용 관리: 최근 ${missedCount}회의 복용을 놓치셨습니다. 약의 효과를 제대로 발휘하려면 처방대로 꾸준히 복용하는 것이 중요합니다. 복용을 놓쳤을 때는 다음 복용 시간에 두 배를 복용하지 말고, 의사나 약사와 상담하세요.`);
      }
    }
    
    // 공통 권장사항
    tips.push("🏥 의료진 상담: 약 복용 중 이상 반응이나 부작용이 발생하면 즉시 복용을 중단하고 의사나 약사와 상담하세요. 복약 기록을 의료진에게 보여주면 더 정확한 진단과 치료가 가능합니다.");
    tips.push("📋 건강 관리: 정기적으로 건강 인사이트를 확인하여 자신의 복약 패턴을 파악하고, 지속적으로 개선해 나가시기 바랍니다. 복약 성실도가 낮을수록 치료 효과가 떨어질 수 있으므로, 꾸준한 관리가 필요합니다.");

    return res.json({ overallPct, months, message, tips });
  } catch (error) {
    console.error("Get health insights error:", error);
    return res
      .status(500)
      .json({ error: "건강 인사이트 조회 중 오류가 발생했습니다" });
  }
};
