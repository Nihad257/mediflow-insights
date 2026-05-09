
SELECT d.department_name, 
       ROUND(AVG(DATEDIFF(f.discharge_datetime, f.admission_datetime)), 1) AS avg_los_days
FROM fact_admissions f
JOIN dim_department d ON f.department_id = d.department_id
GROUP BY d.department_name
ORDER BY avg_los_days DESC;

SELECT ROUND(AVG(TIMESTAMPDIFF(MINUTE, triage_datetime, bed_assigned_datetime)), 1) AS avg_er_wait_min
FROM fact_admissions f
JOIN dim_department d ON f.department_id = d.department_id
WHERE d.department_name = 'Emergency'
  AND triage_datetime IS NOT NULL
  AND bed_assigned_datetime IS NOT NULL;
  
SELECT 
    COUNT(*) AS total_discharges,
    SUM(CASE WHEN discharge_ready_datetime IS NOT NULL 
              AND TIMESTAMPDIFF(HOUR, discharge_ready_datetime, discharge_datetime) > 24 
             THEN 1 ELSE 0 END) AS delayed_count,
    ROUND(100.0 * SUM(CASE WHEN discharge_ready_datetime IS NOT NULL 
                             AND TIMESTAMPDIFF(HOUR, discharge_ready_datetime, discharge_datetime) > 24 
                            THEN 1 ELSE 0 END) / COUNT(*), 2) AS delay_pct
FROM fact_admissions
WHERE discharge_ready_datetime IS NOT NULL;