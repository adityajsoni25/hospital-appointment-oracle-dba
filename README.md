# hospital-appointment-oracle-dba
An Oracle SQL and PL/SQL-based Hospital Appointment &amp; Patient Record System featuring database design, triggers, procedures, partitioning, auditing, performance tuning, and auto backup scheduling.

## 🏗️ Project Structure
<img width="1024" height="1024" alt="image" src="https://github.com/user-attachments/assets/e27b5be1-ba77-46bf-a88c-258226bcca9f" />



---

## ✅ Key Features

| Feature                | Description                                                   |
|------------------------|---------------------------------------------------------------|
| 🛡️ Constraints          | PRIMARY KEY, UNIQUE, CHECK, and FOREIGN KEY constraints       |
| 🧮 Normalization        | Tables designed up to 3NF for efficient structure              |
| 👥 User & Roles         | Role-based access using GRANT/REVOKE                          |
| 🔍 Views               | `doctor_schedule_view` for simplified reporting               |
| 🧠 Stored Procedures    | Automated scheduling via `assign_next_appointment` procedure  |
| 🔁 Triggers            | Appointment insert and doctor audit triggers                   |
| 🧱 Partitioning         | `appointments_part` with monthly range partitions             |
| 🧾 Auditing            | Track changes to `doctors` table via `trg_audit_doctor_update`|
| 💾 Backup & Recovery    | Auto backups with `DBMS_SCHEDULER` and Data Pump              |
| ⚡ Performance Tuning   | Indexes on `patient_id`, `appointment_date`                   |

---

## 📊 Report Queries

- 📅 Daily appointments  
- 📆 Weekly appointment summary  
- 👨‍⚕️ Appointments per doctor  

(See `reports/sample_queries.md`)

---

## 🛠️ Technologies Used

- Oracle SQL / PL/SQL  
- Oracle Data Pump  
- DBMS_SCHEDULER  
- SQL Developer / SQL*Plus  

---

## 🧑‍💻 Author

**Aditya Soni**  
GitHub: [@adityajsoni25](https://github.com/adityajsoni25) 

Computer Engineering Student

---

