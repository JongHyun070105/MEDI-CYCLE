WITH date_range AS (
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
  WHERE m.user_id = 18
    AND m.start_date::date <= dr.end_date::date
    AND COALESCE(m.end_date::date, dr.end_date::date) >= dr.start_date::date
),
takes AS (
  SELECT date_trunc('day', mi.intake_time)::date AS d,
         COUNT(*) FILTER (WHERE mi.is_taken = TRUE) AS completed
  FROM medication_intakes mi
  JOIN medications m ON m.id = mi.medication_id AND m.user_id = 18
  WHERE mi.intake_time >= CURRENT_DATE - interval '90 day'
    AND mi.intake_time <= CURRENT_DATE
  GROUP BY 1
)
SELECT 
  COUNT(d.d) as total_days,
  SUM(COALESCE((SELECT SUM(planned)::integer FROM plans p WHERE p.d = d.d),0)) as total_planned,
  SUM(COALESCE((SELECT completed::integer FROM takes t WHERE t.d = d.d),0)) as total_completed
FROM days d;

