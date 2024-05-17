CREATE DATABASE DAMG6210_Group8_Hospital
GO
USE DAMG6210_Group8_Hospital
GO

--------------
--- TABLES ---
--------------

CREATE TABLE Inventory (
	inventory_ID int PRIMARY KEY,
	[name] varchar(40) NOT NULL,
	[type] varchar(10) NOT NULL,
	quantity int NOT NULL DEFAULT 0
)


CREATE TABLE Department (
	department_ID int PRIMARY KEY,
	[name] varchar(30) NOT NULL,
	[location] varchar(10) NOT NULL,
)

CREATE TABLE Stock (
	inventory_ID int,
	department_ID int,
	CONSTRAINT stock_PK PRIMARY KEY (inventory_ID, department_ID),
	CONSTRAINT stock_FK1 FOREIGN KEY (inventory_ID)
		REFERENCES Inventory(inventory_ID),
	CONSTRAINT stock_FK2 FOREIGN KEY (department_ID)
		REFERENCES Department(department_ID)
)

CREATE TABLE Staff (
	employee_ID int PRIMARY KEY,
	first_name varchar(20) NOT NULL,
	last_name varchar(20) NOT NULL,
	[start_date] date NOT NULL,
	email varchar(40) NOT NULL,
	department_ID int, 
	CONSTRAINT staff_FK FOREIGN KEY (department_ID)
		REFERENCES Department(department_ID),
	is_nurse bit NOT NULL
)

CREATE TABLE Nurse (
	employee_ID int PRIMARY KEY,
	CONSTRAINT nurse_FK FOREIGN KEY (employee_ID)
		REFERENCES Staff(employee_ID)
)

CREATE TABLE Room (
	room_ID int PRIMARY KEY,
	floor_no int NOT NULL,
	employee_ID int,
	CONSTRAINT room_FK FOREIGN KEY (employee_ID) 
		REFERENCES Nurse(employee_ID)
)

CREATE TABLE Patient (
	patient_ID int PRIMARY KEY,
	first_name varchar(20) NOT NULL,
	last_name varchar(20) NOT NULL,
	street varchar(40) NOT NULL,
	city varchar(20) NOT NULL,
	[state] varchar(2) NOT NULL, 
	zip_code int NOT NULL,
	date_of_birth date NOT NULL,
	phone_number varchar(10),
	CONSTRAINT phone_CHK
		CHECK (LEN(phone_number) >= 9),
	emergency_contact_name varchar(40) NOT NULL,
	emergency_contact_number varchar(10),
	CONSTRAINT emer_phone_CHK 
		CHECK (LEN(emergency_contact_number) >= 9),
	admit_date date NOT NULL,
	patient_type varchar(1),
	CONSTRAINT patient_type_CHK 
		CHECK (patient_type IN ('O', 'R'))
)

CREATE TABLE Outpatient (
	patient_ID int PRIMARY KEY,
	CONSTRAINT outpatient_FK FOREIGN KEY (patient_ID)
		REFERENCES Patient(patient_ID),
	checkback_date date NOT NULL
)

CREATE TABLE ResidentPatient (
	patient_ID int PRIMARY KEY
	CONSTRAINT patient_FK FOREIGN KEY (patient_ID)
		REFERENCES Patient(patient_ID),
	discharged_date date NOT NULL,
	room_ID int NOT NULL,
	CONSTRAINT res_patient_FK FOREIGN KEY (room_ID)
		REFERENCES Room(room_ID)
)

CREATE TABLE Insurance (
	policy_ID int PRIMARY KEY,
	patient_ID int,
	CONSTRAINT insurance_FK FOREIGN KEY (patient_ID)
		REFERENCES Patient(patient_ID),
	[provider] varchar(20) NOT NULL,
	coverage varchar(15) NOT NULL
)

