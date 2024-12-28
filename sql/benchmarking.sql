
-- repeat below code using a medium warehouse.

declare start_time timestamp_ntz;
        end_time timestamp_ntz;
        elapsed_time_ms float;
        song_name varchar;
        track_id varchar;
        song_cursor cursor for select track_id,song_name  from  spotify.analytics.song_search_times where  warehouse_size='Small';


begin
    -- cursor to fetch song names from the source table
    alter session set use_cached_result=false;
    for record in song_cursor-- adjust 'songs_table' and 'song_column'
        do
            song_name := record.song_name;
            
            -- start timing
            start_time := current_timestamp();
    
            -- perform the search (replace 'songs_table' with the table you're querying)
            call spotify.staging.find_similar_song('%'||:song_name||'%');
    
            -- end timing
            end_time := current_timestamp();
    
            -- calculate elapsed time in milliseconds
            elapsed_time_ms := datediff(millisecond, :start_time, :end_time);

            --set track_id
            track_id := record.track_id;
            
            -- insert the search results into the results table
            update spotify.analytics.song_search_times 
            set song_name = :song_name
                , search_time_ms = :elapsed_time_ms
               
            where track_id = :track_id
            and warehouse_size= 'Small';

    end for;
end;


-- average search time comparison
with small as 
(
    select * 
    from spotify.analytics.song_search_times 
    where warehouse_size = 'Small'
    order by track_id,warehouse_size
)
, medium as 
(
    select * 
    from spotify.analytics.song_search_times 
    where warehouse_size = 'Medium'
    order by track_id,warehouse_size
)
, search_time as
(
    select  s.track_id
            ,s.song_name
            ,m.search_time_ms as medium_search_time
            ,s.search_time_ms as small_search_time
            ,100*(m.search_time_ms - s.search_time_ms)/s.search_time_ms as difference_percentage
    from small s
    inner join medium m
        on s.track_id = m.track_id

)
select avg(difference_percentage)
from search_time;