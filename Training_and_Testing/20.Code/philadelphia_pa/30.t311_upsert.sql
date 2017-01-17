--phili
insert into t311_all
select
"Service Request ID" 	
, CAST("Requested Date/Time", timestamp)	
, "Service Name" 
, "Service Code" 
, "Agency Responsible" 
, Status 
, "Service Notice" 
, "Updated Date/Time" 
, "Expected Date/Time" 
, Address 
, Zipcode 
, "Media URL" 
, Location 
, Latitude 
, Longitude 
, Zipcodes 
, "Census Tracts 2010 - 2013" 

, null as cell_id 
, ST_SetSRID(ST_Point( Longitude, Latitude), 4326) as geom 
, null as census_tra 

from t311_import




-- census tract in 311 import
update t311_all ct
	set census_tra = A.census_tra
	FROM census_tracts as A 
	WHERE  ST_WITHIN (ct.geom, A.geom4326)
	and ct.census_tra is null and ct.geom is not null
	;

update t311_all c
	set cell_id = A.cell_id
	FROM cells as A 
	WHERE  ST_WITHIN (c.geom, A.geom4326)
	and c.cell_id is null and c.geom is not null
	;




