# Please put Ingestion related work here



# Detectors


```


#!/bin/bash
sqoop import \
--connect 'jdbc:oracle:thin:@gravity.cghfmcr8k3ia.us-west-2.rds.amazonaws.com:15210:gravity' \
--username gravity \
--password bootcamp \
--table detectors \
--delete-target-dir \
--target-dir /user/saturn/raw/gravity/detectors_raw \
--as-parquetfile \
--fetch-size 10000 \
--compress \
--compression-codec snappy \
--num-mappers 5 \
--mapreduce-job-name saturn_gravity_detectors \
--null-non-string '\\N'

CREATE EXTERNAL TABLE gravity.detectors_raw (
detector_id STRING,
detector_name STRING,
country STRING,
latitude STRING,
longitude STRING
)
STORED AS PARQUET
LOCATION '/user/saturn/raw/gravity/detectors_raw';


CREATE EXTERNAL TABLE gravity.detectors (
detector_id INT,
detector_name STRING,
country STRING,
latitude DECIMAL,
longitude DECIMAL
)
STORED AS PARQUET
LOCATION '/user/saturn/raw/gravity/detectors';


INSERT OVERWRITE gravity.detectors
    SELECT 
        CAST(detector_id AS INT) AS detector_id,
        detector_name,
        country,
        CAST(latitude AS DECIMAL) AS latitude,
        CAST(longitude AS DECIMAL) AS longitude
    FROM gravity.detectors_raw`
    
```

# Measurements

```
#!/bin/bash
sqoop import \
--connect 'jdbc:oracle:thin:@gravity.cghfmcr8k3ia.us-west-2.rds.amazonaws.com:15210:gravity' \
--username gravity \
--password bootcamp \
--delete-target-dir \
--target-dir /user/saturn/raw/gravity/measurements_raw \
--as-parquetfile \
--fetch-size 10000 \
--compress \
--compression-codec snappy \
--num-mappers 20 \
--mapreduce-job-name saturn_gravity_measurements \
--null-non-string '\\N'
--direct
--split-by detector_id \
--query "select * from MEASUREMENTS WHERE $CONDITIONS"

