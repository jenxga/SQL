-- CREATING  TABLE

-- Note: To recreate the table for other months, just change the number to its equivalent month. 

CREATE TABLE tripdata_0123 (  
	ride_id VARCHAR,
	rideable_type VARCHAR,
	started_at TIMESTAMP,
	ended_at TIMESTAMP,
	start_station_name VARCHAR,
	start_station_id VARCHAR,
	end_station_name VARCHAR,
	end_station_id VARCHAR,
	start_lat FLOAT,
	start_lng FLOAT,
	end_lat FLOAT,
	end_lng FLOAT,
	member_casual TEXT
);

-- COMBINING ALL THE TABLES FOR ANALYSIS

CREATE TABLE tripdata_2023 AS 
SELECT * FROM tripdata_0123
UNION
SELECT * FROM tripdata_0223
UNION
SELECT * FROM tripdata_0323
UNION
SELECT * FROM tripdata_0423
UNION
SELECT * FROM tripdata_0523
UNION
SELECT * FROM tripdata_0623
UNION
SELECT * FROM tripdata_0723
UNION
SELECT * FROM tripdata_0823
UNION
SELECT * FROM tripdata_0923
UNION
SELECT * FROM tripdata_1023
UNION
SELECT * FROM tripdata_1123
UNION
SELECT * FROM tripdata_1223;

-- ADDING COLUMNS FOR RIDE LENGTH CALCULATION

ALTER TABLE tripdata_2023
ADD COLUMN started_at_time TIME,
ADD COLUMN ended_at_time TIME,
ADD COLUMN ride_length TIME;

-- SETTING UP THE VALUES FOR THE NEWLY CREATED COLUMNS

UPDATE tripdata_2023
SET started_at_time = started_at::time without time zone,
	ended_at_time = ended_at::time without time zone;

UPDATE tripdata_2023
SET ride_length = ended_at_time - started_at_time;

-- ADDING THESE COLUMN FOR FURTHER JUSTIFICATION

ALTER TABLE tripdata_2023
ADD COLUMN lat_threshold FLOAT,
ADD COLUMN lng_threshold FLOAT;

UPDATE tripdata_2023
SET lat_threshold = end_lat - start_lat,
	lng_threshold = end_lng - start_lng;

-- REMOVING THE OUTLIERS 

DELETE FROM tripdata_2023
WHERE ride_length <= '00:01:00';

-- REMOVING COLUMNS

ALTER TABLE tripdata_2023
DROP COLUMN started_at_time,
DROP COLUMN ended_at_time,
DROP COLUMN lat_threshold,
DROP COLUMN lng_threshold;

-- CHECKING FOR ANY DUPLICATE VALUES

SELECT ride_id, COUNT(*)
FROM tripdata_2023
GROUP BY ride_id
HAVING COUNT(*) > 1;

-- TOTAL RIDERS

SELECT COUNT(*) AS total_riders
FROM tripdata_2023;

-- TOTAL CASUAL AND MEMBER RIDERS

SELECT member_casual,
COUNT(*) AS total_riders
FROM tripdata_2023
GROUP BY member_casual;

-- AVERAGE RIDE LENGTH

SELECT member_casual, 
AVG(ride_length)::time(0) AS average_ride_length
FROM tripdata_2023
GROUP BY member_casual;

-- WHAT TYPE OF BIKES ARE POPULAR AMONG THE RIDERS

SELECT rideable_type, member_casual,
COUNT(*) AS total_riders
FROM tripdata_2023
GROUP BY member_casual, rideable_type;

-- ADDING DAY OF THE WEEK, MONTH, AND TIME OF DAY COLUMN

ALTER TABLE tripdata_2023
ADD COLUMN day_of_week TEXT,
ADD COLUMN month TEXT,
ADD COLUMN time_of_the_day TEXT;

UPDATE tripdata_2023
SET day_of_week =TO_CHAR(started_at, 'Day'), 
	month = TO_CHAR(started_at, 'Month'),
	time_of_the_day = CASE 
		WHEN TO_CHAR(started_at,  'HH24:MI:SS') BETWEEN '06:00:00' AND '11:59:00' THEN 'Morning'
		WHEN TO_CHAR(started_at,  'HH24:MI:SS') BETWEEN '12:00:00' AND '17:59:00' THEN 'Afternoon'
		WHEN TO_CHAR(started_at,  'HH24:MI:SS') BETWEEN '18:00:00' AND '21:59:00' THEN 'Evening'
		ELSE 'Night'
	END;

-- TOTAL CASUAL RIDERS BY MONTH

SELECT month, 
COUNT(*) AS  total_casual_riders,
AVG(ride_length)::time(0) AS average_ride_length_casual
FROM tripdata_2023
GROUP BY month, member_casual
HAVING member_casual = 'casual'
ORDER BY total_casual_riders DESC;

-- TOTAL CASUAL RIDERS BY TIME OF THE DAY

SELECT time_of_the_day, 
COUNT(*) AS total_casual_riders,
AVG(ride_length)::time(0) AS average_ride_length
FROM tripdata_2023
GROUP BY time_of_the_day, member_casual
HAVING member_casual = 'casual'
ORDER BY total_casual_riders DESC;

-- TOTAL CASUAL RIDERS BY DAY OF WEEK

SELECT day_of_week, 
COUNT(*) AS  total_casual_riders,
AVG(ride_length)::time(0) AS average_ride_length_casual
FROM tripdata_2023
GROUP BY day_of_week, member_casual
HAVING member_casual = 'casual'
ORDER BY total_casual_riders DESC;