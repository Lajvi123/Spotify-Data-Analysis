select*from spotify_data;

--(1) Overview of my listening habits --

select count(*) as total_tracks,
count(distinct artistName) as Artists,
count(distinct trackName) as Songs,
sum(msPlayed) / 3600000.0 as Total_hours_played
from spotify_data;


--(2) What are the 10 most played artists ?--
select TOP 10 artistName, count(*) as play_count,
round(SUM(msPlayed) / 60000, 2) AS total_minutes_played
from spotify_data
group by artistName
order by play_count DESC


--(3) What are the 10 most played tracks ? --
select TOP 10 trackName, count(*) as play_count,
round(SUM(msPlayed) / 60000, 2) AS total_minutes_played
from spotify_data
group by trackName
order by play_count DESC


--(4) Analyse the listening pattern by hour of the day --
select DATEPART(hour, endTime) as hour_of_the_day,
count(*) as play_count,
round(SUM(msPlayed) / 3600000 , 2) AS total_hours_played
from spotify_data
group by DATEPART(hour, endTime)
order by hour_of_the_day;

--(5) Artist Diversity -- 
SELECT COUNT(DISTINCT artistName) AS unique_artists_count
FROM spotify_data;



--(6) Identify listening sessions (tracks played within 30 minutes of each other)
WITH sessions AS (
    SELECT *,
           CASE 
               WHEN DATEDIFF(MINUTE, LAG(endTime) OVER (ORDER BY endTime), endTime) > 30 
               THEN 1 ELSE 0 
           END AS new_session
    FROM spotify_data
)
SELECT COUNT(*) AS total_sessions
FROM (SELECT SUM(new_session) AS session_count FROM sessions) AS session_counts;


--(7) Monthly listening trends 
SELECT FORMAT(endTime, 'yyyy-MM') AS month,
       SUM(msPlayed) / 3600000.0 AS total_hours_played
FROM spotify_data
GROUP BY FORMAT(endTime, 'yyyy-MM')
ORDER BY month;


--(8) What are your peak listening hours?
select top 5 datepart(hour, endTime) as hour,
count(*) as play_count
from spotify_data
group by datepart(hour, endTime)
order by play_count desc

--(9) Which days of the week do you listen to music the most?
select datename(weekday, endTime) as day_of_week,
count(*) as play_count
from spotify_data
group by datename(weekday,endTime)
order by play_count desc; 

--(10) Which songs do you tend to skip most often ?
SELECT top 10 trackName, artistName, msPlayed
FROM spotify_data
WHERE msPlayed < 1000
ORDER BY msPlayed ASC

--(11) What is the overall skip rate ?
SELECT 
    ROUND((COUNT(CASE WHEN msPlayed < 1000 THEN 1 END) * 100 / COUNT(*)), 2) AS skip_rate_percentage
FROM spotify_data;


--(12) How does your listening compare between weekdays and weekends?
SELECT 
    CASE 
        WHEN DATENAME(WEEKDAY, endTime) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS play_count,
    AVG(msPlayed) AS avg_duration
FROM spotify_data
GROUP BY 
    CASE 
        WHEN DATENAME(WEEKDAY, endTime) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END;


--(13) Are there any artists or tracks you've stopped listening to?
WITH artist_listening AS (
    SELECT artistName,
           MIN(endTime) AS first_listen,
           MAX(endTime) AS last_listen,
           DATEDIFF(DAY, MAX(endTime), '2024-05-30') AS days_since_last_listen
    FROM spotify_data
    GROUP BY artistName
)
SELECT top 10 artistName, first_listen, last_listen, days_since_last_listen
FROM artist_listening
WHERE days_since_last_listen > 7
ORDER BY days_since_last_listen DESC;