--phili

insert into crime_all
	select 
	"DC Number" as DCnumber
	, date_trunc('hour',"Dispatch Date/Time") as hr
	, "UCR Code" as UCR
	, "General Crime Category" as GenCrimeCategory
	, latitude
	, longitude
	, null as census_tra
	, null as cell_id
	, ST_SetSRID(ST_POINT( longitude, latitude), 4326) as geom 
from(
	select 
	cast(trim(trailing from trim(leading from substring(substring("Shape",15,30) from '\s.*\)'),','), ')')  as decimal) as latitude
	, cast(trim(leading from trim(leading from substring("Shape" from '\(.*\s'),'('), ',') as decimal) as longitude
	--, ST_SetSRID(ST_POINT( cast(trim(leading from trim(leading from substring("Shape" from '\(.*\s'),'('), ',') as decimal(18,9))
	--	, cast(trim(leading from trim(leading from substring("Shape" from '\(.*\s'),'('), ',') as decimal(18,9))), 4269) as geom 
	, i.*
	from public.crime_import as i 
	) A
;


/* Put crimes in census tracts */
update crime_all ct
	set census_tra = A.census_tra
	FROM census_tracts as A 
	WHERE  ST_WITHIN (ct.geom, A.geom4326)
	and ct.census_tra is null and ct.geom is not null
	;


/*put crimes in cells */
update crime_all c
	set cell_id = A.cell_id
	FROM cells as A 
	WHERE  ST_WITHIN (c.geom, A.geom4326)
	and c.cell_id is null and c.geom is not null
	;


	
