--TO DO : 


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
	(select .007 as cell_width, .007 as cell_height
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
--error on gist(geom) -- only have geom4326; can substitute 

--adding in null row to crime_all for cells as cell_id, then runnning below: 
--alter table crime_all add column cell_id int; 

update crime_all c
	set cell_id = A.cell_id
	FROM cells as A 
	WHERE  ST_WITHIN (c.geom, A.geom4326)
	and c.cell_id is null and c.geom is not null
	;


/* 
# Use these queries to generate and populate the binning table.  The sql should recreated for each city (bc they have different tracts)
# and it'll rerun automatically each time the training pipeline is run bc the cell sizes can change each time


select replace(replace(replace(cast(array_agg(A.sql) as text), '{',''), '}',''), ' ','')
from 
(
	select 'create table cell_census_tract_bins ( cell_id int' as sql
	union all
	(
	select concat('census_tra_' ,census_tra, ' int')
	from census_tracts 
	order by census_tra
	)
	union all 
	select 'primary key ( cell_id );'
) A 
;


select 'insert into cell_census_tract_bins' as sql
union all select 'select c.cell_id'
union all
(
select concat(', max(case when ct.census_tra = ''', census_tra , ''' then 1 else 0 end) as census_tra_', census_tra)
from census_tracts
order by census_tra
)
union all
select 'from cells c
inner join census_tracts ct 
	on ST_INTERSECTS(c.geom4326, ct.geom4326)
group by c.cell_id
;'


-- And use this query to generate the sql for the export step  30.Code/${city}_crimes.sql.yaml

select concat(', census_tra_', census_tra
from census_tracts
order by census_tra
;


*/

drop table if exists cell_census_tract_bins;

 create table cell_census_tract_bins ( cell_id int 
 ,census_tra_000000 int 
 ,census_tra_010200 int 
 ,census_tra_010300 int 
 ,census_tra_010400 int 
 ,census_tra_010500 int 
 ,census_tra_010600 int 
 ,census_tra_010700 int 
 ,census_tra_010800 int 
 ,census_tra_010900 int 
 ,census_tra_020100 int 
 ,census_tra_020200 int 
 ,census_tra_020300 int 
 ,census_tra_020400 int 
 ,census_tra_020500 int 
 ,census_tra_020600 int 
 ,census_tra_020700 int 
 ,census_tra_020800 int 
 ,census_tra_020900 int 
 ,census_tra_030100 int 
 ,census_tra_030200 int 
 ,census_tra_030300 int 
 ,census_tra_030400 int 
 ,census_tra_030500 int 
 ,census_tra_030600 int 
 ,census_tra_030700 int 
 ,census_tra_030800 int 
 ,census_tra_030900 int 
 ,census_tra_031000 int 
 ,census_tra_031100 int 
 ,census_tra_031200 int 
 ,census_tra_031300 int 
 ,census_tra_031400 int 
 ,census_tra_031500 int 
 ,census_tra_031600 int 
 ,census_tra_031800 int 
 ,census_tra_031900 int 
 ,census_tra_032000 int 
 ,census_tra_032100 int 
 ,census_tra_040100 int 
 ,census_tra_040200 int 
 ,census_tra_040300 int 
 ,census_tra_040400 int 
 ,census_tra_040500 int 
 ,census_tra_040600 int 
 ,census_tra_040700 int 
 ,census_tra_040800 int 
 ,census_tra_040900 int 
 ,census_tra_041000 int 
 ,census_tra_050100 int 
 ,census_tra_050200 int 
 ,census_tra_050300 int 
 ,census_tra_050400 int 
 ,census_tra_050500 int 
 ,census_tra_050600 int 
 ,census_tra_050700 int 
 ,census_tra_050800 int 
 ,census_tra_050900 int 
 ,census_tra_051000 int 
 ,census_tra_051100 int 
 ,census_tra_051200 int 
 ,census_tra_051300 int 
 ,census_tra_051400 int 
 ,census_tra_051500 int 
 ,census_tra_060100 int 
 ,census_tra_060200 int 
 ,census_tra_060300 int 
 ,census_tra_060400 int 
 ,census_tra_060500 int 
 ,census_tra_060600 int 
 ,census_tra_060700 int 
 ,census_tra_060800 int 
 ,census_tra_060900 int 
 ,census_tra_061000 int 
 ,census_tra_061100 int 
 ,census_tra_061200 int 
 ,census_tra_061300 int 
 ,census_tra_061400 int 
 ,census_tra_061500 int 
 ,census_tra_061600 int 
 ,census_tra_061700 int 
 ,census_tra_061800 int 
 ,census_tra_061900 int 
 ,census_tra_062000 int 
 ,census_tra_062100 int 
 ,census_tra_062200 int 
 ,census_tra_062300 int 
 ,census_tra_062400 int 
 ,census_tra_062500 int 
 ,census_tra_062600 int 
 ,census_tra_062700 int 
 ,census_tra_062800 int 
 ,census_tra_062900 int 
 ,census_tra_063000 int 
 ,census_tra_063100 int 
 ,census_tra_063200 int 
 ,census_tra_063300 int 
 ,census_tra_063400 int 
 ,census_tra_070100 int 
 ,census_tra_070200 int 
 ,census_tra_070300 int 
 ,census_tra_070400 int 
 ,census_tra_070500 int 
 ,census_tra_070600 int 
 ,census_tra_070700 int 
 ,census_tra_070800 int 
 ,census_tra_070900 int 
 ,census_tra_071000 int 
 ,census_tra_071100 int 
 ,census_tra_071200 int 
 ,census_tra_071300 int 
 ,census_tra_071400 int 
 ,census_tra_071500 int 
 ,census_tra_071600 int 
 ,census_tra_071700 int 
 ,census_tra_071800 int 
 ,census_tra_071900 int 
 ,census_tra_072000 int 
 ,census_tra_080100 int 
 ,census_tra_080200 int 
 ,census_tra_080300 int 
 ,census_tra_080400 int 
 ,census_tra_080500 int 
 ,census_tra_080600 int 
 ,census_tra_080700 int 
 ,census_tra_080800 int 
 ,census_tra_080900 int 
 ,census_tra_081000 int 
 ,census_tra_081100 int 
 ,census_tra_081200 int 
 ,census_tra_081300 int 
 ,census_tra_081400 int 
 ,census_tra_081500 int 
 ,census_tra_081600 int 
 ,census_tra_081700 int 
 ,census_tra_081800 int 
 ,census_tra_081900 int 
 ,census_tra_090100 int 
 ,census_tra_090200 int 
 ,census_tra_090300 int 
 ,census_tra_100100 int 
 ,census_tra_100200 int 
 ,census_tra_100300 int 
 ,census_tra_100400 int 
 ,census_tra_100500 int 
 ,census_tra_100600 int 
 ,census_tra_100700 int 
 ,census_tra_110100 int 
 ,census_tra_110200 int 
 ,census_tra_110300 int 
 ,census_tra_110400 int 
 ,census_tra_110500 int 
 ,census_tra_120100 int 
 ,census_tra_120200 int 
 ,census_tra_120300 int 
 ,census_tra_120400 int 
 ,census_tra_130100 int 
 ,census_tra_130200 int 
 ,census_tra_130300 int 
 ,census_tra_130400 int 
 ,census_tra_130500 int 
 ,census_tra_140100 int 
 ,census_tra_140200 int 
 ,census_tra_140300 int 
 ,census_tra_140400 int 
 ,census_tra_140500 int 
 ,census_tra_140600 int 
 ,census_tra_140700 int 
 ,census_tra_140800 int 
 ,census_tra_150100 int 
 ,census_tra_150200 int 
 ,census_tra_150300 int 
 ,census_tra_150400 int 
 ,census_tra_150500 int 
 ,census_tra_150600 int 
 ,census_tra_150700 int 
 ,census_tra_150800 int 
 ,census_tra_150900 int 
 ,census_tra_151000 int 
 ,census_tra_151100 int 
 ,census_tra_151200 int 
 ,census_tra_160100 int 
 ,census_tra_160200 int 
 ,census_tra_160300 int 
 ,census_tra_160400 int 
 ,census_tra_160500 int 
 ,census_tra_160600 int 
 ,census_tra_160700 int 
 ,census_tra_160800 int 
 ,census_tra_160900 int 
 ,census_tra_161000 int 
 ,census_tra_161100 int 
 ,census_tra_161200 int 
 ,census_tra_161300 int 
 ,census_tra_170100 int 
 ,census_tra_170200 int 
 ,census_tra_170300 int 
 ,census_tra_170400 int 
 ,census_tra_170500 int 
 ,census_tra_170600 int 
 ,census_tra_170700 int 
 ,census_tra_170800 int 
 ,census_tra_170900 int 
 ,census_tra_171000 int 
 ,census_tra_171100 int 
 ,census_tra_180100 int 
 ,census_tra_180200 int 
 ,census_tra_180300 int 
 ,census_tra_190100 int 
 ,census_tra_190200 int 
 ,census_tra_190300 int 
 ,census_tra_190400 int 
 ,census_tra_190500 int 
 ,census_tra_190600 int 
 ,census_tra_190700 int 
 ,census_tra_190800 int 
 ,census_tra_190900 int 
 ,census_tra_191000 int 
 ,census_tra_191100 int 
 ,census_tra_191200 int 
 ,census_tra_191400 int 
 ,census_tra_200100 int 
 ,census_tra_200200 int 
 ,census_tra_200300 int 
 ,census_tra_200400 int 
 ,census_tra_200500 int 
 ,census_tra_200600 int 
 ,census_tra_210100 int 
 ,census_tra_210200 int 
 ,census_tra_210300 int 
 ,census_tra_210400 int 
 ,census_tra_210500 int 
 ,census_tra_210600 int 
 ,census_tra_210700 int 
 ,census_tra_210800 int 
 ,census_tra_210900 int 
 ,census_tra_220100 int 
 ,census_tra_220200 int 
 ,census_tra_220300 int 
 ,census_tra_220400 int 
 ,census_tra_220500 int 
 ,census_tra_220600 int 
 ,census_tra_220700 int 
 ,census_tra_220800 int 
 ,census_tra_220900 int 
 ,census_tra_221000 int 
 ,census_tra_221100 int 
 ,census_tra_221200 int 
 ,census_tra_221300 int 
 ,census_tra_221400 int 
 ,census_tra_221500 int 
 ,census_tra_221600 int 
 ,census_tra_221700 int 
 ,census_tra_221800 int 
 ,census_tra_221900 int 
 ,census_tra_222000 int 
 ,census_tra_222100 int 
 ,census_tra_222200 int 
 ,census_tra_222300 int 
 ,census_tra_222400 int 
 ,census_tra_222500 int 
 ,census_tra_222600 int 
 ,census_tra_222700 int 
 ,census_tra_222800 int 
 ,census_tra_222900 int 
 ,census_tra_230100 int 
 ,census_tra_230200 int 
 ,census_tra_230300 int 
 ,census_tra_230400 int 
 ,census_tra_230500 int 
 ,census_tra_230600 int 
 ,census_tra_230700 int 
 ,census_tra_230800 int 
 ,census_tra_230900 int 
 ,census_tra_231000 int 
 ,census_tra_231100 int 
 ,census_tra_231200 int 
 ,census_tra_231300 int 
 ,census_tra_231400 int 
 ,census_tra_231500 int 
 ,census_tra_231600 int 
 ,census_tra_231700 int 
 ,census_tra_231800 int 
 ,census_tra_240100 int 
 ,census_tra_240200 int 
 ,census_tra_240300 int 
 ,census_tra_240400 int 
 ,census_tra_240500 int 
 ,census_tra_240600 int 
 ,census_tra_240700 int 
 ,census_tra_240800 int 
 ,census_tra_240900 int 
 ,census_tra_241000 int 
 ,census_tra_241100 int 
 ,census_tra_241200 int 
 ,census_tra_241300 int 
 ,census_tra_241400 int 
 ,census_tra_241500 int 
 ,census_tra_241600 int 
 ,census_tra_241700 int 
 ,census_tra_241800 int 
 ,census_tra_241900 int 
 ,census_tra_242000 int 
 ,census_tra_242100 int 
 ,census_tra_242200 int 
 ,census_tra_242300 int 
 ,census_tra_242400 int 
 ,census_tra_242500 int 
 ,census_tra_242600 int 
 ,census_tra_242700 int 
 ,census_tra_242800 int 
 ,census_tra_242900 int 
 ,census_tra_243000 int 
 ,census_tra_243100 int 
 ,census_tra_243200 int 
 ,census_tra_243300 int 
 ,census_tra_243400 int 
 ,census_tra_243500 int 
 ,census_tra_243600 int 
 ,census_tra_250100 int 
 ,census_tra_250200 int 
 ,census_tra_250300 int 
 ,census_tra_250400 int 
 ,census_tra_250500 int 
 ,census_tra_250600 int 
 ,census_tra_250700 int 
 ,census_tra_250800 int 
 ,census_tra_250900 int 
 ,census_tra_251000 int 
 ,census_tra_251200 int 
 ,census_tra_251300 int 
 ,census_tra_251400 int 
 ,census_tra_251500 int 
 ,census_tra_251600 int 
 ,census_tra_251700 int 
 ,census_tra_251800 int 
 ,census_tra_251900 int 
 ,census_tra_252000 int 
 ,census_tra_252100 int 
 ,census_tra_252200 int 
 ,census_tra_252300 int 
 ,census_tra_252400 int 
 ,census_tra_260100 int 
 ,census_tra_260200 int 
 ,census_tra_260300 int 
 ,census_tra_260400 int 
 ,census_tra_260500 int 
 ,census_tra_260600 int 
 ,census_tra_260700 int 
 ,census_tra_260800 int 
 ,census_tra_260900 int 
 ,census_tra_261000 int 
 ,census_tra_270100 int 
 ,census_tra_270200 int 
 ,census_tra_270300 int 
 ,census_tra_270400 int 
 ,census_tra_270500 int 
 ,census_tra_270600 int 
 ,census_tra_270700 int 
 ,census_tra_270800 int 
 ,census_tra_270900 int 
 ,census_tra_271000 int 
 ,census_tra_271100 int 
 ,census_tra_271200 int 
 ,census_tra_271300 int 
 ,census_tra_271400 int 
 ,census_tra_271500 int 
 ,census_tra_271600 int 
 ,census_tra_271700 int 
 ,census_tra_271800 int 
 ,census_tra_271900 int 
 ,census_tra_280100 int 
 ,census_tra_280200 int 
 ,census_tra_280300 int 
 ,census_tra_280400 int 
 ,census_tra_280500 int 
 ,census_tra_280600 int 
 ,census_tra_280700 int 
 ,census_tra_280800 int 
 ,census_tra_280900 int 
 ,census_tra_281000 int 
 ,census_tra_281100 int 
 ,census_tra_281200 int 
 ,census_tra_281300 int 
 ,census_tra_281400 int 
 ,census_tra_281500 int 
 ,census_tra_281600 int 
 ,census_tra_281700 int 
 ,census_tra_281800 int 
 ,census_tra_281900 int 
 ,census_tra_282000 int 
 ,census_tra_282100 int 
 ,census_tra_282200 int 
 ,census_tra_282300 int 
 ,census_tra_282400 int 
 ,census_tra_282500 int 
 ,census_tra_282600 int 
 ,census_tra_282700 int 
 ,census_tra_282800 int 
 ,census_tra_282900 int 
 ,census_tra_283000 int 
 ,census_tra_283100 int 
 ,census_tra_283200 int 
 ,census_tra_283300 int 
 ,census_tra_283400 int 
 ,census_tra_283500 int 
 ,census_tra_283600 int 
 ,census_tra_283700 int 
 ,census_tra_283800 int 
 ,census_tra_283900 int 
 ,census_tra_284000 int 
 ,census_tra_284100 int 
 ,census_tra_284200 int 
 ,census_tra_284300 int 
 ,census_tra_290100 int 
 ,census_tra_290200 int 
 ,census_tra_290300 int 
 ,census_tra_290400 int 
 ,census_tra_290500 int 
 ,census_tra_290600 int 
 ,census_tra_290700 int 
 ,census_tra_290800 int 
 ,census_tra_290900 int 
 ,census_tra_291000 int 
 ,census_tra_291100 int 
 ,census_tra_291200 int 
 ,census_tra_291300 int 
 ,census_tra_291400 int 
 ,census_tra_291500 int 
 ,census_tra_291600 int 
 ,census_tra_291700 int 
 ,census_tra_291800 int 
 ,census_tra_291900 int 
 ,census_tra_292000 int 
 ,census_tra_292100 int 
 ,census_tra_292200 int 
 ,census_tra_292300 int 
 ,census_tra_292400 int 
 ,census_tra_292500 int 
 ,census_tra_292600 int 
 ,census_tra_292700 int 
 ,census_tra_300100 int 
 ,census_tra_300200 int 
 ,census_tra_300300 int 
 ,census_tra_300400 int 
 ,census_tra_300500 int 
 ,census_tra_300600 int 
 ,census_tra_300700 int 
 ,census_tra_300800 int 
 ,census_tra_300900 int 
 ,census_tra_301000 int 
 ,census_tra_301100 int 
 ,census_tra_301200 int 
 ,census_tra_301300 int 
 ,census_tra_301400 int 
 ,census_tra_301500 int 
 ,census_tra_301600 int 
 ,census_tra_301700 int 
 ,census_tra_301800 int 
 ,census_tra_301900 int 
 ,census_tra_302000 int 
 ,census_tra_310100 int 
 ,census_tra_310200 int 
 ,census_tra_310300 int 
 ,census_tra_310400 int 
 ,census_tra_310500 int 
 ,census_tra_310600 int 
 ,census_tra_310700 int 
 ,census_tra_310800 int 
 ,census_tra_310900 int 
 ,census_tra_311000 int 
 ,census_tra_311100 int 
 ,census_tra_311200 int 
 ,census_tra_311300 int 
 ,census_tra_311400 int 
 ,census_tra_311500 int 
 ,census_tra_320100 int 
 ,census_tra_320200 int 
 ,census_tra_320300 int 
 ,census_tra_320400 int 
 ,census_tra_320500 int 
 ,census_tra_320600 int 
 ,census_tra_330100 int 
 ,census_tra_330200 int 
 ,census_tra_330300 int 
 ,census_tra_330400 int 
 ,census_tra_330500 int 
 ,census_tra_340100 int 
 ,census_tra_340200 int 
 ,census_tra_340300 int 
 ,census_tra_340400 int 
 ,census_tra_340500 int 
 ,census_tra_340600 int 
 ,census_tra_350100 int 
 ,census_tra_350200 int 
 ,census_tra_350300 int 
 ,census_tra_350400 int 
 ,census_tra_350500 int 
 ,census_tra_350600 int 
 ,census_tra_350700 int 
 ,census_tra_350800 int 
 ,census_tra_350900 int 
 ,census_tra_351000 int 
 ,census_tra_351100 int 
 ,census_tra_351200 int 
 ,census_tra_351300 int 
 ,census_tra_351400 int 
 ,census_tra_351500 int 
 ,census_tra_360100 int 
 ,census_tra_360200 int 
 ,census_tra_360300 int 
 ,census_tra_360400 int 
 ,census_tra_360500 int 
 ,census_tra_370100 int 
 ,census_tra_370200 int 
 ,census_tra_370300 int 
 ,census_tra_370400 int 
 ,census_tra_380100 int 
 ,census_tra_380200 int 
 ,census_tra_380300 int 
 ,census_tra_380400 int 
 ,census_tra_380500 int 
 ,census_tra_380600 int 
 ,census_tra_380700 int 
 ,census_tra_380800 int 
 ,census_tra_380900 int 
 ,census_tra_381000 int 
 ,census_tra_381100 int 
 ,census_tra_381200 int 
 ,census_tra_381300 int 
 ,census_tra_381400 int 
 ,census_tra_381500 int 
 ,census_tra_381600 int 
 ,census_tra_381700 int 
 ,census_tra_381800 int 
 ,census_tra_381900 int 
 ,census_tra_382000 int 
 ,census_tra_390100 int 
 ,census_tra_390200 int 
 ,census_tra_390300 int 
 ,census_tra_390400 int 
 ,census_tra_390500 int 
 ,census_tra_390600 int 
 ,census_tra_390700 int 
 ,census_tra_400100 int 
 ,census_tra_400200 int 
 ,census_tra_400300 int 
 ,census_tra_400400 int 
 ,census_tra_400500 int 
 ,census_tra_400600 int 
 ,census_tra_400700 int 
 ,census_tra_400800 int 
 ,census_tra_410100 int 
 ,census_tra_410200 int 
 ,census_tra_410300 int 
 ,census_tra_410400 int 
 ,census_tra_410500 int 
 ,census_tra_410600 int 
 ,census_tra_410700 int 
 ,census_tra_410800 int 
 ,census_tra_410900 int 
 ,census_tra_411000 int 
 ,census_tra_411100 int 
 ,census_tra_411200 int 
 ,census_tra_411300 int 
 ,census_tra_411400 int 
 ,census_tra_420100 int 
 ,census_tra_420200 int 
 ,census_tra_420300 int 
 ,census_tra_420400 int 
 ,census_tra_420500 int 
 ,census_tra_420600 int 
 ,census_tra_420700 int 
 ,census_tra_420800 int 
 ,census_tra_420900 int 
 ,census_tra_421000 int 
 ,census_tra_421100 int 
 ,census_tra_421200 int 
 ,census_tra_430100 int 
 ,census_tra_430200 int 
 ,census_tra_430300 int 
 ,census_tra_430400 int 
 ,census_tra_430500 int 
 ,census_tra_430600 int 
 ,census_tra_430700 int 
 ,census_tra_430800 int 
 ,census_tra_430900 int 
 ,census_tra_431000 int 
 ,census_tra_431100 int 
 ,census_tra_431200 int 
 ,census_tra_431300 int 
 ,census_tra_431400 int 
 ,census_tra_440100 int 
 ,census_tra_440200 int 
 ,census_tra_440300 int 
 ,census_tra_440400 int 
 ,census_tra_440500 int 
 ,census_tra_440600 int 
 ,census_tra_440700 int 
 ,census_tra_440800 int 
 ,census_tra_440900 int 
 ,census_tra_450100 int 
 ,census_tra_450200 int 
 ,census_tra_450300 int 
 ,census_tra_460100 int 
 ,census_tra_460200 int 
 ,census_tra_460300 int 
 ,census_tra_460400 int 
 ,census_tra_460500 int 
 ,census_tra_460600 int 
 ,census_tra_460700 int 
 ,census_tra_460900 int 
 ,census_tra_461000 int 
 ,census_tra_470100 int 
 ,census_tra_480100 int 
 ,census_tra_480200 int 
 ,census_tra_480300 int 
 ,census_tra_480400 int 
 ,census_tra_480500 int 
 ,census_tra_490100 int 
 ,census_tra_490200 int 
 ,census_tra_490300 int 
 ,census_tra_490400 int 
 ,census_tra_490500 int 
 ,census_tra_490600 int 
 ,census_tra_490700 int 
 ,census_tra_490800 int 
 ,census_tra_490900 int 
 ,census_tra_491000 int 
 ,census_tra_491100 int 
 ,census_tra_491200 int 
 ,census_tra_491300 int 
 ,census_tra_491400 int 
 ,census_tra_500100 int 
 ,census_tra_500200 int 
 ,census_tra_500300 int 
 ,census_tra_510100 int 
 ,census_tra_510200 int 
 ,census_tra_510300 int 
 ,census_tra_510400 int 
 ,census_tra_510500 int 
 ,census_tra_520100 int 
 ,census_tra_520200 int 
 ,census_tra_520300 int 
 ,census_tra_520400 int 
 ,census_tra_520500 int 
 ,census_tra_520600 int 
 ,census_tra_530100 int 
 ,census_tra_530200 int 
 ,census_tra_530300 int 
 ,census_tra_530400 int 
 ,census_tra_530500 int 
 ,census_tra_530600 int 
 ,census_tra_540100 int 
 ,census_tra_550100 int 
 ,census_tra_550200 int 
 ,census_tra_560100 int 
 ,census_tra_560200 int 
 ,census_tra_560300 int 
 ,census_tra_560400 int 
 ,census_tra_560500 int 
 ,census_tra_560600 int 
 ,census_tra_560700 int 
 ,census_tra_560800 int 
 ,census_tra_560900 int 
 ,census_tra_561000 int 
 ,census_tra_561100 int 
 ,census_tra_561200 int 
 ,census_tra_561300 int 
 ,census_tra_570100 int 
 ,census_tra_570200 int 
 ,census_tra_570300 int 
 ,census_tra_570400 int 
 ,census_tra_570500 int 
 ,census_tra_580100 int 
 ,census_tra_580200 int 
 ,census_tra_580300 int 
 ,census_tra_580400 int 
 ,census_tra_580500 int 
 ,census_tra_580600 int 
 ,census_tra_580700 int 
 ,census_tra_580800 int 
 ,census_tra_580900 int 
 ,census_tra_581000 int 
 ,census_tra_581100 int 
 ,census_tra_590100 int 
 ,census_tra_590200 int 
 ,census_tra_590300 int 
 ,census_tra_590400 int 
 ,census_tra_590500 int 
 ,census_tra_590600 int 
 ,census_tra_590700 int 
 ,census_tra_600100 int 
 ,census_tra_600200 int 
 ,census_tra_600300 int 
 ,census_tra_600400 int 
 ,census_tra_600500 int 
 ,census_tra_600600 int 
 ,census_tra_600700 int 
 ,census_tra_600800 int 
 ,census_tra_600900 int 
 ,census_tra_601000 int 
 ,census_tra_601100 int 
 ,census_tra_601200 int 
 ,census_tra_601300 int 
 ,census_tra_601400 int 
 ,census_tra_601500 int 
 ,census_tra_601600 int 
 ,census_tra_610100 int 
 ,census_tra_610200 int 
 ,census_tra_610300 int 
 ,census_tra_610400 int 
 ,census_tra_610500 int 
 ,census_tra_610600 int 
 ,census_tra_610700 int 
 ,census_tra_610800 int 
 ,census_tra_610900 int 
 ,census_tra_611000 int 
 ,census_tra_611100 int 
 ,census_tra_611200 int 
 ,census_tra_611300 int 
 ,census_tra_611400 int 
 ,census_tra_611500 int 
 ,census_tra_611600 int 
 ,census_tra_611700 int 
 ,census_tra_611800 int 
 ,census_tra_611900 int 
 ,census_tra_612000 int 
 ,census_tra_612100 int 
 ,census_tra_612200 int 
 ,census_tra_620100 int 
 ,census_tra_620200 int 
 ,census_tra_620300 int 
 ,census_tra_620400 int 
 ,census_tra_630100 int 
 ,census_tra_630200 int 
 ,census_tra_630300 int 
 ,census_tra_630400 int 
 ,census_tra_630500 int 
 ,census_tra_630600 int 
 ,census_tra_630700 int 
 ,census_tra_630800 int 
 ,census_tra_630900 int 
 ,census_tra_640100 int 
 ,census_tra_640200 int 
 ,census_tra_640300 int 
 ,census_tra_640400 int 
 ,census_tra_640500 int 
 ,census_tra_640600 int 
 ,census_tra_640700 int 
 ,census_tra_640800 int 
 ,census_tra_650100 int 
 ,census_tra_650200 int 
 ,census_tra_650300 int 
 ,census_tra_650400 int 
 ,census_tra_650500 int 
 ,census_tra_660100 int 
 ,census_tra_660200 int 
 ,census_tra_660300 int 
 ,census_tra_660400 int 
 ,census_tra_660500 int 
 ,census_tra_660600 int 
 ,census_tra_660700 int 
 ,census_tra_660800 int 
 ,census_tra_660900 int 
 ,census_tra_661000 int 
 ,census_tra_661100 int 
 ,census_tra_670100 int 
 ,census_tra_670200 int 
 ,census_tra_670300 int 
 ,census_tra_670400 int 
 ,census_tra_670500 int 
 ,census_tra_670600 int 
 ,census_tra_670700 int 
 ,census_tra_670800 int 
 ,census_tra_670900 int 
 ,census_tra_671000 int 
 ,census_tra_671100 int 
 ,census_tra_671200 int 
 ,census_tra_671300 int 
 ,census_tra_671400 int 
 ,census_tra_671500 int 
 ,census_tra_671600 int 
 ,census_tra_671700 int 
 ,census_tra_671800 int 
 ,census_tra_671900 int 
 ,census_tra_672000 int 
 ,census_tra_680100 int 
 ,census_tra_680200 int 
 ,census_tra_680300 int 
 ,census_tra_680400 int 
 ,census_tra_680500 int 
 ,census_tra_680600 int 
 ,census_tra_680700 int 
 ,census_tra_680800 int 
 ,census_tra_680900 int 
 ,census_tra_681000 int 
 ,census_tra_681100 int 
 ,census_tra_681200 int 
 ,census_tra_681300 int 
 ,census_tra_681400 int 
 ,census_tra_690100 int 
 ,census_tra_690200 int 
 ,census_tra_690300 int 
 ,census_tra_690400 int 
 ,census_tra_690500 int 
 ,census_tra_690600 int 
 ,census_tra_690700 int 
 ,census_tra_690800 int 
 ,census_tra_690900 int 
 ,census_tra_691000 int 
 ,census_tra_691100 int 
 ,census_tra_691200 int 
 ,census_tra_691300 int 
 ,census_tra_691400 int 
 ,census_tra_691500 int 
 ,census_tra_700100 int 
 ,census_tra_700200 int 
 ,census_tra_700300 int 
 ,census_tra_700400 int 
 ,census_tra_700500 int 
 ,census_tra_710100 int 
 ,census_tra_710200 int 
 ,census_tra_710300 int 
 ,census_tra_710400 int 
 ,census_tra_710500 int 
 ,census_tra_710600 int 
 ,census_tra_710700 int 
 ,census_tra_710800 int 
 ,census_tra_710900 int 
 ,census_tra_711000 int 
 ,census_tra_711100 int 
 ,census_tra_711200 int 
 ,census_tra_711300 int 
 ,census_tra_711400 int 
 ,census_tra_711500 int 
 ,census_tra_720100 int 
 ,census_tra_720200 int 
 ,census_tra_720300 int 
 ,census_tra_720400 int 
 ,census_tra_720600 int 
 ,census_tra_720700 int 
 ,census_tra_730100 int 
 ,census_tra_730200 int 
 ,census_tra_730300 int 
 ,census_tra_730400 int 
 ,census_tra_730500 int 
 ,census_tra_730600 int 
 ,census_tra_730700 int 
 ,census_tra_740100 int 
 ,census_tra_740200 int 
 ,census_tra_740300 int 
 ,census_tra_740400 int 
 ,census_tra_750100 int 
 ,census_tra_750200 int 
 ,census_tra_750300 int 
 ,census_tra_750400 int 
 ,census_tra_750500 int 
 ,census_tra_750600 int 
 ,census_tra_760800 int 
 ,census_tra_760900 int 
 ,census_tra_770600 int 
 ,census_tra_770700 int 
 ,census_tra_770800 int 
 ,census_tra_770900 int 
 ,census_tra_808100 int 
 ,census_tra_810400 int 
 ,census_tra_810501 int 
 ,census_tra_811600 int 
 ,census_tra_820800 int 
 ,census_tra_821500 int 
 ,census_tra_823304 int 
 ,census_tra_840000 int 
 , primary key ( cell_id )); 



/*replacing this below: 
create table cell_census_tract_bins ( cell_id int
, census_tra_400100 int
, census_tra_400200 int
, census_tra_400300 int
, census_tra_400400 int
, census_tra_400500 int
, census_tra_400600 int
, census_tra_400700 int
, census_tra_400800 int
, census_tra_400900 int
, census_tra_401000 int
, census_tra_401100 int
, census_tra_401200 int
, census_tra_401300 int
, census_tra_401400 int
, census_tra_401500 int
, census_tra_401600 int
, census_tra_401700 int
, census_tra_401800 int
, census_tra_402200 int
, census_tra_402400 int
, census_tra_402500 int
, census_tra_402600 int
, census_tra_402700 int
, census_tra_402800 int
, census_tra_402900 int
, census_tra_403000 int
, census_tra_403100 int
, census_tra_403300 int
, census_tra_403400 int
, census_tra_403501 int
, census_tra_403502 int
, census_tra_403600 int
, census_tra_403701 int
, census_tra_403702 int
, census_tra_403800 int
, census_tra_403900 int
, census_tra_404000 int
, census_tra_404101 int
, census_tra_404102 int
, census_tra_404200 int
, census_tra_404300 int
, census_tra_404400 int
, census_tra_404501 int
, census_tra_404502 int
, census_tra_404600 int
, census_tra_404700 int
, census_tra_404800 int
, census_tra_404900 int
, census_tra_405000 int
, census_tra_405100 int
, census_tra_405200 int
, census_tra_405301 int
, census_tra_405302 int
, census_tra_405401 int
, census_tra_405402 int
, census_tra_405500 int
, census_tra_405600 int
, census_tra_405700 int
, census_tra_405800 int
, census_tra_405901 int
, census_tra_405902 int
, census_tra_406000 int
, census_tra_406100 int
, census_tra_406201 int
, census_tra_406202 int
, census_tra_406300 int
, census_tra_406400 int
, census_tra_406500 int
, census_tra_406601 int
, census_tra_406602 int
, census_tra_406700 int
, census_tra_406800 int
, census_tra_406900 int
, census_tra_407000 int
, census_tra_407101 int
, census_tra_407102 int
, census_tra_407200 int
, census_tra_407300 int
, census_tra_407400 int
, census_tra_407500 int
, census_tra_407600 int
, census_tra_407700 int
, census_tra_407800 int
, census_tra_407900 int
, census_tra_408000 int
, census_tra_408100 int
, census_tra_408200 int
, census_tra_408300 int
, census_tra_408400 int
, census_tra_408500 int
, census_tra_408600 int
, census_tra_408700 int
, census_tra_408800 int
, census_tra_408900 int
, census_tra_409000 int
, census_tra_409100 int
, census_tra_409200 int
, census_tra_409300 int
, census_tra_409400 int
, census_tra_409500 int
, census_tra_409600 int
, census_tra_409700 int
, census_tra_409800 int
, census_tra_409900 int
, census_tra_410000 int
, census_tra_410100 int
, census_tra_410200 int
, census_tra_410300 int
, census_tra_410400 int
, census_tra_410500 int
, census_tra_981900 int
, census_tra_982000 int
, census_tra_983200 int
, primary key ( cell_id ));

*/


insert into cell_census_tract_bins
select c.cell_id
  , max(case when ct.census_tra = '000000' then 1 else 0 end) as census_tra_000000 
 , max(case when ct.census_tra = '010200' then 1 else 0 end) as census_tra_010200 
 , max(case when ct.census_tra = '010300' then 1 else 0 end) as census_tra_010300 
 , max(case when ct.census_tra = '010400' then 1 else 0 end) as census_tra_010400 
 , max(case when ct.census_tra = '010500' then 1 else 0 end) as census_tra_010500 
 , max(case when ct.census_tra = '010600' then 1 else 0 end) as census_tra_010600 
 , max(case when ct.census_tra = '010700' then 1 else 0 end) as census_tra_010700 
 , max(case when ct.census_tra = '010800' then 1 else 0 end) as census_tra_010800 
 , max(case when ct.census_tra = '010900' then 1 else 0 end) as census_tra_010900 
 , max(case when ct.census_tra = '020100' then 1 else 0 end) as census_tra_020100 
 , max(case when ct.census_tra = '020200' then 1 else 0 end) as census_tra_020200 
 , max(case when ct.census_tra = '020300' then 1 else 0 end) as census_tra_020300 
 , max(case when ct.census_tra = '020400' then 1 else 0 end) as census_tra_020400 
 , max(case when ct.census_tra = '020500' then 1 else 0 end) as census_tra_020500 
 , max(case when ct.census_tra = '020600' then 1 else 0 end) as census_tra_020600 
 , max(case when ct.census_tra = '020700' then 1 else 0 end) as census_tra_020700 
 , max(case when ct.census_tra = '020800' then 1 else 0 end) as census_tra_020800 
 , max(case when ct.census_tra = '020900' then 1 else 0 end) as census_tra_020900 
 , max(case when ct.census_tra = '030100' then 1 else 0 end) as census_tra_030100 
 , max(case when ct.census_tra = '030200' then 1 else 0 end) as census_tra_030200 
 , max(case when ct.census_tra = '030300' then 1 else 0 end) as census_tra_030300 
 , max(case when ct.census_tra = '030400' then 1 else 0 end) as census_tra_030400 
 , max(case when ct.census_tra = '030500' then 1 else 0 end) as census_tra_030500 
 , max(case when ct.census_tra = '030600' then 1 else 0 end) as census_tra_030600 
 , max(case when ct.census_tra = '030700' then 1 else 0 end) as census_tra_030700 
 , max(case when ct.census_tra = '030800' then 1 else 0 end) as census_tra_030800 
 , max(case when ct.census_tra = '030900' then 1 else 0 end) as census_tra_030900 
 , max(case when ct.census_tra = '031000' then 1 else 0 end) as census_tra_031000 
 , max(case when ct.census_tra = '031100' then 1 else 0 end) as census_tra_031100 
 , max(case when ct.census_tra = '031200' then 1 else 0 end) as census_tra_031200 
 , max(case when ct.census_tra = '031300' then 1 else 0 end) as census_tra_031300 
 , max(case when ct.census_tra = '031400' then 1 else 0 end) as census_tra_031400 
 , max(case when ct.census_tra = '031500' then 1 else 0 end) as census_tra_031500 
 , max(case when ct.census_tra = '031600' then 1 else 0 end) as census_tra_031600 
 , max(case when ct.census_tra = '031800' then 1 else 0 end) as census_tra_031800 
 , max(case when ct.census_tra = '031900' then 1 else 0 end) as census_tra_031900 
 , max(case when ct.census_tra = '032000' then 1 else 0 end) as census_tra_032000 
 , max(case when ct.census_tra = '032100' then 1 else 0 end) as census_tra_032100 
 , max(case when ct.census_tra = '040100' then 1 else 0 end) as census_tra_040100 
 , max(case when ct.census_tra = '040200' then 1 else 0 end) as census_tra_040200 
 , max(case when ct.census_tra = '040300' then 1 else 0 end) as census_tra_040300 
 , max(case when ct.census_tra = '040400' then 1 else 0 end) as census_tra_040400 
 , max(case when ct.census_tra = '040500' then 1 else 0 end) as census_tra_040500 
 , max(case when ct.census_tra = '040600' then 1 else 0 end) as census_tra_040600 
 , max(case when ct.census_tra = '040700' then 1 else 0 end) as census_tra_040700 
 , max(case when ct.census_tra = '040800' then 1 else 0 end) as census_tra_040800 
 , max(case when ct.census_tra = '040900' then 1 else 0 end) as census_tra_040900 
 , max(case when ct.census_tra = '041000' then 1 else 0 end) as census_tra_041000 
 , max(case when ct.census_tra = '050100' then 1 else 0 end) as census_tra_050100 
 , max(case when ct.census_tra = '050200' then 1 else 0 end) as census_tra_050200 
 , max(case when ct.census_tra = '050300' then 1 else 0 end) as census_tra_050300 
 , max(case when ct.census_tra = '050400' then 1 else 0 end) as census_tra_050400 
 , max(case when ct.census_tra = '050500' then 1 else 0 end) as census_tra_050500 
 , max(case when ct.census_tra = '050600' then 1 else 0 end) as census_tra_050600 
 , max(case when ct.census_tra = '050700' then 1 else 0 end) as census_tra_050700 
 , max(case when ct.census_tra = '050800' then 1 else 0 end) as census_tra_050800 
 , max(case when ct.census_tra = '050900' then 1 else 0 end) as census_tra_050900 
 , max(case when ct.census_tra = '051000' then 1 else 0 end) as census_tra_051000 
 , max(case when ct.census_tra = '051100' then 1 else 0 end) as census_tra_051100 
 , max(case when ct.census_tra = '051200' then 1 else 0 end) as census_tra_051200 
 , max(case when ct.census_tra = '051300' then 1 else 0 end) as census_tra_051300 
 , max(case when ct.census_tra = '051400' then 1 else 0 end) as census_tra_051400 
 , max(case when ct.census_tra = '051500' then 1 else 0 end) as census_tra_051500 
 , max(case when ct.census_tra = '060100' then 1 else 0 end) as census_tra_060100 
 , max(case when ct.census_tra = '060200' then 1 else 0 end) as census_tra_060200 
 , max(case when ct.census_tra = '060300' then 1 else 0 end) as census_tra_060300 
 , max(case when ct.census_tra = '060400' then 1 else 0 end) as census_tra_060400 
 , max(case when ct.census_tra = '060500' then 1 else 0 end) as census_tra_060500 
 , max(case when ct.census_tra = '060600' then 1 else 0 end) as census_tra_060600 
 , max(case when ct.census_tra = '060700' then 1 else 0 end) as census_tra_060700 
 , max(case when ct.census_tra = '060800' then 1 else 0 end) as census_tra_060800 
 , max(case when ct.census_tra = '060900' then 1 else 0 end) as census_tra_060900 
 , max(case when ct.census_tra = '061000' then 1 else 0 end) as census_tra_061000 
 , max(case when ct.census_tra = '061100' then 1 else 0 end) as census_tra_061100 
 , max(case when ct.census_tra = '061200' then 1 else 0 end) as census_tra_061200 
 , max(case when ct.census_tra = '061300' then 1 else 0 end) as census_tra_061300 
 , max(case when ct.census_tra = '061400' then 1 else 0 end) as census_tra_061400 
 , max(case when ct.census_tra = '061500' then 1 else 0 end) as census_tra_061500 
 , max(case when ct.census_tra = '061600' then 1 else 0 end) as census_tra_061600 
 , max(case when ct.census_tra = '061700' then 1 else 0 end) as census_tra_061700 
 , max(case when ct.census_tra = '061800' then 1 else 0 end) as census_tra_061800 
 , max(case when ct.census_tra = '061900' then 1 else 0 end) as census_tra_061900 
 , max(case when ct.census_tra = '062000' then 1 else 0 end) as census_tra_062000 
 , max(case when ct.census_tra = '062100' then 1 else 0 end) as census_tra_062100 
 , max(case when ct.census_tra = '062200' then 1 else 0 end) as census_tra_062200 
 , max(case when ct.census_tra = '062300' then 1 else 0 end) as census_tra_062300 
 , max(case when ct.census_tra = '062400' then 1 else 0 end) as census_tra_062400 
 , max(case when ct.census_tra = '062500' then 1 else 0 end) as census_tra_062500 
 , max(case when ct.census_tra = '062600' then 1 else 0 end) as census_tra_062600 
 , max(case when ct.census_tra = '062700' then 1 else 0 end) as census_tra_062700 
 , max(case when ct.census_tra = '062800' then 1 else 0 end) as census_tra_062800 
 , max(case when ct.census_tra = '062900' then 1 else 0 end) as census_tra_062900 
 , max(case when ct.census_tra = '063000' then 1 else 0 end) as census_tra_063000 
 , max(case when ct.census_tra = '063100' then 1 else 0 end) as census_tra_063100 
 , max(case when ct.census_tra = '063200' then 1 else 0 end) as census_tra_063200 
 , max(case when ct.census_tra = '063300' then 1 else 0 end) as census_tra_063300 
 , max(case when ct.census_tra = '063400' then 1 else 0 end) as census_tra_063400 
 , max(case when ct.census_tra = '070100' then 1 else 0 end) as census_tra_070100 
 , max(case when ct.census_tra = '070200' then 1 else 0 end) as census_tra_070200 
 , max(case when ct.census_tra = '070300' then 1 else 0 end) as census_tra_070300 
 , max(case when ct.census_tra = '070400' then 1 else 0 end) as census_tra_070400 
 , max(case when ct.census_tra = '070500' then 1 else 0 end) as census_tra_070500 
 , max(case when ct.census_tra = '070600' then 1 else 0 end) as census_tra_070600 
 , max(case when ct.census_tra = '070700' then 1 else 0 end) as census_tra_070700 
 , max(case when ct.census_tra = '070800' then 1 else 0 end) as census_tra_070800 
 , max(case when ct.census_tra = '070900' then 1 else 0 end) as census_tra_070900 
 , max(case when ct.census_tra = '071000' then 1 else 0 end) as census_tra_071000 
 , max(case when ct.census_tra = '071100' then 1 else 0 end) as census_tra_071100 
 , max(case when ct.census_tra = '071200' then 1 else 0 end) as census_tra_071200 
 , max(case when ct.census_tra = '071300' then 1 else 0 end) as census_tra_071300 
 , max(case when ct.census_tra = '071400' then 1 else 0 end) as census_tra_071400 
 , max(case when ct.census_tra = '071500' then 1 else 0 end) as census_tra_071500 
 , max(case when ct.census_tra = '071600' then 1 else 0 end) as census_tra_071600 
 , max(case when ct.census_tra = '071700' then 1 else 0 end) as census_tra_071700 
 , max(case when ct.census_tra = '071800' then 1 else 0 end) as census_tra_071800 
 , max(case when ct.census_tra = '071900' then 1 else 0 end) as census_tra_071900 
 , max(case when ct.census_tra = '072000' then 1 else 0 end) as census_tra_072000 
 , max(case when ct.census_tra = '080100' then 1 else 0 end) as census_tra_080100 
 , max(case when ct.census_tra = '080200' then 1 else 0 end) as census_tra_080200 
 , max(case when ct.census_tra = '080300' then 1 else 0 end) as census_tra_080300 
 , max(case when ct.census_tra = '080400' then 1 else 0 end) as census_tra_080400 
 , max(case when ct.census_tra = '080500' then 1 else 0 end) as census_tra_080500 
 , max(case when ct.census_tra = '080600' then 1 else 0 end) as census_tra_080600 
 , max(case when ct.census_tra = '080700' then 1 else 0 end) as census_tra_080700 
 , max(case when ct.census_tra = '080800' then 1 else 0 end) as census_tra_080800 
 , max(case when ct.census_tra = '080900' then 1 else 0 end) as census_tra_080900 
 , max(case when ct.census_tra = '081000' then 1 else 0 end) as census_tra_081000 
 , max(case when ct.census_tra = '081100' then 1 else 0 end) as census_tra_081100 
 , max(case when ct.census_tra = '081200' then 1 else 0 end) as census_tra_081200 
 , max(case when ct.census_tra = '081300' then 1 else 0 end) as census_tra_081300 
 , max(case when ct.census_tra = '081400' then 1 else 0 end) as census_tra_081400 
 , max(case when ct.census_tra = '081500' then 1 else 0 end) as census_tra_081500 
 , max(case when ct.census_tra = '081600' then 1 else 0 end) as census_tra_081600 
 , max(case when ct.census_tra = '081700' then 1 else 0 end) as census_tra_081700 
 , max(case when ct.census_tra = '081800' then 1 else 0 end) as census_tra_081800 
 , max(case when ct.census_tra = '081900' then 1 else 0 end) as census_tra_081900 
 , max(case when ct.census_tra = '090100' then 1 else 0 end) as census_tra_090100 
 , max(case when ct.census_tra = '090200' then 1 else 0 end) as census_tra_090200 
 , max(case when ct.census_tra = '090300' then 1 else 0 end) as census_tra_090300 
 , max(case when ct.census_tra = '100100' then 1 else 0 end) as census_tra_100100 
 , max(case when ct.census_tra = '100200' then 1 else 0 end) as census_tra_100200 
 , max(case when ct.census_tra = '100300' then 1 else 0 end) as census_tra_100300 
 , max(case when ct.census_tra = '100400' then 1 else 0 end) as census_tra_100400 
 , max(case when ct.census_tra = '100500' then 1 else 0 end) as census_tra_100500 
 , max(case when ct.census_tra = '100600' then 1 else 0 end) as census_tra_100600 
 , max(case when ct.census_tra = '100700' then 1 else 0 end) as census_tra_100700 
 , max(case when ct.census_tra = '110100' then 1 else 0 end) as census_tra_110100 
 , max(case when ct.census_tra = '110200' then 1 else 0 end) as census_tra_110200 
 , max(case when ct.census_tra = '110300' then 1 else 0 end) as census_tra_110300 
 , max(case when ct.census_tra = '110400' then 1 else 0 end) as census_tra_110400 
 , max(case when ct.census_tra = '110500' then 1 else 0 end) as census_tra_110500 
 , max(case when ct.census_tra = '120100' then 1 else 0 end) as census_tra_120100 
 , max(case when ct.census_tra = '120200' then 1 else 0 end) as census_tra_120200 
 , max(case when ct.census_tra = '120300' then 1 else 0 end) as census_tra_120300 
 , max(case when ct.census_tra = '120400' then 1 else 0 end) as census_tra_120400 
 , max(case when ct.census_tra = '130100' then 1 else 0 end) as census_tra_130100 
 , max(case when ct.census_tra = '130200' then 1 else 0 end) as census_tra_130200 
 , max(case when ct.census_tra = '130300' then 1 else 0 end) as census_tra_130300 
 , max(case when ct.census_tra = '130400' then 1 else 0 end) as census_tra_130400 
 , max(case when ct.census_tra = '130500' then 1 else 0 end) as census_tra_130500 
 , max(case when ct.census_tra = '140100' then 1 else 0 end) as census_tra_140100 
 , max(case when ct.census_tra = '140200' then 1 else 0 end) as census_tra_140200 
 , max(case when ct.census_tra = '140300' then 1 else 0 end) as census_tra_140300 
 , max(case when ct.census_tra = '140400' then 1 else 0 end) as census_tra_140400 
 , max(case when ct.census_tra = '140500' then 1 else 0 end) as census_tra_140500 
 , max(case when ct.census_tra = '140600' then 1 else 0 end) as census_tra_140600 
 , max(case when ct.census_tra = '140700' then 1 else 0 end) as census_tra_140700 
 , max(case when ct.census_tra = '140800' then 1 else 0 end) as census_tra_140800 
 , max(case when ct.census_tra = '150100' then 1 else 0 end) as census_tra_150100 
 , max(case when ct.census_tra = '150200' then 1 else 0 end) as census_tra_150200 
 , max(case when ct.census_tra = '150300' then 1 else 0 end) as census_tra_150300 
 , max(case when ct.census_tra = '150400' then 1 else 0 end) as census_tra_150400 
 , max(case when ct.census_tra = '150500' then 1 else 0 end) as census_tra_150500 
 , max(case when ct.census_tra = '150600' then 1 else 0 end) as census_tra_150600 
 , max(case when ct.census_tra = '150700' then 1 else 0 end) as census_tra_150700 
 , max(case when ct.census_tra = '150800' then 1 else 0 end) as census_tra_150800 
 , max(case when ct.census_tra = '150900' then 1 else 0 end) as census_tra_150900 
 , max(case when ct.census_tra = '151000' then 1 else 0 end) as census_tra_151000 
 , max(case when ct.census_tra = '151100' then 1 else 0 end) as census_tra_151100 
 , max(case when ct.census_tra = '151200' then 1 else 0 end) as census_tra_151200 
 , max(case when ct.census_tra = '160100' then 1 else 0 end) as census_tra_160100 
 , max(case when ct.census_tra = '160200' then 1 else 0 end) as census_tra_160200 
 , max(case when ct.census_tra = '160300' then 1 else 0 end) as census_tra_160300 
 , max(case when ct.census_tra = '160400' then 1 else 0 end) as census_tra_160400 
 , max(case when ct.census_tra = '160500' then 1 else 0 end) as census_tra_160500 
 , max(case when ct.census_tra = '160600' then 1 else 0 end) as census_tra_160600 
 , max(case when ct.census_tra = '160700' then 1 else 0 end) as census_tra_160700 
 , max(case when ct.census_tra = '160800' then 1 else 0 end) as census_tra_160800 
 , max(case when ct.census_tra = '160900' then 1 else 0 end) as census_tra_160900 
 , max(case when ct.census_tra = '161000' then 1 else 0 end) as census_tra_161000 
 , max(case when ct.census_tra = '161100' then 1 else 0 end) as census_tra_161100 
 , max(case when ct.census_tra = '161200' then 1 else 0 end) as census_tra_161200 
 , max(case when ct.census_tra = '161300' then 1 else 0 end) as census_tra_161300 
 , max(case when ct.census_tra = '170100' then 1 else 0 end) as census_tra_170100 
 , max(case when ct.census_tra = '170200' then 1 else 0 end) as census_tra_170200 
 , max(case when ct.census_tra = '170300' then 1 else 0 end) as census_tra_170300 
 , max(case when ct.census_tra = '170400' then 1 else 0 end) as census_tra_170400 
 , max(case when ct.census_tra = '170500' then 1 else 0 end) as census_tra_170500 
 , max(case when ct.census_tra = '170600' then 1 else 0 end) as census_tra_170600 
 , max(case when ct.census_tra = '170700' then 1 else 0 end) as census_tra_170700 
 , max(case when ct.census_tra = '170800' then 1 else 0 end) as census_tra_170800 
 , max(case when ct.census_tra = '170900' then 1 else 0 end) as census_tra_170900 
 , max(case when ct.census_tra = '171000' then 1 else 0 end) as census_tra_171000 
 , max(case when ct.census_tra = '171100' then 1 else 0 end) as census_tra_171100 
 , max(case when ct.census_tra = '180100' then 1 else 0 end) as census_tra_180100 
 , max(case when ct.census_tra = '180200' then 1 else 0 end) as census_tra_180200 
 , max(case when ct.census_tra = '180300' then 1 else 0 end) as census_tra_180300 
 , max(case when ct.census_tra = '190100' then 1 else 0 end) as census_tra_190100 
 , max(case when ct.census_tra = '190200' then 1 else 0 end) as census_tra_190200 
 , max(case when ct.census_tra = '190300' then 1 else 0 end) as census_tra_190300 
 , max(case when ct.census_tra = '190400' then 1 else 0 end) as census_tra_190400 
 , max(case when ct.census_tra = '190500' then 1 else 0 end) as census_tra_190500 
 , max(case when ct.census_tra = '190600' then 1 else 0 end) as census_tra_190600 
 , max(case when ct.census_tra = '190700' then 1 else 0 end) as census_tra_190700 
 , max(case when ct.census_tra = '190800' then 1 else 0 end) as census_tra_190800 
 , max(case when ct.census_tra = '190900' then 1 else 0 end) as census_tra_190900 
 , max(case when ct.census_tra = '191000' then 1 else 0 end) as census_tra_191000 
 , max(case when ct.census_tra = '191100' then 1 else 0 end) as census_tra_191100 
 , max(case when ct.census_tra = '191200' then 1 else 0 end) as census_tra_191200 
 , max(case when ct.census_tra = '191400' then 1 else 0 end) as census_tra_191400 
 , max(case when ct.census_tra = '200100' then 1 else 0 end) as census_tra_200100 
 , max(case when ct.census_tra = '200200' then 1 else 0 end) as census_tra_200200 
 , max(case when ct.census_tra = '200300' then 1 else 0 end) as census_tra_200300 
 , max(case when ct.census_tra = '200400' then 1 else 0 end) as census_tra_200400 
 , max(case when ct.census_tra = '200500' then 1 else 0 end) as census_tra_200500 
 , max(case when ct.census_tra = '200600' then 1 else 0 end) as census_tra_200600 
 , max(case when ct.census_tra = '210100' then 1 else 0 end) as census_tra_210100 
 , max(case when ct.census_tra = '210200' then 1 else 0 end) as census_tra_210200 
 , max(case when ct.census_tra = '210300' then 1 else 0 end) as census_tra_210300 
 , max(case when ct.census_tra = '210400' then 1 else 0 end) as census_tra_210400 
 , max(case when ct.census_tra = '210500' then 1 else 0 end) as census_tra_210500 
 , max(case when ct.census_tra = '210600' then 1 else 0 end) as census_tra_210600 
 , max(case when ct.census_tra = '210700' then 1 else 0 end) as census_tra_210700 
 , max(case when ct.census_tra = '210800' then 1 else 0 end) as census_tra_210800 
 , max(case when ct.census_tra = '210900' then 1 else 0 end) as census_tra_210900 
 , max(case when ct.census_tra = '220100' then 1 else 0 end) as census_tra_220100 
 , max(case when ct.census_tra = '220200' then 1 else 0 end) as census_tra_220200 
 , max(case when ct.census_tra = '220300' then 1 else 0 end) as census_tra_220300 
 , max(case when ct.census_tra = '220400' then 1 else 0 end) as census_tra_220400 
 , max(case when ct.census_tra = '220500' then 1 else 0 end) as census_tra_220500 
 , max(case when ct.census_tra = '220600' then 1 else 0 end) as census_tra_220600 
 , max(case when ct.census_tra = '220700' then 1 else 0 end) as census_tra_220700 
 , max(case when ct.census_tra = '220800' then 1 else 0 end) as census_tra_220800 
 , max(case when ct.census_tra = '220900' then 1 else 0 end) as census_tra_220900 
 , max(case when ct.census_tra = '221000' then 1 else 0 end) as census_tra_221000 
 , max(case when ct.census_tra = '221100' then 1 else 0 end) as census_tra_221100 
 , max(case when ct.census_tra = '221200' then 1 else 0 end) as census_tra_221200 
 , max(case when ct.census_tra = '221300' then 1 else 0 end) as census_tra_221300 
 , max(case when ct.census_tra = '221400' then 1 else 0 end) as census_tra_221400 
 , max(case when ct.census_tra = '221500' then 1 else 0 end) as census_tra_221500 
 , max(case when ct.census_tra = '221600' then 1 else 0 end) as census_tra_221600 
 , max(case when ct.census_tra = '221700' then 1 else 0 end) as census_tra_221700 
 , max(case when ct.census_tra = '221800' then 1 else 0 end) as census_tra_221800 
 , max(case when ct.census_tra = '221900' then 1 else 0 end) as census_tra_221900 
 , max(case when ct.census_tra = '222000' then 1 else 0 end) as census_tra_222000 
 , max(case when ct.census_tra = '222100' then 1 else 0 end) as census_tra_222100 
 , max(case when ct.census_tra = '222200' then 1 else 0 end) as census_tra_222200 
 , max(case when ct.census_tra = '222300' then 1 else 0 end) as census_tra_222300 
 , max(case when ct.census_tra = '222400' then 1 else 0 end) as census_tra_222400 
 , max(case when ct.census_tra = '222500' then 1 else 0 end) as census_tra_222500 
 , max(case when ct.census_tra = '222600' then 1 else 0 end) as census_tra_222600 
 , max(case when ct.census_tra = '222700' then 1 else 0 end) as census_tra_222700 
 , max(case when ct.census_tra = '222800' then 1 else 0 end) as census_tra_222800 
 , max(case when ct.census_tra = '222900' then 1 else 0 end) as census_tra_222900 
 , max(case when ct.census_tra = '230100' then 1 else 0 end) as census_tra_230100 
 , max(case when ct.census_tra = '230200' then 1 else 0 end) as census_tra_230200 
 , max(case when ct.census_tra = '230300' then 1 else 0 end) as census_tra_230300 
 , max(case when ct.census_tra = '230400' then 1 else 0 end) as census_tra_230400 
 , max(case when ct.census_tra = '230500' then 1 else 0 end) as census_tra_230500 
 , max(case when ct.census_tra = '230600' then 1 else 0 end) as census_tra_230600 
 , max(case when ct.census_tra = '230700' then 1 else 0 end) as census_tra_230700 
 , max(case when ct.census_tra = '230800' then 1 else 0 end) as census_tra_230800 
 , max(case when ct.census_tra = '230900' then 1 else 0 end) as census_tra_230900 
 , max(case when ct.census_tra = '231000' then 1 else 0 end) as census_tra_231000 
 , max(case when ct.census_tra = '231100' then 1 else 0 end) as census_tra_231100 
 , max(case when ct.census_tra = '231200' then 1 else 0 end) as census_tra_231200 
 , max(case when ct.census_tra = '231300' then 1 else 0 end) as census_tra_231300 
 , max(case when ct.census_tra = '231400' then 1 else 0 end) as census_tra_231400 
 , max(case when ct.census_tra = '231500' then 1 else 0 end) as census_tra_231500 
 , max(case when ct.census_tra = '231600' then 1 else 0 end) as census_tra_231600 
 , max(case when ct.census_tra = '231700' then 1 else 0 end) as census_tra_231700 
 , max(case when ct.census_tra = '231800' then 1 else 0 end) as census_tra_231800 
 , max(case when ct.census_tra = '240100' then 1 else 0 end) as census_tra_240100 
 , max(case when ct.census_tra = '240200' then 1 else 0 end) as census_tra_240200 
 , max(case when ct.census_tra = '240300' then 1 else 0 end) as census_tra_240300 
 , max(case when ct.census_tra = '240400' then 1 else 0 end) as census_tra_240400 
 , max(case when ct.census_tra = '240500' then 1 else 0 end) as census_tra_240500 
 , max(case when ct.census_tra = '240600' then 1 else 0 end) as census_tra_240600 
 , max(case when ct.census_tra = '240700' then 1 else 0 end) as census_tra_240700 
 , max(case when ct.census_tra = '240800' then 1 else 0 end) as census_tra_240800 
 , max(case when ct.census_tra = '240900' then 1 else 0 end) as census_tra_240900 
 , max(case when ct.census_tra = '241000' then 1 else 0 end) as census_tra_241000 
 , max(case when ct.census_tra = '241100' then 1 else 0 end) as census_tra_241100 
 , max(case when ct.census_tra = '241200' then 1 else 0 end) as census_tra_241200 
 , max(case when ct.census_tra = '241300' then 1 else 0 end) as census_tra_241300 
 , max(case when ct.census_tra = '241400' then 1 else 0 end) as census_tra_241400 
 , max(case when ct.census_tra = '241500' then 1 else 0 end) as census_tra_241500 
 , max(case when ct.census_tra = '241600' then 1 else 0 end) as census_tra_241600 
 , max(case when ct.census_tra = '241700' then 1 else 0 end) as census_tra_241700 
 , max(case when ct.census_tra = '241800' then 1 else 0 end) as census_tra_241800 
 , max(case when ct.census_tra = '241900' then 1 else 0 end) as census_tra_241900 
 , max(case when ct.census_tra = '242000' then 1 else 0 end) as census_tra_242000 
 , max(case when ct.census_tra = '242100' then 1 else 0 end) as census_tra_242100 
 , max(case when ct.census_tra = '242200' then 1 else 0 end) as census_tra_242200 
 , max(case when ct.census_tra = '242300' then 1 else 0 end) as census_tra_242300 
 , max(case when ct.census_tra = '242400' then 1 else 0 end) as census_tra_242400 
 , max(case when ct.census_tra = '242500' then 1 else 0 end) as census_tra_242500 
 , max(case when ct.census_tra = '242600' then 1 else 0 end) as census_tra_242600 
 , max(case when ct.census_tra = '242700' then 1 else 0 end) as census_tra_242700 
 , max(case when ct.census_tra = '242800' then 1 else 0 end) as census_tra_242800 
 , max(case when ct.census_tra = '242900' then 1 else 0 end) as census_tra_242900 
 , max(case when ct.census_tra = '243000' then 1 else 0 end) as census_tra_243000 
 , max(case when ct.census_tra = '243100' then 1 else 0 end) as census_tra_243100 
 , max(case when ct.census_tra = '243200' then 1 else 0 end) as census_tra_243200 
 , max(case when ct.census_tra = '243300' then 1 else 0 end) as census_tra_243300 
 , max(case when ct.census_tra = '243400' then 1 else 0 end) as census_tra_243400 
 , max(case when ct.census_tra = '243500' then 1 else 0 end) as census_tra_243500 
 , max(case when ct.census_tra = '243600' then 1 else 0 end) as census_tra_243600 
 , max(case when ct.census_tra = '250100' then 1 else 0 end) as census_tra_250100 
 , max(case when ct.census_tra = '250200' then 1 else 0 end) as census_tra_250200 
 , max(case when ct.census_tra = '250300' then 1 else 0 end) as census_tra_250300 
 , max(case when ct.census_tra = '250400' then 1 else 0 end) as census_tra_250400 
 , max(case when ct.census_tra = '250500' then 1 else 0 end) as census_tra_250500 
 , max(case when ct.census_tra = '250600' then 1 else 0 end) as census_tra_250600 
 , max(case when ct.census_tra = '250700' then 1 else 0 end) as census_tra_250700 
 , max(case when ct.census_tra = '250800' then 1 else 0 end) as census_tra_250800 
 , max(case when ct.census_tra = '250900' then 1 else 0 end) as census_tra_250900 
 , max(case when ct.census_tra = '251000' then 1 else 0 end) as census_tra_251000 
 , max(case when ct.census_tra = '251200' then 1 else 0 end) as census_tra_251200 
 , max(case when ct.census_tra = '251300' then 1 else 0 end) as census_tra_251300 
 , max(case when ct.census_tra = '251400' then 1 else 0 end) as census_tra_251400 
 , max(case when ct.census_tra = '251500' then 1 else 0 end) as census_tra_251500 
 , max(case when ct.census_tra = '251600' then 1 else 0 end) as census_tra_251600 
 , max(case when ct.census_tra = '251700' then 1 else 0 end) as census_tra_251700 
 , max(case when ct.census_tra = '251800' then 1 else 0 end) as census_tra_251800 
 , max(case when ct.census_tra = '251900' then 1 else 0 end) as census_tra_251900 
 , max(case when ct.census_tra = '252000' then 1 else 0 end) as census_tra_252000 
 , max(case when ct.census_tra = '252100' then 1 else 0 end) as census_tra_252100 
 , max(case when ct.census_tra = '252200' then 1 else 0 end) as census_tra_252200 
 , max(case when ct.census_tra = '252300' then 1 else 0 end) as census_tra_252300 
 , max(case when ct.census_tra = '252400' then 1 else 0 end) as census_tra_252400 
 , max(case when ct.census_tra = '260100' then 1 else 0 end) as census_tra_260100 
 , max(case when ct.census_tra = '260200' then 1 else 0 end) as census_tra_260200 
 , max(case when ct.census_tra = '260300' then 1 else 0 end) as census_tra_260300 
 , max(case when ct.census_tra = '260400' then 1 else 0 end) as census_tra_260400 
 , max(case when ct.census_tra = '260500' then 1 else 0 end) as census_tra_260500 
 , max(case when ct.census_tra = '260600' then 1 else 0 end) as census_tra_260600 
 , max(case when ct.census_tra = '260700' then 1 else 0 end) as census_tra_260700 
 , max(case when ct.census_tra = '260800' then 1 else 0 end) as census_tra_260800 
 , max(case when ct.census_tra = '260900' then 1 else 0 end) as census_tra_260900 
 , max(case when ct.census_tra = '261000' then 1 else 0 end) as census_tra_261000 
 , max(case when ct.census_tra = '270100' then 1 else 0 end) as census_tra_270100 
 , max(case when ct.census_tra = '270200' then 1 else 0 end) as census_tra_270200 
 , max(case when ct.census_tra = '270300' then 1 else 0 end) as census_tra_270300 
 , max(case when ct.census_tra = '270400' then 1 else 0 end) as census_tra_270400 
 , max(case when ct.census_tra = '270500' then 1 else 0 end) as census_tra_270500 
 , max(case when ct.census_tra = '270600' then 1 else 0 end) as census_tra_270600 
 , max(case when ct.census_tra = '270700' then 1 else 0 end) as census_tra_270700 
 , max(case when ct.census_tra = '270800' then 1 else 0 end) as census_tra_270800 
 , max(case when ct.census_tra = '270900' then 1 else 0 end) as census_tra_270900 
 , max(case when ct.census_tra = '271000' then 1 else 0 end) as census_tra_271000 
 , max(case when ct.census_tra = '271100' then 1 else 0 end) as census_tra_271100 
 , max(case when ct.census_tra = '271200' then 1 else 0 end) as census_tra_271200 
 , max(case when ct.census_tra = '271300' then 1 else 0 end) as census_tra_271300 
 , max(case when ct.census_tra = '271400' then 1 else 0 end) as census_tra_271400 
 , max(case when ct.census_tra = '271500' then 1 else 0 end) as census_tra_271500 
 , max(case when ct.census_tra = '271600' then 1 else 0 end) as census_tra_271600 
 , max(case when ct.census_tra = '271700' then 1 else 0 end) as census_tra_271700 
 , max(case when ct.census_tra = '271800' then 1 else 0 end) as census_tra_271800 
 , max(case when ct.census_tra = '271900' then 1 else 0 end) as census_tra_271900 
 , max(case when ct.census_tra = '280100' then 1 else 0 end) as census_tra_280100 
 , max(case when ct.census_tra = '280200' then 1 else 0 end) as census_tra_280200 
 , max(case when ct.census_tra = '280300' then 1 else 0 end) as census_tra_280300 
 , max(case when ct.census_tra = '280400' then 1 else 0 end) as census_tra_280400 
 , max(case when ct.census_tra = '280500' then 1 else 0 end) as census_tra_280500 
 , max(case when ct.census_tra = '280600' then 1 else 0 end) as census_tra_280600 
 , max(case when ct.census_tra = '280700' then 1 else 0 end) as census_tra_280700 
 , max(case when ct.census_tra = '280800' then 1 else 0 end) as census_tra_280800 
 , max(case when ct.census_tra = '280900' then 1 else 0 end) as census_tra_280900 
 , max(case when ct.census_tra = '281000' then 1 else 0 end) as census_tra_281000 
 , max(case when ct.census_tra = '281100' then 1 else 0 end) as census_tra_281100 
 , max(case when ct.census_tra = '281200' then 1 else 0 end) as census_tra_281200 
 , max(case when ct.census_tra = '281300' then 1 else 0 end) as census_tra_281300 
 , max(case when ct.census_tra = '281400' then 1 else 0 end) as census_tra_281400 
 , max(case when ct.census_tra = '281500' then 1 else 0 end) as census_tra_281500 
 , max(case when ct.census_tra = '281600' then 1 else 0 end) as census_tra_281600 
 , max(case when ct.census_tra = '281700' then 1 else 0 end) as census_tra_281700 
 , max(case when ct.census_tra = '281800' then 1 else 0 end) as census_tra_281800 
 , max(case when ct.census_tra = '281900' then 1 else 0 end) as census_tra_281900 
 , max(case when ct.census_tra = '282000' then 1 else 0 end) as census_tra_282000 
 , max(case when ct.census_tra = '282100' then 1 else 0 end) as census_tra_282100 
 , max(case when ct.census_tra = '282200' then 1 else 0 end) as census_tra_282200 
 , max(case when ct.census_tra = '282300' then 1 else 0 end) as census_tra_282300 
 , max(case when ct.census_tra = '282400' then 1 else 0 end) as census_tra_282400 
 , max(case when ct.census_tra = '282500' then 1 else 0 end) as census_tra_282500 
 , max(case when ct.census_tra = '282600' then 1 else 0 end) as census_tra_282600 
 , max(case when ct.census_tra = '282700' then 1 else 0 end) as census_tra_282700 
 , max(case when ct.census_tra = '282800' then 1 else 0 end) as census_tra_282800 
 , max(case when ct.census_tra = '282900' then 1 else 0 end) as census_tra_282900 
 , max(case when ct.census_tra = '283000' then 1 else 0 end) as census_tra_283000 
 , max(case when ct.census_tra = '283100' then 1 else 0 end) as census_tra_283100 
 , max(case when ct.census_tra = '283200' then 1 else 0 end) as census_tra_283200 
 , max(case when ct.census_tra = '283300' then 1 else 0 end) as census_tra_283300 
 , max(case when ct.census_tra = '283400' then 1 else 0 end) as census_tra_283400 
 , max(case when ct.census_tra = '283500' then 1 else 0 end) as census_tra_283500 
 , max(case when ct.census_tra = '283600' then 1 else 0 end) as census_tra_283600 
 , max(case when ct.census_tra = '283700' then 1 else 0 end) as census_tra_283700 
 , max(case when ct.census_tra = '283800' then 1 else 0 end) as census_tra_283800 
 , max(case when ct.census_tra = '283900' then 1 else 0 end) as census_tra_283900 
 , max(case when ct.census_tra = '284000' then 1 else 0 end) as census_tra_284000 
 , max(case when ct.census_tra = '284100' then 1 else 0 end) as census_tra_284100 
 , max(case when ct.census_tra = '284200' then 1 else 0 end) as census_tra_284200 
 , max(case when ct.census_tra = '284300' then 1 else 0 end) as census_tra_284300 
 , max(case when ct.census_tra = '290100' then 1 else 0 end) as census_tra_290100 
 , max(case when ct.census_tra = '290200' then 1 else 0 end) as census_tra_290200 
 , max(case when ct.census_tra = '290300' then 1 else 0 end) as census_tra_290300 
 , max(case when ct.census_tra = '290400' then 1 else 0 end) as census_tra_290400 
 , max(case when ct.census_tra = '290500' then 1 else 0 end) as census_tra_290500 
 , max(case when ct.census_tra = '290600' then 1 else 0 end) as census_tra_290600 
 , max(case when ct.census_tra = '290700' then 1 else 0 end) as census_tra_290700 
 , max(case when ct.census_tra = '290800' then 1 else 0 end) as census_tra_290800 
 , max(case when ct.census_tra = '290900' then 1 else 0 end) as census_tra_290900 
 , max(case when ct.census_tra = '291000' then 1 else 0 end) as census_tra_291000 
 , max(case when ct.census_tra = '291100' then 1 else 0 end) as census_tra_291100 
 , max(case when ct.census_tra = '291200' then 1 else 0 end) as census_tra_291200 
 , max(case when ct.census_tra = '291300' then 1 else 0 end) as census_tra_291300 
 , max(case when ct.census_tra = '291400' then 1 else 0 end) as census_tra_291400 
 , max(case when ct.census_tra = '291500' then 1 else 0 end) as census_tra_291500 
 , max(case when ct.census_tra = '291600' then 1 else 0 end) as census_tra_291600 
 , max(case when ct.census_tra = '291700' then 1 else 0 end) as census_tra_291700 
 , max(case when ct.census_tra = '291800' then 1 else 0 end) as census_tra_291800 
 , max(case when ct.census_tra = '291900' then 1 else 0 end) as census_tra_291900 
 , max(case when ct.census_tra = '292000' then 1 else 0 end) as census_tra_292000 
 , max(case when ct.census_tra = '292100' then 1 else 0 end) as census_tra_292100 
 , max(case when ct.census_tra = '292200' then 1 else 0 end) as census_tra_292200 
 , max(case when ct.census_tra = '292300' then 1 else 0 end) as census_tra_292300 
 , max(case when ct.census_tra = '292400' then 1 else 0 end) as census_tra_292400 
 , max(case when ct.census_tra = '292500' then 1 else 0 end) as census_tra_292500 
 , max(case when ct.census_tra = '292600' then 1 else 0 end) as census_tra_292600 
 , max(case when ct.census_tra = '292700' then 1 else 0 end) as census_tra_292700 
 , max(case when ct.census_tra = '300100' then 1 else 0 end) as census_tra_300100 
 , max(case when ct.census_tra = '300200' then 1 else 0 end) as census_tra_300200 
 , max(case when ct.census_tra = '300300' then 1 else 0 end) as census_tra_300300 
 , max(case when ct.census_tra = '300400' then 1 else 0 end) as census_tra_300400 
 , max(case when ct.census_tra = '300500' then 1 else 0 end) as census_tra_300500 
 , max(case when ct.census_tra = '300600' then 1 else 0 end) as census_tra_300600 
 , max(case when ct.census_tra = '300700' then 1 else 0 end) as census_tra_300700 
 , max(case when ct.census_tra = '300800' then 1 else 0 end) as census_tra_300800 
 , max(case when ct.census_tra = '300900' then 1 else 0 end) as census_tra_300900 
 , max(case when ct.census_tra = '301000' then 1 else 0 end) as census_tra_301000 
 , max(case when ct.census_tra = '301100' then 1 else 0 end) as census_tra_301100 
 , max(case when ct.census_tra = '301200' then 1 else 0 end) as census_tra_301200 
 , max(case when ct.census_tra = '301300' then 1 else 0 end) as census_tra_301300 
 , max(case when ct.census_tra = '301400' then 1 else 0 end) as census_tra_301400 
 , max(case when ct.census_tra = '301500' then 1 else 0 end) as census_tra_301500 
 , max(case when ct.census_tra = '301600' then 1 else 0 end) as census_tra_301600 
 , max(case when ct.census_tra = '301700' then 1 else 0 end) as census_tra_301700 
 , max(case when ct.census_tra = '301800' then 1 else 0 end) as census_tra_301800 
 , max(case when ct.census_tra = '301900' then 1 else 0 end) as census_tra_301900 
 , max(case when ct.census_tra = '302000' then 1 else 0 end) as census_tra_302000 
 , max(case when ct.census_tra = '310100' then 1 else 0 end) as census_tra_310100 
 , max(case when ct.census_tra = '310200' then 1 else 0 end) as census_tra_310200 
 , max(case when ct.census_tra = '310300' then 1 else 0 end) as census_tra_310300 
 , max(case when ct.census_tra = '310400' then 1 else 0 end) as census_tra_310400 
 , max(case when ct.census_tra = '310500' then 1 else 0 end) as census_tra_310500 
 , max(case when ct.census_tra = '310600' then 1 else 0 end) as census_tra_310600 
 , max(case when ct.census_tra = '310700' then 1 else 0 end) as census_tra_310700 
 , max(case when ct.census_tra = '310800' then 1 else 0 end) as census_tra_310800 
 , max(case when ct.census_tra = '310900' then 1 else 0 end) as census_tra_310900 
 , max(case when ct.census_tra = '311000' then 1 else 0 end) as census_tra_311000 
 , max(case when ct.census_tra = '311100' then 1 else 0 end) as census_tra_311100 
 , max(case when ct.census_tra = '311200' then 1 else 0 end) as census_tra_311200 
 , max(case when ct.census_tra = '311300' then 1 else 0 end) as census_tra_311300 
 , max(case when ct.census_tra = '311400' then 1 else 0 end) as census_tra_311400 
 , max(case when ct.census_tra = '311500' then 1 else 0 end) as census_tra_311500 
 , max(case when ct.census_tra = '320100' then 1 else 0 end) as census_tra_320100 
 , max(case when ct.census_tra = '320200' then 1 else 0 end) as census_tra_320200 
 , max(case when ct.census_tra = '320300' then 1 else 0 end) as census_tra_320300 
 , max(case when ct.census_tra = '320400' then 1 else 0 end) as census_tra_320400 
 , max(case when ct.census_tra = '320500' then 1 else 0 end) as census_tra_320500 
 , max(case when ct.census_tra = '320600' then 1 else 0 end) as census_tra_320600 
 , max(case when ct.census_tra = '330100' then 1 else 0 end) as census_tra_330100 
 , max(case when ct.census_tra = '330200' then 1 else 0 end) as census_tra_330200 
 , max(case when ct.census_tra = '330300' then 1 else 0 end) as census_tra_330300 
 , max(case when ct.census_tra = '330400' then 1 else 0 end) as census_tra_330400 
 , max(case when ct.census_tra = '330500' then 1 else 0 end) as census_tra_330500 
 , max(case when ct.census_tra = '340100' then 1 else 0 end) as census_tra_340100 
 , max(case when ct.census_tra = '340200' then 1 else 0 end) as census_tra_340200 
 , max(case when ct.census_tra = '340300' then 1 else 0 end) as census_tra_340300 
 , max(case when ct.census_tra = '340400' then 1 else 0 end) as census_tra_340400 
 , max(case when ct.census_tra = '340500' then 1 else 0 end) as census_tra_340500 
 , max(case when ct.census_tra = '340600' then 1 else 0 end) as census_tra_340600 
 , max(case when ct.census_tra = '350100' then 1 else 0 end) as census_tra_350100 
 , max(case when ct.census_tra = '350200' then 1 else 0 end) as census_tra_350200 
 , max(case when ct.census_tra = '350300' then 1 else 0 end) as census_tra_350300 
 , max(case when ct.census_tra = '350400' then 1 else 0 end) as census_tra_350400 
 , max(case when ct.census_tra = '350500' then 1 else 0 end) as census_tra_350500 
 , max(case when ct.census_tra = '350600' then 1 else 0 end) as census_tra_350600 
 , max(case when ct.census_tra = '350700' then 1 else 0 end) as census_tra_350700 
 , max(case when ct.census_tra = '350800' then 1 else 0 end) as census_tra_350800 
 , max(case when ct.census_tra = '350900' then 1 else 0 end) as census_tra_350900 
 , max(case when ct.census_tra = '351000' then 1 else 0 end) as census_tra_351000 
 , max(case when ct.census_tra = '351100' then 1 else 0 end) as census_tra_351100 
 , max(case when ct.census_tra = '351200' then 1 else 0 end) as census_tra_351200 
 , max(case when ct.census_tra = '351300' then 1 else 0 end) as census_tra_351300 
 , max(case when ct.census_tra = '351400' then 1 else 0 end) as census_tra_351400 
 , max(case when ct.census_tra = '351500' then 1 else 0 end) as census_tra_351500 
 , max(case when ct.census_tra = '360100' then 1 else 0 end) as census_tra_360100 
 , max(case when ct.census_tra = '360200' then 1 else 0 end) as census_tra_360200 
 , max(case when ct.census_tra = '360300' then 1 else 0 end) as census_tra_360300 
 , max(case when ct.census_tra = '360400' then 1 else 0 end) as census_tra_360400 
 , max(case when ct.census_tra = '360500' then 1 else 0 end) as census_tra_360500 
 , max(case when ct.census_tra = '370100' then 1 else 0 end) as census_tra_370100 
 , max(case when ct.census_tra = '370200' then 1 else 0 end) as census_tra_370200 
 , max(case when ct.census_tra = '370300' then 1 else 0 end) as census_tra_370300 
 , max(case when ct.census_tra = '370400' then 1 else 0 end) as census_tra_370400 
 , max(case when ct.census_tra = '380100' then 1 else 0 end) as census_tra_380100 
 , max(case when ct.census_tra = '380200' then 1 else 0 end) as census_tra_380200 
 , max(case when ct.census_tra = '380300' then 1 else 0 end) as census_tra_380300 
 , max(case when ct.census_tra = '380400' then 1 else 0 end) as census_tra_380400 
 , max(case when ct.census_tra = '380500' then 1 else 0 end) as census_tra_380500 
 , max(case when ct.census_tra = '380600' then 1 else 0 end) as census_tra_380600 
 , max(case when ct.census_tra = '380700' then 1 else 0 end) as census_tra_380700 
 , max(case when ct.census_tra = '380800' then 1 else 0 end) as census_tra_380800 
 , max(case when ct.census_tra = '380900' then 1 else 0 end) as census_tra_380900 
 , max(case when ct.census_tra = '381000' then 1 else 0 end) as census_tra_381000 
 , max(case when ct.census_tra = '381100' then 1 else 0 end) as census_tra_381100 
 , max(case when ct.census_tra = '381200' then 1 else 0 end) as census_tra_381200 
 , max(case when ct.census_tra = '381300' then 1 else 0 end) as census_tra_381300 
 , max(case when ct.census_tra = '381400' then 1 else 0 end) as census_tra_381400 
 , max(case when ct.census_tra = '381500' then 1 else 0 end) as census_tra_381500 
 , max(case when ct.census_tra = '381600' then 1 else 0 end) as census_tra_381600 
 , max(case when ct.census_tra = '381700' then 1 else 0 end) as census_tra_381700 
 , max(case when ct.census_tra = '381800' then 1 else 0 end) as census_tra_381800 
 , max(case when ct.census_tra = '381900' then 1 else 0 end) as census_tra_381900 
 , max(case when ct.census_tra = '382000' then 1 else 0 end) as census_tra_382000 
 , max(case when ct.census_tra = '390100' then 1 else 0 end) as census_tra_390100 
 , max(case when ct.census_tra = '390200' then 1 else 0 end) as census_tra_390200 
 , max(case when ct.census_tra = '390300' then 1 else 0 end) as census_tra_390300 
 , max(case when ct.census_tra = '390400' then 1 else 0 end) as census_tra_390400 
 , max(case when ct.census_tra = '390500' then 1 else 0 end) as census_tra_390500 
 , max(case when ct.census_tra = '390600' then 1 else 0 end) as census_tra_390600 
 , max(case when ct.census_tra = '390700' then 1 else 0 end) as census_tra_390700 
 , max(case when ct.census_tra = '400100' then 1 else 0 end) as census_tra_400100 
 , max(case when ct.census_tra = '400200' then 1 else 0 end) as census_tra_400200 
 , max(case when ct.census_tra = '400300' then 1 else 0 end) as census_tra_400300 
 , max(case when ct.census_tra = '400400' then 1 else 0 end) as census_tra_400400 
 , max(case when ct.census_tra = '400500' then 1 else 0 end) as census_tra_400500 
 , max(case when ct.census_tra = '400600' then 1 else 0 end) as census_tra_400600 
 , max(case when ct.census_tra = '400700' then 1 else 0 end) as census_tra_400700 
 , max(case when ct.census_tra = '400800' then 1 else 0 end) as census_tra_400800 
 , max(case when ct.census_tra = '410100' then 1 else 0 end) as census_tra_410100 
 , max(case when ct.census_tra = '410200' then 1 else 0 end) as census_tra_410200 
 , max(case when ct.census_tra = '410300' then 1 else 0 end) as census_tra_410300 
 , max(case when ct.census_tra = '410400' then 1 else 0 end) as census_tra_410400 
 , max(case when ct.census_tra = '410500' then 1 else 0 end) as census_tra_410500 
 , max(case when ct.census_tra = '410600' then 1 else 0 end) as census_tra_410600 
 , max(case when ct.census_tra = '410700' then 1 else 0 end) as census_tra_410700 
 , max(case when ct.census_tra = '410800' then 1 else 0 end) as census_tra_410800 
 , max(case when ct.census_tra = '410900' then 1 else 0 end) as census_tra_410900 
 , max(case when ct.census_tra = '411000' then 1 else 0 end) as census_tra_411000 
 , max(case when ct.census_tra = '411100' then 1 else 0 end) as census_tra_411100 
 , max(case when ct.census_tra = '411200' then 1 else 0 end) as census_tra_411200 
 , max(case when ct.census_tra = '411300' then 1 else 0 end) as census_tra_411300 
 , max(case when ct.census_tra = '411400' then 1 else 0 end) as census_tra_411400 
 , max(case when ct.census_tra = '420100' then 1 else 0 end) as census_tra_420100 
 , max(case when ct.census_tra = '420200' then 1 else 0 end) as census_tra_420200 
 , max(case when ct.census_tra = '420300' then 1 else 0 end) as census_tra_420300 
 , max(case when ct.census_tra = '420400' then 1 else 0 end) as census_tra_420400 
 , max(case when ct.census_tra = '420500' then 1 else 0 end) as census_tra_420500 
 , max(case when ct.census_tra = '420600' then 1 else 0 end) as census_tra_420600 
 , max(case when ct.census_tra = '420700' then 1 else 0 end) as census_tra_420700 
 , max(case when ct.census_tra = '420800' then 1 else 0 end) as census_tra_420800 
 , max(case when ct.census_tra = '420900' then 1 else 0 end) as census_tra_420900 
 , max(case when ct.census_tra = '421000' then 1 else 0 end) as census_tra_421000 
 , max(case when ct.census_tra = '421100' then 1 else 0 end) as census_tra_421100 
 , max(case when ct.census_tra = '421200' then 1 else 0 end) as census_tra_421200 
 , max(case when ct.census_tra = '430100' then 1 else 0 end) as census_tra_430100 
 , max(case when ct.census_tra = '430200' then 1 else 0 end) as census_tra_430200 
 , max(case when ct.census_tra = '430300' then 1 else 0 end) as census_tra_430300 
 , max(case when ct.census_tra = '430400' then 1 else 0 end) as census_tra_430400 
 , max(case when ct.census_tra = '430500' then 1 else 0 end) as census_tra_430500 
 , max(case when ct.census_tra = '430600' then 1 else 0 end) as census_tra_430600 
 , max(case when ct.census_tra = '430700' then 1 else 0 end) as census_tra_430700 
 , max(case when ct.census_tra = '430800' then 1 else 0 end) as census_tra_430800 
 , max(case when ct.census_tra = '430900' then 1 else 0 end) as census_tra_430900 
 , max(case when ct.census_tra = '431000' then 1 else 0 end) as census_tra_431000 
 , max(case when ct.census_tra = '431100' then 1 else 0 end) as census_tra_431100 
 , max(case when ct.census_tra = '431200' then 1 else 0 end) as census_tra_431200 
 , max(case when ct.census_tra = '431300' then 1 else 0 end) as census_tra_431300 
 , max(case when ct.census_tra = '431400' then 1 else 0 end) as census_tra_431400 
 , max(case when ct.census_tra = '440100' then 1 else 0 end) as census_tra_440100 
 , max(case when ct.census_tra = '440200' then 1 else 0 end) as census_tra_440200 
 , max(case when ct.census_tra = '440300' then 1 else 0 end) as census_tra_440300 
 , max(case when ct.census_tra = '440400' then 1 else 0 end) as census_tra_440400 
 , max(case when ct.census_tra = '440500' then 1 else 0 end) as census_tra_440500 
 , max(case when ct.census_tra = '440600' then 1 else 0 end) as census_tra_440600 
 , max(case when ct.census_tra = '440700' then 1 else 0 end) as census_tra_440700 
 , max(case when ct.census_tra = '440800' then 1 else 0 end) as census_tra_440800 
 , max(case when ct.census_tra = '440900' then 1 else 0 end) as census_tra_440900 
 , max(case when ct.census_tra = '450100' then 1 else 0 end) as census_tra_450100 
 , max(case when ct.census_tra = '450200' then 1 else 0 end) as census_tra_450200 
 , max(case when ct.census_tra = '450300' then 1 else 0 end) as census_tra_450300 
 , max(case when ct.census_tra = '460100' then 1 else 0 end) as census_tra_460100 
 , max(case when ct.census_tra = '460200' then 1 else 0 end) as census_tra_460200 
 , max(case when ct.census_tra = '460300' then 1 else 0 end) as census_tra_460300 
 , max(case when ct.census_tra = '460400' then 1 else 0 end) as census_tra_460400 
 , max(case when ct.census_tra = '460500' then 1 else 0 end) as census_tra_460500 
 , max(case when ct.census_tra = '460600' then 1 else 0 end) as census_tra_460600 
 , max(case when ct.census_tra = '460700' then 1 else 0 end) as census_tra_460700 
 , max(case when ct.census_tra = '460900' then 1 else 0 end) as census_tra_460900 
 , max(case when ct.census_tra = '461000' then 1 else 0 end) as census_tra_461000 
 , max(case when ct.census_tra = '470100' then 1 else 0 end) as census_tra_470100 
 , max(case when ct.census_tra = '480100' then 1 else 0 end) as census_tra_480100 
 , max(case when ct.census_tra = '480200' then 1 else 0 end) as census_tra_480200 
 , max(case when ct.census_tra = '480300' then 1 else 0 end) as census_tra_480300 
 , max(case when ct.census_tra = '480400' then 1 else 0 end) as census_tra_480400 
 , max(case when ct.census_tra = '480500' then 1 else 0 end) as census_tra_480500 
 , max(case when ct.census_tra = '490100' then 1 else 0 end) as census_tra_490100 
 , max(case when ct.census_tra = '490200' then 1 else 0 end) as census_tra_490200 
 , max(case when ct.census_tra = '490300' then 1 else 0 end) as census_tra_490300 
 , max(case when ct.census_tra = '490400' then 1 else 0 end) as census_tra_490400 
 , max(case when ct.census_tra = '490500' then 1 else 0 end) as census_tra_490500 
 , max(case when ct.census_tra = '490600' then 1 else 0 end) as census_tra_490600 
 , max(case when ct.census_tra = '490700' then 1 else 0 end) as census_tra_490700 
 , max(case when ct.census_tra = '490800' then 1 else 0 end) as census_tra_490800 
 , max(case when ct.census_tra = '490900' then 1 else 0 end) as census_tra_490900 
 , max(case when ct.census_tra = '491000' then 1 else 0 end) as census_tra_491000 
 , max(case when ct.census_tra = '491100' then 1 else 0 end) as census_tra_491100 
 , max(case when ct.census_tra = '491200' then 1 else 0 end) as census_tra_491200 
 , max(case when ct.census_tra = '491300' then 1 else 0 end) as census_tra_491300 
 , max(case when ct.census_tra = '491400' then 1 else 0 end) as census_tra_491400 
 , max(case when ct.census_tra = '500100' then 1 else 0 end) as census_tra_500100 
 , max(case when ct.census_tra = '500200' then 1 else 0 end) as census_tra_500200 
 , max(case when ct.census_tra = '500300' then 1 else 0 end) as census_tra_500300 
 , max(case when ct.census_tra = '510100' then 1 else 0 end) as census_tra_510100 
 , max(case when ct.census_tra = '510200' then 1 else 0 end) as census_tra_510200 
 , max(case when ct.census_tra = '510300' then 1 else 0 end) as census_tra_510300 
 , max(case when ct.census_tra = '510400' then 1 else 0 end) as census_tra_510400 
 , max(case when ct.census_tra = '510500' then 1 else 0 end) as census_tra_510500 
 , max(case when ct.census_tra = '520100' then 1 else 0 end) as census_tra_520100 
 , max(case when ct.census_tra = '520200' then 1 else 0 end) as census_tra_520200 
 , max(case when ct.census_tra = '520300' then 1 else 0 end) as census_tra_520300 
 , max(case when ct.census_tra = '520400' then 1 else 0 end) as census_tra_520400 
 , max(case when ct.census_tra = '520500' then 1 else 0 end) as census_tra_520500 
 , max(case when ct.census_tra = '520600' then 1 else 0 end) as census_tra_520600 
 , max(case when ct.census_tra = '530100' then 1 else 0 end) as census_tra_530100 
 , max(case when ct.census_tra = '530200' then 1 else 0 end) as census_tra_530200 
 , max(case when ct.census_tra = '530300' then 1 else 0 end) as census_tra_530300 
 , max(case when ct.census_tra = '530400' then 1 else 0 end) as census_tra_530400 
 , max(case when ct.census_tra = '530500' then 1 else 0 end) as census_tra_530500 
 , max(case when ct.census_tra = '530600' then 1 else 0 end) as census_tra_530600 
 , max(case when ct.census_tra = '540100' then 1 else 0 end) as census_tra_540100 
 , max(case when ct.census_tra = '550100' then 1 else 0 end) as census_tra_550100 
 , max(case when ct.census_tra = '550200' then 1 else 0 end) as census_tra_550200 
 , max(case when ct.census_tra = '560100' then 1 else 0 end) as census_tra_560100 
 , max(case when ct.census_tra = '560200' then 1 else 0 end) as census_tra_560200 
 , max(case when ct.census_tra = '560300' then 1 else 0 end) as census_tra_560300 
 , max(case when ct.census_tra = '560400' then 1 else 0 end) as census_tra_560400 
 , max(case when ct.census_tra = '560500' then 1 else 0 end) as census_tra_560500 
 , max(case when ct.census_tra = '560600' then 1 else 0 end) as census_tra_560600 
 , max(case when ct.census_tra = '560700' then 1 else 0 end) as census_tra_560700 
 , max(case when ct.census_tra = '560800' then 1 else 0 end) as census_tra_560800 
 , max(case when ct.census_tra = '560900' then 1 else 0 end) as census_tra_560900 
 , max(case when ct.census_tra = '561000' then 1 else 0 end) as census_tra_561000 
 , max(case when ct.census_tra = '561100' then 1 else 0 end) as census_tra_561100 
 , max(case when ct.census_tra = '561200' then 1 else 0 end) as census_tra_561200 
 , max(case when ct.census_tra = '561300' then 1 else 0 end) as census_tra_561300 
 , max(case when ct.census_tra = '570100' then 1 else 0 end) as census_tra_570100 
 , max(case when ct.census_tra = '570200' then 1 else 0 end) as census_tra_570200 
 , max(case when ct.census_tra = '570300' then 1 else 0 end) as census_tra_570300 
 , max(case when ct.census_tra = '570400' then 1 else 0 end) as census_tra_570400 
 , max(case when ct.census_tra = '570500' then 1 else 0 end) as census_tra_570500 
 , max(case when ct.census_tra = '580100' then 1 else 0 end) as census_tra_580100 
 , max(case when ct.census_tra = '580200' then 1 else 0 end) as census_tra_580200 
 , max(case when ct.census_tra = '580300' then 1 else 0 end) as census_tra_580300 
 , max(case when ct.census_tra = '580400' then 1 else 0 end) as census_tra_580400 
 , max(case when ct.census_tra = '580500' then 1 else 0 end) as census_tra_580500 
 , max(case when ct.census_tra = '580600' then 1 else 0 end) as census_tra_580600 
 , max(case when ct.census_tra = '580700' then 1 else 0 end) as census_tra_580700 
 , max(case when ct.census_tra = '580800' then 1 else 0 end) as census_tra_580800 
 , max(case when ct.census_tra = '580900' then 1 else 0 end) as census_tra_580900 
 , max(case when ct.census_tra = '581000' then 1 else 0 end) as census_tra_581000 
 , max(case when ct.census_tra = '581100' then 1 else 0 end) as census_tra_581100 
 , max(case when ct.census_tra = '590100' then 1 else 0 end) as census_tra_590100 
 , max(case when ct.census_tra = '590200' then 1 else 0 end) as census_tra_590200 
 , max(case when ct.census_tra = '590300' then 1 else 0 end) as census_tra_590300 
 , max(case when ct.census_tra = '590400' then 1 else 0 end) as census_tra_590400 
 , max(case when ct.census_tra = '590500' then 1 else 0 end) as census_tra_590500 
 , max(case when ct.census_tra = '590600' then 1 else 0 end) as census_tra_590600 
 , max(case when ct.census_tra = '590700' then 1 else 0 end) as census_tra_590700 
 , max(case when ct.census_tra = '600100' then 1 else 0 end) as census_tra_600100 
 , max(case when ct.census_tra = '600200' then 1 else 0 end) as census_tra_600200 
 , max(case when ct.census_tra = '600300' then 1 else 0 end) as census_tra_600300 
 , max(case when ct.census_tra = '600400' then 1 else 0 end) as census_tra_600400 
 , max(case when ct.census_tra = '600500' then 1 else 0 end) as census_tra_600500 
 , max(case when ct.census_tra = '600600' then 1 else 0 end) as census_tra_600600 
 , max(case when ct.census_tra = '600700' then 1 else 0 end) as census_tra_600700 
 , max(case when ct.census_tra = '600800' then 1 else 0 end) as census_tra_600800 
 , max(case when ct.census_tra = '600900' then 1 else 0 end) as census_tra_600900 
 , max(case when ct.census_tra = '601000' then 1 else 0 end) as census_tra_601000 
 , max(case when ct.census_tra = '601100' then 1 else 0 end) as census_tra_601100 
 , max(case when ct.census_tra = '601200' then 1 else 0 end) as census_tra_601200 
 , max(case when ct.census_tra = '601300' then 1 else 0 end) as census_tra_601300 
 , max(case when ct.census_tra = '601400' then 1 else 0 end) as census_tra_601400 
 , max(case when ct.census_tra = '601500' then 1 else 0 end) as census_tra_601500 
 , max(case when ct.census_tra = '601600' then 1 else 0 end) as census_tra_601600 
 , max(case when ct.census_tra = '610100' then 1 else 0 end) as census_tra_610100 
 , max(case when ct.census_tra = '610200' then 1 else 0 end) as census_tra_610200 
 , max(case when ct.census_tra = '610300' then 1 else 0 end) as census_tra_610300 
 , max(case when ct.census_tra = '610400' then 1 else 0 end) as census_tra_610400 
 , max(case when ct.census_tra = '610500' then 1 else 0 end) as census_tra_610500 
 , max(case when ct.census_tra = '610600' then 1 else 0 end) as census_tra_610600 
 , max(case when ct.census_tra = '610700' then 1 else 0 end) as census_tra_610700 
 , max(case when ct.census_tra = '610800' then 1 else 0 end) as census_tra_610800 
 , max(case when ct.census_tra = '610900' then 1 else 0 end) as census_tra_610900 
 , max(case when ct.census_tra = '611000' then 1 else 0 end) as census_tra_611000 
 , max(case when ct.census_tra = '611100' then 1 else 0 end) as census_tra_611100 
 , max(case when ct.census_tra = '611200' then 1 else 0 end) as census_tra_611200 
 , max(case when ct.census_tra = '611300' then 1 else 0 end) as census_tra_611300 
 , max(case when ct.census_tra = '611400' then 1 else 0 end) as census_tra_611400 
 , max(case when ct.census_tra = '611500' then 1 else 0 end) as census_tra_611500 
 , max(case when ct.census_tra = '611600' then 1 else 0 end) as census_tra_611600 
 , max(case when ct.census_tra = '611700' then 1 else 0 end) as census_tra_611700 
 , max(case when ct.census_tra = '611800' then 1 else 0 end) as census_tra_611800 
 , max(case when ct.census_tra = '611900' then 1 else 0 end) as census_tra_611900 
 , max(case when ct.census_tra = '612000' then 1 else 0 end) as census_tra_612000 
 , max(case when ct.census_tra = '612100' then 1 else 0 end) as census_tra_612100 
 , max(case when ct.census_tra = '612200' then 1 else 0 end) as census_tra_612200 
 , max(case when ct.census_tra = '620100' then 1 else 0 end) as census_tra_620100 
 , max(case when ct.census_tra = '620200' then 1 else 0 end) as census_tra_620200 
 , max(case when ct.census_tra = '620300' then 1 else 0 end) as census_tra_620300 
 , max(case when ct.census_tra = '620400' then 1 else 0 end) as census_tra_620400 
 , max(case when ct.census_tra = '630100' then 1 else 0 end) as census_tra_630100 
 , max(case when ct.census_tra = '630200' then 1 else 0 end) as census_tra_630200 
 , max(case when ct.census_tra = '630300' then 1 else 0 end) as census_tra_630300 
 , max(case when ct.census_tra = '630400' then 1 else 0 end) as census_tra_630400 
 , max(case when ct.census_tra = '630500' then 1 else 0 end) as census_tra_630500 
 , max(case when ct.census_tra = '630600' then 1 else 0 end) as census_tra_630600 
 , max(case when ct.census_tra = '630700' then 1 else 0 end) as census_tra_630700 
 , max(case when ct.census_tra = '630800' then 1 else 0 end) as census_tra_630800 
 , max(case when ct.census_tra = '630900' then 1 else 0 end) as census_tra_630900 
 , max(case when ct.census_tra = '640100' then 1 else 0 end) as census_tra_640100 
 , max(case when ct.census_tra = '640200' then 1 else 0 end) as census_tra_640200 
 , max(case when ct.census_tra = '640300' then 1 else 0 end) as census_tra_640300 
 , max(case when ct.census_tra = '640400' then 1 else 0 end) as census_tra_640400 
 , max(case when ct.census_tra = '640500' then 1 else 0 end) as census_tra_640500 
 , max(case when ct.census_tra = '640600' then 1 else 0 end) as census_tra_640600 
 , max(case when ct.census_tra = '640700' then 1 else 0 end) as census_tra_640700 
 , max(case when ct.census_tra = '640800' then 1 else 0 end) as census_tra_640800 
 , max(case when ct.census_tra = '650100' then 1 else 0 end) as census_tra_650100 
 , max(case when ct.census_tra = '650200' then 1 else 0 end) as census_tra_650200 
 , max(case when ct.census_tra = '650300' then 1 else 0 end) as census_tra_650300 
 , max(case when ct.census_tra = '650400' then 1 else 0 end) as census_tra_650400 
 , max(case when ct.census_tra = '650500' then 1 else 0 end) as census_tra_650500 
 , max(case when ct.census_tra = '660100' then 1 else 0 end) as census_tra_660100 
 , max(case when ct.census_tra = '660200' then 1 else 0 end) as census_tra_660200 
 , max(case when ct.census_tra = '660300' then 1 else 0 end) as census_tra_660300 
 , max(case when ct.census_tra = '660400' then 1 else 0 end) as census_tra_660400 
 , max(case when ct.census_tra = '660500' then 1 else 0 end) as census_tra_660500 
 , max(case when ct.census_tra = '660600' then 1 else 0 end) as census_tra_660600 
 , max(case when ct.census_tra = '660700' then 1 else 0 end) as census_tra_660700 
 , max(case when ct.census_tra = '660800' then 1 else 0 end) as census_tra_660800 
 , max(case when ct.census_tra = '660900' then 1 else 0 end) as census_tra_660900 
 , max(case when ct.census_tra = '661000' then 1 else 0 end) as census_tra_661000 
 , max(case when ct.census_tra = '661100' then 1 else 0 end) as census_tra_661100 
 , max(case when ct.census_tra = '670100' then 1 else 0 end) as census_tra_670100 
 , max(case when ct.census_tra = '670200' then 1 else 0 end) as census_tra_670200 
 , max(case when ct.census_tra = '670300' then 1 else 0 end) as census_tra_670300 
 , max(case when ct.census_tra = '670400' then 1 else 0 end) as census_tra_670400 
 , max(case when ct.census_tra = '670500' then 1 else 0 end) as census_tra_670500 
 , max(case when ct.census_tra = '670600' then 1 else 0 end) as census_tra_670600 
 , max(case when ct.census_tra = '670700' then 1 else 0 end) as census_tra_670700 
 , max(case when ct.census_tra = '670800' then 1 else 0 end) as census_tra_670800 
 , max(case when ct.census_tra = '670900' then 1 else 0 end) as census_tra_670900 
 , max(case when ct.census_tra = '671000' then 1 else 0 end) as census_tra_671000 
 , max(case when ct.census_tra = '671100' then 1 else 0 end) as census_tra_671100 
 , max(case when ct.census_tra = '671200' then 1 else 0 end) as census_tra_671200 
 , max(case when ct.census_tra = '671300' then 1 else 0 end) as census_tra_671300 
 , max(case when ct.census_tra = '671400' then 1 else 0 end) as census_tra_671400 
 , max(case when ct.census_tra = '671500' then 1 else 0 end) as census_tra_671500 
 , max(case when ct.census_tra = '671600' then 1 else 0 end) as census_tra_671600 
 , max(case when ct.census_tra = '671700' then 1 else 0 end) as census_tra_671700 
 , max(case when ct.census_tra = '671800' then 1 else 0 end) as census_tra_671800 
 , max(case when ct.census_tra = '671900' then 1 else 0 end) as census_tra_671900 
 , max(case when ct.census_tra = '672000' then 1 else 0 end) as census_tra_672000 
 , max(case when ct.census_tra = '680100' then 1 else 0 end) as census_tra_680100 
 , max(case when ct.census_tra = '680200' then 1 else 0 end) as census_tra_680200 
 , max(case when ct.census_tra = '680300' then 1 else 0 end) as census_tra_680300 
 , max(case when ct.census_tra = '680400' then 1 else 0 end) as census_tra_680400 
 , max(case when ct.census_tra = '680500' then 1 else 0 end) as census_tra_680500 
 , max(case when ct.census_tra = '680600' then 1 else 0 end) as census_tra_680600 
 , max(case when ct.census_tra = '680700' then 1 else 0 end) as census_tra_680700 
 , max(case when ct.census_tra = '680800' then 1 else 0 end) as census_tra_680800 
 , max(case when ct.census_tra = '680900' then 1 else 0 end) as census_tra_680900 
 , max(case when ct.census_tra = '681000' then 1 else 0 end) as census_tra_681000 
 , max(case when ct.census_tra = '681100' then 1 else 0 end) as census_tra_681100 
 , max(case when ct.census_tra = '681200' then 1 else 0 end) as census_tra_681200 
 , max(case when ct.census_tra = '681300' then 1 else 0 end) as census_tra_681300 
 , max(case when ct.census_tra = '681400' then 1 else 0 end) as census_tra_681400 
 , max(case when ct.census_tra = '690100' then 1 else 0 end) as census_tra_690100 
 , max(case when ct.census_tra = '690200' then 1 else 0 end) as census_tra_690200 
 , max(case when ct.census_tra = '690300' then 1 else 0 end) as census_tra_690300 
 , max(case when ct.census_tra = '690400' then 1 else 0 end) as census_tra_690400 
 , max(case when ct.census_tra = '690500' then 1 else 0 end) as census_tra_690500 
 , max(case when ct.census_tra = '690600' then 1 else 0 end) as census_tra_690600 
 , max(case when ct.census_tra = '690700' then 1 else 0 end) as census_tra_690700 
 , max(case when ct.census_tra = '690800' then 1 else 0 end) as census_tra_690800 
 , max(case when ct.census_tra = '690900' then 1 else 0 end) as census_tra_690900 
 , max(case when ct.census_tra = '691000' then 1 else 0 end) as census_tra_691000 
 , max(case when ct.census_tra = '691100' then 1 else 0 end) as census_tra_691100 
 , max(case when ct.census_tra = '691200' then 1 else 0 end) as census_tra_691200 
 , max(case when ct.census_tra = '691300' then 1 else 0 end) as census_tra_691300 
 , max(case when ct.census_tra = '691400' then 1 else 0 end) as census_tra_691400 
 , max(case when ct.census_tra = '691500' then 1 else 0 end) as census_tra_691500 
 , max(case when ct.census_tra = '700100' then 1 else 0 end) as census_tra_700100 
 , max(case when ct.census_tra = '700200' then 1 else 0 end) as census_tra_700200 
 , max(case when ct.census_tra = '700300' then 1 else 0 end) as census_tra_700300 
 , max(case when ct.census_tra = '700400' then 1 else 0 end) as census_tra_700400 
 , max(case when ct.census_tra = '700500' then 1 else 0 end) as census_tra_700500 
 , max(case when ct.census_tra = '710100' then 1 else 0 end) as census_tra_710100 
 , max(case when ct.census_tra = '710200' then 1 else 0 end) as census_tra_710200 
 , max(case when ct.census_tra = '710300' then 1 else 0 end) as census_tra_710300 
 , max(case when ct.census_tra = '710400' then 1 else 0 end) as census_tra_710400 
 , max(case when ct.census_tra = '710500' then 1 else 0 end) as census_tra_710500 
 , max(case when ct.census_tra = '710600' then 1 else 0 end) as census_tra_710600 
 , max(case when ct.census_tra = '710700' then 1 else 0 end) as census_tra_710700 
 , max(case when ct.census_tra = '710800' then 1 else 0 end) as census_tra_710800 
 , max(case when ct.census_tra = '710900' then 1 else 0 end) as census_tra_710900 
 , max(case when ct.census_tra = '711000' then 1 else 0 end) as census_tra_711000 
 , max(case when ct.census_tra = '711100' then 1 else 0 end) as census_tra_711100 
 , max(case when ct.census_tra = '711200' then 1 else 0 end) as census_tra_711200 
 , max(case when ct.census_tra = '711300' then 1 else 0 end) as census_tra_711300 
 , max(case when ct.census_tra = '711400' then 1 else 0 end) as census_tra_711400 
 , max(case when ct.census_tra = '711500' then 1 else 0 end) as census_tra_711500 
 , max(case when ct.census_tra = '720100' then 1 else 0 end) as census_tra_720100 
 , max(case when ct.census_tra = '720200' then 1 else 0 end) as census_tra_720200 
 , max(case when ct.census_tra = '720300' then 1 else 0 end) as census_tra_720300 
 , max(case when ct.census_tra = '720400' then 1 else 0 end) as census_tra_720400 
 , max(case when ct.census_tra = '720600' then 1 else 0 end) as census_tra_720600 
 , max(case when ct.census_tra = '720700' then 1 else 0 end) as census_tra_720700 
 , max(case when ct.census_tra = '730100' then 1 else 0 end) as census_tra_730100 
 , max(case when ct.census_tra = '730200' then 1 else 0 end) as census_tra_730200 
 , max(case when ct.census_tra = '730300' then 1 else 0 end) as census_tra_730300 
 , max(case when ct.census_tra = '730400' then 1 else 0 end) as census_tra_730400 
 , max(case when ct.census_tra = '730500' then 1 else 0 end) as census_tra_730500 
 , max(case when ct.census_tra = '730600' then 1 else 0 end) as census_tra_730600 
 , max(case when ct.census_tra = '730700' then 1 else 0 end) as census_tra_730700 
 , max(case when ct.census_tra = '740100' then 1 else 0 end) as census_tra_740100 
 , max(case when ct.census_tra = '740200' then 1 else 0 end) as census_tra_740200 
 , max(case when ct.census_tra = '740300' then 1 else 0 end) as census_tra_740300 
 , max(case when ct.census_tra = '740400' then 1 else 0 end) as census_tra_740400 
 , max(case when ct.census_tra = '750100' then 1 else 0 end) as census_tra_750100 
 , max(case when ct.census_tra = '750200' then 1 else 0 end) as census_tra_750200 
 , max(case when ct.census_tra = '750300' then 1 else 0 end) as census_tra_750300 
 , max(case when ct.census_tra = '750400' then 1 else 0 end) as census_tra_750400 
 , max(case when ct.census_tra = '750500' then 1 else 0 end) as census_tra_750500 
 , max(case when ct.census_tra = '750600' then 1 else 0 end) as census_tra_750600 
 , max(case when ct.census_tra = '760800' then 1 else 0 end) as census_tra_760800 
 , max(case when ct.census_tra = '760900' then 1 else 0 end) as census_tra_760900 
 , max(case when ct.census_tra = '770600' then 1 else 0 end) as census_tra_770600 
 , max(case when ct.census_tra = '770700' then 1 else 0 end) as census_tra_770700 
 , max(case when ct.census_tra = '770800' then 1 else 0 end) as census_tra_770800 
 , max(case when ct.census_tra = '770900' then 1 else 0 end) as census_tra_770900 
 , max(case when ct.census_tra = '808100' then 1 else 0 end) as census_tra_808100 
 , max(case when ct.census_tra = '810400' then 1 else 0 end) as census_tra_810400 
 , max(case when ct.census_tra = '810501' then 1 else 0 end) as census_tra_810501 
 , max(case when ct.census_tra = '811600' then 1 else 0 end) as census_tra_811600 
 , max(case when ct.census_tra = '820800' then 1 else 0 end) as census_tra_820800 
 , max(case when ct.census_tra = '821500' then 1 else 0 end) as census_tra_821500 
 , max(case when ct.census_tra = '823304' then 1 else 0 end) as census_tra_823304 
 , max(case when ct.census_tra = '840000' then 1 else 0 end) as census_tra_840000 
from cells c 
inner join census_tracts ct 
	on ST_INTERSECTS(c.geom4326, ct.geom4326)
group by c.cell_id
;

/* 250-276 replaces 280 (original for oakland)
insert into cell_census_tract_bins
select c.cell_id
, max(case when ct.census_tra = '4001' then 1 else 0 end) as census_tra_400100
, max(case when ct.census_tra = '4002' then 1 else 0 end) as census_tra_400200
, max(case when ct.census_tra = '4003' then 1 else 0 end) as census_tra_400300
, max(case when ct.census_tra = '4004' then 1 else 0 end) as census_tra_400400
, max(case when ct.census_tra = '4005' then 1 else 0 end) as census_tra_400500
, max(case when ct.census_tra = '4006' then 1 else 0 end) as census_tra_400600
, max(case when ct.census_tra = '4007' then 1 else 0 end) as census_tra_400700
, max(case when ct.census_tra = '4008' then 1 else 0 end) as census_tra_400800
, max(case when ct.census_tra = '4009' then 1 else 0 end) as census_tra_400900
, max(case when ct.census_tra = '4010' then 1 else 0 end) as census_tra_401000
, max(case when ct.census_tra = '4011' then 1 else 0 end) as census_tra_401100
, max(case when ct.census_tra = '4012' then 1 else 0 end) as census_tra_401200
, max(case when ct.census_tra = '4013' then 1 else 0 end) as census_tra_401300
, max(case when ct.census_tra = '4014' then 1 else 0 end) as census_tra_401400
, max(case when ct.census_tra = '4015' then 1 else 0 end) as census_tra_401500
, max(case when ct.census_tra = '4016' then 1 else 0 end) as census_tra_401600
, max(case when ct.census_tra = '4017' then 1 else 0 end) as census_tra_401700
, max(case when ct.census_tra = '4018' then 1 else 0 end) as census_tra_401800
, max(case when ct.census_tra = '4022' then 1 else 0 end) as census_tra_402200
, max(case when ct.census_tra = '4024' then 1 else 0 end) as census_tra_402400
, max(case when ct.census_tra = '4025' then 1 else 0 end) as census_tra_402500
, max(case when ct.census_tra = '4026' then 1 else 0 end) as census_tra_402600
, max(case when ct.census_tra = '4027' then 1 else 0 end) as census_tra_402700
, max(case when ct.census_tra = '4028' then 1 else 0 end) as census_tra_402800
, max(case when ct.census_tra = '4029' then 1 else 0 end) as census_tra_402900
, max(case when ct.census_tra = '4030' then 1 else 0 end) as census_tra_403000
, max(case when ct.census_tra = '4031' then 1 else 0 end) as census_tra_403100
, max(case when ct.census_tra = '4033' then 1 else 0 end) as census_tra_403300
, max(case when ct.census_tra = '4034' then 1 else 0 end) as census_tra_403400
, max(case when ct.census_tra = '4035.01' then 1 else 0 end) as census_tra_403501
, max(case when ct.census_tra = '4035.02' then 1 else 0 end) as census_tra_403502
, max(case when ct.census_tra = '4036' then 1 else 0 end) as census_tra_403600
, max(case when ct.census_tra = '4037.01' then 1 else 0 end) as census_tra_403701
, max(case when ct.census_tra = '4037.02' then 1 else 0 end) as census_tra_403702
, max(case when ct.census_tra = '4038' then 1 else 0 end) as census_tra_403800
, max(case when ct.census_tra = '4039' then 1 else 0 end) as census_tra_403900
, max(case when ct.census_tra = '4040' then 1 else 0 end) as census_tra_404000
, max(case when ct.census_tra = '4041.01' then 1 else 0 end) as census_tra_404101
, max(case when ct.census_tra = '4041.02' then 1 else 0 end) as census_tra_404102
, max(case when ct.census_tra = '4042' then 1 else 0 end) as census_tra_404200
, max(case when ct.census_tra = '4043' then 1 else 0 end) as census_tra_404300
, max(case when ct.census_tra = '4044' then 1 else 0 end) as census_tra_404400
, max(case when ct.census_tra = '4045.01' then 1 else 0 end) as census_tra_404501
, max(case when ct.census_tra = '4045.02' then 1 else 0 end) as census_tra_404502
, max(case when ct.census_tra = '4046' then 1 else 0 end) as census_tra_404600
, max(case when ct.census_tra = '4047' then 1 else 0 end) as census_tra_404700
, max(case when ct.census_tra = '4048' then 1 else 0 end) as census_tra_404800
, max(case when ct.census_tra = '4049' then 1 else 0 end) as census_tra_404900
, max(case when ct.census_tra = '4050' then 1 else 0 end) as census_tra_405000
, max(case when ct.census_tra = '4051' then 1 else 0 end) as census_tra_405100
, max(case when ct.census_tra = '4052' then 1 else 0 end) as census_tra_405200
, max(case when ct.census_tra = '4053.01' then 1 else 0 end) as census_tra_405301
, max(case when ct.census_tra = '4053.02' then 1 else 0 end) as census_tra_405302
, max(case when ct.census_tra = '4054.01' then 1 else 0 end) as census_tra_405401
, max(case when ct.census_tra = '4054.02' then 1 else 0 end) as census_tra_405402
, max(case when ct.census_tra = '4055' then 1 else 0 end) as census_tra_405500
, max(case when ct.census_tra = '4056' then 1 else 0 end) as census_tra_405600
, max(case when ct.census_tra = '4057' then 1 else 0 end) as census_tra_405700
, max(case when ct.census_tra = '4058' then 1 else 0 end) as census_tra_405800
, max(case when ct.census_tra = '4059.01' then 1 else 0 end) as census_tra_405901
, max(case when ct.census_tra = '4059.02' then 1 else 0 end) as census_tra_405902
, max(case when ct.census_tra = '4060' then 1 else 0 end) as census_tra_406000
, max(case when ct.census_tra = '4061' then 1 else 0 end) as census_tra_406100
, max(case when ct.census_tra = '4062.01' then 1 else 0 end) as census_tra_406201
, max(case when ct.census_tra = '4062.02' then 1 else 0 end) as census_tra_406202
, max(case when ct.census_tra = '4063' then 1 else 0 end) as census_tra_406300
, max(case when ct.census_tra = '4064' then 1 else 0 end) as census_tra_406400
, max(case when ct.census_tra = '4065' then 1 else 0 end) as census_tra_406500
, max(case when ct.census_tra = '4066.01' then 1 else 0 end) as census_tra_406601
, max(case when ct.census_tra = '4066.02' then 1 else 0 end) as census_tra_406602
, max(case when ct.census_tra = '4067' then 1 else 0 end) as census_tra_406700
, max(case when ct.census_tra = '4068' then 1 else 0 end) as census_tra_406800
, max(case when ct.census_tra = '4069' then 1 else 0 end) as census_tra_406900
, max(case when ct.census_tra = '4070' then 1 else 0 end) as census_tra_407000
, max(case when ct.census_tra = '4071.01' then 1 else 0 end) as census_tra_407101
, max(case when ct.census_tra = '4071.02' then 1 else 0 end) as census_tra_407102
, max(case when ct.census_tra = '4072' then 1 else 0 end) as census_tra_407200
, max(case when ct.census_tra = '4073' then 1 else 0 end) as census_tra_407300
, max(case when ct.census_tra = '4074' then 1 else 0 end) as census_tra_407400
, max(case when ct.census_tra = '4075' then 1 else 0 end) as census_tra_407500
, max(case when ct.census_tra = '4076' then 1 else 0 end) as census_tra_407600
, max(case when ct.census_tra = '4077' then 1 else 0 end) as census_tra_407700
, max(case when ct.census_tra = '4078' then 1 else 0 end) as census_tra_407800
, max(case when ct.census_tra = '4079' then 1 else 0 end) as census_tra_407900
, max(case when ct.census_tra = '4080' then 1 else 0 end) as census_tra_408000
, max(case when ct.census_tra = '4081' then 1 else 0 end) as census_tra_408100
, max(case when ct.census_tra = '4082' then 1 else 0 end) as census_tra_408200
, max(case when ct.census_tra = '4083' then 1 else 0 end) as census_tra_408300
, max(case when ct.census_tra = '4084' then 1 else 0 end) as census_tra_408400
, max(case when ct.census_tra = '4085' then 1 else 0 end) as census_tra_408500
, max(case when ct.census_tra = '4086' then 1 else 0 end) as census_tra_408600
, max(case when ct.census_tra = '4087' then 1 else 0 end) as census_tra_408700
, max(case when ct.census_tra = '4088' then 1 else 0 end) as census_tra_408800
, max(case when ct.census_tra = '4089' then 1 else 0 end) as census_tra_408900
, max(case when ct.census_tra = '4090' then 1 else 0 end) as census_tra_409000
, max(case when ct.census_tra = '4091' then 1 else 0 end) as census_tra_409100
, max(case when ct.census_tra = '4092' then 1 else 0 end) as census_tra_409200
, max(case when ct.census_tra = '4093' then 1 else 0 end) as census_tra_409300
, max(case when ct.census_tra = '4094' then 1 else 0 end) as census_tra_409400
, max(case when ct.census_tra = '4095' then 1 else 0 end) as census_tra_409500
, max(case when ct.census_tra = '4096' then 1 else 0 end) as census_tra_409600
, max(case when ct.census_tra = '4097' then 1 else 0 end) as census_tra_409700
, max(case when ct.census_tra = '4098' then 1 else 0 end) as census_tra_409800
, max(case when ct.census_tra = '4099' then 1 else 0 end) as census_tra_409900
, max(case when ct.census_tra = '4100' then 1 else 0 end) as census_tra_410000
, max(case when ct.census_tra = '4101' then 1 else 0 end) as census_tra_410100
, max(case when ct.census_tra = '4102' then 1 else 0 end) as census_tra_410200
, max(case when ct.census_tra = '4103' then 1 else 0 end) as census_tra_410300
, max(case when ct.census_tra = '4104' then 1 else 0 end) as census_tra_410400
, max(case when ct.census_tra = '4105' then 1 else 0 end) as census_tra_410500
, max(case when ct.census_tra = '9819' then 1 else 0 end) as census_tra_981900
, max(case when ct.census_tra = '9820' then 1 else 0 end) as census_tra_982000
, max(case when ct.census_tra = '9832' then 1 else 0 end) as census_tra_983200
from cells c
left join census_tracts ct 
	on ST_INTERSECTS(c.geom4326, ct.geom4326)
group by c.cell_id
;
*/

--update crime cells 
alter table crime_all drop column cell_id; 
alter table crime_all add column cell_id integer;

update crime_all c
	set cell_id = A.cell_id
	FROM cells as A 
	WHERE  ST_WITHIN (c.geom, A.geom4326)
	and c.cell_id is null and c.geom is not null
	;





