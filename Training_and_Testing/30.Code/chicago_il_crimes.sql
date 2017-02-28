with crime_ones AS (
  select c.cell_id, date_trunc('hour',c.hr) as hr, SUM(COALESCE(  {{crime_sql}}  ,0)) as crime_count
  from crime c
    INNER JOIN weather w ON date_trunc('hour',c.hr) = w.hr
  where c.hr between {{start_date_sql}}::timestamp and {{end_date_sql}}::timestamp
  and c.cell_id is not null
  and {{crime_sql}} > 0   
  group by date_trunc('hour',c.hr), c.cell_id
),
crime_zero_oversample_size AS (
  select c.cell_id, hourstart_series as hr, 0 as crime_count
  from cell_census_tract_bins c
  INNER JOIN generate_series 
    ( {{start_date_sql}} ::timestamp 
    , {{end_date_sql}} ::timestamp
    , '1 hour' ::interval) hourstart_series on 1=1
  INNER JOIN weather w ON hourstart_series = w.hr
  order by random()
  limit (select 3 * count(1) from crime_ones)
),
crime_zeroes AS (
  select z.*
  from crime_zero_oversample_size z
  where (z.cell_id, z.hr) not in (select cell_id, hr from crime_ones) 
  order by random()
  limit (select count(1) from crime_ones)
),
crime_balanced AS (
  select * from crime_ones
  union all
  select * from crime_zeroes
),

crime_all AS (

    select c.cell_id, hr_ser as hr, SUM(COALESCE(  {{crime_sql}}  ,0)) as crime_count
    
    from cell_census_tract_bins c
    INNER JOIN generate_series 
    ( {{start_date_sql}} ::timestamp 
    , {{end_date_sql}} ::timestamp
    , '1 hour' ::interval) hr_ser on 1=1
    left join crime cr
        on c.cell_id = cr.cell_id and hr_ser = cr.hr
    group by c.cell_id, hr_ser
),

weather_deltas AS (
  select ts.ts as hr
  , LAG(w.drybulb_fahrenheit, 24*1) OVER( order by ts.ts) as dod1_drybulb_fahrenheit
  , LAG(w.drybulb_fahrenheit, 24*2) OVER( order by ts.ts) as dod2_drybulb_fahrenheit
  , LAG(w.drybulb_fahrenheit, 24*3) OVER( order by ts.ts) as dod3_drybulb_fahrenheit
  , LAG(w.drybulb_fahrenheit, 24*7*1) OVER( order by ts.ts) as wow1_drybulb_fahrenheit
  , LAG(w.drybulb_fahrenheit, 24*7*2) OVER( order by ts.ts) as wow2_drybulb_fahrenheit
  from generate_series 
    ( {{start_date_sql}}::timestamp - INTERVAL '2 week'
    , {{end_date_sql}}::timestamp
    , '1 hour' ::interval) as ts
  left join weather w on ts.ts = w.hr
),
hour_prec_history AS (
 select hourstart_series2
  , sum (
    case when w.hr between hourstart_series2 - INTERVAL '1 day' and hourstart_series2 then 1 else 0 end
    ) as precip_hour_cnt_in_last_1_day
  , sum (
    case when w.hr between hourstart_series2 - INTERVAL '3 day' and hourstart_series2 then 1 else 0 end
    ) as precip_hour_cnt_in_last_3_day
  , sum (
    case when w.hr between hourstart_series2 - INTERVAL '1 week' and hourstart_series2 then 1 else 0 end
    ) as precip_hour_cnt_in_last_1_week
  , EXTRACT(EPOCH FROM hourstart_series2 - max(w.hr))/3600 as hour_count_since_precip
  from generate_series ( 
      {{start_date_sql}} ::timestamp
      , {{end_date_sql}} ::timestamp
      , '1 hour' ::interval) hourstart_series2
  inner join weather w on w.hr between hourstart_series2 - INTERVAL '8 week' and hourstart_series2
  where w.hourly_precip > 0
  group by hourstart_series2
)

