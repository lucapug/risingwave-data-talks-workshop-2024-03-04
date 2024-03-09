-- Ans. 1
CREATE MATERIALIZED VIEW trips_stats AS
WITH t AS (
    SELECT taxi_zone.Zone as pickup_zone, taxi_zone_1.Zone as dropoff_zone, tpep_pickup_datetime, 
    tpep_dropoff_datetime, tpep_dropoff_datetime - tpep_pickup_datetime AS trip_time
    FROM trip_data
        JOIN taxi_zone ON trip_data.PULocationID = taxi_zone.location_id
        JOIN taxi_zone as taxi_zone_1 ON trip_data.DOLocationID = taxi_zone_1.location_id
)
SELECT
    pickup_zone, dropoff_zone, avg(trip_time) AS avg_trip_time,
    min(trip_time) AS min_trip_time, max(trip_time) AS max_trip_time
FROM t
GROUP BY
    pickup_zone, dropoff_zone
ORDER BY
    pickup_zone, dropoff_zone;


WITH max_avg AS (SELECT MAX(avg_trip_time) AS max FROM trips_stats)
SELECT
    pickup_zone, dropoff_zone, avg_trip_time
FROM    
    trips_stats, max_avg
WHERE
    avg_trip_time = max;

--end Ans.1

-- Ans. 2
CREATE MATERIALIZED VIEW trips_stats_2 AS
WITH t AS (
    SELECT taxi_zone.Zone as pickup_zone, taxi_zone_1.Zone as dropoff_zone, tpep_pickup_datetime, 
    tpep_dropoff_datetime, tpep_dropoff_datetime - tpep_pickup_datetime AS trip_time
    FROM trip_data
        JOIN taxi_zone ON trip_data.PULocationID = taxi_zone.location_id
        JOIN taxi_zone as taxi_zone_1 ON trip_data.DOLocationID = taxi_zone_1.location_id
)
SELECT
    pickup_zone, dropoff_zone, COUNT(*) AS trips_count, avg(trip_time) AS avg_trip_time,
    min(trip_time) AS min_trip_time, max(trip_time) AS max_trip_time
FROM t
GROUP BY
    pickup_zone, dropoff_zone
ORDER BY
    pickup_zone, dropoff_zone;


DROP MATERIALIZED VIEW trips_stats;
ALTER MATERIALIZED VIEW trips_stats_2 RENAME TO trips_stats;

WITH max_avg AS (SELECT MAX(avg_trip_time) AS max FROM trips_stats)
SELECT
    pickup_zone, dropoff_zone, avg_trip_time, trips_count
FROM    
    trips_stats, max_avg
WHERE
    avg_trip_time = max;

-- end Ans.2

-- Ans. 3
CREATE MATERIALIZED VIEW latest_pickup_time AS
WITH t AS (
    SELECT
        max(tpep_pickup_datetime) AS latest_pickup_time
    FROM
        trip_data
)
SELECT
    taxi_zone.Zone as taxi_zone, latest_pickup_time
FROM
    t, trip_data
        JOIN  taxi_zone ON trip_data.PULocationID = taxi_zone.location_id 
WHERE trip_data.tpep_pickup_datetime = t.latest_pickup_time;


SELECT
    taxi_zone.Zone AS pickup_zone, count(*) AS cnt
FROM
    trip_data
        JOIN latest_pickup_time
            ON trip_data.tpep_pickup_datetime > (latest_pickup_time.latest_pickup_time - interval '17 hour')
        JOIN taxi_zone
            ON trip_data.PULocationID = taxi_zone.location_id
GROUP BY
	taxi_zone.Zone
ORDER BY
	cnt DESC
LIMIT 3;

-- end Ans. 3
