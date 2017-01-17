#!/bin/bash -e
code=$WC_TRAIN/10.Code
work=$WC_JOB_DIR/10.work
output=$WC_JOB_DIR/10.download_data

mkdir -p $work $output

download_weathers() {

	for wban in $wbans; do
	for year in `seq $end_year $start_year`; do
	for month in `seq 12 1`; do
		out_file="$work/$wban.$year.$month.json"
		download_weather $wban $year $month $out_file

		echo "out file $out_file"
		file_size=`ls -l $out_file | awk '{print $5}'`
		echo $file_size
		if [ $file_size -gt 1024 ]; then
			weather_json_to_obs ${out_file} ${out_file}.obs
			json2csv -i ${out_file}.obs -k $weather_json_cols >> $weather_csv
		fi
		sleep .25
	done
	sleep 30
	done
	done
}
download_weather() {
	wban=$1
	year=$2
	month=$3
	out_file=$4
	#echo "downloading: ${wban} $year $month"
	nextmonth=$(($month + 1))
	nextyear=$year
	if [ $nextmonth -eq 13 ]; then
		nextmonth=1
		nextyear=$(($year + 1))
	fi
	url="http://plenar.io/v1/api/weather/hourly/?wban_code=$wban&datetime__ge=$year-$month-01&datetime__lt=$nextyear-$nextmonth-01"

	echo "Downloading weather to $out_file"
	echo "curl -o $work/$wban.$year.$month.json $url"
	curl -s -o $out_file "$url"
	echo "Downloaded $(ls -lh $out_file | awk '{print $5}') "

}
weather_json_to_obs() {
	obs_in_file=$1
	obs_out_file=$2
	jq -c '.objects[0].observations[]' $obs_in_file  > $obs_out_file
}

philadelphia_pa_crime() {
	crime_csv=$output/philadelphia_crime.csv 
	echo "Downloading crimes to $crime_csv"
	curl -o $crime_csv "https://data.phila.gov/resource/sspu-uyfa.json"	
}
philadelphia_pa_weather() {

	weather_csv=$output/${WC_CITY}_weather.csv
	weather_json_cols="wind_speed,sealevel_pressure,old_station_type,station_type,sky_condition,wind_direction,sky_condition_top,visibility,datetime,wind_direction_cardinal,relative_humidity,hourly_precip,drybulb_fahrenheit,report_type,dewpoint_fahrenheit,station_pressure,weather_types,wetbulb_fahrenheit,wban_code"
	echo $weather_json_cols > $weather_csv

	wbans="13739"
	start_year="2012"   # should be "2006"
	end_year="2016"
	download_weathers
}

philadelphia_pa_census() {
	echo "Get Shapefile from Maggie"
	#zip=$work/tracts.zip
	#wget https://www.opendataphilly.org/dataset/census-tracts -O $zip
	#unzip $zip -d $work
	shapefile="$work/Census_Tracts_2010.shp"
	sql=$output/census_tracts4326.sql
	shp2pgsql -s 4326 $shapefile census_tracts > $sql

	echo "CREATE INDEX ix_censustracts_geom ON census_tracts using GIST(geom); " >> $sql

}
philadelphia_pa_311() {
	311_csv=$output/philadelphia_311.csv 
	echo "Downloading crimes to $crime_csv"
	curl -o $311_csv "https://data.phila.gov/resource/4t9v-rppq.json"	
}



if [ $WC_CITY = "philadelphia_pa" ]; then
	philadelphia_pa_crime
	philadelphia_pa_weather
	philadelphia_pa_311
else
	"$WC_CITY unimplemented"
	exit 1
fi