CREATE EXTERNAL TABLE gravity.measurements_raw (
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
LOCATION '/user/saturn/raw/gravity/measurements_raw';


CREATE EXTERNAL TABLE gravity.measurements (
measurement_id STRING,
detector_id INT,
galaxy_id INT,
astrophysicist_id INT,
measurement_time BIGINT,
amplitude_1 DECIMAL(20,16),
amplitude_2 DECIMAL(20,16),
amplitude_3 DECIMAL(20,16)
)
STORED AS PARQUET
LOCATION '/user/saturn/raw/gravity/measurements';

INSERT OVERWRITE gravity.measurements
    SELECT 
        measurement_id,
        CAST(detector_id AS INT) AS detector_id,
        CAST(galaxy_id AS INT) AS galaxy_id,
        CAST(astrophysicist_id AS INT) AS astrophysicist_id,
        CAST(measurement_time AS BIGINT) AS measurement_time,
        CAST(amplitude_1 AS DECIMAL(20,16)) AS amplitude_1,
        CAST(amplitude_2 AS DECIMAL(20,16)) AS amplitude_2,
        CAST(amplitude_3 AS DECIMAL(20,16)) AS amplitude_3       
    FROM gravity.measurements_raw
```


# Astrophysicist

```
sqoop import \
--connect 'jdbc:oracle:thin:@gravity.cghfmcr8k3ia.us-west-2.rds.amazonaws.com:15210:gravity' \
--username gravity \
--password bootcamp \
--table ASTROPHYSICISTS \
--delete-target-dir \
--target-dir /user/saturn/raw/gravity/astrophysicists_raw \
--as-parquetfile \
--fetch-size 10000 \
--compress \
--compression-codec snappy \
--num-mappers 1 \
--mapreduce-job-name saturn_gravity_astrophysicists \
--null-non-string '\\N'

CREATE EXTERNAL TABLE astrophysicists_raw (
astrophysicist_id STRING,
astrophysicist_name STRING,
year_of_birth STRING,
nationality STRING)
STORED AS PARQUET
LOCATION '/user/saturn/raw/gravity/astrophysicists_raw';

CREATE TABLE astrophysicists (
astrophysicist_id INT,
astrophysicist_name STRING,
year_of_birth INT,
nationality STRING)
STORED AS PARQUET
LOCATION '/user/saturn/raw/gravity/astrophysicists';

INSERT OVERWRITE astrophysicists
	SELECT
	   CAST(astrophysicist_id as INT) AS astrophysicist_id,
	   astrophysicist_name,
	   CAST(year_of_birth as INT) AS year_of_birth,
	   nationality
	FROM astrophysicists_raw;

```

# Galaxies

```
sqoop import \
--connect 'jdbc:oracle:thin:@gravity.cghfmcr8k3ia.us-west-2.rds.amazonaws.com:15210:gravity' \
--username gravity \
--password bootcamp \
--table GALAXIES \
--delete-target-dir \
--target-dir /user/saturn/raw/gravity/galaxies_raw \
--as-parquetfile \
--fetch-size 10000 \
--compress \
--compression-codec snappy \
--num-mappers 1 \
--mapreduce-job-name saturn_gravity_galaxies \
--null-non-string '\\N'

CREATE EXTERNAL TABLE galaxies_raw (
galaxy_id STRING,
galaxy_name STRING,
galaxy_type STRING,
distance_ly STRING,
absolute_magnitude STRING,
apparent_magnitude STRING,
galaxy_group STRING)
LOCATION '/user/saturn/raw/gravity/galaxies_rawí;

CREATE TABLE galaxies (
galaxy_id INT,
galaxy_name STRING,
galaxy_type STRING,
distance_ly DOUBLE,
absolute_magnitude DOUBLE,
apparent_magnitude DOUBLE,
galaxy_group STRING)
STORED AS PARQUET
LOCATION '/user/saturn/raw/gravity/galaxiesí ;

INSERT OVERWRITE gravity.galaxies
	SELECT
		CAST(galaxy_id as INT) AS galaxy_id,
		galaxy_name,
		galaxy_type,
		CAST(distance_ly as DOUBLE) AS distance_ly,
		CAST(absolute_magnitude as DOUBLE) AS absolute_magnitude,
		CAST(apparent_magnitude as DOUBLE) AS apparent_magnitude,
		galaxy_group
	FROM galaxies_raw;

```

# Impala Queries

```
SELECT count(*)
FROM measurements m
WHERE m.amplitude_1 > 0.995
  AND m.amplitude_3 > 0.995
  AND m.amplitude_2 < 0.005
--Result: 56 

select * from astrophysicists
select * from detectors
select * from galaxies
select * from measurements


```

# Views

```

create view gravitational_waves as select measurement_id,astrophysicist_id,galaxy_id,detector_id,measurement_time from measurements where amplitude_1 > 0.995 and amplitude_3 > 0.995 and amplitude_2 < 0.005  


create view gravitational_waves_user as select measurement_id,astrophysicist_name,nationality,galaxy_name,galaxy_type,detector_name,country from measurements m 
Left outer join astrophysicists a ON m.astrophysicist_id=a.astrophysicist_id
Left outer join galaxies g ON m.galaxy_id=g.galaxy_id
Left outer join detectors d ON m.detector_id=d.detector_id
 WHERE m.amplitude_1 > 0.995 and m.amplitude_3 > 0.995 and m.amplitude_2 < 0.005  
 
 
 create table gravitational_waves_user as select * from gravitational_waves_user;
```



# Flag query 

```
select measurement_id,astrophysicist_name,nationality,galaxy_name,galaxy_type,detector_name,country,
if (m.amplitude_1 > 0.995 and m.amplitude_3 > 0.995 and m.amplitude_2 < 0.005 , 'Y', 'N') as wave_flag
from measurements m 
Left outer join astrophysicists a ON m.astrophysicist_id=a.astrophysicist_id
Left outer join galaxies g ON m.galaxy_id=g.galaxy_id
Left outer join detectors d ON m.detector_id=d.detector_id
```
