USE DAMG6210_Group8_Hospital
-------------
--- VIEWS ---
-------------
CREATE OR ALTER VIEW PatientOverviewView AS
SELECT 
    p.patient_ID, 
    p.first_name, 
    p.last_name, 
    p.street, 
    p.city, 
    p.[state], 
    p.zip_code, 
    p.date_of_birth, 
    p.phone_number, 
    d.first_name AS doctor_first_name, 
    d.last_name AS doctor_last_name, 
    d.specialty
FROM 
    Patient p
LEFT JOIN 
    Appointment a ON p.patient_ID = a.patient_ID
LEFT JOIN 
    Doctor d ON a.doctor_ID = d.doctor_ID;
GO

CREATE OR ALTER VIEW PatientTreatmentHistoryView AS
SELECT 
    t.patient_ID, 
    t.[date], 
    ph.diagnosis, 
    ph.comments, 
    t.[type] AS treatment_type, 
    t.prescription, 
    d.first_name AS doctor_first_name, 
    d.last_name AS doctor_last_name
FROM 
    Treatment t
JOIN 
    PatientHistory ph ON t.patient_ID = ph.patient_ID AND t.[date] = ph.[date]
JOIN 
    Doctor d ON t.doctor_ID = d.doctor_ID;
GO

CREATE OR ALTER VIEW UpcomingAppointmentsView AS
SELECT 
    a.appointment_ID, 
    a.appointment_date, 
    a.appointment_location, 
    p.first_name AS patient_first_name, 
    p.last_name AS patient_last_name, 
    d.first_name AS doctor_first_name, 
    d.last_name AS doctor_last_name, 
    d.specialty
FROM 
    Appointment a
JOIN 
    Patient p ON a.patient_ID = p.patient_ID
JOIN 
    Doctor d ON a.doctor_ID = d.doctor_ID
WHERE 
    a.appointment_date >= CAST(GETDATE() AS DATE);
GO

CREATE OR ALTER VIEW DoctorScheduleView AS
SELECT TOP 100 PERCENT
    d.doctor_ID, 
    d.first_name AS doctor_first_name, 
    d.last_name AS doctor_last_name, 
    d.specialty, 
    a.appointment_date, 
    a.appointment_location,
    p.first_name AS patient_first_name, 
    p.last_name AS patient_last_name
FROM 
    Doctor d
JOIN 
    Appointment a ON d.doctor_ID = a.doctor_ID
JOIN 
    Patient p ON a.patient_ID = p.patient_ID
ORDER BY 
    a.appointment_date, d.doctor_ID;
GO

CREATE OR ALTER VIEW PatientInsuranceView AS
SELECT 
    p.patient_ID, 
    p.first_name AS patient_first_name, 
    p.last_name AS patient_last_name, 
    i.policy_ID, 
    i.provider, 
    i.coverage
FROM 
    Patient p
JOIN 
    Insurance i ON p.patient_ID = i.patient_ID;
GO

CREATE OR ALTER VIEW TreatmentPrescriptionView AS
SELECT 
    t.patient_ID, 
    t.[date], 
    t.[type] AS treatment_type, 
    t.prescription, 
    d.first_name AS doctor_first_name, 
    d.last_name AS doctor_last_name
FROM 
    Treatment t
JOIN 
    Doctor d ON t.doctor_ID = d.doctor_ID
JOIN 
    Patient p ON t.patient_ID = p.patient_ID;
GO

-------------------------
--- STORED PROCEDURES ---
-------------------------

-- ScheduleAppointmentWithPreCheck
CREATE OR ALTER PROCEDURE ScheduleAppointmentWithPreCheck
    @PatientID INT,
    @DoctorID INT,
    @AppointmentDate DATE,
    @AppointmentLocation VARCHAR(10),
    @IsScheduled BIT OUTPUT
AS
BEGIN
    SET @IsScheduled = 0;

    BEGIN TRY
        BEGIN TRANSACTION;
		IF EXISTS (
            SELECT 1
            FROM Appointment
            WHERE doctor_ID = @DoctorID AND appointment_date = @AppointmentDate
        )
        BEGIN
            SET @IsScheduled = 0;
            GOTO EndProcedure;
        END
		INSERT INTO Appointment (patient_ID, doctor_ID, appointment_date, appointment_location)
        VALUES (@PatientID, @DoctorID, @AppointmentDate, @AppointmentLocation);
		SET @IsScheduled = 1;
		COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @IsScheduled = 0; 
    END CATCH
    EndProcedure: 
END
GO


-- CompleteTreatmentAndUpdateInventory
CREATE TYPE dbo.InventoryItemType AS TABLE(
    ItemID INT,
    QuantityUsed INT
);
GO

CREATE OR ALTER PROCEDURE CompleteTreatmentAndUpdateInventory
    @TreatmentID INT,
    @Diagnosis VARCHAR(50),
    @Comments VARCHAR(100),
    @InventoryItems dbo.InventoryItemType READONLY 
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PatientID INT, @Date DATE;
    
    SELECT @PatientID = patient_ID, @Date = [date] FROM Treatment WHERE treatment_ID = @TreatmentID;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS(SELECT 1 FROM PatientHistory WHERE patient_ID = @PatientID AND [date] = @Date)
        BEGIN
            INSERT INTO PatientHistory(patient_ID, [date], diagnosis, comments)
            VALUES (@PatientID, @Date, @Diagnosis, @Comments);
        END
        DECLARE @ItemID INT, @QuantityUsed INT;
        DECLARE cur CURSOR FOR SELECT ItemID, QuantityUsed FROM @InventoryItems;
        OPEN cur;
        FETCH NEXT FROM cur INTO @ItemID, @QuantityUsed;
        WHILE @@FETCH_STATUS = 0
        BEGIN
           FETCH NEXT FROM cur INTO @ItemID, @QuantityUsed;
        END
        CLOSE cur;
        DEALLOCATE cur;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
    END CATCH
