
drop table if exists cells;

create table cells
(
cell_id int not null
, min_lng numeric
, min_lat numeric
, max_lng numeric
, max_lat numeric
, cell_width numeric
, cell_height numeric
, sw text, se text, ne text, nw text
, geom4326 geometry

, primary key (cell_id)
);


insert into cells

select row_number() over ()
, min_lng, min_lat, max_lng, max_lat
, cell_width, cell_height
, sw, se, ne, nw
, ST_SetSRID(ST_GeomFromText(concat('POLYGON((',sw,',',se,',',ne,',',nw,',',sw,'))')), 4326)
from
(
	select 
		lng as min_lng, lat as min_lat, lng + const.cell_width as max_lng, lat + const.cell_height as max_lat, const.cell_width, const.cell_height
		, concat(lng, ' ', lat) as sw
		, concat(lng + const.cell_width, ' ', lat) as se
		, concat(lng + const.cell_width, ' ', lat + const.cell_height) as ne
		, concat(lng, ' ', lat + const.cell_height) as nw
	from
	(select .01 as cell_width, .008 as cell_height
	) as const,
	(

		select
		cast(min(st_ymin(geom4326)) as numeric) as min_lat
		, cast(max(st_ymax(geom4326)) as numeric) as max_lat
		, cast(min(st_xmin(geom4326)) as numeric) as min_lng
		, cast(max(st_xmax(geom4326)) as numeric) as max_lng
		from census_tracts

	) extent
	, generate_series(extent.min_lat, extent.max_lat, const.cell_height) lat
	, generate_series(extent.min_lng, extent.max_lng, const.cell_width) lng
	order by lat asc, lng asc
) as corners
;


CREATE INDEX ix_cells_geom ON cells using GIST(geom4326);



update crime_all c
	set cell_id = A.cell_id
	FROM cells as A 
	WHERE  ST_WITHIN (c.geom, A.geom4326)
	and c.cell_id is null and c.geom is not null
	;


/* 
# Use these queries to generate and populate the binning table.  The sql should recreated for each city (bc they have different tracts)
# and it'll rerun automatically each time the training pipeline is run bc the cell sizes can change each time


select replace(replace(replace(cast(array_agg(A.sql) as text), '{',''), '}',''), '"','')
from 
(
	select 'create table cell_census_tract_bins ( cell_id int' as sql
	union all
	(
	select concat('census_tra_' ,tractce10, ' int')
	from census_tracts 
	order by tractce10
	)
	union all 
	select 'primary key ( cell_id );'
) A 
;


select 'insert into cell_census_tract_bins' as sql
union all select 'select c.cell_id'
union all
(
select concat(', max(case when ct.census_tra = ''', census_tra , ''' then 1 else 0 end) as census_tra_', tractce10)
from census_tracts
order by tractce10
)
union all
select 'from cells c
inner join census_tracts ct 
	on ST_INTERSECTS(c.geom4326, ct.geom4326)
group by c.cell_id
;'


-- And use this query to generate the sql for the export step  30.Code/${city}_crimes.sql.yaml

select concat(', census_tra_', tractce10)
from census_tracts
order by tractce10
;

*/

drop table if exists cell_census_tract_bins;

