USE StagingOlympics;
GO

/* =============================================
   1. Bảng Stage_Person
   Nguồn: olympics.dbo.person
   Mục đích: Nguồn cho Dim_Athlete
   ============================================= */
CREATE TABLE dbo.Stage_Person (
    id          INT,            -- Giữ ID gốc để Lookup
    full_name   NVARCHAR(255),  -- Dùng NVARCHAR để an toàn dữ liệu
    gender      NVARCHAR(10),
    height      INT,
    weight      INT,
    
    -- Cột Audit để theo dõi
    Load_Date   DATETIME DEFAULT GETDATE()
);
GO

/* =============================================
   2. Bảng Stage_NOC_Region
   Nguồn: olympics.dbo.noc_region
   Mục đích: Nguồn cho Dim_NOC
   ============================================= */
CREATE TABLE dbo.Stage_NOC_Region (
    id          INT,
    noc         NVARCHAR(10),   -- Mã quốc gia (VD: VIE)
    region_name NVARCHAR(200),  -- Tên quốc gia
    notes       NVARCHAR(MAX),
    Load_Date   DATETIME DEFAULT GETDATE()
);
GO

/* =============================================
   3. Bảng Stage_Games
   Nguồn: olympics.dbo.games
   Mục đích: Nguồn cho Dim_Game (Phần thông tin Kỳ vận hội)
   ============================================= */
CREATE TABLE dbo.Stage_Games (
    id          INT,
    games_year  INT,
    games_name  NVARCHAR(100),  -- VD: 1992 Summer
    season      NVARCHAR(50),   -- Summer/Winter
    Load_Date   DATETIME DEFAULT GETDATE()
);
GO

/* =============================================
   4. Bảng Stage_City
   Nguồn: olympics.dbo.city
   Mục đích: Nguồn cho Dim_Game (Phần thông tin Thành phố)
   ============================================= */
CREATE TABLE dbo.Stage_City (
    id          INT,
    city_name   NVARCHAR(200),
    Load_Date   DATETIME DEFAULT GETDATE()
);
GO

/* =============================================
   5. Bảng Stage_Event_Sport
   LƯU Ý: Ở đây ta có thể tạo 2 bảng riêng hoặc Join sẵn nếu muốn.
   Để Extract nhanh nhất, ta tạo 2 bảng riêng biệt như nguồn.
   ============================================= */

-- Bảng Stage_Sport
CREATE TABLE dbo.Stage_Sport (
    id          INT,
    sport_name  NVARCHAR(200),
    Load_Date   DATETIME DEFAULT GETDATE()
);

-- Bảng Stage_Event (Nguồn cho Dim_Event)
CREATE TABLE dbo.Stage_Event (
    id          INT,
    sport_id    INT,            -- Khóa ngoại lỏng (chỉ lưu giá trị)
    event_name  NVARCHAR(255),
    Load_Date   DATETIME DEFAULT GETDATE()
);
GO

/* =============================================
   6. Bảng Stage_Medal
   Nguồn: olympics.dbo.medal
   Mục đích: Nguồn cho Dim_Medal
   ============================================= */
CREATE TABLE dbo.Stage_Medal (
    id          INT,
    medal_name  NVARCHAR(50),
    Load_Date   DATETIME DEFAULT GETDATE()
);
GO

/* =============================================
   7. Bảng Stage_Games_Competitor
   Nguồn: olympics.dbo.games_competitor
   Mục đích: Xác định VĐV (Person) tham gia Kỳ vận hội (Games) nào và Tuổi (Age).
   ============================================= */
CREATE TABLE dbo.Stage_Games_Competitor (
    id          INT, -- ID này ít dùng trong DW, nhưng cứ giữ
    games_id    INT, -- Link tới Games
    person_id   INT, -- Link tới Person
    age         INT, -- Measure quan trọng: Tuổi
    Load_Date   DATETIME DEFAULT GETDATE()
);
GO

/* =============================================
   8. Bảng Stage_Competitor_Event
   Nguồn: olympics.dbo.competitor_event
   Mục đích: Bảng cốt lõi chứa kết quả thi đấu (Ai thi môn gì, huy chương gì).
   ============================================= */
CREATE TABLE dbo.Stage_Competitor_Event (
    event_id        INT, -- Link tới Event
    competitor_id   INT, -- Link tới Stage_Games_Competitor
    medal_id        INT, -- Link tới Medal
    Load_Date       DATETIME DEFAULT GETDATE()
);
GO

/* =============================================
   9. Bảng Stage_Person_Region
   Nguồn: olympics.dbo.person_region
   Mục đích: Xác định VĐV thuộc quốc gia nào (NOC).
   ============================================= */
CREATE TABLE dbo.Stage_Person_Region (
    person_id   INT,
    region_id   INT,
    Load_Date   DATETIME DEFAULT GETDATE()
);
GO

/* =============================================
   10. Bảng Stage_Games_City
   Nguồn: olympics.dbo.games_city
   Mục đích: Xác định Kỳ vận hội tổ chức ở đâu (Mapping Games - City).
   ============================================= */
CREATE TABLE dbo.Stage_Games_City (
    games_id    INT,
    city_id     INT,
    Load_Date   DATETIME DEFAULT GETDATE()
);
GO