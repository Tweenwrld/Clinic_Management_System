
CREATE DATABASE clinic_management;

USE clinic_management;


-- =============================================
-- TABLES FOR PEOPLE AND USERS
-- =============================================

-- Table for storing all user account information
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    user_role ENUM('admin', 'doctor', 'nurse', 'receptionist', 'patient', 'lab_technician') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_login DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_email_format CHECK (email REGEXP '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$')
);

-- Table for common person information
CREATE TABLE person (
    person_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other', 'Prefer not to say') NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) NOT NULL DEFAULT 'USA',
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_person_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    CONSTRAINT chk_phone_format CHECK (phone_number REGEXP '^[0-9\\-\\+\\(\\) ]{10,20}$')
);

-- =============================================
-- MEDICAL STAFF TABLES
-- =============================================

-- Table for departments
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    location VARCHAR(100),
    head_doctor_id INT,  -- Will add foreign key constraint after doctors table is created
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table for doctor specialties
CREATE TABLE specialties (
    specialty_id INT AUTO_INCREMENT PRIMARY KEY,
    specialty_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table for doctors
CREATE TABLE doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    person_id INT NOT NULL,
    department_id INT NOT NULL,
    license_number VARCHAR(50) NOT NULL UNIQUE,
    qualification VARCHAR(255) NOT NULL,
    experience_years INT,
    consultation_fee DECIMAL(10, 2) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_doctor_person FOREIGN KEY (person_id) REFERENCES person(person_id) ON DELETE CASCADE,
    CONSTRAINT fk_doctor_department FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE RESTRICT
);

-- Adding the foreign key constraint back to departments
ALTER TABLE departments
ADD CONSTRAINT fk_department_head_doctor FOREIGN KEY (head_doctor_id) REFERENCES doctors(doctor_id) ON DELETE SET NULL;

-- Mapping table for doctor specialties (many-to-many)
CREATE TABLE doctor_specialties (
    doctor_id INT NOT NULL,
    specialty_id INT NOT NULL,
    PRIMARY KEY (doctor_id, specialty_id),
    CONSTRAINT fk_doctor_specialties_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE CASCADE,
    CONSTRAINT fk_doctor_specialties_specialty FOREIGN KEY (specialty_id) REFERENCES specialties(specialty_id) ON DELETE CASCADE
);

-- Table for nurses
CREATE TABLE nurses (
    nurse_id INT AUTO_INCREMENT PRIMARY KEY,
    person_id INT NOT NULL,
    department_id INT NOT NULL,
    license_number VARCHAR(50) NOT NULL UNIQUE,
    is_head_nurse BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_nurse_person FOREIGN KEY (person_id) REFERENCES person(person_id) ON DELETE CASCADE,
    CONSTRAINT fk_nurse_department FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE RESTRICT
);

-- Table for staff (receptionists, lab technicians, etc.)
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    person_id INT NOT NULL,
    department_id INT NOT NULL,
    position VARCHAR(100) NOT NULL,
    hire_date DATE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_staff_person FOREIGN KEY (person_id) REFERENCES person(person_id) ON DELETE CASCADE,
    CONSTRAINT fk_staff_department FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE RESTRICT
);

-- =============================================
-- PATIENT RELATED TABLES
-- =============================================

-- Table for insurance providers
CREATE TABLE insurance_providers (
    provider_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_name VARCHAR(100) NOT NULL UNIQUE,
    contact_phone VARCHAR(20) NOT NULL,
    contact_email VARCHAR(100),
    address VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table for patients
CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    person_id INT NOT NULL,
    blood_group ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Unknown') DEFAULT 'Unknown',
    allergies TEXT,
    ongoing_medications TEXT,
    registration_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    insurance_provider_id INT,
    insurance_policy_number VARCHAR(100),
    insurance_expiry_date DATE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_patient_person FOREIGN KEY (person_id) REFERENCES person(person_id) ON DELETE CASCADE,
    CONSTRAINT fk_patient_insurance FOREIGN KEY (insurance_provider_id) REFERENCES insurance_providers(provider_id) ON DELETE SET NULL
);

-- Table for medical history
CREATE TABLE medical_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    condition_name VARCHAR(255) NOT NULL,
    diagnosis_date DATE,
    treatment_summary TEXT,
    is_chronic BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_history_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE
);

