#!/bin/bash -e
code=$WC_TRAIN/20.Code/$WC_CITY

input=$WC_JOB_DIR/10.download_data
output=$WC_JOB_DIR/20.output

sql_cmd="psql -h $WC_PG_HOST -U accountname $WC_CITY"

crime_csv_delim=","

# mkdir -p $output

default_crime() {
	crime_csv=$input/${WC_CITY}_crime.csv 
	echo $crime_csv
	$sql_cmd -c "\COPY crime_import FROM '$crime_csv' DELIMITER '${crime_csv_delim}' CSV header;"
	$sql_cmd -f "$code/10.crime_upsert.sql"
}
default_weather() {
	weather_csv=$input/${WC_CITY}_weather.csv
	$sql_cmd -c "\COPY weather_import FROM '$weather_csv' DELIMITER ',' CSV header;"
	$sql_cmd -f "$code/20.weather_upsert.sql"
}
if [ $WC_CITY = "philadelphia_pa" ]; then
	default_crime
	default_weather

else
	"$WC_CITY unimplemented"
	exit 1
fi





