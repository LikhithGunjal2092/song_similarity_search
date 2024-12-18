
use role accountadmin;
use database spotify;
create role searchapp;
grant usage on database spotify to role  searchapp;
grant usage on schema staging to role  searchapp;
grant select on all tables in database spotify to role searchapp;
grant usage on all procedures in database spotify to searchapp;
grant usage on warehouse compute_wh to role searchapp;



create user searchappuser
password = ''  
default_role = searchapp            
default_warehouse = compute_wh 
default_namespace = spotify.staging  
must_change_password = false;      


grant role searchapp to user searchappuser;









