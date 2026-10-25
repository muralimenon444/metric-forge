# Databricks notebook source
# Synthetic, fictional source data for metric-forge.
# Writes three Epic-style CSV feeds to the raw volume. Safe to re-run (overwrites).
# Planted data problems are intentional so the pipeline has something to catch.

BASE = "/Volumes/workspace/metric_forge/raw"

FILES = {
    "patients": """pat_id,mrn,sex,birth_year,zip3
P001,MRN100001,F,1961,750
P002,MRN100002,M,1984,752
P003,MRN100003,F,1999,750
P004,MRN1000X4,M,1975,752
P005,MRN100005,F,1948,750
P001,MRN100001,F,1961,750
""",
    "encounters": """csn,pat_id,dept_code,enc_type,admit_ts,discharge_ts,attending_prov_id
900001,P001,ED,Emergency,2026-10-01 08:14:00,2026-10-01 14:02:00,PR10
900002,P002,MED-4W,Inpatient,2026-10-01 11:30:00,2026-10-05 10:15:00,PR22
900003,P003,ED,Emergency,2026-10-02 22:40:00,2026-10-03 01:10:00,PR10
900004,P004,ICU,Inpatient,2026-10-02 06:00:00,2026-10-01 18:00:00,PR31
900005,P005,SURG-2,Surgical,2026-10-03 07:30:00,2026-10-03 16:45:00,
900006,P001,MED-4W,Inpatient,2026-10-10 09:00:00,2026-10-12 12:00:00,PR22
""",
    "lab_results": """result_id,csn,test_code,test_name,result_value,unit,ref_low,ref_high,result_ts
1,900001,2160-0,Creatinine,1.1,mg/dL,0.7,1.3,2026-10-01 09:10:00
2,900002,2951-2,Sodium,131,mmol/L,135,145,2026-10-01 12:00:00
3,900002,718-7,Hemoglobin,,g/dL,12.0,16.0,2026-10-02 06:00:00
4,900003,6690-2,WBC,11.8,10*3/uL,4.0,11.0,2026-10-02 23:30:00
5,900006,2951-2,Sodium,138,mmol/L,135,145,2026-10-10 10:00:00
6,900002,2160-0,Creatinine,2.4,mg/dL,0.7,1.3,2026-10-03 06:00:00
7,900005,2160-0,Creatinine,110,umol/L,0.7,1.3,2026-10-03 09:00:00
""",
}

import os

for feed, content in FILES.items():
    folder = f"{BASE}/{feed}"
    os.makedirs(folder, exist_ok=True)  # creates the feed folder inside the raw volume
    with open(f"{folder}/{feed}.csv", "w") as f:
        f.write(content)
    print(f"Wrote {folder}/{feed}.csv")
