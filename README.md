# 🏥 MediFlow Insights — Hospital Patient Flow & Discharge Delay Analytics

![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-blue?logo=power-bi)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange?logo=mysql)
![Python](https://img.shields.io/badge/Python-3.13-yellow?logo=python)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

An end-to-end healthcare analytics project that transforms synthetic hospital data into actionable operational insights using **MySQL** for data warehousing and **Power BI** for interactive dashboards.

---

## 🏥 Business Problem

Hospital managers often lack a unified view of:

- Patient admissions and discharges
- Bed utilization across departments
- Discharge delays
- Operational bottlenecks

Data exists in silos (admissions, bed management, billing), making it difficult to monitor hospital flow efficiently. This leads to overcrowding, long emergency wait times, delayed discharges, and suboptimal resource use.

---

## 💡 Solution

This project builds a **star-schema MySQL data warehouse** and connects it to a **Power BI dashboard** to monitor key hospital operational KPIs and identify bottlenecks in patient flow and discharge processes.

---

## 📊 Dashboard Pages

| Page | What It Shows |
|------|---------------|
| **Executive Overview** | Total admissions, discharges, current inpatients, ALOS, bed occupancy rate, admissions trend |
| **Patient Flow** | Occupied beds by department, daily admissions vs discharges |
| **Discharge Delays** | Delay rate, delayed discharge count, department-wise breakdown |
| **Financial Overview** | Charges by department, revenue vs length of stay |

---

## 📈 Key KPIs Observed

- **Total Admissions:** 5,000
- **Average ER Wait Time:** 82 minutes
- **Discharge Delay Rate:** 11.9% (583 delayed discharges)
- **Average Length of Stay:** 5.57 days
- **Bed Occupancy Rate:** 26% (snapshot)
- **Readmission Rate:** 11%

---

## ⚙️ Tech Stack

| Tool | Purpose |
|-----|---------|
| **MySQL 8.0** | Star schema data warehouse (ETL + queries) |
| **Power BI Desktop** | Data modeling, DAX measures, interactive dashboard |
| **Python (pandas, numpy)** | Synthetic hospital data generation |
| **Git & GitHub** | Version control and portfolio |

---

## 🗂️ Star Schema Design

- **Fact Tables:** Admissions, Billing
- **Dimension Tables:** Patients, Beds, Departments, Dates, Diagnosis

This structure enables efficient analytical queries and dashboard performance.

---

## 📁 Repository Structure

```
mediflow-insights/
├── data/raw/                  # Synthetic CSV data files
├── sql/
│   ├── 02_etl_load.sql       # Database setup and ETL
│   ├── 03_queries.sql        # Basic SQL queries
│   ├── 04_queries.sql        # Intermediate SQL queries
│   └── 05_queries.sql        # Advanced SQL queries
├── powerbi/
│   └── MediFlow-Dashboard.pbix
├── generate_data.py          # Python script to generate data
├── .gitignore
├── LICENSE
└── README.md
```

---

## 🚀 How to Run This Project

### Step 1 — Generate Synthetic Data

```bash
python generate_data.py
```

This creates CSV files inside `data/raw/`.

---

### Step 2 — Create Database & Load Data (MySQL)

Open MySQL and run:

```sql
source sql/02_etl_load.sql;
```

---

### Step 3 — Explore SQL Queries

Run:

- `03_queries.sql` — Basic analysis
- `04_queries.sql` — Intermediate joins & aggregations
- `05_queries.sql` — Advanced KPIs

---

### Step 4 — Open Power BI Dashboard

Open:

```
powerbi/MediFlow-Dashboard.pbix
```

Refresh the data connection if needed.

---

## 🎯 What This Project Demonstrates

- Data warehousing using star schema
- Writing analytical SQL queries (joins, aggregations, KPIs)
- Building professional Power BI dashboards with DAX
- Understanding hospital operational metrics
- End-to-end analytics workflow from data generation → ETL → visualization

---

## 📌 Future Improvements

- Use a real hospital dataset
- Deploy dashboard to Power BI Service
- Add automated ETL pipeline
- Add data dictionary documentation

---

## 📜 License

This project is licensed under the MIT License.
