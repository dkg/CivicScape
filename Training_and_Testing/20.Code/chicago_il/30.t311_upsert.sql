--chicago upsert 311 data

--grafitti insert 
insert into t311_all
select
	"Type of Service Request" as req311_a
	, null as req311_b
	, "Creation Date" as date_created
	, "Completion Date" as date_completed
	, Cast(Latitude as decimal(18,9)) as lat
 	, CAST(Longitude as decimal(18,9)) as long
 	, ST_SetSRID(ST_Point(CAST(Longitude as decimal(18,9))
		, CAST(Latitude as decimal(18,9))		
	), 4326) as geom 

	, null as census_traf
	, null as  crime_count 
	, null as robbery_count 
	, null as violent_count 
	, null as assault_count 
	, null as property_count  
from t311_import_graf
where Status = 'Open' OR Status = 'Completed'
 ;


--vehicles import
insert into t311_all
select
	"Type of Service Request" as req311_a
	, null as req311_b
	, "Creation Date" as date_created
	, "Completion Date" as date_completed
	, Cast(Latitude as decimal(18,9)) as lat
 	, CAST(Longitude as decimal(18,9)) as long
 	, ST_SetSRID(ST_Point(CAST(Longitude as decimal(18,9))
		, CAST(Latitude as decimal(18,9))		
	), 4326) as geom 

	, null as census_tra
	, null as  crime_count 
	, null as robbery_count 
	, null as violent_count 
	, null as assault_count 
	, null as property_count  
from t311_import_vehicles
where Status = 'Open' OR Status = 'Completed'
 ;

--stlights import
insert into t311_all
select
	"Type of Service Request" as req311_a
	, null as req311_b
	, "Creation Date" as date_created
	, "Completion Date" as date_completed
	, Cast(Latitude as decimal(18,9)) as lat
 	, CAST(Longitude as decimal(18,9)) as long
 	, ST_SetSRID(ST_Point(CAST(Longitude as decimal(18,9))
		, CAST(Latitude as decimal(18,9))		
	), 4326) as geom 

	, null as census_tra
	, null as  crime_count 
	, null as robbery_count 
	, null as violent_count 
	, null as assault_count 
	, null as property_count  
from t311_import_stlghts_oneout
where Status = 'Open' OR Status = 'Completed'
 ;

--sanitation import
insert into t311_all
select
	"What is the Nature of this Code Violation?" as req311_a
	, null as req311_b
	, "Creation Date" as date_created
	, "Completion Date" as date_completed
	, Cast(Latitude as decimal(18,9)) as lat
 	, CAST(Longitude as decimal(18,9)) as long
 	, ST_SetSRID(ST_Point(CAST(Longitude as decimal(18,9))
		, CAST(Latitude as decimal(18,9))		
	), 4326) as geom 

	, null as census_tra
	, null as  crime_count 
	, null as robbery_count 
	, null as violent_count 
	, null as assault_count 
	, null as property_count  
from t311_import_sanitation
where Status = 'Open' OR Status = 'Completed'
 ;

--potholes import 
insert into t311_all
select
	"TYPE OF SERVICE REQUEST" as req311_a
	, null as req311_b
	, "CREATION DATE" as date_created
	, "COMPLETION DATE" as date_completed
	, Cast(LATITUDE as decimal(18,9)) as lat
 	, CAST(LONGITUDE as decimal(18,9)) as long
 	, ST_SetSRID(ST_Point(CAST(Longitude as decimal(18,9))
		, CAST(Latitude as decimal(18,9))		
	), 4326) as geom 

	, null as census_tra
	, null as  crime_count 
	, null as robbery_count 
	, null as violent_count 
	, null as assault_count 
	, null as property_count  
from t311_import_potholes
where STATUS = 'Open' OR STATUS = 'Completed'
 ;

--Vacant builings import 
insert into t311_all
select
	"SERVICE REQUEST TYPE" as req311_a
	, null as req311_b
	, "DATE SERVICE REQUEST WAS RECEIVED" as date_created
	, null as date_completed
	, Cast(LATITUDE as decimal(18,9)) as lat
 	, CAST(LONGITUDE as decimal(18,9)) as long
 	, ST_SetSRID(ST_Point(CAST(LONGITUDE as decimal(18,9))
		, CAST(LATITUDE as decimal(18,9))		
	), 4326) as geom 

	, null as census_tra
	, null as  crime_count 
	, null as robbery_count 
	, null as violent_count 
	, null as assault_count 
	, null as property_count  
