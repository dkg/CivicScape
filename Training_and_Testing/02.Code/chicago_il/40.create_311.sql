--TODO: chicago 311 -- different because inserting multiple tables into t311_all 


CREATE TABLE t311_import_graf
(
	"Creation Date" Date
	, Status varchar(200)
	, "Completion Date" Date
	, "Service Request Number" varchar(200)
	, "Type of Service Request" varchar(300)
	, "What Type of Surface is the Grafitti on?" varchar(300)
	, "Where is the Graffiti located" varchar(300)
	, "Street Address" varchar(200)
	, "Zip Code" varchar(100)
	, "X Coordinate" decimal
	, "Y Coordinate" decimal	
	, Ward varchar(20)
	, "Police District" varchar(200)
	, "Community Area" varchar(100)
	, SSA varchar(20)
	, Latitude decimal 
	, Longitude decimal 
	, Location varchar(200)
);

CREATE TABLE t311_import_vehicles
(
	"Creation Date" Date
	, Status varchar(200)
	, "Completion Date" Date 
	, "Service Request Number" varchar(100)
	, "Type of Service Request" varchar(300)
	, "License Plate" varchar(200) 
	, "Vehicle Make/Model" varchar(200)
	, "Vehicle Color" varchar(200)
	, "Current Activity" varchar(200)
	, "Most Recent Action" varchar(200)
	, "How Many Days Has the Vehicle Been Reported as Parked?" varchar(100)
	, "Street Address" varchar(200)
	, "Zip Code" varchar(100)
	, "X Coordinate" decimal
	, "Y Coordinate" decimal	
	, Ward varchar(20)
	, "Police District" varchar(200)
	, "Community Area" varchar(100)
	, SSA varchar(20)
	, Latitude decimal 
	, Longitude decimal 
	, Location varchar(200)
);


CREATE TABLE t311_import_stlghts_oneout
(
	"Creation Date" Date
	, Status varchar(200)
	, "Completion Date" Date
	, "Service Request Number" varchar(100)
	, "Type of Service Request" varchar(300)
	, "Street Address" varchar(200)
	, "Zip Code" varchar(100)
	, "X Coordinate" decimal
	, "Y Coordinate" decimal	
	, Ward varchar(20)
	, "Police District" varchar(200)
	, "Community Area" varchar(100)
	, Latitude decimal 
	, Longitude decimal 
	, Location varchar(200)
);


CREATE TABLE t311_import_sanitation 
(
	"Creation Date" Date
	, Status varchar(200)
	, "Completion Date" Date
	, "Type of Service Request" varchar(300)
	, "What is the Nature of this Code Violation?" varchar(300)
	, "Street Address" varchar(200)
	, "Zip Code" varchar(100)
	, "X Coordinate" decimal
	, "Y Coordinate" decimal	
	, Ward varchar(20)
	, "Police District" varchar(200)
	, "Community Area" varchar(100)
	, SSA varchar(20)
	, Latitude decimal 
	, Longitude decimal 
	, Location varchar(200)
);


CREATE TABLE t311_import_potholes 
(
	"CREATION DATE" Date
	, STATUS varchar(200)
	, "COMPLETION DATE" Date 
	, "SERVICE REQUEST NUMBER" varchar(200)
	, "TYPE OF SERVICE REQUEST" varchar(300)
	, "CURRENT ACTIVITY" varchar(300)
	, "MOST RECENT ACTION" varchar(100)
	, "NUMBER OF POTHOLES FILLED ON BLOCK" varchar(10)
	, "STREET ADDRESS" varchar(200)
	, ZIP varchar(100)
	, "X COORDINATE" decimal
	, "Y COORDINATE" decimal	
	, Ward varchar(20)
	, "Police District" varchar(200)
	, "Community Area" varchar(100)
	, SSA varchar(20)
	, LATITUDE decimal 
	, LONGITUDE decimal 
	, LOCATION varchar(200)
);

CREATE TABLE t311_import_VacantBldgs
(
	"SERVICE REQUEST TYPE" varchar(200)
	, "SERVICE REQUEST NUMBER" varchar(100)
	, "DATE SERVICE REQUEST WAS RECEIVED" date
--	, "LOCATION OF BUILDING ON THE LOT" varchar(300)
--	, "IS THE BUILDING DANGERIOUS OR HAZARDOUS?" varchar(300)
--	, "IS BUILDING OPEN OR BOARDED?" varchar(300)
--	, "IF THE BUILDING IS OPEN, WHERE IS THE ENTRY POINT?" varchar(200)
--	, "IS THE BUILDING CURRENTLY VACANT OR OCCUPIED?" varchar(200)
--	, "IS THE BUILDING VACANT DUE TO FIRE?" varchar(200)
--	, "ANY PEOPLE USING PROPERTY? (HOMELESS, CHILDEN, GANGS)" varchar(200)
--	, "ADDRESS STREET NUMBER" varchar(20)
--	, "ADDRESS STREET NAME" varchar(200)
--	, "ADDRESS STREET SUFFIX" varchar(20) 
--	, "ZIP CODE" varchar(100)
	, "X COORDINATE" decimal
	, "Y COORDINATE" decimal	
--	, Ward varchar(20)
	, "Police District" varchar(200)
	, "Community Area" varchar(100)
	, LATITUDE decimal 
	, LONGITUDE decimal 
	, Location varchar(200)
);


