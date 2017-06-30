drop table if exists oozie_raw_astrophysicists;

create external table oozie_raw_astrophysicists (astrophysicist_id STRING, astrophysicist_name STRING, year_of_birth STRING, nationality STRING) STORED AS PARQUET LOCATION '/user/saturn/raw/gravity/oozie_raw_astrophysicists';

Insert overwrite table oozie_astrophysicists select cast(astrophysicist_id as INT) astrophysicist_id, astrophysicist_name, CAST(year_of_birth as INT) year_of_birth, nationality from oozie_raw_astrophysicists;