END
GO


-- GenerateMonthlyBillingReport
CREATE OR ALTER PROCEDURE GenerateDetailedMonthlyBillingReport
    @Year INT,
    @Month INT
AS
BEGIN
    SELECT 
        p.patient_ID,
        p.first_name + ' ' + p.last_name AS PatientName,
        COUNT(DISTINCT a.appointment_ID) AS AppointmentCount,
        SUM(b.total_amount) AS TotalBilled
    FROM 
        Bill b
        INNER JOIN Patient p ON b.patient_ID = p.patient_ID
        LEFT JOIN Appointment a ON p.patient_ID = a.patient_ID
                                   AND YEAR(a.appointment_date) = @Year
                                   AND MONTH(a.appointment_date) = @Month
    WHERE 
        YEAR(b.bill_date) = @Year AND MONTH(b.bill_date) = @Month
    GROUP BY 
        p.patient_ID, p.first_name, p.last_name;
END
GO

-- AdjustPatientBill
CREATE or ALTER PROCEDURE AdjustPatientBill
    @BillID INT,
    @Amount DECIMAL(10, 2),
    @AdjustmentType VARCHAR(10), -- 'Charge' or 'Credit'
    @AdjustedAmount DECIMAL(10, 2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;    
        IF @AdjustmentType = 'Charge'
        BEGIN
            UPDATE Bill SET total_amount = total_amount + @Amount WHERE bill_ID = @BillID;
        END
        ELSE IF @AdjustmentType = 'Credit'
        BEGIN
            UPDATE Bill SET total_amount = total_amount - @Amount WHERE bill_ID = @BillID;
        END
		SELECT @AdjustedAmount = total_amount FROM Bill WHERE bill_ID = @BillID;
        INSERT INTO BillAdjustmentLog(bill_ID, adjustment_amount, adjustment_type, adjustment_date)
        VALUES (@BillID, @Amount, @AdjustmentType, GETDATE());
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @AdjustedAmount = -1; -- Indicate error
    END CATCH
END
GO


--ScheduleTreatmentAndCheckInventory
CREATE TYPE InventoryItemTableType AS TABLE(
    ItemID INT,
    QuantityUsed INT
)
GO

CREATE OR ALTER PROCEDURE ScheduleTreatmentAndCheckInventory
    @PatientID INT,
    @DoctorID INT,
    @TreatmentDate DATE,
    @TreatmentType VARCHAR(20),
    @InventoryItems InventoryItemTableType READONLY,
    @IsScheduled BIT OUTPUT,
    @InventoryShortage BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IsScheduled = 0;
    SET @InventoryShortage = 0;
    DECLARE @ErrorMessage NVARCHAR(4000);
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @ItemID INT, @QuantityUsed INT, @AvailableQuantity INT;
        DECLARE inventory_cursor CURSOR FOR
            SELECT ItemID, QuantityUsed FROM @InventoryItems;
        OPEN inventory_cursor;
        FETCH NEXT FROM inventory_cursor INTO @ItemID, @QuantityUsed;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT @AvailableQuantity = quantity FROM Inventory WHERE inventory_ID = @ItemID;
            IF @AvailableQuantity < @QuantityUsed
            BEGIN
                SET @InventoryShortage = 1;
                SET @ErrorMessage = 'Not enough inventory for item ID: ' + CAST(@ItemID AS VARCHAR(10));
                THROW 50000, @ErrorMessage, 1; -- Using the prepared message
            END
            UPDATE Inventory SET quantity = quantity - @QuantityUsed WHERE inventory_ID = @ItemID;
            FETCH NEXT FROM inventory_cursor INTO @ItemID, @QuantityUsed;
        END
        CLOSE inventory_cursor;
        DEALLOCATE inventory_cursor;
        IF @InventoryShortage = 0
        BEGIN
            INSERT INTO Treatment(patient_ID, doctor_ID, [date], [type])
            VALUES (@PatientID, @DoctorID, @TreatmentDate, @TreatmentType);
            SET @IsScheduled = 1; 
		END
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @IsScheduled = 0;
    END CATCH
END
GO

-- GenerateDoctorActivityReport
CREATE OR ALTER PROCEDURE GenerateDoctorActivityReport
    @DoctorID INT,
    @ReportMonth INT,
    @ReportYear INT,
    @TreatmentCount INT OUTPUT,
    @PatientCount INT OUTPUT,
    @TotalBilling DECIMAL(18,2) OUTPUT
AS
BEGIN
    SELECT 
        @TreatmentCount = COUNT(DISTINCT t.treatment_ID),
        @PatientCount = COUNT(DISTINCT t.patient_ID),
        @TotalBilling = SUM(b.total_amount)
    FROM 
        Treatment t
    JOIN 
        Bill b ON t.patient_ID = b.patient_ID
    WHERE 
        t.doctor_ID = @DoctorID
        AND MONTH(t.[date]) = @ReportMonth
        AND YEAR(t.[date]) = @ReportYear;
END
GO