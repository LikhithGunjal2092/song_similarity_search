use role accountadmin;
use warehouse compute_wh;
use database spotify;
use schema spotify.staging;

create stage my_s3_stage
storage_integration = s3_int
url = 's3://spotify-bigdata/staging/'
file_format = my_csv;