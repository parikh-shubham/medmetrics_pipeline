-- ====================================================
-- RECURSIVE CTE: Full patient journey chain
-- ====================================================
WITH PatientJourneyBase AS (
    -- Anchor: first admission per patient
    SELECT
        subject_id,
        hadm_id,
        admittime,
        dischtime,
        admission_type,
        journey_step,
        journey_path
    FROM(
        SELECT
            a.subject_id,
            a.hadm_id,
            a.admittime,
            a.dischtime,
            a.admission_type,
            1 AS journey_step,
            CAST(a.admission_type AS VARCHAR(MAX)) AS journey_path,
            ROW_NUMBER() OVER (PARTITION BY a.subject_id ORDER BY a.admittime) AS rn
        FROM admissions a
    ) AS t
    WHERE rn = 1
    
 
    UNION ALL
 
    -- Recursive: subsequent admissions
    SELECT
        a.subject_id,
        a.hadm_id,
        a.admittime,
        a.dischtime,
        a.admission_type,
        j.journey_step + 1,
        j.journey_path + ' -> ' + a.admission_type
    FROM admissions a
    INNER JOIN PatientJourneyBase j ON a.subject_id = j.subject_id
    WHERE a.admittime > j.admittime
      AND a.hadm_id  != j.hadm_id
      AND j.journey_step < 5  -- Limit to 5 hops to avoid infinite recursion
)
SELECT
    subject_id,
    MAX(journey_step) AS total_admissions,
    MIN(admittime)    AS first_admission,
    MAX(dischtime)    AS last_discharge,
    MAX(journey_path) AS full_journey_path
FROM PatientJourneyBase
GROUP BY subject_id
HAVING MAX(journey_step) >= 2   -- Only patients with 2+ admissions
ORDER BY total_admissions DESC;