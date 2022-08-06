-- 1D: Creating a temporal table with hidden periods

CREATE TABLE dbo.CompanyLocation
(
  CompanyLocationId   INT                                            NOT NULL IDENTITY(1,1),
  CompanyLocationName VARCHAR(50)                                    NOT NULL,
  City                VARCHAR(50)                                    NOT NULL,
  ValidFrom           DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
  ValidTo             DATETIME2 GENERATED ALWAYS AS ROW END   HIDDEN NOT NULL,
  PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
  CONSTRAINT pkcCompanyLocation PRIMARY KEY CLUSTERED (CompanyLocationId)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.CompanyLocation_History))