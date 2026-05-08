-- 1. Total Number of Patients
SELECT COUNT(*) AS total_patients FROM patients;

-- 2. Total Number of Admissions
SELECT COUNT(*) AS total_admissions FROM admissions;

-- 3. Gender Distribution Across Patients
SELECT gender, COUNT(*) AS count
FROM patients
GROUP BY gender;

-- 4. Age Distribution Across Patients
SELECT
	MIN(anchor_age) AS min_age,
	MAX(anchor_age) AS max_age,
	AVG(anchor_age) AS avg_age
FROM patients;

-- 5. Average Length of Stay (LOS) in days
SELECT
    AVG(DATEDIFF(HOUR, admittime, dischtime)/24.0) AS avg_los_days,
    MIN(DATEDIFF(HOUR, admittime, dischtime)/24.0) AS min_los,
    MAX(DATEDIFF(HOUR, admittime, dischtime)/24.0) AS max_los
FROM admissions
WHERE dischtime IS NOT NULL;

-- 6. Admission Types Breakdown
SELECT admission_type, COUNT(*) AS count
FROM admissions
GROUP BY admission_type
ORDER BY count DESC;

-- 7. Insurance Distribution
SELECT insurance, COUNT(*) AS count
FROM admissions
GROUP BY insurance
ORDER BY count DESC;

-- 8. Top 10 Most Common Diagnoses
SELECT TOP 10
    d.icd_code,
    di.long_title,
    COUNT(*) AS frequency
FROM diagnoses_icd d
LEFT JOIN d_icd_diagnoses di
    ON d.icd_code = di.icd_code AND d.icd_version = di.icd_version
GROUP BY d.icd_code, di.long_title
ORDER BY frequency DESC;

-- 9. ICU stay overview
SELECT
    first_careunit,
    COUNT(*) AS stays,
    CEILING(AVG(los)) AS avg_icu_los_days
FROM icustays
GROUP BY first_careunit
ORDER BY stays DESC;

-- 10. How many patients have NULL discharge time (still admitted)?
SELECT COUNT(*) AS missing_discharge
FROM admissions
WHERE dischtime IS NULL;