# 🏥 MedMetrics Pipeline Analytics

Welcome to the **Clinical Data Warehouse Project** repository! 🚀  
Designed as a portfolio project, this project demonstrates a comprehensive data warehousing and analytics solution, transforming raw Electronic Health Record (EHR) data into actionable intelligence for hospital administration. 

---
## 🏗️ Pipeline Architecture

The pipeline processes raw clinical data into a strategic reporting engine:

1. **Data Engineering**: Automated ETL ingestion of hospital records (admissions, diagnoses, ICU stays, lab events) into a structured database.
2. **Dimensional Modeling**: Transformation of transactional data into a highly optimized Star Schema (Fact and Dimension tables) featuring Slowly Changing Dimensions (SCD) for patient tracking.
3. **Pathway Analytics**: Deployment of recursive modeling to map multi-hop patient care journeys, tracking the exact sequence of departments a patient traverses.
4. **KPI Engine**: Modular stored procedures aggregating critical operational metrics for downstream integration into executive dashboards.
   
---
## 📖 Project Overview

This project executes the following core phases:

1. **Architecture Initialization**: Establishing base schemas and resolving data anomalies (e.g., active admissions handling).
2. **Entity Structuring**: Architecting the Star Schema to link patient demographics, detailed ICD disease categorizations, and admission attributes.
3. **Behavioral Tracking**: Flagging 30-day readmissions and calculating cumulative Length of Stay (LOS) across varying facility departments.
4. **Strategic Output**: Translating clinical occurrences into financial and operational risk metrics, highlighting mortality rates, readmission drivers, and demographic resource utilization.
   
---

## 🚀 Project Requirements

### Building the Data Warehouse (Data Engineering)

#### Objective
Develop a modern data warehouse using SQL Server to consolidate complex EHR data, enabling predictive resource allocation and informed clinical decision-making.

#### Specifications
- **Data Sources**: Import raw clinical datasets, including patient demographics, ICU stays, and ICD disease codes.
- **Data Quality**: Cleanse and resolve data quality issues, ensuring accurate handling of patient mortality flags and sequential admission timelines.
- **Integration**: Combine disparate clinical tables into a single, user-friendly data model designed for rapid analytical queries.
- **Scope**: Focus on structuring the data to support readmission tracking, length of stay (LOS) calculations, and patient flow mapping.
- **Documentation**: Provide clear documentation of the schema to support both healthcare administrators and technical analytics teams.

---

### BI: Analytics & Reporting (Data Analysis)

#### Objective
Develop SQL-based analytics to deliver detailed, automated insights into:
- **30-Day Readmission Risk & Financial Impact**
- **Length of Stay (LOS) Optimization across Departments**
- **Patient Care Pathway Bottlenecks**
- **In-Hospital Mortality & Care Quality Trends**

---

## 🛡️ License

This project is licensed under the [MIT License](LICENSE). 

## 🌟 About Me

Hi there! I'm **Shubham Parikh**. I am a Computer Engineer who understands both technology and business operations. Instead of focusing only on code, I focus on how systems, data, and processes work together to improve business performance and drive strategic decision-making.

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/shubhamparikh/)
