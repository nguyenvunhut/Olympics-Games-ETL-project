USE StagingOlympics;
GO
/* Thủ tục này sẽ được gọi trong "Execute SQL Task" đầu tiên của SSIS Control Flow 
*/
CREATE PROCEDURE dbo.sp_Truncate_Staging_Tables
AS
BEGIN
    TRUNCATE TABLE dbo.Stage_Person;
    TRUNCATE TABLE dbo.Stage_Games;
    TRUNCATE TABLE dbo.Stage_City;
    TRUNCATE TABLE dbo.Stage_Sport;
    TRUNCATE TABLE dbo.Stage_Event;
    TRUNCATE TABLE dbo.Stage_Medal;
    TRUNCATE TABLE dbo.Stage_NOC_Region;
    
    -- Truncate các bảng liên kết
    TRUNCATE TABLE dbo.Stage_Games_Competitor;
    TRUNCATE TABLE dbo.Stage_Competitor_Event;
    TRUNCATE TABLE dbo.Stage_Person_Region;
    TRUNCATE TABLE dbo.Stage_Games_City;
END
GO