SELECT 
c.cell_id, 
cast(c.hr as date) as dt, 
COALESCE(c.crime_count,0) as crime_count,
-1 as placeholder_1,
-1 as placeholder_2,

date_part('year', c.hr)as year,
date_part('hour', c.hr)as hournumber,
w.*,
wd.dod1_drybulb_fahrenheit,
wd.dod2_drybulb_fahrenheit,
wd.dod3_drybulb_fahrenheit,
wd.wow1_drybulb_fahrenheit,
wd.wow2_drybulb_fahrenheit,
hour_prec_history.precip_hour_cnt_in_last_1_day,
hour_prec_history.precip_hour_cnt_in_last_3_day,
hour_prec_history.precip_hour_cnt_in_last_1_week,
hour_prec_history.hour_count_since_precip,
date_part('month', c.hr)as month_of_year,
extract(DOW FROM c.hr)as day_of_week

/*note that monday is 1*/
/* generate these from ${city}_cell_setup.sql */
 ,census_tra_000000   
 ,census_tra_010200   
 ,census_tra_010300   
 ,census_tra_010400   
 ,census_tra_010500   
 ,census_tra_010600   
 ,census_tra_010700   
 ,census_tra_010800   
 ,census_tra_010900   
 ,census_tra_020100   
 ,census_tra_020200   
 ,census_tra_020300   
 ,census_tra_020400   
 ,census_tra_020500   
 ,census_tra_020600   
 ,census_tra_020700   
 ,census_tra_020800   
 ,census_tra_020900   
 ,census_tra_030100   
 ,census_tra_030200   
 ,census_tra_030300   
 ,census_tra_030400   
 ,census_tra_030500   
 ,census_tra_030600   
 ,census_tra_030700   
 ,census_tra_030800   
 ,census_tra_030900   
 ,census_tra_031000   
 ,census_tra_031100   
 ,census_tra_031200   
 ,census_tra_031300   
 ,census_tra_031400   
 ,census_tra_031500   
 ,census_tra_031600   
 ,census_tra_031800   
 ,census_tra_031900   
 ,census_tra_032000   
 ,census_tra_032100   
 ,census_tra_040100   
 ,census_tra_040200   
 ,census_tra_040300   
 ,census_tra_040400   
 ,census_tra_040500   
 ,census_tra_040600   
 ,census_tra_040700   
 ,census_tra_040800   
 ,census_tra_040900   
 ,census_tra_041000   
 ,census_tra_050100   
 ,census_tra_050200   
 ,census_tra_050300   
 ,census_tra_050400   
 ,census_tra_050500   
 ,census_tra_050600   
 ,census_tra_050700   
 ,census_tra_050800   
 ,census_tra_050900   
 ,census_tra_051000   
 ,census_tra_051100   
 ,census_tra_051200   
 ,census_tra_051300   
 ,census_tra_051400   
 ,census_tra_051500   
 ,census_tra_060100   
 ,census_tra_060200   
 ,census_tra_060300   
 ,census_tra_060400   
 ,census_tra_060500   
 ,census_tra_060600   
 ,census_tra_060700   
 ,census_tra_060800   
 ,census_tra_060900   
 ,census_tra_061000   
 ,census_tra_061100   
 ,census_tra_061200   
 ,census_tra_061300   
 ,census_tra_061400   
 ,census_tra_061500   
 ,census_tra_061600   
 ,census_tra_061700   
 ,census_tra_061800   
 ,census_tra_061900   
 ,census_tra_062000   
 ,census_tra_062100   
 ,census_tra_062200   
 ,census_tra_062300   
 ,census_tra_062400   
 ,census_tra_062500   
 ,census_tra_062600   
 ,census_tra_062700   
 ,census_tra_062800   
 ,census_tra_062900   
 ,census_tra_063000   
 ,census_tra_063100   
 ,census_tra_063200   
 ,census_tra_063300   
 ,census_tra_063400   
 ,census_tra_070100   
 ,census_tra_070200   
 ,census_tra_070300   
 ,census_tra_070400   
 ,census_tra_070500   
 ,census_tra_070600   
 ,census_tra_070700   
 ,census_tra_070800   
 ,census_tra_070900   
 ,census_tra_071000   
 ,census_tra_071100   
 ,census_tra_071200   
 ,census_tra_071300   
 ,census_tra_071400   
 ,census_tra_071500   
 ,census_tra_071600   
 ,census_tra_071700   
 ,census_tra_071800   
 ,census_tra_071900   
 ,census_tra_072000   
 ,census_tra_080100   
 ,census_tra_080200   
 ,census_tra_080300   
 ,census_tra_080400   
 ,census_tra_080500   
 ,census_tra_080600   
 ,census_tra_080700   
 ,census_tra_080800   
 ,census_tra_080900   
 ,census_tra_081000   
 ,census_tra_081100   
 ,census_tra_081200   
 ,census_tra_081300   
 ,census_tra_081400   
 ,census_tra_081500   
 ,census_tra_081600   
 ,census_tra_081700   
 ,census_tra_081800   
 ,census_tra_081900   
 ,census_tra_090100   
 ,census_tra_090200   
 ,census_tra_090300   
 ,census_tra_100100   
 ,census_tra_100200   
 ,census_tra_100300   
 ,census_tra_100400   
 ,census_tra_100500   
 ,census_tra_100600   
 ,census_tra_100700   
 ,census_tra_110100   
 ,census_tra_110200   
 ,census_tra_110300   
 ,census_tra_110400   
 ,census_tra_110500   
 ,census_tra_120100   
 ,census_tra_120200   
 ,census_tra_120300   
 ,census_tra_120400   
 ,census_tra_130100   
 ,census_tra_130200   
 ,census_tra_130300   
 ,census_tra_130400   
 ,census_tra_130500   
 ,census_tra_140100   
 ,census_tra_140200   
 ,census_tra_140300   
 ,census_tra_140400   
 ,census_tra_140500   
 ,census_tra_140600   
 ,census_tra_140700   
 ,census_tra_140800   
 ,census_tra_150100   
 ,census_tra_150200   
 ,census_tra_150300   
 ,census_tra_150400   
 ,census_tra_150500   
 ,census_tra_150600   
 ,census_tra_150700   
 ,census_tra_150800   
 ,census_tra_150900   
 ,census_tra_151000   
 ,census_tra_151100   
 ,census_tra_151200   
 ,census_tra_160100   
 ,census_tra_160200   
 ,census_tra_160300   
 ,census_tra_160400   
 ,census_tra_160500   
 ,census_tra_160600   
 ,census_tra_160700   
 ,census_tra_160800   
 ,census_tra_160900   
 ,census_tra_161000   
 ,census_tra_161100   
 ,census_tra_161200   
 ,census_tra_161300   
 ,census_tra_170100   
 ,census_tra_170200   
 ,census_tra_170300   
 ,census_tra_170400   
 ,census_tra_170500   
 ,census_tra_170600   
 ,census_tra_170700   
 ,census_tra_170800   
 ,census_tra_170900   
 ,census_tra_171000   
 ,census_tra_171100   
 ,census_tra_180100   
 ,census_tra_180200   
 ,census_tra_180300   
 ,census_tra_190100   
 ,census_tra_190200   
 ,census_tra_190300   
 ,census_tra_190400   
 ,census_tra_190500   
 ,census_tra_190600   
 ,census_tra_190700   
 ,census_tra_190800   
 ,census_tra_190900   
 ,census_tra_191000   
 ,census_tra_191100   
 ,census_tra_191200   
 ,census_tra_191400   
 ,census_tra_200100   
 ,census_tra_200200   
 ,census_tra_200300   
 ,census_tra_200400   
 ,census_tra_200500   
 ,census_tra_200600   
 ,census_tra_210100   
 ,census_tra_210200   
 ,census_tra_210300   
 ,census_tra_210400   
 ,census_tra_210500   
 ,census_tra_210600   
 ,census_tra_210700   
 ,census_tra_210800   
 ,census_tra_210900   
 ,census_tra_220100   
 ,census_tra_220200   
 ,census_tra_220300   
 ,census_tra_220400   
 ,census_tra_220500   
 ,census_tra_220600   
 ,census_tra_220700   
 ,census_tra_220800   
 ,census_tra_220900   
 ,census_tra_221000   
 ,census_tra_221100   
 ,census_tra_221200   
 ,census_tra_221300   
 ,census_tra_221400   
 ,census_tra_221500   
 ,census_tra_221600   
 ,census_tra_221700   
 ,census_tra_221800   
 ,census_tra_221900   
 ,census_tra_222000   
 ,census_tra_222100   
 ,census_tra_222200   
 ,census_tra_222300   
 ,census_tra_222400   
 ,census_tra_222500   
 ,census_tra_222600   
 ,census_tra_222700   
 ,census_tra_222800   
 ,census_tra_222900   
 ,census_tra_230100   
 ,census_tra_230200   
 ,census_tra_230300   
 ,census_tra_230400   
 ,census_tra_230500   
 ,census_tra_230600   
 ,census_tra_230700   
 ,census_tra_230800   
 ,census_tra_230900   
 ,census_tra_231000   
 ,census_tra_231100   
 ,census_tra_231200   
 ,census_tra_231300   
 ,census_tra_231400   
 ,census_tra_231500   
 ,census_tra_231600   
 ,census_tra_231700   
 ,census_tra_231800   
 ,census_tra_240100   
 ,census_tra_240200   
 ,census_tra_240300   
 ,census_tra_240400   
 ,census_tra_240500   
 ,census_tra_240600   
 ,census_tra_240700   
 ,census_tra_240800   
 ,census_tra_240900   
 ,census_tra_241000   
 ,census_tra_241100   
 ,census_tra_241200   
 ,census_tra_241300   
 ,census_tra_241400   
 ,census_tra_241500   
 ,census_tra_241600   
 ,census_tra_241700   
 ,census_tra_241800   
 ,census_tra_241900   
 ,census_tra_242000   
 ,census_tra_242100   
 ,census_tra_242200   
 ,census_tra_242300   
 ,census_tra_242400   
 ,census_tra_242500   
 ,census_tra_242600   
 ,census_tra_242700   
 ,census_tra_242800   
 ,census_tra_242900   
 ,census_tra_243000   
 ,census_tra_243100   
 ,census_tra_243200   
 ,census_tra_243300   
 ,census_tra_243400   
 ,census_tra_243500   
 ,census_tra_243600   
 ,census_tra_250100   
 ,census_tra_250200   
 ,census_tra_250300   
 ,census_tra_250400   
 ,census_tra_250500   
 ,census_tra_250600   
 ,census_tra_250700   
 ,census_tra_250800   
 ,census_tra_250900   
 ,census_tra_251000   
 ,census_tra_251200   
 ,census_tra_251300   
 ,census_tra_251400   
 ,census_tra_251500   
 ,census_tra_251600   
 ,census_tra_251700   
 ,census_tra_251800   
 ,census_tra_251900   
 ,census_tra_252000   
 ,census_tra_252100   
 ,census_tra_252200   
 ,census_tra_252300   
 ,census_tra_252400   
 ,census_tra_260100   
 ,census_tra_260200   
 ,census_tra_260300   
 ,census_tra_260400   
 ,census_tra_260500   
 ,census_tra_260600   
 ,census_tra_260700   
 ,census_tra_260800   
 ,census_tra_260900   
 ,census_tra_261000   
 ,census_tra_270100   
 ,census_tra_270200   
 ,census_tra_270300   
 ,census_tra_270400   
 ,census_tra_270500   
 ,census_tra_270600   
 ,census_tra_270700   
 ,census_tra_270800   
 ,census_tra_270900   
 ,census_tra_271000   
 ,census_tra_271100   
 ,census_tra_271200   
 ,census_tra_271300   
 ,census_tra_271400   
 ,census_tra_271500   
 ,census_tra_271600   
 ,census_tra_271700   
 ,census_tra_271800   
 ,census_tra_271900   
 ,census_tra_280100   
 ,census_tra_280200   
 ,census_tra_280300   
 ,census_tra_280400   
 ,census_tra_280500   
 ,census_tra_280600   
 ,census_tra_280700   
 ,census_tra_280800   
 ,census_tra_280900   
 ,census_tra_281000   
 ,census_tra_281100   
 ,census_tra_281200   
 ,census_tra_281300   
 ,census_tra_281400   
 ,census_tra_281500   
 ,census_tra_281600   
 ,census_tra_281700   
 ,census_tra_281800   
 ,census_tra_281900   
 ,census_tra_282000   
 ,census_tra_282100   
 ,census_tra_282200   
 ,census_tra_282300   
 ,census_tra_282400   
 ,census_tra_282500   
 ,census_tra_282600   
 ,census_tra_282700   
 ,census_tra_282800   
 ,census_tra_282900   
 ,census_tra_283000   
 ,census_tra_283100   
 ,census_tra_283200   
 ,census_tra_283300   
 ,census_tra_283400   
 ,census_tra_283500   
 ,census_tra_283600   
 ,census_tra_283700   
 ,census_tra_283800   
 ,census_tra_283900   
 ,census_tra_284000   
 ,census_tra_284100   
 ,census_tra_284200   
 ,census_tra_284300   
 ,census_tra_290100   
 ,census_tra_290200   
 ,census_tra_290300   
 ,census_tra_290400   
 ,census_tra_290500   
 ,census_tra_290600   
 ,census_tra_290700   
 ,census_tra_290800   
 ,census_tra_290900   
 ,census_tra_291000   
 ,census_tra_291100   
 ,census_tra_291200   
 ,census_tra_291300   
 ,census_tra_291400   
 ,census_tra_291500   
 ,census_tra_291600   
 ,census_tra_291700   
 ,census_tra_291800   
 ,census_tra_291900   
 ,census_tra_292000   
 ,census_tra_292100   
 ,census_tra_292200   
 ,census_tra_292300   
 ,census_tra_292400   
 ,census_tra_292500   
 ,census_tra_292600   
 ,census_tra_292700   
 ,census_tra_300100   
 ,census_tra_300200   
 ,census_tra_300300   
 ,census_tra_300400   
 ,census_tra_300500   
 ,census_tra_300600   
 ,census_tra_300700   
 ,census_tra_300800   
 ,census_tra_300900   
 ,census_tra_301000   
 ,census_tra_301100   
 ,census_tra_301200   
 ,census_tra_301300   
 ,census_tra_301400   
 ,census_tra_301500   
 ,census_tra_301600   
 ,census_tra_301700   
 ,census_tra_301800   
 ,census_tra_301900   
 ,census_tra_302000   
 ,census_tra_310100   
 ,census_tra_310200   
 ,census_tra_310300   
 ,census_tra_310400   
 ,census_tra_310500   
 ,census_tra_310600   
 ,census_tra_310700   
 ,census_tra_310800   
 ,census_tra_310900   
 ,census_tra_311000   
 ,census_tra_311100   
 ,census_tra_311200   
 ,census_tra_311300   
 ,census_tra_311400   
 ,census_tra_311500   
 ,census_tra_320100   
 ,census_tra_320200   
 ,census_tra_320300   
 ,census_tra_320400   
 ,census_tra_320500   
 ,census_tra_320600   
 ,census_tra_330100   
 ,census_tra_330200   
 ,census_tra_330300   
 ,census_tra_330400   
 ,census_tra_330500   
 ,census_tra_340100   
 ,census_tra_340200   
 ,census_tra_340300   
 ,census_tra_340400   
 ,census_tra_340500   
 ,census_tra_340600   
 ,census_tra_350100   
 ,census_tra_350200   
 ,census_tra_350300   
 ,census_tra_350400   
 ,census_tra_350500   
 ,census_tra_350600   
 ,census_tra_350700   
 ,census_tra_350800   
 ,census_tra_350900   
 ,census_tra_351000   
 ,census_tra_351100   
 ,census_tra_351200   
 ,census_tra_351300   
 ,census_tra_351400   
 ,census_tra_351500   
 ,census_tra_360100   
 ,census_tra_360200   
 ,census_tra_360300   
 ,census_tra_360400   
 ,census_tra_360500   
 ,census_tra_370100   
 ,census_tra_370200   
 ,census_tra_370300   
 ,census_tra_370400   
 ,census_tra_380100   
 ,census_tra_380200   
 ,census_tra_380300   
 ,census_tra_380400   
 ,census_tra_380500   
 ,census_tra_380600   
 ,census_tra_380700   
 ,census_tra_380800   
 ,census_tra_380900   
 ,census_tra_381000   
 ,census_tra_381100   
 ,census_tra_381200   
 ,census_tra_381300   
 ,census_tra_381400   
 ,census_tra_381500   
 ,census_tra_381600   
 ,census_tra_381700   
 ,census_tra_381800   
 ,census_tra_381900   
 ,census_tra_382000   
 ,census_tra_390100   
 ,census_tra_390200   
 ,census_tra_390300   
 ,census_tra_390400   
 ,census_tra_390500   
 ,census_tra_390600   
 ,census_tra_390700   
 ,census_tra_400100   
 ,census_tra_400200   
 ,census_tra_400300   
 ,census_tra_400400   
 ,census_tra_400500   
 ,census_tra_400600   
 ,census_tra_400700   
 ,census_tra_400800   
 ,census_tra_410100   
 ,census_tra_410200   
 ,census_tra_410300   
 ,census_tra_410400   
 ,census_tra_410500   
 ,census_tra_410600   
 ,census_tra_410700   
 ,census_tra_410800   
 ,census_tra_410900   
 ,census_tra_411000   
 ,census_tra_411100   
 ,census_tra_411200   
 ,census_tra_411300   
 ,census_tra_411400   
 ,census_tra_420100   
 ,census_tra_420200   
 ,census_tra_420300   
 ,census_tra_420400   
 ,census_tra_420500   
 ,census_tra_420600   
 ,census_tra_420700   
 ,census_tra_420800   
 ,census_tra_420900   
 ,census_tra_421000   
 ,census_tra_421100   
 ,census_tra_421200   
 ,census_tra_430100   
 ,census_tra_430200   
 ,census_tra_430300   
 ,census_tra_430400   
 ,census_tra_430500   
 ,census_tra_430600   
 ,census_tra_430700   
 ,census_tra_430800   
 ,census_tra_430900   
 ,census_tra_431000   
 ,census_tra_431100   
 ,census_tra_431200   
 ,census_tra_431300   
 ,census_tra_431400   
 ,census_tra_440100   
 ,census_tra_440200   
 ,census_tra_440300   
 ,census_tra_440400   
 ,census_tra_440500   
 ,census_tra_440600   
 ,census_tra_440700   
 ,census_tra_440800   
 ,census_tra_440900   
 ,census_tra_450100   
 ,census_tra_450200   
 ,census_tra_450300   
 ,census_tra_460100   
 ,census_tra_460200   
 ,census_tra_460300   
 ,census_tra_460400   
 ,census_tra_460500   
 ,census_tra_460600   
 ,census_tra_460700   
 ,census_tra_460900   
 ,census_tra_461000   
 ,census_tra_470100   
 ,census_tra_480100   
 ,census_tra_480200   
 ,census_tra_480300   
 ,census_tra_480400   
 ,census_tra_480500   
 ,census_tra_490100   
 ,census_tra_490200   
 ,census_tra_490300   
 ,census_tra_490400   
 ,census_tra_490500   
 ,census_tra_490600   
 ,census_tra_490700   
 ,census_tra_490800   
 ,census_tra_490900   
 ,census_tra_491000   
 ,census_tra_491100   
 ,census_tra_491200   
 ,census_tra_491300   
 ,census_tra_491400   
 ,census_tra_500100   
 ,census_tra_500200   
 ,census_tra_500300   
 ,census_tra_510100   
 ,census_tra_510200   
 ,census_tra_510300   
 ,census_tra_510400   
 ,census_tra_510500   
 ,census_tra_520100   
 ,census_tra_520200   
 ,census_tra_520300   
 ,census_tra_520400   
 ,census_tra_520500   
 ,census_tra_520600   
 ,census_tra_530100   
 ,census_tra_530200   
 ,census_tra_530300   
 ,census_tra_530400   
 ,census_tra_530500   
 ,census_tra_530600   
 ,census_tra_540100   
 ,census_tra_550100   
 ,census_tra_550200   
 ,census_tra_560100   
 ,census_tra_560200   
 ,census_tra_560300   
 ,census_tra_560400   
 ,census_tra_560500   
 ,census_tra_560600   
 ,census_tra_560700   
 ,census_tra_560800   
 ,census_tra_560900   
 ,census_tra_561000   
 ,census_tra_561100   
 ,census_tra_561200   
 ,census_tra_561300   
 ,census_tra_570100   
 ,census_tra_570200   
 ,census_tra_570300   
 ,census_tra_570400   
 ,census_tra_570500   
 ,census_tra_580100   
 ,census_tra_580200   
 ,census_tra_580300   
 ,census_tra_580400   
 ,census_tra_580500   
 ,census_tra_580600   
 ,census_tra_580700   
 ,census_tra_580800   
 ,census_tra_580900   
 ,census_tra_581000   
 ,census_tra_581100   
 ,census_tra_590100   
 ,census_tra_590200   
 ,census_tra_590300   
 ,census_tra_590400   
 ,census_tra_590500   
 ,census_tra_590600   
 ,census_tra_590700   
 ,census_tra_600100   
 ,census_tra_600200   
 ,census_tra_600300   
 ,census_tra_600400   
 ,census_tra_600500   
 ,census_tra_600600   
 ,census_tra_600700   
 ,census_tra_600800   
 ,census_tra_600900   
 ,census_tra_601000   
 ,census_tra_601100   
 ,census_tra_601200   
 ,census_tra_601300   
 ,census_tra_601400   
 ,census_tra_601500   
 ,census_tra_601600   
 ,census_tra_610100   
 ,census_tra_610200   
 ,census_tra_610300   
 ,census_tra_610400   
 ,census_tra_610500   
 ,census_tra_610600   
 ,census_tra_610700   
 ,census_tra_610800   
 ,census_tra_610900   
 ,census_tra_611000   
 ,census_tra_611100   
 ,census_tra_611200   
 ,census_tra_611300   
 ,census_tra_611400   
 ,census_tra_611500   
 ,census_tra_611600   
 ,census_tra_611700   
 ,census_tra_611800   
 ,census_tra_611900   
 ,census_tra_612000   
 ,census_tra_612100   
 ,census_tra_612200   
 ,census_tra_620100   
 ,census_tra_620200   
 ,census_tra_620300   
 ,census_tra_620400   
 ,census_tra_630100   
 ,census_tra_630200   
 ,census_tra_630300   
 ,census_tra_630400   
 ,census_tra_630500   
 ,census_tra_630600   
 ,census_tra_630700   
 ,census_tra_630800   
 ,census_tra_630900   
 ,census_tra_640100   
 ,census_tra_640200   
 ,census_tra_640300   
 ,census_tra_640400   
 ,census_tra_640500   
 ,census_tra_640600   
 ,census_tra_640700   
 ,census_tra_640800   
 ,census_tra_650100   
 ,census_tra_650200   
 ,census_tra_650300   
 ,census_tra_650400   
 ,census_tra_650500   
 ,census_tra_660100   
 ,census_tra_660200   
 ,census_tra_660300   
 ,census_tra_660400   
 ,census_tra_660500   
 ,census_tra_660600   
 ,census_tra_660700   
 ,census_tra_660800   
 ,census_tra_660900   
 ,census_tra_661000   
 ,census_tra_661100   
 ,census_tra_670100   
 ,census_tra_670200   
 ,census_tra_670300   
 ,census_tra_670400   
 ,census_tra_670500   
 ,census_tra_670600   
 ,census_tra_670700   
 ,census_tra_670800   
 ,census_tra_670900   
 ,census_tra_671000   
 ,census_tra_671100   
 ,census_tra_671200   
 ,census_tra_671300   
 ,census_tra_671400   
 ,census_tra_671500   
 ,census_tra_671600   
 ,census_tra_671700   
 ,census_tra_671800   
 ,census_tra_671900   
 ,census_tra_672000   
 ,census_tra_680100   
 ,census_tra_680200   
 ,census_tra_680300   
 ,census_tra_680400   
 ,census_tra_680500   
 ,census_tra_680600   
 ,census_tra_680700   
 ,census_tra_680800   
 ,census_tra_680900   
 ,census_tra_681000   
 ,census_tra_681100   
 ,census_tra_681200   
 ,census_tra_681300   
 ,census_tra_681400   
 ,census_tra_690100   
 ,census_tra_690200   
 ,census_tra_690300   
 ,census_tra_690400   
 ,census_tra_690500   
 ,census_tra_690600   
 ,census_tra_690700   
 ,census_tra_690800   
 ,census_tra_690900   
 ,census_tra_691000   
 ,census_tra_691100   
 ,census_tra_691200   
 ,census_tra_691300   
 ,census_tra_691400   
 ,census_tra_691500   
 ,census_tra_700100   
 ,census_tra_700200   
 ,census_tra_700300   
 ,census_tra_700400   
 ,census_tra_700500   
 ,census_tra_710100   
 ,census_tra_710200   
 ,census_tra_710300   
 ,census_tra_710400   
 ,census_tra_710500   
 ,census_tra_710600   
 ,census_tra_710700   
 ,census_tra_710800   
 ,census_tra_710900   
 ,census_tra_711000   
 ,census_tra_711100   
 ,census_tra_711200   
 ,census_tra_711300   
 ,census_tra_711400   
 ,census_tra_711500   
 ,census_tra_720100   
 ,census_tra_720200   
 ,census_tra_720300   
 ,census_tra_720400   
 ,census_tra_720600   
 ,census_tra_720700   
 ,census_tra_730100   
 ,census_tra_730200   
 ,census_tra_730300   
 ,census_tra_730400   
 ,census_tra_730500   
 ,census_tra_730600   
 ,census_tra_730700   
 ,census_tra_740100   
 ,census_tra_740200   
 ,census_tra_740300   
 ,census_tra_740400   
 ,census_tra_750100   
 ,census_tra_750200   
 ,census_tra_750300   
 ,census_tra_750400   
 ,census_tra_750500   
 ,census_tra_750600   
 ,census_tra_760800   
 ,census_tra_760900   
 ,census_tra_770600   
 ,census_tra_770700   
 ,census_tra_770800   
 ,census_tra_770900   
 ,census_tra_808100   
 ,census_tra_810400   
 ,census_tra_810501   
 ,census_tra_811600   
 ,census_tra_820800   
 ,census_tra_821500   
 ,census_tra_823304   
 ,census_tra_840000   


FROM 
{{ crime_data_set }} c
left join cell_census_tract_bins ct_bins
    on c.cell_id = ct_bins.cell_id

INNER JOIN weather w ON c.hr = w.hr
LEFT JOIN weather_deltas wd ON c.hr = wd.hr

left join hour_prec_history
  on c.hr = hour_prec_history.hourstart_series2