CREATE TABLE Bill (
	bill_ID int PRIMARY KEY,
	patient_ID int,
	CONSTRAINT bill_FK FOREIGN KEY (patient_ID)
		REFERENCES Patient(patient_ID),
	bill_date date NOT NULL,
	total_amount int NOT NULL,
	payment_method varchar(10)
	CONSTRAINT payment_CHK 
		CHECK (payment_method IN ('insurance', 'cash', 'credit', 'check'))
)

CREATE TABLE Doctor (
	doctor_ID int PRIMARY KEY,
	specialty varchar(30) NOT NULL,
	first_name varchar(20) NOT NULL,
	last_name varchar(20) NOT NULL,
	office_location varchar(10)
)

CREATE TABLE Appointment (
	appointment_ID int PRIMARY KEY,
	patient_ID int, 
	CONSTRAINT appointment_FK1 FOREIGN KEY (patient_ID)
		REFERENCES Patient(patient_ID),
	doctor_ID int,
	CONSTRAINT appointment_FK2 FOREIGN KEY (doctor_ID)
		REFERENCES Doctor(doctor_ID),
	appointment_date date NOT NULL,
	appointment_location varchar(10) NOT NULL
)

CREATE TABLE PatientHistory (
	patient_ID int,
	[date] date,
	CONSTRAINT history_PK PRIMARY KEY (patient_ID, [date]),
	CONSTRAINT history_FK FOREIGN KEY (patient_ID)
		REFERENCES Patient(patient_ID),
	diagnosis varchar(20) NOT NULL,
	comments varchar(50) NOT NULL
)

CREATE TABLE Treatment (
	treatment_ID int PRIMARY KEY,
	doctor_ID int,
	CONSTRAINT treatment_FK1 FOREIGN KEY (doctor_ID) 
		REFERENCES Doctor(doctor_ID),
	employee_ID int,
	CONSTRAINT treatment_FK2 FOREIGN KEY (employee_ID) 
		REFERENCES Nurse(employee_ID),
	patient_ID int,
	CONSTRAINT treatment_FK3 FOREIGN KEY (patient_ID) 
		REFERENCES Patient(patient_ID),
	[date] date,
	CONSTRAINT treatment_FK4 FOREIGN KEY (patient_ID, [date]) 
		REFERENCES PatientHistory(patient_ID, [date]),
	[type] varchar(30) NOT NULL,
	prescription varchar(30) NOT NULL
)

CREATE TABLE BillAdjustmentLog (
    log_ID INT IDENTITY PRIMARY KEY,
    bill_ID INT,
    adjustment_amount DECIMAL(10, 2),
    adjustment_type VARCHAR(10),
    adjustment_date DATETIME,
    FOREIGN KEY (bill_ID) REFERENCES Bill(bill_ID)
)

CREATE TABLE DeletedPatientHistory (
    patient_ID int,
    [date] date,
    diagnosis varchar(20) NOT NULL,
    comments varchar(50) NOT NULL
)

CREATE TABLE AppointmentLog (
    log_ID INTEGER PRIMARY KEY IDENTITY(1,1),
    appointment_ID INT,
    patient_ID INT,
    doctor_ID INT,
    appointment_date DATE,
    appointment_location VARCHAR(10),
    log_timestamp TIMESTAMP,
    FOREIGN KEY (appointment_ID) REFERENCES Appointment(appointment_ID),
    FOREIGN KEY (patient_ID) REFERENCES Patient(patient_ID),
    FOREIGN KEY (doctor_ID) REFERENCES Doctor(doctor_ID)
)

GO

-----------------------------
--- NON-CLUSTERED INDEXES ---
-----------------------------

CREATE NONCLUSTERED INDEX Idx_Patient_Name
	ON Patient(first_name, last_name)
GO

CREATE NONCLUSTERED INDEX Idx_Emp_Name
	ON Staff(first_name, last_name)
GO

CREATE NONCLUSTERED INDEX Idx_Doctor_Name
	ON Doctor(first_name, last_name)
GO

