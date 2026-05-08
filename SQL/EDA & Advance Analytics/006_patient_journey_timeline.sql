-- ====================================================
-- PATIENT JOURNEY TIMELINE
-- ====================================================
SELECT
    a.subject_id,
    a.hadm_id,
    a.admittime,
    a.dischtime,
    a.admission_type,
    a.discharge_location,
    DATEDIFF(HOUR, a.admittime, a.dischtime) / 24.0  AS los_days,
 
    -- Visit sequence number per patient
    ROW_NUMBER() OVER (
        PARTITION BY a.subject_id
        ORDER BY a.admittime
    ) AS visit_sequence,
 
    -- Total visits for this patient
    COUNT(*) OVER (PARTITION BY a.subject_id) AS total_visits,
 
    -- Previous admission date
    LAG(a.admittime) OVER (
        PARTITION BY a.subject_id ORDER BY a.admittime
    ) AS prev_admit_date,
 
    -- Days since last admission
    DATEDIFF(DAY,
        LAG(a.admittime) OVER (PARTITION BY a.subject_id ORDER BY a.admittime),
        a.admittime
    ) AS days_since_last_admit,
 
    -- Next admission date
    LEAD(a.admittime) OVER (
        PARTITION BY a.subject_id ORDER BY a.admittime
    ) AS next_admit_date,
 
    -- Days until next admission
    DATEDIFF(DAY, a.dischtime,
        LEAD(a.admittime) OVER (PARTITION BY a.subject_id ORDER BY a.admittime)
    ) AS days_to_next_admit,
 
    -- 30-day readmission flag
    CASE
        WHEN DATEDIFF(DAY, a.dischtime,
            LEAD(a.admittime) OVER (PARTITION BY a.subject_id ORDER BY a.admittime)
        ) <= 30 THEN 1 ELSE 0
    END AS readmitted_within_30d,
 
    -- Running total LOS per patient
    SUM(DATEDIFF(HOUR, a.admittime, a.dischtime) / 24.0) OVER (
        PARTITION BY a.subject_id
        ORDER BY a.admittime
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_los_days,
 
    -- Rank by LOS within admission type
    RANK() OVER (
        PARTITION BY a.admission_type
        ORDER BY DATEDIFF(HOUR, a.admittime, a.dischtime) DESC
    ) AS los_rank_in_type
 
FROM admissions AS a
WHERE a.dischtime IS NOT NULL
ORDER BY a.subject_id, a.admittime;