-- =============================================
-- APPOINTMENT AND SCHEDULING TABLES
-- =============================================

-- Table for appointment statuses
CREATE TABLE appointment_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert default appointment statuses
INSERT INTO appointment_status (status_name, description) VALUES
('Scheduled', 'Appointment has been scheduled'),
('Confirmed', 'Appointment has been confirmed'),
('Completed', 'Appointment has been completed'),
('Cancelled', 'Appointment has been cancelled'),
('No-Show', 'Patient did not show up for the appointment'),
('Rescheduled', 'Appointment has been rescheduled');

-- Table for appointments
CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    department_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status_id INT NOT NULL,
    reason_for_visit TEXT NOT NULL,
    notes TEXT,
    created_by INT NOT NULL,  -- User who created the appointment
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_appointment_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE RESTRICT,
    CONSTRAINT fk_appointment_department FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE RESTRICT,
    CONSTRAINT fk_appointment_status FOREIGN KEY (status_id) REFERENCES appointment_status(status_id) ON DELETE RESTRICT,
    CONSTRAINT fk_appointment_created_by FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE RESTRICT,
    CONSTRAINT chk_appointment_time CHECK (end_time > start_time)
);

-- Table for doctor schedules
CREATE TABLE doctor_schedules (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id INT NOT NULL,
    day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    max_appointments INT DEFAULT 20,
    break_start TIME,
    break_end TIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_schedule_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE CASCADE,
    CONSTRAINT uc_doctor_day_time UNIQUE (doctor_id, day_of_week),
    CONSTRAINT chk_schedule_time CHECK (end_time > start_time),
    CONSTRAINT chk_break_time CHECK (break_end > break_start)
);

-- Table for doctor time-off
CREATE TABLE doctor_time_off (
    time_off_id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason ENUM('Vacation', 'Sick Leave', 'Conference', 'Personal', 'Other') NOT NULL,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_time_off_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE CASCADE,
    CONSTRAINT chk_time_off_dates CHECK (end_date >= start_date)
);

-- =============================================
-- MEDICAL RECORDS AND EXAMINATIONS
-- =============================================

-- Table for vitals
CREATE TABLE vitals (
    vital_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    appointment_id INT,
    recorded_by INT NOT NULL,  -- Staff/nurse who recorded
    temperature DECIMAL(5, 2),  -- in Celsius
    blood_pressure VARCHAR(20),  -- format: "120/80"
    heart_rate INT,  -- BPM
    respiratory_rate INT,  -- breaths per minute
    height DECIMAL(5, 2),  -- in cm
    weight DECIMAL(5, 2),  -- in kg
    oxygen_saturation DECIMAL(5, 2),  -- percentage
    blood_glucose DECIMAL(5, 2),  -- mg/dL
    recorded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_vitals_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_vitals_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE SET NULL,
    CONSTRAINT fk_vitals_recorder FOREIGN KEY (recorded_by) REFERENCES users(user_id) ON DELETE RESTRICT
);

-- Table for medical records
CREATE TABLE medical_records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    appointment_id INT NOT NULL,
    doctor_id INT NOT NULL,
    diagnosis TEXT NOT NULL,
    treatment_plan TEXT NOT NULL,
    notes TEXT,
    followup_required BOOLEAN DEFAULT FALSE,
    followup_date DATE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_record_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_record_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE CASCADE,
    CONSTRAINT fk_record_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE RESTRICT
);

-- =============================================
-- MEDICATIONS AND PHARMACY
-- =============================================

-- Table for medication categories
CREATE TABLE medication_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table for medications/drugs
CREATE TABLE medications (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    medication_name VARCHAR(255) NOT NULL,
    generic_name VARCHAR(255) NOT NULL,
    manufacturer VARCHAR(100),
    description TEXT,
    dosage_form ENUM('Tablet', 'Capsule', 'Liquid', 'Injection', 'Topical', 'Inhaler', 'Other') NOT NULL,
    strength VARCHAR(50) NOT NULL,  -- e.g., "500mg", "50mg/ml"
    requires_prescription BOOLEAN DEFAULT TRUE,
    in_stock BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_medication_category FOREIGN KEY (category_id) REFERENCES medication_categories(category_id) ON DELETE SET NULL
);

