--chicago
-- to do: consider relocating crime view creation to here

insert into crime_all
select 
	ID
	, null as census_tra
	, date_trunc('hour', "Date") as hr
	, iucr
	, "Primary Type" as primarytype
	, description description
	, "FBI Code" as fbicode
	, arrest
	, domestic
	, latitude as lat
	, longitude as long
	, ST_SetSRID(ST_POINT( longitude, latitude), 4326) as geom 
from public.crime_import
;

--update with census tracts 
update crime_all
	set census_tra = A.census_tra

FROM census_tracts as A 

WHERE  ST_WITHIN (crime_all.geom, A.geom4326)
and crime_all.census_tra is null and crime_all.geom is not null
;


delete from crime_import;

/*
	delete from crime_import_2;

	INSERT INTO crime_import_2(
				id, casenumber, dt, block, iucr, primarytype, description, locationdescription, 
				arrest, domestic, beat, district, ward, communityarea, fbicode, 
				xcoordinate, ycoordinate, year, updatedon, latitude, longitude, location, 
				crimehour,
				geom

				)

	select 
	id, casenumber, dt, block, iucr, primarytype, description, locationdescription, 
				arrest, domestic, beat, district, ward, communityarea, fbicode, 
				xcoordinate, ycoordinate, year, updatedon, latitude, longitude, location, 
			date_trunc('hour', dt) as crimehour,
				ST_SetSRID(ST_POINT(longitude, latitude), 4326) as geom
	from crime_import
	;




	-- Log the rows we're processing
	insert into crime_import_log
	select ci.* 
	from crime_import ci
	inner join crime_import_2 ci2 on ci.id = ci2.id
	-- ON CONFLICT(id) DO NOTHING
	;










	insert into crime 
	select *
	from 
	(
		select id,
		census_tra, 
		crimehour, 
		sum(case when fbicode = '01A' or iucr in ('041A', '041B', '0420', '0430', '0479', '0495') then 1 else 0 end) as shooting_count,
		sum(case when fbicode = '04A' then 1 else 0 end) as assault_count,
		sum(case when fbicode = '03' then 1 else 0 end) as robbery_count,
		fbicode,
		iucr
		from crime_import_2

		where crimehour is not null
		group by id
	) A
	ON CONFLICT (id) 
	DO UPDATE SET
	shooting_count = EXCLUDED.shooting_count
	,robbery_count = EXCLUDED.robbery_count
	,assault_count = EXCLUDED.assault_count
	,fbicode = EXCLUDED.fbicode
	,iucr = EXCLUDED.iucr
	;



	insert into censustracts (census_tra)
	select distinct c.census_tra
	from crime_import_2 c
	left join censustracts ct 
		on c.census_tra = ct.census_tra
	where ct.census_tra is null
	;



	
	
	delete from crime_import ci
	using  crime_import_2 ci2 
	where ci.id = ci2.id
	;
	

	delete from crime_import_2;
