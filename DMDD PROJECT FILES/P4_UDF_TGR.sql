USE DAMG6210_Group8_Hospital
GO
----------------
--- TRIGGERS ---
----------------

-- Delete Trigger for Patient History
CREATE OR ALTER TRIGGER onDelete_PatientHistory
ON PatientHistory
FOR DELETE
AS
BEGIN
    INSERT INTO DeletedPatientHistory (patient_ID, [date], diagnosis, comments)
    SELECT patient_ID, [date], diagnosis, comments
	FROM deleted
END
GO

-- Insert trigger for Appointment
CREATE OR ALTER TRIGGER onInsert_Appointment
ON Appointment
FOR INSERT
AS
BEGIN
    INSERT INTO AppointmentLog (appointment_ID, patient_ID, doctor_ID, appointment_date, appointment_location)
    SELECT appointment_ID, patient_ID, doctor_ID, appointment_date, appointment_location
	FROM inserted
END
GO

------------
--- UDFs ---
------------

CREATE FUNCTION CalculateAge (@dob date) 
RETURNS int
AS
BEGIN
    DECLARE @age int;
    -- Calculate age based on current date and dob
    SET @age = YEAR(GETDATE()) - YEAR(@dob);
    RETURN @age
END
GO
-- Create column using UDF
ALTER TABLE Patient
ADD age int;

UPDATE Patient
SET age = dbo.CalculateAge(date_of_birth)
FROM Patient

select * from Patient

--UDF 2--
CREATE FUNCTION dbo.IsDoctorAvailable(@doctorID int)
RETURNS bit
AS
BEGIN
    DECLARE @isAvailable bit;

    IF EXISTS (SELECT 1 
               FROM Appointment 
               WHERE doctor_ID = @doctorID 
                 AND CAST(appointment_date AS date) = CAST(GETDATE() AS date))
    BEGIN
        SET @isAvailable = 0; -- Not available
    END
    ELSE
    BEGIN
        SET @isAvailable = 1; -- Available
    END

    RETURN @isAvailable; 
END
GO


-- Add a non-persisted computed column to Doctor table
ALTER TABLE Doctor 
ADD is_available AS dbo.IsDoctorAvailable(doctor_ID);

-- Querying the Doctor table to see the computed value
SELECT doctor_ID, is_available FROM Doctor;




CREATE FUNCTION dbo.GetStockStatus(@inventoryID int, @threshold int)
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @quantity int;
    DECLARE @status VARCHAR(10);

    SELECT @quantity = quantity FROM Inventory WHERE inventory_ID = @inventoryID;

    SET @status = CASE 
                     WHEN @quantity > @threshold THEN 'high'
                     WHEN @quantity < @threshold THEN 'low'
                     ELSE 'normal' -- Optional: Add a 'normal' case if needed
                  END;

    RETURN @status;
END
GO

ALTER TABLE Inventory ADD stock_status varchar(10);

DECLARE @threshold INT = 50;

UPDATE Inventory
SET stock_status = dbo.GetStockStatus(inventory_ID, @threshold);




select * from Inventory




