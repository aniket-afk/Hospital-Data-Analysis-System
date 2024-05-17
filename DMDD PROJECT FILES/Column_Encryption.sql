-- Setting up Encryption Infrastructure

USE DAMG6210_Group8_Hospital
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Hospital@123!';
GO
CREATE CERTIFICATE HospitalCert WITH SUBJECT = 'Encryption Certificate for Hospital Management system';
GO
CREATE SYMMETRIC KEY HospitalSymmetricKey WITH ALGORITHM = AES_256 ENCRYPTION BY CERTIFICATE HospitalCert;
GO


-- Modify Tables for Encryption
-- CAR Table for Registration Number
ALTER TABLE PatientHistory ADD DiagnosisEncrypted VARBINARY(MAX);
ALTER TABLE Insurance ADD PolicyIDEncrypted VARBINARY(MAX);

-- Encrypt Column Data
OPEN SYMMETRIC KEY HospitalSymmetricKey DECRYPTION BY CERTIFICATE HospitalCert;
-- Encrypt CAR.RegistrationNumber
UPDATE PatientHistory
SET DiagnosisEncrypted = EncryptByKey(Key_GUID('HospitalSymmetricKey'), diagnosis, 1, HashBytes('SHA2_256', CONVERT(varbinary, diagnosis)));
GO

UPDATE Insurance
SET  PolicyIDEncrypted= EncryptByKey(Key_GUID('HospitalSymmetricKey'), CONVERT(varbinary, policy_ID), 1, HashBytes('SHA2_256', CONVERT(varbinary, policy_ID)));
GO

-- Encrypt BILLING.CreditCardNumber
CLOSE SYMMETRIC KEY HospitalSymmetricKey;
GO


SELECT * FROM PatientHistory;
SELECT * FROM Insurance;
