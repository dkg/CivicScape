

CREATE TABLE weather_import
(
wind_speed varchar(100),
sealevel_pressure varchar(100),
old_station_type varchar(100),
station_type varchar(100),
sky_condition varchar(100),
wind_direction varchar(100),
sky_condition_top varchar(100),
visibility varchar(100),
dttime timestamp without time zone,
wind_direction_cardinal varchar(100),
relative_humidity varchar(100),
hourly_precip varchar(100),
drybulb_fahrenheit varchar(100),
report_type varchar(100),
dewpoint_fahrenheit varchar(100),
station_pressure varchar(100),
weather_types varchar(500),
wetbulb_fahrenheit varchar(100),
wban_code integer
) ;


CREATE INDEX ix_weather_i_station ON weather_import (wban_code, dttime);

CREATE INDEX ix_weather_i_time ON weather_import (dttime, wind_speed, drybulb_fahrenheit, hourly_precip, relative_humidity, weather_types);

CREATE TABLE weather_import_log
(
wind_speed varchar(100),
sealevel_pressure varchar(100),
old_station_type varchar(100),
station_type varchar(100),
sky_condition varchar(100),
wind_direction varchar(100),
sky_condition_top varchar(100),
visibility varchar(100),
dttime timestamp without time zone,
wind_direction_cardinal varchar(100),
relative_humidity varchar(100),
hourly_precip varchar(100),
drybulb_fahrenheit varchar(100),
report_type varchar(100),
dewpoint_fahrenheit varchar(100),
station_pressure varchar(100),
weather_types varchar(500),
wetbulb_fahrenheit varchar(100),
wban_code integer
) ;


CREATE UNIQUE INDEX ix_weather_log_station ON weather_import_log (wban_code, dttime);


create table weather (
	hr timestamp not null primary key
	, wind_speed numeric(18,4)
	, drybulb_fahrenheit numeric(18,4)
	, hourly_precip numeric(18,4)
	, relative_humidity numeric(18,4)
	, fz int
	, ra int
	, ts int
	, br int
	, sn int
	, hz int
	, dz int
	, pl int
	, fg int
	, sa int
	, up int
	, fu int
	, sq int
	, gs int

);

CREATE INDEX ix_weather_time ON weather (hr);