create table cell_census_tract_bins ( cell_id int
  , census_tra_000100 int  
  , census_tra_000200 int  
  , census_tra_000300 int  
  , census_tra_000401 int  
  , census_tra_000402 int  
  , census_tra_000500 int  
  , census_tra_000600 int  
  , census_tra_000700 int  
  , census_tra_000801 int  
  , census_tra_000803 int  
  , census_tra_000804 int  
  , census_tra_000901 int  
  , census_tra_000902 int  
  , census_tra_001001 int  
  , census_tra_001002 int  
  , census_tra_001101 int  
  , census_tra_001102 int  
  , census_tra_001201 int  
  , census_tra_001202 int  
  , census_tra_001300 int  
  , census_tra_001400 int  
  , census_tra_001500 int  
  , census_tra_001600 int  
  , census_tra_001700 int  
  , census_tra_001800 int  
  , census_tra_001900 int  
  , census_tra_002000 int  
  , census_tra_002100 int  
  , census_tra_002200 int  
  , census_tra_002300 int  
  , census_tra_002400 int  
  , census_tra_002500 int  
  , census_tra_002701 int  
  , census_tra_002702 int  
  , census_tra_002801 int  
  , census_tra_002802 int  
  , census_tra_002900 int  
  , census_tra_003001 int  
  , census_tra_003002 int  
  , census_tra_003100 int  
  , census_tra_003200 int  
  , census_tra_003300 int  
  , census_tra_003600 int  
  , census_tra_003701 int  
  , census_tra_003702 int  
  , census_tra_003800 int  
  , census_tra_003901 int  
  , census_tra_003902 int  
  , census_tra_004001 int  
  , census_tra_004002 int  
  , census_tra_004101 int  
  , census_tra_004102 int  
  , census_tra_004201 int  
  , census_tra_004202 int  
  , census_tra_005000 int  
  , census_tra_005400 int  
  , census_tra_005500 int  
  , census_tra_005600 int  
  , census_tra_006000 int  
  , census_tra_006100 int  
  , census_tra_006200 int  
  , census_tra_006300 int  
  , census_tra_006400 int  
  , census_tra_006500 int  
  , census_tra_006600 int  
  , census_tra_006700 int  
  , census_tra_006900 int  
  , census_tra_007000 int  
  , census_tra_007101 int  
  , census_tra_007102 int  
  , census_tra_007200 int  
  , census_tra_007300 int  
  , census_tra_007400 int  
  , census_tra_007700 int  
  , census_tra_007800 int  
  , census_tra_007900 int  
  , census_tra_008000 int  
  , census_tra_008101 int  
  , census_tra_008102 int  
  , census_tra_008200 int  
  , census_tra_008301 int  
  , census_tra_008302 int  
  , census_tra_008400 int  
  , census_tra_008500 int  
  , census_tra_008601 int  
  , census_tra_008602 int  
  , census_tra_008701 int  
  , census_tra_008702 int  
  , census_tra_008801 int  
  , census_tra_008802 int  
  , census_tra_009000 int  
  , census_tra_009100 int  
  , census_tra_009200 int  
  , census_tra_009300 int  
  , census_tra_009400 int  
  , census_tra_009500 int  
  , census_tra_009600 int  
  , census_tra_009801 int  
  , census_tra_009802 int  
  , census_tra_010000 int  
  , census_tra_010100 int  
  , census_tra_010200 int  
  , census_tra_010300 int  
  , census_tra_010400 int  
  , census_tra_010500 int  
  , census_tra_010600 int  
  , census_tra_010700 int  
  , census_tra_010800 int  
  , census_tra_010900 int  
  , census_tra_011000 int  
  , census_tra_011100 int  
  , census_tra_011200 int  
  , census_tra_011300 int  
  , census_tra_011400 int  
  , census_tra_011500 int  
  , census_tra_011700 int  
  , census_tra_011800 int  
  , census_tra_011900 int  
  , census_tra_012000 int  
  , census_tra_012100 int  
  , census_tra_012201 int  
  , census_tra_012203 int  
  , census_tra_012204 int  
  , census_tra_012500 int  
  , census_tra_013100 int  
  , census_tra_013200 int  
  , census_tra_013300 int  
  , census_tra_013401 int  
  , census_tra_013402 int  
  , census_tra_013500 int  
  , census_tra_013601 int  
  , census_tra_013602 int  
  , census_tra_013700 int  
  , census_tra_013800 int  
  , census_tra_013900 int  
  , census_tra_014000 int  
  , census_tra_014100 int  
  , census_tra_014200 int  
  , census_tra_014300 int  
  , census_tra_014400 int  
  , census_tra_014500 int  
  , census_tra_014600 int  
  , census_tra_014700 int  
  , census_tra_014800 int  
  , census_tra_014900 int  
  , census_tra_015101 int  
  , census_tra_015102 int  
  , census_tra_015200 int  
  , census_tra_015300 int  
  , census_tra_015600 int  
  , census_tra_015700 int  
  , census_tra_015800 int  
  , census_tra_016000 int  
  , census_tra_016100 int  
  , census_tra_016200 int  
  , census_tra_016300 int  
  , census_tra_016400 int  
  , census_tra_016500 int  
  , census_tra_016600 int  
  , census_tra_016701 int  
  , census_tra_016702 int  
  , census_tra_016800 int  
  , census_tra_016901 int  
  , census_tra_016902 int  
  , census_tra_017000 int  
  , census_tra_017100 int  
  , census_tra_017201 int  
  , census_tra_017202 int  
  , census_tra_017300 int  
  , census_tra_017400 int  
  , census_tra_017500 int  
  , census_tra_017601 int  
  , census_tra_017602 int  
  , census_tra_017701 int  
  , census_tra_017702 int  
  , census_tra_017800 int  
  , census_tra_017900 int  
  , census_tra_018001 int  
  , census_tra_018002 int  
  , census_tra_018300 int  
  , census_tra_018400 int  
  , census_tra_018800 int  
  , census_tra_019000 int  
  , census_tra_019100 int  
  , census_tra_019200 int  
  , census_tra_019501 int  
  , census_tra_019502 int  
  , census_tra_019700 int  
  , census_tra_019800 int  
  , census_tra_019900 int  
  , census_tra_020000 int  
  , census_tra_020101 int  
  , census_tra_020102 int  
  , census_tra_020200 int  
  , census_tra_020300 int  
  , census_tra_020400 int  
  , census_tra_020500 int  
  , census_tra_020600 int  
  , census_tra_020700 int  
  , census_tra_020800 int  
  , census_tra_020900 int  
  , census_tra_021000 int  
  , census_tra_021100 int  
  , census_tra_021200 int  
  , census_tra_021300 int  
  , census_tra_021400 int  
  , census_tra_021500 int  
  , census_tra_021600 int  
  , census_tra_021700 int  
  , census_tra_021800 int  
  , census_tra_021900 int  
  , census_tra_022000 int  
  , census_tra_023100 int  
  , census_tra_023500 int  
  , census_tra_023600 int  
  , census_tra_023700 int  
  , census_tra_023800 int  
  , census_tra_023900 int  
  , census_tra_024000 int  
  , census_tra_024100 int  
  , census_tra_024200 int  
  , census_tra_024300 int  
  , census_tra_024400 int  
  , census_tra_024500 int  
  , census_tra_024600 int  
  , census_tra_024700 int  
  , census_tra_024800 int  
  , census_tra_024900 int  
  , census_tra_025200 int  
  , census_tra_025300 int  
  , census_tra_025400 int  
  , census_tra_025500 int  
  , census_tra_025600 int  
  , census_tra_025700 int  
  , census_tra_025800 int  
  , census_tra_025900 int  
  , census_tra_026000 int  
  , census_tra_026100 int  
  , census_tra_026200 int  
  , census_tra_026301 int  
  , census_tra_026302 int  
  , census_tra_026400 int  
  , census_tra_026500 int  
  , census_tra_026600 int  
  , census_tra_026700 int  
  , census_tra_026800 int  
  , census_tra_026900 int  
  , census_tra_027000 int  
  , census_tra_027100 int  
  , census_tra_027200 int  
  , census_tra_027300 int  
  , census_tra_027401 int  
  , census_tra_027402 int  
  , census_tra_027500 int  
  , census_tra_027600 int  
  , census_tra_027700 int  
  , census_tra_027800 int  
  , census_tra_027901 int  
  , census_tra_027902 int  
  , census_tra_028000 int  
  , census_tra_028100 int  
  , census_tra_028200 int  
  , census_tra_028300 int  
  , census_tra_028400 int  
  , census_tra_028500 int  
  , census_tra_028600 int  
  , census_tra_028700 int  
  , census_tra_028800 int  
  , census_tra_028901 int  
  , census_tra_028902 int  
  , census_tra_029000 int  
  , census_tra_029100 int  
  , census_tra_029200 int  
  , census_tra_029300 int  
  , census_tra_029400 int  
  , census_tra_029800 int  
  , census_tra_029900 int  
  , census_tra_030000 int  
  , census_tra_030100 int  
  , census_tra_030200 int  
  , census_tra_030501 int  
  , census_tra_030502 int  
  , census_tra_030600 int  
  , census_tra_030700 int  
  , census_tra_030800 int  
  , census_tra_030900 int  
  , census_tra_031000 int  
  , census_tra_031101 int  
  , census_tra_031102 int  
  , census_tra_031200 int  
  , census_tra_031300 int  
  , census_tra_031401 int  
  , census_tra_031402 int  
  , census_tra_031501 int  
  , census_tra_031502 int  
  , census_tra_031600 int  
  , census_tra_031700 int  
  , census_tra_031800 int  
  , census_tra_031900 int  
  , census_tra_032000 int  
  , census_tra_032100 int  
  , census_tra_032300 int  
  , census_tra_032500 int  
  , census_tra_032600 int  
  , census_tra_032900 int  
  , census_tra_033000 int  
  , census_tra_033101 int  
  , census_tra_033102 int  
  , census_tra_033200 int  
  , census_tra_033300 int  
  , census_tra_033400 int  
  , census_tra_033500 int  
  , census_tra_033600 int  
  , census_tra_033701 int  
  , census_tra_033702 int  
  , census_tra_033800 int  
  , census_tra_033900 int  
  , census_tra_034000 int  
  , census_tra_034100 int  
  , census_tra_034200 int  
  , census_tra_034400 int  
  , census_tra_034501 int  
  , census_tra_034502 int  
  , census_tra_034600 int  
  , census_tra_034701 int  
  , census_tra_034702 int  
  , census_tra_034801 int  
  , census_tra_034802 int  
  , census_tra_034803 int  
  , census_tra_034900 int  
  , census_tra_035100 int  
  , census_tra_035200 int  
  , census_tra_035301 int  
  , census_tra_035302 int  
  , census_tra_035500 int  
  , census_tra_035601 int  
  , census_tra_035602 int  
  , census_tra_035701 int  
  , census_tra_035702 int  
  , census_tra_035800 int  
  , census_tra_035900 int  
  , census_tra_036000 int  
  , census_tra_036100 int  
  , census_tra_036201 int  
  , census_tra_036202 int  
  , census_tra_036203 int  
  , census_tra_036301 int  
  , census_tra_036302 int  
  , census_tra_036303 int  
  , census_tra_036400 int  
  , census_tra_036501 int  
  , census_tra_036502 int  
  , census_tra_036600 int  
  , census_tra_036700 int  
  , census_tra_036900 int  
  , census_tra_037200 int  
  , census_tra_037300 int  
  , census_tra_037500 int  
  , census_tra_037600 int  
  , census_tra_037700 int  
  , census_tra_037800 int  
  , census_tra_037900 int  
  , census_tra_038000 int  
  , census_tra_038100 int  
  , census_tra_038200 int  
  , census_tra_038300 int  
  , census_tra_038400 int  
  , census_tra_038500 int  
  , census_tra_038600 int  
  , census_tra_038700 int  
  , census_tra_038800 int  
  , census_tra_038900 int  
  , census_tra_039000 int  
  , census_tra_980000 int  
  , census_tra_980100 int  
  , census_tra_980200 int  
  , census_tra_980300 int  
  , census_tra_980400 int  
  , census_tra_980500 int  
  , census_tra_980600 int  
  , census_tra_980700 int  
  , census_tra_980800 int  
  , census_tra_980900 int  
  , census_tra_989100 int  
, primary key ( cell_id ));




