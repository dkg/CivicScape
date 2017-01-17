--philadelphia
CREATE TABLE crime_import
(
District varchar(80)
, PSA varchar(15)	
, "Dispatch Date/Time" timestamp
, "Dispatch Date" date
, "Dispatch Time" time
, Hour int
, "DC Number" varchar(150)
, "Location Block" varchar(200)
, "UCR Code" varchar(10)
, "General Crime Category" varchar(150) 
, Shape varchar(150)
, "Police Districts" varchar(100)
, primary key ("DC Number")
 ); 

create table crime_all
(
	DCnumber varchar(150)
	, hr timestamp
	, UCR varchar(200)
	, GenCrimeCategory varchar(200)
	, latitude decimal
	, longitude decimal

	, census_tra varchar(100)	
	, cell_id int
	, geom geometry
	, primary key (DCnumber)
);


CREATE INDEX ix_crime ON crime_all using GIST(geom);
CREATE INDEX ix_crime_hr ON crime_all (hr, census_tra);
CREATE INDEX ix_crime_tract ON crime_all (census_tra, hr);
CREATE INDEX ix_cell_hr2 ON crime_all (hr, cell_id);
CREATE INDEX ix_crime_cell ON crime_all (cell_id, hr);



drop view if exists crime;
create view crime
AS
select 
census_tra, cell_id, hr

, case when UCR in ('300') then 1 else 0 end as robbery_count
, case when UCR in ('100','400') then 1 else 0 end as violent_count
, case when UCR in ('800') then 1 else 0 end as assault_count
, case when UCR in ('500','600','700') then 1 else 0 end as property_count
, UCR
from crime_all c
	;
