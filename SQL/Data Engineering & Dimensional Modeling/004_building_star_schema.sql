-- ====================================================
-- DIMENSION TABLE 1: dim_patient
-- ====================================================
CREATE TABLE dim_patient (
    patient_key        INT IDENTITY(1,1) PRIMARY KEY,
    subject_id         INT,
    gender             VARCHAR(1),
    anchor_age         INT,
    age_group          VARCHAR(20),  -- 0-17, 18-35, 36-50, 51-65, 65+
    anchor_year_group  VARCHAR(20),
    dod                DATE,
    is_deceased        BIT,
    -- SCD Type 2 columns
    effective_date     DATE DEFAULT GETDATE(),
    expiry_date        DATE DEFAULT '9999-12-31',
    is_current         BIT DEFAULT 1
);
 
INSERT INTO dim_patient (
    subject_id, gender, anchor_age, age_group,
    anchor_year_group, dod, is_deceased
)
SELECT
    subject_id,
    gender,
    anchor_age,
    CASE
        WHEN anchor_age < 18          THEN '0-17'
        WHEN anchor_age BETWEEN 18 AND 35 THEN '18-35'
        WHEN anchor_age BETWEEN 36 AND 50 THEN '36-50'
        WHEN anchor_age BETWEEN 51 AND 65 THEN '51-65'
        ELSE '65+'
    END AS age_group,
    anchor_year_group,
    dod,
    CASE WHEN dod IS NOT NULL THEN 1 ELSE 0 END AS is_deceased
FROM patients;
 
-- ====================================================
-- DIMENSION TABLE 2: dim_date
-- ====================================================
CREATE TABLE dim_date (
    date_key      INT PRIMARY KEY,  -- YYYYMMDD format
    full_date     DATE,
    year          INT,
    quarter       INT,
    month         INT,
    month_name    VARCHAR(10),
    week          INT,
    day_of_week   INT,
    day_name      VARCHAR(10),
    is_weekend    BIT
);
 
-- Populating dim_date for year range 2100-2200
DECLARE @start DATE = '2100-01-01';
DECLARE @end   DATE = '2210-12-31';
DECLARE @curr  DATE = @start;
 
WHILE @curr <= @end
BEGIN
    INSERT INTO dim_date VALUES (
        CONVERT(INT, FORMAT(@curr,'yyyyMMdd')),
        @curr,
        YEAR(@curr),
        DATEPART(QUARTER, @curr),
        MONTH(@curr),
        DATENAME(MONTH, @curr),
        DATEPART(WEEK, @curr),
        DATEPART(WEEKDAY, @curr),
        DATENAME(WEEKDAY, @curr),
        CASE WHEN DATEPART(WEEKDAY, @curr) IN (1,7) THEN 1 ELSE 0 END
    );
    SET @curr = DATEADD(DAY, 1, @curr);
END;
 
-- ====================================================
-- DIMENSION TABLE 3: dim_diagnosis
-- ====================================================
CREATE TABLE dim_diagnosis (
    diagnosis_key  INT IDENTITY(1,1) PRIMARY KEY,
    icd_code       VARCHAR(10),
    icd_version    INT,
    long_title     VARCHAR(500),
    disease_category VARCHAR(100)
);
 
INSERT INTO dim_diagnosis (icd_code, icd_version, long_title, disease_category)
SELECT DISTINCT
    d.icd_code,
    d.icd_version,
    ISNULL(di.long_title, 'Unknown'),
    CASE
        WHEN d.icd_code LIKE 'A%' OR d.icd_code LIKE 'B%' THEN 'Infectious Disease'
        WHEN d.icd_code LIKE 'C%' OR d.icd_code LIKE 'D0%' THEN 'Cancer/Neoplasm'
        WHEN d.icd_code LIKE 'E%' THEN 'Endocrine/Metabolic'
        WHEN d.icd_code LIKE 'F%' THEN 'Mental Health'
        WHEN d.icd_code LIKE 'G%' THEN 'Neurological'
        WHEN d.icd_code LIKE 'I%' THEN 'Cardiovascular'
        WHEN d.icd_code LIKE 'J%' THEN 'Respiratory'
        WHEN d.icd_code LIKE 'K%' THEN 'Digestive'
        WHEN d.icd_code LIKE 'M%' THEN 'Musculoskeletal'
        WHEN d.icd_code LIKE 'N%' THEN 'Renal/Urinary'
        WHEN d.icd_code LIKE 'S%' OR d.icd_code LIKE 'T%' THEN 'Injury/Trauma'
        ELSE 'Other'
    END
