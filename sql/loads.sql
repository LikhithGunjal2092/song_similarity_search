
use role accountadmin;
use database spotify;
use schema staging;

copy into staging.features
from @my_s3_stage/spotify_features_data_2023.csv
file_format = ( 
    type = 'csv' 
    field_optionally_enclosed_by = '"' 
    skip_header = 1 
    null_if = ('', 'null')
);


copy into staging.tracks
from @my_s3_stage/spotify_tracks_data_2023.csv
file_format = ( 
    type = 'csv' 
    field_optionally_enclosed_by = '"' 
    skip_header = 1 
    null_if = ('', 'null')
);



copy into staging.artist 
from @my_s3_stage/spotify_artist_data_2023.csv
file_format = ( 
    type = 'csv' 
    field_optionally_enclosed_by = '"' 
    skip_header = 1 
    null_if = ('', 'null')
);


copy into staging.albums 
from @my_s3_stage/spotify-albums_data_2023.csv
file_format = ( 
    type = 'csv' 
    field_optionally_enclosed_by = '"' 
    skip_header = 1 

);


insert into staging.feature_vector
select f.id
      ,a.track_name
      ,a.artist_0
      ,array_construct(danceability,energy,key,loudness,mode,speechiness,acousticness,instrumentalness,liveness,valence,tempo)::VECTOR(FLOAT, 11)
from staging.features f
inner join staging.albums a
    on a.track_id = f.id;


--- insert sample song subset for benchmarking into analytics.song_search_times

insert into analytics.song_search_times(track_id,song_name,warehouse_size)
select track_id,track_name,'Small'  from spotify.staging.feature_vector where len(track_name)>2  and regexp_like(collate(track_name,''), '[a-zA-Z]+')  limit 1000;

insert into analytics.song_search_times(track_id,song_name,warehouse_size)
select track_id,song_name,'Medium'
from spotify.analytics.song_search_times 
where warehouse_size = 'Small'
order by track_id
limit 1000;

insert into analytics.song_search_times(track_id,song_name,warehouse_size)
select track_id,song_name,'Large'
from spotify.analytics.song_search_times
where warehouse_size = 'Small'
order by track_id,warehouse_size
limit 1000;
