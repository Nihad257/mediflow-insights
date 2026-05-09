
SELECT COUNT(*) AS total_admissions FROM fact_admissions;

SELECT d.department_name, COUNT(*) AS total_admissions
FROM fact_admissions f
JOIN dim_department d ON f.department_id = d.department_id
GROUP BY d.department_name
ORDER BY total_admissions DESC;