-- Table for prescriptions
CREATE TABLE prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    medical_record_id INT,
    prescribed_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    expiry_date DATE NOT NULL,
    status ENUM('Issued', 'Filled', 'Partially Filled', 'Expired', 'Cancelled') DEFAULT 'Issued',
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_prescription_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_prescription_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE RESTRICT,
    CONSTRAINT fk_prescription_record FOREIGN KEY (medical_record_id) REFERENCES medical_records(record_id) ON DELETE SET NULL,
    CONSTRAINT chk_prescription_dates CHECK (expiry_date >= prescribed_date)
);

-- Table for prescription items (medications in a prescription)
CREATE TABLE prescription_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    prescription_id INT NOT NULL,
    medication_id INT NOT NULL,
    dosage VARCHAR(100) NOT NULL,  -- e.g., "1 tablet"
    frequency VARCHAR(100) NOT NULL,  -- e.g., "twice daily"
    duration VARCHAR(100) NOT NULL,  -- e.g., "for 7 days"
    quantity INT NOT NULL,
    instructions TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_prescription_item_prescription FOREIGN KEY (prescription_id) REFERENCES prescriptions(prescription_id) ON DELETE CASCADE,
    CONSTRAINT fk_prescription_item_medication FOREIGN KEY (medication_id) REFERENCES medications(medication_id) ON DELETE RESTRICT
);

-- =============================================
-- LABORATORY AND DIAGNOSTICS
-- =============================================

-- Table for lab test categories
CREATE TABLE lab_test_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table for lab tests
CREATE TABLE lab_tests (
    test_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    test_name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    normal_range VARCHAR(100),
    price DECIMAL(10, 2) NOT NULL,
    preparation_instructions TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_test_category FOREIGN KEY (category_id) REFERENCES lab_test_categories(category_id) ON DELETE SET NULL
);

-- Table for lab orders
CREATE TABLE lab_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_id INT,
    ordered_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    status ENUM('Ordered', 'Collected', 'In Progress', 'Completed', 'Cancelled') DEFAULT 'Ordered',
    priority ENUM('Routine', 'Urgent', 'STAT') DEFAULT 'Routine',
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_lab_order_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_lab_order_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE RESTRICT,
    CONSTRAINT fk_lab_order_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE SET NULL
);

-- Table for lab order items (tests in an order)
CREATE TABLE lab_order_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    test_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_lab_order_item_order FOREIGN KEY (order_id) REFERENCES lab_orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_lab_order_item_test FOREIGN KEY (test_id) REFERENCES lab_tests(test_id) ON DELETE RESTRICT
);

-- Table for lab results
CREATE TABLE lab_results (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    order_item_id INT NOT NULL,
    technician_id INT NOT NULL,  -- Staff who performed the test
    result_value TEXT NOT NULL,
    is_abnormal BOOLEAN DEFAULT FALSE,
    performed_date DATETIME NOT NULL,
    verified_by INT,  -- Doctor who verified the results
    verified_date DATETIME,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_lab_result_order_item FOREIGN KEY (order_item_id) REFERENCES lab_order_items(item_id) ON DELETE CASCADE,
    CONSTRAINT fk_lab_result_technician FOREIGN KEY (technician_id) REFERENCES staff(staff_id) ON DELETE RESTRICT,
    CONSTRAINT fk_lab_result_verifier FOREIGN KEY (verified_by) REFERENCES doctors(doctor_id) ON DELETE SET NULL
);

-- =============================================
-- BILLING AND PAYMENTS
-- =============================================

-- Table for service categories
CREATE TABLE service_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table for services
CREATE TABLE services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    service_name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    duration_minutes INT,
    price DECIMAL(10, 2) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_service_category FOREIGN KEY (category_id) REFERENCES service_categories(category_id) ON DELETE SET NULL
);

-- Table for invoices
CREATE TABLE invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    appointment_id INT,
    invoice_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    discount_amount DECIMAL(10, 2) DEFAULT 0.00,
    tax_amount DECIMAL(10, 2) DEFAULT 0.00,
    payable_amount DECIMAL(10, 2) NOT NULL,  -- total_amount - discount_amount + tax_amount
    status ENUM('Pending', 'Paid', 'Partially Paid', 'Overdue', 'Cancelled') DEFAULT 'Pending',
    notes TEXT,
    created_by INT NOT NULL,  -- User who created the invoice
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_invoice_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_invoice_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE SET NULL,
    CONSTRAINT fk_invoice_created_by FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE RESTRICT,
    CONSTRAINT chk_invoice_dates CHECK (due_date >= invoice_date),
    CONSTRAINT chk_payable_amount CHECK (payable_amount = total_amount - discount_amount + tax_amount)
);