insert into cell_census_tract_bins
select c.cell_id
 , max(case when ct.census_tra = '1' then 1 else 0 end) as census_tra_000100 
 , max(case when ct.census_tra = '2' then 1 else 0 end) as census_tra_000200 
 , max(case when ct.census_tra = '3' then 1 else 0 end) as census_tra_000300 
 , max(case when ct.census_tra = '4.01' then 1 else 0 end) as census_tra_000401 
 , max(case when ct.census_tra = '4.02' then 1 else 0 end) as census_tra_000402 
 , max(case when ct.census_tra = '5' then 1 else 0 end) as census_tra_000500 
 , max(case when ct.census_tra = '6' then 1 else 0 end) as census_tra_000600 
 , max(case when ct.census_tra = '7' then 1 else 0 end) as census_tra_000700 
 , max(case when ct.census_tra = '8.01' then 1 else 0 end) as census_tra_000801 
 , max(case when ct.census_tra = '8.03' then 1 else 0 end) as census_tra_000803 
 , max(case when ct.census_tra = '8.04' then 1 else 0 end) as census_tra_000804 
 , max(case when ct.census_tra = '9.01' then 1 else 0 end) as census_tra_000901 
 , max(case when ct.census_tra = '9.02' then 1 else 0 end) as census_tra_000902 
 , max(case when ct.census_tra = '10.01' then 1 else 0 end) as census_tra_001001 
 , max(case when ct.census_tra = '10.02' then 1 else 0 end) as census_tra_001002 
 , max(case when ct.census_tra = '11.01' then 1 else 0 end) as census_tra_001101 
 , max(case when ct.census_tra = '11.02' then 1 else 0 end) as census_tra_001102 
 , max(case when ct.census_tra = '12.01' then 1 else 0 end) as census_tra_001201 
 , max(case when ct.census_tra = '12.02' then 1 else 0 end) as census_tra_001202 
 , max(case when ct.census_tra = '13' then 1 else 0 end) as census_tra_001300 
 , max(case when ct.census_tra = '14' then 1 else 0 end) as census_tra_001400 
 , max(case when ct.census_tra = '15' then 1 else 0 end) as census_tra_001500 
 , max(case when ct.census_tra = '16' then 1 else 0 end) as census_tra_001600 
 , max(case when ct.census_tra = '17' then 1 else 0 end) as census_tra_001700 
 , max(case when ct.census_tra = '18' then 1 else 0 end) as census_tra_001800 
 , max(case when ct.census_tra = '19' then 1 else 0 end) as census_tra_001900 
 , max(case when ct.census_tra = '20' then 1 else 0 end) as census_tra_002000 
 , max(case when ct.census_tra = '21' then 1 else 0 end) as census_tra_002100 
 , max(case when ct.census_tra = '22' then 1 else 0 end) as census_tra_002200 
 , max(case when ct.census_tra = '23' then 1 else 0 end) as census_tra_002300 
 , max(case when ct.census_tra = '24' then 1 else 0 end) as census_tra_002400 
 , max(case when ct.census_tra = '25' then 1 else 0 end) as census_tra_002500 
 , max(case when ct.census_tra = '27.01' then 1 else 0 end) as census_tra_002701 
 , max(case when ct.census_tra = '27.02' then 1 else 0 end) as census_tra_002702 
 , max(case when ct.census_tra = '28.01' then 1 else 0 end) as census_tra_002801 
 , max(case when ct.census_tra = '28.02' then 1 else 0 end) as census_tra_002802 
 , max(case when ct.census_tra = '29' then 1 else 0 end) as census_tra_002900 
 , max(case when ct.census_tra = '30.01' then 1 else 0 end) as census_tra_003001 
 , max(case when ct.census_tra = '30.02' then 1 else 0 end) as census_tra_003002 
 , max(case when ct.census_tra = '31' then 1 else 0 end) as census_tra_003100 
 , max(case when ct.census_tra = '32' then 1 else 0 end) as census_tra_003200 
 , max(case when ct.census_tra = '33' then 1 else 0 end) as census_tra_003300 
 , max(case when ct.census_tra = '36' then 1 else 0 end) as census_tra_003600 
 , max(case when ct.census_tra = '37.01' then 1 else 0 end) as census_tra_003701 
 , max(case when ct.census_tra = '37.02' then 1 else 0 end) as census_tra_003702 
 , max(case when ct.census_tra = '38' then 1 else 0 end) as census_tra_003800 
 , max(case when ct.census_tra = '39.01' then 1 else 0 end) as census_tra_003901 
 , max(case when ct.census_tra = '39.02' then 1 else 0 end) as census_tra_003902 
 , max(case when ct.census_tra = '40.01' then 1 else 0 end) as census_tra_004001 
 , max(case when ct.census_tra = '40.02' then 1 else 0 end) as census_tra_004002 
 , max(case when ct.census_tra = '41.01' then 1 else 0 end) as census_tra_004101 
 , max(case when ct.census_tra = '41.02' then 1 else 0 end) as census_tra_004102 
 , max(case when ct.census_tra = '42.01' then 1 else 0 end) as census_tra_004201 
 , max(case when ct.census_tra = '42.02' then 1 else 0 end) as census_tra_004202 
 , max(case when ct.census_tra = '50' then 1 else 0 end) as census_tra_005000 
 , max(case when ct.census_tra = '54' then 1 else 0 end) as census_tra_005400 
 , max(case when ct.census_tra = '55' then 1 else 0 end) as census_tra_005500 
 , max(case when ct.census_tra = '56' then 1 else 0 end) as census_tra_005600 
 , max(case when ct.census_tra = '60' then 1 else 0 end) as census_tra_006000 
 , max(case when ct.census_tra = '61' then 1 else 0 end) as census_tra_006100 
 , max(case when ct.census_tra = '62' then 1 else 0 end) as census_tra_006200 
 , max(case when ct.census_tra = '63' then 1 else 0 end) as census_tra_006300 
 , max(case when ct.census_tra = '64' then 1 else 0 end) as census_tra_006400 
 , max(case when ct.census_tra = '65' then 1 else 0 end) as census_tra_006500 
 , max(case when ct.census_tra = '66' then 1 else 0 end) as census_tra_006600 
 , max(case when ct.census_tra = '67' then 1 else 0 end) as census_tra_006700 
 , max(case when ct.census_tra = '69' then 1 else 0 end) as census_tra_006900 
 , max(case when ct.census_tra = '70' then 1 else 0 end) as census_tra_007000 
 , max(case when ct.census_tra = '71.01' then 1 else 0 end) as census_tra_007101 
 , max(case when ct.census_tra = '71.02' then 1 else 0 end) as census_tra_007102 
 , max(case when ct.census_tra = '72' then 1 else 0 end) as census_tra_007200 
 , max(case when ct.census_tra = '73' then 1 else 0 end) as census_tra_007300 
 , max(case when ct.census_tra = '74' then 1 else 0 end) as census_tra_007400 
 , max(case when ct.census_tra = '77' then 1 else 0 end) as census_tra_007700 
 , max(case when ct.census_tra = '78' then 1 else 0 end) as census_tra_007800 
 , max(case when ct.census_tra = '79' then 1 else 0 end) as census_tra_007900 
 , max(case when ct.census_tra = '80' then 1 else 0 end) as census_tra_008000 
 , max(case when ct.census_tra = '81.01' then 1 else 0 end) as census_tra_008101 
 , max(case when ct.census_tra = '81.02' then 1 else 0 end) as census_tra_008102 
 , max(case when ct.census_tra = '82' then 1 else 0 end) as census_tra_008200 
 , max(case when ct.census_tra = '83.01' then 1 else 0 end) as census_tra_008301 
 , max(case when ct.census_tra = '83.02' then 1 else 0 end) as census_tra_008302 
 , max(case when ct.census_tra = '84' then 1 else 0 end) as census_tra_008400 
 , max(case when ct.census_tra = '85' then 1 else 0 end) as census_tra_008500 
 , max(case when ct.census_tra = '86.01' then 1 else 0 end) as census_tra_008601 
 , max(case when ct.census_tra = '86.02' then 1 else 0 end) as census_tra_008602 
 , max(case when ct.census_tra = '87.01' then 1 else 0 end) as census_tra_008701 
 , max(case when ct.census_tra = '87.02' then 1 else 0 end) as census_tra_008702 
 , max(case when ct.census_tra = '88.01' then 1 else 0 end) as census_tra_008801 
 , max(case when ct.census_tra = '88.02' then 1 else 0 end) as census_tra_008802 
 , max(case when ct.census_tra = '90' then 1 else 0 end) as census_tra_009000 
 , max(case when ct.census_tra = '91' then 1 else 0 end) as census_tra_009100 
 , max(case when ct.census_tra = '92' then 1 else 0 end) as census_tra_009200 
 , max(case when ct.census_tra = '93' then 1 else 0 end) as census_tra_009300 
 , max(case when ct.census_tra = '94' then 1 else 0 end) as census_tra_009400 
 , max(case when ct.census_tra = '95' then 1 else 0 end) as census_tra_009500 
 , max(case when ct.census_tra = '96' then 1 else 0 end) as census_tra_009600 
 , max(case when ct.census_tra = '98.01' then 1 else 0 end) as census_tra_009801 
 , max(case when ct.census_tra = '98.02' then 1 else 0 end) as census_tra_009802 
 , max(case when ct.census_tra = '100' then 1 else 0 end) as census_tra_010000 
 , max(case when ct.census_tra = '101' then 1 else 0 end) as census_tra_010100 
 , max(case when ct.census_tra = '102' then 1 else 0 end) as census_tra_010200 
 , max(case when ct.census_tra = '103' then 1 else 0 end) as census_tra_010300 
 , max(case when ct.census_tra = '104' then 1 else 0 end) as census_tra_010400 
 , max(case when ct.census_tra = '105' then 1 else 0 end) as census_tra_010500 
 , max(case when ct.census_tra = '106' then 1 else 0 end) as census_tra_010600 
 , max(case when ct.census_tra = '107' then 1 else 0 end) as census_tra_010700 
 , max(case when ct.census_tra = '108' then 1 else 0 end) as census_tra_010800 
 , max(case when ct.census_tra = '109' then 1 else 0 end) as census_tra_010900 
 , max(case when ct.census_tra = '110' then 1 else 0 end) as census_tra_011000 
 , max(case when ct.census_tra = '111' then 1 else 0 end) as census_tra_011100 
 , max(case when ct.census_tra = '112' then 1 else 0 end) as census_tra_011200 
 , max(case when ct.census_tra = '113' then 1 else 0 end) as census_tra_011300 
 , max(case when ct.census_tra = '114' then 1 else 0 end) as census_tra_011400 
 , max(case when ct.census_tra = '115' then 1 else 0 end) as census_tra_011500 
 , max(case when ct.census_tra = '117' then 1 else 0 end) as census_tra_011700 
 , max(case when ct.census_tra = '118' then 1 else 0 end) as census_tra_011800 
 , max(case when ct.census_tra = '119' then 1 else 0 end) as census_tra_011900 
 , max(case when ct.census_tra = '120' then 1 else 0 end) as census_tra_012000 
 , max(case when ct.census_tra = '121' then 1 else 0 end) as census_tra_012100 
 , max(case when ct.census_tra = '122.01' then 1 else 0 end) as census_tra_012201 
 , max(case when ct.census_tra = '122.03' then 1 else 0 end) as census_tra_012203 
 , max(case when ct.census_tra = '122.04' then 1 else 0 end) as census_tra_012204 
 , max(case when ct.census_tra = '125' then 1 else 0 end) as census_tra_012500 
 , max(case when ct.census_tra = '131' then 1 else 0 end) as census_tra_013100 
 , max(case when ct.census_tra = '132' then 1 else 0 end) as census_tra_013200 
 , max(case when ct.census_tra = '133' then 1 else 0 end) as census_tra_013300 
 , max(case when ct.census_tra = '134.01' then 1 else 0 end) as census_tra_013401 
 , max(case when ct.census_tra = '134.02' then 1 else 0 end) as census_tra_013402 
 , max(case when ct.census_tra = '135' then 1 else 0 end) as census_tra_013500 
 , max(case when ct.census_tra = '136.01' then 1 else 0 end) as census_tra_013601 
 , max(case when ct.census_tra = '136.02' then 1 else 0 end) as census_tra_013602 
 , max(case when ct.census_tra = '137' then 1 else 0 end) as census_tra_013700 
 , max(case when ct.census_tra = '138' then 1 else 0 end) as census_tra_013800 
 , max(case when ct.census_tra = '139' then 1 else 0 end) as census_tra_013900 
 , max(case when ct.census_tra = '140' then 1 else 0 end) as census_tra_014000 
 , max(case when ct.census_tra = '141' then 1 else 0 end) as census_tra_014100 
 , max(case when ct.census_tra = '142' then 1 else 0 end) as census_tra_014200 
 , max(case when ct.census_tra = '143' then 1 else 0 end) as census_tra_014300 
 , max(case when ct.census_tra = '144' then 1 else 0 end) as census_tra_014400 
 , max(case when ct.census_tra = '145' then 1 else 0 end) as census_tra_014500 
 , max(case when ct.census_tra = '146' then 1 else 0 end) as census_tra_014600 
 , max(case when ct.census_tra = '147' then 1 else 0 end) as census_tra_014700 
 , max(case when ct.census_tra = '148' then 1 else 0 end) as census_tra_014800 
 , max(case when ct.census_tra = '149' then 1 else 0 end) as census_tra_014900 
 , max(case when ct.census_tra = '151.01' then 1 else 0 end) as census_tra_015101 
 , max(case when ct.census_tra = '151.02' then 1 else 0 end) as census_tra_015102 
 , max(case when ct.census_tra = '152' then 1 else 0 end) as census_tra_015200 
 , max(case when ct.census_tra = '153' then 1 else 0 end) as census_tra_015300 
 , max(case when ct.census_tra = '156' then 1 else 0 end) as census_tra_015600 
 , max(case when ct.census_tra = '157' then 1 else 0 end) as census_tra_015700 
 , max(case when ct.census_tra = '158' then 1 else 0 end) as census_tra_015800 
 , max(case when ct.census_tra = '160' then 1 else 0 end) as census_tra_016000 
 , max(case when ct.census_tra = '161' then 1 else 0 end) as census_tra_016100 
 , max(case when ct.census_tra = '162' then 1 else 0 end) as census_tra_016200 
 , max(case when ct.census_tra = '163' then 1 else 0 end) as census_tra_016300 
 , max(case when ct.census_tra = '164' then 1 else 0 end) as census_tra_016400 
 , max(case when ct.census_tra = '165' then 1 else 0 end) as census_tra_016500 
 , max(case when ct.census_tra = '166' then 1 else 0 end) as census_tra_016600 
 , max(case when ct.census_tra = '167.01' then 1 else 0 end) as census_tra_016701 
 , max(case when ct.census_tra = '167.02' then 1 else 0 end) as census_tra_016702 
 , max(case when ct.census_tra = '168' then 1 else 0 end) as census_tra_016800 
 , max(case when ct.census_tra = '169.01' then 1 else 0 end) as census_tra_016901 
 , max(case when ct.census_tra = '169.02' then 1 else 0 end) as census_tra_016902 
 , max(case when ct.census_tra = '170' then 1 else 0 end) as census_tra_017000 
 , max(case when ct.census_tra = '171' then 1 else 0 end) as census_tra_017100 
 , max(case when ct.census_tra = '172.01' then 1 else 0 end) as census_tra_017201 
 , max(case when ct.census_tra = '172.02' then 1 else 0 end) as census_tra_017202 
 , max(case when ct.census_tra = '173' then 1 else 0 end) as census_tra_017300 
 , max(case when ct.census_tra = '174' then 1 else 0 end) as census_tra_017400 
 , max(case when ct.census_tra = '175' then 1 else 0 end) as census_tra_017500 
 , max(case when ct.census_tra = '176.01' then 1 else 0 end) as census_tra_017601 
 , max(case when ct.census_tra = '176.02' then 1 else 0 end) as census_tra_017602 
 , max(case when ct.census_tra = '177.01' then 1 else 0 end) as census_tra_017701 
 , max(case when ct.census_tra = '177.02' then 1 else 0 end) as census_tra_017702 
 , max(case when ct.census_tra = '178' then 1 else 0 end) as census_tra_017800 
 , max(case when ct.census_tra = '179' then 1 else 0 end) as census_tra_017900 
 , max(case when ct.census_tra = '180.01' then 1 else 0 end) as census_tra_018001 
 , max(case when ct.census_tra = '180.02' then 1 else 0 end) as census_tra_018002 
 , max(case when ct.census_tra = '183' then 1 else 0 end) as census_tra_018300 
 , max(case when ct.census_tra = '184' then 1 else 0 end) as census_tra_018400 
 , max(case when ct.census_tra = '188' then 1 else 0 end) as census_tra_018800 
 , max(case when ct.census_tra = '190' then 1 else 0 end) as census_tra_019000 
 , max(case when ct.census_tra = '191' then 1 else 0 end) as census_tra_019100 
 , max(case when ct.census_tra = '192' then 1 else 0 end) as census_tra_019200 
 , max(case when ct.census_tra = '195.01' then 1 else 0 end) as census_tra_019501 
 , max(case when ct.census_tra = '195.02' then 1 else 0 end) as census_tra_019502 
 , max(case when ct.census_tra = '197' then 1 else 0 end) as census_tra_019700 
 , max(case when ct.census_tra = '198' then 1 else 0 end) as census_tra_019800 
 , max(case when ct.census_tra = '199' then 1 else 0 end) as census_tra_019900 
 , max(case when ct.census_tra = '200' then 1 else 0 end) as census_tra_020000 
 , max(case when ct.census_tra = '201.01' then 1 else 0 end) as census_tra_020101 
 , max(case when ct.census_tra = '201.02' then 1 else 0 end) as census_tra_020102 
 , max(case when ct.census_tra = '202' then 1 else 0 end) as census_tra_020200 
 , max(case when ct.census_tra = '203' then 1 else 0 end) as census_tra_020300 
 , max(case when ct.census_tra = '204' then 1 else 0 end) as census_tra_020400 
 , max(case when ct.census_tra = '205' then 1 else 0 end) as census_tra_020500 
 , max(case when ct.census_tra = '206' then 1 else 0 end) as census_tra_020600 
 , max(case when ct.census_tra = '207' then 1 else 0 end) as census_tra_020700 
 , max(case when ct.census_tra = '208' then 1 else 0 end) as census_tra_020800 
 , max(case when ct.census_tra = '209' then 1 else 0 end) as census_tra_020900 
 , max(case when ct.census_tra = '210' then 1 else 0 end) as census_tra_021000 
 , max(case when ct.census_tra = '211' then 1 else 0 end) as census_tra_021100 
 , max(case when ct.census_tra = '212' then 1 else 0 end) as census_tra_021200 
 , max(case when ct.census_tra = '213' then 1 else 0 end) as census_tra_021300 
 , max(case when ct.census_tra = '214' then 1 else 0 end) as census_tra_021400 
 , max(case when ct.census_tra = '215' then 1 else 0 end) as census_tra_021500 
 , max(case when ct.census_tra = '216' then 1 else 0 end) as census_tra_021600 
 , max(case when ct.census_tra = '217' then 1 else 0 end) as census_tra_021700 
 , max(case when ct.census_tra = '218' then 1 else 0 end) as census_tra_021800 
 , max(case when ct.census_tra = '219' then 1 else 0 end) as census_tra_021900 
 , max(case when ct.census_tra = '220' then 1 else 0 end) as census_tra_022000 
 , max(case when ct.census_tra = '231' then 1 else 0 end) as census_tra_023100 
 , max(case when ct.census_tra = '235' then 1 else 0 end) as census_tra_023500 
 , max(case when ct.census_tra = '236' then 1 else 0 end) as census_tra_023600 
 , max(case when ct.census_tra = '237' then 1 else 0 end) as census_tra_023700 
 , max(case when ct.census_tra = '238' then 1 else 0 end) as census_tra_023800 
 , max(case when ct.census_tra = '239' then 1 else 0 end) as census_tra_023900 
 , max(case when ct.census_tra = '240' then 1 else 0 end) as census_tra_024000 
 , max(case when ct.census_tra = '241' then 1 else 0 end) as census_tra_024100 
 , max(case when ct.census_tra = '242' then 1 else 0 end) as census_tra_024200 
 , max(case when ct.census_tra = '243' then 1 else 0 end) as census_tra_024300 
 , max(case when ct.census_tra = '244' then 1 else 0 end) as census_tra_024400 
 , max(case when ct.census_tra = '245' then 1 else 0 end) as census_tra_024500 
 , max(case when ct.census_tra = '246' then 1 else 0 end) as census_tra_024600 
 , max(case when ct.census_tra = '247' then 1 else 0 end) as census_tra_024700 
 , max(case when ct.census_tra = '248' then 1 else 0 end) as census_tra_024800 
 , max(case when ct.census_tra = '249' then 1 else 0 end) as census_tra_024900 
 , max(case when ct.census_tra = '252' then 1 else 0 end) as census_tra_025200 
 , max(case when ct.census_tra = '253' then 1 else 0 end) as census_tra_025300 
 , max(case when ct.census_tra = '254' then 1 else 0 end) as census_tra_025400 
 , max(case when ct.census_tra = '255' then 1 else 0 end) as census_tra_025500 
 , max(case when ct.census_tra = '256' then 1 else 0 end) as census_tra_025600 
 , max(case when ct.census_tra = '257' then 1 else 0 end) as census_tra_025700 
 , max(case when ct.census_tra = '258' then 1 else 0 end) as census_tra_025800 
 , max(case when ct.census_tra = '259' then 1 else 0 end) as census_tra_025900 
 , max(case when ct.census_tra = '260' then 1 else 0 end) as census_tra_026000 
 , max(case when ct.census_tra = '261' then 1 else 0 end) as census_tra_026100 
 , max(case when ct.census_tra = '262' then 1 else 0 end) as census_tra_026200 
 , max(case when ct.census_tra = '263.01' then 1 else 0 end) as census_tra_026301 
 , max(case when ct.census_tra = '263.02' then 1 else 0 end) as census_tra_026302 
 , max(case when ct.census_tra = '264' then 1 else 0 end) as census_tra_026400 
 , max(case when ct.census_tra = '265' then 1 else 0 end) as census_tra_026500 
 , max(case when ct.census_tra = '266' then 1 else 0 end) as census_tra_026600 
 , max(case when ct.census_tra = '267' then 1 else 0 end) as census_tra_026700 
 , max(case when ct.census_tra = '268' then 1 else 0 end) as census_tra_026800 
 , max(case when ct.census_tra = '269' then 1 else 0 end) as census_tra_026900 
 , max(case when ct.census_tra = '270' then 1 else 0 end) as census_tra_027000 
 , max(case when ct.census_tra = '271' then 1 else 0 end) as census_tra_027100 
 , max(case when ct.census_tra = '272' then 1 else 0 end) as census_tra_027200 
 , max(case when ct.census_tra = '273' then 1 else 0 end) as census_tra_027300 
 , max(case when ct.census_tra = '274.01' then 1 else 0 end) as census_tra_027401 
 , max(case when ct.census_tra = '274.02' then 1 else 0 end) as census_tra_027402 
 , max(case when ct.census_tra = '275' then 1 else 0 end) as census_tra_027500 
 , max(case when ct.census_tra = '276' then 1 else 0 end) as census_tra_027600 
 , max(case when ct.census_tra = '277' then 1 else 0 end) as census_tra_027700 
 , max(case when ct.census_tra = '278' then 1 else 0 end) as census_tra_027800 
 , max(case when ct.census_tra = '279.01' then 1 else 0 end) as census_tra_027901 
 , max(case when ct.census_tra = '279.02' then 1 else 0 end) as census_tra_027902 
 , max(case when ct.census_tra = '280' then 1 else 0 end) as census_tra_028000 
 , max(case when ct.census_tra = '281' then 1 else 0 end) as census_tra_028100 
 , max(case when ct.census_tra = '282' then 1 else 0 end) as census_tra_028200 
 , max(case when ct.census_tra = '283' then 1 else 0 end) as census_tra_028300 
 , max(case when ct.census_tra = '284' then 1 else 0 end) as census_tra_028400 
 , max(case when ct.census_tra = '285' then 1 else 0 end) as census_tra_028500 
 , max(case when ct.census_tra = '286' then 1 else 0 end) as census_tra_028600 
 , max(case when ct.census_tra = '287' then 1 else 0 end) as census_tra_028700 
 , max(case when ct.census_tra = '288' then 1 else 0 end) as census_tra_028800 
 , max(case when ct.census_tra = '289.01' then 1 else 0 end) as census_tra_028901 
 , max(case when ct.census_tra = '289.02' then 1 else 0 end) as census_tra_028902 
 , max(case when ct.census_tra = '290' then 1 else 0 end) as census_tra_029000 
 , max(case when ct.census_tra = '291' then 1 else 0 end) as census_tra_029100 
 , max(case when ct.census_tra = '292' then 1 else 0 end) as census_tra_029200 
 , max(case when ct.census_tra = '293' then 1 else 0 end) as census_tra_029300 
 , max(case when ct.census_tra = '294' then 1 else 0 end) as census_tra_029400 
 , max(case when ct.census_tra = '298' then 1 else 0 end) as census_tra_029800 
 , max(case when ct.census_tra = '299' then 1 else 0 end) as census_tra_029900 
 , max(case when ct.census_tra = '300' then 1 else 0 end) as census_tra_030000 
 , max(case when ct.census_tra = '301' then 1 else 0 end) as census_tra_030100 
 , max(case when ct.census_tra = '302' then 1 else 0 end) as census_tra_030200 
 , max(case when ct.census_tra = '305.01' then 1 else 0 end) as census_tra_030501 
 , max(case when ct.census_tra = '305.02' then 1 else 0 end) as census_tra_030502 
 , max(case when ct.census_tra = '306' then 1 else 0 end) as census_tra_030600 
 , max(case when ct.census_tra = '307' then 1 else 0 end) as census_tra_030700 
 , max(case when ct.census_tra = '308' then 1 else 0 end) as census_tra_030800 
 , max(case when ct.census_tra = '309' then 1 else 0 end) as census_tra_030900 
 , max(case when ct.census_tra = '310' then 1 else 0 end) as census_tra_031000 
 , max(case when ct.census_tra = '311.01' then 1 else 0 end) as census_tra_031101 
 , max(case when ct.census_tra = '311.02' then 1 else 0 end) as census_tra_031102 
 , max(case when ct.census_tra = '312' then 1 else 0 end) as census_tra_031200 
 , max(case when ct.census_tra = '313' then 1 else 0 end) as census_tra_031300 
 , max(case when ct.census_tra = '314.01' then 1 else 0 end) as census_tra_031401 
 , max(case when ct.census_tra = '314.02' then 1 else 0 end) as census_tra_031402 
 , max(case when ct.census_tra = '315.01' then 1 else 0 end) as census_tra_031501 
 , max(case when ct.census_tra = '315.02' then 1 else 0 end) as census_tra_031502 
 , max(case when ct.census_tra = '316' then 1 else 0 end) as census_tra_031600 
 , max(case when ct.census_tra = '317' then 1 else 0 end) as census_tra_031700 
 , max(case when ct.census_tra = '318' then 1 else 0 end) as census_tra_031800 
 , max(case when ct.census_tra = '319' then 1 else 0 end) as census_tra_031900 
 , max(case when ct.census_tra = '320' then 1 else 0 end) as census_tra_032000 
 , max(case when ct.census_tra = '321' then 1 else 0 end) as census_tra_032100 
 , max(case when ct.census_tra = '323' then 1 else 0 end) as census_tra_032300 
 , max(case when ct.census_tra = '325' then 1 else 0 end) as census_tra_032500 
 , max(case when ct.census_tra = '326' then 1 else 0 end) as census_tra_032600 
 , max(case when ct.census_tra = '329' then 1 else 0 end) as census_tra_032900 
 , max(case when ct.census_tra = '330' then 1 else 0 end) as census_tra_033000 
 , max(case when ct.census_tra = '331.01' then 1 else 0 end) as census_tra_033101 
 , max(case when ct.census_tra = '331.02' then 1 else 0 end) as census_tra_033102 
 , max(case when ct.census_tra = '332' then 1 else 0 end) as census_tra_033200 
 , max(case when ct.census_tra = '333' then 1 else 0 end) as census_tra_033300 
 , max(case when ct.census_tra = '334' then 1 else 0 end) as census_tra_033400 
 , max(case when ct.census_tra = '335' then 1 else 0 end) as census_tra_033500 
 , max(case when ct.census_tra = '336' then 1 else 0 end) as census_tra_033600 
 , max(case when ct.census_tra = '337.01' then 1 else 0 end) as census_tra_033701 
 , max(case when ct.census_tra = '337.02' then 1 else 0 end) as census_tra_033702 
 , max(case when ct.census_tra = '338' then 1 else 0 end) as census_tra_033800 
 , max(case when ct.census_tra = '339' then 1 else 0 end) as census_tra_033900 
 , max(case when ct.census_tra = '340' then 1 else 0 end) as census_tra_034000 
 , max(case when ct.census_tra = '341' then 1 else 0 end) as census_tra_034100 
 , max(case when ct.census_tra = '342' then 1 else 0 end) as census_tra_034200 
 , max(case when ct.census_tra = '344' then 1 else 0 end) as census_tra_034400 
 , max(case when ct.census_tra = '345.01' then 1 else 0 end) as census_tra_034501 
 , max(case when ct.census_tra = '345.02' then 1 else 0 end) as census_tra_034502 
 , max(case when ct.census_tra = '346' then 1 else 0 end) as census_tra_034600 
 , max(case when ct.census_tra = '347.01' then 1 else 0 end) as census_tra_034701 
 , max(case when ct.census_tra = '347.02' then 1 else 0 end) as census_tra_034702 
 , max(case when ct.census_tra = '348.01' then 1 else 0 end) as census_tra_034801 
 , max(case when ct.census_tra = '348.02' then 1 else 0 end) as census_tra_034802 
 , max(case when ct.census_tra = '348.03' then 1 else 0 end) as census_tra_034803 
 , max(case when ct.census_tra = '349' then 1 else 0 end) as census_tra_034900 
 , max(case when ct.census_tra = '351' then 1 else 0 end) as census_tra_035100 
 , max(case when ct.census_tra = '352' then 1 else 0 end) as census_tra_035200 
 , max(case when ct.census_tra = '353.01' then 1 else 0 end) as census_tra_035301 
 , max(case when ct.census_tra = '353.02' then 1 else 0 end) as census_tra_035302 
 , max(case when ct.census_tra = '355' then 1 else 0 end) as census_tra_035500 
 , max(case when ct.census_tra = '356.01' then 1 else 0 end) as census_tra_035601 
 , max(case when ct.census_tra = '356.02' then 1 else 0 end) as census_tra_035602 
 , max(case when ct.census_tra = '357.01' then 1 else 0 end) as census_tra_035701 
 , max(case when ct.census_tra = '357.02' then 1 else 0 end) as census_tra_035702 
 , max(case when ct.census_tra = '358' then 1 else 0 end) as census_tra_035800 
 , max(case when ct.census_tra = '359' then 1 else 0 end) as census_tra_035900 
 , max(case when ct.census_tra = '360' then 1 else 0 end) as census_tra_036000 
 , max(case when ct.census_tra = '361' then 1 else 0 end) as census_tra_036100 
 , max(case when ct.census_tra = '362.01' then 1 else 0 end) as census_tra_036201 
 , max(case when ct.census_tra = '362.02' then 1 else 0 end) as census_tra_036202 
 , max(case when ct.census_tra = '362.03' then 1 else 0 end) as census_tra_036203 
 , max(case when ct.census_tra = '363.01' then 1 else 0 end) as census_tra_036301 
 , max(case when ct.census_tra = '363.02' then 1 else 0 end) as census_tra_036302 
 , max(case when ct.census_tra = '363.03' then 1 else 0 end) as census_tra_036303 
 , max(case when ct.census_tra = '364' then 1 else 0 end) as census_tra_036400 
 , max(case when ct.census_tra = '365.01' then 1 else 0 end) as census_tra_036501 
 , max(case when ct.census_tra = '365.02' then 1 else 0 end) as census_tra_036502 
 , max(case when ct.census_tra = '366' then 1 else 0 end) as census_tra_036600 
 , max(case when ct.census_tra = '367' then 1 else 0 end) as census_tra_036700 
 , max(case when ct.census_tra = '369' then 1 else 0 end) as census_tra_036900 
 , max(case when ct.census_tra = '372' then 1 else 0 end) as census_tra_037200 
 , max(case when ct.census_tra = '373' then 1 else 0 end) as census_tra_037300 
 , max(case when ct.census_tra = '375' then 1 else 0 end) as census_tra_037500 
 , max(case when ct.census_tra = '376' then 1 else 0 end) as census_tra_037600 
 , max(case when ct.census_tra = '377' then 1 else 0 end) as census_tra_037700 
 , max(case when ct.census_tra = '378' then 1 else 0 end) as census_tra_037800 
 , max(case when ct.census_tra = '379' then 1 else 0 end) as census_tra_037900 
 , max(case when ct.census_tra = '380' then 1 else 0 end) as census_tra_038000 
 , max(case when ct.census_tra = '381' then 1 else 0 end) as census_tra_038100 
 , max(case when ct.census_tra = '382' then 1 else 0 end) as census_tra_038200 
 , max(case when ct.census_tra = '383' then 1 else 0 end) as census_tra_038300 
 , max(case when ct.census_tra = '384' then 1 else 0 end) as census_tra_038400 
 , max(case when ct.census_tra = '385' then 1 else 0 end) as census_tra_038500 
 , max(case when ct.census_tra = '386' then 1 else 0 end) as census_tra_038600 
 , max(case when ct.census_tra = '387' then 1 else 0 end) as census_tra_038700 
 , max(case when ct.census_tra = '388' then 1 else 0 end) as census_tra_038800 
 , max(case when ct.census_tra = '389' then 1 else 0 end) as census_tra_038900 
 , max(case when ct.census_tra = '390' then 1 else 0 end) as census_tra_039000 
 , max(case when ct.census_tra = '9800' then 1 else 0 end) as census_tra_980000 
 , max(case when ct.census_tra = '9801' then 1 else 0 end) as census_tra_980100 
 , max(case when ct.census_tra = '9802' then 1 else 0 end) as census_tra_980200 
 , max(case when ct.census_tra = '9803' then 1 else 0 end) as census_tra_980300 
 , max(case when ct.census_tra = '9804' then 1 else 0 end) as census_tra_980400 
 , max(case when ct.census_tra = '9805' then 1 else 0 end) as census_tra_980500 
 , max(case when ct.census_tra = '9806' then 1 else 0 end) as census_tra_980600 
 , max(case when ct.census_tra = '9807' then 1 else 0 end) as census_tra_980700 
 , max(case when ct.census_tra = '9808' then 1 else 0 end) as census_tra_980800 
 , max(case when ct.census_tra = '9809' then 1 else 0 end) as census_tra_980900 
 , max(case when ct.census_tra = '9891' then 1 else 0 end) as census_tra_989100 
 from cells c
inner join census_tracts ct 
	on ST_INTERSECTS(c.geom4326, ct.geom4326)
group by c.cell_id
; 





