
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