CREATE TABLE t311_import_alleylightsout
(
	"Creation Date" Date
	, Status varchar(200)
	, "Completion Date" Date
	, "Service Request Number" varchar(200)
	, "Type of Service Request" varchar(300)
	, "Street Address" varchar(200)
	, "Zip Code" varchar(100)
	, "X Coordinate" varchar(200)
	, "Y Coordinate" varchar(200)	
	, Ward varchar(20)
	, "Police District" varchar(200)
	, "Community Area" varchar(100)
	, Latitude varchar(200) 
	, Longitude varchar(200) 
	, Location varchar(200)
);

CREATE TABLE t311_import_garbage
(
	"Creation Date" Date
	, Status varchar(200)
	, "Completion Date" Date
	, "Service Request Number" varchar(200)
	, "Type of Service Request" varchar(300)
	, "Number of Black Carts Delivered" varchar(300)
	, "Current Activity" varchar(300)
	, "Most Recent Action" varchar(200)
	, "Street Address" varchar(200)
	, "Zip Code" varchar(100)
	, "X Coordinate" decimal
	, "Y Coordinate" decimal	
	, Ward varchar(20)
	, "Police District" varchar(200)
	, "Community Area" varchar(100)
	, SSA varchar(20)
	, Latitude decimal 
	, Longitude decimal 
	, Location varchar(200)
);

CREATE TABLE t311_import_rodent
(
	"Creation Date" Date
	, Status varchar(200)
	, "Completion Date" Date
	, "Service Request Number" varchar(200)
	, "Type of Service Request" varchar(300)
	, "Number of Premises Baited" varchar(300)
	, "Number of Premises with Garbage" varchar(300)
	, "Number of Premises with Rats" varchar(300)
	, "Current Activity" varchar(300)
	, "Most Recent Action" varchar(200)
	, "Street Address" varchar(200)
	, "Zip Code" varchar(100)
	, "X Coordinate" decimal
	, "Y Coordinate" decimal	
	, Ward varchar(20)
	, "Police District" varchar(200)
	, "Community Area" varchar(100)
	, Latitude decimal 
	, Longitude decimal 
	, Location varchar(200)
);


CREATE TABLE t311_import_tree
(
	"Creation Date" Date
	, Status varchar(200)
	, "Completion Date" Date
	, "Service Request Number" varchar(200)
	, "Type of Service Request" varchar(300)
	, "Location of Trees" varchar(300)
	, "Street Address" varchar(200)
	, "Zip Code" varchar(100)
	, "X Coordinate" decimal
	, "Y Coordinate" decimal	
	, Ward varchar(20)
	, "Police District" varchar(200)
	, "Community Area" varchar(100)
	, Latitude decimal 
	, Longitude decimal 
	, Location varchar(200)
);


CREATE table t311_all
(
req311_a varchar(200)
, req311_b varchar(150)
, date_created date
, date_completed date
, lat decimal 
, long decimal 

, geom geometry
, census_tra varchar(30)
, crime_count numeric
, robbery_count integer
, violent_count integer
, assault_count integer
, property_count integer 
 ); 

CREATE INDEX ix_t311 ON t311_all using GIST(geom);
CREATE INDEX ix_t311_hr ON t311_all (date_created, census_tra);
CREATE INDEX ix_t311_tract ON t311_all (census_tra, date_created);

--create aggregated crime by day table
create table agg_crime
( 
	census_tra varchar(20)
	, eventdate date
	, sumviolent_count numeric
	, sumassault_count numeric
	, sumproperty_count varchar
	, sumrobbery_count numeric
);

CREATE INDEX ix_crime_date ON agg_crime (eventdate);
CREATE INDEX ix_311_tra ON agg_crime (census_tra);
CREATE INDEX ix_311_tra_date ON agg_crime (census_tra,eventdate);


--draft unified 311 table

CREATE view t311_all
(
req311_a varchar(200)
, req311_b varchar(150)
, date_created date ONLY
, date_completed date ONLY
, lat decimal 
, long decimal 

, geom geometry
, census_tra varchar(30)
, crime_count numeric
, robbery_count integer
, violent_count integer
, assault_count integer
, property_count integer 
 ); 



