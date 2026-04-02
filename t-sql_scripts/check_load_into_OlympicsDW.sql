USE OlympicsDW;
GO

/* TEST CASE 1: SO SÁNH TỔNG SỐ DÒNG (ROW COUNT)
   Mục tiêu: Đảm bảo số dòng sau khi làm sạch ở Staging = Số dòng trong Fact
*/
-- 1. Đếm số dòng hợp lệ ở Staging 
WITH Cleaned_Data AS (
    SELECT 
        competitor_id, event_id,
        ROW_NUMBER() OVER(PARTITION BY competitor_id, event_id ORDER BY medal_id DESC) as rn
    FROM StagingOlympics.dbo.Stage_Competitor_Event
)
SELECT 'Staging (Cleaned)' AS Source, COUNT(*) AS Total_Rows 
FROM Cleaned_Data 
WHERE rn = 1
UNION ALL
-- 2. Đếm số dòng thực tế trong Data Warehouse
SELECT 'OlympicsDW (Fact)', COUNT(*) 
FROM OlympicsDW.dbo.Fact_Olympic_Results;

/* TEST CASE 2: KIỂM TRA TỔNG SỐ HUY CHƯƠNG (MEDAL COUNT VALIDATION)
   Mục tiêu: Đảm bảo logic chuyển đổi "NA" -> 0 và tên huy chương -> 1 là chính xác.
*/

-- 1. Tính tổng huy chương từ Staging (Logic: Medal_ID có giá trị và tên khác 'NA')
WITH Cleaned_Staging AS (
    SELECT 
        ce.medal_id, m.medal_name,
        ROW_NUMBER() OVER(PARTITION BY ce.competitor_id, ce.event_id ORDER BY ce.medal_id DESC) as rn
    FROM StagingOlympics.dbo.Stage_Competitor_Event ce
    LEFT JOIN StagingOlympics.dbo.Stage_Medal m ON ce.medal_id = m.id
)
SELECT 
    'Staging' AS Source, 
    COUNT(*) AS Total_Medals_Awarded
FROM Cleaned_Staging
WHERE rn = 1 AND medal_name IN ('Gold', 'Silver', 'Bronze') -- Chỉ đếm huy chương thật
UNION ALL
-- 2. Tính tổng từ Fact Table (Dùng cột Medal_Count đã tính sẵn)
SELECT 
    'Data Warehouse', 
    SUM(Medal_Count)
FROM OlympicsDW.dbo.Fact_Olympic_Results;

/* TEST CASE 3: KIỂM TRA TỈ LỆ DỮ LIỆU "UNKNOWN" (DATA QUALITY)
   Mục tiêu: Đánh giá chất lượng dữ liệu nguồn.
*/

USE OlympicsDW;
GO

SELECT 
    'Athlete Lookup' AS Dimension,
    SUM(CASE WHEN Athlete_Key = -1 THEN 1 ELSE 0 END) AS Unknown_Count,
    COUNT(*) AS Total_Rows,
    CAST(SUM(CASE WHEN Athlete_Key = -1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Error_Rate_Percent
FROM dbo.Fact_Olympic_Results
UNION ALL
SELECT 
    'NOC (Country) Lookup',
    SUM(CASE WHEN NOC_Key = -1 THEN 1 ELSE 0 END),
    COUNT(*),
    CAST(SUM(CASE WHEN NOC_Key = -1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2))
FROM dbo.Fact_Olympic_Results
UNION ALL
SELECT 
    'Game Lookup',
    SUM(CASE WHEN Game_Key = -1 THEN 1 ELSE 0 END),
    COUNT(*),
    CAST(SUM(CASE WHEN Game_Key = -1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2))
FROM dbo.Fact_Olympic_Results;

/* TEST CASE 4: ĐỐI CHIẾU CHI TIẾT VẬN ĐỘNG VIÊN (SPOT CHECK)
   Mục tiêu: Đảm bảo các thông tin mô tả (Tên, Tuổi, Quốc gia, Sự kiện) không bị lệch.
*/

-- Truy vấn từ DW (Đã join các bảng Dim)
SELECT 
    a.Full_Name,
    g.Games_Name,
    e.Event_Name,
    n.NOC_Code,
    f.Age,
    m.Medal_Name
FROM OlympicsDW.dbo.Fact_Olympic_Results f
JOIN OlympicsDW.dbo.Dim_Athlete a ON f.Athlete_Key = a.Athlete_Key
JOIN OlympicsDW.dbo.Dim_Game g ON f.Game_Key = g.Game_Key
JOIN OlympicsDW.dbo.Dim_Event e ON f.Event_Key = e.Event_Key
JOIN OlympicsDW.dbo.Dim_NOC n ON f.NOC_Key = n.NOC_Key
JOIN OlympicsDW.dbo.Dim_Medal m ON f.Medal_Key = m.Medal_Key
WHERE a.Full_Name LIKE 'Usain%Bolt'
ORDER BY g.Year, e.Event_Name;

-- Đối chiếu thủ công với kết quả truy vấn gốc từ Staging 
SELECT 
    p.full_name,
    gm.games_name,
    ev.event_name,
    nr.noc,
    gc.age,
    md.medal_name
FROM StagingOlympics.dbo.Stage_Person p
JOIN StagingOlympics.dbo.Stage_Games_Competitor gc ON p.id = gc.person_id
JOIN StagingOlympics.dbo.Stage_Games gm ON gc.games_id = gm.id
JOIN StagingOlympics.dbo.Stage_Competitor_Event ce ON gc.id = ce.competitor_id
JOIN StagingOlympics.dbo.Stage_Event ev ON ce.event_id = ev.id
LEFT JOIN StagingOlympics.dbo.Stage_Medal md ON ce.medal_id = md.id
LEFT JOIN StagingOlympics.dbo.Stage_Person_Region pr ON p.id = pr.person_id
LEFT JOIN StagingOlympics.dbo.Stage_NOC_Region nr ON pr.region_id = nr.id
WHERE p.full_name LIKE 'Usain%Bolt'
ORDER BY gm.games_year, ev.event_name;

-- Kiểm tra tổng số huy chương Vàng của Michael Phelps
-- Kết quả mong đợi: Michael Phelps phải có tổng cộng 28 huy chương.
SELECT 
    a.Full_Name, 
    SUM(f.Medal_Count) AS Total_Medals
FROM dbo.Fact_Olympic_Results f
JOIN dbo.Dim_Athlete a ON f.Athlete_Key = a.Athlete_Key
JOIN dbo.Dim_Medal m ON f.Medal_Key = m.Medal_Key
WHERE a.Full_Name LIKE 'Michael Fred Phelps%'
GROUP BY a.Full_Name;