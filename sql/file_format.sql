use role accountadmin;
use warehouse compute_wh;
use database spotify;
use schema spotify.staging;

create file format my_csv 
type=csv;