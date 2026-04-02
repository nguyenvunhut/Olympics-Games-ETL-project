USE StagingOlympics;
GO

SELECT 'Person' AS TableName, 
       (SELECT COUNT(*) FROM olympics.dbo.person) AS Source_Count,
       (SELECT COUNT(*) FROM StagingOlympics.dbo.Stage_Person) AS Staging_Count
UNION ALL
SELECT 'Games', 
       (SELECT COUNT(*) FROM olympics.dbo.games),
       (SELECT COUNT(*) FROM StagingOlympics.dbo.Stage_Games)
UNION ALL
SELECT 'Competitor_Event', 
       (SELECT COUNT(*) FROM olympics.dbo.competitor_event),
       (SELECT COUNT(*) FROM StagingOlympics.dbo.Stage_Competitor_Event)
UNION ALL
SELECT 'City', 
       (SELECT COUNT(*) FROM olympics.dbo.city),
       (SELECT COUNT(*) FROM StagingOlympics.dbo.Stage_City)
UNION ALL
SELECT 'Event', 
       (SELECT COUNT(*) FROM olympics.dbo.event),
       (SELECT COUNT(*) FROM StagingOlympics.dbo.Stage_Event)
UNION ALL
SELECT 'Games_City', 
       (SELECT COUNT(*) FROM olympics.dbo.games_city),
       (SELECT COUNT(*) FROM StagingOlympics.dbo.Stage_Games_City)
UNION ALL
SELECT 'games_competitor', 
       (SELECT COUNT(*) FROM olympics.dbo.games_competitor),
       (SELECT COUNT(*) FROM StagingOlympics.dbo.Stage_Games_Competitor)
UNION ALL
SELECT 'medal', 
       (SELECT COUNT(*) FROM olympics.dbo.medal),
       (SELECT COUNT(*) FROM StagingOlympics.dbo.Stage_Medal)
UNION ALL
SELECT 'NOC_region', 
       (SELECT COUNT(*) FROM olympics.dbo.noc_region),
       (SELECT COUNT(*) FROM StagingOlympics.dbo.Stage_NOC_Region)
UNION ALL
SELECT 'Person_region', 
       (SELECT COUNT(*) FROM olympics.dbo.person_region),
       (SELECT COUNT(*) FROM StagingOlympics.dbo.Stage_Person_Region)
UNION ALL
SELECT 'Sport', 
       (SELECT COUNT(*) FROM olympics.dbo.sport),
       (SELECT COUNT(*) FROM StagingOlympics.dbo.Stage_Sport)
