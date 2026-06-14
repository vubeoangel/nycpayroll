-- 1 Agency Master
CREATE TABLE NYC_Payroll_AGENCY_MD (
    AgencyID        VARCHAR(10),
    AgencyName      VARCHAR(50)
);

-- 2 Employee Master
CREATE TABLE NYC_Payroll_EMP_MD (
    EmployeeID      VARCHAR(10),
    LastName        VARCHAR(20),
    FirstName       VARCHAR(20)
);

-- 3 Title Master
CREATE TABLE NYC_Payroll_TITLE_MD (
    TitleCode     VARCHAR(10),
    TitleDescription VARCHAR(100)
);

-- 4 Payroll 2020
CREATE TABLE NYC_Payroll_Data_2020 (
    FiscalYear        INT,
    PayrollNumber     INT,
    AgencyID          VARCHAR(10),
    AgencyName        VARCHAR(50),
    EmployeeID        VARCHAR(10),
    LastName          VARCHAR(20),
    FirstName         VARCHAR(20),
    AgencyStartDate   DATE,
    WorkLocationBorough VARCHAR(50),
    TitleCode         VARCHAR(10),
    TitleDescription  VARCHAR(100),
    LeaveStatusasofJune30 VARCHAR(50),
    BaseSalary        FLOAT,
    PayBasis          VARCHAR(50),
    RegularHours      FLOAT,
    RegularGrossPaid  FLOAT,
    OTHours           FLOAT,
    TotalOTPaid       FLOAT,
    TotalOtherPay     FLOAT
);

-- 5. Payroll 2021 
CREATE TABLE NYC_Payroll_Data_2021 (
    FiscalYear        INT,
    PayrollNumber     INT,
    AgencyID          VARCHAR(10),
    AgencyName        VARCHAR(50),
    EmployeeID        VARCHAR(10),
    LastName          VARCHAR(20),
    FirstName         VARCHAR(20),
    AgencyStartDate   DATE,
    WorkLocationBorough VARCHAR(50),
    TitleCode         VARCHAR(10),
    TitleDescription  VARCHAR(100),
    LeaveStatusasofJune30 VARCHAR(50),
    BaseSalary        FLOAT,
    PayBasis          VARCHAR(50),
    RegularHours      FLOAT,
    RegularGrossPaid  FLOAT,
    OTHours           FLOAT,
    TotalOTPaid       FLOAT,
    TotalOtherPay     FLOAT
);


-- 6. Summary table (ADF dump)
CREATE TABLE NYC_Payroll_Summary (
    FiscalYear    INT,
    AgencyName    VARCHAR(50),
    TotalPaid     FLOAT
);