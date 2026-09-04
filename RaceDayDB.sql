-- ============================================
-- RaceDay Database Script
-- Section C: SQL Database Script
-- Run on a clean SQL Server instance via SSMS.
-- ============================================

CREATE DATABASE RaceDayDB;
GO

USE RaceDayDB;
GO

-- ============================================
-- SCHEMA
-- ============================================

-- ---------- 1. Users ----------
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(150) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) NOT NULL,
    PhoneNumber NVARCHAR(20) NULL,
    DateOfBirth DATE NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT CHK_Users_Role CHECK (Role IN ('Organiser', 'Participant'))
);
GO

-- ---------- 2. Venues ----------
CREATE TABLE Venues (
    VenueID INT IDENTITY(1,1) PRIMARY KEY,
    VenueName NVARCHAR(150) NOT NULL,
    AddressLine NVARCHAR(200) NULL,
    City NVARCHAR(100) NOT NULL,
    Province NVARCHAR(50) NOT NULL,
    Latitude DECIMAL(9,6) NULL,
    Longitude DECIMAL(9,6) NULL
);
GO

-- ---------- 3. Events ----------
CREATE TABLE Events (
    EventID INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserID INT NOT NULL,
    VenueID INT NOT NULL,
    EventName NVARCHAR(150) NOT NULL,
    EventType NVARCHAR(20) NOT NULL,
    EventDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    DistanceKM DECIMAL(5,2) NULL,
    Description NVARCHAR(1000) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT CHK_Events_Type CHECK (EventType IN ('Run', 'Walk', 'Cycle')),
    CONSTRAINT FK_Events_Organiser FOREIGN KEY (OrganiserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Events_Venue FOREIGN KEY (VenueID) REFERENCES Venues(VenueID)
);
GO

-- ---------- 4. Categories ----------
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,
    DistanceKM DECIMAL(5,2) NOT NULL,
    MinAge INT NULL,
    EntryFee DECIMAL(8,2) NOT NULL DEFAULT 0,
    CONSTRAINT FK_Categories_Event FOREIGN KEY (EventID) REFERENCES Events(EventID) ON DELETE CASCADE
);
GO

-- ---------- 5. Enrolments ----------
CREATE TABLE Enrolments (
    EnrolmentID INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID INT NOT NULL,
    CategoryID INT NOT NULL,
    EnrolmentDate DATETIME NOT NULL DEFAULT GETDATE(),
    BibNumber NVARCHAR(10) NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Enrolled',
    CONSTRAINT CHK_Enrolments_Status CHECK (Status IN ('Enrolled', 'Cancelled')),
    CONSTRAINT FK_Enrolments_Participant FOREIGN KEY (ParticipantID) REFERENCES Users(UserID),
    CONSTRAINT FK_Enrolments_Category FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT UQ_Enrolments_Participant_Category UNIQUE (ParticipantID, CategoryID)
);
GO

-- ---------- 6. Results ----------
CREATE TABLE Results (
    ResultID INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID INT NOT NULL UNIQUE,
    CapturedByUserID INT NOT NULL,
    FinishTime TIME NULL,
    DistanceCoveredKM DECIMAL(5,2) NULL,
    Position INT NULL,
    Status NVARCHAR(20) NOT NULL,
    CapturedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT CHK_Results_Status CHECK (Status IN ('Finished', 'DNF', 'DNS')),
    CONSTRAINT FK_Results_Enrolment FOREIGN KEY (EnrolmentID) REFERENCES Enrolments(EnrolmentID),
    CONSTRAINT FK_Results_CapturedBy FOREIGN KEY (CapturedByUserID) REFERENCES Users(UserID)
);
GO

-- ============================================
-- SEED DATA
-- ============================================

-- ---------- Users (2 Organisers, 2 Participants) ----------
-- Note: PasswordHash values below are placeholders for planning purposes only.
-- In Part 2, real passwords will be hashed (e.g. via ASP.NET Core Identity / BCrypt) before insertion.

