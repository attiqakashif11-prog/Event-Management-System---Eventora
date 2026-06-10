

USE master;


IF EXISTS (SELECT name FROM sys.databases WHERE name = 'EventoraDB')
    DROP DATABASE EventoraDB;


CREATE DATABASE EventoraDB;

USE EventoraDB;
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(150) UNIQUE NOT NULL,
    Password NVARCHAR(256) NOT NULL,         -- Plain text as requested
    Phone NVARCHAR(20),
    Role NVARCHAR(20) DEFAULT 'User',        -- Admin, User, Organizer
    ProfilePicture NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    IconPath NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE Venues (
    VenueID INT IDENTITY(1,1) PRIMARY KEY,
    VenueName NVARCHAR(150) NOT NULL,
    Location NVARCHAR(300) NOT NULL,
    Capacity INT NOT NULL,
    Phone NVARCHAR(20),
    Email NVARCHAR(150),
    Description NVARCHAR(1000),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE Organizers (
    OrganizerID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    Email NVARCHAR(150) UNIQUE NOT NULL,
    Phone NVARCHAR(20),
    Organization NVARCHAR(200),
    Bio NVARCHAR(1000),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Events (
    EventID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    ShortDescription NVARCHAR(500),
    Description NVARCHAR(MAX),
    EventDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    VenueID INT FOREIGN KEY REFERENCES Venues(VenueID),
    CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID),
    OrganizerID INT FOREIGN KEY REFERENCES Organizers(OrganizerID),
    CreatedByUserID INT FOREIGN KEY REFERENCES Users(UserID),
    EventType NVARCHAR(20) DEFAULT 'Public',
    Status NVARCHAR(20) DEFAULT 'Upcoming',  
    ApprovalStatus NVARCHAR(20) DEFAULT 'Pending', 
    AvailableSeats INT DEFAULT 0,
    TotalRevenue DECIMAL(18,2) DEFAULT 0,
    ImagePath NVARCHAR(500),
    Tags NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE TicketTypes (
    TicketTypeID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT FOREIGN KEY REFERENCES Events(EventID) ON DELETE CASCADE,
    TypeName NVARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    TotalSeats INT NOT NULL,
    AvailableSeats INT NOT NULL,
    Description NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE Bookings (
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    BookingReference NVARCHAR(20) UNIQUE NOT NULL,
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    EventID INT FOREIGN KEY REFERENCES Events(EventID),
    TicketTypeID INT FOREIGN KEY REFERENCES TicketTypes(TicketTypeID),
    NumberOfTickets INT NOT NULL DEFAULT 1,
    TotalAmount DECIMAL(10,2) NOT NULL,
    Status NVARCHAR(20) DEFAULT 'Confirmed',
    BookingDate DATETIME DEFAULT GETDATE(),
    Notes NVARCHAR(500)
);

CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT FOREIGN KEY REFERENCES Bookings(BookingID),
    Amount DECIMAL(10,2) NOT NULL,
    PaymentMethod NVARCHAR(50) DEFAULT 'Cash',
    PaymentStatus NVARCHAR(20) DEFAULT 'Completed',
    TransactionID NVARCHAR(100),
    PaymentDate DATETIME DEFAULT GETDATE(),
    Notes NVARCHAR(500)
);

CREATE TABLE Gallery (
    GalleryID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT FOREIGN KEY REFERENCES Events(EventID) ON DELETE CASCADE,
    ImagePath NVARCHAR(500) NOT NULL,
    Caption NVARCHAR(200),
    UploadedByUserID INT FOREIGN KEY REFERENCES Users(UserID),
    UploadedAt DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);

CREATE TABLE Notifications (
    NotificationID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    Title NVARCHAR(200) NOT NULL,
    Message NVARCHAR(1000) NOT NULL,
    Type NVARCHAR(30) DEFAULT 'System',
    IsRead BIT DEFAULT 0,
    RelatedEventID INT NULL,
    RelatedBookingID INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);
CREATE TABLE Reports (
    ReportID INT IDENTITY(1,1) PRIMARY KEY,
    ReportName NVARCHAR(200) NOT NULL,
    ReportType NVARCHAR(50) NOT NULL,
    DateFrom DATE,
    DateTo DATE,
    GeneratedByUserID INT FOREIGN KEY REFERENCES Users(UserID),
    Parameters NVARCHAR(MAX),
    GeneratedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE SystemSettings (
    SettingID INT IDENTITY(1,1) PRIMARY KEY,
    SettingKey NVARCHAR(100) UNIQUE NOT NULL,
    SettingValue NVARCHAR(500),
    Description NVARCHAR(300),
    UpdatedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE AuditLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    TableName NVARCHAR(100),
    Action NVARCHAR(20),         -- INSERT, UPDATE, DELETE
    RecordID INT,
    ChangedBy NVARCHAR(150),
    OldValue NVARCHAR(MAX),
    NewValue NVARCHAR(MAX),
    ChangedAt DATETIME DEFAULT GETDATE()
);
CREATE VIEW vw_EventDetails AS
SELECT
    e.EventID,
    e.Title,
    e.ShortDescription,
    e.EventDate,
    e.StartTime,
    e.EndTime,
    e.Status,
    e.ApprovalStatus,
    e.AvailableSeats,
    e.EventType,
    e.ImagePath,
    e.Tags,
    e.CreatedAt,
    v.VenueName,
    v.Location AS VenueLocation,
    v.Capacity AS VenueCapacity,
    c.CategoryName,
    o.Name AS OrganizerName,
    o.Organization,
    o.Email AS OrganizerEmail,
    u.FullName AS CreatedBy,
    u.Email AS CreatorEmail
FROM Events e
LEFT JOIN Venues v ON e.VenueID = v.VenueID
LEFT JOIN Categories c ON e.CategoryID = c.CategoryID
LEFT JOIN Organizers o ON e.OrganizerID = o.OrganizerID
LEFT JOIN Users u ON e.CreatedByUserID = u.UserID
WHERE e.IsActive = 1;
CREATE VIEW vw_BookingDetails AS
SELECT
    b.BookingID,
    b.BookingReference,
    b.NumberOfTickets,
    b.TotalAmount,
    b.Status AS BookingStatus,
    b.BookingDate,
    b.Notes,
    u.FullName AS UserName,
    u.Email AS UserEmail,
    u.Phone AS UserPhone,
    e.Title AS EventTitle,
    e.EventDate,
    e.ApprovalStatus AS EventApproval,
    tk.TypeName AS TicketType,
    tk.Price AS TicketPrice,
    p.PaymentMethod,
    p.PaymentStatus,
    p.PaymentDate
FROM Bookings b
JOIN Users u ON b.UserID = u.UserID
JOIN Events e ON b.EventID = e.EventID
LEFT JOIN TicketTypes tk ON b.TicketTypeID = tk.TicketTypeID
LEFT JOIN Payments p ON b.BookingID = p.BookingID;

CREATE VIEW vw_EventRevenue AS
SELECT
    e.EventID,
    e.Title,
    e.EventDate,
    e.ApprovalStatus,
    COUNT(b.BookingID) AS TotalBookings,
    ISNULL(SUM(b.NumberOfTickets), 0) AS TotalTicketsSold,
    ISNULL(SUM(b.TotalAmount), 0) AS TotalRevenue,
    e.AvailableSeats AS RemainingSeats
FROM Events e
LEFT JOIN Bookings b ON e.EventID = b.EventID AND b.Status = 'Confirmed'
WHERE e.IsActive = 1
GROUP BY e.EventID, e.Title, e.EventDate, e.ApprovalStatus, e.AvailableSeats;
CREATE FUNCTION fn_GetEventRevenue(@EventID INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Revenue DECIMAL(18,2)
    SELECT @Revenue = ISNULL(SUM(TotalAmount), 0)
    FROM Bookings
    WHERE EventID = @EventID AND Status = 'Confirmed'
    RETURN @Revenue
END
CREATE FUNCTION fn_GetAvailableSeats(@EventID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Seats INT
    SELECT @Seats = ISNULL(SUM(AvailableSeats), 0)
    FROM TicketTypes
    WHERE EventID = @EventID AND IsActive = 1
    RETURN @Seats
END
CREATE FUNCTION fn_GetUserBookingCount(@UserID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT
    SELECT @Count = COUNT(*) FROM Bookings
    WHERE UserID = @UserID AND Status = 'Confirmed'
    RETURN @Count
END
CREATE FUNCTION fn_IsEventFullyBooked(@EventID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @Avail INT
    SET @Avail = dbo.fn_GetAvailableSeats(@EventID)
    RETURN CASE WHEN @Avail <= 0 THEN 1 ELSE 0 END
END
CREATE FUNCTION fn_GetEventBookings(@EventID INT)
RETURNS TABLE
AS
RETURN (
    SELECT b.BookingID, b.BookingReference, u.FullName, u.Email,
           tk.TypeName, b.NumberOfTickets, b.TotalAmount, b.Status, b.BookingDate
    FROM Bookings b
    JOIN Users u ON b.UserID = u.UserID
    LEFT JOIN TicketTypes tk ON b.TicketTypeID = tk.TicketTypeID
    WHERE b.EventID = @EventID
)

CREATE TRIGGER trg_AfterBookingInsert
ON Bookings
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Events
    SET TotalRevenue = dbo.fn_GetEventRevenue(i.EventID),
        UpdatedAt = GETDATE()
    FROM Events e
    JOIN inserted i ON e.EventID = i.EventID
    WHERE i.Status = 'Confirmed';

    INSERT INTO AuditLog (TableName, Action, RecordID, ChangedBy, NewValue)
    SELECT 'Bookings', 'INSERT', i.BookingID,
           (SELECT Email FROM Users WHERE UserID = i.UserID),
           'Booking confirmed for EventID: ' + CAST(i.EventID AS NVARCHAR)
    FROM inserted i;
END

CREATE TRIGGER trg_AfterBookingUpdate
ON Bookings
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Events
    SET TotalRevenue = dbo.fn_GetEventRevenue(i.EventID),
        UpdatedAt = GETDATE()
    FROM Events e
    JOIN inserted i ON e.EventID = i.EventID
    INSERT INTO AuditLog (TableName, Action, RecordID, ChangedBy, OldValue, NewValue)
    SELECT 'Bookings', 'UPDATE', i.BookingID,
           (SELECT Email FROM Users WHERE UserID = i.UserID),
           'Status was: ' + d.Status,
           'Status now: ' + i.Status
    FROM inserted i JOIN deleted d ON i.BookingID = d.BookingID;
END

CREATE TRIGGER trg_AfterEventApproval
ON Events
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(ApprovalStatus)
    BEGIN
        INSERT INTO Notifications (UserID, Title, Message, Type, RelatedEventID)
        SELECT
            i.CreatedByUserID,
            CASE i.ApprovalStatus
                WHEN 'Approved' THEN 'Event Approved ✅'
                WHEN 'Rejected' THEN 'Event Rejected ❌'
                ELSE 'Event Status Updated'
            END,
            CASE i.ApprovalStatus
                WHEN 'Approved' THEN 'Your event "' + i.Title + '" has been approved by admin and is now live!'
                WHEN 'Rejected' THEN 'Your event "' + i.Title + '" was not approved by the admin. Please contact admin.'
                ELSE 'Your event "' + i.Title + '" status changed to ' + i.ApprovalStatus
            END,
            'Event',
            i.EventID
        FROM inserted i
        JOIN deleted d ON i.EventID = d.EventID
        WHERE i.ApprovalStatus <> d.ApprovalStatus
          AND i.CreatedByUserID IS NOT NULL;
        INSERT INTO AuditLog (TableName, Action, RecordID, ChangedBy, OldValue, NewValue)
        SELECT 'Events', 'UPDATE', i.EventID, 'Admin',
               'ApprovalStatus was: ' + d.ApprovalStatus,
               'ApprovalStatus now: ' + i.ApprovalStatus
        FROM inserted i JOIN deleted d ON i.EventID = d.EventID
        WHERE i.ApprovalStatus <> d.ApprovalStatus;
    END
END
CREATE TRIGGER trg_PreventUserDelete
ON Users
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @HasBookings INT;
    SELECT @HasBookings = COUNT(*)
    FROM deleted d
    JOIN Bookings b ON d.UserID = b.UserID
    WHERE b.Status = 'Confirmed';

    IF @HasBookings > 0
    BEGIN
        RAISERROR('Cannot delete user with confirmed bookings. Deactivate instead.', 16, 1);
        RETURN;
    END

    UPDATE Users SET IsActive = 0
    WHERE UserID IN (SELECT UserID FROM deleted);

    INSERT INTO AuditLog (TableName, Action, RecordID, ChangedBy, NewValue)
    SELECT 'Users', 'DELETE (soft)', UserID, Email, 'User deactivated'
    FROM deleted;
END

CREATE TRIGGER trg_EventsUpdatedAt
ON Events
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Events SET UpdatedAt = GETDATE()
    WHERE EventID IN (SELECT EventID FROM inserted);
END

CREATE TRIGGER trg_UsersAudit
ON Users
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AuditLog (TableName, Action, RecordID, ChangedBy, OldValue, NewValue)
    SELECT 'Users', 'UPDATE', i.UserID, i.Email,
           'Name was: ' + d.FullName + ', Role was: ' + d.Role,
           'Name now: ' + i.FullName + ', Role now: ' + i.Role
    FROM inserted i JOIN deleted d ON i.UserID = d.UserID;
END


CREATE PROCEDURE sp_GetDashboardSummary
AS
BEGIN
    SELECT
        (SELECT COUNT(*) FROM Events WHERE IsActive=1) AS TotalEvents,
        (SELECT COUNT(*) FROM Events WHERE ApprovalStatus='Pending' AND IsActive=1) AS PendingEvents,
        (SELECT COUNT(*) FROM Bookings WHERE Status='Confirmed') AS TotalBookings,
        (SELECT COUNT(*) FROM Users WHERE IsActive=1) AS TotalUsers,
        (SELECT ISNULL(SUM(TotalAmount),0) FROM Bookings WHERE Status='Confirmed') AS TotalRevenue;
END

CREATE PROCEDURE sp_ApproveEvent
    @EventID INT,
    @ApprovalStatus NVARCHAR(20),
    @AdminNote NVARCHAR(500) = NULL
AS
BEGIN
    UPDATE Events
    SET ApprovalStatus = @ApprovalStatus,
        Status = CASE WHEN @ApprovalStatus = 'Approved' THEN 'Upcoming' ELSE 'Cancelled' END,
        UpdatedAt = GETDATE()
    WHERE EventID = @EventID;
END

CREATE PROCEDURE sp_CreateBooking
    @BookingReference NVARCHAR(20),
    @UserID INT,
    @EventID INT,
    @TicketTypeID INT,
    @NumberOfTickets INT,
    @TotalAmount DECIMAL(10,2),
    @PaymentMethod NVARCHAR(50),
    @Notes NVARCHAR(500)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
     
        DECLARE @Avail INT;
        SELECT @Avail = AvailableSeats FROM TicketTypes WHERE TicketTypeID = @TicketTypeID;
        IF @Avail < @NumberOfTickets
            THROW 50001, 'Not enough seats available.', 1;

      
        DECLARE @BookingID INT;
        INSERT INTO Bookings (BookingReference, UserID, EventID, TicketTypeID, NumberOfTickets, TotalAmount, Status, Notes)
        VALUES (@BookingReference, @UserID, @EventID, @TicketTypeID, @NumberOfTickets, @TotalAmount, 'Confirmed', @Notes);
        SET @BookingID = SCOPE_IDENTITY();

       
        INSERT INTO Payments (BookingID, Amount, PaymentMethod, PaymentStatus)
        VALUES (@BookingID, @TotalAmount, @PaymentMethod, 'Completed');

       
        UPDATE TicketTypes SET AvailableSeats = AvailableSeats - @NumberOfTickets WHERE TicketTypeID = @TicketTypeID;
        UPDATE Events SET AvailableSeats = AvailableSeats - @NumberOfTickets WHERE EventID = @EventID;

        COMMIT TRANSACTION;
        SELECT @BookingID AS BookingID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

USE master;

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'EventoraDB_Backup')
    DROP DATABASE EventoraDB_Backup;

USE EventoraDB;

INSERT INTO Users (FullName, Email, Password, Phone, Role) VALUES
('Ayesha Khan', 'ayesha@eventora.com', 'Admin@123', '+92 300 1234567', 'Admin');
INSERT INTO Users (FullName, Email, Password, Phone, Role) VALUES
('Ali Hassan', 'ali@eventora.com', 'User@123', '+92 321 9876543', 'User');
INSERT INTO Categories (CategoryName, Description) VALUES
('Conference', 'Professional conferences and seminars'),
('Concert', 'Music concerts and live performances'),
('Sports', 'Sports events and tournaments'),
('Workshop', 'Educational workshops and training'),
('Technology', 'Tech events and hackathons'),
('Cultural', 'Cultural festivals and exhibitions');
INSERT INTO Venues (VenueName, Location, Capacity, Phone, Email) VALUES
('Expo Center', 'Lahore, Punjab', 5000, '+92 42 111 222 333', 'info@expocenter.pk'),
('Alhamra Arts Council', 'Lahore, Punjab', 800, '+92 42 9920 1234', 'info@alhamra.pk'),
('National Hockey Stadium', 'Lahore, Punjab', 15000, '+92 42 9921 5678', 'info@nhsl.pk');
INSERT INTO Organizers (Name, Email, Phone, Organization) VALUES
('Ahmed Ali', 'ahmed@events.pk', '+92 300 9876543', 'Elite Events'),
('Sara Hassan', 'sara@techevents.pk', '+92 321 5556677', 'TechPK Events');
INSERT INTO Events (Title, ShortDescription, Description, EventDate, StartTime, EndTime, VenueID, CategoryID, OrganizerID, CreatedByUserID, AvailableSeats, Status, ApprovalStatus)
VALUES
('Tech Conference 2024', 'A leading tech conference.', 'A leading tech conference bringing together developers, innovators and industry leaders from across Pakistan.', '2024-12-25', '09:00', '18:00', 1, 5, 1, 1, 500, 'Upcoming', 'Approved'),
('Music Night Lahore', 'An amazing evening of live music.', 'Join us for an incredible night of live music performances by top artists of Pakistan.', '2024-12-30', '19:00', '23:00', 2, 2, 2, 1, 800, 'Upcoming', 'Approved'),
('User Submitted Event', 'Event submitted by user pending admin approval.', 'This is a demo event submitted by a regular user awaiting admin approval.', '2025-01-15', '10:00', '16:00', 3, 4, 1, 2, 200, 'Upcoming', 'Pending');
INSERT INTO TicketTypes (EventID, TypeName, Price, TotalSeats, AvailableSeats, Description) VALUES
(1, 'VIP', 5000, 100, 100, 'VIP access with front row seating and refreshments'),
(1, 'General', 1500, 400, 400, 'Standard admission ticket'),
(2, 'VIP', 3000, 50, 50, 'VIP backstage access and meet & greet'),
(2, 'General', 800, 750, 750, 'General admission'),
(3, 'General', 500, 200, 200, 'Standard ticket');
INSERT INTO SystemSettings (SettingKey, SettingValue, Description) VALUES
('AppName', 'Eventora', 'Application name'),
('AdminEmail', 'ayesha@eventora.com', 'Admin email address'),
('Currency', 'PKR', 'Default currency'),
('MaxTicketsPerBooking', '10', 'Maximum tickets per booking'),
('AppVersion', '2.0.0', 'Application version');
INSERT INTO Notifications (UserID, Title, Message, Type) VALUES
(1, 'Welcome to Eventora!', 'Your admin account is ready. You can now manage events, approve submissions, and view reports.', 'System'),
(2, 'Welcome to Eventora!', 'Your account is ready. Start by browsing events and booking tickets!', 'System');


 
USE EventoraDB;
GO
 
-- ============================================
-- QUERY 1: Events With Full Details & Booking Count
-- Purpose: Show all approved upcoming events with
--          organizer, venue, category, and how many
--          confirmed bookings each event has so far.
-- JOINs: Events -> Venues, Categories, Organizers
-- Nested: Subquery for booking count per event
-- ============================================
SELECT
    e.EventID,
    e.Title                             AS EventTitle,
    e.EventDate,
    e.StartTime,
    e.EndTime,
    c.CategoryName,
    v.VenueName,
    v.Location                          AS VenueCity,
    o.Name                              AS OrganizerName,
    o.Organization,
    e.AvailableSeats,
    e.Status,
    (
        SELECT COUNT(*)
        FROM Bookings b
        WHERE b.EventID = e.EventID
          AND b.Status = 'Confirmed'
    )                                   AS ConfirmedBookings,
    (
        SELECT ISNULL(SUM(b2.TotalAmount), 0)
        FROM Bookings b2
        WHERE b2.EventID = e.EventID
          AND b2.Status = 'Confirmed'
    )                                   AS TotalRevenuePKR
FROM Events e
JOIN Venues     v ON e.VenueID     = v.VenueID
JOIN Categories c ON e.CategoryID  = c.CategoryID
JOIN Organizers o ON e.OrganizerID = o.OrganizerID
WHERE e.IsActive        = 1
  AND e.ApprovalStatus  = 'Approved'
  AND e.Status          = 'Upcoming'
ORDER BY e.EventDate ASC;
GO
 
 
-- ============================================
-- QUERY 2: Users Who Booked More Than Once
-- Purpose: Find loyal/repeat customers — users who
--          have made 2 or more confirmed bookings.
-- JOINs: Users -> Bookings
-- Nested: HAVING with subquery to filter count
-- ============================================
SELECT
    u.UserID,
    u.FullName,
    u.Email,
    u.Phone,
    u.Role,
    COUNT(b.BookingID)              AS TotalBookings,
    SUM(b.TotalAmount)              AS TotalSpentPKR,
    MAX(b.BookingDate)              AS LastBookingDate
FROM Users u
JOIN Bookings b ON u.UserID = b.UserID
WHERE u.IsActive = 1
  AND b.Status   = 'Confirmed'
  AND u.UserID IN
  (
      SELECT UserID
      FROM Bookings
      WHERE Status = 'Confirmed'
      GROUP BY UserID
      HAVING COUNT(BookingID) >= 2
  )
GROUP BY u.UserID, u.FullName, u.Email, u.Phone, u.Role
ORDER BY TotalSpentPKR DESC;
GO
 
 
-- ============================================
-- QUERY 3: Events With No Bookings Yet
-- Purpose: Identify events that are approved and active
--          but have received zero confirmed bookings —
--          useful for marketing/promotion decisions.
-- JOINs: Events -> Venues, Categories
-- Nested: NOT EXISTS subquery on Bookings
-- ============================================
SELECT
    e.EventID,
    e.Title,
    e.EventDate,
    e.AvailableSeats,
    c.CategoryName,
    v.VenueName,
    v.Location,
    e.CreatedAt                     AS PostedOn
FROM Events e
JOIN Categories c ON e.CategoryID = c.CategoryID
JOIN Venues     v ON e.VenueID    = v.VenueID
WHERE e.IsActive       = 1
  AND e.ApprovalStatus = 'Approved'
  AND NOT EXISTS
  (
      SELECT 1
      FROM Bookings b
      WHERE b.EventID = e.EventID
        AND b.Status  = 'Confirmed'
  )
ORDER BY e.EventDate ASC;
GO
 
 
-- ============================================
-- QUERY 4: Revenue & Sales Breakdown Per Ticket Type
-- Purpose: For each event show how each ticket tier
--          (VIP, General, etc.) performed in sales.
-- JOINs: Events -> TicketTypes -> Bookings
-- Nested: Subquery for sold-out check
-- ============================================
SELECT
    e.Title                                     AS EventTitle,
    e.EventDate,
    tt.TypeName                                 AS TicketTier,
    tt.Price                                    AS PricePerTicket,
    tt.TotalSeats,
    tt.AvailableSeats                           AS RemainingSeats,
    (tt.TotalSeats - tt.AvailableSeats)         AS TicketsSold,
    ISNULL(
        (
            SELECT SUM(b.TotalAmount)
            FROM Bookings b
            WHERE b.TicketTypeID = tt.TicketTypeID
              AND b.Status       = 'Confirmed'
        ), 0
    )                                           AS RevenuePKR,
    CASE
        WHEN tt.AvailableSeats = 0 THEN 'SOLD OUT'
        WHEN tt.AvailableSeats < (tt.TotalSeats * 0.1) THEN 'Almost Full'
        ELSE 'Available'
    END                                         AS SeatStatus
FROM Events e
JOIN TicketTypes tt ON e.EventID = tt.EventID
WHERE e.IsActive  = 1
  AND tt.IsActive = 1
ORDER BY e.EventDate ASC, RevenuePKR DESC;
GO
 
 
-- ============================================
-- QUERY 5: Pending Events With Creator Info
-- Purpose: Admin dashboard — list all events still
--          awaiting approval, along with who submitted
--          them and which organizer is attached.
-- JOINs: Events -> Users, Organizers, Categories, Venues
-- Nested: Subquery to verify creator is still active
-- ============================================
SELECT
    e.EventID,
    e.Title,
    e.EventDate,
    e.ShortDescription,
    c.CategoryName,
    v.VenueName,
    o.Name                              AS OrganizerName,
    o.Organization,
    u.FullName                          AS SubmittedBy,
    u.Email                             AS SubmitterEmail,
    u.Role                              AS SubmitterRole,
    e.CreatedAt                         AS SubmittedOn,
    DATEDIFF(DAY, e.CreatedAt, GETDATE()) AS DaysPending
FROM Events e
JOIN Users      u ON e.CreatedByUserID = u.UserID
JOIN Organizers o ON e.OrganizerID     = o.OrganizerID
JOIN Categories c ON e.CategoryID      = c.CategoryID
JOIN Venues     v ON e.VenueID         = v.VenueID
WHERE e.ApprovalStatus = 'Pending'
  AND e.IsActive       = 1
  AND e.CreatedByUserID IN
  (
      SELECT UserID
      FROM Users
      WHERE IsActive = 1
  )
ORDER BY e.CreatedAt ASC;
GO
 
 
-- ============================================
-- QUERY 6: Top 5 Most Active Organizers
-- Purpose: Rank organizers by number of approved events
--          and total revenue they have generated.
-- JOINs: Organizers -> Events -> Bookings
-- Nested: Subquery for max single-event revenue
-- ============================================
SELECT TOP 5
    o.OrganizerID,
    o.Name                              AS OrganizerName,
    o.Organization,
    o.Email,
    COUNT(DISTINCT e.EventID)           AS TotalApprovedEvents,
    ISNULL(SUM(b.TotalAmount), 0)       AS TotalRevenuePKR,
    ISNULL(SUM(b.NumberOfTickets), 0)   AS TotalTicketsSold,
    (
        SELECT TOP 1 e2.Title
        FROM Events e2
        LEFT JOIN Bookings b2 ON e2.EventID = b2.EventID
                              AND b2.Status  = 'Confirmed'
        WHERE e2.OrganizerID     = o.OrganizerID
          AND e2.ApprovalStatus  = 'Approved'
        GROUP BY e2.EventID, e2.Title
        ORDER BY SUM(b2.TotalAmount) DESC
    )                                   AS BestPerformingEvent
FROM Organizers o
JOIN Events e   ON o.OrganizerID = e.OrganizerID
                AND e.ApprovalStatus = 'Approved'
                AND e.IsActive       = 1
LEFT JOIN Bookings b ON e.EventID  = b.EventID
                     AND b.Status   = 'Confirmed'
WHERE o.IsActive = 1
GROUP BY o.OrganizerID, o.Name, o.Organization, o.Email
ORDER BY TotalRevenuePKR DESC;
GO
 
 
-- ============================================
-- QUERY 7: User Booking History With Payment Info
-- Purpose: Full booking + payment trail for each user —
--          useful for user profile and admin audit view.
-- JOINs: Users -> Bookings -> Events -> TicketTypes -> Payments
-- Nested: Subquery to label payment as Paid/Unpaid
-- ============================================
SELECT
    u.FullName                          AS UserName,
    u.Email,
    b.BookingReference,
    e.Title                             AS EventTitle,
    e.EventDate,
    tt.TypeName                         AS TicketType,
    b.NumberOfTickets,
    b.TotalAmount,
    b.Status                            AS BookingStatus,
    b.BookingDate,
    p.PaymentMethod,
    p.PaymentStatus,
    p.PaymentDate,
    CASE
        WHEN
        (
            SELECT COUNT(*)
            FROM Payments px
            WHERE px.BookingID     = b.BookingID
              AND px.PaymentStatus = 'Completed'
        ) > 0
        THEN 'Paid'
        ELSE 'Payment Pending'
    END                                 AS PaymentLabel
FROM Users u
JOIN Bookings    b  ON u.UserID           = b.UserID
JOIN Events      e  ON b.EventID          = e.EventID
LEFT JOIN TicketTypes tt ON b.TicketTypeID = tt.TicketTypeID
LEFT JOIN Payments    p  ON b.BookingID    = p.BookingID
WHERE u.IsActive = 1
ORDER BY b.BookingDate DESC;
GO
 
 
-- ============================================
-- QUERY 8: Venue Utilization Report
-- Purpose: How busy is each venue — total events hosted,
--          capacity used, and revenue generated there.
-- JOINs: Venues -> Events -> Bookings
-- Nested: Subquery to find busiest upcoming date per venue
-- ============================================
SELECT
    v.VenueID,
    v.VenueName,
    v.Location,
    v.Capacity                              AS MaxCapacity,
    COUNT(DISTINCT e.EventID)               AS TotalEventsHosted,
    ISNULL(SUM(b.NumberOfTickets), 0)       AS TotalAttendeesBooked,
    ISNULL(SUM(b.TotalAmount), 0)           AS TotalRevenuePKR,
    CASE
        WHEN v.Capacity > 0
        THEN CAST(
                ROUND(
                    (ISNULL(SUM(b.NumberOfTickets), 0) * 100.0) / (v.Capacity * COUNT(DISTINCT e.EventID)),
                    2
                ) AS NVARCHAR(20)
             ) + '%'
        ELSE 'N/A'
    END                                     AS AvgOccupancyRate,
    (
        SELECT TOP 1 CAST(e2.EventDate AS NVARCHAR(20))
        FROM Events e2
        WHERE e2.VenueID        = v.VenueID
          AND e2.IsActive       = 1
          AND e2.ApprovalStatus = 'Approved'
          AND e2.EventDate      >= CAST(GETDATE() AS DATE)
        ORDER BY e2.EventDate ASC
    )                                       AS NextUpcomingEventDate
FROM Venues v
JOIN Events e   ON v.VenueID  = e.VenueID
                AND e.IsActive = 1
LEFT JOIN Bookings b ON e.EventID = b.EventID
                     AND b.Status  = 'Confirmed'
WHERE v.IsActive = 1
GROUP BY v.VenueID, v.VenueName, v.Location, v.Capacity
ORDER BY TotalRevenuePKR DESC;
GO
 
 
-- ============================================
-- QUERY 9: Unread Notifications Per User
-- Purpose: Show all unread notifications for active
--          users along with related event info if any.
-- JOINs: Notifications -> Users -> Events (LEFT)
-- Nested: Subquery for total unread count per user
-- ============================================
SELECT
    n.NotificationID,
    u.FullName                              AS RecipientName,
    u.Email                                 AS RecipientEmail,
    n.Title                                 AS NotificationTitle,
    n.Message,
    n.Type                                  AS NotificationType,
    n.CreatedAt                             AS SentAt,
    ISNULL(e.Title, 'N/A')                 AS RelatedEvent,
    ISNULL(CAST(e.EventDate AS NVARCHAR(20)), 'N/A') AS RelatedEventDate,
    (
        SELECT COUNT(*)
        FROM Notifications nx
        WHERE nx.UserID  = u.UserID
          AND nx.IsRead  = 0
    )                                       AS TotalUnreadForUser
FROM Notifications n
JOIN Users u        ON n.UserID        = u.UserID
LEFT JOIN Events e  ON n.RelatedEventID = e.EventID
WHERE n.IsRead   = 0
  AND u.IsActive = 1
  AND u.UserID IN
  (
      SELECT DISTINCT UserID
      FROM Notifications
      WHERE IsRead = 0
  )
ORDER BY n.CreatedAt DESC;
GO
 
 
-- ============================================
-- QUERY 10: Complete Admin Audit Trail
-- Purpose: Show audit log with context — what changed,
--          in which table, cross-referenced with user
--          emails from Users table where possible.
-- JOINs: AuditLog -> Users (LEFT, by email match)
-- Nested: Subquery to check if the actor user is Admin
-- ============================================
SELECT
    al.LogID,
    al.TableName,
    al.Action,
    al.RecordID,
    al.ChangedBy                            AS ActorEmail,
    ISNULL(u.FullName, 'System/Unknown')    AS ActorFullName,
    ISNULL(u.Role, 'N/A')                  AS ActorRole,
    CASE
        WHEN
        (
            SELECT COUNT(*)
            FROM Users ux
            WHERE ux.Email    = al.ChangedBy
              AND ux.Role     = 'Admin'
              AND ux.IsActive = 1
        ) > 0
        THEN 'Admin Action'
        ELSE 'User/System Action'
    END                                     AS ActionType,
    al.OldValue,
    al.NewValue,
    al.ChangedAt                            AS ActionDateTime
FROM AuditLog al
LEFT JOIN Users u ON al.ChangedBy = u.Email
ORDER BY al.ChangedAt DESC;
GO
 
-- ============================================
PRINT '10 Eventora Queries executed successfully!';
PRINT 'No existing tables/triggers/functions were modified.';
-- ============================================;
