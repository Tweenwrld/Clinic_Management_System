# Clinic Management Database

## Overview
This project contains a comprehensive database schema for a Clinic Management System. The database includes tables for users, people, staff, patients, medical records, appointments, laboratory tests, pharmacy/medication, billing, inventory, notifications, documents, and auditing. It also contains views for common business queries and triggers to automate data integrity tasks.

## Initial Code Provided
The initial code was designed to:
- **Create the Database and Schema:**  
  I created tables for `users`, `person`, `departments`, `doctors`, `nurses`, `staff`, `patients`, medical history, appointments, insurance providers, and more.  
- **Defining Relationships:**  
  I established foreign keys to enforce relationships (e.g., between patients and persons, doctors and departments).
- **Enabling Automation:**  
  I created triggers for automatically updating invoice status after payments, adjusting inventory, generating notifications, and logging updates.
- **Insert Sample Data:**  
  Populated the database with initial data for testing, including sample departments, specialties, users, and persons.

## Issues Encountered & Corrections Made

### 1. Duplicate Insert Errors
- **Issue:**  
  When re-running the insert commands, errors occurred because duplicate data was being inserted (e.g., duplicate department names or user names).
- **Correction:**  
  I used `INSERT IGNORE` for sample data to prevent duplicate entry errors. This allows the script to be safely re-run without errors if the data already exists.

### 2. Trigger Creation Conflicts
- **Issue:**  
  Running the triggers multiple times led to "trigger already exists" errors.
- **Correction:**  
  I added `DROP TRIGGER IF EXISTS` statements before each `CREATE TRIGGER` to ensure old triggers are removed before re-creation.

### 3. Use of Session Variables in Triggers
- **Issue:**  
  The initial trigger code used session variables (e.g., `@min_stock`), which could lead to unintended results in concurrent sessions.
- **Correction:**  
  I replaced session variables with locally declared variables inside each trigger. This improved encapsulation and prevented cross-trigger contamination.

### 4. Date Default Syntax
- **Issue:**  
  In the original code, I experimented using `DEFAULT (CURRENT_DATE)` in several places, which I noted sometimes caused compatibility issues.
- **Correction:**  
  I then replaced such defaults with `DEFAULT CURRENT_DATE` (without parentheses) for better compatibility across MySQL versions.

### 5. Consistent DELIMITER Management
- **Issue:**  
  Triggers required a custom delimiter for proper parsing.
- **Correction:**  
  I explicitly set and then reset the delimiter (`DELIMITER //` and `DELIMITER ;`) around each trigger definition to ensure proper execution.

## How to Use This Database

1. **Import the SQL Schema:**
   - Download or copy the provided SQL scripts for creating the database and all its objects.
   - In your MySQL client, ensure that you are connected to your server.
   - Run the entire SQL script (it includes table definitions for all areas of the clinic, followed by view definitions, trigger definitions, and sample data inserts).
   - The sample data insertion sections use `INSERT IGNORE` so that duplicate records are skipped if the script is re-run.

2. **Verifying the Setup:**
   - After running the scripts, verify that the database is created correctly by listing the tables:
     ```sql
     USE clinic_management;
     SHOW TABLES;
     ```
   - Run a few `SELECT` queries on the views (like `view_patient_info` or `view_doctor_info`) to ensure data is being queried as expected.

3. **Testing Triggers & Automation:**
   - The project includes several triggers such as updating invoice status after a payment and logging patient updates.
   - Test these triggers by inserting new records (for example, a new payment) and verifying that the related invoice status updates.

4. **ERD Visualization:**
   - The detailed ERD is written using the Mermaid `erDiagram` syntax.  
   - To view the ERD:
     - Copy the Mermaid code from the [Clinic ERD](clinic_erd.mmd)
     - Paste it into the [Mermaid Live Editor](https://mermaid.live/) to view and interact with the diagram.
     - For the diagram follow [View Clinic Management ERD](Clinic-mngmt-ERD.png)




## Summary
- The database supports comprehensive operations for a clinic management system.
- All corrections were applied to ensure re-runnable, error-free SQL scripts.
- The system now includes proper error handling for duplicate entries via `INSERT IGNORE`, trigger definitions with local variable scoping, and consistent best practices for MySQL development.

Feel free to update this code and README as new requirements or enhancements are introduced.

---

This `README.md` serves as thorough documentation of:
- The initial code and intended functionality.
- The corrections I introduced (duplicate handling, triggers, proper date defaults, etc.).
- The current state of the database, confirming that it has been successfully created with the sample data.

---

## Conclusion

If you see messages stating that rows were inserted without errors (like the successful insertion into the `person` table), it means the entire database schema was executed successfully, and the database now contains all the required tables, views, triggers, and sample data. The corrections ensured error-free re-runs and robust data integrity for your clinic management system.

Happy coding and database managing!
