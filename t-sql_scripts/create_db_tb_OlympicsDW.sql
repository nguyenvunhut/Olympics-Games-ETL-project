USE master;
GO

-- 1. Tạo Database OlympicsDW (Xóa cũ nếu tồn tại để làm sạch môi trường Dev)
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'OlympicsDW')
BEGIN
    ALTER DATABASE OlympicsDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE OlympicsDW;
END
GO

CREATE DATABASE OlympicsDW;
GO

USE OlympicsDW;
GO

/* ==========================================================================
   PHẦN 1: TẠO CÁC BẢNG DIMENSION (BẢNG CHIỀU)
   Lưu ý: Tất cả đều có Key tự tăng (Surrogate Key) và Original_ID để Lookup
   ========================================================================== */

-- 1. Dim_NOC (Quốc gia/Vùng lãnh thổ)
CREATE TABLE dbo.Dim_NOC (
    NOC_Key         INT IDENTITY(1,1) PRIMARY KEY, -- Khóa đại diện (Surrogate Key)
    Original_ID     INT,                           -- ID gốc từ Source (để Lookup)
    NOC_Code        NVARCHAR(10),                  -- Mã 3 ký tự (VIE, USA...)
    Region_Name     NVARCHAR(200)                  -- Tên quốc gia đầy đủ
);
GO

-- 2. Dim_Athlete (Vận động viên)
CREATE TABLE dbo.Dim_Athlete (
    Athlete_Key     INT IDENTITY(1,1) PRIMARY KEY,
    Original_ID     INT,                           -- ID gốc từ bảng Person
    Full_Name       NVARCHAR(255),
    Gender          NVARCHAR(10),
    Height          INT,
    Weight          INT
);
GO

-- 3. Dim_Game (Kỳ vận hội & Địa điểm)
-- Bảng này gộp thông tin từ Games và City để thuận tiện phân tích
CREATE TABLE dbo.Dim_Game (
    Game_Key        INT IDENTITY(1,1) PRIMARY KEY,
    Original_ID     INT,                           -- ID gốc từ bảng Games
    Games_Name      NVARCHAR(100),                 -- VD: 1992 Summer
    Year            INT,
    Season          NVARCHAR(50),
    City_Name       NVARCHAR(200)                  -- Lấy từ bảng City
);
GO

-- 4. Dim_Event (Môn thi & Nội dung)
-- Gộp Sport và Event vào chung một chiều
CREATE TABLE dbo.Dim_Event (
    Event_Key       INT IDENTITY(1,1) PRIMARY KEY,
    Original_ID     INT,                           -- ID gốc từ bảng Event
    Sport_Name      NVARCHAR(200),
    Event_Name      NVARCHAR(255)
);
GO

-- 5. Dim_Medal (Huy chương)
CREATE TABLE dbo.Dim_Medal (
    Medal_Key       INT IDENTITY(1,1) PRIMARY KEY,
    Original_ID     INT,                           -- ID gốc từ bảng Medal
    Medal_Name      NVARCHAR(50),
    Score_Value     INT DEFAULT 0                  -- Cột bổ sung: Vàng=3, Bạc=2, Đồng=1
);
GO

-- Thêm dòng 'Unknown' (-1) cho các bảng Dimension để xử lý lỗi Lookup (Best Practice)
SET IDENTITY_INSERT dbo.Dim_NOC ON;
INSERT INTO dbo.Dim_NOC (NOC_Key, Original_ID, NOC_Code, Region_Name) VALUES (-1, -1, 'UNK', 'Unknown');
SET IDENTITY_INSERT dbo.Dim_NOC OFF;

SET IDENTITY_INSERT dbo.Dim_Athlete ON;
INSERT INTO dbo.Dim_Athlete (Athlete_Key, Original_ID, Full_Name) VALUES (-1, -1, 'Unknown Athlete');
SET IDENTITY_INSERT dbo.Dim_Athlete OFF;

SET IDENTITY_INSERT dbo.Dim_Game ON;
INSERT INTO dbo.Dim_Game (Game_Key, Original_ID, Games_Name) VALUES (-1, -1, 'Unknown Game');
SET IDENTITY_INSERT dbo.Dim_Game OFF;

SET IDENTITY_INSERT dbo.Dim_Event ON;
INSERT INTO dbo.Dim_Event (Event_Key, Original_ID, Event_Name) VALUES (-1, -1, 'Unknown Event');
SET IDENTITY_INSERT dbo.Dim_Event OFF;

SET IDENTITY_INSERT dbo.Dim_Medal ON;
INSERT INTO dbo.Dim_Medal (Medal_Key, Original_ID, Medal_Name) VALUES (-1, -1, 'Unknown Medal');
SET IDENTITY_INSERT dbo.Dim_Medal OFF;
GO

/* ==========================================================================
   PHẦN 2: TẠO BẢNG FACT (BẢNG SỰ KIỆN)
   Chứa các khóa ngoại và các cột Measure đã được tính toán sẵn
   ========================================================================== */

CREATE TABLE dbo.Fact_Olympic_Results (
    Result_ID                   INT IDENTITY(1,1) PRIMARY KEY,
    
    -- Các khóa ngoại (Foreign Keys) liên kết với Dimension
    Athlete_Key                 INT NOT NULL,
    Game_Key                    INT NOT NULL,
    Event_Key                   INT NOT NULL,
    NOC_Key                     INT NOT NULL,
    Medal_Key                   INT NOT NULL,
    
    -- Các độ đo (Measures)
    Age                         INT, -- Tuổi (có thể Null)
    
    -- Các cột tính toán (Additive Measures) phục vụ việc SUM thay vì Count
    Medal_Count                 INT DEFAULT 0, -- 1 nếu có huy chương, 0 nếu NA
    Athlete_Participation_Count INT DEFAULT 0, -- 1 để đếm lượt tham gia
    Event_Count                 INT DEFAULT 0, -- 1 để đếm sự kiện
    NOC_Count                   INT DEFAULT 0, -- 1 để đếm quốc gia
    
    -- Metadata theo dõi ETL
    Created_Date                DATETIME DEFAULT GETDATE(),

    -- Thiết lập ràng buộc khóa ngoại (Optional - nhưng tốt cho Data Integrity)
    CONSTRAINT FK_Fact_Athlete FOREIGN KEY (Athlete_Key) REFERENCES Dim_Athlete(Athlete_Key),
    CONSTRAINT FK_Fact_Game    FOREIGN KEY (Game_Key)    REFERENCES Dim_Game(Game_Key),
    CONSTRAINT FK_Fact_Event   FOREIGN KEY (Event_Key)   REFERENCES Dim_Event(Event_Key),
    CONSTRAINT FK_Fact_NOC     FOREIGN KEY (NOC_Key)     REFERENCES Dim_NOC(NOC_Key),
    CONSTRAINT FK_Fact_Medal   FOREIGN KEY (Medal_Key)   REFERENCES Dim_Medal(Medal_Key)
);
GO