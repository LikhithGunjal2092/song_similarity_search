
-- repeat below code using a medium warehouse.

declare start_time timestamp_ntz;
        end_time timestamp_ntz;
        elapsed_time_ms float;
        song_name varchar;
        track_id varchar;
        song_cursor cursor for select track_id,song_name  from  spotify.analytics.song_search_times where  warehouse_size='small';-- cursor to fetch song names from the source table


begin
    -- switching off query cache to measure real search time
    alter session set use_cached_result=false;

    for record in song_cursor
        do
            song_name := record.song_name;
            
            -- start timing
            start_time := current_timestamp();
    
            -- perform the search
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
            and warehouse_size= 'small';

    end for;
end;


-- average search time and cost comparison
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
select avg(medium_search_time) as average_medium_search_time
      ,avg(small_search_time) as average_small_search_time
      ,avg(round(difference_percentage,2)) as percent_diff_bw_medium_and_small
      ,4*sum(medium_search_time)/3600000 as cost_per1000_medium_search -- query cost  in credits for medium warehouse search on sample dataset (4 credits/hour)
      ,2*sum(small_search_time)/3600000  as cost_per1000_small_search -- query cost in credits for small warehouse search on sample dataset (2 credits/hour)
      ,(2*sum(medium_search_time) - sum(small_search_time))/(sum(small_search_time)) as percent_cost_difference
from search_time;
