-- Author: Aditya Soni

-- ============================
-- Hospital Appointment & Patient Record System
-- Oracle DBA Mini Project
-- ============================

-- Drop tables if exist (for reset)
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE appointments PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE patients PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE doctors PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE departments PURGE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- 1. DEPARTMENTS Table
CREATE TABLE departments (
    dept_id     NUMBER PRIMARY KEY,
    dept_name   VARCHAR2(100) NOT NULL UNIQUE,
    location    VARCHAR2(100)
);

-- 2. DOCTORS Table
CREATE TABLE doctors (
    doc_id      NUMBER PRIMARY KEY,
    name        VARCHAR2(100) NOT NULL,
    specialization VARCHAR2(100),
    dept_id     NUMBER,
    contact     VARCHAR2(15),
    availability VARCHAR2(10),
    CONSTRAINT fk_dept FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- 3. PATIENTS Table
CREATE TABLE patients (
    patient_id  NUMBER PRIMARY KEY,
    name        VARCHAR2(100) NOT NULL,
    age         NUMBER CHECK (age BETWEEN 0 AND 120),
    gender      CHAR(1) CHECK (gender IN ('M', 'F')),
    contact     VARCHAR2(15)
);

-- 4. APPOINTMENTS Table
CREATE TABLE appointments (
    appointment_id   NUMBER PRIMARY KEY,
    patient_id       NUMBER,
    doc_id           NUMBER,
    appointment_date DATE NOT NULL,
    description      VARCHAR2(200),
    CONSTRAINT fk_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    CONSTRAINT fk_doctor FOREIGN KEY (doc_id) REFERENCES doctors(doc_id)
);

-- Insert Sample Data
INSERT INTO departments VALUES (1, 'Cardiology', 'Block A');
INSERT INTO departments VALUES (2, 'Neurology', 'Block B');

INSERT INTO doctors VALUES (101, 'Dr. Mehta', 'Cardiologist', 1, '9999988888', 'Yes');
INSERT INTO doctors VALUES (102, 'Dr. Shah', 'Neurologist', 2, '9999977777', 'Yes');

INSERT INTO patients VALUES (201, 'Amit Patel', 45, 'M', '8888866666');
INSERT INTO patients VALUES (202, 'Neha Sharma', 30, 'F', '8888855555');

INSERT INTO appointments VALUES (301, 201, 101, TO_DATE('2025-07-15', 'YYYY-MM-DD'), 'Regular Checkup');
INSERT INTO appointments VALUES (302, 202, 102, TO_DATE('2025-07-16', 'YYYY-MM-DD'), 'Migraine Treatment');

-- Create View
CREATE OR REPLACE VIEW doctor_schedule_view AS
SELECT d.name AS doctor_name, dept.dept_name, a.appointment_date, p.name AS patient_name
FROM appointments a
JOIN doctors d ON a.doc_id = d.doc_id
JOIN patients p ON a.patient_id = p.patient_id
JOIN departments dept ON d.dept_id = dept.dept_id;

-- Create Trigger: Log appointment insert
CREATE TABLE appointment_log (
    log_id        NUMBER GENERATED ALWAYS AS IDENTITY,
    action_time   TIMESTAMP DEFAULT SYSTIMESTAMP,
    appointment_id NUMBER,
    patient_id    NUMBER,
    doc_id        NUMBER,
    action        VARCHAR2(20)
);

CREATE OR REPLACE TRIGGER trg_log_appointment
AFTER INSERT ON appointments
FOR EACH ROW
BEGIN
    INSERT INTO appointment_log (appointment_id, patient_id, doc_id, action)
    VALUES (:NEW.appointment_id, :NEW.patient_id, :NEW.doc_id, 'INSERT');
END;
/

-- Create Procedure: Assign next appointment
CREATE OR REPLACE PROCEDURE assign_next_appointment (
    p_patient_id IN NUMBER,
    p_doc_id     IN NUMBER
) IS
    next_id NUMBER;
BEGIN
    SELECT NVL(MAX(appointment_id), 300) + 1 INTO next_id FROM appointments;
    INSERT INTO appointments (appointment_id, patient_id, doc_id, appointment_date, description)
    VALUES (next_id, p_patient_id, p_doc_id, SYSDATE + 1, 'Auto-Scheduled');
    DBMS_OUTPUT.PUT_LINE('Appointment Scheduled with ID: ' || next_id);
END;
/

-- Grant Read-Only Role
CREATE ROLE readonly_role;
GRANT SELECT ON departments TO readonly_role;
GRANT SELECT ON doctors TO readonly_role;
GRANT SELECT ON patients TO readonly_role;
GRANT SELECT ON appointments TO readonly_role;

-- =====================================
-- ADVANCED DBA TASKS
-- =====================================

-- ✅ Partitioning: Monthly partitioning of APPOINTMENTS table
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE appointments_part PURGE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
CREATE TABLE appointments_part (
    appointment_id   NUMBER,
    patient_id       NUMBER,
    doc_id           NUMBER,
    appointment_date DATE,
    description      VARCHAR2(200)
)
PARTITION BY RANGE (appointment_date) (
    PARTITION jan2025 VALUES LESS THAN (TO_DATE('2025-02-01', 'YYYY-MM-DD')),
    PARTITION feb2025 VALUES LESS THAN (TO_DATE('2025-03-01', 'YYYY-MM-DD')),
    PARTITION mar2025 VALUES LESS THAN (TO_DATE('2025-04-01', 'YYYY-MM-DD')),
    PARTITION future  VALUES LESS THAN (MAXVALUE)
);

-- ✅ Auditing: Fine-grained auditing on DOCTORS table
-- Enable standard auditing (must be enabled at DB level)
-- Assuming DB is configured, we'll simulate it with a trigger log for demo purposes

CREATE TABLE doctor_audit_log (
    log_id        NUMBER GENERATED ALWAYS AS IDENTITY,
    action_time   TIMESTAMP DEFAULT SYSTIMESTAMP,
    user_name     VARCHAR2(30),
    doc_id        NUMBER,
    old_name      VARCHAR2(100),
    new_name      VARCHAR2(100),
    action        VARCHAR2(20)
);

CREATE OR REPLACE TRIGGER trg_audit_doctor_update
BEFORE UPDATE ON doctors
FOR EACH ROW
BEGIN
    INSERT INTO doctor_audit_log (user_name, doc_id, old_name, new_name, action)
    VALUES (USER, :OLD.doc_id, :OLD.name, :NEW.name, 'UPDATE');
END;
/

-- ✅ Backup & Recovery: Simulate export/import using Data Pump
-- This is just the command simulation; to be run in terminal/SQL*Plus or shell

-- EXPORT:
-- expdp user/password DIRECTORY=dpump_dir DUMPFILE=hos_backup.dmp LOGFILE=hos_export.log FULL=y

-- IMPORT:
-- impdp user/password DIRECTORY=dpump_dir DUMPFILE=hos_backup.dmp LOGFILE=hos_import.log FULL=y

-- ✅ Performance Tuning: Create Indexes
CREATE INDEX idx_patient_id ON appointments(patient_id);
CREATE INDEX idx_appointment_date ON appointments(appointment_date);

-- ==========================================
-- REPORT QUERIES FOR ANALYSIS
-- ==========================================

-- Daily Appointments
SELECT a.appointment_id, p.name AS patient, d.name AS doctor, a.appointment_date, a.description
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doc_id = d.doc_id
WHERE TRUNC(a.appointment_date) = TRUNC(SYSDATE);

-- Weekly Appointment Summary
SELECT TO_CHAR(appointment_date, 'YYYY-MM-DD') AS appoint_day,
       COUNT(*) AS total_appointments
FROM appointments
WHERE appointment_date BETWEEN SYSDATE - 7 AND SYSDATE
GROUP BY TO_CHAR(appointment_date, 'YYYY-MM-DD')
ORDER BY appoint_day;

-- Appointments Per Doctor
SELECT d.name AS doctor, COUNT(*) AS total_appointments
FROM appointments a
JOIN doctors d ON a.doc_id = d.doc_id
GROUP BY d.name
ORDER BY total_appointments DESC;

-- ==========================================
-- AUTO BACKUP SCHEDULER USING DBMS_SCHEDULER
-- ==========================================

-- 1. Create Directory
CREATE OR REPLACE DIRECTORY dpump_dir AS '/u01/oracle/backups';
GRANT READ, WRITE ON DIRECTORY dpump_dir TO your_user;

-- 2. Create Scheduler Job for Daily Backup
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'daily_backup_job',
    job_type        => 'EXECUTABLE',
    job_action      => '/u01/app/oracle/product/19.0.0/dbhome_1/bin/expdp',
    number_of_arguments => 5,
    auto_drop       => FALSE,
    enabled         => FALSE
  );

  DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('daily_backup_job', 1, 'your_user/your_password');
  DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('daily_backup_job', 2, 'DIRECTORY=dpump_dir');
  DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('daily_backup_job', 3, 'DUMPFILE=hos_backup_%U.dmp');
  DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('daily_backup_job', 4, 'LOGFILE=hos_backup.log');
  DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('daily_backup_job', 5, 'FULL=Y');

  DBMS_SCHEDULER.SET_ATTRIBUTE('daily_backup_job', 'repeat_interval', 'FREQ=DAILY;BYHOUR=1;BYMINUTE=0');
  DBMS_SCHEDULER.ENABLE('daily_backup_job');
END;
/
