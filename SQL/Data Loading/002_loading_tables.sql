CREATE OR ALTER PROCEDURE load_mimic AS

BEGIN

	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	
	BEGIN TRY
		
		SET @batch_start_time = GETDATE();

		PRINT '===============================================';
		PRINT 'Loading MIMIC Tables';
		PRINT '===============================================';

		-- 1. PATIENTS TABLE
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: patients'
		TRUNCATE TABLE patients;

		PRINT '>> Inserting Data Into Table: patients'
		INSERT INTO patients
		SELECT * FROM dbo.raw_patients

		-- 2. ADMISSIONS TABLE
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: admissions'
		TRUNCATE TABLE admissions;

		PRINT '>> Inserting Data Into Table: admissions'
		INSERT INTO admissions
		SELECT * FROM dbo.raw_admissions

		-- 3. DIAGNOSES TABLE
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: diagnoses_icd'
		TRUNCATE TABLE admissions;

		PRINT '>> Inserting Data Into Table: diagnoses_icd'
		INSERT INTO diagnoses_icd
		SELECT * FROM dbo.raw_diagnoses_icd

		-- 4. PROCEDURES TABLE
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: procedures_icd'
		TRUNCATE TABLE procedures_icd;

		PRINT '>> Inserting Data Into Table: procedures_icd'
		INSERT INTO procedures_icd
		SELECT * FROM dbo.raw_procedures_icd

		-- 5. LAB EVENTS TABLE
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: labevents'
		TRUNCATE TABLE labevents;

		PRINT '>> Inserting Data Into Table: labevents'
		INSERT INTO labevents
		SELECT * FROM dbo.raw_labevents

		-- 6. PRESCRIPTIONS TABLE
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: prescriptions'
		TRUNCATE TABLE prescriptions;

		PRINT '>> Inserting Data Into Table: prescriptions'
		INSERT INTO prescriptions
		SELECT * FROM dbo.raw_prescriptions

		-- 7. ICU STAYS TABLE
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: icustays'
		TRUNCATE TABLE icustays;

		PRINT '>> Inserting Data Into Table: icustays'
		INSERT INTO icustays
		SELECT * FROM dbo.raw_icustays

		-- 8. ICD DIAGNOSIS DESCRIPTIONS
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: d_icd_diagnoses'
		TRUNCATE TABLE d_icd_diagnoses;

		PRINT '>> Inserting Data Into Table: d_icd_diagnoses'
		INSERT INTO d_icd_diagnoses
		SELECT * FROM dbo.raw_d_icd_diagnoses

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> -----------------';

		SET @batch_end_time = GETDATE();
		PRINT '================================================='
		PRINT 'Loading MIMIC Tables Is Completed!'
		PRINT '-- Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
		PRINT '================================================='

	END TRY

	BEGIN CATCH
		
		PRINT '====================================================='
		PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '====================================================='

	END CATCH

END

-- EXECUTE load_mimic;