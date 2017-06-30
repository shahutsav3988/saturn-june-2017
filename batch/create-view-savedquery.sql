DROP TABLE IF EXISTS agg_gravitational_waves;

CREATE TABLE agg_gravitational_waves STORED AS PARQUET LOCATION '/user/saturn/raw/gravity/agg_gravitational_waves' AS select measurement_id,astrophysicist_name,nationality,galaxy_name,galaxy_type,detector_name,country,
if (m.amplitude_1 > 0.995 and m.amplitude_3 > 0.995 and m.amplitude_2 < 0.005 , 'Y', 'N') as wave_flag
from measurements m 
Left outer join astrophysicists a ON m.astrophysicist_id=a.astrophysicist_id
Left outer join galaxies g ON m.galaxy_id=g.galaxy_id
Left outer join detectors d ON m.detector_id=d.detector_id;
