-- ============================================================
-- 1. DATA PREPARATION
-- ============================================================

-- 1.1 Create ride_length column
-- Calculates the duration of each ride.
-- Invalid records where started_at > ended_at are excluded
-- from the calculation by leaving ride_length as NULL.

ALTER TABLE bike_trip_copy
ADD COLUMN ride_length TIME;

UPDATE bike_trip_copy
SET ride_length = TIMEDIFF(ended_at, started_at)
WHERE started_at <= ended_at;


-- 1.2 Create day_of_week column
-- Extracts the day of the week from started_at.
-- MySQL DAYOFWEEK(): Sunday = 1, Saturday = 7.

ALTER TABLE bike_trip_copy
ADD COLUMN day_of_week INT;

UPDATE bike_trip_copy
SET day_of_week = DAYOFWEEK(started_at);


-- 1.3 Create day column
-- Converts the numeric day_of_week into weekday names.

ALTER TABLE bike_trip_copy
ADD COLUMN day VARCHAR(10);

UPDATE bike_trip_copy
SET day = CASE
    WHEN day_of_week = 1 THEN 'Sunday'
    WHEN day_of_week = 2 THEN 'Monday'
    WHEN day_of_week = 3 THEN 'Tuesday'
    WHEN day_of_week = 4 THEN 'Wednesday'
    WHEN day_of_week = 5 THEN 'Thursday'
    WHEN day_of_week = 6 THEN 'Friday'
    WHEN day_of_week = 7 THEN 'Saturday'
END;

-- ============================================================
-- 2. DESCRIPTIVE ANALYSIS
-- ============================================================


-- 2.1 Average Ride Length
-- Calculates the average duration of all rides.

SELECT
    SEC_TO_TIME(AVG(TIME_TO_SEC(ride_length))) AS avg_ride_length
FROM bike_trip_copy;


-- 2.2 Maximum Ride Length
-- Identifies the longest ride duration.

SELECT
    MAX(ride_length) AS max_ride_length
FROM bike_trip_copy;


-- 2.3 Minimum Ride Length
-- Identifies the shortest ride duration.

SELECT
    MIN(ride_length) AS min_ride_length
FROM bike_trip_copy;


-- 2.4 Total Number of Rides
-- Counts all recorded rides.

SELECT
    COUNT(ride_id) AS total_rides
FROM bike_trip_copy;


-- 2.5 Ride Count by Rider Type
-- Compares the total rides taken by Members and Casual riders.

SELECT
    member_casual,
    COUNT(ride_id) AS total_rides
FROM bike_trip_copy
GROUP BY member_casual;


-- 2.6 Ride Count and Average Ride Length by Rider Type
-- Compares ride volume and average duration between rider types.

SELECT
    member_casual,
    COUNT(ride_id) AS total_rides,
    SEC_TO_TIME(AVG(TIME_TO_SEC(ride_length))) AS avg_ride_length
FROM bike_trip_copy
GROUP BY member_casual;


-- 2.7 Ride Count by Bike Type
-- Identifies the usage of each bike type.

SELECT
    rideable_type,
    COUNT(ride_id) AS total_rides
FROM bike_trip_copy
GROUP BY rideable_type;


-- 2.8 Ride Count by Day
-- Counts rides for each day of the week.

SELECT
    day,
    COUNT(ride_id) AS total_rides
FROM bike_trip_copy
GROUP BY day;


-- 2.9 Ride Count by Day and Rider Type
-- Compares weekday ride counts between Members and Casual riders.

SELECT
    day,
    member_casual,
    COUNT(ride_id) AS rider_count
FROM bike_trip_copy
GROUP BY day, member_casual;


-- 2.10 Average Ride Length by Day
-- Calculates average ride duration for each day of the week.

SELECT
    day,
    SEC_TO_TIME(AVG(TIME_TO_SEC(ride_length))) AS avg_ride_length
FROM bike_trip_copy
GROUP BY day;


-- 2.11 Average Ride Length by Day and Rider Type
-- Compares average daily ride durations between Members and Casual riders.

SELECT
    day,
    member_casual,
    SEC_TO_TIME(AVG(TIME_TO_SEC(ride_length))) AS avg_ride_length
FROM bike_trip_copy
GROUP BY day, member_casual;


-- 2.12 Monthly Ride Distribution by Rider Type
-- Analyzes monthly ride volume for Members and Casual riders.

SELECT
    MONTH(started_at) AS month,
    member_casual,
    COUNT(ride_id) AS total_rides
FROM bike_trip_copy
GROUP BY MONTH(started_at), member_casual
ORDER BY month, member_casual;


-- 2.13 Hourly Ride Distribution by Rider Type
-- Identifies hourly ride patterns for Members and Casual riders.

SELECT
    HOUR(started_at) AS ride_hour,
    member_casual,
    COUNT(ride_id) AS ride_count
FROM bike_trip_copy
GROUP BY ride_hour, member_casual
ORDER BY ride_hour;

-- ============================================================
-- 3. VIEWS
-- ============================================================

-- 3.1 Average Ride Length

CREATE OR REPLACE VIEW avg_ride_length AS
SELECT
    SEC_TO_TIME(AVG(TIME_TO_SEC(ride_length))) AS ride_duration
FROM bike_trip_copy;


-- 3.2 Average Ride Length by Rider Type

CREATE OR REPLACE VIEW avg_ride_length_per_member_casual AS
SELECT
    member_casual,
    SEC_TO_TIME(AVG(TIME_TO_SEC(ride_length))) AS avg_ride_length
FROM bike_trip_copy
GROUP BY member_casual;


-- 3.3 Average Ride Length by Day and Rider Type

CREATE OR REPLACE VIEW avg_ride_length_per_day_and_member_casual AS
SELECT
    day,
    member_casual,
    SEC_TO_TIME(AVG(TIME_TO_SEC(ride_length))) AS avg_ride_length
FROM bike_trip_copy
GROUP BY day, member_casual;


-- 3.4 Bike Type Preference by Rider Type

CREATE OR REPLACE VIEW bike_type_preference AS
SELECT
    rideable_type,
    member_casual,
    COUNT(ride_id) AS rider_count
FROM bike_trip_copy
GROUP BY rideable_type, member_casual;


-- 3.5 Ride Count by Bike Type

CREATE OR REPLACE VIEW favourable_bike AS
SELECT
    rideable_type,
    COUNT(ride_id) AS rider_count
FROM bike_trip_copy
GROUP BY rideable_type;


-- 3.6 Hourly Ride Distribution

CREATE OR REPLACE VIEW hourly_ride_distribution AS
SELECT
    HOUR(started_at) AS ride_hour,
    member_casual,
    COUNT(ride_id) AS ride_count
FROM bike_trip_copy
GROUP BY ride_hour, member_casual;


-- 3.7 Maximum Ride Length

CREATE OR REPLACE VIEW max_ride_length AS
SELECT
    SEC_TO_TIME(MAX(TIME_TO_SEC(ride_length))) AS ride_duration
FROM bike_trip_copy;


-- 3.8 Most Frequent Riding Day

CREATE OR REPLACE VIEW mode AS
SELECT
    day,
    COUNT(ride_id) AS rider_frequency
FROM bike_trip_copy
GROUP BY day;


-- 3.9 Monthly Ride Trend

CREATE OR REPLACE VIEW monthly_ride_trend AS
SELECT
    MONTH(started_at) AS month,
    member_casual,
    COUNT(ride_id) AS ride_count
FROM bike_trip_copy
GROUP BY month, member_casual;


-- 3.10 Popular Ending Stations

CREATE OR REPLACE VIEW popular_end_stations AS
SELECT
    end_station_name,
    member_casual,
    COUNT(ride_id) AS ride_count
FROM bike_trip_copy
GROUP BY end_station_name, member_casual;


-- 3.11 Popular Starting Stations

CREATE OR REPLACE VIEW popular_start_stations AS
SELECT
    start_station_name,
    member_casual,
    COUNT(ride_id) AS ride_count
FROM bike_trip_copy
GROUP BY start_station_name, member_casual;


-- 3.12 Ride Count per Day

CREATE OR REPLACE VIEW rider_count_per_day AS
SELECT
    day,
    COUNT(ride_id) AS rider_count
FROM bike_trip_copy
GROUP BY day;


-- 3.13 Rider Type Distribution

CREATE OR REPLACE VIEW rider_type_distribution AS
SELECT
    member_casual,
    COUNT(ride_id) AS rider_count,
    ROUND(
        COUNT(ride_id) * 100.0 / (SELECT COUNT(ride_id) FROM bike_trip_copy),
        2
    ) AS ride_percentage
FROM bike_trip_copy
GROUP BY member_casual;
