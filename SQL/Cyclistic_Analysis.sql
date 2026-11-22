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
