# 🏥 MediFlow Insights — Hospital Patient Flow & Discharge Delay Analytics

![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-blue?logo=power-bi)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange?logo=mysql)
![Python](https://img.shields.io/badge/Python-3.13-yellow?logo=python)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

An end‑to‑end analytics project that transforms synthetic hospital data into actionable operational insights using **MySQL** for data warehousing and **Power BI** for interactive dashboards.

---

## 🏥 Business Problem

Hospital managers lack a unified view of patient flow, discharge delays, and bed utilization. Data sits in silos — admissions, bed management, billing — with no way to see the full picture. This leads to overcrowding, long emergency wait times, delayed discharges, and suboptimal resource use.

## 💡 Solution

A star‑schema MySQL data warehouse combined with an interactive Power BI dashboard that tracks key operational KPIs, identifies bottlenecks, and supports data‑driven decision‑making by hospital operations managers.

---

## 📊 Dashboard Pages

| Page | What It Shows |
|------|---------------|
| **Executive Overview** | Total admissions, discharges, current inpatients, average length of stay, bed occupancy rate, admissions trend, department breakdown |
| **Patient Flow** | Occupied beds by department, daily admissions vs discharges comparison |
| **Discharge Delays** | Delay rate, delayed discharge count, breakdown by department and discharge destination |
| **Financial** | Total charges, charges by department, revenue vs length of stay summary |

---

## 📈 Key KPIs

- **Total Admissions:** 5,000
- **Average ER Wait Time:** 82.8 minutes
- **Discharge Delay Rate:** 11.9% (583 delayed discharges)
- **Average Length of Stay:** 5.57 days
- **Bed Occupancy Rate:** 26% (snapshot)
- **Readmission Rate:** ~7%

---

## ⚙️ Tech Stack

- **MySQL 8.0** — Data warehouse (star schema: 5 dimension tables, 2 fact tables)
- **Power BI Desktop** — DAX measures, interactive dashboard, data modeling
- **Python 3.13** — Synthetic data generation (pandas, numpy)
- **Git & GitHub** — Version control and portfolio

---

## 📁 Repository Structure

MediFlow-Insights/
├── data/raw/ # 7 synthetic CSV files
├── sql/
│ ├── 02_etl_load.sql # Database setup + ETL (star schema creation)
│ ├── 03_queries.sql # Beginner SQL queries
│ ├── 04_queries.sql # Intermediate SQL queries
│ └── 05_queries.sql # Advanced SQL queries (CTEs, window functions)
├── powerbi/
│ └── MediFlow-Dashboard.pbix # Power BI dashboard file
├── generate_data.py # Python script to generate synthetic data
├── .gitignore
├── LICENSE
└── README.md


---

## 🚀 How to Run This Project

### 1. Generate the data
```bash
python generate_data.py

This creates 7 CSV files in data/raw/.


---

### Fix 2: Populate LICENSE

Open `LICENSE`, delete everything, paste: