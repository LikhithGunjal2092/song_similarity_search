use role accountadmin;
use database spotify;
use schema staging;


create table staging.features (
    danceability float,
    energy float,
    key integer,
    loudness float,
    mode integer,
    speechiness float,
    acousticness float,
    instrumentalness float,
    liveness float,
    valence float,
    tempo float,
    type varchar,
    id varchar,
    uri varchar,
    track_href varchar,
    analysis_url varchar,
    duration_ms integer,
    time_signature integer
);



create table staging.tracks
(
    id varchar
    ,track_popularity number(38,0)
    ,explicit boolean
);



create table staging.artist (
    id varchar,
    name varchar,
    artist_popularity integer,
    artist_genres array,
    followers integer,
    genre_0 varchar,
    genre_1 varchar,
    genre_2 varchar,
    genre_3 varchar,
    genre_4 varchar,
    genre_5 varchar,
    genre_6 varchar
);



create table staging.albums (
    track_name varchar,
    track_id varchar,
    track_number integer,
    duration_ms integer,
    album_type varchar,
    artists varchar,
    total_tracks integer,
    album_name varchar,
    release_date varchar,
    label varchar,
    album_popularity integer,
    album_id varchar,
    artist_id varchar,
    artist_0 varchar,
    artist_1 varchar,
    artist_2 varchar,
    artist_3 varchar,
    artist_4 varchar,
    artist_5 varchar,
    artist_6 varchar,
    artist_7 varchar,
    artist_8 varchar,
    artist_9 varchar,
    artist_10 varchar,
    artist_11 varchar,
    duration_sec float
);


create or replace table staging.feature_vector

(    track_id varchar
    ,track_name varchar
    ,artist_name varchar 
    ,feature_vector vector(float,11)
);

create or replace table spotify.analytics.song_search_times 
(
    search_id int autoincrement(1,1),
    track_id varchar,
    song_name varchar,
    search_time_ms float,
    warehouse_size varchar
    
);