FROM diagnoses_icd d
LEFT JOIN d_icd_diagnoses di ON d.icd_code = di.icd_code AND d.icd_version = di.icd_version;
 
-- ====================================================
-- DIMENSION TABLE 4: dim_admission_type
-- ====================================================
CREATE TABLE dim_admission_type (
    admission_type_key INT IDENTITY(1,1) PRIMARY KEY,
    admission_type     VARCHAR(50),
    admission_location VARCHAR(60),
    insurance_type     VARCHAR(30)
);
 
INSERT INTO dim_admission_type (admission_type, admission_location, insurance_type)
SELECT DISTINCT admission_type, admission_location, insurance
FROM admissions;
 
-- ====================================================
-- FACT TABLE: fact_patient_admissions
-- ====================================================
CREATE TABLE fact_patient_admissions (
    admission_key        INT IDENTITY(1,1) PRIMARY KEY,
    hadm_id              INT,
    subject_id           INT,
    patient_key          INT,           -- FK to dim_patient
    admit_date_key       INT,           -- FK to dim_date
    discharge_date_key   INT,           -- FK to dim_date
    admission_type       VARCHAR(50),
    insurance            VARCHAR(30),
    discharge_location   VARCHAR(60),
    los_hours            FLOAT,         -- Length of Stay in hours
    los_days             FLOAT,         -- Length of Stay in days
    is_icu_admission     BIT,
    icu_los_days         FLOAT,
    diagnosis_count      INT,           -- # of ICD codes for this admission
    procedure_count      INT,
    prescription_count   INT,
    lab_test_count       INT,
    is_readmission       BIT,           -- readmitted within 30 days?
    days_to_readmit      INT,
    hospital_expire_flag TINYINT,       -- 1 = died in hospital
    is_emergency         BIT
);
 
INSERT INTO fact_patient_admissions (
    hadm_id, subject_id, patient_key,
    admit_date_key, discharge_date_key,
    admission_type, insurance, discharge_location,
    los_hours, los_days, is_icu_admission, icu_los_days,
    diagnosis_count, procedure_count, prescription_count, lab_test_count,
    is_readmission, days_to_readmit, hospital_expire_flag, is_emergency
)
SELECT
    a.hadm_id,
    a.subject_id,
    dp.patient_key,
    CONVERT(INT, FORMAT(CAST(a.admittime AS DATE), 'yyyyMMdd'))  AS admit_date_key,
    CONVERT(INT, FORMAT(CAST(a.dischtime AS DATE), 'yyyyMMdd'))  AS discharge_date_key,
    a.admission_type,
    a.insurance,
    a.discharge_location,
    DATEDIFF(HOUR, a.admittime, a.dischtime)                     AS los_hours,
    DATEDIFF(HOUR, a.admittime, a.dischtime) / 24.0              AS los_days,
    CASE WHEN i.hadm_id IS NOT NULL THEN 1 ELSE 0 END            AS is_icu_admission,
    ISNULL(i.icu_los, 0)                                         AS icu_los_days,
    ISNULL(dc.diag_count, 0)                                     AS diagnosis_count,
    ISNULL(pc.proc_count, 0)                                     AS procedure_count,
    ISNULL(rx.rx_count, 0)                                       AS prescription_count,
    ISNULL(lb.lab_count, 0)                                      AS lab_test_count,
    0                                                            AS is_readmission,
    NULL                                                         AS days_to_readmit,
    a.hospital_expire_flag,
    CASE WHEN a.admission_type = 'EMERGENCY' THEN 1 ELSE 0 END   AS is_emergency
FROM admissions a
LEFT JOIN dim_patient dp ON a.subject_id = dp.subject_id AND dp.is_current = 1
LEFT JOIN (
    SELECT hadm_id, SUM(los) AS icu_los FROM icustays GROUP BY hadm_id
) i ON a.hadm_id = i.hadm_id
LEFT JOIN (
    SELECT hadm_id, COUNT(*) AS diag_count FROM diagnoses_icd GROUP BY hadm_id
) dc ON a.hadm_id = dc.hadm_id
LEFT JOIN (
    SELECT hadm_id, COUNT(*) AS proc_count FROM procedures_icd GROUP BY hadm_id
) pc ON a.hadm_id = pc.hadm_id
LEFT JOIN (
    SELECT hadm_id, COUNT(*) AS rx_count FROM prescriptions GROUP BY hadm_id
) rx ON a.hadm_id = rx.hadm_id
LEFT JOIN (
    SELECT hadm_id, COUNT(*) AS lab_count FROM labevents GROUP BY hadm_id
) lb ON a.hadm_id = lb.hadm_id
WHERE a.dischtime IS NOT NULL;