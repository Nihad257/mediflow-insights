USE mediflow_hospital;

DROP TABLE IF EXISTS fact_transfers;
DROP TABLE IF EXISTS fact_admissions;
DROP TABLE IF EXISTS dim_bed;
DROP TABLE IF EXISTS dim_department;
DROP TABLE IF EXISTS dim_discharge_destination;
DROP TABLE IF EXISTS dim_patient;
DROP TABLE IF EXISTS dim_date;

CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    date DATE NOT NULL,
    year SMALLINT,
    month TINYINT,
    month_name VARCHAR(10),
    day_of_week TINYINT,
    is_weekend TINYINT,
    quarter TINYINT,
    season VARCHAR(10)
);

CREATE TABLE dim_patient (
    patient_id INT PRIMARY KEY,
    date_of_birth DATE,
    gender CHAR(1),
    zip_code VARCHAR(3)
);

CREATE TABLE dim_department (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    type VARCHAR(20)
);

CREATE TABLE dim_discharge_destination (
    destination_id INT PRIMARY KEY,
    destination_name VARCHAR(50) NOT NULL
);

CREATE TABLE dim_bed (
    bed_id INT PRIMARY KEY,
    department_id INT,
    bed_type VARCHAR(20),
    is_occupied TINYINT,
    FOREIGN KEY (department_id) REFERENCES dim_department(department_id)
);

INSERT INTO dim_date
SELECT DISTINCT * FROM stg_dim_date;

INSERT INTO dim_patient
SELECT DISTINCT * FROM stg_dim_patient;

INSERT INTO dim_department
SELECT DISTINCT * FROM stg_dim_department;

INSERT INTO dim_discharge_destination
SELECT DISTINCT * FROM stg_dim_discharge_destination;

INSERT INTO dim_bed
SELECT DISTINCT * FROM stg_dim_bed;

CREATE TABLE fact_admissions (
    admission_id INT PRIMARY KEY,
    patient_id INT,
    admission_date_id INT,
    discharge_date_id INT,
    department_id INT,
    bed_id INT,
    admission_type VARCHAR(20),
    admission_datetime DATETIME,
    discharge_datetime DATETIME,
    triage_datetime DATETIME,
    bed_assigned_datetime DATETIME,
    discharge_ready_datetime DATETIME,
    total_charges DECIMAL(10,2),
    billing_datetime DATETIME,
    readmission_30_flag TINYINT,
    discharge_destination_id INT,
    FOREIGN KEY (patient_id) REFERENCES dim_patient(patient_id),
    FOREIGN KEY (admission_date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (discharge_date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (department_id) REFERENCES dim_department(department_id),
    FOREIGN KEY (bed_id) REFERENCES dim_bed(bed_id),
    FOREIGN KEY (discharge_destination_id) REFERENCES dim_discharge_destination(destination_id)
);

CREATE TABLE fact_transfers (
    transfer_id INT PRIMARY KEY,
    admission_id INT,
    from_bed_id INT,
    to_bed_id INT,
    transfer_datetime DATETIME,
    reason VARCHAR(50),
    FOREIGN KEY (admission_id) REFERENCES fact_admissions(admission_id),
    FOREIGN KEY (from_bed_id) REFERENCES dim_bed(bed_id),
    FOREIGN KEY (to_bed_id) REFERENCES dim_bed(bed_id)
);

-- Clean fact_admissions: remove duplicates (keep first), fix datetimes
INSERT INTO fact_admissions
WITH deduped AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY admission_id ORDER BY admission_datetime) AS rn
    FROM stg_fact_admissions
)
SELECT
    admission_id,
    patient_id,
    admission_date_id,
    discharge_date_id,
    department_id,
    bed_id,
    admission_type,
    STR_TO_DATE(NULLIF(admission_datetime, ''), '%Y-%m-%d %H:%i:%s') AS admission_datetime,
    STR_TO_DATE(NULLIF(discharge_datetime, ''), '%Y-%m-%d %H:%i:%s') AS discharge_datetime,
    STR_TO_DATE(NULLIF(triage_datetime, ''), '%Y-%m-%d %H:%i:%s') AS triage_datetime,
    STR_TO_DATE(NULLIF(bed_assigned_datetime, ''), '%Y-%m-%d %H:%i:%s') AS bed_assigned_datetime,
    STR_TO_DATE(NULLIF(discharge_ready_datetime, ''), '%Y-%m-%d %H:%i:%s') AS discharge_ready_datetime,
    total_charges,
    STR_TO_DATE(NULLIF(billing_datetime, ''), '%Y-%m-%d %H:%i:%s') AS billing_datetime,
    readmission_30_flag,
    discharge_destination_id
FROM deduped
WHERE rn = 1;

INSERT INTO fact_transfers
WITH deduped_transfers AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY transfer_id ORDER BY transfer_datetime) AS rn
    FROM stg_fact_transfers
)
SELECT
    transfer_id,
    admission_id,
    from_bed_id,
    to_bed_id,
    STR_TO_DATE(transfer_datetime, '%Y-%m-%d %H:%i:%s') AS transfer_datetime,
    reason
FROM deduped_transfers
WHERE rn = 1
  AND admission_id IN (SELECT admission_id FROM fact_admissions);
  
  
 SELECT COUNT(*) FROM dim_date;  
SELECT COUNT(*) FROM dim_patient;    
SELECT COUNT(*) FROM dim_department;
SELECT COUNT(*) FROM dim_bed;   
SELECT COUNT(*) FROM dim_discharge_destination; 
SELECT COUNT(*) FROM fact_admissions;      
SELECT COUNT(*) FROM fact_transfers;    