-- Test Views
SELECT * 
FROM PatientOverviewView;

SELECT * 
FROM PatientTreatmentHistoryView;

SELECT *
FROM UpcomingAppointmentsView;

SELECT *
FROM DoctorScheduleView
ORDER BY appointment_date, doctor_ID;

SELECT *
FROM PatientInsuranceView;

SELECT *
FROM TreatmentPrescriptionView;

-- Test Stored Procedures

-- ScheduleAppointmentWithPreCheck
DECLARE @IsScheduled BIT;
EXEC ScheduleAppointmentWithPreCheck 
    @PatientID = 15, 
    @DoctorID = 4, 
    @AppointmentDate = '2023-08-15', 
    @AppointmentLocation = 'Loc005', 
    @IsScheduled = @IsScheduled OUTPUT;
PRINT 'Appointment Scheduled: ' + CASE WHEN @IsScheduled = 1 THEN 'Yes' ELSE 'No' END;


-- CompleteTreatmentAndUpdateInventory
DECLARE @InventoryItems AS dbo.InventoryItemType;
INSERT INTO @InventoryItems (ItemID, QuantityUsed) VALUES (1, 3), (2, 1);
DECLARE @TreatmentID INT = 1; 
DECLARE @Diagnosis VARCHAR(50) = 'Example Diagnosis';
DECLARE @Comments VARCHAR(100) = 'Example Comments';
EXEC CompleteTreatmentAndUpdateInventory @TreatmentID, @Diagnosis, @Comments, @InventoryItems;

-- GenerateDetailedMonthlyBillingReport
DECLARE @ReportYear INT = 2024;
DECLARE @ReportMonth INT = 3;
EXEC GenerateDetailedMonthlyBillingReport @Year = @ReportYear, @Month = @ReportMonth;

-- AdjustPatientBill
DECLARE @NewTotalAmount DECIMAL(10, 2);
EXEC AdjustPatientBill 
    @BillID = 12, 
    @Amount = 100.00, 
    @AdjustmentType = 'Charge', 
    @AdjustedAmount = @NewTotalAmount OUTPUT;
PRINT 'New Total Amount: ' + CONVERT(VARCHAR, @NewTotalAmount);

-- ScheduleTreatmentAndCheckInventory
DECLARE @InvItems InventoryItemTableType;
INSERT INTO @InvItems (ItemID, QuantityUsed) VALUES (1, 2), (2, 1);
DECLARE @Scheduled BIT, @Shortage BIT;
EXEC ScheduleTreatmentAndCheckInventory 
    @PatientID = 10, 
    @DoctorID = 5, 
    @TreatmentDate = '2023-08-15', 
    @TreatmentType = 'Physical Therapy', 
    @InventoryItems = @InvItems, 
    @IsScheduled = @Scheduled OUTPUT, 
    @InventoryShortage = @Shortage OUTPUT;
IF @Scheduled = 1
    PRINT 'Treatment scheduled successfully.';
ELSE IF @Shortage = 1
    PRINT 'Unable to schedule treatment due to inventory shortage.';
ELSE
    PRINT 'Treatment scheduling failed.';

-- GenerateDoctorActivityReport
DECLARE @TreatmentCount INT, @PatientCount INT, @TotalBilling DECIMAL(18,2);
EXEC GenerateDoctorActivityReport 
    @DoctorID = 1, 
    @ReportMonth = 6, 
    @ReportYear = 2023, 
    @TreatmentCount = @TreatmentCount OUTPUT, 
    @PatientCount = @PatientCount OUTPUT, 
    @TotalBilling = @TotalBilling OUTPUT;
PRINT 'Treatments: ' + CAST(@TreatmentCount AS VARCHAR) +
      ', Patients: ' + CAST(@PatientCount AS VARCHAR) +
      ', Total Billing: ' + CAST(@TotalBilling AS VARCHAR);


-- Test Triggers
INSERT INTO Appointment (appointment_ID, patient_ID, doctor_ID, appointment_date, appointment_location) VALUES
	(100, 2, 5, '2023-06-01', 'Loc001')


-- Test UDFs
SELECT date_of_birth, dbo.CalculateAge(date_of_birth) AS age
FROM patient
