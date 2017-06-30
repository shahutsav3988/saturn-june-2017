drop table if exists gravity.oozie_raw_measurements;

CREATE EXTERNAL TABLE gravity.oozie_raw_measurements (
measurement_id STRING,
detector_id STRING,
galaxy_id STRING,
astrophysicist_id STRING,
measurement_time STRING,
amplitude_1 STRING,
amplitude_2 STRING,
amplitude_3 STRING
)
STORED AS PARQUET 
LOCATION '/user/saturn/raw/gravity/oozie_raw_measurements';

INSERT OVERWRITE TABLE gravity.oozie_measurements
    SELECT
        measurement_id,
        CAST(detector_id AS INT) AS detector_id,
        CAST(galaxy_id AS INT) AS galaxy_id,
        CAST(astrophysicist_id AS INT) AS astrophysicist_id,
        CAST(measurement_time AS BIGINT) AS measurement_time,
        CAST(amplitude_1 AS DECIMAL(20,16)) AS amplitude_1,
        CAST(amplitude_2 AS DECIMAL(20,16)) AS amplitude_2,
        CAST(amplitude_3 AS DECIMAL(20,16)) AS amplitude_3      
    FROM gravity.oozie_raw_measurements;