-- Table for invoice items
CREATE TABLE invoice_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT NOT NULL,
    item_type ENUM('Service', 'Lab Test', 'Medication', 'Other') NOT NULL,
    item_id_ref INT NOT NULL,  -- service_id, test_id, medication_id, etc.
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    discount_percent DECIMAL(5, 2) DEFAULT 0.00,
    total_price DECIMAL(10, 2) NOT NULL,  -- (unit_price * quantity) * (1 - discount_percent/100)
    description VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_invoice_item_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE,
    CONSTRAINT chk_total_price CHECK (total_price = (unit_price * quantity) * (1 - discount_percent/100))
);

-- Table for payments
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT NOT NULL,
    payment_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Insurance', 'Online Transfer', 'Check', 'Other') NOT NULL,
    transaction_reference VARCHAR(100),
    received_by INT NOT NULL,  -- User who received the payment
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE,
    CONSTRAINT fk_payment_received_by FOREIGN KEY (received_by) REFERENCES users(user_id) ON DELETE RESTRICT
);

-- Table for insurance claims
CREATE TABLE insurance_claims (
    claim_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT NOT NULL,
    insurance_provider_id INT NOT NULL,
    patient_id INT NOT NULL,
    claim_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    claim_amount DECIMAL(10, 2) NOT NULL,
    approved_amount DECIMAL(10, 2),
    status ENUM('Submitted', 'In Processing', 'Approved', 'Partially Approved', 'Rejected', 'Settled') DEFAULT 'Submitted',
    rejection_reason TEXT,
    claim_reference VARCHAR(100),
    submitted_by INT NOT NULL,  -- User who submitted the claim
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_claim_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE,
    CONSTRAINT fk_claim_provider FOREIGN KEY (insurance_provider_id) REFERENCES insurance_providers(provider_id) ON DELETE RESTRICT,
    CONSTRAINT fk_claim_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_claim_submitted_by FOREIGN KEY (submitted_by) REFERENCES users(user_id) ON DELETE RESTRICT
);

-- =============================================
-- INVENTORY MANAGEMENT
-- =============================================

-- Table for suppliers
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    phone_number VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    address VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50) DEFAULT 'USA',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table for inventory categories
CREATE TABLE inventory_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table for inventory items
CREATE TABLE inventory_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    item_name VARCHAR(255) NOT NULL,
    description TEXT,
    current_stock INT NOT NULL DEFAULT 0,
    minimum_stock INT NOT NULL DEFAULT 10,
    unit_of_measure VARCHAR(50) NOT NULL DEFAULT 'Each',
    unit_cost DECIMAL(10, 2) NOT NULL,
    expiry_date DATE,
    location VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_category FOREIGN KEY (category_id) REFERENCES inventory_categories(category_id) ON DELETE SET NULL,
    CONSTRAINT chk_current_stock CHECK (current_stock >= 0)
);

-- Table for inventory transactions
CREATE TABLE inventory_transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    transaction_type ENUM('Purchase', 'Usage', 'Return', 'Adjustment', 'Transfer') NOT NULL,
    quantity INT NOT NULL,
    transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reference_id INT,  -- Could be purchase_id, invoice_id, etc.
    reference_type VARCHAR(50),  -- 'Purchase', 'Invoice', etc.
    performed_by INT NOT NULL,  -- User who performed the transaction
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_transaction_item FOREIGN KEY (item_id) REFERENCES inventory_items(item_id) ON DELETE CASCADE,
    CONSTRAINT fk_transaction_performer FOREIGN KEY (performed_by) REFERENCES users(user_id) ON DELETE RESTRICT
);

-- Table for purchase orders
CREATE TABLE purchase_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    order_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    expected_delivery_date DATE,
    status ENUM('Draft', 'Pending', 'Approved', 'Ordered', 'Partially Received', 'Received', 'Cancelled') DEFAULT 'Draft',
    total_amount DECIMAL(10, 2) NOT NULL,
    payment_status ENUM('Pending', 'Partial', 'Paid') DEFAULT 'Pending',
    created_by INT NOT NULL,  -- User who created the purchase order
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_purchase_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE RESTRICT,
    CONSTRAINT fk_purchase_created_by FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE RESTRICT
);