INSERT INTO Users (FullName, Email, PasswordHash, Role, PhoneNumber, DateOfBirth)
VALUES
('Thabo Nkosi', 'thabo.nkosi@raceday.co.za', 'HASHED_PASSWORD_1', 'Organiser', '0821234567', '1985-03-14'),
('Sarah van der Merwe', 'sarah.vdm@raceday.co.za', 'HASHED_PASSWORD_2', 'Organiser', '0837654321', '1990-07-22'),
('Lindiwe Dlamini', 'lindiwe.dlamini@gmail.com', 'HASHED_PASSWORD_3', 'Participant', '0721112223', '1996-11-05'),
('Michael Botha', 'michael.botha@gmail.com', 'HASHED_PASSWORD_4', 'Participant', '0834445556', '1993-01-30');
GO

-- ---------- Venues ----------
INSERT INTO Venues (VenueName, AddressLine, City, Province, Latitude, Longitude)
VALUES
('Comrades Marathon Start', 'City Hall, Church Street', 'Pietermaritzburg', 'KwaZulu-Natal', -29.600950, 30.379630),
('Green Point Athletics Stadium', 'Fritz Sonnenberg Road', 'Cape Town', 'Western Cape', -33.907290, 18.408500),
('Soweto Community Park', 'Vilakazi Street', 'Soweto', 'Gauteng', -26.238600, 27.905400);
GO

-- ---------- Events (3 events) ----------
INSERT INTO Events (OrganiserID, VenueID, EventName, EventType, EventDate, StartTime, DistanceKM, Description)
VALUES
(1, 1, 'Comrades Marathon 2026', 'Run', '2026-06-14', '05:30:00', 87.70, 'Iconic ultramarathon between Pietermaritzburg and Durban.'),
(2, 2, 'Cape Town Cycle Tour 2026', 'Cycle', '2026-03-08', '06:00:00', 109.00, 'Scenic cycling tour around the Cape Peninsula.'),
(1, 3, 'Soweto Charity Fun Walk 2026', 'Walk', '2026-09-20', '08:00:00', 5.00, 'Community fun walk raising funds for local schools.');
GO

-- ---------- Categories (2 per event) ----------
INSERT INTO Categories (EventID, CategoryName, DistanceKM, MinAge, EntryFee)
VALUES
(1, 'Senior (87km)', 87.70, 20, 950.00),
(1, 'Veteran 50+ (87km)', 87.70, 50, 950.00),
(2, '109km Cycle', 109.00, 18, 650.00),
(2, '56km Cycle', 56.00, 16, 450.00),
(3, '5km Fun Walk', 5.00, NULL, 50.00),
(3, 'Under 20 (5km)', 5.00, NULL, 30.00);
GO

-- ---------- Enrolments ----------
INSERT INTO Enrolments (ParticipantID, CategoryID, BibNumber, Status)
VALUES
(3, 1, 'CM1001', 'Enrolled'),  -- Lindiwe -> Comrades Senior
(3, 3, 'CT2001', 'Enrolled'),  -- Lindiwe -> Cape Town Cycle Tour 109km
(4, 5, 'SW3001', 'Enrolled'),  -- Michael -> Soweto Fun Walk 5km
(4, 4, 'CT2002', 'Enrolled');  -- Michael -> Cape Town Cycle Tour 56km
GO

-- ---------- Results ----------
-- Captured by an Organiser after the relevant event has taken place.
INSERT INTO Results (EnrolmentID, CapturedByUserID, FinishTime, DistanceCoveredKM, Position, Status)
VALUES
(1, 1, '08:45:12', NULL, 152, 'Finished'),   -- Lindiwe finished the Comrades in 8h45m, captured by Organiser 1
(2, 2, '03:12:40', NULL, 45, 'Finished'),    -- Lindiwe finished the Cycle Tour, captured by Organiser 2
(3, 1, NULL, 3.50, NULL, 'DNF');             -- Michael did not finish the Soweto walk; distance covered recorded instead
GO
