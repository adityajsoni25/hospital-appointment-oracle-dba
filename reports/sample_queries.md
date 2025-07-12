# 📊 Sample Report Queries

This file includes useful SQL queries for analyzing appointment data in the Hospital Appointment & Patient Record System.

---

## 📅 1. Daily Appointments

```sql
SELECT a.appointment_id, p.name AS patient, d.name AS doctor, a.appointment_date, a.description
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doc_id = d.doc_id
WHERE TRUNC(a.appointment_date) = TRUNC(SYSDATE);

## 📆 2. Weekly Appointment Summary

SELECT TO_CHAR(appointment_date, 'YYYY-MM-DD') AS appoint_day,
       COUNT(*) AS total_appointments
FROM appointments
WHERE appointment_date BETWEEN SYSDATE - 7 AND SYSDATE
GROUP BY TO_CHAR(appointment_date, 'YYYY-MM-DD')
ORDER BY appoint_day;

## 👨‍⚕️ 3. Appointments Per Doctor

SELECT d.name AS doctor, COUNT(*) AS total_appointments
FROM appointments a
JOIN doctors d ON a.doc_id = d.doc_id
GROUP BY d.name
ORDER BY total_appointments DESC;
