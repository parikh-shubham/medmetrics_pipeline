-- ====================================================
-- SP 1: Overall KPI Summary
-- ====================================================
CREATE OR ALTER PROCEDURE sp_KPI_Summary
AS BEGIN
    SELECT
        COUNT(DISTINCT subject_id)                     AS total_patients,
        COUNT(*)                                       AS total_admissions,
        ROUND(AVG(los_days), 2)                       AS avg_los_days,
        ROUND(AVG(CAST(is_icu_admission AS FLOAT))*100, 2) AS icu_admission_pct,
        ROUND(AVG(CAST(hospital_expire_flag AS FLOAT))*100, 2) AS in_hospital_mortality_pct,
        ROUND(AVG(CAST(is_readmission AS FLOAT))*100, 2) AS readmission_rate_pct,
        ROUND(AVG(CAST(is_emergency AS FLOAT))*100, 2) AS emergency_admission_pct,
        AVG(diagnosis_count)                           AS avg_diagnoses_per_admit,
        AVG(lab_test_count)                            AS avg_labs_per_admit
    FROM fact_patient_admissions;
END;
GO
 
-- ====================================================
-- SP 2: Readmission Rate by Insurance
-- ====================================================
CREATE OR ALTER PROCEDURE usp_Readmission_By_Insurance
AS 
BEGIN
    SET NOCOUNT ON;

    SELECT
        insurance,
        COUNT(*)                                           AS total_admissions,
        SUM(CAST(is_readmission AS INT))                   AS readmissions,
        ROUND(AVG(CAST(is_readmission AS FLOAT)) * 100, 2) AS readmission_rate_pct,
        ROUND(AVG(CAST(los_days AS FLOAT)), 2)             AS avg_los_days
    FROM fact_patient_admissions
    GROUP BY insurance
    ORDER BY readmission_rate_pct DESC;
END;
GO
-- ====================================================
-- SP 3: LOS by Age Group
-- ====================================================
CREATE OR ALTER PROCEDURE sp_LOS_By_AgeGroup
AS BEGIN
    SELECT
        p.age_group,
        COUNT(f.hadm_id)           AS admissions,
        ROUND(AVG(f.los_days), 2)  AS avg_los_days,
        ROUND(MIN(f.los_days), 2)  AS min_los_days,
        ROUND(MAX(f.los_days), 2)  AS max_los_days,
        ROUND(STDEV(f.los_days), 2) AS stdev_los
    FROM fact_patient_admissions f
    JOIN dim_patient p ON f.patient_key = p.patient_key
    GROUP BY p.age_group
    ORDER BY p.age_group;
END;
GO
 
-- ====================================================
-- SP 4: Disease Category Analysis
-- ====================================================
CREATE OR ALTER PROCEDURE sp_Disease_Category_Analysis
AS BEGIN
    SELECT
        dd.disease_category,
        COUNT(DISTINCT d.hadm_id)                 AS admissions_affected,
        COUNT(*)                                   AS total_diagnoses,
        ROUND(AVG(f.los_days), 2)                 AS avg_los_days,
        ROUND(AVG(CAST(f.hospital_expire_flag AS FLOAT))*100, 2) AS mortality_pct
    FROM diagnoses_icd d
    JOIN dim_diagnosis dd ON d.icd_code = dd.icd_code AND d.icd_version = dd.icd_version
    JOIN fact_patient_admissions f ON d.hadm_id = f.hadm_id
    GROUP BY dd.disease_category
    ORDER BY admissions_affected DESC;
END;
GO
 
-- ====================================================
-- SP 5: Monthly Admission Trends
-- ====================================================
CREATE OR ALTER PROCEDURE sp_Monthly_Trends
AS BEGIN
    SELECT
        dd.year,
        dd.month,
        dd.month_name,
        COUNT(f.hadm_id)                           AS admissions,
        ROUND(AVG(f.los_days), 2)                 AS avg_los_days,
        SUM(f.hospital_expire_flag)                AS deaths,
        ROUND(AVG(CAST(f.is_emergency AS FLOAT))*100, 2) AS emergency_pct
    FROM fact_patient_admissions f
    JOIN dim_date dd ON f.admit_date_key = dd.date_key
    GROUP BY dd.year, dd.month, dd.month_name
    ORDER BY dd.year, dd.month;
END;
GO
 
-- ====================================================
-- RUN ALL STORED PROCEDURES TO TEST
-- ====================================================
EXEC sp_KPI_Summary;
EXEC usp_Readmission_By_Insurance;
EXEC sp_LOS_By_AgeGroup;
EXEC sp_Disease_Category_Analysis;
EXEC sp_Monthly_Trends;