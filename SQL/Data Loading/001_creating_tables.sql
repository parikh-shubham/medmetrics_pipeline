/* Creating the Database */

CREATE DATABASE PatientJourneyDB;
GO
USE PatientJourneyDB;
GO

/* Creating Tables */

-- 1. PATIENTS TABLE

IF OBJECT_ID ('patients', 'U') IS NOT NULL
	DROP TABLE patients;
CREATE TABLE patients (
	subject_id INT PRIMARY KEY,
	gender VARCHAR(1),
	anchor_age INT,
	anchor_year INT,
	anchor_year_group VARCHAR(20),
	dod DATE
);

-- 2. ADMISSIONS TABLE

IF OBJECT_ID ('admissions', 'U') IS NOT NULL
	DROP TABLE admissions;
CREATE TABLE admissions (
	subject_id INT,
	hadm_id INT,
	admittime DATETIME,
	dischtime DATETIME,
	deathtime DATETIME,
	admission_type VARCHAR(50),
	admit_provider_id VARCHAR(20),
    admission_location VARCHAR(60),
    discharge_location VARCHAR(60),
    insurance         VARCHAR(30),
    language          VARCHAR(20),
    marital_status    VARCHAR(30),
    race              VARCHAR(80),
    edregtime         DATETIME,
    edouttime         DATETIME,
    hospital_expire_flag TINYINT

);

-- 3. DIAGNOSES TABLE

IF OBJECT_ID ('diagnoses_icd', 'U') IS NOT NULL
	DROP TABLE diagnoses_icd;
CREATE TABLE diagnoses_icd (
	subject_id  INT,
    hadm_id     INT,
    seq_num     INT,
    icd_code    VARCHAR(10),
    icd_version INT
);

-- 4. PROCEDURES TABLE

IF OBJECT_ID ('procedures_icd', 'U') IS NOT NULL
	DROP TABLE procedures_icd;
CREATE TABLE procedures_icd (
	subject_id  INT,
    hadm_id     INT,
    seq_num     INT,
    chartdate   DATE,
    icd_code    VARCHAR(10),
    icd_version INT
);

-- 5. LAB EVENTS TABLE

IF OBJECT_ID ('labevents', 'U') IS NOT NULL
	DROP TABLE labevents;
CREATE TABLE labevents (
    labevent_id BIGINT PRIMARY KEY,
    subject_id    INT,
    hadm_id       INT,
    itemid        INT,
    charttime     DATETIME,
    storetime     DATETIME,
    value         VARCHAR(200),
    valuenum      FLOAT,
    valueuom      VARCHAR(20),
    flag          VARCHAR(10)
);

-- 6. PRESCRIPTIONS TABLE

IF OBJECT_ID ('prescriptions', 'U') IS NOT NULL
	DROP TABLE prescriptions;
CREATE TABLE prescriptions (
    subject_id    INT,
    hadm_id       INT,
    pharmacy_id   INT,
    starttime     DATETIME,
    stoptime      DATETIME,
    drug_type     VARCHAR(30),
    drug          VARCHAR(100),
    dose_val_rx   VARCHAR(50),
    dose_unit_rx  VARCHAR(30),
    route         VARCHAR(30)
);

-- 7. ICU STAYS TABLE

IF OBJECT_ID ('icustays', 'U') IS NOT NULL
	DROP TABLE icustays;
CREATE TABLE icustays (
    subject_id    INT,
    hadm_id       INT,
    stay_id       INT PRIMARY KEY,
    first_careunit VARCHAR(50),
    last_careunit  VARCHAR(50),
    intime        DATETIME,
    outtime       DATETIME,
    los           FLOAT
);

-- 8. ICD DIAGNOSIS DESCRIPTIONS

IF OBJECT_ID ('d_icd_diagnoses', 'U') IS NOT NULL
	DROP TABLE d_icd_diagnoses;
CREATE TABLE d_icd_diagnoses (
    icd_code    VARCHAR(10),
    icd_version INT,
    long_title  VARCHAR(500)
);