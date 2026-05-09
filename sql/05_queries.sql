
SELECT dd.year, dd.month, dd.month_name, COUNT(f.admission_id) AS admissions
FROM fact_admissions f
JOIN dim_date dd ON f.admission_date_id = dd.date_id
GROUP BY dd.year, dd.month, dd.month_name
ORDER BY dd.year, dd.month;

WITH monthly AS (
    SELECT dd.year, dd.month, dd.month_name, COUNT(f.admission_id) AS adm_count
    FROM fact_admissions f
    JOIN dim_date dd ON f.admission_date_id = dd.date_id
    GROUP BY dd.year, dd.month, dd.month_name
)
SELECT year, month_name, adm_count,
       SUM(adm_count) OVER (ORDER BY year, month) AS cumulative_admissions
FROM monthly
ORDER BY year, month;

WITH daily AS (
    SELECT dd.date, COUNT(f.admission_id) AS daily_adm
    FROM fact_admissions f
    JOIN dim_date dd ON f.admission_date_id = dd.date_id
    GROUP BY dd.date
)
SELECT date, daily_adm,
       ROUND(AVG(daily_adm) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 1) AS ma_7d
FROM daily
ORDER BY date;

SELECT d.department_name, 
       COUNT(DISTINCT f.bed_id) AS occupied_beds,
       b.total_beds,
       ROUND(100.0 * COUNT(DISTINCT f.bed_id) / b.total_beds, 2) AS occupancy_pct
FROM fact_admissions f
JOIN dim_department d ON f.department_id = d.department_id
JOIN (
    SELECT department_id, COUNT(*) AS total_beds
    FROM dim_bed
    GROUP BY department_id
) b ON d.department_id = b.department_id
WHERE f.discharge_datetime > '2025-12-15'  -- simulated snapshot date
GROUP BY d.department_id, d.department_name, b.total_beds
ORDER BY occupancy_pct DESC;

SELECT f.admission_id, f.patient_id, 
       TIMESTAMPDIFF(MINUTE, f.triage_datetime, f.bed_assigned_datetime) AS er_wait_minutes,
       f.admission_datetime
FROM fact_admissions f
JOIN dim_department d ON f.department_id = d.department_id
WHERE d.department_name = 'Emergency'
  AND f.triage_datetime IS NOT NULL
  AND f.bed_assigned_datetime IS NOT NULL
ORDER BY er_wait_minutes DESC
LIMIT 10;

SELECT 
    COUNT(*) AS total_stays,
    SUM(f.readmission_30_flag) AS readmissions,
    ROUND(100.0 * SUM(f.readmission_30_flag) / COUNT(*), 2) AS readmission_rate_pct
FROM fact_admissions f;

WITH delay_stats AS (
    SELECT d.department_name,
           COUNT(*) AS total_discharges,
           SUM(CASE WHEN f.discharge_ready_datetime IS NOT NULL 
                     AND TIMESTAMPDIFF(HOUR, f.discharge_ready_datetime, f.discharge_datetime) > 24 
                    THEN 1 ELSE 0 END) AS delayed_count
    FROM fact_admissions f
    JOIN dim_department d ON f.department_id = d.department_id
    WHERE f.discharge_ready_datetime IS NOT NULL
    GROUP BY d.department_name
)
SELECT department_name,
       total_discharges,
       delayed_count,
       ROUND(100.0 * delayed_count / total_discharges, 2) AS delay_rate_pct,
       RANK() OVER (ORDER BY delayed_count DESC) AS delay_rank
FROM delay_stats
ORDER BY delay_rank;