USE OlympicsDW;
GO

-- 1. XÓA BẢNG FACT (FACT TABLE)
-- Phải xóa bảng Fact trước vì nó chứa khóa ngoại trỏ tới các bảng Dimension
DELETE FROM dbo.Fact_Olympic_Results;
-- Reset lại bộ đếm ID tự tăng về 0 (để dòng tiếp theo bắt đầu từ 1)
DBCC CHECKIDENT ('dbo.Fact_Olympic_Results', RESEED, 0);
GO

-- 2. XÓA CÁC BẢNG DIMENSION (DIMENSION TABLES)
-- Lưu ý: Chỉ xóa các dòng có Key > -1 để giữ lại dòng 'Unknown' mặc định

-- 2.1. Xóa Dim_Medal
DELETE FROM dbo.Dim_Medal WHERE Medal_Key > -1;
DBCC CHECKIDENT ('dbo.Dim_Medal', RESEED, 0);

-- 2.2. Xóa Dim_NOC
DELETE FROM dbo.Dim_NOC WHERE NOC_Key > -1;
DBCC CHECKIDENT ('dbo.Dim_NOC', RESEED, 0);

-- 2.3. Xóa Dim_Event
DELETE FROM dbo.Dim_Event WHERE Event_Key > -1;
DBCC CHECKIDENT ('dbo.Dim_Event', RESEED, 0);

-- 2.4. Xóa Dim_Game
DELETE FROM dbo.Dim_Game WHERE Game_Key > -1;
DBCC CHECKIDENT ('dbo.Dim_Game', RESEED, 0);

-- 2.5. Xóa Dim_Athlete
DELETE FROM dbo.Dim_Athlete WHERE Athlete_Key > -1;
DBCC CHECKIDENT ('dbo.Dim_Athlete', RESEED, 0);
GO

/*Giải thích kỹ thuật:
Tại sao dùng DELETE thay vì TRUNCATE?

TRUNCATE nhanh hơn nhưng không chạy được khi bảng đang được tham chiếu bởi khóa ngoại (Foreign Key). Vì các bảng Dimension đang được bảng Fact tham chiếu, ta phải dùng DELETE.

DELETE WHERE Key > -1: Điều kiện này cực kỳ quan trọng để bảo vệ dòng dữ liệu "Unknown" (ID = -1) mà ta đã tạo lúc khởi tạo DB. Nếu xóa dòng này, các Lookup bị lỗi sẽ không biết trỏ đi đâu.

DBCC CHECKIDENT (..., RESEED, 0):

Lệnh này đặt lại số thứ tự tự tăng (Identity) về 0.

Dòng dữ liệu mới được nạp vào sẽ bắt đầu từ số 1, giúp ID đẹp và không bị tăng vọt lên hàng triệu sau nhiều lần chạy lại package.*/