from t311_import_vacantbldgs
--where Status = 'Open' OR Status = 'Completed'
 ;

--alleylights out 
insert into t311_all
select
	"Type of Service Request" as req311_a
	, null as req311_b
	, "Creation Date" as date_created
	, "Completion Date" as date_completed
	, Cast(Latitude as decimal(18,9)) as lat
 	, CAST(Longitude as decimal(18,9)) as long
 	, ST_SetSRID(ST_Point(CAST(Longitude as decimal(18,9))
		, CAST(Latitude as decimal(18,9))		
	), 4326) as geom 

	, null as census_tra
	, null as  crime_count 
	, null as robbery_count 
	, null as violent_count 
	, null as assault_count 
	, null as property_count  
from t311_import_alleylightsout
where Status = 'Open' OR Status = 'Completed'
 ;

---garbage 
insert into t311_all
select
	"Type of Service Request" as req311_a
	, null as req311_b
	, "Creation Date" as date_created
	, "Completion Date" as date_completed
	, Cast(Latitude as decimal(18,9)) as lat
 	, CAST(Longitude as decimal(18,9)) as long
 	, ST_SetSRID(ST_Point(CAST(Longitude as decimal(18,9))
		, CAST(Latitude as decimal(18,9))		
	), 4326) as geom 

	, null as census_tra
	, null as  crime_count 
	, null as robbery_count 
	, null as violent_count 
	, null as assault_count 
	, null as property_count  
from t311_import_garbage
where Status = 'Open' OR Status = 'Completed'
 ;

---rodent 
insert into t311_all
select
	"Type of Service Request" as req311_a
	, null as req311_b
	, "Creation Date" as date_created
	, "Completion Date" as date_completed
	, Cast(Latitude as decimal(18,9)) as lat
 	, CAST(Longitude as decimal(18,9)) as long
 	, ST_SetSRID(ST_Point(CAST(Longitude as decimal(18,9))
		, CAST(Latitude as decimal(18,9))		
	), 4326) as geom 

	, null as census_tra
	, null as  crime_count 
	, null as robbery_count 
	, null as violent_count 
	, null as assault_count 
	, null as property_count  
from t311_import_rodent
where Status = 'Open' OR Status = 'Completed'
 ;

---tree
insert into t311_all
select
	"Type of Service Request" as req311_a
	, null as req311_b
	, "Creation Date" as date_created
	, "Completion Date" as date_completed
	, Cast(Latitude as decimal(18,9)) as lat
 	, CAST(Longitude as decimal(18,9)) as long
 	, ST_SetSRID(ST_Point(CAST(Longitude as decimal(18,9))
		, CAST(Latitude as decimal(18,9))		
	), 4326) as geom 

	, null as census_tra
	, null as  crime_count 
	, null as robbery_count 
	, null as violent_count 
	, null as assault_count 
	, null as property_count  
from t311_import_tree
where Status = 'Open' OR Status = 'Completed'
 ;

--load agg_crime
insert into agg_crime
select
		census_tra
		, date(hr) as eventdate 
		, Sum(violent_count) as sumviolent_count
		, sum(assault_count) as sumassault_count
		, null as property_count
		from crime
		group by census_tra, hr
;

-- census tract in 311 import
update t311_all ct
	set census_tra = A.census_tra
	FROM census_tracts as A 
	WHERE  ST_WITHIN (ct.geom, A.geom4326)
	and ct.census_tra is null and ct.geom is not null
	;

--join to aggregated table 
--delete non-matched census_tras
--delete from t311_all where census_tra IS NULL; 


update t311_all 
	set violent_count = t.sumviolent_count
	, assault_count = t.sumassault_count
--	, property_count = t.sumproperty_count
--	, robbery_count = t.sumrobbery_count
	from agg_crime as t
	WHERE (t311_all.census_tra = t.census_tra)
	and (t311_all.date_created = t.eventdate)
	and t311_all.violent_count is null and t.sumviolent_count is not null
	--and t.eventdate > '01-01-2011'
;