-- Table for purchase order items
CREATE TABLE purchase_order_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    inventory_item_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,  -- unit_price * quantity
    received_quantity INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_purchase_item_order FOREIGN KEY (order_id) REFERENCES purchase_orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_purchase_item_inventory FOREIGN KEY (inventory_item_id) REFERENCES inventory_items(item_id) ON DELETE RESTRICT,
    CONSTRAINT chk_po_total_price CHECK (total_price = unit_price * quantity)
);

-- =============================================
-- SYSTEM AND AUDITING TABLES
-- =============================================

-- Table for system settings
CREATE TABLE system_settings (
    setting_id INT AUTO_INCREMENT PRIMARY KEY,
    setting_name VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT NOT NULL,
    data_type ENUM('string', 'integer', 'boolean', 'float', 'json') NOT NULL DEFAULT 'string',
    description TEXT,
    is_editable BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table for audit logs
CREATE TABLE audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,  -- 'patient', 'appointment', etc.
    entity_id INT NOT NULL,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Table for notifications
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    notification_type VARCHAR(50) NOT NULL,
    reference_id INT,  -- ID of the related entity (appointment, lab result, etc.)
    reference_type VARCHAR(50),  -- Type of the related entity
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notification_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Table for documents
CREATE TABLE documents (
    document_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    document_type VARCHAR(100) NOT NULL,
    title VARCHAR(255) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    file_size INT NOT NULL,  -- in bytes
    file_type VARCHAR(50) NOT NULL,  -- MIME type
    uploaded_by INT NOT NULL,  -- User who uploaded the document
    upload_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    CONSTRAINT fk_document_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_document_uploader FOREIGN KEY (uploaded_by) REFERENCES users(user_id) ON DELETE RESTRICT
);

-- =============================================
-- CREATE VIEWS FOR COMMON DATA NEEDS
-- =============================================

-- View for basic patient information
CREATE VIEW view_patient_info AS
SELECT 
    p.patient_id,
    per.first_name,
    per.last_name,
    per.date_of_birth,
    per.gender,
    per.phone_number,
    per.address,
    per.city,
    per.state,
    per.postal_code,
    p.blood_group,
    p.registration_date,
    ins.provider_name AS insurance_provider,
    p.insurance_policy_number,
    p.insurance_expiry_date
FROM 
    patients p
JOIN 
    person per ON p.person_id = per.person_id
LEFT JOIN 
    insurance_providers ins ON p.insurance_provider_id = ins.provider_id;

-- View for doctor information with department and specialties
CREATE OR REPLACE VIEW view_doctor_info AS
SELECT 
    d.doctor_id,
    per.first_name,
    per.last_name,
    per.phone_number,
    per.address,
    dept.department_name,
    d.license_number,
    d.qualification,
    d.experience_years,
    d.consultation_fee,
    GROUP_CONCAT(DISTINCT s.specialty_name ORDER BY s.specialty_name ASC SEPARATOR ', ') AS specialties
FROM 
    doctors d
JOIN 
    person per ON d.person_id = per.person_id
JOIN 
    departments dept ON d.department_id = dept.department_id
LEFT JOIN 
    doctor_specialties ds ON d.doctor_id = ds.doctor_id
LEFT JOIN 
    specialties s ON ds.specialty_id = s.specialty_id
JOIN 
    users u ON per.user_id = u.user_id
GROUP BY 
    d.doctor_id;

-- View for upcoming appointments
CREATE OR REPLACE VIEW view_upcoming_appointments AS
SELECT 
    a.appointment_id,
    a.appointment_date,
    a.start_time,
    a.end_time,
    p_info.first_name AS patient_first_name,
    p_info.last_name AS patient_last_name,
    p_info.phone_number AS patient_phone,
    d_info.first_name AS doctor_first_name,
    d_info.last_name AS doctor_last_name,
    dept.department_name,
    ast.status_name
FROM 
    appointments a
JOIN 
    view_patient_info p_info ON a.patient_id = p_info.patient_id
JOIN 
    view_doctor_info d_info ON a.doctor_id = d_info.doctor_id
JOIN 
    departments dept ON a.department_id = dept.department_id
JOIN 
    appointment_status ast ON a.status_id = ast.status_id
WHERE 
    a.appointment_date >= CURDATE()
    AND ast.status_name NOT IN ('Cancelled', 'Completed')
ORDER BY 
    a.appointment_date, a.start_time;

-- View for invoices with payment status
CREATE OR REPLACE VIEW view_invoice_payment_status AS
SELECT 
    i.invoice_id,
    i.patient_id,
    CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
    i.invoice_date,
    i.due_date,
    i.total_amount,
    i.discount_amount,
    i.tax_amount,
    i.payable_amount,
    i.status AS invoice_status,
    COALESCE(SUM(p.amount), 0) AS paid_amount,
    i.payable_amount - COALESCE(SUM(p.amount), 0) AS balance,
    CASE 
        WHEN i.payable_amount <= COALESCE(SUM(p.amount), 0) THEN 'Fully Paid'
        WHEN COALESCE(SUM(p.amount), 0) > 0 THEN 'Partially Paid'
        WHEN i.due_date < CURDATE() THEN 'Overdue'
        ELSE 'Pending'
    END AS payment_status
FROM 
    invoices i
JOIN 
    patients pat ON i.patient_id = pat.patient_id
JOIN 
    person per ON pat.person_id = per.person_id
LEFT JOIN 
    payments p ON i.invoice_id = p.invoice_id
GROUP BY 
    i.invoice_id;

-- View for medication inventory
CREATE OR REPLACE VIEW view_medication_inventory AS
SELECT 
    m.medication_id,
    m.medication_name,
    m.generic_name,
    mc.category_name,
    m.dosage_form,
    m.strength,
    i.current_stock,
    i.minimum_stock,
    CASE 
        WHEN i.current_stock <= i.minimum_stock THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status,
    i.unit_cost,
    i.expiry_date,
    CASE 
        WHEN i.expiry_date IS NOT NULL AND i.expiry_date < CURDATE() THEN 'Expired'
        WHEN i.expiry_date IS NOT NULL AND i.expiry_date < DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN 'Expiring Soon'
        ELSE 'Valid'
    END AS expiry_status
FROM 
    medications m
JOIN 
    inventory_items i ON m.medication_id = i.item_id
LEFT JOIN 
    medication_categories mc ON m.category_id = mc.category_id;

-- View for lab test results
CREATE OR REPLACE VIEW view_lab_test_results AS
SELECT 
    lr.result_id,
    pt.patient_id,
    CONCAT(per.first_name, ' ', per.last_name) AS patient_name,
    lo.order_id,
    lt.test_name,
    lr.result_value,
    lt.normal_range,
    lr.is_abnormal,
    lr.performed_date,
    CONCAT(doctor_per.first_name, ' ', doctor_per.last_name) AS ordered_by,
    CONCAT(tech_per.first_name, ' ', tech_per.last_name) AS performed_by,
    CASE 
        WHEN lr.verified_by IS NOT NULL THEN CONCAT(ver_per.first_name, ' ', ver_per.last_name)
        ELSE NULL
    END AS verified_by,
    lr.verified_date
FROM 
    lab_results lr
JOIN 
    lab_order_items loi ON lr.order_item_id = loi.item_id
JOIN 
    lab_orders lo ON loi.order_id = lo.order_id
JOIN 
    lab_tests lt ON loi.test_id = lt.test_id
JOIN 
    patients pt ON lo.patient_id = pt.patient_id
JOIN 
    person per ON pt.person_id = per.person_id
JOIN 
    doctors doc ON lo.doctor_id = doc.doctor_id
JOIN 
    person doctor_per ON doc.person_id = doctor_per.person_id
JOIN 
    staff tech ON lr.technician_id = tech.staff_id
JOIN 
    person tech_per ON tech.person_id = tech_per.person_id
LEFT JOIN 
    doctors ver_doc ON lr.verified_by = ver_doc.doctor_id
LEFT JOIN 
    person ver_per ON ver_doc.person_id = ver_per.person_id
ORDER BY 
    lr.performed_date DESC;

-- =============================================
-- TRIGGERS FOR DATA INTEGRITY AND AUTOMATION
-- =============================================

-- Trigger to update invoice status based on payments
DELIMITER //
DROP TRIGGER IF EXISTS after_payment_insert//
CREATE TRIGGER after_payment_insert
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
    DECLARE total_paid DECIMAL(10, 2);
    DECLARE invoice_total DECIMAL(10, 2);
    
    -- Calculate total paid for this invoice
    SELECT COALESCE(SUM(amount), 0) 
      INTO total_paid
      FROM payments
      WHERE invoice_id = NEW.invoice_id;
    
    -- Get the invoice's payable amount
    SELECT payable_amount 
      INTO invoice_total
      FROM invoices
      WHERE invoice_id = NEW.invoice_id;
    
    -- Update invoice status
    IF total_paid >= invoice_total THEN
        UPDATE invoices 
          SET status = 'Paid' 
          WHERE invoice_id = NEW.invoice_id;
    ELSE
        UPDATE invoices 
          SET status = 'Partially Paid' 
          WHERE invoice_id = NEW.invoice_id;
    END IF;
END//
DELIMITER ;

-- Trigger to update inventory after a transaction
DELIMITER //
DROP TRIGGER IF EXISTS after_inventory_transaction//
CREATE TRIGGER after_inventory_transaction
AFTER INSERT ON inventory_transactions
FOR EACH ROW
BEGIN
    DECLARE new_stock INT;
    DECLARE min_stock INT;
    
    -- Adjust stock based on transaction type
    IF NEW.transaction_type = 'Purchase' OR NEW.transaction_type = 'Return' THEN
        UPDATE inventory_items
          SET current_stock = current_stock + NEW.quantity
          WHERE item_id = NEW.item_id;
    ELSE
        UPDATE inventory_items
          SET current_stock = current_stock - NEW.quantity
          WHERE item_id = NEW.item_id;
    END IF;
    
    -- Retrieve updated stock details
    SELECT current_stock, minimum_stock 
      INTO new_stock, min_stock
      FROM inventory_items
      WHERE item_id = NEW.item_id;
    
    -- Create notification if the current stock falls below minimum stock
    IF new_stock <= min_stock THEN
        INSERT INTO notifications (user_id, title, message, notification_type, reference_id, reference_type)
        SELECT u.user_id, 'Low Stock Alert',
               CONCAT('Item "', 
                      (SELECT item_name FROM inventory_items WHERE item_id = NEW.item_id),
                      '" is running low (', new_stock, ' remaining)'),
               'Inventory', NEW.item_id, 'InventoryItem'
        FROM users u
        WHERE u.user_role = 'admin';
    END IF;
END//
DELIMITER ;

-- Trigger to create notification for new appointments
DELIMITER //
DROP TRIGGER IF EXISTS after_appointment_insert//
CREATE TRIGGER after_appointment_insert
AFTER INSERT ON appointments
FOR EACH ROW
BEGIN
    -- Notification for the doctor
    INSERT INTO notifications (user_id, title, message, notification_type, reference_id, reference_type)
    SELECT u.user_id, 'New Appointment',
           CONCAT('You have a new appointment on ', 
                  DATE_FORMAT(NEW.appointment_date, '%M %d, %Y'),
                  ' at ', 
                  TIME_FORMAT(NEW.start_time, '%h:%i %p')),
           'Appointment', NEW.appointment_id, 'Appointment'
    FROM doctors d
    JOIN person p ON d.person_id = p.person_id
    JOIN users u ON p.user_id = u.user_id
    WHERE d.doctor_id = NEW.doctor_id;
    
    -- Notification for the patient
    INSERT INTO notifications (user_id, title, message, notification_type, reference_id, reference_type)
    SELECT u.user_id, 'Appointment Confirmation',
           CONCAT('Your appointment is scheduled for ', 
                  DATE_FORMAT(NEW.appointment_date, '%M %d, %Y'),
                  ' at ', 
                  TIME_FORMAT(NEW.start_time, '%h:%i %p')),
           'Appointment', NEW.appointment_id, 'Appointment'
    FROM patients pt
    JOIN person p ON pt.person_id = p.person_id
    JOIN users u ON p.user_id = u.user_id
    WHERE pt.patient_id = NEW.patient_id;
END//
DELIMITER ;

-- Trigger to log changes to patient data
DELIMITER //
DROP TRIGGER IF EXISTS after_patient_update//
CREATE TRIGGER after_patient_update
AFTER UPDATE ON patients
FOR EACH ROW
BEGIN
    DECLARE old_values JSON;
    DECLARE new_values JSON;
    DECLARE changer_id INT;
    
    -- Create JSON objects for old and new patient values
    SET old_values = JSON_OBJECT(
        'blood_group', OLD.blood_group,
        'allergies', OLD.allergies,
        'ongoing_medications', OLD.ongoing_medications,
        'insurance_provider_id', OLD.insurance_provider_id,
        'insurance_policy_number', OLD.insurance_policy_number,
        'insurance_expiry_date', OLD.insurance_expiry_date
    );
    
    SET new_values = JSON_OBJECT(
        'blood_group', NEW.blood_group,
        'allergies', NEW.allergies,
        'ongoing_medications', NEW.ongoing_medications,
        'insurance_provider_id', NEW.insurance_provider_id,
        'insurance_policy_number', NEW.insurance_policy_number,
        'insurance_expiry_date', NEW.insurance_expiry_date
    );
    
    -- Identify the user who made the change (assumes a one-to-one mapping between patients and person)
    SELECT user_id INTO changer_id
      FROM person
      WHERE person_id = (
            SELECT person_id 
              FROM patients 
              WHERE patient_id = NEW.patient_id
      );
    
    -- Insert the change into the audit log
    INSERT INTO audit_logs (user_id, action, entity_type, entity_id, old_values, new_values)
    VALUES (changer_id, 'UPDATE', 'patient', NEW.patient_id, old_values, new_values);
END//
DELIMITER ;

-- =============================================
-- INSERT SAMPLE DATA FOR TESTING
-- =============================================

-- Insert sample departments
INSERT IGNORE INTO departments (department_name, description, location) VALUES
('General Medicine', 'Department for general medical consultations and treatment', 'First Floor, Wing A'),
('Cardiology', 'Department for heart-related issues and treatments', 'Second Floor, Wing B'),
('Pediatrics', 'Department for child healthcare', 'First Floor, Wing C'),
('Orthopedics', 'Department for bone and joint issues', 'Third Floor, Wing A'),
('Dermatology', 'Department for skin related issues', 'Second Floor, Wing C');

-- Insert sample specialties
INSERT IGNORE INTO specialties (specialty_name, description) VALUES
('General Medicine', 'General medical practice and primary care'),
('Cardiology', 'Diagnosis and treatment of heart diseases'),
('Pediatrics', 'Medical care for infants, children, and adolescents'),
('Orthopedics', 'Diagnosis and treatment of musculoskeletal system'),
('Dermatology', 'Diagnosis and treatment of skin disorders');

-- Insert sample users
INSERT IGNORE INTO users (username, password_hash, email, user_role, is_active) VALUES
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin@clinic.com', 'admin', TRUE),
('doctor1', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'doctor1@clinic.com', 'doctor', TRUE),
('doctor2', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'doctor2@clinic.com', 'doctor', TRUE),
('nurse1', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'nurse1@clinic.com', 'nurse', TRUE),
('receptionist1', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'receptionist1@clinic.com', 'receptionist', TRUE),
('patient1', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'patient1@email.com', 'patient', TRUE),
('patient2', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'patient2@email.com', 'patient', TRUE);

-- Insert sample person data
INSERT IGNORE INTO person (user_id, first_name, last_name, date_of_birth, gender, phone_number, address, city, state, postal_code, country) VALUES
(1, 'Admin', 'User', '1980-01-15', 'Male', '555-123-4567', '123 Admin St', 'Adminville', 'NY', '10001', 'USA'),
(2, 'John', 'Smith', '1975-05-20', 'Male', '555-234-5678', '456 Doctor Ave', 'Medtown', 'CA', '90210', 'USA'),
(3, 'Sarah', 'Johnson', '1980-08-10', 'Female', '555-345-6789', '789 Medicine Blvd', 'Healthville', 'TX', '75001', 'USA'),
(4, 'Emma', 'Davis', '1990-03-25', 'Female', '555-456-7890', '101 Nurse St', 'Caretown', 'FL', '33101', 'USA'),
(5, 'Michael', 'Brown', '1985-11-12', 'Male', '555-567-8901', '202 Reception Rd', 'Welcometown', 'IL', '60601', 'USA'),
(6, 'Robert', 'Williams', '1970-07-15', 'Male', '555-678-9012', '303 Patient Ln', 'Healtown', 'PA', '19101', 'USA'),
(7, 'Linda', 'Jones', '1982-09-28', 'Female', '555-789-0123', '404 Client St', 'Wellness City', 'OH', '43201', 'USA');