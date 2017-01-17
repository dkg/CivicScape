--philadelphia
CREATE TABLE t311_import
(
"Service Request ID" varchar(50)	
, "Requested Date/Time" timestamp
, "Service Name" varchar(200)
, "Service Code" varchar(150)
, "Agency Responsible" varchar(150)
, Status varchar(150)
, "Service Notice" varchar(150)
, "Updated Date/Time" timestamp
, "Expected Date/Time" timestamp
, Address varchar(300)
, Zipcode varchar(50)
, "Media URL" varchar(500)
, Location varchar(200)
, Latitude decimal(18,9)
, Longitude decimal(18,9)
, Zipcodes varchar(80)
, "Census Tracts 2010 - 2013" varchar(30)
, primary key ("Service Request ID")
 ); 


CREATE TABLE t311_all
(
"Service Request ID" varchar(50)	
, "Requested Date/Time" timestamp
, "Service Name" varchar(200)
, "Service Code" varchar(150)
, "Agency Responsible" varchar(150)
, Status varchar(150)
, "Service Notice" varchar(150)
, "Updated Date/Time" timestamp
, "Expected Date/Time" timestamp
, Address varchar(300)
, Zipcode varchar(50)
, "Media URL" varchar(500)
, Location varchar(200)
, Latitude decimal(18,9)
, Longitude decimal(18,9)
, Zipcodes varchar(80)
, "Census Tracts 2010 - 2013" varchar(30)
, primary key ("Service Request ID")

, cell_id int
, geom geometry
, census_tra varchar(30)
 ); 

CREATE INDEX ix_t311 ON t311_all using GIST(geom);
CREATE INDEX ix_t311_hr ON t311_all (date_created, cell_id);
CREATE INDEX ix_t311_tract ON t311_all (cell_id, date_created);
CREATE INDEX ix_311_type on t311_all (cell_id, date_created, violent_count);



drop view if exists t311;
create view t311
AS
select city, cell_id, hr, sum(graf) as graf, sum(illdumping) as illdumping, sum(bldgmaint) as bldgmaint
, sum(sanitation) as sanitation, sum(traffic) as traffic, sum(vac_bldg) as vac_bldg
, sum(vac_vehicle) as vac_vehicle, sum(stlghts) as stlghts, sum(alleylghts) as alleylghts
, sum(garbage_pickup) as garbage_pickup
, sum(graf) + sum(illdumping) + sum(bldgmaint) + sum(sanitation) + sum(traffic) + sum(vac_bldg) + sum(vac_vehicle) + sum(stlghts) + sum(alleylghts) + sum(garbage_pickup) 
as t311Events
FROM 
(
select
case when cell_id is not null then '4' else '4' end as city
, cell_id
, date_trunc('hour', "Requested Date/Time") as hr
, case when t311_all."Service Name" = 'Graffiti Removal' then 1 else 0 end as graf
, case when t311_all."Service Name" = 'Illegal Dumping' then 1 else 0 end as illdumping
, case when t311_all."Service Name" = 'Maintenance Residential or Commercial' then 1 else 0 end as bldgmaint
--, null as streetsw
--, null as electrical
, case when t311_all."Service Name" = 'Sanitation / Dumpster Violation' then 1 else 0 end as sanitation
--, null as recycling
, case when t311_all."Service Name" = 'Street Trees' then 1 else 0 end as tree
, case when t311_all."Service Name" = 'Traffic (Other)' then 1 else 0 end as traffic
, case when t311_all."Service Name" = ' Vacant House or Commercial' then 1 else 0 end as vac_bldg
, case when t311_all."Service Name" = 'Abandoned Vehicle' then 1 else 0 end as vac_vehicle
, case when t311_all."Service Name" = 'Street Light Outage' then 1 else 0 end as stlghts
, case when t311_all."Service Name" = 'Alley Light Outage ' then 1 else 0 end as alleylghts
--, null as potholes
, case when t311_all."Service Name" = 'Rubbish/Recyclable Material Collection' then 1 else 0 end as garbage_pickup
--, null as rodent
--, null as sidewalk
from t311_all 
where cell_id is not null
group by cell_id, date_trunc('hour', "Requested Date/Time")
, case when t311_all."Service Name" = 'Graffiti Removal' then 1 else 0 end
, case when t311_all."Service Name" = 'Illegal Dumping' then 1 else 0 end
, case when t311_all."Service Name" = 'Maintenance Residential or Commercial' then 1 else 0 end
, case when t311_all."Service Name" = 'Sanitation / Dumpster Violation' then 1 else 0 end
, case when t311_all."Service Name" = 'Street Trees' then 1 else 0 end 
, case when t311_all."Service Name" = 'Traffic (Other)' then 1 else 0 end 
, case when t311_all."Service Name" = ' Vacant House or Commercial' then 1 else 0 end 
, case when t311_all."Service Name" = 'Abandoned Vehicle' then 1 else 0 end 
, case when t311_all."Service Name" = 'Street Light Outage' then 1 else 0 end 
, case when t311_all."Service Name" = 'Alley Light Outage ' then 1 else 0 end 
, case when t311_all."Service Name" = 'Rubbish/Recyclable Material Collection' then 1 else 0 end
 ) a 
GROUP BY city, cell_id, hr






