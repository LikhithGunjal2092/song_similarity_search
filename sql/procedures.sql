use role accountadmin;
use database spotify;
use schema staging;

create or replace procedure spotify.staging.find_similar_song("song_name" varchar(16777216))
returns table ("similar_track_id" varchar(16777216), "similar_track_name" varchar(16777216), "similar_artist" varchar(16777216), "similarity_score" number(38,2))
language sql
execute as caller
as begin
let results resultset := 
(

    with best_search as
    (
        select track_id 
        from spotify.staging.tracks tr
        inner join spotify.staging.albums ab
            on ab.track_id = tr.id
        where track_name like :song_name
        order by tr.track_popularity desc
        limit 1
    )
    , base_song as 
    (
        select feature_vector,track_name,track_id
        from staging.feature_vector
        where track_id = (select track_id from best_search)
    
    )
    
    select   cast(fv.track_id as varchar) as simlar_track_id
            ,cast(fv.track_name as varchar) as similar_track_name
            ,cast(fv.artist_name as varchar) as similar_artist_name
            ,cast((1 - vector_l2_distance( bs.feature_vector, fv.feature_vector)) as number(38,2)) similarity_score
    from base_song bs
    cross join staging.feature_vector fv
    where bs.track_id != fv.track_id
    and vector_l2_distance( bs.feature_vector, fv.feature_vector) > 0
    order by vector_l2_distance( bs.feature_vector, fv.feature_vector) asc  
limit 10
);

return table(results);
end;