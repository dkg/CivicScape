




	insert into weather
	
		
		
		SELECT hourstart
, cast(avg(case when w.wind_speed = '' then null else cast(w.wind_speed AS decimal(18,4)) end) as decimal(18,4)) as wind_speed
, cast(avg(case when w.drybulb_fahrenheit = '' then null else cast(w.drybulb_fahrenheit AS decimal(18,4)) end) as decimal(18,4)) as drybulb_fahrenheit
, cast(avg(case when w.hourly_precip = '' then null else cast(w.hourly_precip AS decimal(18,4)) end) as decimal(18,4)) as hourly_precip
, cast(avg(case when w.relative_humidity = '' then null else cast(w.relative_humidity AS decimal(18,4)) end) as decimal(18,4)) as relative_humidity

, max(case when w.weather_types is null then 0 when position('FZ' in w.weather_types) = 0 then 0 else 1 end) as FZ
, max(case when w.weather_types is null then 0 when position('RA' in w.weather_types) = 0 then 0 else 1 end) as RA
, max(case when w.weather_types is null then 0 when position('TS' in w.weather_types) = 0 then 0 else 1 end) as TS
, max(case when w.weather_types is null then 0 when position('BR' in w.weather_types) = 0 then 0 else 1 end) as BR
, max(case when w.weather_types is null then 0 when position('SN' in w.weather_types) = 0 then 0 else 1 end) as SN
, max(case when w.weather_types is null then 0 when position('HZ' in w.weather_types) = 0 then 0 else 1 end) as HZ
, max(case when w.weather_types is null then 0 when position('DZ' in w.weather_types) = 0 then 0 else 1 end) as DZ
, max(case when w.weather_types is null then 0 when position('PL' in w.weather_types) = 0 then 0 else 1 end) as PL
, max(case when w.weather_types is null then 0 when position('FG' in w.weather_types) = 0 then 0 else 1 end) as FG
, max(case when w.weather_types is null then 0 when position('SA' in w.weather_types) = 0 then 0 else 1 end) as SA
, max(case when w.weather_types is null then 0 when position('UP' in w.weather_types) = 0 then 0 else 1 end) as UP
, max(case when w.weather_types is null then 0 when position('FU' in w.weather_types) = 0 then 0 else 1 end) as FU
, max(case when w.weather_types is null then 0 when position('SQ' in w.weather_types) = 0 then 0 else 1 end) as SQ
, max(case when w.weather_types is null then 0 when position('GS' in w.weather_types) = 0 then 0 else 1 end) as GS

--, w.*
	FROM  generate_series 
		( '2001-10-01' ::timestamp
		, '2020-01-01' ::timestamp
		, '1 hour' ::interval) as hourstart
	inner join weather_import w on w.dttime between hourstart -interval '30 minute' and hourstart + interval '29 minute'
	group by hourstart
	
	ON CONFLICT (hr) 
	DO UPDATE SET
	wind_speed = EXCLUDED.wind_speed
	,drybulb_fahrenheit = EXCLUDED.drybulb_fahrenheit
	,hourly_precip = EXCLUDED.hourly_precip
	,relative_humidity = EXCLUDED.relative_humidity
	,fz = EXCLUDED.fz
	,ra = EXCLUDED.ra
	,ts = EXCLUDED.ts
	,br = EXCLUDED.br
	, sn = EXCLUDED.sn
	, hz = EXCLUDED.hz
	, dz = EXCLUDED.dz
	, pl = EXCLUDED.pl
	, fg = EXCLUDED.fg
	, sa = EXCLUDED.sa
	, up = EXCLUDED.up
	, fu = EXCLUDED.fu
	, sq = EXCLUDED.sq
	, gs = EXCLUDED.gs
	;




	
	
	-- delete from weather_import;