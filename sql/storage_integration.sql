use role accountadmin;
use warehouse compute_wh;
use database spotify;
use schema spotify.staging;

create storage integration s3_int
  type = external_stage
  storage_provider = 's3'
  enabled = true
  storage_aws_role_arn = 'arn:aws:iam::354918362659:role/snwoflakes3role'
  storage_allowed_locations = ('*');