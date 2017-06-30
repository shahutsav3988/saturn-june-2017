drop table if exists gravity.oozie_raw_detectors;

CREATE EXTERNAL TABLE gravity.oozie_raw_detectors (
detector_id string, 
detector_name string, 
country string, 
latitude string, 
longitude string
)
 STORED AS PARQUET LOCATION '/user/saturn/raw/gravity/oozie_raw_detectors';

INSERT OVERWRITE TABLE gravity.oozie_detectors
    SELECT
        CAST(detector_id AS INT) AS detector_id,
        detector_name,
        country,
        CAST(latitude AS DECIMAL(20,16)) AS latitude,
        CAST(longitude AS DECIMAL(20,16)) AS longitude
    FROM gravity.oozie_raw_detectors;
    
