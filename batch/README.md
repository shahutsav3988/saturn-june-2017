
# oozie Workflows

```

Keep workflow here

```

# Spark Script

```

import sys
from pyspark import SparkContext
from pyspark import SparkConf
from pyspark.sql import HiveContext
if __name__ == "__main__":
  sc = SparkContext()
  hiveContext = HiveContext(sc)
  detectors = hiveContext.read.parquet("/user/saturn/raw/gravity/detectors_raw/*.parquet")
  detectors.registerTempTable("detectors")
  galaxies = hiveContext.read.parquet("/user/saturn/raw/gravity/raw_galaxies/*.parquet")
  galaxies.registerTempTable("galaxies")
  astrophysicists = hiveContext.read.parquet("/user/saturn/raw/gravity/astrophysicists_raw/*.parquet")
  astrophysicists.registerTempTable("astrophysicists")
  measurements = hiveContext.read.parquet("/user/saturn/raw/gravity/measurements_raw/01*.parquet")
  measurements.registerTempTable("measurements");
  measurementDen = measurements.join(astrophysicists, measurements.ASTROPHYSICIST_ID.cast('INT') == astrophysicists.ASTROPHYSICIST_ID.cast('INT'), 'left_outer') \
                               .join(detectors, measurements.DETECTOR_ID.cast('INT') == detectors.DETECTOR_ID.cast('INT'), 'left_outer') \
                               .join(galaxies, measurements.GALAXY_ID.cast('INT') == galaxies.GALAXY_ID.cast('INT'), 'left_outer') \
                               .select(measurements.MEASUREMENT_ID, measurements.DETECTOR_ID.cast('INT'), measurements.GALAXY_ID.cast('INT'), measurements.ASTROPHYSICIST_ID.cast('INT'), measurements.MEASUREMENT_TIME.cast('BIGINT'), measurements.AMPLITUDE_1.cast('DECIMAL(20,16)'), measurements.AMPLITUDE_2.cast('DECIMAL(20,16)'), \
                                       measurements.AMPLITUDE_3.cast('DECIMAL(20,16)'), astrophysicists.ASTROPHYSICIST_NAME, astrophysicists.YEAR_OF_BIRTH.cast('INT'), astrophysicists.NATIONALITY, detectors.DETECTOR_NAME, detectors.COUNTRY, detectors.LATITUDE.cast('DECIMAL(10,6)'), detectors.LONGITUDE.cast('DECIMAL(10,6)'), \
                                       galaxies.GALAXY_NAME, galaxies.GALAXY_TYPE, galaxies.DISTANCE_LY.cast('DECIMAL(5,3)'), galaxies.ABSOLUTE_MAGNITUDE.cast('DECIMAL(5,3)'), galaxies.APPARENT_MAGNITUDE.cast('DECIMAL(5,3)'), galaxies.GALAXY_GROUP)
  measurementDen.write.format("parquet").mode("overwrite").saveAsTable("gravity.measurementDen_spark")
  #hiveContext.sql("select * from measurementDen").show(5)
  #measurementDen.select(measurementDen.detector_id).show(5)
  
  sc.stop()

```
