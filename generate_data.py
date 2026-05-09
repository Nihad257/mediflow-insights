"""
MediFlow Insights – Synthetic Data Generator
Generates realistic hospital operations data for MySQL + Power BI project.
Outputs: 7 CSV files into ./data/raw/
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random
import os

# ---- CONFIG ----
np.random.seed(42)
random.seed(42)
START_DATE = pd.Timestamp("2025-01-01")
END_DATE = pd.Timestamp("2025-12-31")
N_PATIENTS = 3000
N_ADMISSIONS = 5000
N_TRANSFERS = 6000

# Create output folder
os.makedirs("data/raw", exist_ok=True)

# ---- 1. dim_date ----
dates = pd.date_range(START_DATE, END_DATE + timedelta(days=30), freq='D')
dim_date = pd.DataFrame({
    'date_id': dates.strftime('%Y%m%d').astype(int),
    'date': dates,
    'year': dates.year,
    'month': dates.month,
    'month_name': dates.strftime('%B'),
    'day_of_week': dates.dayofweek + 1,
    'is_weekend': (dates.dayofweek >= 5).astype(int),
    'quarter': dates.quarter,
    'season': np.select(
        [dates.month.isin([12,1,2]),
         dates.month.isin([3,4,5]),
         dates.month.isin([6,7,8]),
         dates.month.isin([9,10,11])],
        ['Winter', 'Spring', 'Summer', 'Fall'],
        default=''
    )
})
dim_date.to_csv('data/raw/dim_date.csv', index=False)

# ---- 2. dim_patient ----
genders = ['M','F','O']
today = pd.Timestamp('2025-12-31')
patients = []
for pid in range(1, N_PATIENTS+1):
    dob = today - pd.DateOffset(days=random.randint(0, 100*365))
    gender = random.choice(genders)
    zip_code = f"{random.randint(100,999):03d}"
    patients.append((pid, dob, gender, zip_code))
dim_patient = pd.DataFrame(patients, columns=['patient_id','date_of_birth','gender','zip_code'])
dim_patient.to_csv('data/raw/dim_patient.csv', index=False)

# ---- 3. dim_department ----
departments = [
    ('Emergency', 'Emergency'),
    ('Cardiology', 'Inpatient'),
    ('Orthopedics', 'Inpatient'),
    ('Neurology', 'Inpatient'),
    ('General Surgery', 'Inpatient'),
    ('ICU', 'ICU'),
    ('Maternity', 'Inpatient'),
    ('Pediatrics', 'Inpatient'),
    ('Oncology', 'Inpatient'),
    ('Rehabilitation', 'Inpatient'),
]
dim_department = pd.DataFrame(departments, columns=['department_name','type'])
dim_department.insert(0, 'department_id', range(1, len(dim_department)+1))
dim_department.to_csv('data/raw/dim_department.csv', index=False)

# ---- 4. dim_bed ----
beds = []
bed_id = 1
for _, dept in dim_department.iterrows():
    dept_id = dept['department_id']
    dept_name = dept['department_name']
    if dept['type'] == 'ICU':
        n_beds = 12
        bed_type = 'ICU'
    elif dept_name == 'Emergency':
        n_beds = 25
        bed_type = 'ER'
    elif dept_name == 'Maternity':
        n_beds = 20
        bed_type = 'Maternity'
    elif dept_name == 'Pediatrics':
        n_beds = 20
        bed_type = 'Pediatric'
    else:
        n_beds = random.randint(20, 30)
        bed_type = 'General'
    for _ in range(n_beds):
        beds.append((bed_id, dept_id, bed_type))
        bed_id += 1
dim_bed = pd.DataFrame(beds, columns=['bed_id','department_id','bed_type'])
dim_bed['is_occupied'] = 0
dim_bed.to_csv('data/raw/dim_bed.csv', index=False)

# ---- 5. dim_discharge_destination ----
destinations = [
    ('Home',),
    ('Home with Home Health',),
    ('Skilled Nursing Facility',),
    ('Rehab Facility',),
    ('Another Hospital',),
    ('Deceased',),
    ('Against Medical Advice',)
]
dim_destination = pd.DataFrame(destinations, columns=['destination_name'])
dim_destination.insert(0, 'destination_id', range(1, len(dim_destination)+1))
dim_destination.to_csv('data/raw/dim_discharge_destination.csv', index=False)

# ---- Helper functions ----
def random_datetime(date, hour_range=(0,23)):
    h = random.randint(hour_range[0], hour_range[1])
    m = random.randint(0,59)
    s = random.randint(0,59)
    return pd.Timestamp(date) + pd.Timedelta(hours=h, minutes=m, seconds=s)

# ---- 6. fact_admissions ----
admissions = []
admission_id = 1
for _ in range(N_ADMISSIONS):
    pid = random.randint(1, N_PATIENTS)
    month = random.choices(
        [1,2,3,4,5,6,7,8,9,10,11,12],
        weights=[1.2, 1.2, 1.1, 1.0, 0.9, 0.8, 0.7, 0.8, 0.9, 1.0, 1.1, 1.1]
    )[0]
    day = random.randint(1, 28)
    adm_date = pd.Timestamp(year=2025, month=month, day=day)
    if adm_date.dayofweek >= 5 and random.random() < 0.3:
        adm_date += timedelta(days=random.choice([1,2]))
    adm_datetime = random_datetime(adm_date, hour_range=(8,20))
    triage_datetime = adm_datetime + timedelta(minutes=random.randint(5, 30))
    dept_id = random.choice(dim_department['department_id'])
    is_er = (dim_department[dim_department['department_id']==dept_id]['department_name'].values[0] == 'Emergency')
    if is_er:
        base_wait = random.randint(15, 120)
        if triage_datetime.hour < 8 or triage_datetime.hour > 18:
            base_wait += random.randint(30, 60)
        if triage_datetime.dayofweek >= 5:
            base_wait += random.randint(20, 40)
    else:
        base_wait = random.randint(10, 60)
    bed_assigned_datetime = triage_datetime + timedelta(minutes=base_wait)
    los_days = random.choices([1,2,3,4,5,6,7,8,9,10,11,14,21,30],
                              weights=[0.05,0.1,0.15,0.15,0.12,0.1,0.08,0.05,0.03,0.02,0.02,0.02,0.01,0.01])[0]
    los_hours = los_days * 24 + random.randint(-12, 12)
    discharge_datetime = bed_assigned_datetime + timedelta(hours=los_hours)
    if discharge_datetime.date() > END_DATE.date():
        discharge_datetime = pd.Timestamp(END_DATE.date()) + timedelta(hours=12)
    delay_chance = random.random()
    if delay_chance < 0.15:
        delay_hours = random.randint(12, 72)
        discharge_ready = discharge_datetime - timedelta(hours=delay_hours)
    else:
        discharge_ready = discharge_datetime
    if random.random() < 0.05:
        billing_dt = None
    else:
        billing_delay = random.randint(1,5)
        billing_dt = discharge_datetime + timedelta(days=billing_delay)
    daily_rate = 2000 if dept_id == 6 else 1500 if dept_id in [1,10] else 1200
    total_charges = round(daily_rate * los_days + random.uniform(-200,500), 2)
    if total_charges < 0:
        total_charges = 500.0
    available_beds = dim_bed[dim_bed['department_id']==dept_id]['bed_id'].tolist()
    bed = random.choice(available_beds)
    readmit = 0
    if los_days > 7 and random.random() < 0.15:
        readmit = 1
    elif delay_chance < 0.15 and random.random() < 0.1:
        readmit = 1
    elif random.random() < 0.07:
        readmit = 1
    dest_id = random.choices([1,2,3,4,5,6,7], weights=[0.5,0.1,0.15,0.1,0.05,0.02,0.08])[0]
    admissions.append((
        admission_id, pid,
        int(adm_datetime.strftime('%Y%m%d')),
        int(discharge_datetime.strftime('%Y%m%d')),
        dept_id, bed, 'Emergency' if is_er else random.choice(['Elective','Urgent']),
        adm_datetime, discharge_datetime, triage_datetime,
        bed_assigned_datetime, discharge_ready, total_charges,
        billing_dt, readmit, dest_id
    ))
    admission_id += 1

fact_admissions = pd.DataFrame(admissions, columns=[
    'admission_id', 'patient_id', 'admission_date_id', 'discharge_date_id',
    'department_id', 'bed_id', 'admission_type', 'admission_datetime',
    'discharge_datetime', 'triage_datetime', 'bed_assigned_datetime',
    'discharge_ready_datetime', 'total_charges', 'billing_datetime',
    'readmission_30_flag', 'discharge_destination_id'
])
null_idx = fact_admissions.sample(frac=0.02, random_state=42).index
fact_admissions.loc[null_idx, 'discharge_ready_datetime'] = pd.NaT
dupes = fact_admissions.sample(10, random_state=99)
fact_admissions = pd.concat([fact_admissions, dupes], ignore_index=True)
fact_admissions.to_csv('data/raw/fact_admissions.csv', index=False)

# ---- 7. fact_transfers ----
transfers = []
transfer_id = 1
for _, adm in fact_admissions.iterrows():
    if random.random() < 0.6:
        n_trans = random.choices([1,2,3], weights=[0.7,0.2,0.1])[0]
        current_bed = adm['bed_id']
        adm_dt = adm['admission_datetime']
        for _ in range(n_trans):
            trans_time = adm_dt + timedelta(hours=random.randint(2, max(2, int((adm['discharge_datetime'] - adm_dt).total_seconds()//3600)-2)))
            new_dept = random.choice(dim_department['department_id'])
            possible_beds = dim_bed[dim_bed['department_id']==new_dept]['bed_id'].tolist()
            new_bed = random.choice(possible_beds)
            reason = random.choice(['Clinical need','Patient request','Bed availability','Isolation'])
            transfers.append((transfer_id, adm['admission_id'], current_bed, new_bed, trans_time, reason))
            current_bed = new_bed
            transfer_id += 1

fact_transfers = pd.DataFrame(transfers, columns=[
    'transfer_id','admission_id','from_bed_id','to_bed_id','transfer_datetime','reason'
])
fact_transfers.to_csv('data/raw/fact_transfers.csv', index=False)

print("All CSV files generated in data/raw/")