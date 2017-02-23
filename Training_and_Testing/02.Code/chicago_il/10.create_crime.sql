--chicago


CREATE TABLE crime_import
(ID int, 
"Case Number" varchar(100), 
"Date" timestamp, 
Block varchar(100), 
IUCR varchar(100), 
"Primary Type" varchar(100), 
Description varchar(1000),
"Location Description" varchar(1000),
Arrest varchar(25),
Domestic varchar(25),
Beat varchar(25),
District varchar(25),
Ward varchar(25),
"Community Area" varchar(25),
"FBI Code" varchar(25),
"X Coordinate" double precision,
"Y Coordinate" double precision,
Year int,
"Updated On" varchar(100),
Latitude double precision,
Longitude double precision,
Location varchar(100) 
); 


CREATE TABLE crime_import_log
(ID int, 
CaseNumber varchar(100), 
Dt timestamp, 
Block varchar(100), 
iucr varchar(100), 
PrimaryType varchar(100), 
Description varchar(1000),
LocationDescription varchar(1000),
Arrest varchar(25),
Domestic varchar(25),
Beat varchar(25),
District varchar(25),
Ward varchar(25),
CommunityArea varchar(25),
fbicode varchar(25),
XCoordinate double precision,
YCoordinate double precision,
Year int,
UpdatedOn varchar(100),
Latitude double precision,
Longitude double precision,
Location varchar(100) ); 


CREATE TABLE crime_import_2
(ID int primary key, 
CaseNumber varchar(100), 
Dt timestamp, 
Block varchar(100), 
iucr varchar(100), 
PrimaryType varchar(100), 
Description varchar(1000),
LocationDescription varchar(1000),
Arrest varchar(25),
Domestic varchar(25),
Beat varchar(25),
District varchar(25),
Ward varchar(25),
CommunityArea varchar(25),
fbicode varchar(25),
XCoordinate double precision,
YCoordinate double precision,
Year int,
UpdatedOn varchar(100),
Latitude double precision,
Longitude double precision,
Location varchar(100),
crimehour timestamp,
geom geometry, 
census_tra varchar(6)

); 

CREATE INDEX ix_crime_i ON crime_import_2 using GIST(geom);
CREATE INDEX ix_crime_i2_dt ON crime_import_2 (dt);
CREATE INDEX ix_crime_tra ON crime_import_2 (census_tra, id);
CREATE INDEX ix_crime_tra_hr_type ON crime_import_2 (census_tra,crimehour, iucr, fbicode);
CREATE INDEX ix_crime_id_to_geom ON crime_import_2 (id, geom);
create index ix_crime_crimehour on crime_import_2 (crimehour, primarytype);

--create crime_all
create table crime_all
(
	ID varchar(20) 
	, census_tra varchar(10)
	, hr timestamp
	, iucr varchar(100)
	, primarytype varchar(100)
	, description varchar(1000)
	, fbicode varchar(80)
	, arrest varchar(80)
	, domestic varchar(80)
	, long decimal
	, lat decimal
	
	, geom geometry
	, primary key (ID)
);


CREATE INDEX ix_crime ON crime_all using GIST(geom);
CREATE INDEX ix_crime_hr ON crime_all (hr, census_tra);
CREATE INDEX ix_crime_tract ON crime_all (census_tra, hr);

--aggregated crime by day 




/*
CREATE TABLE crime
(ID int primary key, 
census_tra varchar(6),
hr timestamp,
shooting_count int,
assault_count int,
robbery_count int,
fbicode varchar(25),
iucr varchar(100),
geom geometry

); 
CREATE INDEX ix_crime ON crime using GIST(geom);
CREATE INDEX ix_crime_hr ON crime (hr, census_tra);
CREATE INDEX ix_crime_tract ON crime (census_tra, hr);
*/



drop view if exists crime;

create view crime
AS
select 
cell_id, hr , census_tra 

, case when fbicode = '03' then 1 else 0 end as robbery_count
, case when fbicode in ('01', '01A', '041A', '041B', '0420', '0430', '0479', '0495') then 1 else 0 end as violent_count
, case when fbicode = '04A' then 1 else 0 end as assault_count
, case when fbicode in ('07','05') then 1 else 0 end as property_count
, iucr as UCR 
from crime_all c
	;



