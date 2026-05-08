-- ====================================================
-- UPDATE READMISSION FLAGS
-- A readmission = admitted within 30 days of last discharge
-- ====================================================
WITH ReadmitCTE AS (
    SELECT
        hadm_id,
        CASE
            WHEN DATEDIFF(DAY,
                LAG(dischtime) OVER (PARTITION BY subject_id ORDER BY admittime),
                admittime
            ) <= 30
            AND ROW_NUMBER() OVER (PARTITION BY subject_id ORDER BY admittime) > 1
            THEN 1 ELSE 0
        END AS is_readmission,
        DATEDIFF(DAY,
            LAG(dischtime) OVER (PARTITION BY subject_id ORDER BY admittime),
            admittime
        ) AS days_to_readmit
    FROM admissions
    WHERE dischtime IS NOT NULL
)
UPDATE f
SET
    f.is_readmission  = r.is_readmission,
    f.days_to_readmit = r.days_to_readmit
FROM fact_patient_admissions f
JOIN ReadmitCTE r ON f.hadm_id = r.hadm_id;
 
-- Verify the update
SELECT
    SUM(CAST(is_readmission AS INT)) AS total_readmissions,
    COUNT(*)            AS total_admissions,
    ROUND(AVG(CAST(is_readmission AS FLOAT))*100, 2) AS readmission_pct
FROM fact_patient_admissions;