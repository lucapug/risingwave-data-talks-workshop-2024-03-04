CREATE TABLE avg_fare_amt_1_min(
    avg_fare_amount_per_min numeric,
    num_rides_per_min Int64,
) ENGINE = ReplacingMergeTree
PRIMARY KEY (avg_fare_amount_per_min, num_rides_per_min);